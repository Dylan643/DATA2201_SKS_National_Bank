-- DATA2201 – Relational Databases
-- Group Project Phase 1: SKS National Bank
-- File: create_database.sql
-- Submitted by: Dylan Retana (ID: 467710), Freddy Munini (473383), Ime Iquoho (460765)
-- Bow Valley College

-- What this script does (short):Creates and tests 10 stored procedures for SKS_National_Bank,
-- each performing analytical queries like balances, loans, and branch performance.
-- Defines 10 stored procedures based on the case study, each with a test call.

USE SKS_National_Bank;
GO

/* 1) Total balances by customer (sums across all their accounts) */
IF OBJECT_ID('dbo.sp_CustomerTotalBalance') IS NOT NULL DROP PROC dbo.sp_CustomerTotalBalance;
GO
CREATE PROC dbo.sp_CustomerTotalBalance
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.CustomerID,
        c.FirstName + ' ' + c.LastName AS CustomerName,
        SUM(a.Balance) AS TotalBalance
    FROM dbo.Customer c
    LEFT JOIN dbo.CustomerAccount ca ON ca.CustomerID = c.CustomerID
    LEFT JOIN dbo.Account a ON a.AccountID = ca.AccountID
    GROUP BY c.CustomerID, c.FirstName, c.LastName
    ORDER BY TotalBalance DESC, CustomerName;
END;
GO
--Test
EXEC dbo.sp_CustomerTotalBalance;
GO

/* 2) Total loan amount by branch */
IF OBJECT_ID('dbo.sp_TotalLoanAmountByBranch') IS NOT NULL DROP PROC dbo.sp_TotalLoanAmountByBranch;
GO
CREATE PROC dbo.sp_TotalLoanAmountByBranch
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        b.BranchName,
        SUM(l.LoanAmount) AS TotalLoanAmount
    FROM dbo.Branch b
    LEFT JOIN dbo.Loan l ON l.BranchID = b.BranchID
    GROUP BY b.BranchName
    ORDER BY TotalLoanAmount DESC, b.BranchName;
END;
GO
--Test
EXEC dbo.sp_TotalLoanAmountByBranch;
GO

/* 3) Customers with joint accounts (accounts owned by >1 customer) */
IF OBJECT_ID('dbo.sp_JointAccounts') IS NOT NULL DROP PROC dbo.sp_JointAccounts;
GO
CREATE PROC dbo.sp_JointAccounts
AS
BEGIN
    SET NOCOUNT ON;
    WITH owners AS (
        SELECT ca.AccountID, COUNT(*) AS OwnerCount
        FROM dbo.CustomerAccount ca
        GROUP BY ca.AccountID
        HAVING COUNT(*) > 1
    )
    SELECT
        o.AccountID,
        a.AccountType,
        STRING_AGG(c.FirstName + ' ' + c.LastName, ', ') 
            WITHIN GROUP (ORDER BY c.LastName, c.FirstName) AS Owners
    FROM owners o
    JOIN dbo.CustomerAccount ca ON ca.AccountID = o.AccountID
    JOIN dbo.Customer c ON c.CustomerID = ca.CustomerID
    JOIN dbo.Account a ON a.AccountID = o.AccountID
    GROUP BY o.AccountID, a.AccountType
    ORDER BY o.AccountID;
END;
GO
EXEC dbo.sp_JointAccounts;
GO

/* 4) Overdraft history for a specific account (chequing only) */
IF OBJECT_ID('dbo.sp_OverdraftHistory') IS NOT NULL DROP PROC dbo.sp_OverdraftHistory;
GO
CREATE PROC dbo.sp_OverdraftHistory
    @AccountID BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT o.OverdraftDate, o.Amount, o.CheckNumber
    FROM dbo.Overdraft o
    JOIN dbo.Account a ON a.AccountID = o.AccountID
    WHERE o.AccountID = @AccountID
    ORDER BY o.OverdraftDate DESC;
END;
GO
DECLARE @TestAcct BIGINT = (SELECT TOP 1 AccountID FROM dbo.Account WHERE AccountType='C');
EXEC dbo.sp_OverdraftHistory @AccountID=@TestAcct;
GO

/* 5) Savings interest preview (annualized) */
IF OBJECT_ID('dbo.sp_SavingsInterestPreview') IS NOT NULL DROP PROC dbo.sp_SavingsInterestPreview;
GO
CREATE PROC dbo.sp_SavingsInterestPreview
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        a.AccountID,
        a.Balance,
        a.InterestRate,
        CAST(a.Balance * (a.InterestRate/100.0) AS DECIMAL(18,2)) AS ProjectedOneYearInterest
    FROM dbo.Account a
    WHERE a.AccountType='S';
END;
GO
--Test
EXEC dbo.sp_SavingsInterestPreview;
GO

/* 6) Branch performance snapshot: total deposits & total loans */
IF OBJECT_ID('dbo.sp_BranchPerformance') IS NOT NULL DROP PROC dbo.sp_BranchPerformance;
GO
CREATE PROC dbo.sp_BranchPerformance
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        b.BranchName,
        b.City,
        b.TotalDeposits,
        b.TotalLoans,
        (SELECT SUM(LoanAmount) FROM dbo.Loan l WHERE l.BranchID = b.BranchID) AS CalculatedLoanSum
    FROM dbo.Branch b
    ORDER BY b.TotalDeposits DESC;
