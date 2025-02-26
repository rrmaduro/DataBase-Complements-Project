/********************************************
 *	UC: Complementos de Bases de Dados 2023/2024
 *
 *	Turma: 2ºL_EI-SW-03 (15:00h - 17:00h)
 *		Nome Aluno: Ricardo Pinto (nº 202200637)
 *		Nome Aluno: Rodrigo Maduro (nº 202200166)
 *	    Nome Aluno: Rodrigo Arraiado (nº 202100436)
 *	
 *			SetUp
 *  
 ********************************************/

-- Section: AdventureWorks Database Setup

-- Drop the AdventureWorks database if it exists
IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'AdventureWorks')
    DROP DATABASE AdventureWorks;
GO

-- Create the AdventureWorks database if it does not exist
IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'AdventureWorks')
    CREATE DATABASE AdventureWorks
	ON PRIMARY
       (
           NAME = 'AdventureWorks',
           FILENAME = 'D:\Pessoal\Faculdade\2º Ano\1º Semestre\CBD\Projeto-CBD\scripts\Backups\FileGroups\AdventureWorks.mdf',
           SIZE = 2048KB,
           FILEGROWTH = 1024KB
       ),
   FILEGROUP AdventureWorks_Sales
       (
           NAME = 'AdventureWorks_Sales',
           FILENAME = 'D:\Pessoal\Faculdade\2º Ano\1º Semestre\CBD\Projeto-CBD\scripts\Backups\FileGroups\AdventureWorks_Sales.ndf',
           SIZE = 2048KB,
           FILEGROWTH = 1024KB
       ),
   FILEGROUP AdventureWorks_Person
       (
           NAME = 'AdventureWorks_Person',
           FILENAME = 'D:\Pessoal\Faculdade\2º Ano\1º Semestre\CBD\Projeto-CBD\scripts\Backups\FileGroups\AdventureWorks_Person.ndf',
           SIZE = 2048KB,
           FILEGROWTH = 1024KB
       ),
	   FILEGROUP AdventureWorks_Production
       (
           NAME = 'AdventureWorks_Production',
           FILENAME = 'D:\Pessoal\Faculdade\2º Ano\1º Semestre\CBD\Projeto-CBD\scripts\Backups\FileGroups\AdventureWorks_Production.ndf',
           SIZE = 2048KB,
           FILEGROWTH = 1024KB
       ),
   FILEGROUP AdventureWorks_InfoLog
       (
           NAME = 'AdventureWorks_InfoLog',
           FILENAME = 'D:\Pessoal\Faculdade\2º Ano\1º Semestre\CBD\Projeto-CBD\scripts\Backups\FileGroups\AdventureWorks_InfoLog.ndf',
           SIZE = 2048KB,
           FILEGROWTH = 1024KB
       )
LOG ON
    (
        NAME = 'AdventureWorks_Log',
        FILENAME = 'D:\Pessoal\Faculdade\2º Ano\1º Semestre\CBD\Projeto-CBD\scripts\Backups\FileGroups\AdventureWorks_Log.ldf',
        SIZE = 1024KB,
        FILEGROWTH = 10%
    )
GO


USE AdventureWorks;

-- Drop the schemas if they exist
DROP SCHEMA IF EXISTS Sales
GO
DROP SCHEMA IF EXISTS Production
GO
DROP SCHEMA IF EXISTS Person
GO
DROP SCHEMA IF EXISTS Logs
GO

-- Create the Sales schema
CREATE SCHEMA Sales;
GO

-- Create the Production schema
CREATE SCHEMA Production;
GO

-- Create the Person schema
CREATE SCHEMA Person;
GO

-- Create the Logs schema
CREATE SCHEMA Logs;
GO


-- Section: Table Definitions

-- Drop the tables if they exist
DROP TABLE IF EXISTS Logs.sentEmails;
DROP TABLE IF EXISTS Sales.SalesOrderDetail;
DROP TABLE IF EXISTS Production.Product;
DROP TABLE IF EXISTS Production.Description;
DROP TABLE IF EXISTS Sales.SalesOrderHeader;
DROP TABLE IF EXISTS Person.Customer;
DROP TABLE IF EXISTS Sales.Address;
DROP TABLE IF EXISTS Sales.SalesTerritory;
DROP TABLE IF EXISTS Sales.Currency;
DROP TABLE IF EXISTS Production.SubCategory;
DROP TABLE IF EXISTS Production.Category;

-- Category Table
CREATE TABLE Production.Category (
  CategoryKey INT IDENTITY(1,1) PRIMARY KEY,
  FrenchCategoryName VARCHAR(50),
  EnglishCategoryName VARCHAR(50),
  SpanishCategoryName VARCHAR(50)
) ON AdventureWorks_Production;

-- SubCategory Table
CREATE TABLE Production.SubCategory (
  SubCategoryKey INT IDENTITY(1,1) PRIMARY KEY,
  FrenchSubCategoryName VARCHAR(50),
  EnglishSubCategoryName VARCHAR(50),
  SpanishSubCategoryName VARCHAR(50),
  CategoryKey INT,
  FOREIGN KEY (CategoryKey) REFERENCES Production.Category(CategoryKey)
) ON AdventureWorks_Production;

-- Currency Table
CREATE TABLE Sales.Currency (
  CurrencyKey TINYINT IDENTITY(1,1) PRIMARY KEY,
  CurrencyAlternateKey VARCHAR(50),
  CurrencyName VARCHAR(50)
)ON AdventureWorks_Sales;

