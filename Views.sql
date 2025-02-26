/********************************************
 *	UC: Complementos de Bases de Dados 2023/2024
 *
 *	Turma: 2ºL_EI-SW-03 (15:00h - 17:00h)
 *		Nome Aluno: Ricardo Pinto (nº 202200637)
 *		Nome Aluno: Rodrigo Maduro (nº 202200166)
 *	    Nome Aluno: Rodrigo Arraiado (nº 202100436)
 *	
 *			Views
 ********************************************/

-- Section: Views

USE AdventureWorks;


-- Drop the CustomerTotalPurchases view
DROP VIEW IF EXISTS Sales.vw_CustomerTotalPurchases;
GO

-- Drop the CustomerPurchases view
DROP VIEW IF EXISTS Sales.vw_CustomerPurchases;
GO

-- Drop the FR_SalesView
DROP VIEW IF EXISTS Sales.vw_FR_SalesView;
GO




-- View: CustomerPurchases
CREATE VIEW Sales.vw_CustomerPurchases AS
SELECT
    so.SalesOrderNumber,
    so.OrderDate,
    sod.ProductKey,
    p.Size,
    p.Color,
    p.StandardCost,
    p.ListPrice,
    sod.OrderQuantity,
    sod.SalesAmount,
	c.CustomerKey
FROM
    Sales.SalesOrderHeader so
JOIN
    Sales.SalesOrderDetail sod ON so.SalesOrderNumber = sod.SalesOrderNumber
JOIN
    Production.Product p ON sod.ProductKey = p.ProductKey
JOIN
    Person.Customer c ON so.CustomerKey = c.CustomerKey;

GO


-- View: CustomerTotalPurchases
CREATE VIEW Sales.vw_CustomerTotalPurchases AS
SELECT
    cp.SalesOrderNumber,
    cp.OrderDate,
    cp.ProductKey,
    cp.Size,
    cp.Color,
    cp.StandardCost,
    cp.ListPrice,
    cp.OrderQuantity,
    cp.SalesAmount,
    SUM(cp.SalesAmount) OVER (PARTITION BY cp.SalesOrderNumber) AS TotalAmount,
	 cp.CustomerKey 
FROM
    Sales.CustomerPurchases cp;
GO


-- View: Purchases in France
CREATE VIEW Sales.vw_FR_SalesView
AS
SELECT
    soh.SalesOrderNumber,
    soh.OrderDate,
    c.LastName + ', ' + c.FirstName AS CustomerName,
    p.ModelName AS ProductName,
    sod.OrderQuantity,
    sod.UnitPrice,
    sod.SalesAmount,
    a.StateProvince,
    a.CountryRegion,
	a.CountryRegionName
FROM
    Sales.SalesOrderHeader soh
    INNER JOIN Person.Customer c ON soh.CustomerKey = c.CustomerKey
    INNER JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderNumber = sod.SalesOrderNumber
    INNER JOIN Production.Product p ON sod.ProductKey = p.ProductKey
    INNER JOIN Sales.Address a ON soh.CustomerKey = a.CustomerKey
    INNER JOIN Sales.SalesTerritory st ON a.SalesTerritoryKey = st.SalesTerritoryKey
WHERE
    a.CountryRegion = 'FR';
go



-- View data for a specific customer
SELECT *
FROM Sales.vw_CustomerTotalPurchases
WHERE CustomerKey = 11237;


-- View data from CustomerPurchases
SELECT *
FROM Sales.vw_CustomerPurchases;

go
-- Create a view for sales records from France
CREATE VIEW dbo.vw_France_SalesRecords
AS
SELECT soh.*
FROM Sales.SalesOrderHeader soh
JOIN Sales.Address a ON soh.CustomerKey = a.CustomerKey
WHERE a.CountryRegionName = 'France';



go


DROP VIEW IF EXISTS Sales.vw_France_SalesDetails;
go

--Sales records para França
CREATE VIEW Sales.vw_France_SalesDetails
AS
SELECT
     sod.SalesOrderKey AS SalesID,
    soh.CustomerKey,
    soh.OrderDate,
    sod.SalesOrderLineNumber AS OrderItem,
    pd.ModelName AS Product,
    sod.OrderQuantity AS Quantity,
    sod.UnitPrice AS Price
FROM
    AdventureWorks.Sales.SalesOrderHeader soh
JOIN
    AdventureWorks.Sales.SalesOrderDetail sod ON soh.SalesOrderNumber = sod.SalesOrderNumber
JOIN
    AdventureWorks.Production.Product pd ON sod.ProductKey = pd.ProductKey
JOIN
    AdventureWorks.Sales.Address a ON soh.CustomerKey = a.CustomerKey
WHERE
    a.CountryRegionName = 'France';

	go
	
	
DROP VIEW IF EXISTS  Sales.vw_RockyMountains_SalesDetails;
go
--Sales records para Rocky Mountains (Northeast)
CREATE VIEW Sales.vw_RockyMountains_SalesDetails
AS
SELECT
    sod.SalesOrderKey AS SalesID,
    soh.CustomerKey,
    soh.OrderDate,
    sod.SalesOrderLineNumber AS OrderItem,
    pd.ModelName AS Product,
    sod.OrderQuantity AS Quantity,
    sod.UnitPrice AS Price
FROM
    AdventureWorks.Sales.SalesOrderHeader soh
JOIN
    AdventureWorks.Sales.SalesOrderDetail sod ON soh.SalesOrderNumber = sod.SalesOrderNumber
JOIN
    AdventureWorks.Production.Product pd ON sod.ProductKey = pd.ProductKey
JOIN
    AdventureWorks.Sales.Address a ON soh.CustomerKey = a.CustomerKey
JOIN
    AdventureWorks.Sales.SalesTerritory st ON a.SalesTerritoryKey = st.SalesTerritoryKey
WHERE
    st.SalesTerritoryKey = 8;