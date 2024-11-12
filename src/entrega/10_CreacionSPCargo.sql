-------------------------------------------------------------------
-------------------  Stored Procedures CARGO -------------------
-------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO

CREATE OR ALTER PROCEDURE Administracion.InsertarCargo
	@Cargo VARCHAR(30)
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacci�n

        -- Verificar si el cargo ya existe
        IF EXISTS (SELECT 1 FROM Administracion.Cargo WHERE Cargo = @Cargo)	
        BEGIN
            RAISERROR('+ El cargo ya existe. Terminando el procedimiento.', 16, 1);
            RETURN;
        END
		INSERT Administracion.Cargo VALUES(@Cargo)
		COMMIT TRANSACTION;  -- Confirmar transacci�n

        PRINT('+ Cargo insertado con éxito.');
	END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacci�n en caso de error

        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserción del Cargo: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Administracion.EliminarCargo
	@Cargo VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacci�n

        -- Buscar cargo y eliminar
        DELETE FROM Administracion.Cargo 
        WHERE Cargo = @Cargo;

        IF @@ROWCOUNT = 0  -- Verificar si se eliminó algún registro
        BEGIN
            RAISERROR('+ Cargo inexistente.', 16, 1);
            RETURN;
        END

        COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Cargo eliminado con éxito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacci�n en caso de error

        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la eliminación del Cargo: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;