-- SalesTerritory Table
CREATE TABLE Sales.SalesTerritory (
  SalesTerritoryKey INT IDENTITY(1,1) PRIMARY KEY,
  SalesTerritoryCountry VARCHAR(255),
  SalesTerritoryRegion VARCHAR(255),
  SalesTerritoryGroup VARCHAR(255)
) ON AdventureWorks_Sales;

-- Customer Table
CREATE TABLE Person.Customer (
  CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
  LastName VARCHAR(255),
  MiddleName VARCHAR(50),
  FirstName VARCHAR(50),
  NameStyle VARCHAR(50),
  BirthDate DATE,
  MaritalStatus VARCHAR(50),
  Gender VARCHAR(50),
  EmailAddress VARCHAR(50),
  YearlyIncome INT,
  Title VARCHAR(10),
  TotalChildren TINYINT,
  NumberChildrenAtHome TINYINT,
  EducationLevel VARCHAR(50),
  Occupation VARCHAR(50),
  HouseOwnerFlag BIT,
  NumberCarsOwned TINYINT,
  Phone VARCHAR(50),
  DateFirstPurchase DATE,
  CommuteDistance VARCHAR(50),
  CustomerPassword NVARCHAR(255),
  SecurityQuestion NVARCHAR(255),
  SecurityAnswer NVARCHAR(255)
) ON AdventureWorks_Person;

-- Address Table
CREATE TABLE Sales.Address (
  AddressKey INT IDENTITY(1,1) PRIMARY KEY,
  StateProvince VARCHAR(50),
  CountryRegion VARCHAR(50),
  City VARCHAR(50),
  AddressLine2 VARCHAR(255),
  AddressLine1 VARCHAR(255),
  PostalCode VARCHAR(50),
  StateProvinceName VARCHAR(255),
  CountryRegionName VARCHAR(255),
  SalesTerritoryKey INT,
  CustomerKey INT,
  FOREIGN KEY (SalesTerritoryKey) REFERENCES Sales.SalesTerritory(SalesTerritoryKey),
  FOREIGN KEY (CustomerKey) REFERENCES Person.Customer(CustomerKey)
) ON AdventureWorks_Sales;

-- Description Table
CREATE TABLE Production.Description (
  DescriptionKey INT IDENTITY(1,1) PRIMARY KEY,
  FrenchDescription NVARCHAR(1000),
  EnglishDescription NVARCHAR(255),
  SpanishProductName NVARCHAR(255),
  EnglishProductName NVARCHAR(255),
  FrenchProductName NVARCHAR(255)
) ON AdventureWorks_Production;

-- Product Table
CREATE TABLE Production.Product (
  ProductKey INT IDENTITY(1,1) PRIMARY KEY,
  Size VARCHAR(50),
  SizeUnitMeasureCode VARCHAR(50),
  DaysToManufacture TINYINT,
  Color VARCHAR(50),
  SizeRange VARCHAR(50),
  StandardCost FLOAT,
  ListPrice FLOAT,
  SafetyStockLevel SMALLINT,
  WeightUnitMeasureCode VARCHAR(50),
  FinishedGoodsFlag VARCHAR(50),
  Weight FLOAT,
  Class VARCHAR(50),
  ProductLine VARCHAR(50),
  DealerPrice FLOAT,
  ModelName VARCHAR(50),
  Status VARCHAR(50),
  DescriptionKey INT,
  SubCategoryKey INT,
  FOREIGN KEY (DescriptionKey) REFERENCES Production.Description(DescriptionKey),
  FOREIGN KEY (SubCategoryKey) REFERENCES Production.SubCategory(SubCategoryKey)
) ON AdventureWorks_Production;

-- SalesOrderHeader Table
CREATE TABLE Sales.SalesOrderHeader (
  SalesOrderNumber VARCHAR(50) PRIMARY KEY,
  DueDate DATE,
  OrderDate DATE,
  CustomerPONumber SMALLINT,
  CarrierTrackingNumber TINYINT,
  OrderDateKey DATE,
  DueDateKey DATE,
  RevisionNumber TINYINT,
  ShipDate DATETIME2(7),
  ShipDateKey DATE,
  CustomerKey INT,
  CurrencyKey TINYINT,
  SalesTerritoryKey INT,
  FOREIGN KEY (CustomerKey) REFERENCES Person.Customer(CustomerKey),
  FOREIGN KEY (CurrencyKey) REFERENCES Sales.Currency(CurrencyKey),
  FOREIGN KEY (SalesTerritoryKey) REFERENCES Sales.SalesTerritory(SalesTerritoryKey)
) ON AdventureWorks_Sales;

-- SalesOrderDetail Table
CREATE TABLE Sales.SalesOrderDetail (
  SalesOrderKey INT IDENTITY(1,1) PRIMARY KEY,
  SalesOrderNumber VARCHAR(50),
  TaxAmt INT,
  SalesAmount FLOAT,
  SalesOrderLineNumber TINYINT,
  DiscountAmount TINYINT,
  UnitPriceDiscountPct TINYINT,
  OrderQuantity TINYINT,
  ProductStandardCost FLOAT,
  UnitPrice FLOAT,
  TotalProductCost FLOAT,
  ExtendedAmount FLOAT,
  ProductKey INT,
  FOREIGN KEY (ProductKey) REFERENCES Production.Product(ProductKey),
  FOREIGN KEY (SalesOrderNumber) REFERENCES Sales.SalesOrderHeader(SalesOrderNumber)
)ON AdventureWorks_Sales;

-- Section: Logs Tables

CREATE TABLE Logs.SentEmails (
    sentEmailID INT IDENTITY(1,1) PRIMARY KEY,
    recipientEmail NVARCHAR(255),
    emailMessage NVARCHAR(MAX),
    EmailTime DATETIME2 DEFAULT GETDATE()
)ON AdventureWorks_InfoLog;



