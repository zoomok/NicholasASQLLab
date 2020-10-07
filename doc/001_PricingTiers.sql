--===========================================================================================================================
-- Lab 1 : Pricing Tiers
--===========================================================================================================================
* DTU : Used in Non-Production, CPU performance
		| Basic
		| Standard
		| Premium : Sacle-out, Zone-redundant

* vCore	 : Production
		| General Purpose	| Provisioned															| Azure
							| Serveless	(Compute resources are auto-scaled, Billed per second)		| Hybrid
		| Hyperscale		| Secondary Replicas, Very large OLTP database							| Benefit
		| Business Critical	| high transaction rate and lowest latency I/O,							| (55% discount)
							  for Business critical system

** DTU : We can just like the DTU to the horsepower in a car because it directly affects the performance of the database.
		 DTU represents a mixture of the following performance metrics as a single performance unit for Azure SQL Database
		 * CPU
		 * Memory
		 * Data I/O and Log I/O
