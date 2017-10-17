/* ----------------------------------------------------------------------------------------------------------------------
-- Stored Procedure to satisfied the requirement in question 7: For each book authored (or co-authored) by "Stephen King",
-- retrieve the title and the number of copies owned by the library branch whose name is "Central".
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
			WHERE ROUTINE_NAME = 'uspGetBranchNameBookTitleNoOfCopies')
DROP PROC [dbo].[uspGetBranchNameBookTitleNoOfCopies]
GO


CREATE PROC dbo.uspGetBranchNameBookTitleNoOfCopies @AuthorName varchar(50), @BranchName varchar(50), @BookTitle varchar(50) OUTPUT, @NoOfCopies int OUTPUT
AS

BEGIN

	DECLARE @errorString varchar(100)
	DECLARE @AuthorResults int = 0
	DECLARE @BookResults int = 0
	DECLARE @BranchResults int = 0

	SET NOCOUNT ON	

	BEGIN TRY

		-- When parameters are null or empty strings, the main select statment won't return any rows
		-- so the error needs catching and a meaningful message needs to be raised
		IF @AuthorName IS NULL OR @AuthorName = ''
			BEGIN
				RAISERROR('An author''s name has not been specified',16,1)
				RETURN
			END
		ELSE IF @BranchName IS NULL OR @BranchName = ''
			BEGIN
				RAISERROR('A library branch has not been specified',16,1)
				RETURN
			END

		-- Checking to see if there are rows in the tables used in the main select statment below for error handling
		SET @AuthorResults = (SELECT	COUNT(*)
								FROM	book.tbl_author)

		SET @BookResults = (SELECT	COUNT(*)
								FROM	book.tbl_book)

		SET @BranchResults = (SELECT	COUNT(*)
								FROM	book.tbl_branch)

		-- If tables have no records, the main select statement won't return any rows
		-- so error needs catching and meaningful messages needs to be raised
		IF @AuthorResults = 0
			BEGIN
				RAISERROR('There are no authors',16,1)
				RETURN
			END
		ELSE IF @BookResults = 0
			BEGIN
				RAISERROR('There are no books',16,1)
				RETURN
			END
		ELSE IF @BranchResults = 0
			BEGIN
				RAISERROR('There are no library branches',16,1)
				RETURN
			END
		ELSE IF @AuthorResults >= 1 AND @BookResults >= 1 AND @BranchResults >= 1
			BEGIN

				SELECT		bk.title,
							c.no_of_copies
				FROM		book.tbl_copy c
				INNER JOIN  book.tbl_book bk ON c.book_id = bk.book_id
				INNER JOIN  book.tbl_branch bh ON c.branch_id = bh.branch_id
				INNER JOIN  book.tbl_author a ON bk.author_id = a.author_id	
				WHERE		bh.name = @BranchName
				AND			a.name = @AuthorName;
						
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
DECLARE @NoOfCopies int
EXEC dbo.uspGetBranchNameBookTitleNoOfCopies 'Stephen King','Central', @BookTitle OUTPUT, @NoOfCopies OUTPUT
GO
*/
