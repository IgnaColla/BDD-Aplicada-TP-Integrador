-- VER TABLAS

USE Com2900G17
GO

Select ISNULL('Hello', (SELECT NOMBRE FROM Administracion.Sucursal WHERE Ciudad= 'San Justo' AND Direccion = 'Rivera Indarte 1234'));

select * from Administracion.Empleado where Legajo = NULL or DNI = NULL
select * from Administracion.Sucursal

select * from Productos.ClasificacionProducto
select * from Productos.Producto
select * from Productos.Catalogo order by id

select * from Ventas.MedioDePago
select * from Ventas.Venta

--VACIAR TABLAS
/*
delete from Administracion.Empleado
delete from Administracion.Sucursal

delete from Productos.ClasificacionProducto
delete from Productos.Catalogo
delete from Productos.Producto

delete from Ventas.MedioDePago
delete from Ventas.Venta
*/