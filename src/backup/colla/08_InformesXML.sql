-------------------------------------------------------------------------------
-------------------  Stored Procedures - INFORMES DE VENTAS -------------------
-------------------------------------------------------------------------------

-- #################### Creacion ####################

USE Com2900G17
GO

CREATE OR ALTER PROCEDURE Ventas.InformeMensualDiarioXML
	@Mes INT = 1, -- Fechas por defecto
	@Anio INT = 2019  
AS
BEGIN
	BEGIN TRY
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

		PRINT('+ Informe generado con éxito.');
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la creación del informe: %s', 16, 1, @ErrorMessage);
	END CATCH;
END


CREATE OR ALTER PROCEDURE Ventas.InformeMensualXML
	@Mes INT = 1, -- Fechas por defecto
	@Anio INT = 2019  
AS
BEGIN
	BEGIN TRY
		SELECT 
			DATENAME(WEEKDAY, Fecha) AS DiaDeLaSemana,  -- Nombre del día de la semana
			SUM(PrecioUnitario * Cantidad) AS TotalFacturado  -- Suma de los montos facturados
		FROM 
			Ventas.Venta
		WHERE 
			MONTH(Fecha) = @Mes AND 
			YEAR(Fecha) = @Anio
		GROUP BY DATENAME(WEEKDAY, Fecha)
		FOR XML RAW('InformeMensual'),
				ROOT('Venta.Ventas'),
				TYPE;

		PRINT('+ Informe mensual generado con éxito.');
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la creación del informe mensual: %s', 16, 1, @ErrorMessage);
	END CATCH;
END


CREATE OR ALTER PROCEDURE Ventas.InformeTrimestralXML
AS
BEGIN
	BEGIN TRY
		SELECT 
				DATENAME(MONTH, Fecha) AS Mes,
				em.Turno,
				SUM(vt.PrecioUnitario * vt.Cantidad) AS TotalFacturado
		FROM Ventas.Venta AS vt INNER JOIN Administracion.Empleado AS em
		ON vt.Empleado = em.IdEmpleado
		GROUP BY em.Turno, DATENAME(MONTH, Fecha)
		FOR XML RAW('InformeTrimestral'),
			ROOT('Venta.Ventas'),
			TYPE;

		PRINT('+ Informe trimestral generado con éxito.');
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la creación del informe trimestral: %s', 16, 1, @ErrorMessage);
	END CATCH;
END


CREATE OR ALTER PROCEDURE Ventas.InformeEntreFechasXML
	@fecha_ini date = '2019-01-01',
	@fecha_fin date = '2019-01-30'
AS
BEGIN
	BEGIN TRY
		SELECT 
				vt.Producto,
				SUM(vt.Cantidad) AS CantidadVendida
		FROM Ventas.Venta AS vt
		where vt.Fecha >= @fecha_ini AND vt.Fecha <= @fecha_fin
		GROUP BY vt.Producto
		ORDER BY SUM(vt.Cantidad) DESC
			FOR XML RAW('InformeTrimestral'),
			ROOT('Venta.Ventas'),
			TYPE;

		PRINT('+ Informe entre fechas generado con éxito.');
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la creación del informe entre fechas: %s', 16, 1, @ErrorMessage);
	END CATCH;
END


CREATE OR ALTER PROCEDURE Ventas.InformeEntreFechasPorSucursalXML
	@fecha_ini date = '2019-01-01',
	@fecha_fin date = '2019-01-30'
AS
BEGIN
	BEGIN TRY
		SELECT 
				su.Sucursal,
				SUM(vt.Cantidad) AS CantidadVendida
		FROM Ventas.Venta AS vt INNER JOIN Administracion.Sucursal AS su
		ON vt.Ciudad = su.Ciudad
		WHERE vt.Fecha >= @fecha_ini AND vt.Fecha <= @fecha_fin
		GROUP BY su.Sucursal
		ORDER BY SUM(vt.Cantidad) DESC
			FOR XML RAW('InformeTrimestral'),
			ROOT('Venta.Ventas'),
			TYPE;
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('+ Error durante la creación del informe entre fechas por sucursal: %s', 16, 1, @ErrorMessage);
	END CATCH;
END


-- #################### Ejecucion ####################

EXEC Ventas.InformeMensualDiarioXML
EXEC Ventas.InformeMensualXML
EXEC Ventas.InformeTrimestralXML
EXEC Ventas.InformeEntreFechasXML
EXEC Ventas.InformeEntreFechasPorSucursalXML
