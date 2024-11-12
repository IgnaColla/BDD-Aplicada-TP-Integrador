-------------------------------------------------------------------
-------------------  Stored Procedures VENTAS  --------------------
-------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO

CREATE OR ALTER PROCEDURE Ventas.ImportarMediosDePagoDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @SQL NVARCHAR(MAX);

		CREATE TABLE #MedioPago(
			Id INT IDENTITY PRIMARY KEY,
			Codigo VARCHAR(15) UNIQUE,
			Descripcion VARCHAR(25)          
		)

        SET @SQL = N'BULK INSERT #MedioPago
                    FROM ''' + @RutaArchivo + ''' 
                    WITH (
                        FIELDTERMINATOR = '';'',  -- Cambia el separador seg�n sea necesario
                        ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila seg�n sea necesario
                        FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
                        CODEPAGE = ''65001'',
                        KEEPNULLS
                    );';
        
        EXEC sp_executesql @SQL;

		INSERT Ventas.MedioDePago(Codigo, Descripcion)
		SELECT mo.Codigo, mo.Descripcion FROM #MedioPago mo
		WHERE NOT EXISTS (
            SELECT 1 
            FROM Ventas.MedioDePago mp
            WHERE mo.Codigo = mp.Codigo
        );

        PRINT('+ Importación de Medios de Pago completada exitosamente.');
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importación de Medios de Pago: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE Ventas.ImportarVentasDesdeCSV
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @SQL NVARCHAR(MAX);

		CREATE TABLE #Venta(
			IdFactura VARCHAR(15),           
			TipoFactura CHAR(1),
			Ciudad VARCHAR(10),
			TipoCliente VARCHAR(10),           
			Genero CHAR(6),                     
			Producto VARCHAR(100),               
			PrecioUnitario DECIMAL(10, 2),       
			Cantidad INT,   
			Fecha DATE,                           
			Hora TIME,                          
			MedioPago VARCHAR(15),              
			Empleado INT,                         
			IdentificadorPago VARCHAR(40)
		)

        SET @SQL = N'BULK INSERT #Venta
                    FROM ''' + @RutaArchivo + ''' 
                    WITH (
                        FIELDTERMINATOR = '';'',  -- Cambia el separador seg�n sea necesario
                        ROWTERMINATOR = ''\n'',   -- Cambia el terminador de fila seg�n sea necesario
                        FIRSTROW = 2,              -- Si el archivo tiene encabezados, comienza desde la segunda fila
                        CODEPAGE = ''65001''
                    );';
        
        EXEC sp_executesql @SQL;

		INSERT Ventas.Factura(NumeroFactura, TipoFactura, Fecha, Hora, IdMedioPago, Subtotal, Total, IdentificadorPago)
		SELECT DISTINCT vt.IdFactura,
						vt.TipoFactura, 
						vt.Fecha, 
						vt.Hora,
						mp.Id,
						0,
						0,
						vt.IdentificadorPago
		FROM #Venta vt INNER JOIN Ventas.MedioDePago mp ON vt.MedioPago = mp.Codigo 
		WHERE NOT EXISTS (
            SELECT 1 
            FROM Ventas.Factura ft
            WHERE vt.IdFactura = ft.NumeroFactura
        );

		-- Reemplazamos los valores '--' en la columna IdentificadorPago por NULL
        UPDATE Ventas.Factura
        SET IdentificadorPago = NULL
        WHERE IdentificadorPago = '--';

		WITH ProductosUnicos AS (
			SELECT 
				Id,
				Producto,
				Precio,
				ROW_NUMBER() OVER (PARTITION BY Producto, Precio ORDER BY Id) AS row_num
			FROM 
				Productos.Catalogo
		)

		INSERT Ventas.DetalleFactura(IdFactura, IdProducto, PrecioUnitario, Cantidad)
		SELECT 
				ft.Id AS IdFactura,
				pu.Id AS IdProducto,
				vt.PrecioUnitario,
				vt.Cantidad
		FROM #Venta vt
		INNER JOIN Ventas.Factura ft ON vt.IdFactura = ft.NumeroFactura
		INNER JOIN ProductosUnicos pu ON vt.Producto = pu.Producto AND vt.PrecioUnitario = pu.Precio
		WHERE row_num = 1 AND
		NOT EXISTS(
			SELECT 1 
			FROM Ventas.DetalleFactura dft
			WHERE dft.IdFactura = ft.Id AND dft.IdProducto = pu.Id AND dft.PrecioUnitario = vt.PrecioUnitario
			AND dft.Cantidad = vt.Cantidad
		);

		UPDATE ft
		SET 
			ft.Subtotal = TotalAcumulado.Total
		FROM 
			Ventas.Factura ft
		INNER JOIN (
			-- Calcula el subtotal acumulado por factura
			SELECT 
				IdFactura,
				SUM(df.PrecioUnitario * df.Cantidad) AS Total
			FROM 
				Ventas.DetalleFactura df
			GROUP BY 
				IdFactura
		) AS TotalAcumulado ON ft.Id = TotalAcumulado.IdFactura;


		UPDATE ft
		SET 
			ft.Total = ft.Subtotal * 1.21
		FROM 
			Ventas.Factura ft
		INNER JOIN 
			Ventas.DetalleFactura df ON ft.Id = df.IdFactura;

		INSERT Ventas.Venta(IdFactura, IdSucursal, IdEmpleado, TipoCliente, Genero)
		SELECT DISTINCT	ft.Id, 
						su.Id, 
						em.Legajo, 
						TipoCliente,
						CASE 
							WHEN vt.Genero = 'Male' THEN 'M'
							WHEN vt.Genero = 'Female' THEN 'F'
							ELSE 'O'
						END AS Genero
		FROM #Venta vt
		INNER JOIN Ventas.Factura ft ON vt.IdFactura = ft.NumeroFactura
		INNER JOIN Administracion.Sucursal su ON vt.Ciudad = su.Nombre
		INNER JOIN Administracion.Empleado em ON vt.Empleado = em.Legajo
		WHERE NOT EXISTS (
            SELECT 1 
            FROM Ventas.Venta ve
        );


        PRINT('+ Importación de Ventas y Facturas completada exitosamente.');
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la importación de Ventas: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.InsertarVenta
	@Sucursal VARCHAR(20),
    @TipoCliente VARCHAR(10),
    @Genero CHAR(1),                      
	@LegajoEmpleado INT,
	@NumeroFactura VARCHAR(15),
	@TipoFactura CHAR(1),
	@Fecha DATE,                         
    @Hora TIME,                            
	@MedioPago VARCHAR(15),           
	@IdentificadorPago VARCHAR(40) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;  -- Iniciar transacción

	-- Verificar si esa venta ya existe
	IF EXISTS (SELECT 1 FROM Ventas.Factura WHERE NumeroFactura=@NumeroFactura)
        BEGIN
            RAISERROR('+ La venta ya existe. Terminando el procedimiento.', 16, 1);
            RETURN;
		END
	IF NOT EXISTS (SELECT Id FROM Ventas.MedioDePago WHERE Codigo=@MedioPago)
		BEGIN
            RAISERROR('+ El medio de pago no existe. Terminando el procedimiento.', 16, 1);
            RETURN;
		END
	DECLARE @IdMedioPago INT =  (SELECT Id FROM Ventas.MedioDePago WHERE Codigo=@MedioPago);
	-- Insertar nuevo registro
	INSERT Ventas.Factura VALUES (@NumeroFactura,@TipoFactura,@Fecha,@Hora,@IdMedioPago,0,0,@IdentificadorPago);

	IF NOT EXISTS (SELECT Id FROM Administracion.Sucursal WHERE Nombre=@Sucursal)
		BEGIN
            RAISERROR('+ La sucursal no existe. Terminando el procedimiento.', 16, 1);
            RETURN;
		END
	DECLARE @IdSucursal INT =  (SELECT Id FROM Administracion.Sucursal WHERE Nombre=@Sucursal);

	IF NOT EXISTS (SELECT Legajo FROM Administracion.Empleado WHERE Legajo=@LegajoEmpleado)
		BEGIN
            RAISERROR('+ El empleado no existe. Terminando el procedimiento.', 16, 1);
            RETURN;
		END
	DECLARE @IdFactura INT = (SELECT MAX(ID) FROM Ventas.Factura);

	INSERT Ventas.Venta VALUES(@IdFactura,@IdSucursal,@TipoCliente,@Genero,@LegajoEmpleado);

	COMMIT TRANSACTION;  -- Confirmar transacción

        PRINT('+ Venta insertada con éxito.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;  -- Revertir transacción en caso de error

        DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la inserción de la Venta: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

exec Ventas.InsertarVenta
	@Sucursal = 'Yangon',
    @TipoCliente = 'Normal',
    @Genero = 'F',                      
	@LegajoEmpleado = '257023',
	@NumeroFactura = '849-09-5899',
	@TipoFactura = 'A',
	@Fecha = '28/02/2019',                         
    @Hora = '13:32',                            
	@MedioPago = 'Cash',           
	@IdentificadorPago = NULL

	select * from Ventas.Factura ft
	where ft.NumeroFactura = '849-09-3801'

	select * from Ventas.Venta vt
	WHERE vt.IdFactura = 15003