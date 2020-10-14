--===========================================================================================================================
-- Lab 12 : Microsoft Azure SQL Database Primer
--===========================================================================================================================
1. Link : Professional Azure SQL Server Admin 2nd.pdf


-- SQL0318
2. create a new orders table
CREATE TABLE orders 
  ( 
     orderid  INT IDENTITY(1, 1) PRIMARY KEY, 
     quantity INT, 
     sales    MONEY 
  ); 

--populate Orders table with sample data
; 
WITH t1 
     AS (SELECT 1 AS a 
         UNION ALL 
         SELECT 1), 
     t2 
     AS (SELECT 1 AS a 
         FROM   t1 
                CROSS JOIN t1 AS b), 
     t3 
     AS (SELECT 1 AS a 
         FROM   t2 
                CROSS JOIN t2 AS b), 
     t4 
     AS (SELECT 1 AS a 
         FROM   t3 
                CROSS JOIN t3 AS b), 
     t5 
     AS (SELECT 1 AS a 
         FROM   t4 
                CROSS JOIN t4 AS b), 
     nums 
     AS (SELECT Row_number() 
                  OVER ( 
                    ORDER BY (SELECT NULL)) AS n 
         FROM   t5) 
INSERT INTO orders 
SELECT n, 
       n * 10 
FROM   nums;

GO

SELECT TOP 10 * from orders;

-- Master
-- view the existing firewall rules

select	*
from	sys.firewall_rules
;

-- add firewall
sp_set_firewall_rule

-- delete firewall
sp_delete_firewall_rule

-- SQL0318
select	count(*) as OrderCount
from	orders
;

OrderCount
-----------
65536


3. Differences between Azure SQL Database and SQL Server

	- Backups are automatically scheduled and start within a few minutes of the database provisioning
	- Backups are consistent, transaction-wise, which means that you can do a point-in-time restore
	- There is no additional cost for backup storage until it goes beyond 200% of the provisioned database storage
	- You can also use the long-term retention period feature to store backups
		in the Azure vault for a much lower cost for a longer duration
	- Apart from automatic backups, you can also export the Azure SQL Database bacpac or dacpac file to Azure storage

	- The default recovery model of an Azure SQL database is FULL
	- SQL>
	use master
	go
	
	select	name,
			recovery_model_desc
	from	sys.databases
	;

	name				recovery_model_desc
	------------------- ------------------------
	master				FULL
	Synapse0318			SIMPLE
	SQL0318				FULL
	SQL0319				FULL
	PipelineParameters	FULL

	- Azure SQL Server doesn`t have SQL Server Agent
	- The CDC requires SQL Server Agent, and therefore isn`t available in Azure SQL Database
	- However, you can use the temporal table, SSIS, or Azure Data Factory to implement CDC
	- It`s a PaaS offering and we don`t have access to or control of event logs or error logs
	- You won`t get a performance improvement by having partitions on different disks (spindles)
	- Replication and distribution agents can`t be configured on Azure SQL Database
	- Three-part names (databasename.schemaname.tablename) are only limited to tempdb
	- SQL CLR was initially supported and then the support was removed due to concerns about security issues
	- Log shipping isn`t supported by Azure SQL Database
	- SQL Trace and Profiler can`t be used to trace events on Azure SQL Server
	- System procedures such as sp_addmessage, sp_helpuser, and sp_configure aren`t supported
	- USE Statement isn`t supported in Azure SQL Database


4. Activity: Provisioning an Azure SQL Server and SQL Database Using PowerShell

PS C:\Users\Administrator> Add-AzureRmAccount

Account          : nicholas.azure.adf@gmail.com
SubscriptionName : Free Trial
SubscriptionId   : 3688f460-76ee-4b63-b2eb-fb1edd332e61
TenantId         : ad390af9-a472-46a9-97c0-b1a0d5403e35
Environment      : AzureCloud

-- save the profile details to a file
PS C:\Users\Administrator> Save-AzureRmProfile -Path C:\code\MyAzureProfile.json

--(End)----------------------------------------------------------------------------------------------------------------------
