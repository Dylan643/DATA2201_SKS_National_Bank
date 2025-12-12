/*
Course: DATA2201 – Relational Databases
Instructor: Michael Dorsey
Project: SKS National Bank – Phase 2

Group: J
Students:
- Dylan Retana (ID: 467710)
- Freddy Munini (ID: 473383)
- Ime Iquoho (ID: 460765)

File: 07_additional_validation_tests.sql
Description: Optional validation queries to further verify ERD relationships,
JSON data, spatial data, and audit logging.
*/

USE SKS_National_Bank;
GO

------------------------------------------------------------
-- 1) Validate Customer ? Account relationships
------------------------------------------------------------
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    a.AccountID,
    a.AccountType,
    a.Balance
FROM dbo.Customer c
JOIN dbo.CustomerAccount ca ON c.CustomerID = ca.CustomerID
JOIN dbo.Account a ON ca.AccountID = a.AccountID
ORDER BY c.CustomerID;
GO

------------------------------------------------------------
-- 2) Validate Loan ? Payment relationships
------------------------------------------------------------
SELECT 
    l.LoanID,
    l.LoanAmount,
    lp.PaymentNo,
    lp.PaymentDate,
    lp.PaymentAmount
FROM dbo.Loan l
JOIN dbo.LoanPayment lp ON l.LoanID = lp.LoanID
ORDER BY l.LoanID, lp.PaymentNo;
GO

------------------------------------------------------------
-- 3) Validate JSON data using SQL Server JSON functions
------------------------------------------------------------
SELECT
    CustomerID,
    FirstName,
    LastName,
    JSON_VALUE(PreferencesJson, '$.language') AS PreferredLanguage,
    JSON_VALUE(PreferencesJson, '$.paperlessStatements') AS PaperlessStatements
FROM dbo.Customer
WHERE PreferencesJson IS NOT NULL;
GO

------------------------------------------------------------
-- 4) Validate spatial data (distance between branches)
------------------------------------------------------------
SELECT 
    b1.BranchName AS BranchA,
    b2.BranchName AS BranchB,
    b1.GeoLocation.STDistance(b2.GeoLocation) AS DistanceInMeters
FROM dbo.Branch b1
JOIN dbo.Branch b2 
    ON b1.BranchID < b2.BranchID;
GO

------------------------------------------------------------
-- 5) Review recent audit activity (trigger validation)
------------------------------------------------------------
SELECT TOP 10 *
FROM dbo.Audit
ORDER BY EventTime DESC;
GO
