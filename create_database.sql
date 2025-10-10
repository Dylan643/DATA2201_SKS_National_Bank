-- DATA2201 – Relational Databases
-- Group Project Phase 1: SKS National Bank
-- File: create_database.sql
-- Submitted by: Dylan Retana (ID: 467710), Freddy Munini, Ime Iquoho
-- Bow Valley College
-- Date: October 07, 2025

-- What this script does (short):
-- Creates the SKS_National_Bank database with all tables, keys, checks, and helpful indexes.

---------------------------------------------
-- 0) Drop & create database
---------------------------------------------
IF DB_ID('SKS_National_Bank') IS NOT NULL
BEGIN
    ALTER DATABASE SKS_National_Bank SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SKS_National_Bank;
END;
GO

CREATE DATABASE SKS_National_Bank;
GO

USE SKS_National_Bank;
GO

---------------------------------------------
-- 1) Branch
---------------------------------------------
CREATE TABLE dbo.Branch (
    BranchID        INT             IDENTITY(1,1) PRIMARY KEY,
    BranchName      VARCHAR(100)    NOT NULL,
    City            VARCHAR(100)    NOT NULL,
    TotalDeposits   DECIMAL(18,2)   NOT NULL DEFAULT 0,
    TotalLoans      DECIMAL(18,2)   NOT NULL DEFAULT 0,
    CreatedAt       DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT UQ_Branch_BranchName UNIQUE (BranchName),
    CONSTRAINT CK_Branch_NonNegative CHECK (TotalDeposits >= 0 AND TotalLoans >= 0)
);

---------------------------------------------
-- 2) Location (Branch or non-branch office)
---------------------------------------------
CREATE TABLE dbo.Location (
    LocationID      INT             IDENTITY(1,1) PRIMARY KEY,
    AddressLine1    VARCHAR(120)    NOT NULL,
    AddressLine2    VARCHAR(120)    NULL,
    City            VARCHAR(100)    NOT NULL,
    ProvinceState   VARCHAR(100)    NOT NULL,
    PostalCode      VARCHAR(20)     NOT NULL,
    LocationType    CHAR(1)         NOT NULL, -- 'B' = Branch, 'O' = Office (not in a branch)
    BranchID        INT             NULL,     -- Required when LocationType='B'
    IsActive        BIT             NOT NULL DEFAULT 1,

    CONSTRAINT CK_Location_Type CHECK (LocationType IN ('B','O')),
    CONSTRAINT CK_Location_BranchLink CHECK (
        (LocationType = 'B' AND BranchID IS NOT NULL) OR
        (LocationType = 'O' AND BranchID IS NULL)
    ),
    CONSTRAINT FK_Location_Branch 
        FOREIGN KEY (BranchID) REFERENCES dbo.Branch(BranchID)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

---------------------------------------------
-- 3) Employee (self-referencing manager)
---------------------------------------------
CREATE TABLE dbo.Employee (
    EmployeeID      INT             IDENTITY(1,1) PRIMARY KEY,
    FirstName       VARCHAR(60)     NOT NULL,
    LastName        VARCHAR(60)     NOT NULL,
    HomeAddress     VARCHAR(200)    NOT NULL,
    StartDate       DATE            NOT NULL,
    Role            VARCHAR(40)     NOT NULL, -- e.g., 'PersonalBanker','LoanOfficer','Teller','Mgr'
    ManagerID       INT             NULL,

    CONSTRAINT FK_Employee_Manager
        FOREIGN KEY (ManagerID) REFERENCES dbo.Employee(EmployeeID)
        ON DELETE SET NULL ON UPDATE NO ACTION
);

---------------------------------------------
-- 4) EmployeeLocation (M:N Employee ↔ Location)
---------------------------------------------
CREATE TABLE dbo.EmployeeLocation (
    EmployeeID      INT         NOT NULL,
    LocationID      INT         NOT NULL,
    AssignedSince   DATE        NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    CONSTRAINT PK_EmployeeLocation PRIMARY KEY (EmployeeID, LocationID),
    CONSTRAINT FK_EmployeeLocation_Emp 
        FOREIGN KEY (EmployeeID) REFERENCES dbo.Employee(EmployeeID)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT FK_EmployeeLocation_Loc 
        FOREIGN KEY (LocationID) REFERENCES dbo.Location(LocationID)
        ON DELETE CASCADE ON UPDATE NO ACTION
);

