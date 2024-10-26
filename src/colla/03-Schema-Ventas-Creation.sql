USE Com2900G17

DROP TABLE IF EXISTS Ventas.Venta
DROP TABLE IF EXISTS Ventas.MedioDePago

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Ventas')
BEGIN
    EXEC('CREATE SCHEMA Ventas')
END

CREATE TABLE Ventas.MedioDePago(
	Codigo VARCHAR(15) PRIMARY KEY,
    Descripcion VARCHAR(25) NOT NULL
)

CREATE TABLE Ventas.Venta(
    IdFactura VARCHAR(20) PRIMARY KEY CHECK (IdFactura LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'),
    TipoFactura CHAR(1) NOT NULL CHECK (TipoFactura IN ('A', 'B', 'C')),
    Ciudad VARCHAR(20) NOT NULL,
    TipoCliente VARCHAR(10) NOT NULL CHECK (TipoCliente IN ('Member', 'Normal')),
    Genero CHAR(6) NOT NULL CHECK (Genero IN ('Male', 'Female')),
    Producto NVARCHAR(100) NOT NULL,
    PrecioUnitario DECIMAL(10, 2) NOT NULL CHECK (PrecioUnitario > 0),
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    Fecha DATE NOT NULL,
    Hora TIME NOT NULL,
    MedioPago VARCHAR(15) NOT NULL,
    Empleado INT NOT NULL,
    IdentificadorPago VARCHAR(40) UNIQUE,
    CONSTRAINT FK_Venta_Empleado FOREIGN KEY (Empleado) REFERENCES Administracion.Empleado(IdEmpleado) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Venta_MedioPago FOREIGN KEY (MedioPago) REFERENCES Ventas.MedioDePago(Codigo)
);
