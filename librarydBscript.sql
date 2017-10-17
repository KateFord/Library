-- Create a dB 
CREATE DATABASE db_library
GO

-- Specify which dB to use in the script
USE db_library
GO

-- Create a schema
CREATE SCHEMA book
GO

-- Create tables (card_no may be the same as borrower_id)
CREATE TABLE book.tbl_borrower(
	borrower_id		INT PRIMARY KEY NOT NULL IDENTITY (1,1),
	address			VARCHAR(100) NOT NULL,
	card_no			INT NOT NULL,
	name			VARCHAR(50) NOT NULL,
	phone			VARCHAR(50) NOT NULL
);

-- Create tbl_publisher
CREATE TABLE book.tbl_publisher(
	publisher_id	INT PRIMARY KEY NOT NULL IDENTITY (1,1),
	address			VARCHAR(100) NOT NULL,
	name			VARCHAR(50) NOT NULL,
	phone			VARCHAR(50) NOT NULL
);

-- Create tbl_branch
CREATE TABLE book.tbl_branch(
	branch_id		INT PRIMARY KEY NOT NULL IDENTITY (1,1),
	address			VARCHAR(100) NOT NULL,
	name			VARCHAR(50) NOT NULL,
	phone			VARCHAR(50) NOT NULL,
);

-- Create tbl_author
CREATE TABLE book.tbl_author(
	author_id		INT PRIMARY KEY NOT NULL IDENTITY (1,1),
	name			VARCHAR(50) NOT NULL
);

-- Create tbl_book
CREATE TABLE book.tbl_book(
	book_id			INT PRIMARY KEY NOT NULL IDENTITY (1,1),
	author_id		INT NOT NULL CONSTRAINT fk_book_author_id FOREIGN KEY REFERENCES book.tbl_author(author_id) ON UPDATE CASCADE ON DELETE CASCADE,
	publisher_id	INT NOT NULL CONSTRAINT fk_book_publisher_id FOREIGN KEY REFERENCES book.tbl_publisher(publisher_id) ON UPDATE CASCADE ON DELETE CASCADE,
	title			VARCHAR(50) NOT NULL
);


-- Create tbl_copy
CREATE TABLE book.tbl_copy(
	copy_id			INT PRIMARY KEY NOT NULL IDENTITY (1,1),
	book_id			INT NOT NULL CONSTRAINT fk_copy_book_id FOREIGN KEY REFERENCES book.tbl_book(book_id) ON UPDATE CASCADE ON DELETE CASCADE,
	branch_id		INT NOT NULL CONSTRAINT fk_copy_branch_id FOREIGN KEY REFERENCES book.tbl_branch(branch_id) ON UPDATE CASCADE ON DELETE CASCADE,
	no_of_copies	INT NOT NULL
);

-- Add a unique Key to tbl_copy (which may make the copy_id colum redundant)
ALTER TABLE book.tbl_copy
ADD CONSTRAINT UC_book_branch UNIQUE (book_id,branch_id);

CREATE TABLE book.tbl_loan(
	loan_id			INT PRIMARY KEY NOT NULL IDENTITY (1,1),
	book_id			INT NOT NULL CONSTRAINT fk_loan_book_id FOREIGN KEY REFERENCES book.tbl_book(book_id) ON UPDATE CASCADE ON DELETE CASCADE,
	borrower_id		INT NOT NULL CONSTRAINT fk_loan_borrower_id FOREIGN KEY REFERENCES book.tbl_borrower(borrower_id) ON UPDATE CASCADE ON DELETE CASCADE,
	branch_id		INT NOT NULL CONSTRAINT fk_loan_branch_id FOREIGN KEY REFERENCES book.tbl_branch(branch_id) ON UPDATE CASCADE ON DELETE CASCADE,
	date_due		DATE NULL,
	date_out		DATE NULL
);

-- Add a column to the loans table to store the actual date the book is returned
ALTER TABLE book.tbl_loan
ADD date_returned DATE NULL;

-- Populate tables
INSERT INTO [book].[tbl_publisher]
           ([address],[name],[phone])
     VALUES
		('Oxford England','Oxford University Press','971-111-1111'),
		('Paris France','Hachette Livre','971-111-1112'),
		('Edinburgh Scotland','Pan Macmillan','971-111-1113'),
		('London England','Pearson Education','971-111-1114'),
		('New York USA','Simon & Schuster','971-111-1115'),
		('Dublin Ireland','Faber & Faber','971-111-1116'),
		('Swansea Wales','Andersen Press','971-111-1117'),
		('Chicago USA','Bantam Press','971-111-1118')
;

-- Popluate tbl_author (not catered for co-authors but the dB can be easily modified)
INSERT INTO [book].[tbl_author]
        ([name])
     VALUES
		('Ian Banks'),
		('Ian Rankin'),
		('Lewis Carroll'),
		('Mark Twain'),
		('William Shakespeare'),
		('Charles Dickens'),
		('Victor Hugo'),
		('Jean-Paul Sartre'),
		('Mark Lee'),
        ('Stephen King')
