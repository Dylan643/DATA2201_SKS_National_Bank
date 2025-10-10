-- DATA2201 – Relational Databases
-- Group Project Phase 1: SKS National Bank
-- File: populate_database.sql
-- Submitted by: Dylan Retana (ID: 467710), Freddy Munini, Ime Iquoho
-- Bow Valley College
-- Date: October 07, 2025

-- What this script does (short):
-- Inserts sample data for each table (≥5 rows where possible) to test our queries.

USE SKS_National_Bank;
GO

SET NOCOUNT ON;
GO

/* --------------------------------------------------------------------------
   1) Branch (≥3)
--------------------------------------------------------------------------- */
INSERT INTO dbo.Branch (BranchName, City, TotalDeposits, TotalLoans)
VALUES
('Downtown HQ',      'Calgary',  2500000, 1800000),
('North Hill',       'Calgary',  1400000,  900000),
('Riverbend',        'Edmonton', 1200000, 1100000);

/* --------------------------------------------------------------------------
   2) Location (≥5) — include both Branch and Office types
--------------------------------------------------------------------------- */
INSERT INTO dbo.Location (AddressLine1, AddressLine2, City, ProvinceState, PostalCode, LocationType, BranchID)
SELECT '100 Main St', NULL, 'Calgary',  'AB', 'T1A 1A1', 'B', BranchID FROM dbo.Branch WHERE BranchName='Downtown HQ';
INSERT INTO dbo.Location (AddressLine1, AddressLine2, City, ProvinceState, PostalCode, LocationType, BranchID)
SELECT '200 North Rd', NULL, 'Calgary', 'AB', 'T2B 2B2', 'B', BranchID FROM dbo.Branch WHERE BranchName='North Hill';
INSERT INTO dbo.Location (AddressLine1, AddressLine2, City, ProvinceState, PostalCode, LocationType, BranchID)
SELECT '300 River Ave', NULL, 'Edmonton','AB', 'T3C 3C3', 'B', BranchID FROM dbo.Branch WHERE BranchName='Riverbend';

-- Two non-branch offices (LocationType = 'O', BranchID must be NULL)
INSERT INTO dbo.Location (AddressLine1, AddressLine2, City, ProvinceState, PostalCode, LocationType, BranchID)
VALUES
('400 Corporate Plaza', NULL, 'Calgary',  'AB', 'T4D 4D4', 'O', NULL),
('500 Service Center',  NULL, 'Edmonton', 'AB', 'T5E 5E5', 'O', NULL);

/* --------------------------------------------------------------------------
   3) Employee (≥8) — include managers and different roles
--------------------------------------------------------------------------- */
-- First insert a top manager (no ManagerID)
INSERT INTO dbo.Employee (FirstName, LastName, HomeAddress, StartDate, Role, ManagerID)
VALUES ('Morgan','Lee','10 Aspen Way, Calgary, AB','2018-01-15','Mgr',NULL);

-- Get ManagerID for others
DECLARE @MgrID INT = (SELECT EmployeeID FROM dbo.Employee WHERE FirstName='Morgan' AND LastName='Lee');

INSERT INTO dbo.Employee (FirstName, LastName, HomeAddress, StartDate, Role, ManagerID) VALUES
('Ava','Ng','22 Oak Dr, Calgary, AB','2019-03-10','PersonalBanker', @MgrID),
('Noah','Singh','35 Pine St, Calgary, AB','2020-06-01','LoanOfficer',  @MgrID),
('Ethan','Rao','48 Birch Rd, Edmonton, AB','2021-09-20','Teller',      @MgrID),
('Mia','Zhang','59 Maple Ln, Calgary, AB','2022-02-05','Teller',       @MgrID),
('Liam','Khan','61 Cedar Ct, Edmonton, AB','2020-11-11','PersonalBanker', @MgrID),
('Emma','Gomez','72 Willow Pl, Calgary, AB','2023-04-07','LoanOfficer',   @MgrID),
('Lucas','Brown','83 Spruce Gr, Calgary, AB','2019-12-18','PersonalBanker', @MgrID);

