create database LIBRARY_SYSTEM;
use LIBRARY_SYSTEM;

create Table Authors (
AuthorId int primary key,
AuthorName varchar(50) Not null
);
create table Books(
BookId int primary key ,
Title varchar(50),
AuthorId int,
foreign key (AuthorId) references Authors(AuthorId)

);

create table BookCopies(
CopyId int Primary key,
BookId int ,
IsAvailable bit,
foreign key (BookId) references Books(BookId)

);

create table Users(
UserId int primary key,
UserName varchar(50)
);


create table Borrowing(
BorrowiD int identity(1,1) primary key ,
UserId int,
CopyId int,
BorrowDate date,
ReturnDate date NULL,
foreign key (UserId) references Users(UserId),
foreign key (CopyId) references BookCopies(Copyid)
); 
INSERT INTO Authors VALUES
(1, 'APJ Abdul Kalam'),
(2, 'Chetan Bhagat');

INSERT INTO Books VALUES
(101, 'Wings of Fire', 1),
(102, 'India 2020', 1),
(103, 'Half Girlfriend', 2);

INSERT INTO BookCopies VALUES
(1, 101, 1),
(2, 102, 1),
(3, 103, 1);

INSERT INTO Users VALUES
(1, 'Rahul'),
(2, 'Anu');


CREATE PROCEDURE sp_CheckOutBook
@UserId int,
@CopyId int
as
begin 

if exists(
select 1 from BookCopies
where CopyId=@CopyId and IsAvailable=1
)
begin 
INSERT INTO Borrowing (UserId, CopyId, BorrowDate)
VALUES (@UserId, @CopyId, GETDATE());


UPDATE  BookCopies SET IsAvailable=0 
where CopyId=@CopyId;

END

ELSE 
BEGIN 
PRINT 'Book copy is Not Available';
end
end;

exec dbo.sp_CheckOutBook 1,1;


SELECT * FROM Borrowing

CREATE PROCEDURE sp_ReturnBook
    @UserId INT,
    @CopyId INT
AS
BEGIN
    UPDATE Borrowing
    SET ReturnDate = GETDATE()
    WHERE UserId = @UserId
      AND CopyId = @CopyId
      AND ReturnDate IS NULL;

    UPDATE BookCopies
    SET IsAvailable = 1
    WHERE CopyId = @CopyId;
END;

EXEC dbo.sp_ReturnBook 1, 1;


CREATE FUNCTION fn_BookCountByAuthor
(
    @AuthorId INT
)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;

    SELECT @Count = COUNT(*)
    FROM Books
    WHERE AuthorId = @AuthorId;

    RETURN @Count;
END;
SELECT dbo.fn_BookCountByAuthor(1) AS TotalBooks;
select * from Books



CREATE FUNCTION fn_OverdueBorrowings ()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        b.BorrowId,
        u.UserName,
        bc.CopyId,
        b.BorrowDate
    FROM Borrowing b
    JOIN Users u ON b.UserId = u.UserId
    JOIN BookCopies bc ON b.CopyId = bc.CopyId
    WHERE b.ReturnDate IS NULL
      AND DATEDIFF(DAY, b.BorrowDate, GETDATE()) > 7
);
SELECT * FROM dbo.fn_OverdueBorrowings();
