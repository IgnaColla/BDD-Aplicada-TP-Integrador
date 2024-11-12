-------------------------------------------------------------------
--------------  Stored Procedures DETALLE FACTURA  ----------------
-------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO

CREATE OR ALTER PROCEDURE Ventas.InsertarDetalleFactura
	@Factura VARCHAR(15),
	@Producto VARCHAR(100),
	@Categoria VARCHAR(40),
	@PrecioCompra DECIMAL(10,2),
	@PrecioVenta DECIMAL(10,5),
	@Cantidad INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

	-- Verificar si esa venta ya existe

	
	
	IF not exists (SELECT 1 FROM Productos.Catalogo c 
	INNER JOIN Productos.CatalogoCategoria cc ON cc.IdCatalogo = c.Id
	INNER JOIN Productos.Categoria cat ON cat.Id = cc.IdCategoria
	WHERE Producto = @Producto AND Precio = @PrecioCompra AND cat.Categoria = @Categoria)
		BEGIN
            RAISERROR('+ El producto no existe. Terminando el procedimiento.', 16, 1);
            RETURN;
		END
	DECLARE @IdCatalogo INT = (SELECT c.ID FROM Productos.Catalogo c 
	INNER JOIN Productos.CatalogoCategoria cc ON cc.IdCatalogo = c.Id
	INNER JOIN Productos.Categoria cat ON cat.Id = cc.IdCategoria
	WHERE Producto = @Producto AND Precio = @PrecioCompra AND cat.Categoria = @Categoria);

	IF NOT EXISTS (SELECT Id FROM Ventas.Factura WHERE NumeroFactura=@Factura)
		BEGIN
            RAISERROR('+ La factura no existe. Terminando el procedimiento.', 16, 1);
            RETURN;
		END

	DECLARE @IdFactura INT =  (SELECT Id FROM Ventas.Factura WHERE NumeroFactura=@Factura);

	IF EXISTS (SELECT 1 FROM Ventas.DetalleFactura WHERE IdFactura = @IdFactura AND IdProducto = @IdCatalogo)
		BEGIN
            RAISERROR('+ El producto ya fue cargado. Terminando el procedimiento.', 16, 1);
            RETURN;
		END

	-- Insertar nuevo registro
	INSERT Ventas.DetalleFactura VALUES (@IdFactura,@IdCatalogo,@PrecioVenta,@Cantidad);

	UPDATE ft
		SET 
			ft.Subtotal = ft.Subtotal + (@PrecioVenta * @Cantidad)
		FROM 
			Ventas.Factura ft
		INNER JOIN 
			Ventas.DetalleFactura df ON ft.Id = df.IdFactura
		WHERE ft.id = @IdFactura;

	UPDATE ft
		SET 
			ft.Total = ft.Subtotal * 1.21
		FROM 
			Ventas.Factura ft
		INNER JOIN 
			Ventas.DetalleFactura df ON ft.Id = df.IdFactura
		WHERE ft.id = @IdFactura;

	COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Detalle de factura insertada con éxito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserción de la detalle de factura: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO