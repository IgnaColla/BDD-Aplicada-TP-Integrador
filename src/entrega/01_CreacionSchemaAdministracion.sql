------------------------------------------------------------------------
-------------------  CREACION SCHEMA ADMINISTRACION  -------------------
------------------------------------------------------------------------

USE Com2900G17;
GO

-- Eliminación de tablas si existen
DROP TABLE IF EXISTS Administracion.Empleado;
GO
DROP TABLE IF EXISTS Administracion.Cargo;
GO
DROP TABLE IF EXISTS Administracion.Sucursal;
GO

BEGIN TRY
    -- Creación del esquema Administracion si no existe
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Administracion')
        EXEC('CREATE SCHEMA Administracion');

    -- Creación de tabla Sucursal
    CREATE TABLE Administracion.Sucursal (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Ciudad VARCHAR(20) NOT NULL,
		Nombre VARCHAR(20) NOT NULL,
        Direccion VARCHAR(100) NOT NULL,
        Horario VARCHAR(45) NOT NULL,
        Telefono VARCHAR(10) NOT NULL,
		UNIQUE(Ciudad, Direccion)
    );

	-- Creación de tabla Cargo
	CREATE TABLE Administracion.Cargo(
		Id INT IDENTITY(1,1) PRIMARY KEY,
		Cargo VARCHAR(30) NOT NULL UNIQUE
	);

    -- Creación de tabla Empleado
    CREATE TABLE Administracion.Empleado (
        Legajo INT PRIMARY KEY,
        Nombre VARCHAR(50) NOT NULL,
        Apellido VARCHAR(50) NOT NULL,
        DNI CHAR(8) NOT NULL CHECK (TRY_CAST(DNI AS INT) IS NOT NULL AND LEN(DNI) = 8),
        Direccion VARCHAR(255) NOT NULL,
        EmailPersonal VARCHAR(100) NULL CHECK (EmailPersonal LIKE '%@%.%'),
        EmailEmpresa VARCHAR(100) NULL CHECK (EmailEmpresa LIKE '%@%.%'),
        CUIL CHAR(11) CHECK (TRY_CAST(CUIL AS BIGINT) IS NOT NULL AND LEN(CUIL) = 11 OR CUIL IS NULL),
        IdCargo INT NOT NULL,
        IdSucursal INT,
        Turno VARCHAR(20) CHECK (Turno IN ('TM', 'TT', 'Jornada Completa')),
		Estado CHAR(1) CHECK (Estado IN('A', 'I')),
        CONSTRAINT FK_Sucursal FOREIGN KEY (IdSucursal) 
		REFERENCES Administracion.Sucursal(Id) ON DELETE SET NULL ON UPDATE CASCADE,
		CONSTRAINT FK_Cargo FOREIGN KEY (IdCargo) 
        REFERENCES Administracion.Cargo(Id) ON UPDATE CASCADE
    );
    PRINT '+ Esquema y tablas en [Administracion] creados correctamente.';
END TRY
BEGIN CATCH
    -- Captura y muestra el error si ocurre uno
    DECLARE @ErrorMessage VARCHAR(500) = ERROR_MESSAGE();
    RAISERROR('+ Error durante la creación del esquema o las tablas en [Administracion]: %s', 16, 1, @ErrorMessage);
END CATCH;
