-------------------------------------------------------------------
-------------------  CREACION SCHEMA PRODUCTOS  -------------------
-------------------------------------------------------------------

USE Com2900G17;
GO

DROP TABLE IF EXISTS Productos.CatalogoCategoria
GO
DROP TABLE IF EXISTS Productos.Categoria
GO
DROP TABLE IF EXISTS Productos.Linea
GO
DROP TABLE IF EXISTS Productos.Catalogo
GO


BEGIN TRY
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Productos')
        EXEC('CREATE SCHEMA Productos')

	-- Creación de tabla Linea
    CREATE TABLE Productos.Linea(
        Id INT IDENTITY(1,1) PRIMARY KEY,
        LineaProducto VARCHAR(15) NOT NULL
    )

	-- Creación de tabla Categoria
	CREATE TABLE Productos.Categoria(
        Id INT IDENTITY(1,1) PRIMARY KEY,
		Categoria VARCHAR(40) UNIQUE NOT NULL,
		IdLinea INT,
		CONSTRAINT Fk_Linea FOREIGN KEY(IdLinea)
		REFERENCES Productos.Linea(Id) ON DELETE SET NULL ON UPDATE CASCADE
	)

	-- Creación de tabla Catalogo
    CREATE TABLE Productos.Catalogo(
        Id INT PRIMARY KEY,
		Producto VARCHAR(100) NOT NULL, 
        Precio DECIMAL(10, 2) NOT NULL,    
		PrecioRef DECIMAL(10, 2),    
        UnidadRef VARCHAR(10),       
        Fecha CHAR(20)                     
    )

	-- Creación de una tabla intermedia 
	CREATE TABLE Productos.CatalogoCategoria (
		IdCatalogo INT NOT NULL,
		IdCategoria INT NOT NULL,
		CONSTRAINT FK_CatalogoCategoria_Catalogo FOREIGN KEY (IdCatalogo)
		REFERENCES Productos.Catalogo(Id),
		CONSTRAINT FK_CatalogoCategoria_Categoria FOREIGN KEY (IdCategoria)
		REFERENCES Productos.Categoria(Id),
		PRIMARY KEY (IdCatalogo, IdCategoria)
	);

    PRINT('+ Esquema y tablas en [Productos] creados correctamente.');
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
    RAISERROR('+ Error durante la creación del esquema o las tablas en [Productos]: %s', 16, 1, @ErrorMessage);
END CATCH;

