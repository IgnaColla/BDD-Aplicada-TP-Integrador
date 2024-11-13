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
EXEC Ventas.InsertarNotaCredito '102-77-2261';
REVERT;
GO

-- Empleado no puede crear nota de credito
USE Com2900G17;
GO
EXECUTE AS USER = 'UserEmpleado';
EXEC Ventas.InsertarNotaCredito '101-81-4070';
REVERT;
GO
