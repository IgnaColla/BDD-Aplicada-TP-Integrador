USE Com2900G17
GO

CREATE OR ALTER PROCEDURE Ventas.InformeMenualDiarioXML
@Mes INT = 1, -- Fechas por defecto
@Anio INT = 2019  
AS
BEGIN
	SELECT 
		FORMAT(Fecha, 'dd/MM/yyyy') AS Dia,  -- Formatea la fecha en el formato deseado
		SUM(PrecioUnitario * Cantidad) AS TotalFacturado
	FROM Ventas.Venta
	WHERE MONTH(Fecha) = @Mes AND YEAR(Fecha) = @Anio
	GROUP BY Fecha
	ORDER BY Fecha
	FOR XML RAW('InformeMensualDiario'),
			ROOT('Venta.Ventas'),
			TYPE;
END
GO

CREATE OR ALTER PROCEDURE Ventas.InformeMensualXML
@Mes INT = 1, -- Fechas por defecto
@Anio INT = 2019  
AS
BEGIN
	SELECT 
		DATENAME(WEEKDAY, Fecha) AS DiaDeLaSemana,  -- Nombre del día de la semana
		SUM(PrecioUnitario * Cantidad) AS TotalFacturado  -- Suma de los montos facturados
	FROM 
		Ventas.Venta
	WHERE 
		MONTH(Fecha) = @Mes AND 
		YEAR(Fecha) = @Anio
	GROUP BY 
		DATENAME(WEEKDAY, Fecha)
	FOR XML RAW('InformeMensual'),
			ROOT('Venta.Ventas'),
			TYPE;
END
GO

CREATE OR ALTER PROCEDURE Ventas.InformeTrimestralXML
AS
BEGIN
	select 
			DATENAME(MONTH, Fecha) as Mes,
			em.Turno,
			SUM(vt.PrecioUnitario * vt.Cantidad) as TotalFacturado
	from Ventas.Venta as vt INNER JOIN Administracion.Empleado as em
	on vt.Empleado = em.IdEmpleado
	group by
			em.Turno,
			DATENAME(MONTH, Fecha)
	FOR XML RAW('InformeTrimestral'),
		ROOT('Venta.Ventas'),
		TYPE;
END
GO

CREATE OR ALTER PROCEDURE Ventas.InformeEntreFechasXML
@fecha_ini date = '2019-01-01',
@fecha_fin date = '2019-01-30'
AS
BEGIN
	select 
			vt.Producto,
			SUM(vt.Cantidad) as CantidadVendida
	from Ventas.Venta as vt
	where vt.Fecha >= @fecha_ini AND vt.Fecha <= @fecha_fin
	group by vt.Producto
	ORDER BY SUM(vt.Cantidad) DESC
		FOR XML RAW('InformeTrimestral'),
		ROOT('Venta.Ventas'),
		TYPE;
END
GO

CREATE OR ALTER PROCEDURE Ventas.InformeEntreFechasPorSucursalXML
@fecha_ini date = '2019-01-01',
@fecha_fin date = '2019-01-30'
AS
BEGIN
	select 
			su.Sucursal,
			SUM(vt.Cantidad) as CantidadVendida
	from Ventas.Venta as vt inner join Administracion.Sucursal as su
	on vt.Ciudad = su.Ciudad
	where vt.Fecha >= @fecha_ini AND vt.Fecha <= @fecha_fin
	group by 
			su.Sucursal
	ORDER BY SUM(vt.Cantidad) DESC
		FOR XML RAW('InformeTrimestral'),
		ROOT('Venta.Ventas'),
		TYPE;
END

exec Ventas.InformeMenualDiarioXML
exec Ventas.InformeMensualXML
exec Ventas.InformeTrimestralXML
exec Ventas.InformeEntreFechasXML
exec Ventas.InformeEntreFechasPorSucursalXML


