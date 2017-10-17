/* ----------------------------------------------------------------------------------------------------------------------
-- Stored Procedure to satisfied the requirement in question 2: How many copies of the book titled "The Lost Tribe" are owned
-- by each library branch?
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
			WHERE ROUTINE_NAME = 'uspGetNoOfCopiesOfBookAtEachBranch')
DROP PROC [dbo].[uspGetNoOfCopiesOfBookAtEachBranch]
GO

CREATE PROC dbo.uspGetNoOfCopiesOfBookAtEachBranch @BookTitle varchar(50), @NoOfCopies int OUTPUT, @BranchName varchar(50) OUTPUT
AS

BEGIN

	DECLARE @errorString varchar(100)
	DECLARE @BookResults int = 0
	DECLARE @BranchResults int = 0

	SET NOCOUNT ON	

	BEGIN TRY

		-- When parameters are null or empty strings, the main select statment won't return any rows
		-- so the error needs catching and a meaningful message needs to be raised
		IF @BookTitle IS NULL OR @BookTitle = ''
			BEGIN
				RAISERROR('A book title has not been specified',16,1)
				RETURN
			END
		
		-- Checking to see if there are rows in the tables used in the main select statment below for error handling
		SET @BookResults = (SELECT	COUNT(title)
						FROM	book.tbl_book
						WHERE	title = @BookTitle)

		SET @BranchResults = (SELECT	COUNT(*)
								FROM	book.tbl_branch)

		-- If either of the tables has no records, the main select statement won't return any rows
		-- so an error needs catching and a meaningful message needs to be raised
		IF @BookResults = 0
			BEGIN
				RAISERROR('There are no books',16,1)
				RETURN
			END
		ELSE IF @BranchResults = 0
			BEGIN
				RAISERROR('There are no library branches',16,1)
				RETURN
			END
		ELSE IF @BookResults >= 1 AND @BranchResults >= 1
			BEGIN

				SELECT		COUNT(c.no_of_copies) 'Copies',
							bh.name 'Branch'
				FROM		book.tbl_copy c
				INNER JOIN	book.tbl_book bk ON c.book_id = bk.book_id
				INNER JOIN	book.tbl_branch bh ON c.branch_id = bh.branch_id
				WHERE		bk.title = @BookTitle
				GROUP BY    bh.name;


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
DECLARE @BranchName varchar(max)
EXEC dbo.uspGetNoOfCopiesOfBookAtEachBranch 'The Lost Tribe', @NoOfCopies OUTPUT, @BranchName OUTPUT
GO
*/
