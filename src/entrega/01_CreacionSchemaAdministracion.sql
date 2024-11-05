-----------------------------------------------------------------------
-------------------  CREACION SCHEMA ADMINISTRACION -------------------
-----------------------------------------------------------------------

USE Com2900G17;
GO

-- Eliminación de tablas si existen
DROP TABLE IF EXISTS Administracion.Empleado;
DROP TABLE IF EXISTS Administracion.Sucursal;
GO

BEGIN TRY
    -- Creación del esquema Administracion si no existe
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Administracion')
        EXEC('CREATE SCHEMA Administracion');

    -- Creación de tabla Administracion.Sucursal
    CREATE TABLE Administracion.Sucursal (
        IdSucursal INT IDENTITY(1,1) PRIMARY KEY,
        Ciudad CHAR(10) NOT NULL,
        Sucursal VARCHAR(20) NOT NULL UNIQUE,
        Direccion VARCHAR(100) NOT NULL UNIQUE, -- Que no sea la misma sucursal
        Horario VARCHAR(45) NOT NULL,
        Telefono VARCHAR(10) NOT NULL CHECK (TRY_CAST(Telefono AS INT) IS NOT NULL)
    );

    -- Creación de tabla Administracion.Empleado
    CREATE TABLE Administracion.Empleado (
        IdEmpleado INT PRIMARY KEY,
        Nombre VARCHAR(50) NOT NULL,
        Apellido VARCHAR(50) NOT NULL,
        DNI CHAR(8) NOT NULL CHECK (TRY_CAST(DNI AS INT) IS NOT NULL),
        Direccion VARCHAR(255) NOT NULL,
        EmailPersonal VARCHAR(100) NULL CHECK (EmailPersonal LIKE '%@%.%'),
        EmailEmpresa VARCHAR(100) NULL CHECK (EmailEmpresa LIKE '%@%.%'),
        CUIL CHAR(11) NULL CHECK (TRY_CAST(CUIL AS BIGINT) IS NOT NULL),
        Cargo VARCHAR(30) NOT NULL,
        Sucursal VARCHAR(20) NOT NULL,
        Turno VARCHAR(20) CHECK (Turno IN ('TM', 'TT', 'Jornada Completa')),
        CONSTRAINT FK_Sucursal FOREIGN KEY (Sucursal) 
		REFERENCES Administracion.Sucursal(Sucursal) ON DELETE CASCADE ON UPDATE CASCADE
    );
    PRINT '+ Esquema y tablas en [Administracion] creados correctamente.';
END TRY
BEGIN CATCH
    -- Captura y muestra el error si ocurre uno
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('+ Error durante la creación del esquema o las tablas en [Administracion]: %s', 16, 1, @ErrorMessage);
END CATCH;
