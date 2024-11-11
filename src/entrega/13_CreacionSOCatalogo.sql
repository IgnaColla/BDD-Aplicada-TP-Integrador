--------------------------------------------------------------------
-------------------  Stored Procedures CATALOGOS  -------------------
--------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO

CREATE OR ALTER PROCEDURE Productos.InsertarCatalogo
	@Producto VARCHAR(100), 
    @Precio DECIMAL(10, 2),    
	@PrecioRef DECIMAL(10, 2) = NULL,    
    @UnidadRef VARCHAR(10) = NULL,       
    @Fecha CHAR(20),
	@Categoria VARCHAR(40)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION; -- Iniciar transacción

	-- Insertar nuevo registro
	DECLARE @idCatalogo INT = (SELECT MAX(id)+1 FROM Productos.Catalogo);
	INSERT Productos.Catalogo(Id,Producto,Precio,PrecioRef,UnidadRef,Fecha) VALUES (@idCatalogo,@Producto,@Precio,@PrecioRef,@UnidadRef,@Fecha);

	DECLARE @idCategoria INT = (SELECT id FROM Productos.Categoria WHERE Categoria = @Categoria);
	INSERT Productos.CatalogoCategoria(IdCatalogo,IdCategoria) VALUES (@idCatalogo,@idCategoria);

	COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Catalogo insertada con éxito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserción del catalogo: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Productos.ActualizarCatalogo
	@Producto VARCHAR(100), 
    @Precio DECIMAL(10, 2),    
	@PrecioRef DECIMAL(10, 2) = NULL,    
    @UnidadRef VARCHAR(10) = NULL,       
    @Fecha CHAR(20),
	@Categoria VARCHAR(40)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

	DECLARE @IdCatalogo INT = (SELECT c.ID FROM Productos.Catalogo c 
	inner join Productos.CatalogoCategoria cc ON cc.IdCatalogo = c.Id
	inner join Productos.Categoria cat ON cat.Id = cc.IdCategoria
	where Producto = @Producto and Precio = @Precio and cat.Categoria = @Categoria)

	-- Verificar si ese catalogo ya existe
	IF NOT EXISTS (SELECT 1 FROM Productos.Catalogo WHERE id = @IdCatalogo)	
        BEGIN
            RAISERROR('+ El catologo no existe. Terminando el procedimiento.', 16, 1);
            RETURN;
    END

	-- Insertar nuevo registro
	UPDATE Productos.Catalogo
	SET	Precio =  @Precio,
	PrecioRef = CASE WHEN @PrecioRef IS NOT NULL THEN @PrecioRef ELSE (SELECT PrecioRef FROM Productos.Catalogo WHERE id = @IdCatalogo) END,
	UnidadRef = CASE WHEN @UnidadRef IS NOT NULL THEN @UnidadRef ELSE (SELECT UnidadRef FROM Productos.Catalogo WHERE id = @IdCatalogo) END,
	Fecha = CASE WHEN @Fecha IS NOT NULL THEN @Fecha ELSE (SELECT Fecha FROM Productos.Catalogo WHERE id = @IdCatalogo) END
	WHERE id = @IdCatalogo
	COMMIT TRANSACTION;
	
	-- Confirmar transacción

        PRINT('+ Catalogo actualizado con éxito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la actualización del catalogo: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Productos.EliminarCatalogo
	@Producto VARCHAR(100),
    @Categoria VARCHAR(40),
	@Precio DECIMAL(10, 2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

        -- Buscar catalogo y eliminar
		DECLARE @IdCatalogo INT = (SELECT c.ID FROM Productos.Catalogo c 
		inner join Productos.CatalogoCategoria cc ON cc.IdCatalogo = c.Id
		inner join Productos.Categoria cat ON cat.Id = cc.IdCategoria
		where Producto = @Producto and Precio = @Precio and cat.Categoria = @Categoria)


        DELETE FROM Productos.Catalogo 
        WHERE Id = @IdCatalogo;

        IF @@ROWCOUNT = 0  -- Verificar si se eliminó algún registro
        BEGIN
            RAISERROR('+ Catalogo inexistente.', 16, 1);
            RETURN;
        END

        COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Catalogo eliminado con éxito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la eliminación de lo Catalogo: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO