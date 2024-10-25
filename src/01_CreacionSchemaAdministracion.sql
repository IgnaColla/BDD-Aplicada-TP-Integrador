USE Com2900G17
GO

DROP TABLE IF EXISTS Administracion.Empleado
GO
DROP TABLE IF EXISTS Administracion.Sucursal
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Administracion')
BEGIN
    EXEC('CREATE SCHEMA Administracion')
END
GO
CREATE TABLE Administracion.Sucursal(
	Ciudad CHAR(10),            
    Sucursal VARCHAR(20) PRIMARY KEY,     
    Direccion VARCHAR(100),      
    Horario VARCHAR(45),        
    Telefono VARCHAR(10)   
)
GO
CREATE TABLE Administracion.Empleado(
	IdEmpleado INT PRIMARY KEY, 
    Nombre VARCHAR(50) NOT NULL,             
    Apellido VARCHAR(50) NOT NULL,           
    DNI CHAR(8) NOT NULL,              
    Direccion VARCHAR(255) NOT NULL,         
    EmailPersonal VARCHAR(100),             
    EmailEmpresa VARCHAR(100),              
    CUIL CHAR(11) NULL,                     
    Cargo VARCHAR(30) NOT NULL,              
    Sucursal VARCHAR(20) NOT NULL,           
    Turno VARCHAR(20) CHECK (Turno IN ('TM', 'TT', 'Jornada Completa')) -- Restricción para turnos válidos
	CONSTRAINT FK_Sucursal FOREIGN KEY(Sucursal) REFERENCES Administracion.Sucursal(Sucursal)
	ON DELETE CASCADE ON UPDATE CASCADE
)
GO
