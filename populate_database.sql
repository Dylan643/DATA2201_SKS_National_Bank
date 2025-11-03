-- DATA2201 – Relational Databases
-- Group Project Phase 1: SKS National Bank
-- File: create_database.sql
-- Submitted by: Dylan Retana (ID: 467710), Freddy Munini (473383), Ime Iquoho (460765)
-- Bow Valley College

-- What this script does (short):This script populates all tables in the SKS_National_Bank database with realistic sample data, 
-- and verifies referential integrity by checking table counts and relationships for valid foreign key links.

-- Inserts sample data for each table (≥5 rows where possible) to test our queries.

USE SKS_National_Bank;
GO

SET NOCOUNT ON;

-- =====================================================================
-- CLEANUP SECTION
-- =====================================================================
DELETE FROM dbo.CustomerAssignedStaff;
DELETE FROM dbo.LoanPayment;
DELETE FROM dbo.CustomerLoan;
DELETE FROM dbo.Loan;
DELETE FROM dbo.Overdraft;
DELETE FROM dbo.CustomerAccount;
DELETE FROM dbo.Account;
DELETE FROM dbo.Customer;
DELETE FROM dbo.EmployeeLocation;
DELETE FROM dbo.Employee;
DELETE FROM dbo.Location;
DELETE FROM dbo.Branch;

-- =====================================================================
-- 1) BRANCH
-- =====================================================================
INSERT INTO dbo.Branch (BranchName, City, TotalDeposits, TotalLoans)
SELECT 'Downtown HQ','Calgary',2500000,1800000
WHERE NOT EXISTS (SELECT 1 FROM dbo.Branch WHERE BranchName='Downtown HQ');

INSERT INTO dbo.Branch (BranchName, City, TotalDeposits, TotalLoans)
SELECT 'North Hill','Calgary',1400000,900000
WHERE NOT EXISTS (SELECT 1 FROM dbo.Branch WHERE BranchName='North Hill');

INSERT INTO dbo.Branch (BranchName, City, TotalDeposits, TotalLoans)
SELECT 'Riverbend','Edmonton',1200000,1100000
WHERE NOT EXISTS (SELECT 1 FROM dbo.Branch WHERE BranchName='Riverbend');

-- Store branch IDs
DECLARE 
    @B_DTHQ INT = (SELECT BranchID FROM dbo.Branch WHERE BranchName='Downtown HQ'),
    @B_NH   INT = (SELECT BranchID FROM dbo.Branch WHERE BranchName='North Hill'),
    @B_RB   INT = (SELECT BranchID FROM dbo.Branch WHERE BranchName='Riverbend');

-- =====================================================================
-- 2) LOCATION
-- =====================================================================
INSERT INTO dbo.Location (AddressLine1, City, ProvinceState, PostalCode, LocationType, BranchID)
SELECT '100 Main St','Calgary','AB','T1A 1A1','B',@B_DTHQ
WHERE NOT EXISTS (SELECT 1 FROM dbo.Location WHERE AddressLine1='100 Main St');

INSERT INTO dbo.Location (AddressLine1, City, ProvinceState, PostalCode, LocationType, BranchID)
SELECT '200 North Rd','Calgary','AB','T2B 2B2','B',@B_NH
WHERE NOT EXISTS (SELECT 1 FROM dbo.Location WHERE AddressLine1='200 North Rd');

INSERT INTO dbo.Location (AddressLine1, City, ProvinceState, PostalCode, LocationType, BranchID)
SELECT '300 River Ave','Edmonton','AB','T3C 3C3','B',@B_RB
WHERE NOT EXISTS (SELECT 1 FROM dbo.Location WHERE AddressLine1='300 River Ave');

INSERT INTO dbo.Location (AddressLine1, City, ProvinceState, PostalCode, LocationType, BranchID)
VALUES 
('400 Corporate Plaza','Calgary','AB','T4D 4D4','O',NULL),
('500 Service Center','Edmonton','AB','T5E 5E5','O',NULL);

-- =====================================================================
-- 3) EMPLOYEE
-- =====================================================================
INSERT INTO dbo.Employee (FirstName, LastName, HomeAddress, StartDate, Role, ManagerID)
VALUES ('Morgan','Lee','10 Aspen Way, Calgary, AB','2018-01-15','Mgr',NULL);

DECLARE @MgrID INT = (SELECT EmployeeID FROM dbo.Employee WHERE FirstName='Morgan' AND LastName='Lee');

