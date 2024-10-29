---------------------------------------------------------------
-------------------  CREACION SCHEMA VENTAS -------------------
---------------------------------------------------------------

USE Com2900G17
GO

-- Eliminación de tablas si existen
DROP TABLE IF EXISTS Ventas.Venta;
DROP TABLE IF EXISTS Ventas.MedioDePago;

BEGIN TRY
	-- Creación del esquema Ventas si no existe
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Ventas')
        EXEC('CREATE SCHEMA Ventas');

	-- Creación de tabla MedioDePago
	CREATE TABLE Ventas.MedioDePago(
		idMP INT IDENTITY,
		Codigo VARCHAR(15) PRIMARY KEY,
		Descripcion VARCHAR(25) NOT NULL
	)

	-- Creación de tabla Venta
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

	PRINT('+ Esquema y tablas en [Ventas] creados correctamente.');
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('+ Error durante la creación del esquema o las tablas en [Ventas]: %s', 16, 1, @ErrorMessage);
END CATCH;
