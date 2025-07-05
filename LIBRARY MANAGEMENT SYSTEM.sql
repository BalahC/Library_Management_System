--- LIBRARY MANAGEMENT SYSTEM
-- CREATE TABLES IN OUR DB
--- CREATING BRANCH TABLE
DROP TABLE IF EXISTS branch;
CREATE TABLE branch (
					branch_id varchar(10)	PRIMARY KEY,
					manager_id	varchar(10),
					branch_address	varchar(50),
					contact_no varchar(20)
);

--- CREATING EMPLOYEE TABLE
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
						emp_id varchar(10)	PRIMARY KEY,
						emp_name varchar(60),
						position varchar(30),
						salary	float,
						branch_id varchar(20)
);

-- CREATING BOOKS TABLE

DROP TABLE IF EXISTS books;
CREATE TABLE books (
					book_id	varchar(50)	PRIMARY KEY,
					book_title	varchar(100),
					category varchar(50),
					rental_price float,	
					status	varchar(50),
					author	varchar(50),
					publisher varchar(50)
);

-- CREATING Members TABLE

DROP TABLE IF EXISTS members;

CREATE TABLE members (
						member_id varchar(10)	PRIMARY KEY,
						member_name	varchar(40),
						member_address	varchar(50),
						reg_date date
);

-- CREATING Issued_Status TABLE

DROP TABLE IF EXISTS issued_status;

CREATE TABLE issued_status (
							issued_id varchar(10) PRIMARY KEY,
							issued_member_id varchar(20),
							issued_book_name varchar(100),
							issued_date	date,
							issued_book_id	varchar(20), -- FOREIGN KEY
							issued_emp_id varchar(20) --- FK
);

-- CREATING Return_Status TABLE

DROP TABLE IF EXISTS return_status;

CREATE TABLE return_status(
							return_id varchar(10) PRIMARY KEY,
							issued_id varchar(20),  -- FK
							return_book_name varchar(100),	
							return_date	date,
							return_book_id varchar(40)  -- FK
);

-- DEFINING FOREIGN KEY
ALTER TABLE IF EXISTS issued_status 
    ADD CONSTRAINT "FK_emp" FOREIGN KEY (issued_emp_id)
    REFERENCES employees (emp_id);

	ALTER TABLE IF EXISTS issued_status 
    ADD CONSTRAINT "FK_member" FOREIGN KEY (issued_member_id)
    REFERENCES members (member_id);

ALTER TABLE IF EXISTS issued_status 
    ADD CONSTRAINT "FK_book" FOREIGN KEY (issued_book_id)
    REFERENCES books (book_id);

ALTER TABLE IF EXISTS return_status 
    ADD CONSTRAINT "FK_issued" FOREIGN KEY (issued_id)
    REFERENCES issued_status (issued_id);

ALTER TABLE IF EXISTS return_status 
    ADD CONSTRAINT "FK_book" FOREIGN KEY (return_book_id)
    REFERENCES books (book_id);


SELECT * FROM books;

-- Project TASK


-- ### 2. CRUD Operations


-- Task 1. Creating a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(book_id,book_title,category,rental_price,status,author,publisher)
	VALUES
		('978-1-60129-456-2', 'To Kill a Mockingbird',
		'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books;

-- Task 2: Updating an Existing Member's Address

UPDATE members
SET member_address = '798 Oak St'
WHERE member_id = 'C103';
SELECT * FROM members;
-- Task 3: Deleting a Record from the Issued Status Table
-- Objective: Deleting the record with issued_id = 'IS123' from the issued_status table.

DELETE FROM	issued_status
WHERE issued_id = 'IS123';
SELECT * FROM issued_status;

-- Task 4: Retrieving All Books Issued by a Specific Employee
-- Objective: Selecting all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status;

SELECT issued_status.issued_id,
		issued_status.issued_book_name,
		issued_status.issued_date,
		issued_status.issued_member_id,
		employees.emp_id,
		employees.emp_name,
		employees."position",
		employees.branch_id
FROM issued_status
JOIN employees ON issued_status.issued_emp_id = employees.emp_id
WHERE emp_id = 'E101';

-- Task 5: Listing Members Who Have Issued More Than One Book
-- Objective: Using GROUP BY to find members who have issued more than one book.
SELECT * FROM issued_status;

SELECT issued_status.issued_member_id,
		COUNT(issued_id) as Nb_books_issued,
		members.member_name,
		members.member_address
FROM issued_status JOIN members 
ON members.member_id = issued_status.issued_member_id
GROUP BY issued_status.issued_member_id, members.member_name, members.member_address
HAVING COUNT(issued_id) > 1;

SELECT * FROM members;
-- ### 3. CTAS (Create Table As Select)

-- Task 6: Creating Summary Tables**
-- Using CTAS to generate new tables based on query results - each book and total book_issued_count

CREATE TABLE book_issued_cnt
AS
SELECT books.book_id,
		books.book_title,
		COUNT(issued_id) as total_issued
FROM books
JOIN issued_status 
ON issued_status.issued_book_id = books.book_id
GROUP BY 1,2
ORDER BY total_issued DESC;

SELECT * FROM book_issued_cnt;
-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieving All Books in a Specific Category:(Fiction)

SELECT book_id,
	book_title,
	author,
	category
FROM books WHERE category = 'Fiction'



-- Task 8: Finding Total Rental Income by Category:

SELECT * FROM books;

SELECT books.category,
		SUM(books.rental_price) AS "Total_Rental_Income"
FROM books
GROUP BY 1
ORDER BY "Total_Rental_Income" DESC


-- Task 9. **Insert four new records & list Members Who Registered in the Last 360 Days**:

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES 
	('C120','Balah','332 Oak St','2024-12-10'),
	('C122','Ouedraogo','562 Ouaga St','2024-11-10'),
	('C123','Minatou','986 Patte St','2024-11-28'),
	('C124','Safiatou','237 Pissy St','2024-10-20');


SELECT * FROM members
WHERE members.reg_date >= CURRENT_DATE - INTERVAL '360 days';

-- Task 10: Listing Employees with Their Branch Manager's Name and their branch details**:

SELECT e1.emp_id,
		e1.emp_name,
		e1."position",
		e1.salary,
		branch.manager_id,
		e2.emp_name as "Manager",
		branch.contact_no
FROM employees as e1 
JOIN branch 
ON branch.branch_id = e1.branch_id
JOIN 
employees as e2 
ON e2.emp_id= branch.manager_id

SELECT * FROM branch;

-- Task 11. Creating a Table of Books with Rental Price Above a Certain Threshold ($4.5)

CREATE TABLE books_price AS

SELECT * FROM books
WHERE rental_price >= 4.5
ORDER BY rental_price DESC;

SELECT * FROM books_price;

-- Task 12: Retrieving the List of Books Not Yet Returned

SELECT * FROM return_status;
SELECT issued_status.issued_id,
		issued_status.issued_book_id,
		issued_status.issued_date,
		issued_status.issued_book_name,
		issued_status.issued_emp_id
FROM issued_status
LEFT JOIN return_status 
ON return_status.issued_id = issued_status.issued_id
WHERE return_status.issued_id IS NULL

-- First Part By SHING The Analyst

    Member ID
    Number of overdue books
    Total fines
*/