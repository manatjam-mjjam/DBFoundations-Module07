--*************************************************************************--
-- Title: Assignment07
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2026-11-24,Mjjamsuwan,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_Mjjamsuwan')
	 Begin 
	  Alter Database [Assignment07DB_Mjjamsuwan] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_Mjjamsuwan;
	 End
	Create Database Assignment07DB_Mjjamsuwan;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_Mjjamsuwan;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

/*
-- Step 1: Select only the needed columns
Select 
  ProductName, 
  UnitPrice
From vProducts;  
go

-- Step 2:  Add Order by:
Select 
  ProductName, 
  UnitPrice
From vProducts
Order By ProductName;
go 

-- Step 3: Use a Function
Select 
  ProductName, 
  Format(UnitPrice, 'C', 'en-US') As UnitPrice
From vProducts;
go

*/

-- Final Answer
Select 
	ProductName,
	Format(UnitPrice, 'C', 'en-US') As UnitPrice 
From vProducts
Order By ProductName;
Go


-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

/*
-- Step 1: Identify the table (Views) needed
-- Category name in vCategories, and product names and price in vProducts. We need both, so we need a join
	-- vCategories: CategoryID, CategoryName
	-- vProducts: ProductID, ProductName, CategoryID, UnitPrice
	-- The shared column is CategoryID.

-- Step 2: Join the two views
Select CategoryName, ProductName, UnitPrice
From vCategories 
 Inner Join vProducts  
	On vCategories.CategoryID = vProducts.CategoryID;
go 

-- Step 3: Format the price as US dollars
Select 
   CategoryName, 
   ProductName, 
   Format(UnitPrice, 'C', 'en-US') As UnitPrice
From vCategories 
 Inner Join vProducts  
	On vCategories.CategoryID = vProducts.CategoryID;
go

-- Step 4: Add Order by Category and Products
Order By CategoryName, ProductName;
go 

*/

-- Final Answer
Select 
	CategoryName, 
	ProductName,
	Format(UnitPrice, 'C', 'en-US') As UnitPrice
From vCategories 
 Inner Join vProducts  
	On vCategories.CategoryID = vProducts.CategoryID
Order By CategoryName, ProductName;
Go


-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

/*
-- Step 1: Identify the view needed
	-- Product Names are in vProducts; ProductID, ProductName, CategoryID, UnitPrice
	-- Dates and Counts are in vInventories; InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, Count
	-- The shared column is ProductID

-- STEP 2: Join the two views
Select 
  ProductName, 
  InventoryDate, 
  [Count]
From vProducts  
 Inner Join vInventories 
	On vProducts.ProductID = vInventories.ProductID;
go 

-- STEP 3: Add the function to Format the date as 'January 2017'
Select
  ProductName,
  Format(InventoryDate, 'MMMM, yyyy') As InventoryDate,
  [Count] As InventoryCount
From vProducts 
 Inner Join vInventories
  On vProducts.ProductID = vInventories.ProductID;
go

*/

-- Final Answer
Select
  ProductName,
  Format(InventoryDate, 'MMMM, yyyy') As InventoryDate,
  [Count] As InventoryCount
From vProducts 
 Inner Join vInventories 
  On vProducts.ProductID = vInventories.ProductID
Order By ProductName, vInventories.InventoryDate;
go


-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

/*
-- Start from the Question 3 query - we reuse it because View Body is the same query as Question 3.
Select 
  ProductName,
  Format(InventoryDate, 'MMMM, yyyy') As InventoryDate,
  [Count] As InventoryCount
From vProducts
 Inner Join vInventories
  On vProducts.ProductID = vInventories.ProductID;
go 

*/


-- Final Answer
Create View vProductInventories
As
  Select
    ProductName,
    Format(InventoryDate, 'MMMM, yyyy') As InventoryDate,
    [Count] As InventoryCount
  From vProducts
  Inner Join vInventories
    On vProducts.ProductID = vInventories.ProductID;
go 


-- Check that it works 
Select * From vProductInventories
Order By ProductName, Cast(InventoryDate As Date);
go


-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

/*
-- Step 1: Identify the views as we need category names, inventory dates, and counts, so we go through three view
	-- Category Name: vCategorie.CategoryName
	-- Inventory Dates: vInventories.InventoryDate
	-- TOTAL Inventory Count: SUM([Count])

-- Step 2: Join all three basic views
Select 
  CategoryName,
  InventoryDate,
  [Count] 
From vCateogories
Join vProducts 
  On vCategories.CategoryID = vProducts.CategoryID
Join vInventories As I 
  On vProducts.ProductID = vInventories.ProductID;
go 

-- Step 3: Add SUM() and Group by, one row per category per date as a Total Inventory Count by Category and date
Select
  CategoryName, 
  InventoryDate,
  SUM([Count]) As InventoryCountByCategory
From vCategories 
Join vProducts
  On vCategories.CategoryID = vProducts.CategoryID
Join vInventories 
  On vProducts.ProductID = vInventories.ProductID
Group By CategoryName, InventoryDate;
go

-- Step 4: Add the Format() the date as 'January, 2017', and fix the Group By
Select 
  CategoryName,
  Format(InventoryDate, 'MMMM, yyyy') As InventoryDate,
  SUM([Count]) As InventoryCountByCategory
From vCategories  
 Inner Join vProducts 
   On vCategories.CategoryID = vProducts.CategoryID
 Inner Join vInventories 
   On vProducts.ProductID = vInventories.ProductID
Group By CategoryName, InventoryDate;
go

*/