---------------------------------------------
-- 5) Customer
---------------------------------------------
CREATE TABLE dbo.Customer (
    CustomerID      INT             IDENTITY(1,1) PRIMARY KEY,
    FirstName       VARCHAR(60)     NOT NULL,
    LastName        VARCHAR(60)     NOT NULL,
    HomeAddress     VARCHAR(200)    NOT NULL,
    Email           VARCHAR(120)    NULL,     -- unique when provided
    Phone           VARCHAR(30)     NULL,
    CreatedAt       DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);
-- Unique email when not null (filtered index)
CREATE UNIQUE INDEX UX_Customer_Email_NotNull
    ON dbo.Customer (Email)
    WHERE Email IS NOT NULL;

---------------------------------------------
-- 6) Account (Chequing/Savings in one table)
---------------------------------------------
CREATE TABLE dbo.Account (
    AccountID       BIGINT          IDENTITY(10000001,1) PRIMARY KEY,
    BranchID        INT             NOT NULL,
    AccountType     CHAR(1)         NOT NULL, -- 'C'=Chequing, 'S'=Savings
    Balance         DECIMAL(18,2)   NOT NULL DEFAULT 0,
    LastAccessDate  DATE            NULL,
    InterestRate    DECIMAL(5,3)    NULL,    -- only for Savings
    OpenedDate      DATE            NOT NULL DEFAULT CAST(GETDATE() AS DATE),

    CONSTRAINT FK_Account_Branch 
        FOREIGN KEY (BranchID) REFERENCES dbo.Branch(BranchID)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_Account_Type CHECK (AccountType IN ('C','S')),
    CONSTRAINT CK_Account_InterestByType CHECK (
        (AccountType='S' AND InterestRate IS NOT NULL AND InterestRate >= 0) OR
        (AccountType='C' AND InterestRate IS NULL)
    ),
    CONSTRAINT CK_Account_BalanceNonNegative CHECK (Balance >= 0)
);

---------------------------------------------
-- 7) CustomerAccount (M:N Customer ↔ Account, supports joint)
---------------------------------------------
CREATE TABLE dbo.CustomerAccount (
    CustomerID          INT         NOT NULL,
    AccountID           BIGINT      NOT NULL,
    OwnershipStartDate  DATE        NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    OwnershipPercent    DECIMAL(5,2) NULL, -- optional; 0–100 if used
    CONSTRAINT PK_CustomerAccount PRIMARY KEY (CustomerID, AccountID),
    CONSTRAINT FK_CustomerAccount_Cust 
        FOREIGN KEY (CustomerID) REFERENCES dbo.Customer(CustomerID)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT FK_CustomerAccount_Acct 
        FOREIGN KEY (AccountID) REFERENCES dbo.Account(AccountID)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT CK_CustomerAccount_Pct CHECK (OwnershipPercent IS NULL OR (OwnershipPercent >= 0 AND OwnershipPercent <= 100))
);

---------------------------------------------
-- 8) Overdraft (chequing-only events)
---------------------------------------------
CREATE TABLE dbo.Overdraft (
    OverdraftID     BIGINT          IDENTITY(1,1) PRIMARY KEY,
    AccountID       BIGINT          NOT NULL,
    OverdraftDate   DATE            NOT NULL,
    Amount          DECIMAL(18,2)   NOT NULL CHECK (Amount > 0),
    CheckNumber     VARCHAR(20)     NOT NULL,
    CONSTRAINT FK_Overdraft_Account 
        FOREIGN KEY (AccountID) REFERENCES dbo.Account(AccountID)
        ON DELETE CASCADE ON UPDATE NO ACTION
);
/*
 Note: Enforcing "Overdraft only for chequing accounts" requires referencing
 Account.AccountType. A CHECK cannot reference another table in SQL Server.
 We will enforce this rule in Phase 2 via a trigger (see create_triggers.sql).
*/

