--===========================================================================================================================
-- Lab 14 : Backing Up an Azure SQL Database
--===========================================================================================================================
1. Link : Professional Azure SQL Server Admin 2nd.pdf

2. Automatic backups
	- Full 				: The first automatic full backup is performed immediately after the database is provisioned
						  Scheduled for once a week
	- Differential 		: Scheduled to occur every hour
	- Transaction Log 	: Transaction log backups are scheduled for every 5-10 minutes

	---------------------------------------------------------------------------------------------------------------
	Azure SQL database is provisioned -> First full backup	 -> Differential Backups  -> Transaction Log backups
										 (Weekly thereafter)	Every 1 hour		     Every 5 - 10 minutes
	---------------------------------------------------------------------------------------------------------------

3. Configuring Long-Term Backup Retention for Azure SQL Database
	- Azure portal	->
	- SQL Server	-> SQL0318
	- Manage backup	->
	- Configure policies	-> Weekly/Monthly/Yearly

4. Manual backups
	- Conventional database backup statements don`t work in Azure SQL Database
	- Exporting the database as a DACPAC (data and schema) or
	- BACPAC (schema) and bcp out the data into csv files

	- Export BACPAC to your Azure storage account using the Azure portal
	- Export BACPAC to your Azure storage account using PowerShell
	- Export BACPAC using SQL Server Management Studio
	- Export BACPAC or DACPAC to an on-premises system using sqlpackage.exe

5.	Backing up an Azure SQL Database Using SQL Server Management Studio (SSMS)
	- Connect to database SQL0318
	- Task -> Export Data-tier application
	- Save to local disk : S:\My_SQLServer\sql0318_19-OCT-2020.bacpac
	- Finish
	
	- DACPAC stands for Data-Tier Application Package and contains the database schema in .xml format
	- BACPAC is a DACPAC with data.
	
	- Meta info
		- model.xml: This contains the database objects in .xml format
		- Origin.xml: This contains the count of each database object, database size,
			export start date, and other statistics about the BACPAC and the database
		- DacMetadata.xml: This contains the DAC version and the database name
		- Data: This folder contains a subfolder for each of the tables in the database
			Thesesubfolders contain the table data in BCP format:

--(End)----------------------------------------------------------------------------------------------------------------------