END;
GO
--Test
EXEC dbo.sp_BranchPerformance;
GO

/* 7) Employees working at multiple locations */
IF OBJECT_ID('dbo.sp_EmployeesMultiLocation') IS NOT NULL DROP PROC dbo.sp_EmployeesMultiLocation;
GO
CREATE PROC dbo.sp_EmployeesMultiLocation
AS
BEGIN
    SET NOCOUNT ON;
    WITH counts AS (
        SELECT EmployeeID, COUNT(*) AS Cnt
        FROM dbo.EmployeeLocation
        GROUP BY EmployeeID
        HAVING COUNT(*) > 1
    )
    SELECT
        e.EmployeeID,
        e.FirstName + ' ' + e.LastName AS EmployeeName,
        e.Role,
        c.Cnt AS LocationCount
    FROM counts c
    JOIN dbo.Employee e ON e.EmployeeID = c.EmployeeID
    ORDER BY c.Cnt DESC, EmployeeName;
END;
GO
--Test
EXEC dbo.sp_EmployeesMultiLocation;
GO
/* 8) Loan payment schedule & running total for a loan */
IF OBJECT_ID('dbo.sp_LoanPaymentsDetail') IS NOT NULL DROP PROC dbo.sp_LoanPaymentsDetail;
GO
CREATE PROC dbo.sp_LoanPaymentsDetail
    @LoanID BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        lp.LoanID,
        lp.PaymentNo,
        lp.PaymentDate,
        lp.PaymentAmount,
        SUM(lp.PaymentAmount) OVER (PARTITION BY lp.LoanID ORDER BY lp.PaymentNo) AS CumulativePaid
    FROM dbo.LoanPayment lp
    WHERE lp.LoanID = @LoanID
    ORDER BY lp.PaymentNo;
END;
GO
--Test
DECLARE @TestLoan BIGINT = (SELECT TOP 1 LoanID FROM dbo.Loan);
EXEC dbo.sp_LoanPaymentsDetail @LoanID=@TestLoan;
GO

/* 9) Customers handled by a given staff member (by role) */
IF OBJECT_ID('dbo.sp_CustomersByStaff') IS NOT NULL DROP PROC dbo.sp_CustomersByStaff;
GO
CREATE PROC dbo.sp_CustomersByStaff
    @EmployeeID INT,
    @StaffRole  VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.CustomerID,
        c.FirstName + ' ' + c.LastName AS CustomerName,
        cas.StaffRole
    FROM dbo.CustomerAssignedStaff cas
    JOIN dbo.Customer c ON c.CustomerID = cas.CustomerID
    WHERE cas.EmployeeID = @EmployeeID
      AND cas.StaffRole  = @StaffRole
    ORDER BY CustomerName;
END;
GO
DECLARE @AnyPB INT = (SELECT TOP 1 EmployeeID FROM dbo.Employee WHERE Role='PersonalBanker');
EXEC dbo.sp_CustomersByStaff @EmployeeID=@AnyPB, @StaffRole='PersonalBanker';
GO

/* 10) Top N branches by total deposits (parameterized) */
IF OBJECT_ID('dbo.sp_TopBranchesByDeposits') IS NOT NULL DROP PROC dbo.sp_TopBranchesByDeposits;
GO
CREATE PROC dbo.sp_TopBranchesByDeposits
    @TopN INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@TopN)
        b.BranchName,
        b.City,
        b.TotalDeposits
    FROM dbo.Branch b
    ORDER BY b.TotalDeposits DESC, b.BranchName;
END;
GO
EXEC dbo.sp_TopBranchesByDeposits @TopN = 2;
GO

PRINT 'prepared_queries.sql executed successfully.';
GO


--Testing the 10 stored procedures

EXEC dbo.sp_CustomerTotalBalance;
GO

EXEC dbo.sp_TotalLoanAmountByBranch;
GO

EXEC dbo.sp_JointAccounts;
GO

DECLARE @TestAcct BIGINT = (SELECT TOP 1 AccountID FROM dbo.Account WHERE AccountType='C');
EXEC dbo.sp_OverdraftHistory @AccountID=@TestAcct;
GO

EXEC dbo.sp_SavingsInterestPreview;
GO

EXEC dbo.sp_BranchPerformance;
GO

EXEC dbo.sp_EmployeesMultiLocation;
GO

DECLARE @TestLoan BIGINT = (SELECT TOP 1 LoanID FROM dbo.Loan);
EXEC dbo.sp_LoanPaymentsDetail @LoanID=@TestLoan;
GO

DECLARE @AnyPB INT = (SELECT TOP 1 EmployeeID FROM dbo.Employee WHERE Role='PersonalBanker');
EXEC dbo.sp_CustomersByStaff @EmployeeID=@AnyPB, @StaffRole='PersonalBanker';
GO

EXEC dbo.sp_TopBranchesByDeposits @TopN = 2;
GO

