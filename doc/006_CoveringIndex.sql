--===========================================================================================================================
-- Lab 6 : Using Covering Indexes to Improve Query Performance
--===========================================================================================================================
-- set showplan_all on
-- set showplan_all off
-----------------------------------------------------------------------------------------------
-- Clustered Index
-----------------------------------------------------------------------------------------------
ALTER TABLE [Sales].[Customer] ADD  CONSTRAINT [PK_Customer_CustomerID] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (
	PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF,
	IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [PRIMARY]
;

-- set showplan_all on
select	c.*
from	sales.Customer c
where	c.CustomerID = 123
;

select c.CustomerID,    c.AccountNumber  from sales.Customer c  where c.CustomerID = 123  ;
  |--Compute Scalar(DEFINE:([c].[AccountNumber]=[AdventureWorks2012].[Sales].[Customer].[AccountNumber] as [c].[AccountNumber]))
       |--Compute Scalar(DEFINE:([c].[AccountNumber]=isnull('AW'+[AdventureWorks2012].[dbo].[ufnLeadingZeros]([AdventureWorks2012].[Sales].[Customer].[CustomerID] as [c].[CustomerID]),'')))
            |--Clustered Index Seek(OBJECT:([AdventureWorks2012].[Sales].[Customer].[PK_Customer_CustomerID] AS [c]), SEEK:([c].[CustomerID]=CONVERT_IMPLICIT(int,[@1],0)) ORDERED FORWARD)

-----------------------------------------------------------------------------------------------
-- Nonclustered Index
-----------------------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX [IX_Customer_PersonID_TerritoryID] ON [Sales].[Customer]
(	[PersonID] ASC,
	[TerritoryID] ASC
)
WITH (
	PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF,
	ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
	)
ON [PRIMARY]
;

select	c.PersonID,
		c.TerritoryID,
		c.StoreID
from	sales.Customer c
where	c.PersonID = 20613
;

select c.PersonID,    c.TerritoryID,    c.StoreID  from sales.Customer c  where c.PersonID = 20613
  |--Nested Loops(Inner Join, OUTER REFERENCES:([c].[CustomerID]))
       |--Index Seek(OBJECT:([AdventureWorks2012].[Sales].[Customer].[IX_Customer_PersonID_TerritoryID] AS [c]), SEEK:([c].[PersonID]=(20613)) ORDERED FORWARD)
       |--Clustered Index Seek(OBJECT:([AdventureWorks2012].[Sales].[Customer].[PK_Customer_CustomerID] AS [c]), SEEK:([c].[CustomerID]=[AdventureWorks2012].[Sales].[Customer].[CustomerID] as [c].[CustomerID]) LOOKUP ORDERED FORWARD)

select	c.PersonID,
		c.TerritoryID,
		c.StoreID
from	sales.Customer c
where	c.PersonID between 1 and 20613
;

select c.PersonID,    c.TerritoryID,    c.StoreID  from sales.Customer c  where c.PersonID between 1 and 20613
  |--Clustered Index Scan(OBJECT:([AdventureWorks2012].[Sales].[Customer].[PK_Customer_CustomerID] AS [c]), WHERE:([AdventureWorks2012].[Sales].[Customer].[PersonID] as [c].[PersonID]>=(1) AND [AdventureWorks2012].[Sales].[Customer].[PersonID] as [c].[PersonID]<=(20613)))

select	c.PersonID,
		c.TerritoryID
from	sales.Customer c
where	c.PersonID between 20000 and 20613
;

select c.PersonID,    c.TerritoryID  from sales.Customer c  where c.PersonID between 20000 and 20613  ;
  |--Index Seek(OBJECT:([AdventureWorks2012].[Sales].[Customer].[IX_Customer_PersonID_TerritoryID] AS [c]), SEEK:([c].[PersonID] >= CONVERT_IMPLICIT(int,[@1],0) AND [c].[PersonID] <= CONVERT_IMPLICIT(int,[@2],0)) ORDERED FORWARD)
 
------------------------------------------------------------------------------------------
-- Including Non-Key columns (Covering index)
------------------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX [IX_Customer_PersonID_TerritoryID_Store_ID] ON [Sales].[Customer]
(	[PersonID] ASC,
	[TerritoryID] ASC
)
INCLUDE([StoreID]) --> Include multiple columns
WITH (
	PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF,
	ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
	)
ON [PRIMARY]
;

select	c.PersonID,
		c.TerritoryID,
		c.StoreID
from	sales.Customer c
where	c.PersonID between 1 and 20613
;

select c.PersonID,    c.TerritoryID,    c.StoreID  from sales.Customer c  where c.PersonID between 1 and 20613
  |--Index Seek(OBJECT:([AdventureWorks2012].[Sales].[Customer].[IX_Customer_PersonID_TerritoryID_Store_ID] AS [c]), SEEK:([c].[PersonID] >= (1) AND [c].[PersonID] <= (20613)) ORDERED FORWARD)
