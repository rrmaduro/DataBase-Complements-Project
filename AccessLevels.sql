/********************************************
 * UC: Complementos de Bases de Dados 2023/2024
 *
 * Turma: 2ºL_EI-SW-03 (15:00h - 17:00h)
 * Nome Aluno: Ricardo Pinto (nº 202200637)
 * Nome Aluno: Rodrigo Maduro (nº 202200166)
 * Nome Aluno: Rodrigo Arraiado (nº 202100436)
 * Access Levels
 ********************************************/
USE AdventureWorks;
GO

-- Drop logins
DROP LOGIN SalesPersonUserLogin;
DROP LOGIN AdminUserLogin;
DROP LOGIN STFranceUserLogin;
DROP LOGIN STNortheastUserLogin;

-- Drop roles
DROP ROLE STFranceRole;
DROP ROLE STNortheastRole;
DROP ROLE SalesPersonRole;
DROP ROLE AdminRole;

-- Revoke permissions and drop users
REVOKE ALL ON DATABASE::AdventureWorks FROM AdminRole;
DROP USER SalesTerritoryUser;
DROP USER SalesPersonUser;
DROP USER STFranceUser;
DROP USER STNortheastUser;
DROP USER AdminUser;

-- Create Logins
CREATE LOGIN AdminUserLogin WITH PASSWORD = 'qkjwfbk';
CREATE LOGIN SalesPersonUserLogin WITH PASSWORD = 'owjdbkief';
CREATE LOGIN STFranceUserLogin WITH PASSWORD = 'qkwjifb';
CREATE LOGIN STNortheastUserLogin WITH PASSWORD = 'jqhbwfuhq';

-- Create Users
CREATE USER AdminUser FOR LOGIN AdminUserLogin;
CREATE USER SalesPersonUser FOR LOGIN SalesPersonUserLogin;
CREATE USER STFranceUser FOR LOGIN STFranceUserLogin;
CREATE USER STNortheastUser FOR LOGIN STNortheastUserLogin;

-- Create Roles
CREATE ROLE AdminRole;
CREATE ROLE SalesPersonRole;
CREATE ROLE STFranceRole;
CREATE ROLE STNortheastRole;

-- Add Users to Roles
ALTER ROLE AdminRole ADD MEMBER AdminUser;
ALTER ROLE SalesPersonRole ADD MEMBER SalesPersonUser;
ALTER ROLE STFranceRole ADD MEMBER STFranceUser;
ALTER ROLE STNortheastRole ADD MEMBER STNortheastUser;

-- Grant Permissions to Users and Roles
GRANT VIEW DEFINITION, ALTER, CONTROL TO AdminRole;
GRANT ALL ON DATABASE::AdventureWorks TO AdminRole;

GRANT SELECT, INSERT, UPDATE, EXECUTE, DELETE ON SCHEMA::Sales TO SalesPersonRole;
GRANT SELECT, INSERT, UPDATE, EXECUTE, DELETE ON SCHEMA::Person TO SalesPersonRole;
GRANT SELECT, INSERT, UPDATE, EXECUTE, DELETE ON SCHEMA::Production TO SalesPersonRole;

GRANT SELECT ON Sales.vw_France_SalesDetails TO STFranceRole;
GRANT SELECT ON Sales.vw_RockyMountains_SalesDetails TO STNortheastRole;


-- SalesPersonUser
EXECUTE AS LOGIN = 'SalesPersonUserLogin';

-- Test for Sales.AddCurrency
EXEC Sales.sp_AddCurrency
  @CurrencyAlternateKey = 'TEST',
  @CurrencyName = 'Test Currency';

SELECT * FROM Sales.Currency
WHERE CurrencyAlternateKey = 'TEST';

-- Test for Sales.RemoveCurrency
DECLARE @CurrencyKeyToRemove INT;

SELECT @CurrencyKeyToRemove = CurrencyKey
FROM Sales.Currency
WHERE CurrencyAlternateKey = 'TEST';

EXEC Sales.sp_RemoveCurrency @CurrencyKey = @CurrencyKeyToRemove;

SELECT * FROM Sales.Currency
WHERE CurrencyAlternateKey = 'TEST';
-- End of Test for Sales.AddCurrency and Sales.RemoveCurrency

-- Test for Sales.AddSalesTerritory
EXEC Sales.sp_AddSalesTerritory
  @SalesTerritoryCountry = 'TestCountry',
  @SalesTerritoryRegion = 'TestRegion',
  @SalesTerritoryGroup = 'TestGroup';

SELECT * FROM Sales.SalesTerritory
WHERE SalesTerritoryCountry = 'TestCountry';

-- Test for Sales.RemoveSalesTerritory
DECLARE @SalesTerritoryKeyToRemove INT;

SELECT @SalesTerritoryKeyToRemove = SalesTerritoryKey
FROM Sales.SalesTerritory
WHERE SalesTerritoryCountry = 'TestCountry';

EXEC Sales.sp_RemoveSalesTerritory @SalesTerritoryKey = @SalesTerritoryKeyToRemove;

SELECT * FROM Sales.SalesTerritory
WHERE SalesTerritoryCountry = 'TestCountry';
-- End of Test for Sales.AddSalesTerritory and Sales.RemoveSalesTerritory

-- Test for Sales.AddAddress
EXEC Sales.sp_AddAddress
  @StateProvince = 'TestState',
  @CountryRegion = 'TestRegion',
  @City = 'TestCity',
  @AddressLine2 = 'TestAddressLine2',
  @AddressLine1 = 'TestAddressLine1',
  @PostalCode = 'TestPostalCode',
  @StateProvinceName = 'TestStateName',
  @CountryRegionName = 'TestRegionName',
  @SalesTerritoryKey = 1, -- Provide a valid SalesTerritoryKey
  @CustomerKey = 1; -- Provide a valid CustomerKey

SELECT * FROM Sales.Address
WHERE City = 'TestCity';

-- Test for Sales.RemoveAddress
DECLARE @AddressKeyToRemove INT;

SELECT @AddressKeyToRemove = AddressKey
FROM Sales.Address
WHERE City = 'TestCity';

EXEC Sales.sp_RemoveAddress @AddressKey = @AddressKeyToRemove;

SELECT * FROM Sales.Address
WHERE City = 'TestCity';
-- End of Test for Sales.AddAddress and Sales.RemoveAddress

-- Revert back to the original login
REVERT;

-- Repeat the process for Person schema
EXECUTE AS LOGIN = 'SalesPersonUserLogin';

-- Test for Person.AddCustomer
EXEC Person.sp_AddCustomer
  @LastName = 'TestLastName',
  @FirstName = 'TestFirstName',
  @MiddleName = 'TestMiddleName',
  @NameStyle = 'TestNameStyle',
  @BirthDate = '2022-01-01',
  @MaritalStatus = 'TestMaritalStatus',
  @Gender = 'TestGender',
  @EmailAddress = 'test@email.com',
  @YearlyIncome = 50000,
  @Title = 'Mr.',
  @TotalChildren = 2,
  @NumberChildrenAtHome = 1,
  @EducationLevel = 'TestEducationLevel',
  @Occupation = 'TestOccupation',
  @HouseOwnerFlag = 1,
  @NumberCarsOwned = 2,
  @Phone = '123-456-7890',
  @DateFirstPurchase = '2022-01-01',
  @CommuteDistance = 'TestCommuteDistance';

SELECT * FROM Person.Customer
WHERE LastName = 'TestLastName';

-- Test for Person.RemoveCustomer
DECLARE @CustomerKeyToRemove INT;

SELECT @CustomerKeyToRemove = CustomerKey
FROM Person.Customer
WHERE LastName = 'TestLastName';

EXEC Person.sp_RemoveCustomer @CustomerKey = @CustomerKeyToRemove;

SELECT * FROM Person.Customer
WHERE LastName = 'TestLastName';
-- End of Test for Person.AddCustomer and Person.RemoveCustomer

-- Revert back to the original login
REVERT;







-- STFranceUser
EXECUTE AS LOGIN = 'STFranceUserLogin';

SELECT * FROM Sales.vw_RockyMountains_SalesDetails;
SELECT * FROM Sales.vw_France_SalesDetails;
SELECT * FROM Sales.SalesOrderDetail;

REVERT;





-- STNortheastUser
EXECUTE AS LOGIN = 'STNortheastUserLogin';

SELECT * FROM Sales.vw_France_SalesDetails;
SELECT * FROM Sales.vw_RockyMountains_SalesDetails;
SELECT * FROM Sales.SalesOrderDetail;

REVERT;
