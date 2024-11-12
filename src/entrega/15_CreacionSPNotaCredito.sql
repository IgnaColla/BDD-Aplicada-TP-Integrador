-------------------------------------------------------------------
-------------------  Stored Procedures Nota de Credito -------------------
-------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO

CREATE OR ALTER PROCEDURE Ventas.InsertarNotaCredito
	@Factura VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción
		IF NOT EXISTS (SELECT 1 FROM Ventas.Factura WHERE NumeroFactura=@Factura OR (SELECT IdentificadorPago FROM Ventas.Factura WHERE NumeroFactura=@Factura) = NULL)
        BEGIN
            RAISERROR('+ La factura no existe o no esta paga. Terminando el procedimiento.', 16, 1);
            RETURN;
		END

		DECLARE @IdFactura INT = (SELECT id FROM Ventas.Factura WHERE NumeroFactura=@Factura);
		INSERT Ventas.NotaCredito VALUES (@IdFactura);

		COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Nota de credito insertada con éxito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserción de la nota de credito: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO