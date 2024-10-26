USE Com2900G17

DROP TABLE IF EXISTS Productos.Catalogo
DROP TABLE IF EXISTS Productos.ProductoImportado
DROP TABLE IF EXISTS Productos.ProductoElectronico
DROP TABLE IF EXISTS Productos.ClasificacionProducto

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Productos')
BEGIN
    EXEC('CREATE SCHEMA Productos')
END

CREATE TABLE Productos.ClasificacionProducto(
    LineaProducto VARCHAR(15) NOT NULL UNIQUE,
    Producto VARCHAR(40) NOT NULL PRIMARY KEY
);

CREATE TABLE Productos.Catalogo(
    Id INT PRIMARY KEY,
    Categoria VARCHAR(40) NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Precio DECIMAL(5, 2) NOT NULL CHECK (Precio > 0),
    PrecioRef DECIMAL(5, 2) NOT NULL CHECK (PrecioRef > 0),
    UnidadRef VARCHAR(5) NOT NULL,
    Fecha DATETIME NOT NULL,
    CONSTRAINT FK_Catalogo_Clasificacion FOREIGN KEY(Categoria) REFERENCES Productos.ClasificacionProducto(Producto) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Productos.ProductoImportado(
    IdProducto INT IDENTITY PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Proveedor VARCHAR(50) NOT NULL,
    Categoria VARCHAR(15) NULL,
    CantidadPorUnidad VARCHAR(25) NOT NULL,
    PrecioUnitario DECIMAL(5, 2) NOT NULL CHECK (PrecioUnitario > 0),
    CONSTRAINT FK_Categoria FOREIGN KEY(Categoria) REFERENCES Productos.ClasificacionProducto(LineaProducto) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Productos.ProductoElectronico(
    IdProducto INT IDENTITY(1,1) PRIMARY KEY,
    Producto VARCHAR(30) NOT NULL,
    PrecioUnitario DECIMAL(5, 2) NOT NULL CHECK (PrecioUnitario > 0)
);