/* --------------------------------------------------------------------------
   4) EmployeeLocation (≥5; prefer multiple per employee)
--------------------------------------------------------------------------- */
-- Link employees to locations (branches and/or offices)
INSERT INTO dbo.EmployeeLocation (EmployeeID, LocationID, AssignedSince)
SELECT e.EmployeeID, l.LocationID, '2022-01-01'
FROM dbo.Employee e
JOIN dbo.Location l ON l.LocationType='B'
WHERE e.FirstName='Ava'   AND e.LastName='Ng'      AND l.BranchID = (SELECT BranchID FROM dbo.Branch WHERE BranchName='Downtown HQ');

INSERT INTO dbo.EmployeeLocation (EmployeeID, LocationID, AssignedSince)
SELECT e.EmployeeID, l.LocationID, '2022-01-01'
FROM dbo.Employee e
JOIN dbo.Location l ON l.LocationType='B'
WHERE e.FirstName='Noah'  AND e.LastName='Singh'   AND l.BranchID = (SELECT BranchID FROM dbo.Branch WHERE BranchName='North Hill');

INSERT INTO dbo.EmployeeLocation (EmployeeID, LocationID, AssignedSince)
SELECT e.EmployeeID, l.LocationID, '2022-01-01'
FROM dbo.Employee e
JOIN dbo.Location l ON l.LocationType='B'
WHERE e.FirstName='Liam'  AND e.LastName='Khan'    AND l.BranchID = (SELECT BranchID FROM dbo.Branch WHERE BranchName='Riverbend');

INSERT INTO dbo.EmployeeLocation (EmployeeID, LocationID, AssignedSince)
SELECT e.EmployeeID, l.LocationID, '2023-03-01'
FROM dbo.Employee e
JOIN dbo.Location l ON l.LocationType='O' AND l.AddressLine1='400 Corporate Plaza'
WHERE e.FirstName='Emma'  AND e.LastName='Gomez';

INSERT INTO dbo.EmployeeLocation (EmployeeID, LocationID, AssignedSince)
SELECT e.EmployeeID, l.LocationID, '2021-05-15'
FROM dbo.Employee e
JOIN dbo.Location l ON l.LocationType='B'
WHERE e.FirstName='Lucas' AND e.LastName='Brown'   AND l.BranchID = (SELECT BranchID FROM dbo.Branch WHERE BranchName='Downtown HQ');

-- A few more assignments to exceed 5 rows
INSERT INTO dbo.EmployeeLocation (EmployeeID, LocationID, AssignedSince)
SELECT e.EmployeeID, l.LocationID, '2021-05-15'
FROM dbo.Employee e
JOIN dbo.Location l ON l.LocationType='B'
WHERE e.FirstName='Mia' AND e.LastName='Zhang'   AND l.BranchID = (SELECT BranchID FROM dbo.Branch WHERE BranchName='North Hill');

INSERT INTO dbo.EmployeeLocation (EmployeeID, LocationID, AssignedSince)
SELECT e.EmployeeID, l.LocationID, '2021-07-22'
FROM dbo.Employee e
JOIN dbo.Location l ON l.LocationType='B'
WHERE e.FirstName='Ethan' AND e.LastName='Rao'   AND l.BranchID = (SELECT BranchID FROM dbo.Branch WHERE BranchName='Riverbend');

/* --------------------------------------------------------------------------
   5) Customer (≥10)
--------------------------------------------------------------------------- */
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

/* --------------------------------------------------------------------------
   6) Account (≥12; mix C & S). Capture generated IDs with OUTPUT.
--------------------------------------------------------------------------- */
DECLARE @NewAccounts TABLE (AccountID BIGINT, Label VARCHAR(50));

-- Downtown HQ branch accounts
DECLARE @B_DTHQ INT = (SELECT BranchID FROM dbo.Branch WHERE BranchName='Downtown HQ');
DECLARE @B_NH   INT = (SELECT BranchID FROM dbo.Branch WHERE BranchName='North Hill');
DECLARE @B_RB   INT = (SELECT BranchID FROM dbo.Branch WHERE BranchName='Riverbend');

