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
