-------------------------------------------------------------------
-------------------  Stored Procedures BACKUP  --------------------
-------------------------------------------------------------------

/*
Para la ejecucion periodica de estos backups es necesario crear un job en Windows, debido a que la version SQL Server Express
no permite la utilizacion de SQL Server Agent para lograr esto
*/

-- Backup diferencial de la base de datos "Ventas"
BACKUP DATABASE Com2900G17
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLPC\MSSQL\Backups\Ventas_Diario_Diferencial.bak'
WITH DIFFERENTIAL, 
     NAME = 'Backup Diferencial Diario',
     FORMAT;
GO

-- Backup completo de la base de datos "Ventas"
BACKUP DATABASE Com2900G17
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLPC\MSSQL\Backups\Ventas_Semanal_Completo.bak'
WITH FORMAT, 
     NAME = 'Backup Completo Semanal';
GO