INSERT INTO dbo.Employee (FirstName, LastName, HomeAddress, StartDate, Role, ManagerID)
VALUES 
('Ava','Ng','22 Oak Dr, Calgary, AB','2019-03-10','PersonalBanker',@MgrID),
('Noah','Singh','35 Pine St, Calgary, AB','2020-06-01','LoanOfficer',@MgrID),
('Ethan','Rao','48 Birch Rd, Edmonton, AB','2021-09-20','Teller',@MgrID),
('Mia','Zhang','59 Maple Ln, Calgary, AB','2022-02-05','Teller',@MgrID),
('Liam','Khan','61 Cedar Ct, Edmonton, AB','2020-11-11','PersonalBanker',@MgrID),
('Emma','Gomez','72 Willow Pl, Calgary, AB','2023-04-07','LoanOfficer',@MgrID),
('Lucas','Brown','83 Spruce Gr, Calgary, AB','2019-12-18','PersonalBanker',@MgrID);

-- =====================================================================
-- 4) EMPLOYEELOCATION
-- =====================================================================
INSERT INTO dbo.EmployeeLocation (EmployeeID, LocationID, AssignedSince)
SELECT e.EmployeeID, l.LocationID, '2022-01-01'
FROM dbo.Employee e
JOIN dbo.Location l ON l.BranchID=@B_DTHQ
WHERE e.FirstName='Ava';

INSERT INTO dbo.EmployeeLocation (EmployeeID, LocationID, AssignedSince)
SELECT e.EmployeeID, l.LocationID, '2022-01-01'
FROM dbo.Employee e
JOIN dbo.Location l ON l.BranchID=@B_NH
WHERE e.FirstName='Noah';

-- =====================================================================
-- 5) CUSTOMER
-- =====================================================================
INSERT INTO dbo.Customer (FirstName, LastName, HomeAddress, Email, Phone) VALUES
('Dylan','Retana','11 Elm St, Calgary, AB','dylan.retana@example.com','403-100-1000'),
('Aisha','Patel','12 Elm St, Calgary, AB','aisha.patel@example.com','403-100-1001'),
('Bruno','Costa','13 Elm St, Edmonton, AB','bruno.costa@example.com','780-100-1002'),
('Chloe','Martin','14 Elm St, Calgary, AB','chloe.martin@example.com','403-100-1003'),
('Diego','Lopez','15 Elm St, Edmonton, AB','diego.lopez@example.com','780-100-1004'),
('Eva','Chen','16 Elm St, Calgary, AB','eva.chen@example.com','403-100-1005'),
('Farah','Hassan','17 Elm St, Edmonton, AB','farah.hassan@example.com','780-100-1006'),
('Gabe','Nguyen','18 Elm St, Calgary, AB','gabe.nguyen@example.com','403-100-1007'),
('Hana','Kim','19 Elm St, Calgary, AB','hana.kim@example.com','403-100-1008'),
('Ivan','Kovacs','20 Elm St, Edmonton, AB','ivan.kovacs@example.com','780-100-1009');

-- Rehydrate all customer IDs
DECLARE 
    @cDylan INT = (SELECT CustomerID FROM dbo.Customer WHERE Email='dylan.retana@example.com'),
    @cAisha INT = (SELECT CustomerID FROM dbo.Customer WHERE Email='aisha.patel@example.com'),
    @cBruno INT = (SELECT CustomerID FROM dbo.Customer WHERE Email='bruno.costa@example.com'),
    @cChloe INT = (SELECT CustomerID FROM dbo.Customer WHERE Email='chloe.martin@example.com'),
    @cDiego INT = (SELECT CustomerID FROM dbo.Customer WHERE Email='diego.lopez@example.com'),
    @cEva   INT = (SELECT CustomerID FROM dbo.Customer WHERE Email='eva.chen@example.com'),
    @cFarah INT = (SELECT CustomerID FROM dbo.Customer WHERE Email='farah.hassan@example.com'),
    @cGabe  INT = (SELECT CustomerID FROM dbo.Customer WHERE Email='gabe.nguyen@example.com'),
    @cHana  INT = (SELECT CustomerID FROM dbo.Customer WHERE Email='hana.kim@example.com'),
    @cIvan  INT = (SELECT CustomerID FROM dbo.Customer WHERE Email='ivan.kovacs@example.com');

-- =====================================================================
-- 6) ACCOUNT
-- =====================================================================
DECLARE @NewAccounts TABLE (AccountID BIGINT, Label VARCHAR(50));

