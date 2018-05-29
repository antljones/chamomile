--
EXEC sp_addumpdevice
  @devtype = N'disk'
  , @logicalname = N'<database>_backup'
  , @physicalname= N'<path>\<database>.bak';
GO

--
BACKUP DATABASE [<database>] TO DISK = N'<path>\<database>.bak' WITH FORMAT
  , MEDIANAME = N'<database>_backup', NAME = 'Full Backup of [<database>]';
GO

BACKUP DATABASE [<database>] TO <DATABASE>_backup WITH DIFFERENTIAL;
GO 
