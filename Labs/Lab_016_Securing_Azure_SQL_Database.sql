--===========================================================================================================================
-- Lab 16 : Securing an Azure SQL Database
--===========================================================================================================================
1. Link : Professional Azure SQL Server Admin 2nd.pdf (Page 191)

2. Objectives
	- Configure firewall settings for Azure SQL Server and SQL Database
	- Implement audit and threat detection
	- Implement encryption, dynamic data masking, and row-level security
	- Implement AD authentication for an Azure SQL database
	
3. Access Control
	- Azure SQL Database uses firewall rules to limit access to authorized IPs and block access to unauthorized IPs
	- This is the first level of access control provided by Azure SQL Database
	- Firewall rules can be created at the server level and the database level

4. Firewall rules
	- The computer`s IP address is validated against the database-level firewall rules
	- To allow Azure applications to connect to an Azure SQL database,
		you need to add the IP 0.0.0.0 as the start and end IP address to the server-level firewall rules
	- Server level		: Rules are stored in the master database
	- Database level 	: Rules are stored within individual Azure SQL databases

5. Server-Level firewall
	- Azure portal
	- Azure SQL server
	- Set server firewall
	- Add client IP address
	- You can provide access to all systems within a specified IP range by specifying the start and end IP accordingly
	- To make an Azure SQL database accessible to Azure applications,
		toggle Allow access to Azure services to ON and click Save to save the configuration

	- Managing Server-Level Firewall Rules Using Transact-SQL
		- Search
		SQL>
		Select	*
		from	sys.firewall_rules
		;

		- Add IP
		SQL>
		Execute sp_set_firewall_rule
			@name = N'Work',
			@start_ip_address = '115.118.1.0',
			@end_ip_address = '115.118.16.255'
		;
		
		- Update
		SQL>
		Execute sp_set_firewall_rule
			@name = N'Work',
			@start_ip_address = '115.118.10.0',
			@end_ip_address = '115.118.16.255'
		;
		
		- Delete
		SQL>
		Execute sp_delete_firewall_rule @name= N'Work'
		;
		
	- Managing Database-level Firewall Rules Using Transact-SQL
		- Search
		SQL>
		select	*
		from	sys.database_firewall_rules
		;
		
		- Add IP
		SQL>
		Exec sp_set_database_firewall_rule
			@name = N'MasterDB',
			@start_ip_address = '115.118.10.0',
			@end_ip_address = '115.118.16.255'
		;
			
		- Update
		SQL>
		Exec sp_set_database_firewall_rule
			@name = N'MasterDB',
			@start_ip_address = '115.118.1.0',
			@end_ip_address = '115.118.16.255'
		;
		
		- Delete
		SQL>
		Exec sp_delete_database_firewall_rule
			@name = N'MasterDB'
		;

		- Flush Cache
		DBCC FLUSHAUTHCACHE
		;
		
6. Authentication
	- SQL authentication : username and password

	- Azure Active Directory authentication
		- Active Directory – Password 	: It works with Azure AD managed domains and federated domains
			- Azure portal		->
			- Active directory 	->
			- Users				->
			- New user			->
			- Insert user information
			- Create			-> jake@nicholasazureasagmail.onmicrosoft.com / Jungpalxx
			
			- sqlserver0318
			- Active directory admin
			- Set admin
			- select user
			- Save
			
			- SSMS
			- Active Directory – Password
			- jake@nicholasazureasagmail.onmicrosoft.com / Dkagh03xx
			

		- Active Directory – Integrated	: The on-premises AD should be integrated into Azure AD
										  This can be done using the free tool, Azure AD Connect
										  Similar to on-premises Windows authentication

		- Active Directory – Universal with MFA support : MFA stands for multi-factor authentication

7. Authorization
	- Object-level permission a user has within a SQL database
	- The admin accounts, SQL authentication accounts, and Azure AD accounts have db_owner
		access to all databases and are allowed to do anything within a database

	- Server-Level Administrative Roles
		- Database Creators : Members of database creators (dbmanager) are allowed to create new SQL databases
			- Create a new user with the database creator role
			- SSMS with server admin (or AD admin)
			- CREATE LOGIN John WITH PASSWORD = 'Dkaghxxxx'; (master db)
			- CREATE USER John FROM LOGIN John;
			- ALTER ROLE dbmanager ADD MEMBER John;
			- (new query window)
			- CREATE DATABASE JohnsDB
		
		- Non-Administrative Users
			- Creating Contained Database Users for Azure AD Authentication
				- Create AD User (Alice) : alice@nicholasazureasagmail.onmicrosoft.com
				- SSMS (serveradxxx login)
				- Change database SQLxxxx
				- CREATE USER [alice@xxxsazureasagmail.onmicrosoft.com] FROM EXTERNAL PROVIDER
				- ALTER ROLE [db_datareader] ADD Member [alice@xxxazureasagmail.onmicrosoft.com]
				- (Active Directory – Password) Login with alice@xxxazureasagmail.onmicrosoft.com

8. Groups and Roles
	- You can group users with similar sets of permissions in an Azure AD group or an SQL database role
	- You can then assign the permissions to the group and add users to it
	- If a new user with the same permissions arrives, add the user to the group or role

9. Row-level Security
	- Controls what data in a table the user has access to
	- Filter predicates : Filter predicates apply to SELECT, UPDATE, and DELETE, and silently filter out unqualified rows
	- Block predicates	: Block predicates apply to AFTER INSERT, AFTER UPDATE, BEFORE UPDATE, and BEFORE DELETE,
							and block unqualified rows being written to the table

10. Dynamic Data Masking
	- Restricts the exposure of sensitive data by masking it to non-privileged users
	- 4 types	: Default / Email / Random / Custom String

11. Advanced Data Security	--> Azure Defender
	- It`s a paid service, is priced independently of Azure SQL Database
	- Provides vulnerability assessment, threat detection, and data discovery and classification
	- Vulnerability assessment
	- Advanced threat detection

	- Azure portal	->
	- Databaase		->
	- Enable Azure Defender for SQL on the server	-> ON
	- It automatically does a vulnerability scan, data discovery and classification, and threat detection
	- Vulnerability Assessment and Advanced Threat Protection reports are available

	- Vulnerability Assessment
		- Notice that there are 44 passed checks and 6 failed checks – 2 high-risk and 2 medium-risk and 2 Low
		- Approve as baseline
		- Scan again

	- SQL Data Discovery and Classification
		- Azure portal	->
		- Database		->
		- Data discovery & classification
		- We have found 15 columns with classification recommendations
		- Configure
		- Manage information types
		- Classification	-> Select tables and columns
		- Accept selected recommendations	-> Save

12.	Auditing
	- Auditing tracks and records database events to an audit log
	- Define what database actions are to be audited
	- Find unusual activities or trends by using preconfigured reports and dashboards to understand and analyze the audit log
	- It`s recommended to audit the server instead of auditing individual databases

	- Azure portal	->
	- Database		-> 
	- Auditing		-> On : Storage (check) | Log Analytics | Event Hub
	- Storage		-> mystoragexxxx (data lake does not support this)
	- Save
	- Run SQL		->
	- View audit	->
	- Click list and see SQL
	- Run in Query Editor
		SELECT TOP 100 event_time, server_instance_name, database_name, server_principal_name, client_ip, statement, succeeded, action_id, class_type, additional_information
		FROM sys.fn_get_audit_file('https://mystoragexxxx.blob.core.windows.net/sqldbauditlogs/sqlserverxxxx/SQLxxxx/SqlDbAuditing_Audit_NoRetention/2020-11-02/03_38_45_964_0.xel', default, default)
		WHERE (event_time <= '2020-11-02T03:42:31.900Z')
		/* additional WHERE clause conditions/filters can be added here */
		ORDER BY event_time DESC

13. Activity: Implementing Row-level Security
--====================================================================================================================
-- 1. Scenario
--====================================================================================================================
Let`s say that we have two customers Mike and John and two database users each for our two customers. (Mike and John)
You have to implement Row Level Security so each customer should only be able to view and edit their records.
The user CustomerAdmin is allowed to view and edit all customer records.

