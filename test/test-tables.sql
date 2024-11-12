-- VER TABLAS

USE Com2900G17
GO

select * from Administracion.Empleado
select * from Administracion.Sucursal
select * from Administracion.Cargo

select * from Productos.CatalogoCategoria
select * from Productos.Categoria
select * from Productos.Linea
select * from Productos.Catalogo order by id

select * from Ventas.Venta
select * from Ventas.DetalleFactura
select * from Ventas.Factura
select * from Ventas.NotaCredito
select * from Ventas.MedioDePago

--VACIAR TABLAS
/*
delete from Administracion.Empleado
delete from Administracion.Sucursal
delete from Administracion.Cargo

delete from Productos.CatalogoCategoria
delete from Productos.Categoria
delete from Productos.Linea
delete from Productos.Catalogo

delete from Ventas.DetalleFactura
delete from Ventas.Factura
delete from Ventas.Venta
delete from Ventas.NotaCredito
delete from Ventas.MedioDePago

*/