-- Final Answer
Create View vCategoryInventories
AS 
  Select 
    CategoryName,
	Format(InventoryDate, 'MMMM, yyyy') As InventoryDate,
	Sum([Count]) As InventoryCountByCategory
From vCategories 
Inner Join vProducts  
  On vCategories.CategoryID = vProducts.CategoryID
Inner Join vInventories
  On vProducts.ProductID = vInventories.ProductID
Group By CategoryName, InventoryDate;
go 


-- Check that it works: included Order by
Select * From vCategoryInventories
Order By CategoryName, Cast(InventoryDate As Date); 
go


-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

/*
-- Step 1: Identify the column needed
Select 
  ProductName,
  InventoryDate, 
  InventoryCount
From vProductInventories;
go 

-- Step 2: Add Lag() to get the previous Month Count
Select 
  ProductName,
  InventoryDate,
  InventoryCount,
  Lag(InventoryCount) Over (Partition By ProductName -- Partition by ProductName restarts the "previous row" for each product
  							Order By Cast(InventoryDate As Dates)) As PreviousMountCount
From vProductInventories;
go


-- Step 3: Fix the January NULLs with ZERO
IsNull(Lag(InventoryCount) Over (Partition By ProductName
								Order By Cast(InventoryDate As Date)), 0) As PreviousMonthCounts

*/

-- Final Answer - Create a new View
Create View vProductInventoriesWithPreviousMonthCounts
As
  Select
    ProductName,
    InventoryDate,
	InventoryCount,
	IsNull(Lag(InventoryCount) Over (Partition By ProductName
									Order By Cast(InventoryDate As Date)), '0') As PreviousMonthCounts
From vProductInventories;
go  


-- Check that it works: 
-- Order By Product and Date
Select * From vProductInventoriesWithPreviousMonthCounts
Order By ProductName, Cast(InventoryDate As Date);
go 



-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

/*

-- Step 1: Start from Question 6 View, we already had the previous month's count, and the new view must use vProductInventoriesWithPreviousMonthCounts 
-- as the requirement

-- Step 2: Set the KPI rule: compare current inventory and previous month count as;
	-- InventoryCount > PreviousMonthCounts --> 1 (increased)
	-- InventoryCount = PreviousMonthCounts --> 0 (same)
	-- InventoryCount < PreviousMonthCounts --> -1 (decreased)

*/

-- Final Answer
Create View vProductInventoriesWithPreviousMonthCountsWithKPIs
As 
   Select
      ProductName,
      InventoryDate,
      InventoryCount,
	  PreviousMonthCounts,
      Case
	 	 When InventoryCount > PreviousMonthCounts Then 1
	  	 When InventoryCount = PreviousMonthCounts Then 0
	  	 When InventoryCount < PreviousMonthCounts Then -1
   End As CountVsPreviousCountKPI
From vProductInventoriesWithPreviousMonthCounts;
go


-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: 
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs
Order By ProductName, Cast(InventoryDate As Date);
go


-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

/*
-- Step1: Start from the question 7 View, wrap the Question 7 view in the Function that filtered by KPI
Select
   ProductName,
   InventoryDate,
   InventoryCount,
   PreviousMonthCounts,
   CountVsPreviousCountKPI
From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go 

-- Step 2: Add a WHERE filter, replace the hard-coded with a parameter @KPI
Where CountVsPreviousCountKPI = @KPI

-- Step 3: Turn it into an Inline Table-Valued Function; (No BEGIN/END needed for this type)
Create Function fProductInventoriesWithPreviousMonthCountsWithKPIs (@KPI int)
Returns Table
As
Return (
	Select ...
	Where CountVsPreviousCountKPI = @KPI
);
go 

*/

-- Final Answer
Create Function fProductInventoriesWithPreviousMonthCountsWithKPIs (@KPI int)
Returns Table 
As
Return (
	Select 
	  ProductName,
	  InventoryDate,
	  InventoryCount,
	  PreviousMonthCounts,
	  CountVsPreviousCountKPI
	From vProductInventoriesWithPreviousMonthCountsWithKPIs
	Where CountVsPreviousCountKPI = @KPI
);
go



-- Check if the function works with different parameters: 1, -1, 0
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1)
Order By ProductName, Cast(InventoryDate As Date);
go 

Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0)
Order by ProductName, Cast(InventoryDate As Date);
go 

Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1)
Order by ProductName, Cast(InventoryDate As Date);
go 


Print 'Note: You will get an error until the views and functions are created!'
/* Check that it works:
Select * From vProductInventories;
Select * From vCategoryInventories;
Select * From vProductInventoriesWithPreviousMonthCounts;
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;

Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/