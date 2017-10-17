/* ----------------------------------------------------------------------------------------------------------------------
-- Stored Procedure to satisfied the requirement in question 4: For each book that is loaned out from the "Sharpstown" branch
-- and whose DueDate is today, retrieve the book title, the borrower's name, and the borrower's address.
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
			WHERE ROUTINE_NAME = 'uspGetBorrowerDetailsBookTitleForBranchLoansDueToday')
DROP PROC [dbo].[uspGetBorrowerDetailsBookTitleForBranchLoansDueToday]
GO


CREATE PROC dbo.uspGetBorrowerDetailsBookTitleForBranchLoansDueToday @BranchName varchar(50), @BookTitle varchar(50) OUTPUT, @BorrowerName varchar(50) OUTPUT, @BorrowerAddress varchar(100) OUTPUT
AS

BEGIN

	DECLARE @errorString varchar(100)
	DECLARE @LoanResults int = 0
	DECLARE @BookResults int = 0
	DECLARE @BranchResults int = 0
	DECLARE @BorrowerResults int = 0

	SET NOCOUNT ON	

	BEGIN TRY

		-- When parameters are null or empty strings, the main select statment won't return any rows
		-- so the error needs catching and a meaningful message needs to be raised
		IF @BranchName IS NULL OR @BranchName = ''
			BEGIN
				RAISERROR('A library branch has not been specified',16,1)
				RETURN
			END

		
		-- Checking to see if there are rows in the tables used in the main select statment below for error handling
		SET @LoanResults = (SELECT	COUNT(*)
								FROM	book.tbl_loan)

		SET @BookResults = (SELECT	COUNT(*)
								FROM	book.tbl_book)

		SET @BranchResults = (SELECT	COUNT(*)
								FROM	book.tbl_branch)

		SET @BorrowerResults = (SELECT	COUNT(*)
								FROM	book.tbl_borrower)

		-- If tables have no records, the main select statement won't return any rows
		-- so error needs catching and meaningful messages needs to be raised
		IF @LoanResults = 0
			BEGIN
				RAISERROR('There are no books checked out',16,1)
				RETURN
			END
		ELSE IF @BookResults = 0
			BEGIN
				RAISERROR('There are no books',16,1)
				RETURN
			END
		ELSE IF @BranchResults = 0
			BEGIN
				RAISERROR('There are no libary branches',16,1)
				RETURN
			END
		ELSE IF @BorrowerResults = 0
			BEGIN
				RAISERROR('There are no borrowers',16,1)
				RETURN
			END
		ELSE IF @LoanResults >= 1 AND @BookResults >= 1 AND @BranchResults >= 1 AND @BorrowerResults >= 1
			BEGIN

				SELECT		bk.title 'Book Title',
							br.name 'Borrower''s Name',
							br.address 'Borrower''s Address'
				FROM		book.tbl_loan l
				INNER JOIN	book.tbl_book bk ON l.book_id = bk.book_id
				INNER JOIN	book.tbl_branch bh ON l.branch_id = bh.branch_id
				INNER JOIN  book.tbl_borrower br ON l.borrower_id = br.borrower_id
				WHERE		bh.name = @BranchName
				AND			l.date_due = CONVERT(date,GETDATE());
										
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
DECLARE @BookTitle varchar(50)
DECLARE @BorrowerName varchar(50)
DECLARE @BorrowerAddress varchar(100)
EXEC dbo.uspGetBorrowerDetailsBookTitleForBranchLoansDueToday 'Sharpstown', @BookTitle OUTPUT, @BorrowerName OUTPUT, @BorrowerAddress OUTPUT
GO
*/