INSERT INTO dbo.Account (BranchID, AccountType, Balance, LastAccessDate, InterestRate, OpenedDate)
OUTPUT inserted.AccountID, 'Dylan_C' INTO @NewAccounts(AccountID, Label)
VALUES (@B_DTHQ, 'C', 1200.00, '2025-09-10', NULL, '2024-03-01');

INSERT INTO dbo.Account (BranchID, AccountType, Balance, LastAccessDate, InterestRate, OpenedDate)
OUTPUT inserted.AccountID, 'Dylan_S' INTO @NewAccounts(AccountID, Label)
VALUES (@B_DTHQ, 'S', 3500.00, '2025-09-20', 1.250, '2024-03-01');

INSERT INTO dbo.Account (BranchID, AccountType, Balance, LastAccessDate, InterestRate, OpenedDate)
OUTPUT inserted.AccountID, 'Aisha_C' INTO @NewAccounts(AccountID, Label)
VALUES (@B_DTHQ, 'C', 800.00, '2025-09-12', NULL, '2024-04-10');

-- North Hill accounts
INSERT INTO dbo.Account (BranchID, AccountType, Balance, LastAccessDate, InterestRate, OpenedDate)
OUTPUT inserted.AccountID, 'Chloe_S' INTO @NewAccounts(AccountID, Label)
VALUES (@B_NH, 'S', 6400.00, '2025-09-22', 1.150, '2024-05-15');

INSERT INTO dbo.Account (BranchID, AccountType, Balance, LastAccessDate, InterestRate, OpenedDate)
OUTPUT inserted.AccountID, 'Chloe_C' INTO @NewAccounts(AccountID, Label)
VALUES (@B_NH, 'C', 950.00, '2025-09-25', NULL, '2024-05-15');

INSERT INTO dbo.Account (BranchID, AccountType, Balance, LastAccessDate, InterestRate, OpenedDate)
OUTPUT inserted.AccountID, 'Eva_C' INTO @NewAccounts(AccountID, Label)
VALUES (@B_NH, 'C', 400.00, '2025-09-18', NULL, '2024-06-01');

-- Riverbend accounts
INSERT INTO dbo.Account (BranchID, AccountType, Balance, LastAccessDate, InterestRate, OpenedDate)
OUTPUT inserted.AccountID, 'Bruno_C' INTO @NewAccounts(AccountID, Label)
VALUES (@B_RB, 'C', 2200.00, '2025-09-05', NULL, '2024-04-21');

INSERT INTO dbo.Account (BranchID, AccountType, Balance, LastAccessDate, InterestRate, OpenedDate)
OUTPUT inserted.AccountID, 'Diego_S' INTO @NewAccounts(AccountID, Label)
VALUES (@B_RB, 'S', 5000.00, '2025-09-15', 1.050, '2024-07-03');

INSERT INTO dbo.Account (BranchID, AccountType, Balance, LastAccessDate, InterestRate, OpenedDate)
OUTPUT inserted.AccountID, 'Farah_C' INTO @NewAccounts(AccountID, Label)
VALUES (@B_RB, 'C', 300.00, '2025-09-09', NULL, '2024-08-12');

-- Extra to reach ≥12
INSERT INTO dbo.Account (BranchID, AccountType, Balance, LastAccessDate, InterestRate, OpenedDate)
OUTPUT inserted.AccountID, 'Gabe_S' INTO @NewAccounts(AccountID, Label)
VALUES (@B_DTHQ, 'S', 7200.00, '2025-09-21', 1.300, '2024-02-05');

INSERT INTO dbo.Account (BranchID, AccountType, Balance, LastAccessDate, InterestRate, OpenedDate)
OUTPUT inserted.AccountID, 'Hana_C' INTO @NewAccounts(AccountID, Label)
VALUES (@B_NH, 'C', 150.00, '2025-09-08', NULL, '2024-09-10');