--====================================================================================================================
-- 2. Drop objects
--====================================================================================================================
-- drop security policy CustomerFilter;
-- drop function Security.fn_securitypredicate;
-- drop schema Security;
-- drop table Customers;

--====================================================================================================================
-- 3. Create Table
--====================================================================================================================
-- User : serveradxxx
create table Customers
(
	CustomerID			int identity,
	Name				sysname,
	CreditCardNumber	varchar(100),
	Phone				varchar(100),
	Email				varchar(100)
)
;

-- truncate table Customers
Insert into Customers
values
	('Mike',0987654312345678,9876543210,'mike@outlook.com'),
	('Mike',0987654356784567,9876549870,'mike1@outlook.com'),
	('Mike',0984567431234567,9876567210,'mike2@outlook.com'),
	('John',0987654312345678,9876246210,'john@outlook.com'),
	('John',0987654123784567,9876656870,'john2@outlook.com'),
	('John',09856787431234567,9876467210,'john3@outlook.com'),
	('CustomerAdmin',0987654312235578,9873456210,'john@outlook.com'),
	('CustomerAdmin',0984564123784567,9872436870,'mike2@outlook.com'),
	('CustomerAdmin',0945677874312367,9872427210,'chris3@outlook.com')
;

select	*
from	Customers
;

--====================================================================================================================
-- 4. Creating Login
--====================================================================================================================
-- master

-- drop login Mike;
-- drop login John;

create login Mike with password = 'Abcdef2020';
create login John with password = 'Abcdef2020';

--====================================================================================================================
-- 5. Creating Users
--====================================================================================================================
-- sqlxxxx

-- drop user Mike;
-- drop user John;
-- drop user CustomerAdmin;

create user Mike from login Mike;
create user John from login John;
create user CustomerAdmin without login;

exec sp_addrolemember 'db_datawriter', 'Mike';
exec sp_addrolemember 'db_datawriter', 'John';
exec sp_addrolemember 'db_datawriter', 'CustomerAdmin';

--> When login to SSMS using those Users,
--> Options
--> Connection Properties tab
--> Select database to connect to

--====================================================================================================================
-- 6. Grant SELECT permission to Table
--====================================================================================================================
grant select on Customers to Mike;
grant select on Customers to John;
grant select on Customers to CustomerAdmin;

--====================================================================================================================
-- 7. Create a security predicate to filter out the rows based on the logged-in username
--====================================================================================================================
create schema Security;

create function Security.fn_securitypredicate
(
	@Customer as sysname
)
returns table with schemabinding as
return
select	1 as predicateresult
where	@Customer = user_name() or user_name() = 'CustomerAdmin'
;

--====================================================================================================================
-- 8. Create a security policy
--====================================================================================================================
create security policy CustomerFilter
add filter predicate security.fn_securitypredicate(Name) on dbo.Customers,
add block predicate security.fn_securitypredicate(Name) on dbo.Customers
after insert
with (state = on)
;

--====================================================================================================================
-- 9. Test - Execute on new Query Editor
--====================================================================================================================
-----------------------------------------
-- Execute on new Query Editor (Qry1)
-----------------------------------------
execute as user = 'Mike'
go

select	user_name()
go

select	*
from	Customers
;
--> Can see only 'Mike' rows

update	Customers
set		email = 'zoomok@outlooke.com'
where	CustomerID = 11
;
--> No error but value isn't updated

Insert into Customers
values
	('John',0987654312345678,9876543210,'john@outlook.com')
