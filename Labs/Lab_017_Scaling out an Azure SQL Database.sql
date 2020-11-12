--===========================================================================================================================
-- Lab 17 : Scaling out an Azure SQL Database
--===========================================================================================================================
1. Link : Professional Azure SQL Server Admin 2nd.pdf (Page 265)

2. Objectives
	- Perform vertical and horizontal scaling
	- Run cross-database elastic queries
	- Create and maintain Azure SQL Database shards

3. Vertical Scaling
	- One of the most common vertical scaling use cases is to automatically scale up or scale down a service tier
		based on the DTU (Database Throughput Unit) usage
	- Another use case is to schedule scaling up and scaling down based on peak and off-peak business hours

4. Using T-SQL to Change the Service Tier
--==============================================================
-- 1. Current service tier
--==============================================================
-- SQLxxxx
select	*
from	sys.database_service_objectives
;

--==============================================================
-- 2. monitor the progress of the ALTER DATABASE operation
--==============================================================
-- master (query 1 window)
select	*
from	sys.dm_operation_status
where	resource_type_desc = 'database'
and		major_resource_id = 'SQLxxxx'
;

-- Run below 3 Queries (Query 1 ~ Query 3 : query 2 window)
-- Query 1 : Change the databaseEdition or Service tier to Standard S0
alter database SQLxxxx modify (edition = 'Standard', service_objective = 'S0')
Go

-- Query 2 : Get the current service objective
select	*
from	sys.database_service_objectives
Go

-- Query 3 : Wait for the changes to be applied
waitfor delay '00:01:00'
Go

-- Query 4 : Get the current service objective
select	*
from	sys.database_service_objectives
;

-- Query 5 : Automate the process
-- Execute in Master database
print 'database update in progress...'

declare
	@databaseName		sysname = 'SQLxxxx',
	@databaseEdition	varchar(100) = 'Basic',
	@performanceTier	varchar(10) = 'Basic'

