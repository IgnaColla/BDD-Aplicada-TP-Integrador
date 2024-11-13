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

        -- Crear tabla temporal para importar los datos del CSV
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
        );

        -- Ejecutar BULK INSERT para cargar datos en la tabla temporal
        SET @SQL = N'BULK INSERT #Venta
                    FROM ''' + @RutaArchivo + ''' 
                    WITH (
                        FIELDTERMINATOR = '';'',  
                        ROWTERMINATOR = ''\n'',   
                        FIRSTROW = 2,             
                        CODEPAGE = ''65001''
                    );';
        
        EXEC sp_executesql @SQL;

        -- Crear tabla temporal para productos únicos
        CREATE TABLE #ProductosUnicos (
            Id INT,
            Producto VARCHAR(100),
            Precio DECIMAL(10, 2),
            row_num INT
        );

        -- Poblar #ProductosUnicos con los datos únicos de Productos.Catalogo
        INSERT INTO #ProductosUnicos (Id, Producto, Precio, row_num)
        SELECT 
            Id,
            Producto,
            Precio,
            ROW_NUMBER() OVER (PARTITION BY Producto, Precio ORDER BY Id) AS row_num
        FROM Productos.Catalogo;

        -- Insertar datos en la tabla Factura
        INSERT INTO Ventas.Factura (NumeroFactura, TipoFactura, Fecha, Hora, IdMedioPago, SubtotalSinIVA, Total, IdentificadorPago)
        SELECT DISTINCT 
            vt.IdFactura,
            vt.TipoFactura, 
            vt.Fecha, 
            vt.Hora,
            mp.Id,
            0,
            0,
            CASE WHEN vt.IdentificadorPago = '--' THEN NULL ELSE vt.IdentificadorPago END
        FROM #Venta vt
        INNER JOIN Ventas.MedioDePago mp ON vt.MedioPago = mp.Codigo 
        WHERE NOT EXISTS (
            SELECT 1 
            FROM Ventas.Factura ft
            WHERE vt.IdFactura = ft.NumeroFactura
        );

        -- Insertar datos en la tabla DetalleFactura
        INSERT INTO Ventas.DetalleFactura (IdFactura, IdProducto, PrecioUnitario, Cantidad)
        SELECT 
            ft.Id AS IdFactura,
            pu.Id AS IdProducto,
            vt.PrecioUnitario,
            vt.Cantidad
        FROM #Venta vt
        INNER JOIN Ventas.Factura ft ON vt.IdFactura = ft.NumeroFactura
        INNER JOIN #ProductosUnicos pu ON vt.Producto = pu.Producto AND vt.PrecioUnitario = pu.Precio
        WHERE pu.row_num = 1 
          AND NOT EXISTS (
            SELECT 1 
            FROM Ventas.DetalleFactura dft
            WHERE dft.IdFactura = ft.Id 
              AND dft.IdProducto = pu.Id 
              AND dft.PrecioUnitario = vt.PrecioUnitario
              AND dft.Cantidad = vt.Cantidad
        );

        -- Actualizar SubtotalSinIVA y Total en Factura
        UPDATE ft
        SET 
            ft.SubtotalSinIVA = TotalAcumulado.Total
        FROM 
            Ventas.Factura ft
        INNER JOIN (
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
            ft.Total = ft.SubtotalSinIVA * 1.21
        FROM 
            Ventas.Factura ft;

        -- Insertar datos en la tabla Venta
        INSERT INTO Ventas.Venta (IdFactura, IdSucursal, IdEmpleado, TipoCliente, Genero, Total)
        SELECT DISTINCT 
            ft.Id, 
            su.Id, 
            em.Legajo, 
            vt.TipoCliente,
            CASE 
                WHEN vt.Genero = 'Male' THEN 'M'
                WHEN vt.Genero = 'Female' THEN 'F'
                ELSE 'O'
            END AS Genero,
            ft.SubtotalSinIVA
        FROM #Venta vt
        INNER JOIN Ventas.Factura ft ON vt.IdFactura = ft.NumeroFactura
        INNER JOIN Administracion.Sucursal su ON vt.Ciudad = su.Nombre
        INNER JOIN Administracion.Empleado em ON vt.Empleado = em.Legajo
        WHERE NOT EXISTS (
            SELECT 1 
            FROM Ventas.Venta ve
            WHERE ve.IdFactura = ft.Id
        );

        -- Insertar datos en la tabla DetalleVenta
        INSERT INTO Ventas.DetalleVenta (IdVenta, IdProducto, PrecioUnitario, Cantidad)
        SELECT 
            vt.Id AS IdVenta,
            pu.Id AS IdProducto,
            dft.PrecioUnitario,
            dft.Cantidad
        FROM Ventas.Venta vt
        INNER JOIN Ventas.Factura ft ON vt.IdFactura = ft.Id
        INNER JOIN Ventas.DetalleFactura dft ON dft.IdFactura = ft.Id
        INNER JOIN #ProductosUnicos pu ON dft.PrecioUnitario = pu.Precio AND pu.row_num = 1
        WHERE NOT EXISTS (
            SELECT 1 
            FROM Ventas.DetalleVenta dvt
            WHERE dvt.IdVenta = vt.Id 
              AND dvt.IdProducto = pu.Id 
              AND dvt.PrecioUnitario = dft.PrecioUnitario
              AND dvt.Cantidad = dft.Cantidad
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

		INSERT Ventas.Venta VALUES(@IdFactura,@IdSucursal,@TipoCliente,@Genero,@LegajoEmpleado,0);

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
