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
        BEGIN TRANSACTION;  -- Iniciar transacci�n

        -- Verificar si la linea de producto ya existe
        IF EXISTS (SELECT 1 FROM Productos.Linea WHERE LineaProducto = @Linea)	
        BEGIN
            RAISERROR('+ La linea de producto ya existe. Terminando el procedimiento.', 16, 1);
            RETURN;
        END
		INSERT Administracion.Cargo VALUES(@Linea)
		COMMIT TRANSACTION;  -- Confirmar transacci�n

        PRINT('+ Linea de producto insertado con �xito.');
	END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacci�n en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserci�n de la linea de producto: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Productos.EliminarLinea
	@Linea VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacci�n

        -- Buscar linea de prodcuto y eliminar
        DELETE FROM Productos.Linea 
        WHERE LineaProducto = @Linea;

        IF @@ROWCOUNT = 0  -- Verificar si se elimin� alg�n registro
        BEGIN
            RAISERROR('+ Linea de producto inexistente.', 16, 1);
            RETURN;
        END

        COMMIT TRANSACTION;  -- Confirmar transacci�n

        PRINT('+ Linea de producto eliminada con �xito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacci�n en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la eliminaci�n de la Linea de producto: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;