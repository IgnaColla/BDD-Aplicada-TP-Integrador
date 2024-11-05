-------------------------------------------------------------------
-------------------  Stored Procedures CATALOGO -------------------
-------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17
GO


CREATE OR ALTER PROCEDURE Productos.ImportarCategoriasDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
		DECLARE @SQL NVARCHAR(MAX);

		SET @SQL = N'BULK INSERT Productos.ClasificacionProducto
					FROM ''' + @RutaArchivo + ''' 
					WITH (
						FIELDTERMINATOR = '';'',  -- Cambia el separador según sea necesario
						ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila según sea necesario
						FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
						CODEPAGE = ''65001''
					);';
		EXEC sp_executesql @SQL;

		PRINT '+ Importación de categorias completada exitosamente.';
	END TRY
	BEGIN CATCH -- En caso de error
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importación de categorias: %s', 16, 1, @ErrorMessage);
	END CATCH;
END;


CREATE OR ALTER PROCEDURE Productos.ImportarCatalogoDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
		DECLARE @SQL NVARCHAR(MAX);

		SET @SQL = N'BULK INSERT Productos.Catalogo
					FROM ''' + @RutaArchivo + ''' 
					WITH (
						FIELDTERMINATOR = '';'',  -- Cambia el separador según sea necesario
						ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila según sea necesario
						FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
						CODEPAGE = ''65001''
					);';
		EXEC sp_executesql @SQL;
		
		PRINT '+ Importación del catálogo completada exitosamente.';
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importación del catálogo: %s', 16, 1, @ErrorMessage);
	END CATCH;
END;


CREATE OR ALTER PROCEDURE Productos.ImportarProductosImportadosDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @SQL NVARCHAR(MAX);

		-- Tabla temporal para depurar datos
		SELECT IdProducto,Nombre,Proveedor,Categoria,CantidadPorUnidad,
		CAST(PrecioUnitario AS VARCHAR(10)) AS Precio INTO #Importado from Productos.ProductoImportado

		SET @SQL = N'BULK INSERT #Importado
					FROM ''' + @RutaArchivo + ''' 
					WITH (
						FIELDTERMINATOR = '';'',  -- Cambia el separador según sea necesario
						ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila según sea necesario
						FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
						CODEPAGE = ''65001''
					);';
		EXEC sp_executesql @SQL;

		-- Carga de los datos a la tabla ProductoImportado
		INSERT INTO Productos.ProductoImportado (IdProducto, Nombre, Proveedor, Categoria, CantidadPorUnidad, PrecioUnitario)
		SELECT 
			IdProducto,
			Nombre,
			Proveedor,
			Categoria,
			CantidadPorUnidad,
			CAST(REPLACE(REPLACE(Precio, '$', ''), ',', '.') AS DECIMAL(10, 2)) AS Precio
		FROM #Importado;

		PRINT('+ Importación de Productos Importados completada exitosamente.');
	END TRY
	BEGIN CATCH -- En caso de error
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importación de Productos Importados: %s', 16, 1, @ErrorMessage);
	END CATCH;

	DROP TABLE IF EXISTS #Importado;
END;


CREATE OR ALTER PROCEDURE Productos.ImportarProductosElectronicosDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
		DECLARE @SQL NVARCHAR(MAX);

		-- Tabla temporal para depurar datos
		SELECT Producto, 
		CAST(PrecioUnitario AS VARCHAR(10)) AS Precio  INTO #Electronico from Productos.ProductoElectronico

		SET @SQL = N'BULK INSERT #Electronico
					FROM ''' + @RutaArchivo + ''' 
					WITH (
						FIELDTERMINATOR = '';'',  -- Cambia el separador según sea necesario
						ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila según sea necesario
						FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
						CODEPAGE = ''65001''
					);';
		EXEC sp_executesql @SQL;

		-- Carga de datos en la tabla ProductoElectronico
		INSERT INTO Productos.ProductoElectronico(Producto, PrecioUnitario)
		SELECT 
			Producto,
			CAST(REPLACE(Precio, ',', '.') AS DECIMAL(6, 2)) AS Precio
		FROM #Electronico;

		PRINT('+ Importación de Productos Electrónicos completada exitosamente.');
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importación de Productos Electrónicos: %s', 16, 1, @ErrorMessage);
	END CATCH;

	DROP TABLE IF EXISTS #Electronico;
END;


CREATE OR ALTER PROCEDURE Productos.CargarLineaProducto
AS
BEGIN
    SET NOCOUNT ON;

	BEGIN TRY
		-- Reiniciar el contador de identidad en la tabla LineaProducto
		DBCC CHECKIDENT ('Productos.LineaProducto', RESEED, 0);

		-- Inserta en LineaProducto solo las categorías únicas de ProductoImportado que aún no existen en LineaProducto
		INSERT INTO Productos.LineaProducto(Linea)
		SELECT DISTINCT Categoria
		FROM Productos.ProductoImportado AS pi
		WHERE Categoria IS NOT NULL
		  AND NOT EXISTS (
			  SELECT 1
			  FROM Productos.LineaProducto AS lp
			  WHERE lp.Linea = pi.Categoria
		  );

		INSERT INTO Productos.LineaProducto(Linea)
		SELECT DISTINCT LineaProducto
		FROM Productos.ClasificacionProducto AS cp
		WHERE LineaProducto IS NOT NULL
		  AND NOT EXISTS (
			  SELECT 1
			  FROM Productos.LineaProducto AS lp
			  WHERE lp.Linea = cp.LineaProducto
		  );

		PRINT('+ Carga de líneas de producto completada exitosamente.');
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la carga de Linea de Producto: %s', 16, 1, @ErrorMessage);
	END CATCH;
END;


-- #################### Ejecucion ####################

EXEC Productos.ImportarCategoriasDesdeCSV @RutaArchivo = '<Path_al_archivo>';
EXEC Productos.ImportarCatalogoDesdeCSV @RutaArchivo = '<Path_al_archivo>';
EXEC Productos.ImportarProductosImportadosDesdeCSV = '<Path_al_archivo>';
EXEC Productos.ImportarProductosElectronicosDesdeCSV = '<Path_al_archivo>';
