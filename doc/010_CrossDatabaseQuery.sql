--===========================================================================================================================
-- Lab 10 : Azure SQL Cross Database Query
--===========================================================================================================================
-- From SQL0318 connecting to SQL0319
----------------------------------------------------------------------------------------------------------------
-- 1. Create Master Key
--> Protects private keys
----------------------------------------------------------------------------------------------------------------
-- drop master key;

create master key;

----------------------------------------------------------------------------------------------------------------
-- 2. Create a Database Scoped Credential
--> Credential maps to a login or contained user used to connect to remote database
----------------------------------------------------------------------------------------------------------------
-- drop database scoped credential CrossDBCred

create database scoped credential CrossDBCred	-- credential name
	with identity = 'serveradmin',				-- login or contained user name
	secret = 'Dkagh0318'						-- login or contained user password
;

----------------------------------------------------------------------------------------------------------------
-- 3. Create an External Data Source
--> Data source to remote Azure SQL Database server and database
----------------------------------------------------------------------------------------------------------------
-- drop external data source SQL0319

create external data source SQL0319
with
(
	type = RDBMS,										-- data source type
	location = 'sqlserver0318.database.windows.net',	-- Azure SQL Database server name
	database_name = 'SQL0319',							-- database name
	credential = CrossDBCred							-- credential used to connect to server / database
)
;

----------------------------------------------------------------------------------------------------------------
-- 4. Create an External Table
--> External table points to table in an external database with the identical structure
----------------------------------------------------------------------------------------------------------------
-- drop external table SQL0319_Lead

create external table SQL0319_Lead
(
	Lead_Name	varchar(max),
	Campaign	varchar(max),
	Product		varchar(max),
	Last_Updated_Date  datetime
)
with
	(
	data_source = SQL0319,	-- data source
	schema_name	= 'dbo',	-- external table schema
	object_name = 'Lead'	-- name of table in external database
	)
;

----------------------------------------------------------------------------------------------------------------
-- 5. Test
----------------------------------------------------------------------------------------------------------------
select	*
from	lead

union all

select	*
from	SQL0319_lead