;


-- Popluate tbl_book
INSERT INTO [book].[tbl_book]
           ([author_id],[publisher_id],[title])
     VALUES
           ((SELECT author_id FROM book.tbl_author WHERE name = 'Mark Lee'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Oxford University Press'),'The Lost Tribe'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Charles Dickens'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Oxford University Press'),'Bleak House'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Charles Dickens'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Oxford University Press'),'Great Expectations'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Ian Banks'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Oxford University Press'),'The Crow Road'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Ian Banks'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Oxford University Press'),'The Quarry'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Lewis Carroll'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Oxford University Press'),'A Tangled Tale'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Jean-Paul Sartre'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Hachette Livre'),'Being And Nothingness'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Victor Hugo'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Hachette Livre'),'Les Miserables'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Lewis Carroll'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Pan Macmillan'),'Alice In Wonderland'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Lewis Carroll'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Pan Macmillan'),'Through The Looking-glass'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Mark Lee'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Pearson Education'),'The Canal House'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Ian Banks'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Pearson Education'),'Excession'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Mark Lee'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Simon & Schuster'),'Misery'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Mark Lee'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Simon & Schuster'),'The Shining'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'William Shakespeare'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Faber & Faber'),'Hamlet'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'William Shakespeare'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Faber & Faber'),'Macbeth'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Ian Rankin'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Andersen Press'),'Watchman'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Ian Rankin'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Andersen Press'),'Dead Souls'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Mark Twain'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Bantam Press'),'Roughing It'),
		   ((SELECT author_id FROM book.tbl_author WHERE name = 'Mark Twain'),(SELECT publisher_id FROM book.tbl_publisher WHERE name = 'Bantam Press'),'The Innocents Abroard')
;


-- Popluate tbl_branch
INSERT INTO [book].[tbl_branch]
           ([address],[name],[phone])
     VALUES
           ('Portland Oregon','Central','971-222-2221'),
		   ('Portland Oregon','South East','971-222-2222'),
		   ('Portland Oregon','South West','971-222-2223'),
		   ('Portland Oregon','North East','971-222-2224'),
		   ('Portland Oregon','North West','971-222-2225'),
		   ('Portland Oregon','Sharpstown','971-222-2226')
;

-- Popluate tbl_copy
INSERT INTO [book].[tbl_copy]
       ([book_id],[branch_id],[no_of_copies])
     VALUES
           ((SELECT book_id FROM book.tbl_book WHERE title = 'The Lost Tribe'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Bleak House'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Great Expectations'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Crow Road'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Quarry'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'A Tangled Tale'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Being And Nothingness'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Les Miserables'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Alice In Wonderland'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Through The Looking-glass'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Canal House'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Excession'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Misery'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Shining'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Hamlet'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'MacBeth'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Watchman'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Dead Souls'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Roughing It'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Innocents Abroard'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),2),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Lost Tribe'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Bleak House'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Great Expectations'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Crow Road'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Quarry'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'A Tangled Tale'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Being And Nothingness'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Les Miserables'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Alice In Wonderland'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Through The Looking-glass'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Canal House'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Excession'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Misery'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Shining'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Hamlet'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'MacBeth'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Watchman'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Dead Souls'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Roughing It'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Innocents Abroard'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Lost Tribe'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Bleak House'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Great Expectations'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Crow Road'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Quarry'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'A Tangled Tale'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Being And Nothingness'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Les Miserables'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Alice In Wonderland'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Through The Looking-glass'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Canal House'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Excession'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Misery'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Shining'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Hamlet'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'MacBeth'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Watchman'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Dead Souls'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Roughing It'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Innocents Abroard'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),3),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Lost Tribe'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Bleak House'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Great Expectations'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Crow Road'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Quarry'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'A Tangled Tale'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Being And Nothingness'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Les Miserables'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Alice In Wonderland'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Through The Looking-glass'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Canal House'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Excession'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Misery'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Shining'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Hamlet'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'MacBeth'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Watchman'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Dead Souls'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Roughing It'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Innocents Abroard'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),4),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Lost Tribe'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Bleak House'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Great Expectations'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Crow Road'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Quarry'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'A Tangled Tale'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Being And Nothingness'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Les Miserables'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Alice In Wonderland'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Through The Looking-glass'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Canal House'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Excession'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Misery'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Shining'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Hamlet'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'MacBeth'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Watchman'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Dead Souls'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Roughing It'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Innocents Abroard'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North East'),5),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Lost Tribe'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Bleak House'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Great Expectations'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Crow Road'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Quarry'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'A Tangled Tale'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Being And Nothingness'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Les Miserables'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Alice In Wonderland'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Through The Looking-glass'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Canal House'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Excession'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Misery'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Shining'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Hamlet'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'MacBeth'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Watchman'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Dead Souls'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Roughing It'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Innocents Abroard'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'North West'),6)