INSERT INTO dbo.Account (BranchID, AccountType, Balance, LastAccessDate, InterestRate, OpenedDate)
OUTPUT inserted.AccountID, 'Ivan_S' INTO @NewAccounts(AccountID, Label)
VALUES (@B_RB, 'S', 9100.00, '2025-09-26', 1.400, '2024-01-29');

/* --------------------------------------------------------------------------
   7) CustomerAccount (support joint accounts)
--------------------------------------------------------------------------- */
-- Helper: get Customer IDs
DECLARE @cDylan INT  = (SELECT CustomerID FROM dbo.Customer WHERE Email='dylan.retana@example.com');
DECLARE @cAisha INT  = (SELECT CustomerID FROM dbo.Customer WHERE Email='aisha.patel@example.com');
DECLARE @cBruno INT  = (SELECT CustomerID FROM dbo.Customer WHERE Email='bruno.costa@example.com');
DECLARE @cChloe INT  = (SELECT CustomerID FROM dbo.Customer WHERE Email='chloe.martin@example.com');
DECLARE @cDiego INT  = (SELECT CustomerID FROM dbo.Customer WHERE Email='diego.lopez@example.com');
DECLARE @cEva   INT  = (SELECT CustomerID FROM dbo.Customer WHERE Email='eva.chen@example.com');
DECLARE @cFarah INT  = (SELECT CustomerID FROM dbo.Customer WHERE Email='farah.hassan@example.com');
DECLARE @cGabe  INT  = (SELECT CustomerID FROM dbo.Customer WHERE Email='gabe.nguyen@example.com');
DECLARE @cHana  INT  = (SELECT CustomerID FROM dbo.Customer WHERE Email='hana.kim@example.com');
DECLARE @cIvan  INT  = (SELECT CustomerID FROM dbo.Customer WHERE Email='ivan.kovacs@example.com');

-- Helper: fetch AccountIDs by label from @NewAccounts
DECLARE @aDylanC BIGINT = (SELECT AccountID FROM @NewAccounts WHERE Label='Dylan_C');
DECLARE @aDylanS BIGINT = (SELECT AccountID FROM @NewAccounts WHERE Label='Dylan_S');
DECLARE @aAishaC BIGINT = (SELECT AccountID FROM @NewAccounts WHERE Label='Aisha_C');
DECLARE @aChloeS BIGINT = (SELECT AccountID FROM @NewAccounts WHERE Label='Chloe_S');
DECLARE @aChloeC BIGINT = (SELECT AccountID FROM @NewAccounts WHERE Label='Chloe_C');
DECLARE @aEvaC   BIGINT = (SELECT AccountID FROM @NewAccounts WHERE Label='Eva_C');
DECLARE @aBrunoC BIGINT = (SELECT AccountID FROM @NewAccounts WHERE Label='Bruno_C');
DECLARE @aDiegoS BIGINT = (SELECT AccountID FROM @NewAccounts WHERE Label='Diego_S');
DECLARE @aFarahC BIGINT = (SELECT AccountID FROM @NewAccounts WHERE Label='Farah_C');
DECLARE @aGabeS  BIGINT = (SELECT AccountID FROM @NewAccounts WHERE Label='Gabe_S');
DECLARE @aHanaC  BIGINT = (SELECT AccountID FROM @NewAccounts WHERE Label='Hana_C');
DECLARE @aIvanS  BIGINT = (SELECT AccountID FROM @NewAccounts WHERE Label='Ivan_S');

-- Single-owner accounts
INSERT INTO dbo.CustomerAccount (CustomerID, AccountID, OwnershipPercent) VALUES
(@cDylan, @aDylanC, 100), (@cDylan, @aDylanS, 100),
(@cAisha, @aAishaC, 100),
(@cChloe, @aChloeS, 100), (@cChloe, @aChloeC, 100),
(@cEva,   @aEvaC,   100),
(@cBruno, @aBrunoC, 100),
(@cDiego, @aDiegoS, 100),
(@cFarah, @aFarahC, 100),
(@cGabe,  @aGabeS,  100),
(@cHana,  @aHanaC,  100),
(@cIvan,  @aIvanS,  100);

