------------------------------------------------------------------
-------------------  CREACION SCHEMA PRODUCTOS -------------------
------------------------------------------------------------------

USE Com2900G17;
GO

DROP TABLE IF EXISTS Productos.Catalogo
GO
DROP TABLE IF EXISTS Productos.Producto
GO
DROP TABLE IF EXISTS Productos.ClasificacionProducto
GO

BEGIN TRY
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Productos')
        EXEC('CREATE SCHEMA Productos')

    CREATE TABLE Productos.ClasificacionProducto(
        Id INT IDENTITY(1,1) PRIMARY KEY,
        LineaProducto VARCHAR(15),
        Categoria VARCHAR(40) UNIQUE
    )

    CREATE TABLE Productos.Producto(
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Producto VARCHAR(100),
        Precio DECIMAL(10,2),
        UNIQUE(Producto, Precio)
    )

    CREATE TABLE Productos.Catalogo(
        Id INT,             
        Categoria VARCHAR(40),     
        Nombre VARCHAR(100),               
        Precio DECIMAL(10, 2),              
        PrecioRef DECIMAL(10, 2) ,    
        UnidadRef VARCHAR(10),       
        Fecha varchar(50)                     
        CONSTRAINT FK_Catalogo_Clasificacion FOREIGN KEY(Categoria) REFERENCES Productos.ClasificacionProducto(Categoria) ON DELETE CASCADE ON UPDATE CASCADE,
        CONSTRAINT FK_Catalogo_Producto_Precio FOREIGN KEY(Nombre, Precio) REFERENCES Productos.Producto(Producto, Precio) ON DELETE CASCADE ON UPDATE CASCADE
    )

    PRINT('+ Esquema y tablas en [Productos] creados correctamente.');
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('+ Error durante la creación del esquema o las tablas en [Productos]: %s', 16, 1, @ErrorMessage);
END CATCH;
