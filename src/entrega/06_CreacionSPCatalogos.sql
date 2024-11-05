-------------------------------------------------------------------
-------------------  Stored Procedures CATALOGO -------------------
-------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO

CREATE OR ALTER PROCEDURE Productos.ImportarCategoriasDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
         DECLARE @SQL NVARCHAR(MAX);

        CREATE TABLE #Clasificacion(
            LineaProducto VARCHAR(15),
            Categoria VARCHAR(40) UNIQUE
        )

        SET @SQL = N'BULK INSERT #Clasificacion
                    FROM ''' + @RutaArchivo + ''' 
                    WITH (
                        FIELDTERMINATOR = '';'',  -- Cambia el separador seg�n sea necesario
                        ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila seg�n sea necesario
                        FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
                        CODEPAGE = ''65001''
                    );';
        
        EXEC sp_executesql @SQL;

        INSERT INTO Productos.ClasificacionProducto(LineaProducto, Categoria)
        SELECT * FROM #Clasificacion

        INSERT INTO Productos.ClasificacionProducto(LineaProducto, Categoria)
        VALUES('Importado', 'importado'), ('Electronico', 'electronico')

        PRINT '+ Importación de categorias completada exitosamente.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importación de categorias: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE Productos.ImportarCatalogoProductoDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @SQL NVARCHAR(MAX);

        CREATE TABLE #Catalogo(
            Id INT,             
            Categoria VARCHAR(40),     
            Nombre VARCHAR(100),               
            Precio DECIMAL(10, 2),              
            PrecioRef DECIMAL(10, 2) ,    
            UnidadRef VARCHAR(10),       
            Fecha varchar(50)                     
            )

        SET @SQL = N'BULK INSERT #Catalogo
                    FROM ''' + @RutaArchivo + ''' 
                    WITH (
                        FIELDTERMINATOR = '';'',  -- Cambia el separador seg�n sea necesario
                        ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila seg�n sea necesario
                        FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
                        CODEPAGE = ''65001''
                    );';
        
        EXEC sp_executesql @SQL;

        INSERT INTO Productos.Producto
        SELECT DISTINCT Nombre, Precio FROM #Catalogo

        INSERT INTO Productos.Catalogo
        SELECT * FROM #Catalogo

        PRINT('+ Importación del catálogo completada exitosamente.');
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importación del catálogo: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE Productos.AgregarCatalogoProductosImportadosDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @SQL NVARCHAR(MAX);
        DECLARE @LastCatalogoID INT;

        -- Obtener el último ID de la tabla Catalogo
        SELECT @LastCatalogoID = ISNULL(MAX(Id), 0) FROM Productos.Catalogo;

        CREATE TABLE #ProductoImportado(
            IdProducto INT PRIMARY KEY,
            Nombre VARCHAR(50) NOT NULL,
            Proveedor VARCHAR(50) NOT NULL,
            Categoria VARCHAR(15),
            CantidadPorUnidad VARCHAR(25) NOT NULL,
            Price VARCHAR(10)
        )

        SET @SQL = N'BULK INSERT #ProductoImportado
                    FROM ''' + @RutaArchivo + ''' 
                    WITH (
                        FIELDTERMINATOR = '';'',  -- Cambia el separador según sea necesario
                        ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila según sea necesario
                        FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
                        CODEPAGE = ''65001''
                    );';
        
        EXEC sp_executesql @SQL;

        INSERT INTO Productos.Producto(Producto, Precio)
        SELECT DISTINCT Nombre, 
        CAST(REPLACE(REPLACE(Price, '$', ''), ',', '.') AS DECIMAL(10, 2)) AS Precio
        FROM #ProductoImportado

        ;WITH ProductosNoDuplicados AS (
        SELECT
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @LastCatalogoID AS Id,
            i.Nombre,
            i.Price
        FROM #ProductoImportado i
        LEFT JOIN Productos.Catalogo ca ON i.Nombre = ca.Nombre
        WHERE ca.Nombre IS NULL  -- Solo insertar productos que no existan en la tabla principal
        )

        INSERT INTO Productos.Catalogo(Id, Nombre, Precio, Categoria)
        select 
                Id, 
                Nombre, 
                CAST(REPLACE(REPLACE(Price, '$', ''), ',', '.') AS DECIMAL(10, 2)) AS Precio,
                'importado'
        from ProductosNoDuplicados

        DROP TABLE #ProductoImportado

        PRINT('+ Importación de Productos Importados completada exitosamente.');
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importación de Productos Importados: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE Productos.AgregarCatalogoProductosElectronicosDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @SQL NVARCHAR(MAX);	
        DECLARE @LastCatalogoID INT;

        -- Obtener el último ID de la tabla Catalogo
        SELECT @LastCatalogoID = ISNULL(MAX(Id), 0) FROM Productos.Catalogo;

        CREATE TABLE #Electronico(
        Producto VARCHAR(30),
        PrecioUnitario VARCHAR(6)
        )

        CREATE TABLE #ElectronicoSinDuplicados (
        Producto VARCHAR(30),
        PrecioUnitario VARCHAR(6)
        );

        SET @SQL = N'BULK INSERT #Electronico
                    FROM ''' + @RutaArchivo + ''' 
                    WITH (
                        FIELDTERMINATOR = '';'',  -- Cambia el separador seg�n sea necesario
                        ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila seg�n sea necesario
                        FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
                        CODEPAGE = ''65001''
                    );';
        
        EXEC sp_executesql @SQL;

        -- Insertar productos únicos en la nueva tabla
        INSERT INTO #ElectronicoSinDuplicados (Producto, PrecioUnitario)
        SELECT DISTINCT Producto, PrecioUnitario
        FROM #Electronico;

        INSERT INTO Productos.Producto(Producto, Precio)
        SELECT 
                Producto, 
                CAST(REPLACE(PrecioUnitario, ',', '.') AS DECIMAL(10, 2)) AS Precio
        FROM #ElectronicoSinDuplicados

        ;WITH ProductosNoDuplicados AS (
        SELECT
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @LastCatalogoID AS Id,
            e.Producto,
            PrecioUnitario as Precio
        FROM #ElectronicoSinDuplicados e
        LEFT JOIN Productos.Catalogo ca ON e.Producto = ca.Nombre
        WHERE ca.Nombre IS NULL  -- Solo insertar productos que no existan en la tabla principal
        )

        INSERT INTO Productos.Catalogo(Id, Nombre, Precio, Categoria)
        SELECT
            Id,
            Producto,
            CAST(REPLACE(Precio, ',', '.') AS DECIMAL(6, 2)) AS Precio,
            'electronico'
        FROM ProductosNoDuplicados;

        DROP TABLE #Electronico

        PRINT('+ Importación de Productos Electrónicos completada exitosamente.');
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importación de Productos Electrónicos: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO
