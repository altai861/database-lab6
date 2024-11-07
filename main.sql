-- STEP 1: FULL BACKUP
-- First ensure you're using master database
USE master;
GO

-- Set recovery model to FULL if not already
ALTER DATABASE YourDatabase
SET RECOVERY FULL;
GO

-- 1. Create Full Backup
BACKUP DATABASE YourDatabase
TO DISK = 'C:\SQLBackups\YourDatabase_Full.bak'
WITH FORMAT,
    NAME = 'YourDatabase Full Backup',
    DESCRIPTION = 'Full backup of YourDatabase';
GO

-- STEP 2: MAKE SOME CHANGES AND CREATE DIFFERENTIAL BACKUP
-- Switch to your database
USE YourDatabase;
GO

-- Make some changes (example - adjust according to your database)
INSERT INTO Students (StudentName, Age)
VALUES ('John Doe', 20);
GO

-- Create Differential Backup
BACKUP DATABASE YourDatabase
TO DISK = 'C:\SQLBackups\YourDatabase_Diff.bak'
WITH DIFFERENTIAL,
    NAME = 'YourDatabase Differential Backup',
    DESCRIPTION = 'Differential backup containing changes since full backup';
GO

-- STEP 3: MAKE MORE CHANGES AND CREATE LOG BACKUP
-- Make more changes
INSERT INTO Students (StudentName, Age)
VALUES ('Jane Smith', 22);
GO

-- Create Transaction Log Backup
BACKUP LOG YourDatabase
TO DISK = 'C:\SQLBackups\YourDatabase_Log.trn'
WITH 
    NAME = 'YourDatabase Log Backup',
    DESCRIPTION = 'Transaction log backup';
GO

-- STEP 4: RESTORE DATABASE (FULL RESTORE)
USE master;
GO

-- Set database to single user mode
ALTER DATABASE YourDatabase
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

-- Restore the full backup
RESTORE DATABASE YourDatabase
FROM DISK = 'C:\SQLBackups\YourDatabase_Full.bak'
WITH REPLACE,
    RECOVERY;
GO

-- Set database back to multi user mode
ALTER DATABASE YourDatabase
SET MULTI_USER;
GO

-- STEP 5: POINT-IN-TIME RECOVERY
-- First, set to single user mode again
ALTER DATABASE YourDatabase
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

-- Restore full backup with NORECOVERY
RESTORE DATABASE YourDatabase
FROM DISK = 'C:\SQLBackups\YourDatabase_Full.bak'
WITH NORECOVERY;
GO

-- Restore differential backup with NORECOVERY
RESTORE DATABASE YourDatabase
FROM DISK = 'C:\SQLBackups\YourDatabase_Diff.bak'
WITH NORECOVERY;
GO

-- Restore log backup to a specific point in time
RESTORE LOG YourDatabase
FROM DISK = 'C:\SQLBackups\YourDatabase_Log.trn'
WITH RECOVERY,
    STOPAT = '2024-11-07 15:00:00';
GO

-- Set back to multi user mode
ALTER DATABASE YourDatabase
SET MULTI_USER;
GO