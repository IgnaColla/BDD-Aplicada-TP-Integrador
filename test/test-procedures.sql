-- Despues de la creacion de los diferentes objetos (BD, schemas, tablas y procedures)
-- deben cargarse los datos ejecutando los procedures con la ruta a los archivos de informacion
--TODO: deben separarse en distintos archivos para cada esquema

USE Com2900G17
GO

EXEC Administracion.ImportarSucursalesDesdeCSV
@RutaArchivo = 'E:\Lauty\Facultad\2024\BBDDA\TP\TP_Integrador\dataset\Sucursal.csv'
GO

EXEC Administracion.ImportarEmpleadosDesdeCSV
@RutaArchivo = 'E:\Lauty\Facultad\2024\BBDDA\TP\TP_Integrador\dataset\Empleados.csv'
GO

EXEC Productos.ImportarCategoriasDesdeCSV
@RutaArchivo = 'E:\Lauty\Facultad\2024\BBDDA\TP\TP_Integrador\dataset\ClasificacionProductos.csv'
GO

EXEC Productos.ImportarCatalogoProductoDesdeCSV
@RutaArchivo = 'E:\Lauty\Facultad\2024\BBDDA\TP\TP_Integrador\dataset\catalogo.csv'
GO

EXEC Productos.AgregarCatalogoProductosImportadosDesdeCSV
@RutaArchivo = 'E:\Lauty\Facultad\2024\BBDDA\TP\TP_Integrador\dataset\ProductosImportados.csv'
GO

EXEC Productos.AgregarCatalogoProductosElectronicosDesdeCSV
@RutaArchivo = 'E:\Lauty\Facultad\2024\BBDDA\TP\TP_Integrador\dataset\ProductosElectronicos.csv'
GO

EXEC Ventas.ImportarMediosDePagoDesdeCSV
@RutaArchivo = 'E:\Lauty\Facultad\2024\BBDDA\TP\TP_Integrador\dataset\MediosDePago.csv'
GO

EXEC Ventas.ImportarVentasDesdeCSV
@RutaArchivo = 'E:\Lauty\Facultad\2024\BBDDA\TP\TP_Integrador\dataset\ventas_registradas.csv'
GO
