USE Com2900G17
GO

DROP TABLE IF EXISTS Ventas.Venta
GO
DROP TABLE IF EXISTS Ventas.MedioDePago
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Ventas')
BEGIN
    EXEC('CREATE SCHEMA Ventas')
END
GO
CREATE TABLE Ventas.MedioDePago(
	Id int identity,
	Codigo VARCHAR(15) PRIMARY KEY,
    Descripcion VARCHAR(25)          
)
GO
CREATE TABLE Ventas.Venta(
	IdFactura VARCHAR(20) PRIMARY KEY,           -- ID de la factura como clave primaria
    TipoFactura CHAR(1) NOT NULL CHECK (TipoFactura IN ('A', 'B', 'C')), -- Restricción para tipos de factura
    Ciudad VARCHAR(10) NOT NULL,                  -- Ciudad, suficiente espacio para nombres
    TipoCliente VARCHAR(10) NOT NULL,            -- Tipo de cliente, 'Member' o 'Normal'
    Genero CHAR(6) NOT NULL,                      -- Género, 'Male' o 'Female'
    Producto NVARCHAR(100) NOT NULL,               -- Nombre del producto, tamaño ajustado
    PrecioUnitario DECIMAL(10, 2) NOT NULL,       -- Precio unitario con hasta 2 decimales
    Cantidad INT NOT NULL CHECK (Cantidad > 0),   -- Cantidad, debe ser mayor a 0
    Fecha DATE NOT NULL,                           -- Fecha de la venta
    Hora TIME NOT NULL,                            -- Hora de la venta
    MedioPago VARCHAR(15) NOT NULL,              -- Medio de pago, tamaño ajustado
    Empleado INT NOT NULL,                         -- ID del empleado, tipo INT
    IdentificadorPago VARCHAR(40),                -- Identificador de pago, tamaño ajustado
	CONSTRAINT FK_Venta_Empleado FOREIGN KEY(Empleado) 
	REFERENCES Administracion.Empleado(IdEmpleado)
	ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FK_Venta_Medio_Pago FOREIGN KEY(MedioPago) 
	REFERENCES Ventas.MedioDePago(Codigo)
	ON DELETE CASCADE ON UPDATE CASCADE
)
GO
