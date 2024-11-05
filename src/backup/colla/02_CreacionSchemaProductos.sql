------------------------------------------------------------------
-------------------  CREACION SCHEMA PRODUCTOS -------------------
------------------------------------------------------------------

USE Com2900G17;
GO

-- Eliminación de tablas si existen
DROP TABLE IF EXISTS Productos.Catalogo;
DROP TABLE IF EXISTS Productos.ProductoImportado;
DROP TABLE IF EXISTS Productos.ProductoElectronico;
DROP TABLE IF EXISTS Productos.ClasificacionProducto;

BEGIN TRY
    -- Creación del esquema Productos si no existe
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Productos')
        EXEC('CREATE SCHEMA Productos');

    -- Creación de tabla Productos.ClasificacionProducto
    CREATE TABLE Productos.ClasificacionProducto (
        LineaProducto VARCHAR(15) NOT NULL UNIQUE,	-- Categoria
        Producto VARCHAR(40) NOT NULL PRIMARY KEY	-- Nombre
    );

    -- Creación de tabla Productos.Catalogo
    CREATE TABLE Productos.Catalogo (
        Id INT PRIMARY KEY,
        Categoria VARCHAR(40) NOT NULL,
        Nombre VARCHAR(100) NOT NULL,
        Precio DECIMAL(10, 2) NOT NULL CHECK (Precio > 0),
        PrecioRef DECIMAL(10, 2) NOT NULL CHECK (PrecioRef > 0),
        UnidadRef VARCHAR(10) NOT NULL,
        Fecha VARCHAR(50) NOT NULL,
        CONSTRAINT FK_Catalogo_Clasificacion FOREIGN KEY (Categoria) REFERENCES Productos.ClasificacionProducto (Producto) ON DELETE CASCADE ON UPDATE CASCADE
    );

    -- Creación de tabla Productos.ProductoImportado
    CREATE TABLE Productos.ProductoImportado (
        IdProducto INT IDENTITY PRIMARY KEY,
        Nombre VARCHAR(50) NOT NULL,
        Proveedor VARCHAR(50) NOT NULL,
        Categoria VARCHAR(15),
        CantidadPorUnidad VARCHAR(25) NOT NULL,
        PrecioUnitario DECIMAL(10, 2) NOT NULL CHECK (PrecioUnitario > 0),
        CONSTRAINT FK_Categoria FOREIGN KEY (Categoria) REFERENCES Productos.ClasificacionProducto (LineaProducto) ON DELETE CASCADE ON UPDATE CASCADE
    );

    -- Creación de tabla Productos.ProductoElectronico
    CREATE TABLE Productos.ProductoElectronico (
        IdProducto INT IDENTITY(1,1) PRIMARY KEY,
        Producto VARCHAR(30) NOT NULL,
        PrecioUnitario DECIMAL(5, 2) NOT NULL CHECK (PrecioUnitario > 0)
    );

    PRINT('+ Esquema y tablas en [Productos] creados correctamente.');
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('+ Error durante la creación del esquema o las tablas en [Productos]: %s', 16, 1, @ErrorMessage);
END CATCH;