-- Create one joint account example (Chloe & Aisha share Chloe_C 50/50)
-- (We already added Chloe→Chloe_C; add Aisha→Chloe_C too.)
INSERT INTO dbo.CustomerAccount (CustomerID, AccountID, OwnershipPercent)
VALUES (@cAisha, @aChloeC, 50);

/* --------------------------------------------------------------------------
   8) Overdraft (chequing-only) — tie to chequing accounts
--------------------------------------------------------------------------- */
INSERT INTO dbo.Overdraft (AccountID, OverdraftDate, Amount, CheckNumber) VALUES
(@aDylanC, '2025-09-01', 75.00,  '100201'),
(@aAishaC, '2025-09-03', 125.00, '100305'),
(@aChloeC, '2025-09-07', 40.00,  '100412'),
(@aHanaC,  '2025-09-11', 22.50,  '100518');

/* --------------------------------------------------------------------------
   9) Loan (≥6) and 10) CustomerLoan (co-borrowers allowed)
--------------------------------------------------------------------------- */
DECLARE @Loans TABLE (LoanID BIGINT, Label VARCHAR(50));

INSERT INTO dbo.Loan (BranchID, LoanAmount, StartDate, Status)
OUTPUT inserted.LoanID, 'L_Dylan' INTO @Loans(LoanID, Label)
VALUES (@B_DTHQ, 15000.00, '2024-06-01', 'Active');

INSERT INTO dbo.Loan (BranchID, LoanAmount, StartDate, Status)
OUTPUT inserted.LoanID, 'L_Aisha' INTO @Loans(LoanID, Label)
VALUES (@B_DTHQ, 12000.00, '2024-07-10', 'Active');

INSERT INTO dbo.Loan (BranchID, LoanAmount, StartDate, Status)
OUTPUT inserted.LoanID, 'L_Bruno' INTO @Loans(LoanID, Label)
VALUES (@B_RB, 18000.00, '2024-08-20', 'Active');

INSERT INTO dbo.Loan (BranchID, LoanAmount, StartDate, Status)
OUTPUT inserted.LoanID, 'L_Chloe' INTO @Loans(LoanID, Label)
VALUES (@B_NH, 22000.00, '2024-09-15', 'Active');

INSERT INTO dbo.Loan (BranchID, LoanAmount, StartDate, Status)
OUTPUT inserted.LoanID, 'L_Diego' INTO @Loans(LoanID, Label)
VALUES (@B_RB, 9000.00,  '2024-05-05', 'Closed');

INSERT INTO dbo.Loan (BranchID, LoanAmount, StartDate, Status)
OUTPUT inserted.LoanID, 'L_Eva' INTO @Loans(LoanID, Label)
VALUES (@B_NH, 25000.00, '2024-03-25', 'Active');

-- Map borrowers
INSERT INTO dbo.CustomerLoan (CustomerID, LoanID, Role)
SELECT @cDylan, LoanID, 'Primary' FROM @Loans WHERE Label='L_Dylan';
INSERT INTO dbo.CustomerLoan (CustomerID, LoanID, Role)
SELECT @cAisha, LoanID, 'Primary' FROM @Loans WHERE Label='L_Aisha';
INSERT INTO dbo.CustomerLoan (CustomerID, LoanID, Role)
SELECT @cBruno, LoanID, 'Primary' FROM @Loans WHERE Label='L_Bruno';
INSERT INTO dbo.CustomerLoan (CustomerID, LoanID, Role)
SELECT @cChloe, LoanID, 'Primary' FROM @Loans WHERE Label='L_Chloe';
INSERT INTO dbo.CustomerLoan (CustomerID, LoanID, Role)
SELECT @cDiego, LoanID, 'Primary' FROM @Loans WHERE Label='L_Diego';
INSERT INTO dbo.CustomerLoan (CustomerID, LoanID, Role)
SELECT @cEva,   LoanID, 'Primary' FROM @Loans WHERE Label='L_Eva';

-- Add one co-borrower example: Aisha co-borrows with Dylan
INSERT INTO dbo.CustomerLoan (CustomerID, LoanID, Role)
SELECT @cAisha, LoanID, 'CoBorrower' FROM @Loans WHERE Label='L_Dylan';

