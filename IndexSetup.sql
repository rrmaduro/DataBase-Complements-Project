/********************************************
 *	UC: Complementos de Bases de Dados 2023/2024
 *
 *	Turma: 2ºL_EI-SW-03 (15:00h - 17:00h)
 *		Nome Aluno: Ricardo Pinto (nº 202200637)
 *		Nome Aluno: Rodrigo Maduro (nº 202200166)
 *	    Nome Aluno: Rodrigo Arraiado (nº 202100436)
 *	
 *			Indexes
 *  
 ********************************************/


use [AdventureWorks]
go


-- Drop Index on [Sales].[Address]
DROP INDEX [_dta_index_Address_6_1077578877__K11_K2_K4] ON [Sales].[Address];
DROP STATISTICS [Sales].[Address].[_dta_stat_1077578877_2_4];

-- Drop Indexes on [Sales].[SalesOrderDetail]
DROP INDEX [_dta_index_SalesOrderDetail_6_1317579732__K2_4_13] ON [Sales].[SalesOrderDetail];
DROP INDEX [_dta_index_SalesOrderDetail_6_1317579732__K13] ON [Sales].[SalesOrderDetail];
DROP STATISTICS [Sales].[SalesOrderDetail].[_dta_stat_1317579732_13_2];


SET ANSI_PADDING ON

go

CREATE NONCLUSTERED INDEX [_dta_index_Address_6_1077578877__K11_K2_K4] ON [Sales].[Address]
(
	[CustomerKey] ASC,
	[StateProvince] ASC,
	[City] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [_dta_stat_1077578877_2_4] ON [Sales].[Address]([StateProvince], [City])
WITH AUTO_DROP = OFF
go

SET ANSI_PADDING ON

go

CREATE NONCLUSTERED INDEX [_dta_index_SalesOrderDetail_6_1317579732__K2_4_13] ON [Sales].[SalesOrderDetail]
(
	[SalesOrderNumber] ASC
)
INCLUDE([SalesAmount],[ProductKey]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_SalesOrderDetail_6_1317579732__K13] ON [Sales].[SalesOrderDetail]
(
	[ProductKey] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [_dta_stat_1317579732_13_2] ON [Sales].[SalesOrderDetail]([ProductKey], [SalesOrderNumber])
WITH AUTO_DROP = OFF
go



-- DROP para a primeira consulta
DROP INDEX IX_SalesOrderDetail_SalesOrderNumber ON Sales.SalesOrderDetail;
DROP INDEX IX_SalesOrderHeader_CustomerKey ON Sales.SalesOrderHeader;
DROP INDEX IX_Address_CustomerKey ON Sales.Address;
DROP INDEX IX_SalesOrderDetail_ProductKey ON Sales.SalesOrderDetail;
DROP INDEX IX_SalesOrderHeader_OrderDate ON Sales.SalesOrderHeader;
DROP INDEX IX_Product_ProductKey ON Production.Product;
DROP INDEX IX_Category_CategoryKey ON Production.Category;
DROP INDEX IX_SalesOrderDetail_ProductKey_Color ON Sales.SalesOrderDetail;
DROP INDEX IX_Product_Color ON Production.Product;


-- Índices para a primeira consulta (Pesquisa de vendas por cidade)
CREATE INDEX IX_SalesOrderDetail_SalesOrderNumber ON Sales.SalesOrderDetail (SalesOrderNumber);
CREATE INDEX IX_SalesOrderHeader_CustomerKey ON Sales.SalesOrderHeader (CustomerKey);
CREATE INDEX IX_Address_CustomerKey ON Sales.Address (CustomerKey);

-- Índices para a segunda consulta (Taxa de crescimento de vendas por ano e por categoria de produto)
CREATE INDEX IX_SalesOrderDetail_ProductKey ON Sales.SalesOrderDetail (ProductKey);
CREATE INDEX IX_SalesOrderHeader_OrderDate ON Sales.SalesOrderHeader (OrderDate);
CREATE INDEX IX_Product_ProductKey ON Production.Product (ProductKey);
CREATE INDEX IX_Category_CategoryKey ON Production.Category (CategoryKey);

-- Índices para a terceira consulta (Número de produtos nas vendas por cor)
CREATE INDEX IX_Product_Color ON Production.Product (Color);





--=============================================================================
--                              SELETIVIDADE
--=============================================================================

-- Seletividade para a tabela SalesOrderDetail
DECLARE cur_details CURSOR FOR
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SalesOrderDetail' AND TABLE_SCHEMA = 'Sales';

DECLARE @column_name VARCHAR(100)
DECLARE @sql VARCHAR(MAX)

IF OBJECT_ID('tempdb..#result', 'U') IS NOT NULL
    DROP TABLE #result;

CREATE TABLE #result(column_name VARCHAR(100), selectivity DECIMAL(5, 2))

OPEN cur_details
FETCH NEXT FROM cur_details INTO @column_name
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = 'INSERT INTO #result 
                SELECT ''' + @column_name + ''', CAST(COUNT(DISTINCT ' + @column_name + ') AS DECIMAL) / COUNT(*) 
                FROM [Sales].[SalesOrderDetail]';

    EXEC (@sql)

    FETCH NEXT FROM cur_details INTO @column_name
END
CLOSE cur_details
DEALLOCATE cur_details

-- Seletividade para a tabela SalesOrderHeader
DECLARE cur_header CURSOR FOR
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SalesOrderHeader' AND TABLE_SCHEMA = 'Sales';

OPEN cur_header
FETCH NEXT FROM cur_header INTO @column_name
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = 'INSERT INTO #result 
                SELECT ''' + @column_name + ''', CAST(COUNT(DISTINCT ' + @column_name + ') AS DECIMAL) / COUNT(*) 
                FROM [Sales].[SalesOrderHeader]';

    EXEC (@sql)

    FETCH NEXT FROM cur_header INTO @column_name
END
CLOSE cur_header
DEALLOCATE cur_header

-- Seletividade para a tabela Address
DECLARE cur_address CURSOR FOR
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Address' AND TABLE_SCHEMA = 'Sales';

OPEN cur_address
FETCH NEXT FROM cur_address INTO @column_name
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = 'INSERT INTO #result 
                SELECT ''' + @column_name + ''', CAST(COUNT(DISTINCT ' + @column_name + ') AS DECIMAL) / COUNT(*) 
                FROM [Sales].[Address]';

    EXEC (@sql)

    FETCH NEXT FROM cur_address INTO @column_name
END
CLOSE cur_address
DEALLOCATE cur_address

-- Seletividade para a tabela Product
DECLARE cur_product CURSOR FOR
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Product' AND TABLE_SCHEMA = 'Production';

OPEN cur_product
FETCH NEXT FROM cur_product INTO @column_name
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = 'INSERT INTO #result 
                SELECT ''' + @column_name + ''', CAST(COUNT(DISTINCT ' + @column_name + ') AS DECIMAL) / COUNT(*) 
                FROM [Production].[Product]';

    EXEC (@sql)

    FETCH NEXT FROM cur_product INTO @column_name
END
CLOSE cur_product
DEALLOCATE cur_product

-- Test
SELECT * FROM #result ORDER BY selectivity DESC;

