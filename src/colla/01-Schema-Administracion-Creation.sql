USE Com2900G17

DROP TABLE IF EXISTS Administracion.Empleado
DROP TABLE IF EXISTS Administracion.Sucursal

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Administracion')
BEGIN
    EXEC('CREATE SCHEMA Administracion')
END

CREATE TABLE Administracion.Sucursal(
    Ciudad CHAR(10) NOT NULL,
	Sucursal VARCHAR(20) PRIMARY KEY NOT NULL,
    Direccion VARCHAR(100) NOT NULL UNIQUE,			-- Que no sea la misma sucursal
    Horario VARCHAR(45) NOT NULL,
    Telefono VARCHAR(10) NOT NULL CHECK (Telefono LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
);

CREATE TABLE Administracion.Empleado(
    IdEmpleado INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    DNI CHAR(8) NOT NULL CHECK (DNI LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),			-- 8 digitos porque 7 es gente jubilada.
    Direccion VARCHAR(255) NOT NULL,
    EmailPersonal VARCHAR(100) NULL CHECK (EmailPersonal LIKE '%@%.%'),
    EmailEmpresa VARCHAR(100) NULL CHECK (EmailEmpresa LIKE '%@%.%'),
    CUIL CHAR(11) NULL CHECK (CUIL LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    Cargo VARCHAR(30) NOT NULL,
    Sucursal VARCHAR(20) NOT NULL,
    Turno VARCHAR(20) CHECK (Turno IN ('TM', 'TT', 'Jornada Completa')),						-- Restricción para turnos válidos
    CONSTRAINT FK_Sucursal FOREIGN KEY(Sucursal) REFERENCES Administracion.Sucursal(Sucursal) ON DELETE CASCADE ON UPDATE CASCADE
);