---------------------------------------------
-- 9) Loan
---------------------------------------------
CREATE TABLE dbo.Loan (
    LoanID          BIGINT          IDENTITY(50000001,1) PRIMARY KEY,
    BranchID        INT             NOT NULL,
    LoanAmount      DECIMAL(18,2)   NOT NULL CHECK (LoanAmount > 0),
    StartDate       DATE            NOT NULL,
    Status          VARCHAR(20)     NOT NULL DEFAULT 'Active', -- 'Active','Closed','ChargedOff', etc.
    CONSTRAINT FK_Loan_Branch 
        FOREIGN KEY (BranchID) REFERENCES dbo.Branch(BranchID)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

---------------------------------------------
-- 10) CustomerLoan (M:N Customer ↔ Loan, allows co-borrowers)
---------------------------------------------
CREATE TABLE dbo.CustomerLoan (
    CustomerID  INT         NOT NULL,
    LoanID      BIGINT      NOT NULL,
    Role        VARCHAR(20) NOT NULL DEFAULT 'Primary', -- 'Primary','CoBorrower'
    CONSTRAINT PK_CustomerLoan PRIMARY KEY (CustomerID, LoanID),
    CONSTRAINT FK_CustomerLoan_Cust 
        FOREIGN KEY (CustomerID) REFERENCES dbo.Customer(CustomerID)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT FK_CustomerLoan_Loan 
        FOREIGN KEY (LoanID) REFERENCES dbo.Loan(LoanID)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT CK_CustomerLoan_Role CHECK (Role IN ('Primary','CoBorrower'))
);

---------------------------------------------
-- 11) LoanPayment (PK = LoanID + PaymentNo)
---------------------------------------------
CREATE TABLE dbo.LoanPayment (
    LoanID          BIGINT          NOT NULL,
    PaymentNo       INT             NOT NULL, -- unique per loan
    PaymentDate     DATE            NOT NULL,
    PaymentAmount   DECIMAL(18,2)   NOT NULL CHECK (PaymentAmount > 0),
    CONSTRAINT PK_LoanPayment PRIMARY KEY (LoanID, PaymentNo),
    CONSTRAINT FK_LoanPayment_Loan 
        FOREIGN KEY (LoanID) REFERENCES dbo.Loan(LoanID)
        ON DELETE CASCADE ON UPDATE NO ACTION
);

---------------------------------------------
-- 12) CustomerAssignedStaff (who a customer “always works with”)
---------------------------------------------
CREATE TABLE dbo.CustomerAssignedStaff (
    CustomerID  INT         NOT NULL,
    EmployeeID  INT         NOT NULL,
    StaffRole   VARCHAR(20) NOT NULL, -- 'PersonalBanker','LoanOfficer'
    AssignedSince DATE      NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    CONSTRAINT PK_CustomerAssignedStaff PRIMARY KEY (CustomerID, EmployeeID, StaffRole),
    CONSTRAINT FK_CAS_Customer 
        FOREIGN KEY (CustomerID) REFERENCES dbo.Customer(CustomerID)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT FK_CAS_Employee 
        FOREIGN KEY (EmployeeID) REFERENCES dbo.Employee(EmployeeID)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT CK_CAS_StaffRole CHECK (StaffRole IN ('PersonalBanker','LoanOfficer'))
);

---------------------------------------------
-- Helpful indexes for joins and lookups
---------------------------------------------
-- Foreign keys commonly filtered/joined:
CREATE INDEX IX_Location_BranchID           ON dbo.Location(BranchID);
CREATE INDEX IX_Employee_ManagerID          ON dbo.Employee(ManagerID);
CREATE INDEX IX_EmployeeLocation_EmployeeID ON dbo.EmployeeLocation(EmployeeID);
CREATE INDEX IX_EmployeeLocation_LocationID ON dbo.EmployeeLocation(LocationID);
CREATE INDEX IX_Account_BranchID            ON dbo.Account(BranchID);
CREATE INDEX IX_CustomerAccount_AccountID   ON dbo.CustomerAccount(AccountID);
CREATE INDEX IX_Overdraft_AccountID         ON dbo.Overdraft(AccountID);
CREATE INDEX IX_Loan_BranchID               ON dbo.Loan(BranchID);
CREATE INDEX IX_CustomerLoan_LoanID         ON dbo.CustomerLoan(LoanID);
CREATE INDEX IX_LoanPayment_LoanID          ON dbo.LoanPayment(LoanID);
CREATE INDEX IX_CAS_EmployeeID              ON dbo.CustomerAssignedStaff(EmployeeID);

PRINT 'create_database.sql completed successfully.';
