----------------------------------------------------------------
-------------------  CREACION SCHEMA VENTAS  -------------------
----------------------------------------------------------------

USE Com2900G17;
GO

DROP TABLE IF EXISTS Ventas.Venta
GO
DROP TABLE IF EXISTS Ventas.DetalleFactura
GO
DROP TABLE IF EXISTS Ventas.NotaCredito
GO
DROP TABLE IF EXISTS Ventas.Factura
GO
DROP TABLE IF EXISTS Ventas.MedioDePago
GO

BEGIN TRY
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Ventas')
        EXEC('CREATE SCHEMA Ventas')

    CREATE TABLE Ventas.MedioDePago(
        Id INT IDENTITY PRIMARY KEY,
        Codigo VARCHAR(15) UNIQUE,
        Descripcion VARCHAR(25)          
    )

	CREATE TABLE Ventas.Factura(
		Id INT IDENTITY(1,1) PRIMARY KEY,
		NumeroFactura VARCHAR(15) UNIQUE NOT NULL,
		TipoFactura CHAR(1) NOT NULL CHECK (TipoFactura IN ('A', 'B', 'C')),
		Fecha DATE NOT NULL,                         
        Hora TIME NOT NULL,                            
		IdMedioPago INT NOT NULL,              
		Subtotal DECIMAL(10,2) NOT NULL,
		Total DECIMAL(10,2) NOT NULL,
		IdentificadorPago VARCHAR(40),
		CONSTRAINT Fk_Factura_Pago FOREIGN KEY(IdMedioPago)
		REFERENCES Ventas.MedioDePago(Id)
	)

	CREATE TABLE Ventas.DetalleFactura(
		Id INT IDENTITY(1,1) PRIMARY KEY,
		IdFactura INT NOT NULL,
		IdProducto INT NOT NULL,
		PrecioUnitario DECIMAL(10,5) NOT NULL,
		Cantidad INT NOT NULL CHECK(Cantidad > 0)
		CONSTRAINT Fk_Detalle_Factura FOREIGN KEY(IdFactura)
		REFERENCES Ventas.Factura(Id),
		CONSTRAINT Fk_Detalle_Producto FOREIGN KEY(IdProducto)
		REFERENCES Productos.Catalogo(Id)
	)

	CREATE TABLE Ventas.NotaCredito(
		Id INT IDENTITY(1,1) PRIMARY KEY,
		IdFactura INT NOT NULL,
		CONSTRAINT Fk_Nota_Factura FOREIGN KEY(IdFactura)
		REFERENCES Ventas.Factura(Id)
	)

    CREATE TABLE Ventas.Venta(
		Id INT IDENTITY(1,1) PRIMARY KEY,
        IdFactura INT NOT NULL, 
		IdSucursal INT,
        TipoCliente VARCHAR(10) NOT NULL CHECK(TipoCliente IN('Member', 'Normal')),
        Genero CHAR(1) NOT NULL CHECK(Genero IN('F', 'M')),                      
		IdEmpleado INT,
		CONSTRAINT FK_Venta_Empleado FOREIGN KEY(IdEmpleado) 
		REFERENCES Administracion.Empleado(Legajo) ON DELETE SET NULL ON UPDATE CASCADE,
		CONSTRAINT FK_Venta_Sucursal FOREIGN KEY(IdSucursal) 
		REFERENCES Administracion.Sucursal(Id),
        CONSTRAINT FK_Venta_Factura FOREIGN KEY(IdFactura) 
		REFERENCES Ventas.Factura(Id) ON DELETE CASCADE ON UPDATE CASCADE,
	)

    PRINT('+ Esquema y tablas en [Ventas] creados correctamente.');
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
    RAISERROR('+ Error durante la creación del esquema o las tablas en [Ventas]: %s', 16, 1, @ErrorMessage);
END CATCH;
