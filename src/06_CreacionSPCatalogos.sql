USE Com2900G17
GO

CREATE OR ALTER PROCEDURE Productos.ImportarCategoriasDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

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
END;
GO

CREATE OR ALTER PROCEDURE Productos.ImportarCatalogoDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

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
END;
GO

CREATE OR ALTER PROCEDURE Productos.ImportarProductosImportadosDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

	SELECT IdProducto,Nombre,Proveedor,Categoria,CantidadPorUnidad,
    CAST(Precio AS VARCHAR(10)) AS Precio  INTO #Importado from Productos.ProductoImportado

    SET @SQL = N'BULK INSERT #Importado
                FROM ''' + @RutaArchivo + ''' 
                WITH (
                    FIELDTERMINATOR = '';'',  -- Cambia el separador según sea necesario
                    ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila según sea necesario
                    FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
					CODEPAGE = ''65001''
				);';
    EXEC sp_executesql @SQL;

	INSERT INTO Productos.ProductoImportado (IdProducto, Nombre, Proveedor, Categoria, CantidadPorUnidad, Precio)
	SELECT 
		IdProducto,
		Nombre,
		Proveedor,
		Categoria,
		CantidadPorUnidad,
		CAST(REPLACE(REPLACE(Precio, '$', ''), ',', '.') AS DECIMAL(10, 2)) AS Precio
	FROM #Importado;

	DROP TABLE #Importado
END;
GO

CREATE OR ALTER PROCEDURE Productos.ImportarProductosElectronicosDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

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

	INSERT INTO Productos.ProductoElectronico(Producto, PrecioUnitario)
	SELECT 
		Producto,
		CAST(REPLACE(Precio, ',', '.') AS DECIMAL(6, 2)) AS Precio
	FROM #Electronico;

	DROP TABLE #Electronico
END;
GO

CREATE OR ALTER PROCEDURE Productos.CargarLineaProducto
AS
BEGIN
    SET NOCOUNT ON;

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
END;
GO


/*
CREATE OR ALTER PROCEDURE Productos.ImportarCatalogoDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Crear la tabla temporal para almacenar el contenido del archivo
    CREATE TABLE #Catalogos (
        Fila VARCHAR(MAX)
    );

    -- Declarar la variable @SQL para construir la consulta dinámica
    DECLARE @SQL NVARCHAR(MAX);

    -- Construir la consulta BULK INSERT de manera dinámica
    SET @SQL = N'BULK INSERT #Catalogos
                FROM ''' + @RutaArchivo + ''' 
                WITH (
                    FIELDTERMINATOR = '','',  -- Cada línea como una fila
                    ROWTERMINATOR = ''0x0A'',   -- Especificar el terminador de línea (nuevo renglón)
                    FIRSTROW = 2,               -- Comienza desde la segunda fila (omite encabezado)
                    CODEPAGE = ''65001''
                );';

    -- Ejecutar la consulta dinámica
    EXEC sp_executesql @SQL;

	select * from #Catalogos


	SELECT 
    CAST(CatalogoDividido.[1] as int) as Id,
    CatalogoDividido.[2],
    CatalogoDividido.[3],
    CatalogoDividido.[4],
    CatalogoDividido.[5],
    CatalogoDividido.[6],
    CatalogoDividido.[7] as Fecha
FROM (
    SELECT 
        FilaId,
        ROW_NUMBER() OVER (PARTITION BY FilaId ORDER BY (SELECT NULL)) AS RowNum,
        Split.value AS Valor
    FROM (
        SELECT Fila, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS FilaId
        FROM #Catalogos
    ) AS CatalogosConFilaId
    CROSS APPLY STRING_SPLIT(Fila, ',') AS Split
) AS ValoresDivididos
PIVOT (
    MAX(Valor) FOR RowNum IN ([1], [2], [3], [4], [5], [6], [7])
) AS CatalogoDividido;

    -- Eliminar la tabla temporal
    --DROP TABLE #Catalogo;
END;
GO
*/