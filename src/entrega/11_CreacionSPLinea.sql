-------------------------------------------------------------------
-------------------  Stored Procedures LINEA -------------------
-------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO

CREATE OR ALTER PROCEDURE Productos.InsertarLinea
	@Linea VARCHAR(15)
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

        -- Verificar si la linea de producto ya existe
        IF EXISTS (SELECT 1 FROM Productos.Linea WHERE LineaProducto = @Linea)	
        BEGIN
            RAISERROR('+ La linea de producto ya existe. Terminando el procedimiento.', 16, 1);
            RETURN;
        END
		INSERT Productos.Linea VALUES(@Linea)
		COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Linea de producto insertado con éxito.');
	END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserción de la linea de producto: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Productos.EliminarLinea
	@Linea VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

        -- Buscar linea de producto y eliminar
        DELETE FROM Productos.Linea 
        WHERE LineaProducto = @Linea;

        IF @@ROWCOUNT = 0  -- Verificar si se eliminó algún registro
        BEGIN
            RAISERROR('+ Linea de producto inexistente.', 16, 1);
            RETURN;
        END

        COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Linea de producto eliminada con éxito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la eliminación de la Linea de producto: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;