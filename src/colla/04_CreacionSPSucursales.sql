-------------------------------------------------------------------
-------------------  Stored Procedures SUCURSAL -------------------
-------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17
GO

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
                        ROWTERMINATOR = ''\n'',				-- Cambia el terminador de fila si es necesario
                        FIRSTROW = 2,						-- Comienza desde la segunda fila si el archivo tiene encabezados
                        KEEPNULLS,
                        CODEPAGE = ''ACP'',
                        TABLOCK
                    );';
        EXEC sp_executesql @SQL;

		RAISERROR('+ Importación de sucursales completada exitosamente.', 0, 1);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR('+ Error durante la importación de sucursales: %s', 16, 1, @ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;


-- #################### Ejecucion ####################

EXEC Administracion.ImportarSucursalesDesdeCSV @RutaArchivo = 'C:\Users\Ignacio\Downloads\TP-Integrador\Sucursal.csv'

-- OBSERVACIONES
-- Segun la consigna son 3 sucursales por ende tener SP para agregar sucursales no seria necesario
