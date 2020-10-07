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
