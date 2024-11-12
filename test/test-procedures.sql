
USE Com2900G17
GO

-- Prueba SP Importar CSVs (Ejecutar en orden)

EXEC Administracion.ImportarSucursalesDesdeCSV
@RutaArchivo = 'D:\Universidad\BDD-Aplicada-TP-Integrador\dataset\Sucursal.csv'
GO

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

EXEC Productos.InsertarTipoCambio '978','USD'
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

-- Prueba SP Sucursal--

EXEC Administracion.InsertarSucursal 'San Justo','Compra Gamer', 'Rivera Indarte 123', 'L a V 8 a. m.–9 p. m.S y D 9 a. m.-8 p. m.', '4441-5432'
GO

EXEC Administracion.ActualizarSucursal @Ciudad='San Justo',@Nombre='Pegu', @Direccion='Rivera Indarte 123'
GO

EXEC Administracion.EliminarSucursal 'San Justo','Rivera Indarte 1237'
GO


-- Prueba SP Empleados --

EXEC Administracion.InsertarEmpleado @Legajo= '257035', @Nombre='Julian', @Apellido='Villalobos', @DNI='12132134', @Direccion='blablabla 123', @Cargo='Cajero'
GO

EXEC Administracion.ActualizarEmpleado @Legajo= '257035', @Direccion='blablabla 1234'
GO

EXEC Administracion.EliminarEmpleado @Legajo= '257035'
GO 

-- Prueba SP Ventas --

EXEC Ventas.InsertarVenta   @TipoCliente= 'Normal', @Sucursal='San Justo', @Genero= 'M', @LegajoEmpleado= '257020', @NumeroFactura='750-67-8428', @TipoFactura='A', @Fecha='1/5/2019' , @Hora= '13:08', @MedioPago='Cash', @IdentificadorPago='0000003100099475144530'
GO

EXEC Ventas.InsertarVenta   @TipoCliente= 'Normal', @Genero= 'M', @LegajoEmpleado= '257020', @NumeroFactura='750-67-8428', @TipoFactura='A', @Fecha='1/5/2019' , @Hora= '13:08', @MedioPago='Cash', @IdentificadorPago='0000003100099475144530'
GO -- No inserta porque espera el parametro sucursal

-- Prueba SP Cargo--
EXEC Administracion.InsertarCargo 'Cajero' -- No funciona porque el cargo ya existe
GO

EXEC Administracion.EliminarCargo 'CEO'
GO
-- Prueba SP Linea--

EXEC Productos.InsertarLinea 'Juguetes'
GO

EXEC Productos.EliminarLinea 'Juguetes'
GO

-- Prueba SP Catalogo--
EXEC Productos.InsertarCatalogo @Producto ='Chocolate_amargo', @Precio='0.15', @PrecioRef='1.2', @UnidadRef='kg', @Fecha='12/11/2024', @Categoria='chocolate'
GO

EXEC Productos.ActualizarCatalogo @Producto ='Chocolate_amargo', @Precio='0.16', @Fecha='12/11/2024',@UnidadRef='gr', @Categoria='chocolate' -- No encuentra el producto ya que el precio no corresponde a ninguno que exista
GO

EXEC Productos.ActualizarCatalogo @Producto ='Chocolate_amargo', @Precio='0.15', @Fecha='12/11/2024',@UnidadRef='gr', @Categoria='chocolate' -- Cambiar unidad de referencia por gramos
GO

EXEC Productos.EliminarCatalogo @Producto ='Chocolate_amargo', @Precio='0.15', @Categoria='chocolate'
GO

-- Prueba SP Detalle de factura--

EXEC Ventas.InsertarDetalleFactura @Factura='7632426' ,@Producto='Aceite corporal tacto seco Deliplus', @Categoria='cuidado_corporal', @PrecioCompra='3.5', @PrecioVenta='3.5' , @Cantidad='3' --- No inserta porque el numero de factura no existe
GO

EXEC Ventas.InsertarDetalleFactura @Factura='976' ,@Producto='6 Panes pulguitas sin aditivos', @Categoria='pan_de_horno', @PrecioCompra='0.79', @PrecioVenta='3.25' , @Cantidad='3' --- No inserta porque el numero de factura no existe
GO

-- Prueba SP Medio de pago--
EXEC Ventas.InsertarMedioDePago 'Credit card',	'Tarjeta de credito' --No inserta porque el medio de pago ya existe
GO

EXEC Ventas.InsertarMedioDePago 'Other',	'Otro medio'
GO

EXEC Ventas.ActualizarMedioDePago 'Other',	'Otro medio'
GO

EXEC Ventas.EliminarMedioDePago 'Other'
GO


-- Prueba SP Nota de credito --
EXEC Ventas.InsertarNotaCredito '101-17-6199'
GO


EXEC Administracion.AgregarColumnasEncriptadasEmpleado 'DireccionEncriptado'
EXEC Administracion.EncriptarDatosEmpleado 'Direccion'
EXEC Administracion.VerEmpleadoDesencriptado 'Direccion'