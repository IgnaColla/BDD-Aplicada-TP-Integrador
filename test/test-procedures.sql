-- Despues de la creacion de los diferentes objetos (BD, schemas, tablas y procedures)
-- deben cargarse los datos ejecutando los procedures con la ruta a los archivos de informacion
--TODO: deben separarse en distintos archivos para cada esquema

USE Com2900G17
GO

-- Puerba SP Sucursal--

EXEC Administracion.ImportarSucursalesDesdeCSV
@RutaArchivo = 'D:\Universidad\BDD-Aplicada-TP-Integrador\dataset\Sucursal.csv'
GO

EXEC Administracion.InsertarSucursal 'San Justo','Compra Gamer', 'Rivera Indarte 1234', 'L a V 8 a. m.–9 p. m.S y D 9 a. m.-8 p. m.', '4441-5479'
GO

EXEC Administracion.ActualizarSucursal @Ciudad='San Justo',@Nombre='Pegu', @Direccion='Rivera Indarte 1234'
GO

EXEC Administracion.EliminarSucursal 'San Justo','Rivera Indarte 1238'
GO


-- Prueba Empleado SP --

EXEC Administracion.ImportarEmpleadosDesdeCSV
@RutaArchivo = 'D:\Universidad\BDD-Aplicada-TP-Integrador\dataset\Empleados.csv'
GO

EXEC Productos.ImportarCategoriasDesdeCSV
@RutaArchivo = 'D:\Universidad\BDD-Aplicada-TP-Integrador\dataset\ClasificacionProductos.csv'
GO

EXEC Productos.ImportarCatalogoProductoDesdeCSV
@RutaArchivo = 'D:\Universidad\BDD-Aplicada-TP-Integrador\dataset\catalogo.csv'
GO

EXEC Productos.AgregarCatalogoProductosImportadosDesdeCSV
@RutaArchivo = 'D:\Universidad\BDD-Aplicada-TP-Integrador\dataset\ProductosImportados.csv'
GO

EXEC Productos.AgregarCatalogoProductosElectronicosDesdeCSV
@RutaArchivo = 'D:\Universidad\BDD-Aplicada-TP-Integrador\dataset\ProductosElectronicos.csv'
GO

EXEC Ventas.ImportarMediosDePagoDesdeCSV
@RutaArchivo = 'D:\Universidad\BDD-Aplicada-TP-Integrador\dataset\MediosDePago.csv'
GO

EXEC Ventas.ImportarVentasDesdeCSV
@RutaArchivo = 'D:\Universidad\BDD-Aplicada-TP-Integrador\dataset\ventas_registradas.csv'
GO
