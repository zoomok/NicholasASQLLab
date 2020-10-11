--===========================================================================================================================
-- Lab 10 : Add Azure SQL database user
--===========================================================================================================================
* Databases -> Security -> New -> Login
-- ======================================================================================
-- Create SQL Login template for Azure SQL Database and Azure SQL Data Warehouse Database
-- ======================================================================================
CREATE LOGIN demouser
	WITH PASSWORD = 'xxx0318' 
GO
	
* SQL0318 -> Security -> Users -> New user
-- ========================================================================================
-- Create User as DBO template for Azure SQL Database and Azure SQL Data Warehouse Database
-- ========================================================================================
-- For login <login_name, sysname, login_name>, create a user in the database
CREATE USER demouser
	FOR LOGIN demouser
	WITH DEFAULT_SCHEMA = dbo
GO

-- Add user to the database owner role
EXEC sp_addrolemember N'db_datareader', N'demouser'
EXEC sp_addrolemember N'db_datawriter', N'demouser'
GO;

-- DB : master (for SSMS Connection)
CREATE USER demouser FROM LOGIN demouser;

--(End)----------------------------------------------------------------------------------------------------------------------
