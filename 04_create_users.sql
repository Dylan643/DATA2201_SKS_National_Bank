/*
Course: DATA2201 – Relational Databases
Instructor: Michael Dorsey
Project: SKS National Bank – Phase 2

Group: J
Students:
- Dylan Retana (ID: 467710)
- Freddy Munini (ID: 473383)
- Ime Iquoho (ID: 460765)

File: 04_create_users.sql
Description: Creates logins/users and applies permissions with test queries for Phase 2.
*/
GO

USE master;
GO
-- Create logins (server-level). If they already exist, skip.
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'customer_group_J')
    CREATE LOGIN customer_group_J WITH PASSWORD = 'customer', CHECK_POLICY = OFF;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'accountant_group_J')
    CREATE LOGIN accountant_group_J WITH PASSWORD = 'accountant', CHECK_POLICY = OFF;
GO

USE [SKS_National_Bank];
GO

-- Create database users (db-level)
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'customer_group_J')
    CREATE USER customer_group_J FOR LOGIN customer_group_J;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'accountant_group_J')
    CREATE USER accountant_group_J FOR LOGIN accountant_group_J;
GO

------------------------------------------------------------
-- Permissions
------------------------------------------------------------

-- CUSTOMER USER: read-only on customer-facing tables
GRANT SELECT ON dbo.Customer TO customer_group_J;
GRANT SELECT ON dbo.Account TO customer_group_J;
GRANT SELECT ON dbo.CustomerAccount TO customer_group_J;
GRANT SELECT ON dbo.Overdraft TO customer_group_J;
GRANT SELECT ON dbo.Loan TO customer_group_J;
GRANT SELECT ON dbo.CustomerLoan TO customer_group_J;
GRANT SELECT ON dbo.LoanPayment TO customer_group_J;
GRANT SELECT ON dbo.Branch TO customer_group_J;
GO

-- ACCOUNTANT USER:
-- 1) Read access to everything
GRANT SELECT ON dbo.Branch TO accountant_group_J;
GRANT SELECT ON dbo.Location TO accountant_group_J;
GRANT SELECT ON dbo.Employee TO accountant_group_J;
GRANT SELECT ON dbo.EmployeeLocation TO accountant_group_J;
GRANT SELECT ON dbo.Customer TO accountant_group_J;
GRANT SELECT ON dbo.Account TO accountant_group_J;
GRANT SELECT ON dbo.CustomerAccount TO accountant_group_J;
GRANT SELECT ON dbo.Overdraft TO accountant_group_J;
GRANT SELECT ON dbo.Loan TO accountant_group_J;
GRANT SELECT ON dbo.CustomerLoan TO accountant_group_J;
GRANT SELECT ON dbo.LoanPayment TO accountant_group_J;
GRANT SELECT ON dbo.CustomerAssignedStaff TO accountant_group_J;
GO

-- 2) Deny/Remove INSERT/UPDATE/DELETE on account/payment/loan related tables
DENY INSERT, UPDATE, DELETE ON dbo.Account TO accountant_group_J;
DENY INSERT, UPDATE, DELETE ON dbo.CustomerAccount TO accountant_group_J;
DENY INSERT, UPDATE, DELETE ON dbo.Overdraft TO accountant_group_J;
DENY INSERT, UPDATE, DELETE ON dbo.Loan TO accountant_group_J;
DENY INSERT, UPDATE, DELETE ON dbo.CustomerLoan TO accountant_group_J;
DENY INSERT, UPDATE, DELETE ON dbo.LoanPayment TO accountant_group_J;
GO

------------------------------------------------------------
-- Permission tests (run and screenshot results)
------------------------------------------------------------

PRINT '===== TEST: customer_group_J should be able to SELECT Customer, Account =====';
EXECUTE AS USER = 'customer_group_J';
SELECT TOP 5 * FROM dbo.Customer;
SELECT TOP 5 * FROM dbo.Account;
REVERT;
GO

PRINT '===== TEST: customer_group_J should NOT be able to INSERT into Account =====';
BEGIN TRY
    EXECUTE AS USER = 'customer_group_J';
    INSERT INTO dbo.Account (BranchID, AccountType, Balance, LastAccessDate, InterestRate, OpenedDate)
    VALUES (1,'C',10.00,NULL,NULL,CAST(GETDATE() AS DATE));
    REVERT;
END TRY
BEGIN CATCH
    REVERT;
    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT '===== TEST: accountant_group_J can SELECT everything =====';
EXECUTE AS USER = 'accountant_group_J';
SELECT TOP 5 * FROM dbo.LoanPayment;
REVERT;
GO

PRINT '===== TEST: accountant_group_J should NOT be able to UPDATE LoanPayment =====';
BEGIN TRY
    EXECUTE AS USER = 'accountant_group_J';
    UPDATE dbo.LoanPayment SET PaymentAmount = PaymentAmount WHERE 1=0; -- harmless statement
    REVERT;
END TRY
BEGIN CATCH
    REVERT;
    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO
