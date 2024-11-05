----------------------------------------------------------
-------------------  Creacion de ROLES -------------------
----------------------------------------------------------

USE Com2900G17;
GO

-- CREATE LOGIN Empleado WITH PASSWORD = 'Zidane2006';
-- CREATE LOGIN Supervisor WITH PASSWORD = 'Messi2022';

CREATE ROLE Empleado;
ALTER ROLE Empleado ADD MEMBER --EMP;

CREATE ROLE Supervisor;
ALTER ROLE Supervisor ADD MEMBER --MIEMBRO;

GRANT SELECT ON Productos.Catalogo TO Empleado;
GRANT INSERT, DELETE ON Productos.Catalogo TO Supervisor;
GO


--------------------------------------------------------------
-------------------  Encriptación de Datos -------------------
--------------------------------------------------------------

USE Com2900G17;
GO

-- Crear una clave maestra de base de datos
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ContraseñaSegura123!';

-- Crear un certificado para encriptación
CREATE CERTIFICATE CertificadoEmpleado
WITH SUBJECT = 'Encriptacion de datos de empleados';


ALTER TABLE Administracion.Empleado
ADD DNI_encriptado VARBINARY(MAX), Direccion_encriptada VARBINARY(MAX);

-- Encriptar los datos existentes
UPDATE Administracion.Empleado
SET DNI_encriptado = ENCRYPTBYCERTBYKEY(CertificadoEmpleado, DNI),
    Direccion_encriptada = ENCRYPTBYCERTBYKEY(CertificadoEmpleado, Direccion);

-- Opcional: Elimina las columnas no encriptadas si ya no son necesarias
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
