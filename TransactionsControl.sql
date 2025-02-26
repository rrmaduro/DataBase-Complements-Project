/********************************************
 * UC: Complementos de Bases de Dados 2023/2024
 *
 * Turma: 2ºL_EI-SW-03 (15:00h - 17:00h)
 * Nome Aluno: Ricardo Pinto (nº 202200637)
 * Nome Aluno: Rodrigo Maduro (nº 202200166)
 * Nome Aluno: Rodrigo Arraiado (nº 202100436)
 * Transactions
 ********************************************/
	use AdventureWorks;
	go


	DROP PROCEDURE IF EXISTS AddProductToSale;
	go

CREATE PROCEDURE AddProductToSale
		@SalesOrderNumber VARCHAR(50),
		@ProductKey INT,
		@OrderQuantity TINYINT
	AS
	BEGIN
		-- Definir o nível de isolamento da transação
		SET TRANSACTION ISOLATION LEVEL READ COMMITED;

		BEGIN TRANSACTION;

		-- Verificar se a venda existe
		IF NOT EXISTS (SELECT 1 FROM Sales.SalesOrderHeader WHERE SalesOrderNumber = @SalesOrderNumber)
		BEGIN
			PRINT 'Venda não encontrada.';
			ROLLBACK;
			RETURN;
		END;

		IF NOT EXISTS (SELECT 1 FROM Production.Product WHERE ProductKey = @ProductKey)
		BEGIN
			PRINT 'Produto não encontrado.';
			ROLLBACK;
			RETURN;
		END;

		-- Verificar se o produto já existe na venda
		IF EXISTS (SELECT 1 FROM Sales.SalesOrderDetail WHERE SalesOrderNumber = @SalesOrderNumber AND ProductKey = @ProductKey)
		BEGIN
			UPDATE Sales.SalesOrderDetail
			SET OrderQuantity = OrderQuantity + @OrderQuantity,
				ExtendedAmount = (OrderQuantity + @OrderQuantity) * UnitPrice
			WHERE SalesOrderNumber = @SalesOrderNumber AND ProductKey = @ProductKey;
		END
		ELSE
		BEGIN
			-- Adicionar o produto à venda
			INSERT INTO Sales.SalesOrderDetail (SalesOrderNumber, ProductKey, OrderQuantity, UnitPrice, ExtendedAmount)
			VALUES (
				@SalesOrderNumber,
				@ProductKey,
				@OrderQuantity,
				(SELECT ListPrice FROM Production.Product WHERE ProductKey = @ProductKey),
				@OrderQuantity * (SELECT ListPrice FROM Production.Product WHERE ProductKey = @ProductKey)
			);
		END;
		WAITFOR DELAY '00:00:05';

		PRINT 'Produto adicionado/atualizado à venda com sucesso.';

		COMMIT;
	END;


	SELECT * FROM Sales.SalesOrderDetail

	EXEC AddProductToSale
		@SalesOrderNumber = 'SO45631',
		@ProductKey = 350,
		@OrderQuantity = 10;
GO



DROP PROCEDURE IF EXISTS UpdateProductPrice;
go
CREATE PROCEDURE UpdateProductPrice
    @ProductKey INT,
    @NewPrice FLOAT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM Production.Product WHERE ProductKey = @ProductKey)
    BEGIN
        PRINT 'Produto não encontrado.';
        ROLLBACK;
        RETURN;
    END;

    DECLARE @CurrentPrice FLOAT;
    SELECT @CurrentPrice = ListPrice
    FROM Production.Product
    WHERE ProductKey = @ProductKey;

    IF @CurrentPrice <> @NewPrice
    BEGIN
        UPDATE Production.Product
        SET ListPrice = @NewPrice
        WHERE ProductKey = @ProductKey;

        UPDATE Sales.SalesOrderDetail
        SET UnitPrice = @NewPrice, ExtendedAmount = OrderQuantity * @NewPrice
        WHERE ProductKey = @ProductKey
          AND SalesOrderNumber IN (SELECT SalesOrderNumber
                                   FROM Sales.SalesOrderHeader
                                   WHERE OrderDate IS NULL); 
    END;

    WAITFOR DELAY '00:00:05';

    PRINT 'Preço do produto atualizado com sucesso.';

    COMMIT;
END;


EXEC UpdateProductPrice
    @ProductKey = 1,
    @NewPrice = 150.00;

select * from Production.Product




	DROP PROCEDURE IF EXISTS CalculateTotalSalesCurrentYear;
	go


CREATE PROCEDURE CalculateTotalSalesCurrentYear
	AS
	BEGIN
		SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

		-- Iniciar a transação
		BEGIN TRANSACTION;

		-- Variável para armazenar o ano corrente
		DECLARE @CurrentYear INT;
		SET @CurrentYear = YEAR(GETDATE());

		-- Variável para armazenar o total de vendas
		DECLARE @TotalSales DECIMAL(18, 2);

		-- Calcular o total das vendas para o ano corrente
		SELECT @TotalSales = ISNULL(SUM(sod.SalesAmount), 0)
		FROM Sales.SalesOrderDetail sod
		JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderNumber = soh.SalesOrderNumber
		WHERE YEAR(soh.OrderDate) = @CurrentYear;

		-- Aguardar para simular processamento (pode ser removido num ambiente real)
		WAITFOR DELAY '00:00:10';

		-- Exibir o resultado
		PRINT 'Total de Vendas no Ano Corrente (' + CAST(@CurrentYear AS VARCHAR) + '): ' + CAST(@TotalSales AS VARCHAR);

		-- Commit da transação
		COMMIT;
	END;


	EXEC CalculateTotalSalesCurrentYear