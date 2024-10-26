USE Com2900G17

CREATE OR ALTER PROCEDURE Administracion.ImportarSucursalesDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @SQL NVARCHAR(MAX);
        
        SET @SQL = N'BULK INSERT Administracion.Sucursal
                     FROM ''' + @RutaArchivo + ''' 
                     WITH (
                         FIELDTERMINATOR = '';'',			-- Cambia el separador si es necesario
                         ROWTERMINATOR = ''\n'',			-- Cambia el terminador de fila si es necesario
                         FIRSTROW = 2,						-- Comienza desde la segunda fila si el archivo tiene encabezados
                         KEEPNULLS,
                         CODEPAGE = ''ACP'',
                         TABLOCK
                     );';
        EXEC sp_executesql @SQL;
    END TRY
    BEGIN CATCH -- En caso de error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;

EXEC Administracion.ImportarSucursalesDesdeCSV @RutaArchivo = 'C:\Users\Ignacio\Downloads\TP-Integrador\Sucursal.csv'

select * from Administracion.Sucursal

-- OBSERVACIONES
-- Segun la consigna son 3 sucursales por ende tener SP para agregar sucursales no seria necesario
