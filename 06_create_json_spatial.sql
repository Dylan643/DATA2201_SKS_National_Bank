/*
Course: DATA2201 – Relational Databases
Instructor: Michael Dorsey
Project: SKS National Bank – Phase 2

Group: J
Students:
- Dylan Retana (ID: 467710)
- Freddy Munini (ID: 473383)
- Ime Iquoho (ID: 460765)

File: 06_create_json_spatial.sql
Description: Adds a JSON column and a spatial column with sample data and test queries for Phase 2.
*/
GO

USE [SKS_National_Bank];
GO

------------------------------------------------------------
-- JSON Column (Customer.PreferencesJson)
------------------------------------------------------------
IF COL_LENGTH('dbo.Customer', 'PreferencesJson') IS NULL
BEGIN
    ALTER TABLE dbo.Customer
    ADD PreferencesJson NVARCHAR(MAX) NULL;
END
GO

-- Optional JSON validation check constraint (only if column exists and constraint not already created)
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Customer_PreferencesJson_IsJson')
BEGIN
    ALTER TABLE dbo.Customer
    ADD CONSTRAINT CK_Customer_PreferencesJson_IsJson
    CHECK (PreferencesJson IS NULL OR ISJSON(PreferencesJson) = 1);
END
GO

-- Populate JSON for a few customers
UPDATE dbo.Customer
SET PreferencesJson = N'{"paperlessStatements": true, "language": "en", "alerts": ["email","sms"]}'
WHERE Email = 'dylan.retana@example.com';

UPDATE dbo.Customer
SET PreferencesJson = N'{"paperlessStatements": false, "language": "en", "alerts": ["email"]}'
WHERE Email = 'aisha.patel@example.com';

UPDATE dbo.Customer
SET PreferencesJson = N'{"paperlessStatements": true, "language": "fr", "alerts": ["sms"]}'
WHERE Email = 'chloe.martin@example.com';
GO

------------------------------------------------------------
-- Spatial Column (Branch.GeoLocation)
------------------------------------------------------------
IF COL_LENGTH('dbo.Branch', 'GeoLocation') IS NULL
BEGIN
    ALTER TABLE dbo.Branch
    ADD GeoLocation GEOGRAPHY NULL;
END
GO

-- Populate sample locations using BranchName (safer than IDs)
UPDATE dbo.Branch
SET GeoLocation = geography::Point(51.0447, -114.0719, 4326)  -- Calgary (Downtown)
WHERE BranchName = 'Downtown HQ';

UPDATE dbo.Branch
SET GeoLocation = geography::Point(51.0735, -114.1230, 4326)  -- Calgary (North)
WHERE BranchName = 'North Hill';

UPDATE dbo.Branch
SET GeoLocation = geography::Point(53.5461, -113.4938, 4326)  -- Edmonton (Downtown)
WHERE BranchName = 'Riverbend';
GO

------------------------------------------------------------
-- Tests (run and screenshot results)
------------------------------------------------------------
PRINT '===== TEST: JSON column values =====';
SELECT TOP 10 CustomerID, FirstName, LastName, PreferencesJson
FROM dbo.Customer
WHERE PreferencesJson IS NOT NULL;
GO

PRINT '===== TEST: Spatial column values =====';
SELECT BranchID, BranchName, City, GeoLocation.STAsText() AS GeoLocationText
FROM dbo.Branch
WHERE GeoLocation IS NOT NULL;
GO
