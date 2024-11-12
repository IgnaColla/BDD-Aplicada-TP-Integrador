----------------------------------------------------------
-------------------  Creacion de ROLES -------------------
----------------------------------------------------------

ALTER DATABASE Com2900G17 SET TRUSTWORTHY ON;
GO
USE Com2900G17;
GO
ALTER AUTHORIZATION ON DATABASE::Com2900G17 TO [DESKTOP-MSA0JCB\nahuel];
GO

CREATE LOGIN Empleado WITH PASSWORD = 'Zidane2006';
GO
CREATE LOGIN Supervisor WITH PASSWORD = 'Messi2022';
GO

CREATE USER UserEmpleado FOR LOGIN Empleado;
GO
CREATE USER UserSupervisor FOR LOGIN Supervisor;
GO

CREATE ROLE Empleado;
GO
ALTER ROLE Empleado ADD MEMBER UserEmpleado;
GO

CREATE ROLE Supervisor;
GO
ALTER ROLE Supervisor ADD MEMBER UserSupervisor;
GO

-- Garantizar que todos los Supervisores pueden generar notas de credito, pero los empleados no
REVOKE EXECUTE ON Ventas.InsertarNotaCredito TO Empleado;
GO
GRANT EXECUTE ON Ventas.InsertarNotaCredito TO Supervisor;
GO

-- Tabla Empleado sólo tiene borrado lógico
REVOKE DELETE ON Administracion.Empleado TO Empleado;
GO
REVOKE DELETE ON Administracion.Empleado TO Supervisor;
GO

-- Supervisor puede crear nota de credito
USE Com2900G17;
GO
EXECUTE AS USER = 'UserSupervisor';
EXEC Ventas.InsertarNotaCredito '101-81-4070';
REVERT;
GO

-- Empleado no puede crear nota de credito
USE Com2900G17;
GO
EXECUTE AS USER = 'UserEmpleado';
EXEC Ventas.InsertarNotaCredito '101-81-4070';
REVERT;
GO


--------------------------------------------------------------
-------------------  Encriptación de Datos -------------------
--------------------------------------------------------------

USE Com2900G17;
GO

-- Crear una clave maestra de base de datos
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Sc4ryM0v13!';

-- Crear un certificado para encriptación
CREATE CERTIFICATE CertificadoEmpleado
WITH SUBJECT = 'Encriptacion_empleados';
GO

ALTER TABLE Administracion.Empleado
ADD DNI_encriptado VARBINARY(MAX), Direccion_encriptada VARBINARY(MAX);

-- Encriptar los datos existentes
UPDATE Administracion.Empleado
SET DNI_encriptado = ENCRYPTBYCERTBYKEY(CertificadoEmpleado, DNI),
    Direccion_encriptada = ENCRYPTBYCERTBYKEY(CertificadoEmpleado, Direccion);

-- Eliminar las columnas no encriptadas
-- ALTER TABLE Administracion.Empleado
-- DROP COLUMN DNI, Direccion;

GO
