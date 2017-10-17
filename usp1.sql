/* ----------------------------------------------------------------------------------------------------------------------
-- Stored Procedure to satisfied the requirement in question 1: How many copies of the book titled "The Lost Tribe" are owned
-- by the library branch whose name is "Sharpstown"?
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
			WHERE ROUTINE_NAME = 'uspGetNoOfCopiesOfTitleAtBranch')
DROP PROC [dbo].[uspGetNoOfCopiesOfTitleAtBranch]
GO

CREATE PROC dbo.uspGetNoOfCopiesOfTitleAtBranch @BookTitle varchar(50), @BranchName varchar(50), @NoOfCopies int OUTPUT
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
		ELSE IF @BranchName IS NULL OR @BranchName = ''
			BEGIN
			RAISERROR('A library branch has not been specified',16,1)
				RETURN
			END

		-- Checking to see if there are rows in the tables used in the main select statment below for error handling
		SET @BookResults = (SELECT	COUNT(title)
							FROM	book.tbl_book
							WHERE	title = @BookTitle)


		SET @BranchResults = (SELECT	COUNT(*)
							  FROM		book.tbl_branch)

		-- If either of the tables has no records, the main select statement won't return any rows
		-- so an error needs catching and a meaningful message needs to be raised
		IF @BookResults = 0 
			BEGIN
				RAISERROR('The book title does not exist',16,1)
				RETURN
			END
		ELSE IF @BranchResults = 0
			BEGIN
				RAISERROR('There are no libary branches',16,1)
				RETURN
			END
		ELSE IF @BookResults = 1 AND @BranchResults >= 1

			BEGIN

				SELECT		c.no_of_copies
				FROM		book.tbl_copy c
				INNER JOIN	book.tbl_book bk ON c.book_id = bk.book_id
				INNER JOIN	book.tbl_branch bh ON c.branch_id = bh.branch_id
				WHERE		bk.title = @BookTitle 
				AND			bh.name = @BranchName; 
						
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
EXEC dbo.uspGetNoOfCopiesOfTitleAtBranch 'The Lost Tribe', 'Sharpstown', @NoOfCopies OUTPUT
GO
*/
