--===========================================================================================================================
-- Lab 15 : Restoring an Azure SQL Database
--===========================================================================================================================
1. Link : Professional Azure SQL Server Admin 2nd.pdf

2. Scenarios
	- Use point-in-time restore to recover from unexpected data modifications
	- Restore a deleted database using the Azure portal
	- Learn about using geo-restore on a database
	- Restore an Azure SQL database by importing BACPAC

3. Point-In-Time Restore (PITR)
	- A database can only be restored on the same Azure SQL server as the original database with a different name
	
	- Open SQL Server Management Studio (SSMS)
	- Connect to the Azure SQL server hosting the Azure SQL database you wish to perform a PITR on
	- New table
	SQL>
	-- use PipelineParameters
	-- Code is reviewed and is in working condition
	-- Insert a new color
	select	p.*
	into	Colors
	from	(
			SELECT
				 37 AS ColorID
				,'Dark Yellow' AS ColorName
				,1 AS LastEditedBy
				,GETUTCDATE() AS ValidFrom
				,'9999-12-31 23:59:59.9999999' As Validto
			) p
	;

	-- Verify the insert
	select	*
	from	colors
	where	colorid = 37;

	- Log in to the Azure portal with your Azure credentials and go to 'PipelineParameters' database
	- Restore / Point-In-Time
	- Specify the date
	- Database name is renamed to others
	- Restore
	- Check new database and table

4. Long-Term Database Restore (LTDR)
	- The backups are kept in the Azure Recovery Services vault
	- Restore / Long-Term backup retention
	- Select backup
	- Restore
	- Check new database and table

5. Restoring Deleted Databases
	- Log in to the Azure portal with your Azure credentials and go to SQL Server (SQL0318)
	- Settings	-> Deleted database
	- Select deleted database
	- Restore panel
	- Restore point with date
	- Restore
	- Check new database and table

6. Geo-Restore Database
	- Restore a database from a geo-redundant backup to any of the available Azure SQL servers, irrespective of the region
	- An Azure SQL database`s automatic backups are copied to a different region as and when they are taken
	- There is a maximum delay of one hour when copying the database to a different geographical location
	- Therefore, in the case of a disaster, there can be up to an hour of data loss
	- Geo-restore can be used to recover a database if an entire region is unavailable because of a disaster

7. Importing a Database
	- Import a database into an Azure SQL server from a BACPAC or a DACPAC file kept in Azure Storage
	- This can be useful for quickly creating new test environments

	- How to import a database from a BACPAC file kept in Azure Storage
		1. Azure portal
		2. SQL Server
		3. Import database
		4. Select bpac file from storage account
		5. Pricing tier : Basic 100 MB storage
		6. Database name

--(End)----------------------------------------------------------------------------------------------------------------------
