--===========================================================================================================================
-- Lab 13 : Migrating a SQL Server Database to an Azure SQL Database
--===========================================================================================================================
1. Link : Professional Azure SQL Server Admin 2nd.pdf

2. Introduction
	- (1) Finding the migration benefits
	- (2) Finding the blockers
	- (3) Selecting a service model
	- (4) Selecting a service tier
	- (5) Selecting the main region and disaster recovery region
	- (6) Selecting a migration tool

3. Azure SQL Database Service Tiers
	- DTU Pricing Models
		- Database Transaction Units (DTUs)
		- Calculated by Microsoft by running an Online Transaction Processing (OLTP) benchmark

		- The DTU is the measure of Azure SQL Database performance
			- Basic tier 		: The lowest tier available and is applicable to small, infrequently used applications
			- Standard  tier 	: The most commonly used service tier and is best for web applications
									or workgroups with low to medium I/O performance requirements
								  (Levels : S0, S1, S2, S3)
			- Premium tier		: For mission-critical, high transaction-volume applications
								  (Levels : P1, P2, P4, P6, P11, P15)
			- Premium RS tier	: For low-availability, I/O-intensive workloads such as analytical workloads
								  (Levels : PRS1, PRS2, PRS3, PRS4)

		- vCore (virtual core) pricing tiers allow you to independently define and control the compute and storage
			based on the workload of your on-premises SQL Server infrastructure
			- Compute = vCore + Memory

		- Hyperscale Service Tier
			- Takes out the storage engine from the database server and splits it into
				independent scale-out sets of components, page servers, and a log service
			- Compute nodes	:	Primary + Secondary (multi)
								Each compute node has a local data cache, a Resilient Buffer Pool Extension (RBPEX)
			- Page server node	: where the database data files are
			- Log service node	: The log service node is the new transaction log and is again separated from the compute nodes
			- Benefits :
				- Nearly instantaneous backups
				- The snapshot process is fast and takes less than 10 minutes to back up a 50 TB database
				- Higher log throughput and faster transaction commits regardless of data volumes

	- Changing a Service Tier
		- You can scale up or scale down an Azure SQL Database at any point in time
		- Service tier change is performed by creating a replica of the original database at the new service tier
			performance level
		- Once the replica is ready, the connections are switched over to the replica
		- The average switchover time is four seconds
	
	- DTU to vCore
		- 100 Standard tier DTU = 1 vCore General Purpose tier
		- 125 Premium tier DTU = 1 vCore Business Critical tier
		
	- Azure SQL Database DTU Calculator
		- (1) Modify file SqlDtuPerfmon.exe.config
		  (2) Run SqlDtuPerfmon.exe in cmd
		  (3) Upload file to https://dtucalculator.azurewebsites.net/ and Enter Cores
		  (4) Calculate and can see recommendation
	
	- Compatibility test
		- Data Migration Assistant (DMA) : easy-to-use graphical user interface
		- SQL Server Data Tools (SSDT) for Visual Studio
		- SQL Server Management Studio (SSMS) : bacpac file
		- SQLPackage.exe : command-line
		- SQL Azure Migration Wizard
		- SQL Azure Migration Wizard : Community supported tool (download at https://github.com/adragoset/SQLAzureMigration)
		- Azure Database Migration Services (DMS)
			- Fully managed Azure service that enables seamless migrations from multiple data sources to Azure databases
			- Migrate on-premises SQL Server to Azure SQL Database or SQL managed instance
			- Supports both online and offline migrations
			- Migrate Azure SQL Database to SQL database managed instances
			- Migrate an AWS SQL Server RDS instance to Azure SQL Database or SQL managed instance
			- Migrate MySQL to Azure Database for MySQL
			- Migrate PostgreSQL to Azure Database for PostgreSQL
			- Migrate MongoDB to Azure Cosmos DB Mongo API

	- Exercise 1 : Migrating a SQL Server Database to Azure SQL Database Using Azure DMS
		- To migrate an on-premises database, site-to-site connectivity is required via VPN or Azure Express route
		- Skip for now
	
	- Exercise 2 : Migrating an On-Premises SQL Server Database to Azure SQL Database
		- Select "SQL Server Management Studio (SSMS) : bacpac file"
		- SSMS
			- Task	->
			- Deploy Database to Microsoft Azure SQL Database				->
			- Target server name 	: sqlserver0318.database.windows.net 	->
			- Database				: AdventureWorks2012 (New database name)
			- Run
			- Fix compatibility issues
			- Re-run
			- Check sqlserver0318/AdventureWorks2012 in Azure SQL database
			
	- Exercise 3 : Migrating an On-Premises SQL Server Database to Azure SQL Database
		- Select "Microsoft Data Migration Assistant (DMA)"
		- Install Microsoft Data Migration Assistant  tool to on-premises machine (laptop)
		
		- Click "+"
		- (1) Assessment 	: Assessing compatibility and rules
		- Project		: Asess-AdventureWorksDW2012
		- Connect to a server
			- Server name				: DESKTOP-E7F3VBA\SQLEXPRESS
			- Encrypt connection 		: Check
			- Trust server certificate 	: Check
			- Add sources				: AdventureWorks2012
			- Click Start Assessment to find compatibility issues
			- Under Options, select the Compatibility issues radio button
			
		- Click "+"
		- (2) Migration		: Mig-AdventureWorksDW2012
		- Source		: SQL Server
		- Target		: Azure SQL Database
		- Migration scope : Schema and Data
		- Create
		- Select source
			- Server name	: DESKTOP-E7F3VBA\SQLEXPRESS
			- Authentication : Windows
			- Connect		: AdventureWorks2012
		- Select target
			- Server name	: sqlserver0318.database.windows.net
			- Authentication : SQL Server Authentication
			- Username / Password : serveradmin / xxxxx
		- Select objects
			- Select objects to migrate
			- Generate SQL Scripts
		- Scripts & deploy schema
			- Scripts generated
			- Save for keeping script
			- Deploy schema
		- Select tables
		- Migrate data

	- Exercise 4 : Performing Transactional Replication
		- SSMS
		- SQL Server Express version has no "Local Publication" folder
		- Skip this part

--(End)----------------------------------------------------------------------------------------------------------------------