;

-- Popluate tbl_borrower
INSERT INTO [book].[tbl_borrower]
           ([address],[card_no],[name],[phone])
     VALUES
			('Portland Oregon','72721','Kate Wannell','503-111-1111'),
			('Portland Oregon','72722','Natalie Ford','503-111-1112'),
			('Portland Oregon','72723','Sarah Wannell','503-111-1113'),
			('Portland Oregon','72724','Jane Wannell','503-111-1114'),
			('Portland Oregon','72725','Jerry Black','503-111-1115'),
			('Portland Oregon','72726','Kate Black','503-111-1116'),
			('Portland Oregon','72727','Patrick Wannell','503-111-1117'),
			('Portland Oregon','72728','Michael Wannell','503-111-1118'),
			('Portland Oregon','72729','Freddie Logan','503-111-1119'),
			('Portland Oregon','72730','Rachel Logan','503-111-1120'),
			('Portland Oregon','72731','Helen Logan','503-111-1121'),
			('Portland Oregon','72732','Peter Logan','503-111-1122')
;

-- Popluate tbl_loan
INSERT INTO [book].[tbl_loan]
           ([book_id],[borrower_id],[branch_id],[date_due],[date_out])
     VALUES
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Lost Tribe'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Kate Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-10'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Bleak House'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Kate Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-10'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Great Expectations'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Kate Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-10'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Crow Road'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Kate Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-10'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Quarry'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Kate Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-10'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'A Tangled Tale'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Kate Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-10'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Being And Nothingness'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Sarah Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Les Miserables'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Sarah Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Alice In Wonderland'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Sarah Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Through The Looking-glass'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Sarah Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Canal House'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Sarah Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Excession'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Sarah Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Misery'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Sarah Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Hamlet'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Sarah Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'MacBeth'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jane Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Watchman'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jane Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Dead Souls'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jane Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Roughing It'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jane Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Innocents Abroard'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jane Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Lost Tribe'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jane Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Bleak House'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jane Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Great Expectations'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jane Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Crow Road'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jane Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Quarry'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jane Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'A Tangled Tale'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jane Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Sharpstown'),'2017-10-31','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Being And Nothingness'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Michael Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-08'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Les Miserables'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Michael Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-08'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Alice In Wonderland'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Michael Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-08'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Through The Looking-glass'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Michael Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-08'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Canal House'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Michael Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-08'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Excession'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Michael Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-08'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Misery'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Patrick Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-07'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Hamlet'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Patrick Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-07'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'MacBeth'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Patrick Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-07'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Watchman'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Patrick Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-07'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Dead Souls'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Patrick Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-07'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Roughing It'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Patrick Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-07'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Innocents Abroard'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Patrick Wannell'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-10-31','2017-10-07'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Lost Tribe'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Natalie Ford'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-01'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Bleak House'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Natalie Ford'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-01'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Great Expectations'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Natalie Ford'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-01'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Crow Road'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Natalie Ford'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-01'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Quarry'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Natalie Ford'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-01'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'A Tangled Tale'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Natalie Ford'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-01'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Being And Nothingness'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jerry Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-02'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Les Miserables'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jerry Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-02'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Alice In Wonderland'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jerry Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-02'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Through The Looking-glass'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jerry Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-02'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Canal House'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jerry Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-02'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Excession'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jerry Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-02'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Misery'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jerry Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-02'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Hamlet'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jerry Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-02'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'MacBeth'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jerry Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-02'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Watchman'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jerry Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-02'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Dead Souls'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jerry Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-02'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Roughing It'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jerry Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-02'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Innocents Abroard'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Jerry Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South West'),'2017-11-30','2017-10-02'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Lost Tribe'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Kate Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),'2017-11-30','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Bleak House'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Kate Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),'2017-11-30','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Great Expectations'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Kate Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),'2017-11-30','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Crow Road'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Kate Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),'2017-11-30','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Quarry'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Kate Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),'2017-11-30','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'A Tangled Tale'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Kate Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),'2017-11-30','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Being And Nothingness'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Kate Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),'2017-11-30','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Les Miserables'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Kate Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),'2017-11-30','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Alice In Wonderland'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Kate Black'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'South East'),'2017-11-30','2017-10-03'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Through The Looking-glass'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Freddie Logan'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-12-04','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Canal House'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Freddie Logan'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-12-04','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Excession'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Freddie Logan'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-12-04','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Misery'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Freddie Logan'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-12-04','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Hamlet'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Freddie Logan'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-12-04','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'MacBeth'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Freddie Logan'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-12-04','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Watchman'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Freddie Logan'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-12-04','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Dead Souls'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Freddie Logan'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-12-04','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'Roughing It'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Freddie Logan'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-12-04','2017-10-04'),
		   ((SELECT book_id FROM book.tbl_book WHERE title = 'The Innocents Abroard'),(SELECT borrower_id FROM book.tbl_borrower WHERE name = 'Freddie Logan'),(SELECT branch_id FROM book.tbl_branch WHERE name = 'Central'),'2017-12-04','2017-10-04')
;

GO




