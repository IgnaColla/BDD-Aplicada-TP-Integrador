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

CREATE OR ALTER PROCEDURE Productos.AgregarCatalogoProductosImportadosDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

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

	;WITH ProductosNoDuplicados AS (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @LastCatalogoID AS Id,
            i.Nombre,
            Price
        FROM #ProductoImportado i
        LEFT JOIN Productos.Catalogo ca ON i.Nombre = ca.Nombre
        WHERE ca.Nombre IS NULL  -- Solo insertar productos que no existan en la tabla principal
    )

	INSERT INTO Productos.Catalogo(Id, Nombre, Precio)
	SELECT 
		Id,
		Nombre,
		CAST(REPLACE(REPLACE(Price, '$', ''), ',', '.') AS DECIMAL(10, 2)) AS Precio
	FROM ProductosNoDuplicados;
	
	DROP TABLE #ProductoImportado
END;
GO

CREATE OR ALTER PROCEDURE Productos.AgregarCatalogoProductosElectronicosDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

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
                    FIELDTERMINATOR = '';'',  -- Cambia el separador según sea necesario
                    ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila según sea necesario
                    FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
					CODEPAGE = ''65001''
				);';
    EXEC sp_executesql @SQL;

    -- Insertar productos únicos en la nueva tabla
    INSERT INTO #ElectronicoSinDuplicados (Producto, PrecioUnitario)
    SELECT DISTINCT Producto, PrecioUnitario
    FROM #Electronico;

	;WITH ProductosNoDuplicados AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @LastCatalogoID AS Id,
        e.Producto,
        PrecioUnitario as Precio
    FROM #ElectronicoSinDuplicados e
    LEFT JOIN Productos.Catalogo ca ON e.Producto = ca.Nombre
    WHERE ca.Nombre IS NULL  -- Solo insertar productos que no existan en la tabla principal
	)

	INSERT INTO Productos.Catalogo(Id, Nombre, Precio)
	SELECT
		Id,
		Producto,
		CAST(REPLACE(Precio, ',', '.') AS DECIMAL(6, 2)) AS Precio
	FROM ProductosNoDuplicados;

	DROP TABLE #Electronico
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