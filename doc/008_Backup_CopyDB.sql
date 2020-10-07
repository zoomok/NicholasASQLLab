--===========================================================================================================================
-- Lab 8 : Creating backups and copies of your SQL Azure databases
--===========================================================================================================================
1. Link : https://www.mssqltips.com/sqlservertip/2235/creating-backups-and-copies-of-your-sql-azure-databases/

2. Methods
	- The database copy process is asynchronous, which means the database copy command returns immediately and
	  you don`t need an active connection while copying since the actual copy is done by SQL Azure in the background.

	- You can monitor the progress of the database copy using the provided DMVs/catalog views
	- Please note as long as the database copy operation is in progress the original/source database
	  Needs to be online as the copy operation is dependent on it

3. Copy database

create database SQL0318Copy
as copy of SQL0318
go

4. Monitorig
select	*
from	sys.dm_database_copies
;

select	state_desc,
		*
from	sys.databases
