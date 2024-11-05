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
                        CODEPAGE = ''65001''
                    );';
        EXEC sp_executesql @SQL;

		PRINT('+ Importaci�n de sucursales completada exitosamente.');
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR('+ Error durante la importaci�n de sucursales: %s', 16, 1, @ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;


-- #################### Ejecucion ####################

EXEC Administracion.ImportarSucursalesDesdeCSV @RutaArchivo = '<Path_al_archivo>'
