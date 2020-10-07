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