declare @dsql varchar(max) =
'ALTER DATABASE [' + @databaseName + '] MODIFY (Edition = ''' + @databaseEdition + ''',
Service_objective = ''' + @performanceTier + ''')';
set @dsql = @dsql + '
while(
	exists (
			select 	top 1 *
			from 	sys.dm_operation_status
			where 	resource_type_desc = ''database''
			and 	major_resource_id = ''' + @databaseName + '''
			and 	state = 1
			order by start_time desc
			)
	)
begin
waitfor delay ''00:00:05'' end'
exec(@dsql)


5. Vertical Partitioning
	- The data is partitioned in such a way that different sets of tables reside in different individual databases
	- Finance, HR, CRM and inventory, stored in one independent database
	- Vertical partitioning requires cross-database queries in order to generate reports,
		which require data from different tables in different databases

6. Horizontal Scaling
	- Horizontal scaling, or sharding, refers to partitioning the data from one single big table in a database
		across multiple independent databases based on a sharding or partitioning key

7. Sharding
	- Sharding is supported natively in Azure SQL Database
	- Shard					: An individual database that stores a subset of rows of a sharded table
	- Shard set				: A group of shards
	- Sharding key			: A sharding key is the column name based on which the data is partitioned between the shards
	- Shard map manager		: A special database that stores global mapping information about all available shards in a shard set
	- Shard maps			: define the data distribution between different shards based on the sharding key
		- List shard map
		- Range shard map
	- Global shard map (GSM) : Stored and managed by special tables and stored procedures created automatically
							   under the _ShardManagement schema in the shard map manager database
	- Local shard map (LSM)	 : these are the shard maps that track the local shard data within individual shards
	- Reference tables		 : 
	- Application cache		: Applications use the cached mappings to route requests to the correct shards,
								instead of accessing the shard map manager for every request

8. Activity: Creating Alerts
	- Autoscaling to change the service tier to Standard S0 when the DTU is greater than 70%
	- Azure Automation is an Azure service that allows you to automate Azure management tasks through runbooks
	- Azure portal	->

	8.1 Create an Automation account
	- All services	->
	- Automation account -> job0318
	- Azure Run As account : Yes
	-> Create

	8.2	Create a Run books
	- Runbooks			->
	- Import Run book	->
		- c:\Code\Professional-Azure-SQL-Database-Administration-Second-Edition-master\Lesson06\VerticalScaling\Set-AzureSqlDatabaseEdition.ps1
		- Powershell workflow
		- View or Edit PowerShell Workflow Runbook
		- Publish Runbooks
	
	8.3	Create a Credentials : Shared assets and can be used in multiple runbooks
		- New Credential	->
		- SQL03xxCredt		->
		- User name : serveradmin
		- Password  : xxxxxxx
		- Create

	8.4	Create a webhook
		- Runbooks page	->
		- Select the Set-AzureSqldatabaseEdition runbook -> * You must publish the runbook before you can add webhook
		- Webhooks		-> whDBEdition
		- Enabled		-> Yes
		- Expires		-> 1 year (default)
		- Copy URL		-> https://09d254fa-b307-41d9-9710-a804e0504a13.webhook.eus.azure-automation.net/webhooks?token=3sJog3cCBU8iIojyz2C%2b9j0RPKWvlRvdq%2xxxxx
		
		- Create Parameters and run settings
			- For Powershell runbook parameters
			- SERVERNAME 	: sqlserverxxxx
			- DATABASE NAME	: SQLxxxx
			- EDITION		: Standard
			- PERFLEVEL		: S0
			- CREDENTIAL	: SQLxxxxCredt
			- OK
		
		- Create
		- Have created and configured a PowerShell runbook, which runs a PowerShell command when triggered by a webhook
	
	8.5	Create an Azure SQL Database Alert
		- Triggered when the DTU percentage is greater than 70%
		
		- Firstly, subscription should be registered to Microsoft.insights resource provider
		- Azure portal	->
		- Resource		->
		- Resource provider ->
		- Microsoft.Insights -> Register
		
		- Azure portal	->
		- SQL Database	->
		- Alerts		->
		- New alert rule ->
		- Resource		-> sqlserverxxxx/SQLxxxx
		- Condition		-> DTU percentage
			- Alert logic :
			- Static
			- Greater than
			- Maximum
			- 70
		- Action		->
		- Create action group ->
			- Action group name	: High DTU Action Group
			- Actions
				- Action type 	: Webhook
				- Name			: CallWebhook
				- URI			: https://09d254fa-b307-41d9-9710-a804e0504a13.webhook.eus.azure-automation.net/webhooks?token=3sJog3cCBU8iIojyz2C%2b9j0RPKWvlRvdq%2xxxxx
				- Power shell	: .\Start-Workload.ps1 -sqlserver sqlserverxxxx -database SQLxxxx -sqluser serveradmin -sqlpassword Dkaghxxxx -ostresspath
								  "C:\Program Files\Microsoft Corporation\RMLUtils\ostress.exe" -workloadsql .\workload.sql  --> Error for ostress.exe cannot find (failed to install this)

9. Activity: Creating Shards
	- Scenario : Shard Sales.Customer and Sales.Order table into two shards, "SQLxxxx_Shard_1_100" (customerid from 1-100) and "SQLxxxx_Shard_200"(with values from 100-200)
				 The Application.Countries table will be the reference, or the common table present in all shards
	
	9.0 Save Azure subscription
		- Add-AzureRmAccount
		- Save-AzureRmProfile -Path C:\code\MyAzureProfile.json

	9.1 Download the Elastic Database Tool scripts
		- Open Powershell-ISE
		- Save file to 'Sharding_Nick.ps1'
		- 
	9.2 Provision the toystore_SMM shard map manager database
	9.3 Rename toystore database as toystore_shard_1_100
	9.4 Provision the toystore_shard_200 Azure SQL database
	9.5 Promote toystore_SMM to the shard map manager. This will create the shard management tables and procedures in the toystore_SMM database
	9.6 Create the range shard map in the shard map manager database
	9.7 Add shards to the shard map
	9.8 Add the sharded table and reference table schema to the shard map manager database
	9.9 Verify sharding by reviewing the shard map manager tables

	9.10 Execute ps	--> Error
.\Sharding_Nick.ps1 -ResourceGroup RG_xxx -SqlServer sqlxxxx
-UserName xxxx -Password xxxx
-ShardMapManagerdatabase xxxx_SMM -databaseToShard sqlxxxx
-AzureProfileFilePath c:\Code\Professional-Azure-SQL-Database-Administration-Second-Edition-master\MyAzureProfile.json

10. Sharding
	- Link : https://www.youtube.com/watch?v=ISs__Ub9oh8
	- Practices

--(End)----------------------------------------------------------------------------------------------------------------------