INSERT INTO dbo.Account (BranchID, AccountType, Balance, LastAccessDate, InterestRate, OpenedDate)
OUTPUT inserted.AccountID, 'Dylan_C' INTO @NewAccounts(AccountID, Label)
VALUES (@B_DTHQ,'C',1200.00,'2025-09-10',NULL,'2024-03-01'),
       (@B_DTHQ,'S',3500.00,'2025-09-20',1.25,'2024-03-01'),
       (@B_DTHQ,'C',800.00,'2025-09-12',NULL,'2024-04-10'),
       (@B_NH,'S',6400.00,'2025-09-22',1.15,'2024-05-15'),
       (@B_NH,'C',950.00,'2025-09-25',NULL,'2024-05-15'),
       (@B_NH,'C',400.00,'2025-09-18',NULL,'2024-06-01'),
       (@B_RB,'C',2200.00,'2025-09-05',NULL,'2024-04-21'),
       (@B_RB,'S',5000.00,'2025-09-15',1.05,'2024-07-03'),
       (@B_RB,'C',300.00,'2025-09-09',NULL,'2024-08-12'),
       (@B_DTHQ,'S',7200.00,'2025-09-21',1.30,'2024-02-05'),
       (@B_NH,'C',150.00,'2025-09-08',NULL,'2024-09-10'),
       (@B_RB,'S',9100.00,'2025-09-26',1.40,'2024-01-29');

-- =====================================================================
-- 7) CUSTOMERACCOUNT
-- =====================================================================
INSERT INTO dbo.CustomerAccount (CustomerID, AccountID, OwnershipPercent)
SELECT TOP 1 @cDylan, a.AccountID, 100 FROM dbo.Account a WHERE a.BranchID=@B_DTHQ AND a.AccountType='C'
UNION ALL
SELECT TOP 1 @cDylan, a.AccountID, 100 FROM dbo.Account a WHERE a.BranchID=@B_DTHQ AND a.AccountType='S'
UNION ALL
SELECT TOP 1 @cAisha, a.AccountID, 100 FROM dbo.Account a WHERE a.BranchID=@B_DTHQ AND a.Balance=800.00
UNION ALL
SELECT TOP 1 @cChloe, a.AccountID, 100 FROM dbo.Account a WHERE a.BranchID=@B_NH AND a.AccountType='S'
UNION ALL
SELECT TOP 1 @cChloe, a.AccountID, 100 FROM dbo.Account a WHERE a.BranchID=@B_NH AND a.AccountType='C'
UNION ALL
SELECT TOP 1 @cEva, a.AccountID, 100 FROM dbo.Account a WHERE a.Balance=400.00
UNION ALL
SELECT TOP 1 @cBruno, a.AccountID, 100 FROM dbo.Account a WHERE a.Balance=2200.00
UNION ALL
SELECT TOP 1 @cDiego, a.AccountID, 100 FROM dbo.Account a WHERE a.AccountType='S' AND a.BranchID=@B_RB
UNION ALL
SELECT TOP 1 @cFarah, a.AccountID, 100 FROM dbo.Account a WHERE a.Balance=300.00
UNION ALL
SELECT TOP 1 @cGabe, a.AccountID, 100 FROM dbo.Account a WHERE a.Balance=7200.00
UNION ALL
SELECT TOP 1 @cHana, a.AccountID, 100 FROM dbo.Account a WHERE a.Balance=150.00
UNION ALL
SELECT TOP 1 @cIvan, a.AccountID, 100 FROM dbo.Account a WHERE a.Balance=9100.00;

-- =====================================================================
-- 8) OVERDRAFT
-- =====================================================================
INSERT INTO dbo.Overdraft (AccountID, OverdraftDate, Amount, CheckNumber)
SELECT TOP 1 a.AccountID,'2025-09-01',75.00,'100201' FROM dbo.Account a WHERE a.Balance=1200.00
UNION ALL
SELECT TOP 1 a.AccountID,'2025-09-03',125.00,'100305' FROM dbo.Account a WHERE a.Balance=800.00
UNION ALL
SELECT TOP 1 a.AccountID,'2025-09-07',40.00,'100412' FROM dbo.Account a WHERE a.Balance=950.00
UNION ALL
SELECT TOP 1 a.AccountID,'2025-09-11',22.50,'100518' FROM dbo.Account a WHERE a.Balance=150.00;