--> Error
--> The attempted operation failed because the target object 'SQLxxxx.dbo.Customers' has a block predicate that conflicts with this operation.

-----------------------------------------
-- Execute on new Query Editor (Qry2)
-----------------------------------------
execute as user = 'John'
go

select	user_name()
go

select	*
from	Customers
;
--> Can see only 'John' rows

-----------------------------------------
-- Execute on new Query Editor (Qry3)
-----------------------------------------
execute as user = 'CustomerAdmin'
go

select	user_name()
go

select	*
from	Customers
;
--> See all rows

--====================================================================================================================
-- 10. Disable Security policy
--====================================================================================================================
-- serveradxxx

alter security policy CustomerFilter with (state = off);
-- All users can see all rows
	

14. Activity: Implementing Dynamic Data Masking
-- 1. Create user
create user TestUser without login;
grant select on Customers to TestUser;

-- 2. Apply mask functions
alter table Customers alter column phone varchar(100) masked with (function = 'default()');
alter table Customers alter column Email varchar(100) masked with (function = 'email()');
alter table Customers alter column CreditCardNumber varchar(100) masked with (function = 'partial(0,"XXX-XX-", 4)');

select	*
from	customers;

-- 3. Execute on new Query Editor (Qry1)
execute as user = 'TestUser'
go
select	*
from	Customers;

CustomerID	Name	CreditCardNumber	Phone	Email
---------------------------------------------------------------
1			Mike	XXX-XX-5678			xxxx	mXXX@XXXX.com
2			Mike	XXX-XX-4567			xxxx	mXXX@XXXX.com
3			Mike	XXX-XX-4567			xxxx	mXXX@XXXX.com
4			John	XXX-XX-5678			xxxx	jXXX@XXXX.com
5			John	XXX-XX-4567			xxxx	jXXX@XXXX.com

-- 4. List of masked columns
select	mc.name,
		t.name as table_name,
		mc.masking_function
from	sys.masked_columns mc,
		sys.tables t
where	mc.object_id = t.object_id
and		mc.is_masked = 1
and		t.name = 'Customers'
;

-- 5. Grant masked data to user
grant unmask to TestUser;
revoke unmask to TestUser;


15. Activity: Implementing Advanced Data Security to Detect SQL Injection
--====================================================================================================================
-- 1. create table and insert
--====================================================================================================================
create table users
(
	userid		int,
	username	varchar(100),
	usersecret	varchar(100)
)
;
insert into users values
(1,'Ahmad','MyPassword'),
(2,'John','Doe')
;

select	*
from	users
;

--====================================================================================================================
-- 2. Change config file and run window form
--====================================================================================================================
-- SQLInjection.exe.config
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
    <startup> 
        <supportedRuntime version="v4.0" sku=".NETFramework,Version=v4.5.2" />
    </startup>
  <appSettings>
    <add key="server" value="sqlserverxxxx"/>
    <add key="user" value="serverxxx"/>
    <add key="database" value="SQLxxxx"/>
    <add key="password" value="xxxxxx"/>
  </appSettings>
</configuration>

-- Execute SQLInjection.exe
1. John/Doe	--> Search
2. Username : ' OR 1=1 union all select 1,name,name from sys.objects --'	-> Search
3. Username : ' OR 1=1 insert into users values(100,'hacked','hacked') --'	-> Search (Inserted)
4. The hacked user was successfully inserted into the users table


16. Brute force attack
-- BruteForceAttack.exe.config
-- Update server info at config file
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
    <startup> 
        <supportedRuntime version="v4.0" sku=".NETFramework,Version=v4.5.2" />
    </startup>
  <appSettings>
    <add key="Server" value="sqlserverxxxx"/>
    <add key="database" value="SQLxxxx"/>
  </appSettings>
</configuration>

-- Run BruteForceAttack.exe
The connection attempt is made using a different username and password

17. Open Azure SQL Defender
