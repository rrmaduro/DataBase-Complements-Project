/********************************************
 *	UC: Complementos de Bases de Dados 2023/2024
 *
 *	Turma: 2ºL_EI-SW-03 (15:00h - 17:00h)
 *		Nome Aluno: Ricardo Pinto (nº 202200637)
 *		Nome Aluno: Rodrigo Maduro (nº 202200166)
 *	    Nome Aluno: Rodrigo Arraiado (nº 202100436)
 *	
 *			Migration
 ********************************************/

-- Section: Data Migration

USE AdventureWorks;

-- Drop existing procedures for data migration
DROP PROCEDURE IF EXISTS Production.MigrateCategory;
DROP PROCEDURE IF EXISTS Production.MigrateSubCategory;
DROP PROCEDURE IF EXISTS Production.MigrateDescription;
DROP PROCEDURE IF EXISTS Production.MigrateProduct;
DROP PROCEDURE IF EXISTS Sales.MigrateSalesTerritory;
DROP PROCEDURE IF EXISTS Sales.MigrateAddress;
DROP PROCEDURE IF EXISTS Sales.MigrateCurrency;
DROP PROCEDURE IF EXISTS Person.MigrateCustomer;
DROP PROCEDURE IF EXISTS Sales.MigrateSalesOrderHeader;
DROP PROCEDURE IF EXISTS Sales.MigrateSalesOrderDetail;
GO

-- Procedure to migrate data from AdventureWorksOldData.Production.Products to Production.Category
CREATE PROCEDURE Production.MigrateCategory
AS
BEGIN
    BEGIN TRY
        -- Insert distinct category names into Production.Category
        INSERT INTO Production.Category (FrenchCategoryName, EnglishCategoryName, SpanishCategoryName)
        SELECT DISTINCT FrenchProductCategoryName, EnglishProductCategoryName, SpanishProductCategoryName
        FROM AdventureWorksOldData.Production.Products;
    END TRY
    BEGIN CATCH
        -- Print error message if an error occurs during migration
        PRINT 'Error occurred in Production.MigrateCategory';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- Execute the MigrateCategory procedure
EXEC Production.MigrateCategory;
GO

-- Procedure to migrate data from AdventureWorksOldData.Production.ProductSubCategory to Production.SubCategory
CREATE PROCEDURE Production.MigrateSubCategory
AS
BEGIN
    BEGIN TRY
        -- Insert distinct subcategory names along with corresponding category keys into Production.SubCategory
        INSERT INTO Production.SubCategory (FrenchSubCategoryName, EnglishSubCategoryName, SpanishSubCategoryName, CategoryKey)
        SELECT DISTINCT s.FrenchProductSubCategoryName, s.EnglishProductSubCategoryName, s.SpanishProductSubCategoryName, c.CategoryKey
        FROM AdventureWorksOldData.Production.ProductSubCategory s
        JOIN AdventureWorksOldData.Production.Products p ON p.ProductSubcategoryKey  = s.ProductSubcategoryKey
        JOIN Production.Category c ON p.EnglishProductCategoryName COLLATE SQL_Latin1_General_CP1_CI_AS = c.EnglishCategoryName COLLATE SQL_Latin1_General_CP1_CI_AS; 
    END TRY
    BEGIN CATCH
        -- Print error message if an error occurs during migration
        PRINT 'Error occurred in Production.MigrateSubCategory';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- Execute the MigrateSubCategory procedure
EXEC Production.MigrateSubCategory;
GO

-- Procedure to migrate data from AdventureWorksOldData.Production.Products to Production.Description
CREATE PROCEDURE Production.MigrateDescription
AS
BEGIN
    BEGIN TRY
        -- Insert distinct product descriptions into Production.Description
        INSERT INTO Production.Description (FrenchDescription, EnglishDescription, SpanishProductName, EnglishProductName, FrenchProductName)
        SELECT DISTINCT FrenchDescription, EnglishDescription, SpanishProductName, EnglishProductName, FrenchProductName
        FROM AdventureWorksOldData.Production.Products;
    END TRY
    BEGIN CATCH
        -- Print error message if an error occurs during migration
        PRINT 'Error occurred in Production.MigrateDescription';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- Execute the MigrateDescription procedure
EXEC Production.MigrateDescription;
GO

