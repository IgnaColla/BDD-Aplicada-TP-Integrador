-----------------------------------------------------------------------
-------------------  CREACION SCHEMA ADMINISTRACION -------------------
-----------------------------------------------------------------------

USE Com2900G17;
GO

BEGIN TRY
    -- Eliminación de tablas si existen
    IF OBJECT_ID('Administracion.Empleado', 'U') IS NOT NULL
        DROP TABLE Administracion.Empleado;
    IF OBJECT_ID('Administracion.Sucursal', 'U') IS NOT NULL
        DROP TABLE Administracion.Sucursal;
END TRY
BEGIN CATCH
    DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('+ Error eliminando tabla: %s', 16, 1, @ErrorMsg);
END CATCH;

BEGIN TRY
    -- Creación del esquema Administracion si no existe
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Administracion')
        EXEC('CREATE SCHEMA Administracion');

    -- Creación de tabla Administracion.Sucursal
    CREATE TABLE Administracion.Sucursal (
        Ciudad CHAR(10) NOT NULL,
        Sucursal VARCHAR(20) PRIMARY KEY NOT NULL,
        Direccion VARCHAR(100) NOT NULL UNIQUE, -- Que no sea la misma sucursal
        Horario VARCHAR(45) NOT NULL,
        Telefono VARCHAR(10) NOT NULL CHECK (Telefono LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
    );

    -- Creación de tabla Administracion.Empleado
    CREATE TABLE Administracion.Empleado (
        IdEmpleado INT PRIMARY KEY,
        Nombre VARCHAR(50) NOT NULL,
        Apellido VARCHAR(50) NOT NULL,
        DNI CHAR(8) NOT NULL CHECK (DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
        Direccion VARCHAR(255) NOT NULL,
        EmailPersonal VARCHAR(100) NULL CHECK (EmailPersonal LIKE '%@%.%'),
        EmailEmpresa VARCHAR(100) NULL CHECK (EmailEmpresa LIKE '%@%.%'),
        CUIL CHAR(11) NULL CHECK (CUIL LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
        Cargo VARCHAR(30) NOT NULL,
        Sucursal VARCHAR(20) NOT NULL,
        Turno VARCHAR(20) CHECK (Turno IN ('TM', 'TT', 'Jornada Completa')),
        CONSTRAINT FK_Sucursal FOREIGN KEY (Sucursal) REFERENCES Administracion.Sucursal(Sucursal) ON DELETE CASCADE ON UPDATE CASCADE
    );

	RAISERROR('+ Esquema y tablas en [Administracion] creados correctamente.', 0, 1);
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('+ Error durante la creación del esquema o las tablas en [Administracion]: %s', 16, 1, @ErrorMessage);
END CATCH;
