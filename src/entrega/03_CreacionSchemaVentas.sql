USE Com2900G17
GO

DROP TABLE IF EXISTS Ventas.Venta
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

    CREATE TABLE Ventas.Venta(
        IdFactura VARCHAR(20) PRIMARY KEY,           -- ID de la factura como clave primaria
        TipoFactura CHAR(1) NOT NULL CHECK (TipoFactura IN ('A', 'B', 'C')), -- Restricción para tipos de factura
        Ciudad VARCHAR(10) NOT NULL,                  -- Ciudad, suficiente espacio para nombres
        TipoCliente VARCHAR(10) NOT NULL,            -- Tipo de cliente, 'Member' o 'Normal'
        Genero CHAR(6) NOT NULL,                      -- Género, 'Male' o 'Female'
        Producto VARCHAR(100) NOT NULL,               -- Nombre del producto, tama�o ajustado
        PrecioUnitario DECIMAL(10, 2) NOT NULL,       -- Precio unitario con hasta 2 decimales
        Cantidad INT NOT NULL CHECK (Cantidad > 0),   -- Cantidad, debe ser mayor a 0
        Fecha DATE NOT NULL,                           -- Fecha de la venta
        Hora TIME NOT NULL,                            -- Hora de la venta
        MedioPago VARCHAR(15) NOT NULL,              -- Medio de pago, tama�o ajustado
        Empleado INT NOT NULL,                         -- ID del empleado, tipo INT
        IdentificadorPago VARCHAR(40),                -- Identificador de pago, tama�o ajustado
        CONSTRAINT FK_Venta_Empleado FOREIGN KEY(Empleado) REFERENCES Administracion.Empleado(IdEmpleado) ON DELETE CASCADE ON UPDATE CASCADE,
        CONSTRAINT FK_Venta_Medio_Pago FOREIGN KEY(MedioPago) REFERENCES Ventas.MedioDePago(Codigo) ON DELETE CASCADE ON UPDATE CASCADE,
        CONSTRAINT FK_Venta_Producto FOREIGN KEY(Producto, PrecioUnitario) REFERENCES Productos.Producto(Producto, Precio) ON DELETE CASCADE ON UPDATE CASCADE
    )

    PRINT('+ Esquema y tablas en [Ventas] creados correctamente.');
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('+ Error durante la creación del esquema o las tablas en [Ventas]: %s', 16, 1, @ErrorMessage);
END CATCH;
