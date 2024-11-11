-------------------------------------------------------------------
-------------------  Stored Procedures CATEGORIA -------------------
-------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO


CREATE OR ALTER PROCEDURE Productos.InsertarCategoria
	@Categoria VARCHAR(20),
	@Linea VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacci�n

	-- Verificar si esa categoria ya existe
	IF EXISTS (SELECT 1 FROM Productos.Categoria WHERE Categoria = @Categoria)	
        BEGIN
            RAISERROR('+ La categoria ya existe. Terminando el procedimiento.', 16, 1);
            RETURN;
    END
	DECLARE @idLinea INT = (SELECT Id FROM Productos.Linea where LineaProducto = @Linea);
	-- Insertar nuevo registro
	INSERT INTO Productos.Categoria(Categoria,IdLinea) VALUES (@Categoria,@Linea);

	COMMIT TRANSACTION;  -- Confirmar transacci�n

        PRINT('+ Categoria insertada con �xito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacci�n en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserci�n de la Categoria: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Productos.ActualizarCategoria
	@Categoria VARCHAR(20),
	@Linea VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacci�n

	-- Verificar si esa categoria ya existe
	IF NOT EXISTS (SELECT 1 FROM Productos.Categoria WHERE Categoria = @Categoria)	
        BEGIN
            RAISERROR('+ La categoria no existe. Terminando el procedimiento.', 16, 1);
            RETURN;
    END
	DECLARE @idLinea INT = (SELECT Id FROM Productos.Linea where LineaProducto = @Linea);

	-- Actualizar registro
	UPDATE Productos.Categoria
	SET IdLinea = @idLinea
	WHERE Categoria = @Categoria;

	COMMIT TRANSACTION;  -- Confirmar transacci�n

        PRINT('+ Categoria actualizada con �xito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacci�n en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la actualizaci�n de la Categoria: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Productos.EliminarCategoria
	@Categoria VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacci�n

        -- Buscar categoria y eliminar
        DELETE FROM Productos.Categoria 
        WHERE Categoria = @Categoria;

        IF @@ROWCOUNT = 0  -- Verificar si se elimin� alg�n registro
        BEGIN
            RAISERROR('+ Categoria inexistente.', 16, 1);
            RETURN;
        END

        COMMIT TRANSACTION;  -- Confirmar transacci�n

        PRINT('+ Categoria eliminada con �xito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacci�n en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la eliminaci�n de la Categoria: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO