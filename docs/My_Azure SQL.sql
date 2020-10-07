--#################################################################################################################################################################
--#################################################################################################################################################################
-- 4. SQL Server										###########################################################################################################
--#################################################################################################################################################################
--#################################################################################################################################################################

--===========================================================================================================================
-- Lab 1 : Pricing Tiers
--===========================================================================================================================
* DTU : Used in Non-Production, CPU performance
		| Basic
		| Standard
		| Premium : Sacle-out, Zone-redundant

* vCore	 : Production
		| General Purpose	| Provisioned															| Azure
							| Serveless	(Compute resources are auto-scaled, Billed per second)		| Hybrid
		| Hyperscale		| Secondary Replicas, Very large OLTP database							| Benefit
		| Business Critical	| high transaction rate and lowest latency I/O,							| (55% discount)
							  for Business critical system

** DTU : We can just like the DTU to the horsepower in a car because it directly affects the performance of the database.
		 DTU represents a mixture of the following performance metrics as a single performance unit for Azure SQL Database
		 * CPU
		 * Memory
		 * Data I/O and Log I/O

--===========================================================================================================================
-- Lab 2 : Elastic Pools
--===========================================================================================================================
* Overprovisioned resources
* Underprovisioned resources
* Pool resources
	* 100 DTU : Shared across 4 databases
* Create Elastic pool as Server level not database level
* Database -> Overview :
	1. Elastic Pool Name : NickElasticPool
	2. Configure elastic pool : basic
	3. 50 eDTUs + 4.88 GB
	4. Check : NickSQLDB -> nicksqlserver -> SQL elastic pools
* Add database to Elastic Pools :
	* NickElasticPool -> Configure -> Databases -> Add databases -> NickSQLDB -> Save
	* Check : NickElasticPool -> Configure -> Databases -> Currently in this pool

-- Reset
* Remove Elastic Pools :
	* NickElasticPool -> Configure -> Databases -> Remove from the Pool -> NickSQLDB -> Save
	* NickElasticPool -> Remove
* Delete Database : NickSQLDB
* Delete SQL Server : nicksqlserver

--===========================================================================================================================
-- Lab 3 : Failover Group
--===========================================================================================================================
* Database Server (nicksqlserver)
* Failover Group -> Add group -> group name (failovergroupnick) -> Secondary server (nicksqlserver2) ->
  Database within the group (NickSQLDB) -> create -> take 5 mins
* nicksqlserver -> failovergroupnick -> 
	* Read/write listener endpoint 	: Application can use this URL to keep connection regardless of failover and changed DB Server
									  Always point to primary server even after failover to change DB Server
									  Single end point
									  (failovergroupnick.database.windows.net)
	* Read-only listener endpoint 	: Same as but read-only access
									  (failovergroupnick.secondary.database.windows.net)
* nicksqlserver -> failovergroupnick -> failover -> check DB connection
* Geo-Replication applied this change automatically

* Reset : 
	1. Delete FailoverGroup
	2. Delete NickSQLDB (nicksqlserver2/NickSQLDB)
	3. Delete NickSQLDB (nicksqlserver/NickSQLDB)
	4. Delete nicksqlserver2
	5. Delete nicksqlserver

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

	insert into dbo.DemoTable values ('Nick','zoomok@gmail.com');

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

* Test : Query Editor -> Login (demouser / Dkagh0318)
select	*
from	dbo.demotable;
-->
Name	Email
------- -----------------
Nick	zXXX@XXXX.com

--===========================================================================================================================
-- Lab 5 : Auditing
--===========================================================================================================================
* Security -> Auditing
* Default is Disabled
* Enable :
	Storage :
		Configure 			->
		Storage Account 	->
		Create new 			-> Name (mysqlauditing)
		storage (general purpose v1) ->
		Performance (standard) -> Replication (Locally-redundant storage : LRS)
		Retention days (30) -> OK -> Save

* All resources -> Storage account (mysqlauditing) -> Storage explorer -> BLOB Containers -> sqldbauditlogs ->
	nicksqlserver -> NickSQLDB -> sqlDbAuditing_Audit -> 2020-07-25 -> 08_50_20_253_0.xel
	
* Test :
	create table dbo.DemoUserAudit
	(
	AuditLog varchar(max)
	);

	select	*
	from	dbo.DemoUserAudit
	;

* Check storage explorer -> Download xel file -> Open with SSMS

* Reset : 
	1. Delete storage account (sqlauditing)
	2. Delete NickSQLDB
	3. Delete nicksqlserver
	4. Delete Resource Account

--===========================================================================================================================
-- Lab 6 : Using Covering Indexes to Improve Query Performance
--===========================================================================================================================
-- set showplan_all on
-- set showplan_all off
-----------------------------------------------------------------------------------------------
-- Clustered Index
-----------------------------------------------------------------------------------------------
ALTER TABLE [Sales].[Customer] ADD  CONSTRAINT [PK_Customer_CustomerID] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (
	PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF,
	IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [PRIMARY]
;

-- set showplan_all on
select	c.*
from	sales.Customer c
where	c.CustomerID = 123
;

select c.CustomerID,    c.AccountNumber  from sales.Customer c  where c.CustomerID = 123  ;
  |--Compute Scalar(DEFINE:([c].[AccountNumber]=[AdventureWorks2012].[Sales].[Customer].[AccountNumber] as [c].[AccountNumber]))
       |--Compute Scalar(DEFINE:([c].[AccountNumber]=isnull('AW'+[AdventureWorks2012].[dbo].[ufnLeadingZeros]([AdventureWorks2012].[Sales].[Customer].[CustomerID] as [c].[CustomerID]),'')))
            |--Clustered Index Seek(OBJECT:([AdventureWorks2012].[Sales].[Customer].[PK_Customer_CustomerID] AS [c]), SEEK:([c].[CustomerID]=CONVERT_IMPLICIT(int,[@1],0)) ORDERED FORWARD)

-----------------------------------------------------------------------------------------------
-- Nonclustered Index
-----------------------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX [IX_Customer_PersonID_TerritoryID] ON [Sales].[Customer]
(	[PersonID] ASC,
	[TerritoryID] ASC
)
WITH (
	PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF,
	ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
	)
ON [PRIMARY]
;

select	c.PersonID,
		c.TerritoryID,
		c.StoreID
from	sales.Customer c
where	c.PersonID = 20613
;

select c.PersonID,    c.TerritoryID,    c.StoreID  from sales.Customer c  where c.PersonID = 20613
  |--Nested Loops(Inner Join, OUTER REFERENCES:([c].[CustomerID]))
       |--Index Seek(OBJECT:([AdventureWorks2012].[Sales].[Customer].[IX_Customer_PersonID_TerritoryID] AS [c]), SEEK:([c].[PersonID]=(20613)) ORDERED FORWARD)
       |--Clustered Index Seek(OBJECT:([AdventureWorks2012].[Sales].[Customer].[PK_Customer_CustomerID] AS [c]), SEEK:([c].[CustomerID]=[AdventureWorks2012].[Sales].[Customer].[CustomerID] as [c].[CustomerID]) LOOKUP ORDERED FORWARD)

select	c.PersonID,
		c.TerritoryID,
		c.StoreID
from	sales.Customer c
where	c.PersonID between 1 and 20613
;

select c.PersonID,    c.TerritoryID,    c.StoreID  from sales.Customer c  where c.PersonID between 1 and 20613
  |--Clustered Index Scan(OBJECT:([AdventureWorks2012].[Sales].[Customer].[PK_Customer_CustomerID] AS [c]), WHERE:([AdventureWorks2012].[Sales].[Customer].[PersonID] as [c].[PersonID]>=(1) AND [AdventureWorks2012].[Sales].[Customer].[PersonID] as [c].[PersonID]<=(20613)))

select	c.PersonID,
		c.TerritoryID
from	sales.Customer c
where	c.PersonID between 20000 and 20613
;

select c.PersonID,    c.TerritoryID  from sales.Customer c  where c.PersonID between 20000 and 20613  ;
  |--Index Seek(OBJECT:([AdventureWorks2012].[Sales].[Customer].[IX_Customer_PersonID_TerritoryID] AS [c]), SEEK:([c].[PersonID] >= CONVERT_IMPLICIT(int,[@1],0) AND [c].[PersonID] <= CONVERT_IMPLICIT(int,[@2],0)) ORDERED FORWARD)
 
------------------------------------------------------------------------------------------
-- Including Non-Key columns (Covering index)
------------------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX [IX_Customer_PersonID_TerritoryID_Store_ID] ON [Sales].[Customer]
(	[PersonID] ASC,
	[TerritoryID] ASC
)
INCLUDE([StoreID]) --> Include multiple columns
WITH (
	PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF,
	ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
	)
ON [PRIMARY]
;

select	c.PersonID,
		c.TerritoryID,
		c.StoreID
from	sales.Customer c
where	c.PersonID between 1 and 20613
;

select c.PersonID,    c.TerritoryID,    c.StoreID  from sales.Customer c  where c.PersonID between 1 and 20613
  |--Index Seek(OBJECT:([AdventureWorks2012].[Sales].[Customer].[IX_Customer_PersonID_TerritoryID_Store_ID] AS [c]), SEEK:([c].[PersonID] >= (1) AND [c].[PersonID] <= (20613)) ORDERED FORWARD)
  
--===========================================================================================================================
-- Lab 7 : Azure SQL Database - Table Partitioning
--===========================================================================================================================
-- set showplan_all on
-- set showplan_all off

1. Link : https://www.mssqltips.com/sqlservertip/3494/azure-sql-database--table-partitioning/

2. Scenario : Calculate and store the primes numbers from 1 to 1 million with ten data partitions.
			  Thus, the primes numbers will be hashed in buckets at every one hundred thousand mark

3. Create databaes MATH
USE [master]
GO

-- Delete existing database
IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'MATH')
DROP DATABASE MATH
GO

-- Create new database
CREATE DATABASE MATH
(
MAXSIZE = 20GB,
EDITION = 'STANDARD',
SERVICE_OBJECTIVE = 'S2'
)
GO  

4. Create partition function
create partition function pf_hash_by_value (bigint) as range left
for values (100000, 200000, 300000, 400000, 500000, 600000, 700000, 800000, 900000)
go

select	*
from	sys.partition_functions
;

5. Create partition scheme
create partition scheme ps_hash_by_value
as partition pf_hash_by_value
all to ([Primary]);
;

select	*
from	sys.partition_schemes
;

6. Partition system function
select	My_Value,
		$partition.pf_hash_by_value(My_Value) as hash_indx
from	(
		values
		(1),
		(100001),
		(200001),
		(300001),
		(400001),
		(500001),
		(600001),
		(700001),
		(800001),
		(900001)
		) as TEST (My_Value)
;

7. Create the partitioned table
if exists
	(
	select	*
	from	sys.objects
	where	object_id = object_id(N'[dbo].[Tbl_Primes]') and type in (N'U')
	)
drop table [dbo].[Tbl_Primes]

go

create table [dbo].[Tbl_Primes]
(
My_Value	bigint not null,
My_Division	bigint not null,
My_Time		datetime not null constraint DF_Tbl_Primes default getdate()
constraint PK_Tbl_Primes primary key clustered (My_Value asc)
) on ps_hash_by_value (My_Value)
;

8. create a procedure that takes a number as a parameter and determines if it is prime

create procedure sp_is_prime
	@var_num2 bigint
as
begin
	set nocount on

	declare @var_cnt2 bigint;
	declare @var_max2 bigint;

	if (@var_num2 = 1)
		return 0;

	if (@var_num2 = 2)
		return 1;

	select	@var_cnt2 = 2;
	select	@var_max2 = sqrt(@var_num2) + 1;
	
	while (@var_cnt2 <= @var_max2)
	begin
		if (@var_num2 % @var_cnt2) = 0
			return 0;

		select	@var_cnt2 = @var_cnt2 + 1;
	end

	return 1;
end;

9. create a procedure that takes a starting and ending value as input and calculates
	And stores primes numbers between those two values as output

if exists
	(
	select	*
	from	sys.objects
	where	object_id = object_id(N'[dbo].[sp_store_primes]')
	and		type in (N'P', N'PC')
	)
drop procedure [dbo].[sp_store_primes]

go

create procedure sp_store_primes
	@var_alpha bigint,
	@var_omega bigint
as
begin
	set nocount on

	declare @var_cnt1 bigint;
	declare @var_ret1 int;

	select	@var_ret1 = 0;
	select	@var_cnt1 = @var_alpha;

	while (@var_cnt1 <= @var_omega)
	begin
		exec @var_ret1 = dbo.sp_is_prime @var_cnt1;

		if (@var_ret1 = 1)
		insert into tbl_primes (my_value, my_division)
		values (@var_cnt1, sqrt(@var_cnt1));

		select	@var_cnt1 = @var_cnt1 + 1
	end
end
;

10. Execute procedure

exec sp_store_primes 1, 100000
exec sp_store_primes 100001, 200000
exec sp_store_primes 200001, 300000
exec sp_store_primes 300001, 400000
exec sp_store_primes 400001, 500000
exec sp_store_primes 500001, 600000
exec sp_store_primes 600001, 700000
exec sp_store_primes 700001, 800000
exec sp_store_primes 800001, 900000
exec sp_store_primes 900001, 100000

11. Validate data placement
select	partition_number,
		row_count
from	sys.dm_db_partition_stats
where	object_id = object_id('Tbl_Primes')
;
partition_number	row_count
------------------- ----------
1						9592
2						8392
3						8013
4						7863
5						7678
6						7560
7						7445
8						7408
9						7323
10						0

select	$partition.pf_hash_by_value(My_Value) as partition_Number,
		count(*) as Row_Count
from	math.dbo.tbl_primes
group by $partition.pf_hash_by_value(My_Value)
;

partition_Number	Row_Count
------------------ -----------
1						9592
2						8392
3						8013
4						7863
5						7678
6						7560
7						7445
8						7408
9						7323

-- Execution plan
set showplan_all on

select	*
from	tbl_primes
where	my_value = 61027
;

StmtText
select *  from tbl_primes  where my_value = 61027
  |--Clustered Index Seek(OBJECT:([MATH].[dbo].[Tbl_Primes].[PK_Tbl_Primes]), SEEK:([PtnId1000]=RangePartitionNew(CONVERT_IMPLICIT(bigint,[@1],0),(0),(100000),(200000),(300000),(400000),(500000),(600000),(700000),(800000),(900000)) AND [MATH].[dbo].[Tbl_Primes].[My_Value]=CONVERT_IMPLICIT(bigint,[@1],0)) ORDERED FORWARD)

set showplan_all off

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
