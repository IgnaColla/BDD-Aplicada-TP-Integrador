--------------------------------------------------------------------
-------------------  Stored Procedures SUCURSAL  -------------------
--------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO

CREATE OR ALTER PROCEDURE Administracion.ImportarSucursalesDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @SQL NVARCHAR(MAX);

		CREATE TABLE #Sucursal (
			Ciudad VARCHAR(20) NOT NULL,
			Reemplazo VARCHAR(20) NOT NULL,
			Direccion VARCHAR(100) NOT NULL,
			Horario VARCHAR(45) NOT NULL,
			Telefono VARCHAR(10) NOT NULL
    );

        SET @SQL = N'BULK INSERT #Sucursal
                    FROM ''' + @RutaArchivo + ''' 
                    WITH (
                        FIELDTERMINATOR = '';'',  -- Cambia el separador según sea necesario
                        ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila según sea necesario
                        FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
                        CODEPAGE = ''65001''
                    );';
        
        EXEC sp_executesql @SQL;

		INSERT Administracion.Sucursal(Ciudad, Direccion, Telefono, Horario)
		SELECT	su.Reemplazo, 
				TRIM(REPLACE(su.Direccion, CHAR(160), '')), 
				su.Telefono, 
				REPLACE(su.Horario, '"', '') 
		FROM #Sucursal su

		DROP TABLE #Sucursal

		PRINT('+ Importación de sucursales completada exitosamente.');
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importación de sucursales: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO
