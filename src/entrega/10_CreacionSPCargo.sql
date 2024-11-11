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

        PRINT('+ Cargo insertado con �xito.');
	END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacci�n en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserci�n del empleado: %s', 16, 1, @ErrorMessage);
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

        -- Buscar empleado y eliminar
        DELETE FROM Administracion.Cargo 
        WHERE Cargo = @Cargo;

        IF @@ROWCOUNT = 0  -- Verificar si se elimin� alg�n registro
        BEGIN
            RAISERROR('+ Cargo inexistente.', 16, 1);
            RETURN;
        END

        COMMIT TRANSACTION;  -- Confirmar transacci�n

        PRINT('+ Cargo eliminado con �xito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacci�n en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la eliminaci�n del Cargo: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;