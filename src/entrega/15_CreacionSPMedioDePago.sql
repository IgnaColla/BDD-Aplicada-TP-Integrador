-------------------------------------------------------------------
-------------------  Stored Procedures MEDIO DE PAGO -------------------
-------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO

CREATE OR ALTER PROCEDURE Ventas.InsertarMedioDePago
	@Codigo VARCHAR(15),
    @Descripcion VARCHAR(25) = NULL  
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacci�n

        -- Verificar si el medio de pago ya existe
        IF EXISTS (SELECT 1 FROM Ventas.MedioDePago WHERE Codigo = @Codigo)	
        BEGIN
            RAISERROR('+ El medio de pago ya existe. Terminando el procedimiento.', 16, 1);
            RETURN;
        END
		INSERT Ventas.MedioDePago VALUES(@Codigo,@Descripcion)
		COMMIT TRANSACTION;  -- Confirmar transacci�n

        PRINT('+ Medio de pago insertado con �xito.');
	END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacci�n en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserci�n del medio de pago: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.ActualizarMedioDePago
	@Codigo VARCHAR(15),
    @Descripcion VARCHAR(25) = NULL  
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacci�n

        -- Verificar si el medio de pago existe
        IF NOT EXISTS (SELECT 1 FROM Ventas.MedioDePago WHERE Codigo = @Codigo)	
        BEGIN
            RAISERROR('+ El medio de pago no existe. Terminando el procedimiento.', 16, 1);
            RETURN;
        END

		UPDATE Ventas.MedioDePago
		SET Descripcion = @Descripcion
		WHERE Codigo = @Codigo

		COMMIT TRANSACTION;  -- Confirmar transacci�n

        PRINT('+ Medio de pago actualizado con �xito.');
	END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacci�n en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la actualizacion del medio de pago: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.EliminarMedioDePago
	@Codigo VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacci�n

        -- Buscar medio de pago y eliminar
        DELETE FROM Ventas.MedioDePago 
        WHERE Codigo = @Codigo;

        IF @@ROWCOUNT = 0  -- Verificar si se elimin� alg�n registro
        BEGIN
            RAISERROR('+ Medio de pago inexistente.', 16, 1);
            RETURN;
        END

        COMMIT TRANSACTION;  -- Confirmar transacci�n

        PRINT('+ Medio de pago eliminado con �xito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacci�n en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la eliminaci�n de la Linea de producto: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;