-- =====================================================================
-- 9) LOAN + CUSTOMERLOAN
-- =====================================================================
DECLARE @Loans TABLE (LoanID BIGINT, Label VARCHAR(50));

INSERT INTO dbo.Loan (BranchID, LoanAmount, StartDate, Status)
OUTPUT inserted.LoanID, 'L_Dylan' INTO @Loans(LoanID, Label)
VALUES (@B_DTHQ,15000.00,'2024-06-01','Active'),
       (@B_DTHQ,12000.00,'2024-07-10','Active'),
       (@B_RB,18000.00,'2024-08-20','Active'),
       (@B_NH,22000.00,'2024-09-15','Active'),
       (@B_RB,9000.00,'2024-05-05','Closed'),
       (@B_NH,25000.00,'2024-03-25','Active');

INSERT INTO dbo.CustomerLoan (CustomerID,LoanID,Role)
SELECT @cDylan,LoanID,'Primary' FROM @Loans WHERE Label='L_Dylan'
UNION ALL SELECT @cAisha,LoanID,'Primary' FROM @Loans WHERE Label='L_Aisha'
UNION ALL SELECT @cBruno,LoanID,'Primary' FROM @Loans WHERE Label='L_Bruno'
UNION ALL SELECT @cChloe,LoanID,'Primary' FROM @Loans WHERE Label='L_Chloe'
UNION ALL SELECT @cDiego,LoanID,'Primary' FROM @Loans WHERE Label='L_Diego'
UNION ALL SELECT @cEva,LoanID,'Primary' FROM @Loans WHERE Label='L_Eva';

INSERT INTO dbo.CustomerLoan (CustomerID,LoanID,Role)
SELECT @cAisha,LoanID,'CoBorrower' FROM @Loans WHERE Label='L_Dylan';

-- =====================================================================
-- 10) CUSTOMERASSIGNEDSTAFF
-- =====================================================================
-- Reuse previously declared customer variables
SET @cDylan = (SELECT CustomerID FROM dbo.Customer WHERE Email='dylan.retana@example.com');
SET @cAisha = (SELECT CustomerID FROM dbo.Customer WHERE Email='aisha.patel@example.com');
SET @cBruno = (SELECT CustomerID FROM dbo.Customer WHERE Email='bruno.costa@example.com');
SET @cChloe = (SELECT CustomerID FROM dbo.Customer WHERE Email='chloe.martin@example.com');
SET @cDiego = (SELECT CustomerID FROM dbo.Customer WHERE Email='diego.lopez@example.com');
SET @cEva   = (SELECT CustomerID FROM dbo.Customer WHERE Email='eva.chen@example.com');
SET @cFarah = (SELECT CustomerID FROM dbo.Customer WHERE Email='farah.hassan@example.com');
SET @cGabe  = (SELECT CustomerID FROM dbo.Customer WHERE Email='gabe.nguyen@example.com');
SET @cHana  = (SELECT CustomerID FROM dbo.Customer WHERE Email='hana.kim@example.com');
SET @cIvan  = (SELECT CustomerID FROM dbo.Customer WHERE Email='ivan.kovacs@example.com');


-- Rehydrate employees (DO NOT chain these in one DECLARE)
DECLARE @empPB  INT;
DECLARE @empPB2 INT;
DECLARE @empLO  INT;

SELECT TOP (1) @empPB  = EmployeeID
FROM dbo.Employee
WHERE Role = 'PersonalBanker'
ORDER BY EmployeeID;

SELECT TOP (1) @empPB2 = EmployeeID
FROM dbo.Employee
WHERE Role = 'PersonalBanker' AND EmployeeID <> @empPB
ORDER BY EmployeeID;

SELECT TOP (1) @empLO  = EmployeeID
FROM dbo.Employee
WHERE Role = 'LoanOfficer'
ORDER BY EmployeeID;

-- PERSONAL BANKERS (insert if not already assigned)
INSERT INTO dbo.CustomerAssignedStaff (CustomerID, EmployeeID, StaffRole)
SELECT v.CustomerID, v.EmployeeID, v.StaffRole
FROM (VALUES
(@cDylan, @empPB,  'PersonalBanker'),
(@cAisha, @empPB,  'PersonalBanker'),
(@cBruno, @empPB2, 'PersonalBanker'),
(@cChloe, @empPB2, 'PersonalBanker'),
(@cDiego, @empPB,  'PersonalBanker'),
(@cEva,   @empPB2, 'PersonalBanker'),
(@cFarah, @empPB,  'PersonalBanker'),
(@cGabe,  @empPB2, 'PersonalBanker'),
(@cHana,  @empPB,  'PersonalBanker'),
(@cIvan,  @empPB2, 'PersonalBanker')
) AS v(CustomerID, EmployeeID, StaffRole)
WHERE v.CustomerID IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.CustomerAssignedStaff cas
      WHERE cas.CustomerID = v.CustomerID
        AND cas.StaffRole  = v.StaffRole
  );

