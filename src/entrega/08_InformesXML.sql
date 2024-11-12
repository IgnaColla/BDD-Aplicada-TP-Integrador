------------------------------------------------------------
--------------------- INFORMES DE VENTAS -------------------
------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17;
GO

CREATE OR ALTER PROCEDURE Ventas.InformeMensualDiarioTotalFacturadoXML
	@Mes INT = 1, -- Fechas por defecto
	@Anio INT = 2019  
AS
BEGIN
	BEGIN TRY
		SELECT 
			FORMAT(Fecha, 'dd/MM/yyyy') AS Dia,  -- Formatea la fecha en el formato deseado
			SUM(Total) as TotalFacturado
		FROM Ventas.Factura ft
		WHERE MONTH(Fecha) = @Mes AND YEAR(Fecha) = @Anio
		GROUP BY Fecha
		ORDER BY Fecha
		FOR XML RAW('InformeMensualDiario'),
				ROOT('Venta.Ventas'),
				TYPE;
		
		PRINT('+ Creación del informe mensual-diario completado exitosamente.');
    END TRY
    BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la creación del informe: %s', 16, 1, @ErrorMessage);
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE Ventas.InformeMensualTotalFacturadoXML
	@Mes INT = 1, -- Fechas por defecto
	@Anio INT = 2019  
AS
BEGIN
	BEGIN TRY
		SELECT
			DATENAME(WEEKDAY, Fecha) AS DiaDeLaSemana,  		-- Nombre del dia de la semana
			SUM(Total) AS TotalFacturado  	
		FROM 
			Ventas.Factura
		WHERE 
			MONTH(Fecha) = @Mes AND 
			YEAR(Fecha) = @Anio
		GROUP BY 
			DATENAME(WEEKDAY, Fecha)
		FOR XML RAW('InformeMensual'),
				ROOT('Venta.Ventas'),
				TYPE;
		
		PRINT('+ Creación del informe mensual completada exitosamente.');
    END TRY
    BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la creación del informe: %s', 16, 1, @ErrorMessage);
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE Ventas.InformeTrimestralTotalFacturadoXML
AS
BEGIN
	BEGIN TRY
		SELECT 
			DATENAME(MONTH, Fecha) AS Mes,
			em.Turno,
			SUM(ft.Total) AS TotalFacturado
		FROM Ventas.Factura AS ft 
		INNER JOIN Ventas.Venta vt ON ft.Id = vt.IdFactura
		INNER JOIN Administracion.Empleado AS em
		ON vt.IdEmpleado = em.Legajo
		GROUP BY
				em.Turno,
				DATENAME(MONTH, Fecha)
		FOR XML RAW('InformeTrimestral'),
			ROOT('Venta.Ventas'),
			TYPE;
		
		PRINT('+ Creación del Informe trimestral completada exitosamente.');
    END TRY
    BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la creación del informe: %s', 16, 1, @ErrorMessage);
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE Ventas.InformeEntreFechasCantidadXML
	@fecha_ini date = '2019-01-01',
	@fecha_fin date = '2019-01-30'
AS
BEGIN
	BEGIN TRY
		SELECT
			ca.Producto,
			SUM(df.Cantidad) AS CantidadVendida
		FROM Ventas.Factura AS ft 
		INNER JOIN Ventas.DetalleFactura df ON ft.Id = df.IdFactura
		INNER JOIN Productos.Catalogo ca ON df.IdProducto = ca.Id
		WHERE ft.Fecha >= @fecha_ini AND ft.Fecha <= @fecha_fin
		GROUP BY ca.Producto
		ORDER BY SUM(df.Cantidad) DESC
			FOR XML RAW('InformeTrimestral'),
			ROOT('Venta.Ventas'),
			TYPE;
		
		PRINT('+ Creación de informe entre fechas completada exitosamente.');
    END TRY
    BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la creación del informe: %s', 16, 1, @ErrorMessage);
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE Ventas.InformeEntreFechasCantidadPorSucursalXML
	@fecha_ini date = '2019-01-01',
	@fecha_fin date = '2019-01-31'
