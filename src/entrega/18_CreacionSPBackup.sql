-------------------------------------------------------------------
-------------------  Stored Procedures BACKUP  --------------------
-------------------------------------------------------------------
-- Backup completo de la base de datos "Ventas"

USE Com2900G17
GO

CREATE OR ALTER PROCEDURE Administracion.backupDiario
    @Path NVARCHAR(255)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    SET @sql = 'BACKUP DATABASE Com2900G17 TO DISK = ''' + @Path + ''' WITH DIFFERENTIAL, NAME = ''Backup Diferencial Diario'', FORMAT;'

    EXEC sp_executesql @sql
END;
GO


CREATE OR ALTER PROCEDURE Administracion.backupSemanal
    @Path NVARCHAR(255)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    SET @sql = 'BACKUP DATABASE Com2900G17 TO DISK = ''' + @Path + ''' WITH FORMAT, NAME = ''Backup Diferencial Diario'', FORMAT;'

    EXEC sp_executesql @sql
END;
GO

exec Administracion.backupSemanal @Path = 'D:\Backup\Ventas_Semanal_Completo.bak'
exec Administracion.backupDiario @Path = 'D:\Backup\Ventas_Diario_Diferencial.bak'

EXEC Ventas.InformeMensualDiarioTotalFacturadoXML