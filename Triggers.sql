/********************************************
 *	UC: Complementos de Bases de Dados 2023/2024
 *
 *	Turma: 2ºL_EI-SW-03 (15:00h - 17:00h)
 *		Nome Aluno: Ricardo Pinto (nº 202200637)
 *		Nome Aluno: Rodrigo Maduro (nº 202200166)
 *	    Nome Aluno: Rodrigo Arraiado (nº 202100436)
 *	
 *			Database
 ********************************************/
 -- Section: Database Initialization
USE AdventureWorks;

-- Drop the existing view, function, and trigger
DROP VIEW IF EXISTS getNumber;
DROP FUNCTION IF EXISTS dbo.GenerateRandomPassword;
DROP TRIGGER IF EXISTS GenerateLoggin;
GO

-- Create a view to generate a random number between 0 and 1
CREATE VIEW getNumber AS 
SELECT CAST(RAND() * 1000000 AS INT) AS new_number;
GO

-- Create the function to generate a password
CREATE FUNCTION dbo.GenerateRandomPassword()
RETURNS INT
AS
BEGIN
    DECLARE @password INT;

    -- Retrieve the random number from the view
    SET @password = (
        SELECT new_number
        FROM getNumber
    );

    SET @password = @password * 2;

    RETURN @password;
END;
GO


CREATE TRIGGER GenerateLoggin
ON Person.Customer
AFTER INSERT
AS
BEGIN
    -- Disable the row count
    SET NOCOUNT ON;    

    -- Insert into Customer table
    UPDATE c
    SET
        CustomerPassword = CONVERT(VARCHAR(64), HashBytes('SHA2_256', CONVERT(VARBINARY(MAX), dbo.GenerateRandomPassword())), 2),
        SecurityQuestion = 'How many children do you have?',
        SecurityAnswer = CONVERT(VARCHAR(64), HashBytes('SHA2_256', CONVERT(VARBINARY(MAX), i.NumberChildrenAtHome)), 2)
    FROM Person.Customer c
    INNER JOIN inserted i ON c.CustomerKey = i.CustomerKey;

    -- Insert into sentEmails table
    INSERT INTO Logs.SentEmails (recipientEmail, emailMessage, EmailTime)
    SELECT
        EmailAddress,
        'Hello. We sent this email to inform you that a new login access has been created with this email. Your corresponding password is ' + CAST(dbo.GenerateRandomPassword() AS NVARCHAR(200)),
        GETDATE()
    FROM inserted;
END;
GO

select * from Person.Customer




-- Drop the stored procedure if it exists
IF OBJECT_ID('dbo.RecoverPassword', 'P') IS NOT NULL
    DROP PROCEDURE dbo.RecoverPassword;
GO

-- Section: Password Recovery
CREATE PROCEDURE dbo.RecoverPassword
    @EmailAddress NVARCHAR(255),
    @SecurityQuestion NVARCHAR(255),
    @SecurityAnswer NVARCHAR(255)
AS
BEGIN
    DECLARE @RecoveredPassword NVARCHAR(255);

    -- Check security question and answer in the Customer table
    IF EXISTS (
        SELECT 1
        FROM Person.Customer c
        WHERE c.EmailAddress = @EmailAddress
        AND c.SecurityQuestion = @SecurityQuestion
        AND c.SecurityAnswer = @SecurityAnswer
    )
    BEGIN
        -- Generate a new password
        SET @RecoveredPassword = CAST(dbo.GenerateRandomPassword() AS NVARCHAR(255));

        -- Update the password in the Customer table
        UPDATE Person.Customer
        SET CustomerPassword = @RecoveredPassword
        WHERE EmailAddress = @EmailAddress;

        -- Logic to send recovery email
        INSERT INTO Logs.SentEmails (recipientEmail, emailMessage, EmailTime)
        SELECT
            @EmailAddress,
            'Hello. We sent this email to inform you that you requested password recovery. Your new password is ' + @RecoveredPassword,
            GETDATE();

        PRINT 'Recovery email sent successfully.';
    END
    ELSE
    BEGIN
        PRINT 'There was an error.';
    END;
END;
GO

select * from Person.Customer

-- Test Query
SELECT TOP 1 CustomerPassword
FROM Person.Customer
WHERE CustomerKey = (
    SELECT CustomerKey
    FROM Person.Customer
    WHERE EmailAddress = 'cristina4@adventure-works.com'
)
ORDER BY CustomerKey DESC;

SELECT * FROM Person.Customer WHERE EmailAddress='cristina4@adventure-works.com';

-- Test Procedure Execution
EXEC dbo.RecoverPassword 'cristina4@adventure-works.com', 'How many children do you have?', '0';

-- Select the latest sent email and order by time
SELECT TOP 1 *
FROM logs.SentEmails
ORDER BY EmailTime DESC;


