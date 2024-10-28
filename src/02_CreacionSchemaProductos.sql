USE Com2900G17
GO

DROP TABLE IF EXISTS Productos.Catalogo
GO
DROP TABLE IF EXISTS Productos.ProductoImportado
GO
DROP TABLE IF EXISTS Productos.ProductoElectronico
GO
DROP TABLE IF EXISTS Productos.ClasificacionProducto
GO


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Productos')
BEGIN
    EXEC('CREATE SCHEMA Productos')
END
CREATE TABLE Productos.ClasificacionProducto(
	LineaProducto VARCHAR(15),  -- Categoria
    Producto VARCHAR(40) PRIMARY KEY  -- Nombre
)
GO
CREATE TABLE Productos.Catalogo(
    Id INT PRIMARY KEY,             
    Categoria VARCHAR(40),     
    Nombre VARCHAR(100),               
    Precio DECIMAL(10, 2),              
    PrecioRef DECIMAL(10, 2) ,    
    UnidadRef VARCHAR(10),       
    Fecha varchar(50)                     
	CONSTRAINT FK_Catalogo_Clasificacion FOREIGN KEY(Categoria) 
    REFERENCES Productos.ClasificacionProducto(Producto)
	ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE TABLE Productos.ProductoImportado(
	IdProducto INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
	Proveedor VARCHAR(50) NOT NULL,
    Categoria VARCHAR(15),
    CantidadPorUnidad VARCHAR(25) NOT NULL,
	Precio DECIMAL(10,2)
)
GO
CREATE TABLE Productos.ProductoElectronico(
	Producto VARCHAR(30),
	PrecioUnitario DECIMAL(6,2)
)
GO
