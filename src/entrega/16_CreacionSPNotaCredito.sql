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
        BEGIN TRANSACTION;  -- Iniciar transacci�n
		IF NOT EXISTS (SELECT 1 FROM Ventas.Factura WHERE NumeroFactura=@Factura)
        BEGIN
            RAISERROR('+ La factura no existe. Terminando el procedimiento.', 16, 1);
            RETURN;
		END

		DECLARE @IdFactura INT = SELECT id FROM Ventas.Factura WHERE NumeroFactura=@Factura
		INSERT Ventas.NotaCredito VALUES (@IdFactura);

		COMMIT TRANSACTION;  -- Confirmar transacci�n

        PRINT('+ Venta insertada con �xito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacci�n en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserci�n de la Venta: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO