USE Com2900G17
GO

CREATE OR ALTER PROCEDURE Ventas.ImportarMediosDePagoDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'BULK INSERT Ventas.MedioDePago
                FROM ''' + @RutaArchivo + ''' 
                WITH (
                    FIELDTERMINATOR = '';'',  -- Cambia el separador según sea necesario
                    ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila según sea necesario
                    FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
					CODEPAGE = ''65001'',
					KEEPNULLS
				);';
    EXEC sp_executesql @SQL;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.ImportarVentasDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'BULK INSERT Ventas.Venta
                FROM ''' + @RutaArchivo + ''' 
                WITH (
                    FIELDTERMINATOR = '';'',  -- Cambia el separador según sea necesario
                    ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila según sea necesario
                    FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
					CODEPAGE = ''65001''
				);';
    EXEC sp_executesql @SQL;

	-- Reemplazamos los valores '--' en la columna IdentificadorPago por NULL
    UPDATE Ventas.Venta
    SET IdentificadorPago = NULL
    WHERE IdentificadorPago = '--';

END;
GO