-- LOAN OFFICERS (insert if not already assigned)
INSERT INTO dbo.CustomerAssignedStaff (CustomerID, EmployeeID, StaffRole)
SELECT DISTINCT cl.CustomerID, @empLO, 'LoanOfficer'
FROM dbo.CustomerLoan cl
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.CustomerAssignedStaff cas
    WHERE cas.CustomerID = cl.CustomerID
      AND cas.StaffRole  = 'LoanOfficer'
);

-- =====================================================================
-- VERIFICATION
-- =====================================================================
PRINT '========== TABLE COUNTS ==========';

SELECT 
 'Customer' AS TableName,COUNT(*) FROM dbo.Customer
UNION ALL SELECT 'Employee',COUNT(*) FROM dbo.Employee
UNION ALL SELECT 'Branch',COUNT(*) FROM dbo.Branch
UNION ALL SELECT 'Location',COUNT(*) FROM dbo.Location
UNION ALL SELECT 'Account',COUNT(*) FROM dbo.Account
UNION ALL SELECT 'Overdraft',COUNT(*) FROM dbo.Overdraft
UNION ALL SELECT 'Loan',COUNT(*) FROM dbo.Loan
UNION ALL SELECT 'CustomerLoan',COUNT(*) FROM dbo.CustomerLoan
UNION ALL SELECT 'CustomerAssignedStaff',COUNT(*) FROM dbo.CustomerAssignedStaff
UNION ALL SELECT 'EmployeeLocation',COUNT(*) FROM dbo.EmployeeLocation;

PRINT '========== RELATIONSHIP CHECKS ==========';

SELECT c.FirstName+' '+c.LastName AS Customer, e.FirstName+' '+e.LastName AS Banker
FROM dbo.CustomerAssignedStaff cas
JOIN dbo.Customer c ON cas.CustomerID=c.CustomerID
JOIN dbo.Employee e ON cas.EmployeeID=e.EmployeeID
WHERE cas.StaffRole='PersonalBanker'
ORDER BY c.CustomerID;

PRINT '========== VERIFICATION COMPLETE ==========';

/* --------------------------------------------------------------------------
   TESTING & VALIDATION QUERIES
   -------------------------------------------------------------------------- */
PRINT '================ TESTING TABLES ================';

SELECT * FROM dbo.Branch;
GO

SELECT * FROM dbo.Location;
GO

SELECT * FROM dbo.Employee;
GO

SELECT * FROM dbo.EmployeeLocation;
GO

SELECT * FROM dbo.Customer;
GO

SELECT * FROM dbo.Account;
GO

SELECT * FROM dbo.CustomerAccount;
GO

SELECT * FROM dbo.Overdraft;
GO

SELECT * FROM dbo.Loan;
GO

SELECT * FROM dbo.CustomerLoan;
GO

SELECT * FROM dbo.LoanPayment;
GO

SELECT * FROM dbo.CustomerAssignedStaff;
GO

PRINT '================ SUMMARY COUNTS ================';

SELECT 
    'Customer' AS TableName, COUNT(*) AS TotalRows FROM dbo.Customer
UNION ALL SELECT 'Employee', COUNT(*) FROM dbo.Employee
UNION ALL SELECT 'Branch', COUNT(*) FROM dbo.Branch
UNION ALL SELECT 'Location', COUNT(*) FROM dbo.Location
UNION ALL SELECT 'Account', COUNT(*) FROM dbo.Account
UNION ALL SELECT 'Overdraft', COUNT(*) FROM dbo.Overdraft
UNION ALL SELECT 'Loan', COUNT(*) FROM dbo.Loan
UNION ALL SELECT 'CustomerLoan', COUNT(*) FROM dbo.CustomerLoan
UNION ALL SELECT 'LoanPayment', COUNT(*) FROM dbo.LoanPayment
UNION ALL SELECT 'CustomerAssignedStaff', COUNT(*) FROM dbo.CustomerAssignedStaff
UNION ALL SELECT 'EmployeeLocation', COUNT(*) FROM dbo.EmployeeLocation;
GO
