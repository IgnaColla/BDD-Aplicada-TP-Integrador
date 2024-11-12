-------------------------------------------------------------------
--------------  Stored Procedures TIPO DE CAMBIO  ----------------
-------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO

CREATE OR ALTER PROCEDURE Productos.InsertarTipoCambio
	@Peso DECIMAL(10,5),
	@Moneda VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

	-- Verificar si esa venta ya existe
		IF EXISTS ( SELECT 1 FROM Productos.TipoDeCambio WHERE Moneda = @Moneda)
			BEGIN
				RAISERROR('+ La moneda ya existe. Terminando el procedimiento.', 16, 1);
				RETURN;
			END

		INSERT Productos.TipoDeCambio VALUES (@Peso,@Moneda);

			COMMIT TRANSACTION;  -- Confirmar transacción

			PRINT('+ Tipo de moneda insertada con éxito.');
		END TRY
	BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserción del tipo de moneda: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Productos.ActualizarTipoCambio
	@Peso DECIMAL(10,5),
	@Moneda VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

		-- Verificar si esa venta ya existe
		IF NOT EXISTS ( SELECT 1 FROM Productos.TipoDeCambio WHERE Moneda = @Moneda)
			BEGIN
				RAISERROR('+ La moneda no existe. Terminando el procedimiento.', 16, 1);
				RETURN;
			END

		UPDATE Productos.TipoDeCambio 
		SET Peso = @Peso
		WHERE Moneda = @Moneda;

		COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Tipo de moneda actulizada con éxito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la actualización del tipo de moneda: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Productos.EliminarTipoCambio
	@Peso DECIMAL(10,5),
	@Moneda VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

	-- Verificar si esa venta ya existe
		IF NOT EXISTS ( SELECT 1 FROM Productos.TipoDeCambio WHERE Moneda = @Moneda)
			BEGIN
				RAISERROR('+ La moneda no existe. Terminando el procedimiento.', 16, 1);
				RETURN;
			END

		DELETE FROM Productos.TipoDeCambio WHERE Moneda=@Moneda;

		COMMIT TRANSACTION;  -- Confirmar transacción

		PRINT('+ Tipo de moneda eliminada con éxito.');
		END TRY
	BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la eliminación del tipo de moneda: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO