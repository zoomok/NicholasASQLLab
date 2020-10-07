--===========================================================================================================================
-- Lab 7 : Azure SQL Database - Table Partitioning
--===========================================================================================================================
-- set showplan_all on
-- set showplan_all off

1. Link : https://www.mssqltips.com/sqlservertip/3494/azure-sql-database--table-partitioning/

2. Scenario : Calculate and store the primes numbers from 1 to 1 million with ten data partitions.
			  Thus, the primes numbers will be hashed in buckets at every one hundred thousand mark

3. Create databaes MATH
USE [master]
GO

-- Delete existing database
IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'MATH')
DROP DATABASE MATH
GO

-- Create new database
CREATE DATABASE MATH
(
MAXSIZE = 20GB,
EDITION = 'STANDARD',
SERVICE_OBJECTIVE = 'S2'
)
GO  

4. Create partition function
create partition function pf_hash_by_value (bigint) as range left
for values (100000, 200000, 300000, 400000, 500000, 600000, 700000, 800000, 900000)
go

select	*
from	sys.partition_functions
;

5. Create partition scheme
create partition scheme ps_hash_by_value
as partition pf_hash_by_value
all to ([Primary]);
;

select	*
from	sys.partition_schemes
;

6. Partition system function
select	My_Value,
		$partition.pf_hash_by_value(My_Value) as hash_indx
from	(
		values
		(1),
		(100001),
		(200001),
		(300001),
		(400001),
		(500001),
		(600001),
		(700001),
		(800001),
		(900001)
		) as TEST (My_Value)
;

7. Create the partitioned table
if exists
	(
	select	*
	from	sys.objects
	where	object_id = object_id(N'[dbo].[Tbl_Primes]') and type in (N'U')
	)
drop table [dbo].[Tbl_Primes]

go

create table [dbo].[Tbl_Primes]
(
My_Value	bigint not null,
My_Division	bigint not null,
My_Time		datetime not null constraint DF_Tbl_Primes default getdate()
constraint PK_Tbl_Primes primary key clustered (My_Value asc)
) on ps_hash_by_value (My_Value)
;

8. create a procedure that takes a number as a parameter and determines if it is prime

create procedure sp_is_prime
	@var_num2 bigint
as
begin
	set nocount on

	declare @var_cnt2 bigint;
	declare @var_max2 bigint;

	if (@var_num2 = 1)
		return 0;

	if (@var_num2 = 2)
		return 1;

	select	@var_cnt2 = 2;
	select	@var_max2 = sqrt(@var_num2) + 1;
	
	while (@var_cnt2 <= @var_max2)
	begin
		if (@var_num2 % @var_cnt2) = 0
			return 0;

		select	@var_cnt2 = @var_cnt2 + 1;
	end

	return 1;
end;

9. create a procedure that takes a starting and ending value as input and calculates
	And stores primes numbers between those two values as output

if exists
	(
	select	*
	from	sys.objects
	where	object_id = object_id(N'[dbo].[sp_store_primes]')
	and		type in (N'P', N'PC')
	)
drop procedure [dbo].[sp_store_primes]

go

create procedure sp_store_primes
	@var_alpha bigint,
	@var_omega bigint
as
begin
	set nocount on

	declare @var_cnt1 bigint;
	declare @var_ret1 int;

	select	@var_ret1 = 0;
	select	@var_cnt1 = @var_alpha;

	while (@var_cnt1 <= @var_omega)
	begin
		exec @var_ret1 = dbo.sp_is_prime @var_cnt1;

		if (@var_ret1 = 1)
		insert into tbl_primes (my_value, my_division)
		values (@var_cnt1, sqrt(@var_cnt1));

		select	@var_cnt1 = @var_cnt1 + 1
	end
end
;

10. Execute procedure

exec sp_store_primes 1, 100000
exec sp_store_primes 100001, 200000
exec sp_store_primes 200001, 300000
exec sp_store_primes 300001, 400000
exec sp_store_primes 400001, 500000
exec sp_store_primes 500001, 600000
exec sp_store_primes 600001, 700000
exec sp_store_primes 700001, 800000
exec sp_store_primes 800001, 900000
exec sp_store_primes 900001, 100000

11. Validate data placement
select	partition_number,
		row_count
from	sys.dm_db_partition_stats
where	object_id = object_id('Tbl_Primes')
;
partition_number	row_count
------------------- ----------
1						9592
2						8392
3						8013
4						7863
5						7678
6						7560
7						7445
8						7408
9						7323
10						0

select	$partition.pf_hash_by_value(My_Value) as partition_Number,
		count(*) as Row_Count
from	math.dbo.tbl_primes
group by $partition.pf_hash_by_value(My_Value)
;

partition_Number	Row_Count
------------------ -----------
1						9592
2						8392
3						8013
4						7863
5						7678
6						7560
7						7445
8						7408
9						7323

-- Execution plan
set showplan_all on

select	*
from	tbl_primes
where	my_value = 61027
;

StmtText
select *  from tbl_primes  where my_value = 61027
  |--Clustered Index Seek(OBJECT:([MATH].[dbo].[Tbl_Primes].[PK_Tbl_Primes]), SEEK:([PtnId1000]=RangePartitionNew(CONVERT_IMPLICIT(bigint,[@1],0),(0),(100000),(200000),(300000),(400000),(500000),(600000),(700000),(800000),(900000)) AND [MATH].[dbo].[Tbl_Primes].[My_Value]=CONVERT_IMPLICIT(bigint,[@1],0)) ORDERED FORWARD)

set showplan_all off
