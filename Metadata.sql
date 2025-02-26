/********************************************
 *	UC: Complementos de Bases de Dados 2023/2024
 *
 *	Turma: 2ºL_EI-SW-03 (15:00h - 17:00h)
 *		Nome Aluno: Ricardo Pinto (nº 202200637)
 *		Nome Aluno: Rodrigo Maduro (nº 202200166)
 *	    Nome Aluno: Rodrigo Arraiado (nº 202100436)
 *	
 *			Metadata
 *  
 ********************************************/


-- Section: SchemaHistory

USE AdventureWorks;

-- Drop SchemaHistory table if it exists
DROP TABLE IF EXISTS SchemaHistory;

-- Create SchemaHistory table if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SchemaHistory')
BEGIN
    -- If the SchemaHistory table does not exist, create it
    CREATE TABLE SchemaHistory
    (
        ExecutionDateTime DATETIME,  -- Timestamp of execution
        TableName NVARCHAR(255),  -- Name of the table
        ColumnName NVARCHAR(255),  -- Name of the column
        DataType NVARCHAR(50),  -- Data type of the column
        DataSize INT,  -- Size of the data
        Constraints NVARCHAR(MAX)  -- Constraints on the column
    );
END;



-- Drop GenerateHistoryEntries procedure if it exists
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('GenerateHistoryEntries') AND type IN (N'P', N'PC'))
BEGIN
    DROP PROCEDURE GenerateHistoryEntries;
END;

-- Create GenerateHistoryEntries procedure
GO
CREATE PROCEDURE GenerateHistoryEntries
AS
BEGIN
    DECLARE @MaxExecutionDateTime DATETIME;

    -- Get the maximum ExecutionDateTime from SchemaHistory
    SELECT @MaxExecutionDateTime = COALESCE(MAX(ExecutionDateTime), '19000101') FROM SchemaHistory;

    -- Check for changes since the last execution
    IF EXISTS (
        SELECT 1
        FROM sys.tables t
        WHERE t.modify_date > @MaxExecutionDateTime
    )
    BEGIN
        -- Insert into history
        INSERT INTO SchemaHistory (ExecutionDateTime, TableName, ColumnName, DataType, DataSize, Constraints)
        SELECT 
            GETDATE(),  -- Current timestamp
            t.name AS TableName,
            c.name AS ColumnName,
            ty.name AS DataType,
            c.max_length AS DataSize,
            CASE 
                WHEN fk.name IS NOT NULL THEN 'Foreign Key (' + fk.name + ') ' + 'References ' + ref.name + '(' + rc.name + ') ' +
                'On ' + CASE fk.delete_referential_action 
                     WHEN 1 THEN 'Cascade'
                     WHEN 2 THEN 'Set Null'
                     WHEN 3 THEN 'Set Default'
                     ELSE 'No Action' END
                ELSE ''
            END AS Constraints
        FROM sys.tables t
        INNER JOIN sys.columns c ON t.object_id = c.object_id
        INNER JOIN sys.types ty ON c.system_type_id = ty.system_type_id
        LEFT JOIN sys.foreign_keys fk ON t.object_id = fk.parent_object_id
        LEFT JOIN sys.tables ref ON fk.referenced_object_id = ref.object_id
        LEFT JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
        LEFT JOIN sys.columns rc ON fkc.referenced_column_id = rc.column_id
        WHERE t.modify_date > @MaxExecutionDateTime;

        -- Update the maximum ExecutionDateTime for the next iteration
        SELECT @MaxExecutionDateTime = MAX(ExecutionDateTime) FROM SchemaHistory;
    END;
END;

-- Execute the stored procedure
EXEC GenerateHistoryEntries;


-- Drop the view if it exists
DROP VIEW IF EXISTS vw_LatestHistoriyData;
GO

-- Create a view to get the latest historical data
CREATE VIEW vw_LatestHistoriyData AS
SELECT TOP 1 * FROM SchemaHistory ORDER BY ExecutionDateTime DESC;
GO

-- Execute the stored procedure again
EXEC GenerateHistoryEntries;






-- Section: StatisticsTable

-- Drop StatisticsTable if it exists
DROP TABLE IF EXISTS StatisticsTable;

-- Create StatisticsTable if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'StatisticsTable')    
BEGIN         
    -- Create StatisticsTable with columns
    CREATE TABLE StatisticsTable (             
        StatisticsTableID INT PRIMARY KEY IDENTITY(1,1),
        TableName NVARCHAR(128),  -- Name of the table
        RecordCount INT,  -- Number of records in the table
        TotalSpaceOccupiedKB INT,  -- Total space occupied in kilobytes
        Timestamp DATETIME DEFAULT GETDATE()  -- Timestamp of the record
    );     
END;

-- Drop sp_StatisticsRegister procedure if it exists
IF OBJECT_ID('sp_StatisticsRegister', 'P') IS NOT NULL     
    DROP PROCEDURE sp_StatisticsRegister; 

-- Create sp_StatisticsRegister procedure
GO
CREATE PROCEDURE sp_StatisticsRegister 
AS 
BEGIN          
    -- Insert data into StatisticsTable
    INSERT INTO StatisticsTable (TableName, RecordCount, TotalSpaceOccupiedKB)     
    SELECT         
        T.TABLE_NAME,
        (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = T.TABLE_NAME),
        SUM(DATALENGTH(C.COLUMN_NAME)) AS TotalSpaceOccupiedKB  -- kilobytes   
    FROM INFORMATION_SCHEMA.TABLES T         
    LEFT JOIN INFORMATION_SCHEMA.COLUMNS C ON T.TABLE_NAME = C.TABLE_NAME     
    WHERE T.TABLE_TYPE = 'BASE TABLE'     
    GROUP BY T.TABLE_NAME; 
END;

-- Execute sp_StatisticsRegister procedure
EXEC sp_StatisticsRegister;






-- Section: Select Statements

-- Select data from SchemaHistory
SELECT * FROM SchemaHistory;

-- Select data from the view
SELECT * FROM vw_LatestHistoriyData;

-- Select data from StatisticsTable
SELECT * FROM StatisticsTable;
