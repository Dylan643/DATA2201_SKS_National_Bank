/*
Course: DATA2201 – Relational Databases
Instructor: Michael Dorsey
Project: SKS National Bank – Phase 2

Group: J
Students:
- Dylan Retana (ID: 467710)
- Freddy Munini (ID: 473383)
- Ime Iquoho (ID: 460765)

File: 05_create_triggers.sql
Description: Creates an Audit table and three triggers with test statements for Phase 2.
*/
GO

USE [SKS_National_Bank];
GO

------------------------------------------------------------
-- Audit table
------------------------------------------------------------
IF OBJECT_ID('dbo.Audit', 'U') IS NOT NULL
    DROP TABLE dbo.Audit;
GO

CREATE TABLE dbo.Audit
(
    AuditID     INT IDENTITY(1,1) PRIMARY KEY,
    EventTime   DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    TableName   SYSNAME         NOT NULL,
    ActionType  VARCHAR(10)     NOT NULL,
    Details     NVARCHAR(4000)  NOT NULL
);
GO

------------------------------------------------------------
-- Trigger #1: Account INSERT/UPDATE
------------------------------------------------------------
IF OBJECT_ID('dbo.trg_Account_Audit', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Account_Audit;
GO

CREATE TRIGGER dbo.trg_Account_Audit
ON dbo.Account
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Audit (TableName, ActionType, Details)
    SELECT
        'Account',
        CASE 
            WHEN d.AccountID IS NULL THEN 'INSERT' 
            ELSE 'UPDATE' 
        END,
        CONCAT('AccountID=', i.AccountID,
               '; BranchID=', i.BranchID,
               '; Type=', i.AccountType,
               '; Balance=', i.Balance,
               '; OpenedDate=', CONVERT(VARCHAR(10), i.OpenedDate, 120))
    FROM inserted i
    LEFT JOIN deleted d ON d.AccountID = i.AccountID;
END;
GO

------------------------------------------------------------
-- Trigger #2: LoanPayment INSERT
------------------------------------------------------------
IF OBJECT_ID('dbo.trg_LoanPayment_Audit', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_LoanPayment_Audit;
GO

CREATE TRIGGER dbo.trg_LoanPayment_Audit
ON dbo.LoanPayment
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Audit (TableName, ActionType, Details)
    SELECT
        'LoanPayment',
        'INSERT',
        CONCAT('LoanID=', i.LoanID,
               '; PaymentNo=', i.PaymentNo,
               '; PaymentDate=', CONVERT(VARCHAR(10), i.PaymentDate, 120),
               '; Amount=', i.PaymentAmount)
    FROM inserted i;
END;
GO

------------------------------------------------------------
-- Trigger #3: Customer UPDATE
------------------------------------------------------------
IF OBJECT_ID('dbo.trg_Customer_Audit', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Customer_Audit;
GO

CREATE TRIGGER dbo.trg_Customer_Audit
ON dbo.Customer
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Audit (TableName, ActionType, Details)
    SELECT
        'Customer',
        'UPDATE',
        CONCAT('CustomerID=', i.CustomerID,
               '; Name=', i.FirstName, ' ', i.LastName,
               '; OldEmail=', COALESCE(d.Email,'(NULL)'),
               '; NewEmail=', COALESCE(i.Email,'(NULL)'))
    FROM inserted i
    INNER JOIN deleted d ON d.CustomerID = i.CustomerID;
END;
GO

------------------------------------------------------------
-- Tests (run and screenshot results)
------------------------------------------------------------
PRINT '===== TEST: Update a Customer email (should write to dbo.Audit) =====';
DECLARE @custId INT = (SELECT TOP 1 CustomerID FROM dbo.Customer ORDER BY CustomerID);
UPDATE dbo.Customer
SET Email = CONCAT('audit_test_', @custId, '@example.com')
WHERE CustomerID = @custId;
GO

PRINT '===== TEST: Insert a LoanPayment (should write to dbo.Audit) =====';
DECLARE @loanId BIGINT = (SELECT TOP 1 LoanID FROM dbo.Loan ORDER BY LoanID);
IF @loanId IS NOT NULL
BEGIN
    DECLARE @nextPayNo INT = ISNULL((SELECT MAX(PaymentNo) FROM dbo.LoanPayment WHERE LoanID=@loanId), 0) + 1;
    INSERT INTO dbo.LoanPayment (LoanID, PaymentNo, PaymentDate, PaymentAmount)
    VALUES (@loanId, @nextPayNo, CAST(GETDATE() AS DATE), 50.00);
END
GO

PRINT '===== VIEW AUDIT ROWS =====';
SELECT TOP 50 * FROM dbo.Audit ORDER BY AuditID DESC;
GO
