
-- STEP 1: FULL BACKUP
-- First ensure you're using master database
USE MASTER;
GO

ALTER DATABASE LMS
SET RECOVERY FULL;
GO

BACKUP DATABASE LMS
TO DISK = '/var/opt/mssql/data/backups/LMS_FULL.bak'
WITH FORMAT,
    NAME = 'LMS FULL BACKUP',
    DESCRIPTION = 'LMS full backup hiiv';
GO

-- STEP 2: MAKE SOME CHANGES AND CREATE DIFFERENTIAL BACKUP
-- Switch to your database
USE LMS
GO

INSERT INTO Student (RD, firstname, lastname, email, phoneNumber, birthdate, firstExamScore, startDate)
VALUES
('МЮ04300529', 'Altai', 'Gantumut', 'altai@gmail.com', '123-456-7890', '2005-06-15', 85, '2024-09-01'),
('МЮ04300530', 'Goku', 'Goku', 'goku@gmail.com', '123-456-7891', '2006-07-20', 90, '2024-09-01'),
('МЮ04300531', 'Vegeta', 'Vegeta', 'vegeta@gmail.com', '123-456-7892', '2005-05-10', 88, '2024-09-01'),
('МЮ04300532', 'Buu', 'Buu', 'buu@gmail.com', '123-456-7893', '2006-02-18', 92, '2024-09-01'),
('МЮ04300533', 'Naruto', 'Uzumaki', 'naruto@gmail.com', '123-456-7894', '2005-11-30', 78, '2024-09-01');


BACKUP DATABASE LMS 
TO DISK = '/var/opt/mssql/data/backups/LMS_diff.bak'
WITH DIFFERENTIAL,
    NAME = 'LMS differential backup',
    DESCRIPTION = 'Differential backup'
GO



-- STEP 3: MAKE MORE CHANGES AND CREATE LOG BACKUP
-- Make more changes

INSERT INTO Student (RD, firstname, lastname, email, phoneNumber, birthdate, firstExamScore, startDate)
VALUES
('МЮ04300534', 'Luffy', 'Luffy', 'altai@gmail.com', '123-456-7890', '2005-06-15', 85, '2024-09-01'),
('МЮ04300535', 'Nami', 'Nami', 'goku@gmail.com', '123-456-7891', '2006-07-20', 90, '2024-09-01'),
('МЮ04300536', 'Zoro', 'Zoro', 'vegeta@gmail.com', '123-456-7892', '2005-05-10', 88, '2024-09-01'),
('МЮ04300537', 'Sanji', 'Sanji', 'buu@gmail.com', '123-456-7893', '2006-02-18', 92, '2024-09-01'),
('МЮ04300538', 'Chopper', 'Chopper', 'naruto@gmail.com', '123-456-7894', '2005-11-30', 78, '2024-09-01');



-- create transactional log backup

BACKUP LOG LMS 
TO DISK = '/var/opt/mssql/data/backups/LMS_log1.trn'
WITH 
    NAME = 'LMS log backup 1',
    DESCRIPTION = 'Transaction log backup 1'
GO



-- STEP 4: RESTORE DATABASE (FULL RESTORE)
USE master;
GO


ALTER DATABASE LMS
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

-- Restore the full backup
RESTORE DATABASE LMS
FROM DISK = '/var/opt/mssql/data/backups/LMS_FULL.bak'
WITH REPLACE,
    RECOVERY;
GO

-- Set database back to multi user mode
ALTER DATABASE LMS
SET MULTI_USER;
GO




-- POINT IN TIME Nov 8 2024 8:30 am
-- STEP 5: POINT-IN-TIME RECOVERY
-- First, set to single user mode again

USE master;
GO

ALTER DATABASE LMS
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO


-- Restore differential backup with NORECOVERY
RESTORE DATABASE LMS
FROM DISK = '/var/opt/mssql/data/backups/LMS_FULL.bak'
WITH NORECOVERY, REPLACE;
GO

-- -- Restore differential backup with NORECOVERY
RESTORE DATABASE LMS
FROM DISK = '/var/opt/mssql/data/backups/LMS_diff.bak'
WITH NORECOVERY;
GO

-- Restore log backup to a specific point in time
RESTORE LOG LMS
FROM DISK = '/var/opt/mssql/data/backups/LMS_log1.trn'
WITH RECOVERY,
    STOPAT = '2024-11-08 09:58:00';
GO

RESTORE DATABASE LMS
WITH RECOVERY;
GO


-- Set database back to multi user mode
ALTER DATABASE LMS
SET MULTI_USER;
GO



-- Set back to multi user mode
ALTER DATABASE YourDatabase
SET MULTI_USER;
GO
