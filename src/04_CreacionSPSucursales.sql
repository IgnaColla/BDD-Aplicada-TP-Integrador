USE Com2900G17
GO

CREATE OR ALTER PROCEDURE Administracion.ImportarSucursalesDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'BULK INSERT Administracion.Sucursal
                FROM ''' + @RutaArchivo + ''' 
                WITH (
                    FIELDTERMINATOR = '';'',  -- Cambia el separador según sea necesario
                    ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila según sea necesario
                    FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
					KEEPNULLS,
					CODEPAGE = ''ACP'',
					TABLOCK
				);';
    EXEC sp_executesql @SQL;
END;
GO

EXEC Administracion.ImportarSucursalesDesdeCSV
@RutaArchivo = 'E:\Lauty\Facultad\2024\BBDDA\TP\TP_Integrador\dataset\Sucursal.csv'
GO

-- Segun la consigna son 3 sucursales por ende tener SP para agregar sucursales no seria necesario