-- Procedure to migrate data from AdventureWorksOldData.Production.Products to Production.Product
CREATE PROCEDURE Production.MigrateProduct
AS
BEGIN
    BEGIN TRY
        -- Insert distinct product details along with corresponding category and description keys into Production.Product
        INSERT INTO Production.Product (Size, SizeUnitMeasureCode, DaysToManufacture, Color, SizeRange, StandardCost, ListPrice, SafetyStockLevel, WeightUnitMeasureCode, FinishedGoodsFlag, Weight, Class, ProductLine, DealerPrice, ModelName, Status, SubCategoryKey, DescriptionKey)
        SELECT DISTINCT p.Size, p.SizeUnitMeasureCode, p.DaysToManufacture, p.Color, p.SizeRange, p.StandardCost, p.ListPrice, p.SafetyStockLevel, p.WeightUnitMeasureCode, p.FinishedGoodsFlag, p.Weight, p.Class, p.ProductLine, p.DealerPrice, p.ModelName, p.Status, p.ProductSubcategoryKey, d.DescriptionKey
        FROM AdventureWorksOldData.Production.Products p
        JOIN Production.Description d ON p.EnglishProductName COLLATE SQL_Latin1_General_CP1_CI_AS = d.EnglishProductName COLLATE SQL_Latin1_General_CP1_CI_AS;
    END TRY
    BEGIN CATCH
        -- Print error message if an error occurs during migration
        PRINT 'Error occurred in Production.MigrateProduct';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- Execute the MigrateProduct procedure
EXEC Production.MigrateProduct;
GO

-- Procedure to migrate data from AdventureWorksOldData.Sales.SalesTerritory to Sales.SalesTerritory
CREATE PROCEDURE Sales.MigrateSalesTerritory
AS
BEGIN
    BEGIN TRY
        -- Insert distinct sales territory details into Sales.SalesTerritory
        INSERT INTO Sales.SalesTerritory (SalesTerritoryCountry, SalesTerritoryRegion, SalesTerritoryGroup)
        SELECT DISTINCT SalesTerritoryCountry, SalesTerritoryRegion, SalesTerritoryGroup
        FROM AdventureWorksOldData.Sales.SalesTerritory;
    END TRY
    BEGIN CATCH
        -- Print error message if an error occurs during migration
        PRINT 'Error occurred in Sales.MigrateSalesTerritory';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- Execute the MigrateSalesTerritory procedure
EXEC Sales.MigrateSalesTerritory;
GO

-- Procedure to migrate data from AdventureWorksOldData.Person.Customer to Person.Customer
CREATE PROCEDURE Person.MigrateCustomer
AS
BEGIN
    BEGIN TRY
        -- Insert distinct customer details into Person.Customer
        INSERT INTO Person.Customer (LastName, FirstName, NameStyle, BirthDate, MaritalStatus, Gender, EmailAddress, YearlyIncome, Title, MiddleName, TotalChildren, NumberChildrenAtHome, EducationLevel, Occupation, HouseOwnerFlag, NumberCarsOwned, Phone, DateFirstPurchase, CommuteDistance)
        SELECT DISTINCT
            c.LastName, c.FirstName, c.NameStyle, c.BirthDate, c.MaritalStatus, c.Gender, c.EmailAddress, c.YearlyIncome,
            c.Title, c.MiddleName, c.TotalChildren, c.NumberChildrenAtHome, c.Education, c.Occupation, c.HouseOwnerFlag,
            c.NumberCarsOwned, c.Phone, c.DateFirstPurchase, c.CommuteDistance
        FROM
            AdventureWorksOldData.Person.Customer c;
    END TRY
    BEGIN CATCH
        -- Print error message if an error occurs during migration
        PRINT 'Error occurred in Person.MigrateCustomer';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- Execute the MigrateCustomer procedure
EXEC Person.MigrateCustomer;
GO

-- Procedure to migrate data from AdventureWorksOldData.Person.Customer to Sales.Address
CREATE PROCEDURE Sales.MigrateAddress
AS
BEGIN
    BEGIN TRY
        -- Insert distinct address details along with corresponding sales territory and customer keys into Sales.Address
        INSERT INTO Sales.Address (StateProvince, CountryRegion, City, AddressLine1, AddressLine2, PostalCode, StateProvinceName, CountryRegionName, SalesTerritoryKey, CustomerKey)
        SELECT DISTINCT
            a.StateProvinceCode, a.CountryRegionCode, a.City, a.AddressLine1, a.AddressLine2, a.PostalCode,
            a.StateProvinceName, a.CountryRegionName, st.SalesTerritoryKey, a.CustomerKey
        FROM AdventureWorksOldData.Person.Customer a
        LEFT JOIN Person.Customer c ON a.CustomerKey = c.CustomerKey
        INNER JOIN Sales.SalesTerritory st ON a.SalesTerritoryKey = st.SalesTerritoryKey
        WHERE c.CustomerKey IS NOT NULL;
    END TRY
    BEGIN CATCH
        -- Print error message if an error occurs during migration
        PRINT 'Error occurred in Sales.MigrateAddress';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- Execute the MigrateAddress procedure
EXEC Sales.MigrateAddress;
GO

