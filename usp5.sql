/* ----------------------------------------------------------------------------------------------------------------------
-- Stored Procedure to satisfied the requirement in question 5: For each library branch, retrieve the branch name and the
-- total number of books loaned out from that branch.
-------------------------------------------------------------------------------------------------------------------------- */

/* Define which dB */
USE [db_library]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- When the procedure already exists, drop it so that it can be created without erroring
IF EXISTS ( SELECT 1
			FROM INFORMATION_SCHEMA.ROUTINES
			WHERE ROUTINE_NAME = 'uspGetEachBranchNameWithLoanTotal')
DROP PROC [dbo].[uspGetEachBranchNameWithLoanTotal]
GO


CREATE PROC dbo.uspGetEachBranchNameWithLoanTotal @NoOfCopies int OUTPUT, @BranchName varchar(50) OUTPUT
AS

BEGIN

	DECLARE @errorString varchar(100)
	DECLARE @LoanResults int = 0
	DECLARE @BranchResults int = 0
	
	BEGIN TRY

		-- Checking to see if there are rows in the tables used in the main select statment below for error handling	
		SET @LoanResults = (SELECT	COUNT(*)
								FROM	book.tbl_loan)

		SET @BranchResults = (SELECT	COUNT(*)
								FROM	book.tbl_branch)

		-- If tables have no records, the main select statement won't return any rows
		-- so error needs catching and meaningful messages needs to be raised
		IF @LoanResults = 0
			BEGIN
				RAISERROR('There are no books checked out',16,1)
				RETURN
			END
		
		ELSE IF @BranchResults = 0
			BEGIN
				RAISERROR('There are no libary branches',16,1)
				RETURN
			END
		
		ELSE IF @LoanResults >= 1 AND @BranchResults >= 1 
			BEGIN
				SELECT		COUNT(*) 'Total Number of Books Checked Out',
							bh.name 'Library Branch'
				FROM		book.tbl_loan l
				INNER JOIN book.tbl_branch bh ON l.branch_id = bh.branch_id
				GROUP BY	bh.name;
			END

	END TRY

	BEGIN CATCH

		DECLARE @errorMessage	NVARCHAR(4000);
		DECLARE @errorSeverity	INT;
		DECLARE @errorState		INT;

		SELECT  @errorMessage = ERROR_MESSAGE(),
				@errorSeverity = ERROR_SEVERITY(),
				@errorState    = ERROR_STATE();

		RAISERROR(@errorMessage,@errorSeverity,@errorState)
		
	END CATCH

END
GO

/* This is how the stored procedure is run -- commented out at the moment!
DECLARE @NoOfCopies int
DECLARE @BranchName varchar(50)
EXEC dbo.uspGetEachBranchNameWithLoanTotal @NoOfCopies OUTPUT, @BranchName OUTPUT
GO
*/
