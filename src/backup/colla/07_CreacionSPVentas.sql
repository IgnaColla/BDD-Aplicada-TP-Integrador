-------------------------------------------------------------------
-------------------  Stored Procedures VENTAS  --------------------
-------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17
GO

CREATE OR ALTER PROCEDURE Ventas.ImportarMediosDePagoDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
		DECLARE @SQL NVARCHAR(MAX);

		SET @SQL = N'BULK INSERT Ventas.MedioDePago
					FROM ''' + @RutaArchivo + ''' 
					WITH (
						FIELDTERMINATOR = '';'',  -- Cambia el separador seg�n sea necesario
						ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila seg�n sea necesario
						FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
						CODEPAGE = ''65001'',
						KEEPNULLS
					);';
		EXEC sp_executesql @SQL;

		PRINT('+ Importaci�n de Medios de Pago completada exitosamente.');
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importaci�n de Medios de Pago: %s', 16, 1, @ErrorMessage);
	END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE Ventas.ImportarVentasDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @SQL NVARCHAR(MAX);

		SET @SQL = N'BULK INSERT Ventas.Venta
					FROM ''' + @RutaArchivo + ''' 
					WITH (
						FIELDTERMINATOR = '';'',  -- Cambia el separador seg�n sea necesario
						ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila seg�n sea necesario
						FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
						CODEPAGE = ''65001''
					);';
		EXEC sp_executesql @SQL;

		-- Reemplazamos los valores '--' en la columna IdentificadorPago por NULL
		UPDATE Ventas.Venta
		SET IdentificadorPago = NULL
		WHERE IdentificadorPago = '--';

		PRINT('+ Importaci�n de Ventas completada exitosamente.');
	END TRY
	BEGIN CATCH -- En caso de error
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importaci�n de Ventas: %s', 16, 1, @ErrorMessage);
	END CATCH;
END;


-- #################### Ejecucion ####################

EXEC Ventas.ImportarMediosDePagoDesdeCSV @RutaArchivo = '<Path_al_archivo>';
EXEC Ventas.ImportarVentasDesdeCSV @RutaArchivo = '<Path_al_archivo>';