AS
BEGIN
	BEGIN TRY
		SELECT 
			su.Ciudad,
			SUM(df.Cantidad) AS CantidadVendida
		FROM Ventas.Venta AS vt 
		INNER JOIN Administracion.Sucursal AS su ON vt.IdSucursal = su.Id
		INNER JOIN Ventas.Factura ft ON vt.IdFactura = ft.Id
		INNER JOIN Ventas.DetalleFactura df ON ft.Id = df.IdFactura
		WHERE ft.Fecha >= @fecha_ini AND ft.Fecha <= @fecha_fin
		GROUP BY 
				su.Ciudad
		ORDER BY SUM(df.Cantidad) DESC
			FOR XML RAW('InformeTrimestral'),
			ROOT('Venta.Ventas'),
			TYPE;
		
		PRINT('+ Creación de informe entre fechas por sucursal completada exitosamente.');
    END TRY
    BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la creación del informe: %s', 16, 1, @ErrorMessage);
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE Ventas.InformeTop5MasVendidosPorSemanaXML
    @Mes INT = '01'
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRY
		WITH TopProductosPorSemana AS (
			SELECT 
				DATEPART(WEEK, f.Fecha) AS Semana,
				p.Producto AS Producto,
				SUM(df.Cantidad) AS CantidadVendida,
				ROW_NUMBER() OVER (PARTITION BY DATEPART(WEEK, f.Fecha) ORDER BY SUM(df.Cantidad) DESC) AS Ranking
			FROM 
				Ventas.Factura f
			INNER JOIN 
				Ventas.DetalleFactura df ON f.Id = df.IdFactura
			INNER JOIN 
				Productos.Catalogo p ON df.IdProducto = p.Id
			WHERE 
				MONTH(f.Fecha) = @Mes
			GROUP BY 
				DATEPART(WEEK, f.Fecha), df.IdProducto, p.Producto
		)
    
		-- Selección de los 5 productos más vendidos por semana
		SELECT 
			Semana,
			Producto,
			CantidadVendida
		FROM 
			TopProductosPorSemana
		WHERE 
			Ranking <= 5
		ORDER BY 
			Semana, 
			Ranking
		FOR XML RAW('InformeTop5'),
		ROOT('Venta.Ventas'),
		TYPE;

		PRINT('+ Creación de informe Top 5 mas vendidos completada exitosamente.');
    END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la creación del informe: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.InformeProductosMenosVendidosXML
    @Mes INT = '01'
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRY
		WITH CantidadVendidaPorProducto AS (
			SELECT 
				p.Producto,
				SUM(df.Cantidad) AS CantidadVendida
			FROM 
				Ventas.Factura f
			INNER JOIN 
				Ventas.DetalleFactura df ON f.Id = df.IdFactura
			INNER JOIN 
				Productos.Catalogo p ON df.IdProducto = p.Id
			WHERE 
				MONTH(f.Fecha) = @Mes
			GROUP BY 
				df.IdProducto, p.Producto
		)

		-- Selección de los 5 productos menos vendidos en el mes
		SELECT TOP 5
			Producto,
			CantidadVendida
		FROM 
			CantidadVendidaPorProducto
		ORDER BY 
			CantidadVendida ASC
		FOR XML RAW('Informe5Menos'),
		ROOT('Venta.Ventas'),
		TYPE;

			PRINT('+ Creación de informe productos menos vendidos completada exitosamente.');
    END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la creación del informe: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.InformeProductosMenosVendidosPorMesXML
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRY
		WITH CantidadVendidaPorProducto AS (
			SELECT 
				p.Producto,
				YEAR(f.Fecha) AS Anio,
				MONTH(f.Fecha) AS Mes,
				SUM(df.Cantidad) AS CantidadVendida
			FROM 
				Ventas.Factura f
			INNER JOIN 
				Ventas.DetalleFactura df ON f.Id = df.IdFactura
			INNER JOIN 
				Productos.Catalogo p ON df.IdProducto = p.Id
			GROUP BY 
				df.IdProducto, p.Producto, YEAR(f.Fecha), MONTH(f.Fecha)
		),

		ProductosMenosVendidos AS (
			SELECT 
				Producto,
				Anio,
				Mes,
				CantidadVendida,
				ROW_NUMBER() OVER (PARTITION BY Anio, Mes ORDER BY CantidadVendida ASC) AS Rango
			FROM 
				CantidadVendidaPorProducto
		)

		SELECT 
			Anio,
			Mes,
			Producto,
			CantidadVendida
		FROM 
			ProductosMenosVendidos
		WHERE 
			Rango <= 5
		ORDER BY 
			Anio, Mes, CantidadVendida ASC
		FOR XML RAW('Informe5Menos'),
		ROOT('Venta.Ventas'),
		TYPE;

			PRINT('+ Creación de informe productos menos vendidos completada exitosamente.');
    END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la creación del informe: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE Ventas.InformeVentasAcumuladasPorFechaYSucursalXML
    @Fecha DATE = '2019-01-01',
    @Nombre VARCHAR(20) = 'Yangon'
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRY
		SELECT 
			v.Id AS IdVenta,
			f.NumeroFactura,
			f.TipoFactura,
			f.Fecha,
			f.Hora,
			p.Producto,
			df.PrecioUnitario,
			df.Cantidad,
			f.Total,
			v.IdSucursal,
			mp.Descripcion AS MedioDePago
		FROM 
			Ventas.Venta v
		INNER JOIN 
			Ventas.Factura f ON v.IdFactura = f.Id
		INNER JOIN 
			Ventas.DetalleFactura df ON f.Id = df.IdFactura
		INNER JOIN 
			Productos.Catalogo p ON df.IdProducto = p.Id
		INNER JOIN 
			Ventas.MedioDePago mp ON f.IdMedioPago = mp.Id
		INNER JOIN 
			Administracion.Sucursal su ON v.IdSucursal = su.Id
		WHERE 
			f.Fecha = @Fecha
			AND su.Nombre = @Nombre
		ORDER BY 
			f.Fecha, v.IdSucursal, f.NumeroFactura
		FOR XML RAW('InformeSucursalFecha'),
		ROOT('Venta.Ventas'),
		TYPE;

		PRINT('+ Creación de informe ventas por sucursal y fecha completada exitosamente.');
    END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la creación del informe: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO


/*
exec Ventas.InformeMensualDiarioTotalFacturadoXML
exec Ventas.InformeMensualTotalFacturadoXML
exec Ventas.InformeTrimestralTotalFacturadoXML
exec Ventas.InformeEntreFechasCantidadXML
exec Ventas.InformeEntreFechasCantidadPorSucursalXML
exec Ventas.InformeTop5MasVendidosPorSemanaXML
exec Ventas.InformeProductosMenosVendidosXML
exec Ventas.InformeProductosMenosVendidosPorMesXML
exec Ventas.InformeVentasAcumuladasPorFechaYSucursalXML
*/
