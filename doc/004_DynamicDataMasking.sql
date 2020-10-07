--===========================================================================================================================
-- Lab 4 : Dynamic Data Masking
--===========================================================================================================================
* Sensitive information doesn`t not visible
* NickSQLDB -> Create demo table
	create table dbo.DemoTable
	(
	Name varchar(50),
	Email varchar(100)
	);

	insert into dbo.DemoTable values ('Nick','xxx@gmail.com');

	select	*
	from	dbo.DemoTable
	;

* NickSQLDB -> Security/Dynamic data masking -> Add mask :
	1. Schema	: dbo
	2. Table 	: DemoTable
	3. Column 	: Email
	4. Masking field format : Email
	5. Add -> Save

* SQL users excluded from masking (administrators are always excluded) :
	Null (or Add dbuser to exclude)

* Create DB user :
	* Databases -> Security -> New -> Login
	-- ======================================================================================
	-- Create SQL Login template for Azure SQL Database and Azure SQL Data Warehouse Database
	-- ======================================================================================
	CREATE LOGIN demouser
		WITH PASSWORD = 'abcdefg' 
	GO
	
	* NickSQLDB -> Security -> Users -> New user
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
	GO;

	-- DB : master (for SSMS Connection)
	CREATE USER demouser FROM LOGIN demouser;

* Test : Query Editor -> Login (demouser / xxxx)
select	*
from	dbo.demotable;
-->
Name	Email
------- -----------------
Nick	zXXX@XXXX.com
