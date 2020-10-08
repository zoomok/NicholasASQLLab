--===========================================================================================================================
-- Lab 9 : SQL Server CROSS APPLY and OUTER APPLY
--===========================================================================================================================
-- drop table dept;

CREATE TABLE [dbo].[Dept](
	[DepartmentID] [smallint] NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_DepartmentID] PRIMARY KEY CLUSTERED 
(
	[DepartmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

insert into dept
select	d.DepartmentID,
		d.Name
from	HumanResources.Department d
;

insert into dept values(17, 'IT');
insert into dept values(18, 'Inventory');

-- drop table emp;

select	e.BusinessEntityID as EmployeeID,
		p.FirstName,
		p.LastName,
		h.DepartmentID
into	Emp
from	Person.Person p,
		HumanResources.Employee e,
		HumanResources.EmployeeDepartmentHistory h
where	e.BusinessEntityID = p.BusinessEntityID
and		e.BusinessEntityID = h.BusinessEntityID
and		h.EndDate is null
;

ALTER TABLE Emp
   ADD CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID)
;

ALTER TABLE Emp
   ADD CONSTRAINT FK_Dept FOREIGN KEY (DepartmentID)
      REFERENCES Dept (DepartmentID)
;

-- Inner join
select	*
from	dept d
		inner join emp e
			on d.DepartmentID = e.DepartmentID
;
-----------------------------------------------------------------------
-- Join
-----------------------------------------------------------------------
-- Cross Apply
select	*
from	dept d
cross apply
	(
	select	*
	from	emp e
	where	e.DepartmentID = d.DepartmentID
	) a
;

-- Left outer join
select	*
from	dept d
		left outer join emp e
			on d.DepartmentID = e.DepartmentID
;

-- Outer apply
select	*
from	dept d
outer apply
	(
	select	*
	from	emp e
	where	e.DepartmentID = d.DepartmentID
	) a
;

-----------------------------------------------------------------------
-- Create Table valued function
-----------------------------------------------------------------------
create function dbo.fn_GetAllEmpofDept (@DeptID as int)
returns table
as
return
	(
	select	*
	from	emp e
	where	e.DepartmentID = @DeptID
	)
;

select	*
from	dept d
cross apply dbo.fn_GetAllEmpofDept(d.DepartmentID)
;

select	*
from	dept d
outer apply dbo.fn_GetAllEmpofDept(d.DepartmentID)
;

-----------------------------------------------------------------------
-- Performance comparison
-----------------------------------------------------------------------
create table table1
(
id int not null primary key,
row_count int not null
)
;

create table table2
(
id int not null primary key,
value varchar(20)
)
;

begin transaction
declare @cnt int
set @cnt = 1
while @cnt <= 100000
begin
	insert into table2 (id, value)
	values (@cnt, 'Value' + cast(@cnt as varchar))
	set @cnt = @cnt + 1
end
insert into table1 (id, row_count)
select	top 5
		id, id % 2 + 1
from	table2
order by id
commit;

select	*
from	table1;

select	*
from	table2;

select	*
from	table1 t1
join	(
		select	t2o.*,
				(
				select	count(*)
				from	table2 t2i
				where	t2i.id <= t2o.id
				) as rn
		from	table2 t2o
		) t2
on		t2.rn <= t1.row_count
order by t1.id,
		 t2.id
; --> 08:11

select	*
from	table1 t1
join	(
		select	t2o.*,
				row_number() over(order by id) as rn
		from	table2 t2o
		) t2
on t2.rn <= t1.row_count
order by t1.id,
		 t2.id
; --> 0.5 ms

select	*
from	table1 t1
cross apply
	(
	select	top(t1.row_count)
			*
	from	table2
	order by id
	) t2
order by t1.id,
		 t2.id
;