-- Procedure to migrate data from AdventureWorksOldData.Sales.Currency to Sales.Currency
CREATE PROCEDURE Sales.MigrateCurrency 
  AS
  BEGIN
    BEGIN TRY
        -- Insert distinct currency details into Sales.Currency
        INSERT INTO Sales.Currency (CurrencyAlternateKey, CurrencyName) 
        SELECT DISTINCT CurrencyAlternateKey, CurrencyName FROM AdventureWorksOldData.Sales.Currency; 
    END TRY
    BEGIN CATCH
        -- Print error message if an error occurs during migration
        PRINT 'Error occurred in Sales.MigrateCurrency';
        PRINT ERROR_MESSAGE();
    END CATCH
  END;
GO

-- Execute the MigrateCurrency procedure
EXEC Sales.MigrateCurrency; 
GO

-- Procedure to migrate data from AdventureWorksOldData.Sales.Sales7 to Sales.SalesOrderHeader
CREATE PROCEDURE Sales.MigrateSalesOrderHeader
AS
BEGIN
    BEGIN TRY
        -- Insert distinct sales order header details into Sales.SalesOrderHeader
        INSERT INTO Sales.SalesOrderHeader(SalesOrderNumber, DueDate, OrderDate, CustomerPONumber, CarrierTrackingNumber, OrderDateKey, DueDateKey, RevisionNumber, ShipDateKey, ShipDate, CustomerKey, CurrencyKey, SalesTerritoryKey)
        SELECT DISTINCT s.SalesOrderNumber, s.DueDate, s.OrderDate, s.CustomerPONumber, s.CarrierTrackingNumber, s.OrderDateKey, s.DueDateKey, s.RevisionNumber, s.ShipDateKey, s.ShipDate, s.CustomerKey, s.CurrencyKey, s.SalesTerritoryKey 
        FROM AdventureWorksOldData.Sales.Sales7 s
        JOIN Person.Customer c ON s.CustomerKey = c.CustomerKey 
        JOIN Sales.Currency cy ON s.CurrencyKey = cy.CurrencyKey
        JOIN Sales.SalesTerritory st ON s.SalesTerritoryKey = st.SalesTerritoryKey ;
    END TRY
    BEGIN CATCH
        -- Print error message if an error occurs during migration
        PRINT 'Error occurred in Sales.MigrateSalesOrderHeader';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- Execute the MigrateSalesOrderHeader procedure
EXEC Sales.MigrateSalesOrderHeader;
GO

-- Procedure to migrate data from AdventureWorksOldData.Sales.Sales7 to Sales.SalesOrderDetail
CREATE PROCEDURE Sales.MigrateSalesOrderDetail
AS
BEGIN
    BEGIN TRY
        -- Insert distinct sales order detail details into Sales.SalesOrderDetail
        INSERT INTO Sales.SalesOrderDetail (SalesOrderNumber, TaxAmt, SalesAmount, SalesOrderLineNumber, DiscountAmount, UnitPriceDiscountPct, OrderQuantity, ProductStandardCost, UnitPrice, TotalProductCost, ExtendedAmount, ProductKey)
        SELECT s.SalesOrderNumber, s.TaxAmt, s.SalesAmount, s.SalesOrderLineNumber, s.DiscountAmount, s.UnitPriceDiscountPct, s.OrderQuantity, s.ProductStandardCost, s.UnitPrice, s.TotalProductCost, s.ExtendedAmount, p.ProductKey
        FROM AdventureWorksOldData.Sales.Sales7 s
        JOIN Production.Product p ON s.ProductKey = p.ProductKey
        JOIN Sales.SalesOrderHeader soh ON s.SalesOrderNumber COLLATE SQL_Latin1_General_CP1_CI_AS= soh.SalesOrderNumber COLLATE SQL_Latin1_General_CP1_CI_AS;
    END TRY
    BEGIN CATCH
        -- Print error message if an error occurs during migration
        PRINT 'Error occurred in Sales.MigrateSalesOrderDetail';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- Execute the MigrateSalesOrderDetail procedure
EXEC Sales.MigrateSalesOrderDetail;
GO





-- Section: Select Statements

-- Select all records from the Category table
SELECT * FROM Production.Category;

-- Select all records from the SubCategory table
SELECT * FROM Production.SubCategory;

-- Select all records from the Currency table
SELECT * FROM Sales.Currency;

-- Select all records from the SalesTerritory table
SELECT * FROM Sales.SalesTerritory;

-- Select all records from the Customer table
SELECT * FROM Person.Customer;

-- Select all records from the Address table
SELECT * FROM Sales.Address;

-- Select all records from the Description table
SELECT * FROM Production.Description;

-- Select all records from the Product table
SELECT * FROM Production.Product;

-- Select all records from the SalesOrderHeader table
SELECT * FROM Sales.SalesOrderHeader;

-- Select all records from the SalesOrderDetail table
SELECT * FROM Sales.SalesOrderDetail;

-- Select all records from the sentEmails table
SELECT * FROM Logs.sentEmails;

