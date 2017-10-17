/* ----------------------------------------------------------------------------------------------------------------------
-- Stored Procedure to satisfied the requirement in question 6: Retrieve the names, addresses, and number of books checked
-- out for all borrowers who have more than five books checked out.
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
			WHERE ROUTINE_NAME = 'uspGetBorrowerAndNoOfBooksCheckedOutWhenGreaterThanANumber')
DROP PROC [dbo].[uspGetBorrowerAndNoOfBooksCheckedOutWhenGreaterThanANumber]
GO

CREATE PROC dbo.uspGetBorrowerAndNoOfBooksCheckedOutWhenGreaterThanANumber @GreaterThanInt int = 0, @BorrowerName varchar(50) OUTPUT, @BorrowerAddress varchar(100) OUTPUT, @NoOfBooks int OUTPUT
AS

BEGIN

	DECLARE @errorString varchar(100)
	DECLARE @BorrowerResults int = 0
	DECLARE @BookResults int = 0
	DECLARE @LoanResults int = 0

	SET NOCOUNT ON	

	BEGIN TRY

		-- Checking to see if there are rows in the tables used in the main select statment below for error handling
		SET @BorrowerResults = (SELECT	COUNT(*)
								FROM	book.tbl_borrower)

		SET @BookResults = (SELECT	COUNT(*)
								FROM	book.tbl_book)

		SET @LoanResults = (SELECT	COUNT(*)
								FROM	book.tbl_loan)

		-- If tables have no records, the main select statement won't return any rows
		-- so error needs catching and meaningful messages needs to be raised
		IF @BorrowerResults = 0
			BEGIN
				RAISERROR('There are no borrowers',16,1)
				RETURN
			END
		ELSE IF @BookResults = 0
			BEGIN
				RAISERROR('There are no books',16,1)
				RETURN
			END
		ELSE IF @LoanResults = 0
			BEGIN
				RAISERROR('There are no books checked out',16,1)
				RETURN
			END
		ELSE IF @BorrowerResults >= 1 AND @BookResults >= 1 AND @LoanResults >= 1
			BEGIN
				SELECT		br.name,
							br.address,
							COUNT(*) 'Number of Books Checked Out'
				FROM		book.tbl_loan l
				INNER JOIN	book.tbl_book bk ON l.book_id = bk.book_id
				INNER JOIN  book.tbl_borrower br ON l.borrower_id = br.borrower_id
				GROUP BY    br.name,br.address
				HAVING COUNT(*) > @GreaterThanInt;
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
DECLARE @BorrowerName varchar(50)
DECLARE @BorrowerAddress varchar(100)
DECLARE @NoOfBooks int
EXEC dbo.uspGetBorrowerAndNoOfBooksCheckedOutWhenGreaterThanANumber 5, @BorrowerName OUTPUT, @BorrowerAddress OUTPUT, @NoOfBooks OUTPUT
GO
*/
