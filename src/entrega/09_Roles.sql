----------------------------------------------------------
-------------------  Creacion de ROLES -------------------
----------------------------------------------------------

USE Com2900G17;
GO

CREATE LOGIN Empleado WITH PASSWORD = 'Zidane2006';
CREATE LOGIN Supervisor WITH PASSWORD = 'Messi2022';

CREATE USER UserEmpleado FOR LOGIN Empleado;
CREATE USER UserSupervisor FOR LOGIN Supervisor;

CREATE ROLE Empleado;
ALTER ROLE Empleado ADD MEMBER UserEmpleado;

CREATE ROLE Supervisor;
ALTER ROLE Supervisor ADD MEMBER UserSupervisor;

GRANT SELECT ON Productos.Catalogo TO Empleado;
GRANT CONTROL ON Productos.Catalogo TO Supervisor;
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

-----------------------------------------------------------
-------------------  Creacion de BACKUP -------------------
-----------------------------------------------------------

USE Com2900G17;
GO

BACKUP DATABASE Com2900G17
TO DISK = 'C:\Backups\Com2900G17_Full.bak'
WITH FORMAT,
    NAME = 'Full_backup';
GO
