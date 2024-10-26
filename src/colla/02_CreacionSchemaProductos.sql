------------------------------------------------------------------
-------------------  CREACION SCHEMA PRODUCTOS -------------------
------------------------------------------------------------------

USE Com2900G17;
GO

BEGIN TRY
    -- Eliminación de tablas si existen
    IF OBJECT_ID('Productos.Catalogo', 'U') IS NOT NULL
        DROP TABLE Productos.Catalogo;
    IF OBJECT_ID('Productos.ProductoImportado', 'U') IS NOT NULL
        DROP TABLE Productos.ProductoImportado;
    IF OBJECT_ID('Productos.ProductoElectronico', 'U') IS NOT NULL
        DROP TABLE Productos.ProductoElectronico;
    IF OBJECT_ID('Productos.ClasificacionProducto', 'U') IS NOT NULL
        DROP TABLE Productos.ClasificacionProducto;
END TRY
BEGIN CATCH
    DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('+ Error eliminando tabla: %s', 16, 1, @ErrorMsg);
END CATCH;

BEGIN TRY
    -- Creación del esquema Productos si no existe
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Productos')
        EXEC('CREATE SCHEMA Productos');

    -- Creación de tabla Productos.ClasificacionProducto
    CREATE TABLE Productos.ClasificacionProducto (
        LineaProducto VARCHAR(15) NOT NULL UNIQUE,
        Producto VARCHAR(40) NOT NULL PRIMARY KEY
    );

    -- Creación de tabla Productos.Catalogo
    CREATE TABLE Productos.Catalogo (
        Id INT PRIMARY KEY,
        Categoria VARCHAR(40) NOT NULL,
        Nombre VARCHAR(50) NOT NULL,
        Precio DECIMAL(5, 2) NOT NULL CHECK (Precio > 0),
        PrecioRef DECIMAL(5, 2) NOT NULL CHECK (PrecioRef > 0),
        UnidadRef VARCHAR(5) NOT NULL,
        Fecha DATETIME NOT NULL,
        CONSTRAINT FK_Catalogo_Clasificacion FOREIGN KEY (Categoria) 
            REFERENCES Productos.ClasificacionProducto (Producto) ON DELETE CASCADE ON UPDATE CASCADE
    );

    -- Creación de tabla Productos.ProductoImportado
    CREATE TABLE Productos.ProductoImportado (
        IdProducto INT IDENTITY PRIMARY KEY,
        Nombre VARCHAR(50) NOT NULL,
        Proveedor VARCHAR(50) NOT NULL,
        Categoria VARCHAR(15) NULL,
        CantidadPorUnidad VARCHAR(25) NOT NULL,
        PrecioUnitario DECIMAL(5, 2) NOT NULL CHECK (PrecioUnitario > 0),
        CONSTRAINT FK_Categoria FOREIGN KEY (Categoria) 
            REFERENCES Productos.ClasificacionProducto (LineaProducto) ON DELETE CASCADE ON UPDATE CASCADE
    );

    -- Creación de tabla Productos.ProductoElectronico
    CREATE TABLE Productos.ProductoElectronico (
        IdProducto INT IDENTITY(1,1) PRIMARY KEY,
        Producto VARCHAR(30) NOT NULL,
        PrecioUnitario DECIMAL(5, 2) NOT NULL CHECK (PrecioUnitario > 0)
    );

    RAISERROR('+ Esquema y tablas en [Productos] creados correctamente.', 0, 1);
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('+ Error durante la creación del esquema o las tablas en [Productos]: %s', 16, 1, @ErrorMessage);
END CATCH;