/* --------------------------------------------------------------------------
   11) LoanPayment (PK = LoanID + PaymentNo) — add 2–3 per loan
--------------------------------------------------------------------------- */
DECLARE @L_Dylan BIGINT = (SELECT LoanID FROM @Loans WHERE Label='L_Dylan');
DECLARE @L_Aisha BIGINT = (SELECT LoanID FROM @Loans WHERE Label='L_Aisha');
DECLARE @L_Bruno BIGINT = (SELECT LoanID FROM @Loans WHERE Label='L_Bruno');
DECLARE @L_Chloe BIGINT = (SELECT LoanID FROM @Loans WHERE Label='L_Chloe');
DECLARE @L_Diego BIGINT = (SELECT LoanID FROM @Loans WHERE Label='L_Diego');
DECLARE @L_Eva   BIGINT = (SELECT LoanID FROM @Loans WHERE Label='L_Eva');

INSERT INTO dbo.LoanPayment (LoanID, PaymentNo, PaymentDate, PaymentAmount) VALUES
(@L_Dylan, 1, '2024-07-01', 500.00), (@L_Dylan, 2, '2024-08-01', 500.00), (@L_Dylan, 3, '2024-09-01', 500.00),
(@L_Aisha, 1, '2024-08-10', 400.00), (@L_Aisha, 2, '2024-09-10', 400.00),
(@L_Bruno, 1, '2024-09-20', 600.00), (@L_Bruno, 2, '2024-10-20', 600.00),
(@L_Chloe, 1, '2024-10-15', 700.00), (@L_Chloe, 2, '2024-11-15', 700.00),
(@L_Diego, 1, '2024-06-05', 300.00), (@L_Diego, 2, '2024-07-05', 300.00), (@L_Diego, 3, '2024-08-05', 300.00),
(@L_Eva,   1, '2024-04-25', 800.00), (@L_Eva,   2, '2024-05-25', 800.00);

/* --------------------------------------------------------------------------
   12) CustomerAssignedStaff — personal banker and/or loan officer links
--------------------------------------------------------------------------- */
-- Find a personal banker and a loan officer
DECLARE @empPB INT = (SELECT TOP 1 EmployeeID FROM dbo.Employee WHERE Role='PersonalBanker' ORDER BY EmployeeID);
DECLARE @empPB2 INT = (SELECT TOP 1 EmployeeID FROM dbo.Employee WHERE Role='PersonalBanker' AND EmployeeID <> @empPB ORDER BY EmployeeID);
DECLARE @empLO INT = (SELECT TOP 1 EmployeeID FROM dbo.Employee WHERE Role='LoanOfficer' ORDER BY EmployeeID);

-- Assign each customer a personal banker; some also get a loan officer
INSERT INTO dbo.CustomerAssignedStaff (CustomerID, EmployeeID, StaffRole) VALUES
(@cDylan, @empPB, 'PersonalBanker'),
(@cAisha, @empPB, 'PersonalBanker'),
(@cBruno, @empPB2,'PersonalBanker'),
(@cChloe, @empPB2,'PersonalBanker'),
(@cDiego, @empPB, 'PersonalBanker'),
(@cEva,   @empPB2,'PersonalBanker'),
(@cFarah, @empPB, 'PersonalBanker'),
(@cGabe,  @empPB2,'PersonalBanker'),
(@cHana,  @empPB, 'PersonalBanker'),
(@cIvan,  @empPB2,'PersonalBanker');

-- Loan officer assignments for those with loans
INSERT INTO dbo.CustomerAssignedStaff (CustomerID, EmployeeID, StaffRole) VALUES
(@cDylan, @empLO, 'LoanOfficer'),
(@cAisha, @empLO, 'LoanOfficer'),
(@cBruno, @empLO, 'LoanOfficer'),
(@cChloe, @empLO, 'LoanOfficer'),
(@cDiego, @empLO, 'LoanOfficer'),
(@cEva,   @empLO, 'LoanOfficer');

PRINT 'populate_database.sql completed successfully.';
GO
