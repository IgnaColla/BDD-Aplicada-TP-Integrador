-------------------------------------------------------------------
--------------  Stored Procedures DETALLE FACTURA  ----------------
-------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO

CREATE OR ALTER PROCEDURE Ventas.InsertarDetalleVenta
	@Factura VARCHAR(15),
	@IdProducto INT,
	@PrecioVenta DECIMAL(10,5),
	@Cantidad INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

	-- Verificar si esa venta ya existe

	
	
	IF not exists (SELECT 1 FROM Productos.Catalogo WHERE id=@IdProducto)
		BEGIN
            RAISERROR('+ El producto no existe. Terminando el procedimiento.', 16, 1);
            RETURN;
		END

	IF NOT EXISTS (SELECT Id FROM Ventas.Factura WHERE NumeroFactura=@Factura)
		BEGIN
            RAISERROR('+ La factura no existe. Terminando el procedimiento.', 16, 1);
            RETURN;
		END

	DECLARE @IdFactura INT =  (SELECT Id FROM Ventas.Factura WHERE NumeroFactura=@Factura);

	IF EXISTS (SELECT 1 FROM Ventas.DetalleFactura WHERE IdFactura = @IdFactura AND IdProducto = @IdProducto)
		BEGIN
            RAISERROR('+ El producto ya fue cargado. Terminando el procedimiento.', 16, 1);
            RETURN;
		END

	-- Insertar nuevo registro
	INSERT Ventas.DetalleFactura VALUES (@IdFactura,@IdProducto,@PrecioVenta,@Cantidad);

	UPDATE ft
		SET 
			ft.SubtotalSinIVA = ft.SubtotalSinIVA + (@PrecioVenta * @Cantidad)
		FROM 
			Ventas.Factura ft
		INNER JOIN 
			Ventas.DetalleFactura df ON ft.Id = df.IdFactura
		WHERE ft.id = @IdFactura;

	UPDATE ft
		SET 
			ft.Total = ft.SubtotalSinIVA * 1.21
		FROM 
			Ventas.Factura ft
		INNER JOIN 
			Ventas.DetalleFactura df ON ft.Id = df.IdFactura
		WHERE ft.id = @IdFactura;

	DECLARE @IdVenta INT = (SELECT id FROM Ventas.Venta WHERE IdFactura =(SELECT Id FROM	Ventas.Factura WHERE NumeroFactura=@Factura));

	INSERT Ventas.DetalleVenta VALUES (@IdVenta,@IdProducto,@PrecioVenta,@Cantidad);

	UPDATE vt
		SET 
			vt.Total = vt.Total + (@PrecioVenta * @Cantidad)
		FROM 
			Ventas.Venta vt
		INNER JOIN 
			Ventas.DetalleVenta dv ON vt.Id = dv.IdVenta
		WHERE vt.id = @IdVenta;

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