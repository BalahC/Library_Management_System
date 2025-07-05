# Library Management System using SQL

## Project Overview

**Project Title**: Library Management System  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase my skills in database design, manipulation, and querying.

![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/BalahC/Library_Management_System/blob/main/Schema.pgerd.png)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch (
                        branch_id varchar(10)	PRIMARY KEY,
                        manager_id	varchar(10),
                        branch_address  varchar(50),
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
                        issued_book_id varchar(20), -- FOREIGN KEY
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


```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Creating a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(book_id,book_title,category,rental_price,status,author,publisher)
	VALUES
                        ('978-1-60129-456-2', 'To Kill a Mockingbird',
		'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books;
```
**Task 2: Updatimg an Existing Member's Address**

```sql
UPDATE members
SET member_address = '798 Oak St'
WHERE member_id = 'C103';
SELECT * FROM members;
```

**Task 3: Deleting a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS123' from the issued_status table.

```sql
DELETE FROM	issued_status
WHERE issued_id = 'IS123';
SELECT * FROM issued_status;
```

**Task 4: Task 4: Retrieving All Books Issued by a Specific Employee**
-- Objective: Selecting all books issued by the employee with emp_id = 'E101'.
```sql
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
```


**Task 5: Listing Members Who Have Issued More Than One Book**
-- Objective: Using GROUP BY to find members who have issued more than one book.

```sql

SELECT issued_status.issued_member_id,
		COUNT(issued_id) as Nb_books_issued,
		members.member_name,
		members.member_address
FROM issued_status JOIN members 
ON members.member_id = issued_status.issued_member_id
GROUP BY issued_status.issued_member_id, members.member_name, members.member_address
HAVING COUNT(issued_id) > 1;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Creating Summary Tables**
-- Using CTAS to generate new tables based on query results - each book and total book_issued_count**

```sql
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
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieving All Books in a Specific Category:(Fiction)**:

```sql
SELECT book_id,
	book_title,
	author,
	category
FROM books WHERE category = 'Fiction'
```

8. **Task 8: Finding Total Rental Income by Category**:

```sql
SELECT * FROM books;

SELECT books.category,
		SUM(books.rental_price) AS "Total_Rental_Income"
FROM books
GROUP BY 1
ORDER BY "Total_Rental_Income" DESC
```

9. **Insert four new records & list Members Who Registered in the Last 360 Days**
```sql
INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES 
	('C120','Balah','332 Oak St','2024-12-10'),
	('C122','Ouedraogo','562 Ouaga St','2024-11-10'),
	('C123','Minatou','986 Patte St','2024-11-28'),
	('C124','Safiatou','237 Pissy St','2024-10-20');

SELECT * FROM members
WHERE members.reg_date >= CURRENT_DATE - INTERVAL '360 days';
```
10. **Listing Employees with Their Branch Manager's Name and their branch details**:
```sql
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
```

Task 11. **Creating a Table of Books with Rental Price Above a Certain Threshold ($4.5)**:
```sql
CREATE TABLE books_price AS

SELECT * FROM books
WHERE rental_price >= 4.5
ORDER BY rental_price DESC;

SELECT * FROM books_price;
```

Task 12: **Retrieving the List of Books Not Yet Returned**
```sql
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
```

## Advanced SQL Operations

**Task 13: Identifying Members with Overdue Books & the employees that issued the books**  
-- Writing a query to identify members who have overdue books (with a 360-day return period). 
-- Displaying the member's name, book title, issue date, and days overdue..

```sql
CREATE TABLE over_due_days 
AS
SELECT issued_status.issued_id,	
		issued_status.issued_member_id,
		books.book_title,
		members.member_name,
		employees.emp_name,
		issued_status.issued_date,
		(CURRENT_DATE - issued_status.issued_date) - 360 as Over_Due_Days
FROM issued_status
JOIN members 
ON issued_status.issued_member_id = members.member_id
JOIN books 
ON books.book_id = issued_status.issued_book_id
LEFT JOIN return_status
ON return_status.issued_id = issued_status.issued_id
JOIN employees
ON employees.emp_id = issued_status.issued_emp_id
WHERE 
	return_status.return_id IS NULL
	AND
	(CURRENT_DATE - issued_status.issued_date) >360
ORDER BY 1;
```


**Task 14: Updating Book Status on Return**
-- Writing a query to update the status of books in the books table to "Yes" 
-- when they are returned (based on entries in the return_status table).


```sql
SELECT * FROM issued_status
WHERE issued_book_id = '978-0-7432-7356-4';

SELECT * FROM books
WHERE book_id = '978-0-7432-7356-4';

UPDATE books
SET status = 'no'     --- updating the status to 'no' since the book hasn't been return
WHERE book_id = '978-0-7432-7356-4';

SELECT * FROM return_status
WHERE issued_id ='IS132';  --- this book wasn't return

-- book return today & needs to be added in the return_status table

INSERT INTO return_status(return_id,issued_id,return_date, book_quality)
VALUES 
	('RS119','IS132',CURRENT_DATE,'Good');

-- changing the status in the books table to yes since the book has been returned

UPDATE books
SET status = 'yes'
WHERE book_id = '978-0-7432-7356-4';

```

**Task 15: Branch Performance Report**
-- Creating a query to generates the performance report for each branch, 
-- showing the number of books issued, the number of books returned, 
-- and the total revenue generated from book rentals.

```sql
CREATE TABLE branch_report AS
SELECT branch.branch_id, branch.manager_id,
		COUNT(issued_status.issued_id) as book_issued,
		COUNT(return_status.return_id) as book_returned,
		SUM(rental_price) as total_revenue
FROM issued_status
JOIN employees 
ON employees.emp_id = issued_status.issued_emp_id
JOIN books
ON books.book_id = issued_status.issued_book_id
LEFT JOIN return_status 
ON return_status.issued_id = issued_status.issued_id
JOIN branch
ON branch.branch_id = employees.branch_id
GROUP BY 1,2
ORDER BY SUM(rental_price) DESC;
```

**Task 16: Creating a Table of Active Members**
-- Using the CREATE TABLE AS (CTAS) statement to create a new table active_members 
-- containing members who have issued at least one book in the last 6 months.

```sql

CREATE TABLE active_member AS
SELECT issued_status.issued_member_id,
		members.member_name,
		members.reg_date,
		members.member_address
FROM issued_status
JOIN members ON members.member_id = issued_status.issued_member_id
WHERE issued_status.issued_date > CURRENT_DATE - INTERVAL '12 months'
GROUP BY 1,2,3,4;

SELECT * FROM active_members;

```


**Task 17: Finding Employees with the Most Book Issues Processed**
-- finding the top 3 employees who have processed the most book issues.
-- Display the employee name, number of books processed, and their branch.

```sql
SELECT issued_status.issued_emp_id,
		employees.emp_name,
		employees.branch_id,
		COUNT(issued_status.issued_id) as nb_books_processed
FROM issued_status JOIN employees
ON employees.emp_id = issued_status.issued_emp_id
GROUP BY 1,2,3
ORDER BY COUNT(issued_status.issued_id) DESC
LIMIT 3;
```

**Task 18: Members Issuing High-Risk Books**
-- identifying members who have issued books with the status "damaged" in the return_status table. 
-- Displaying their member name, book title, and the number of times they've issued damaged books.     
```sql
SELECT return_status.return_id,
		issued_status.issued_id,
		members.member_name,
		issued_status.issued_book_name,
		return_status.book_quality
FROM issued_status 
JOIN return_status
ON return_status.issued_id = issued_status.issued_id
JOIN members 
ON issued_status.issued_member_id = members.member_id
WHERE return_status.book_quality = 'Damaged';

SELECT * FROM return_status;
```
**Task 19: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:*/

```sql

CREATE TABLE fines_pay 
AS
SELECT * ,
		over_due_days.over_due_days * 0.50 as fines
FROM over_due_days;

```



**Task 20:  Finding the total fines by members**
```sql
SELECT DISTINCT member_name,
		SUM(over_due_days) as over_due,
		SUM(fines) as total_fine
FROM fines_pay
GROUP BY 1
ORDER BY SUM(fines) DESC;
```
## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
-  **Data Analysis**: Best performing employees 
  ![employees](https://github.com/BalahC/Library_Management_System/blob/main/Best_3_Emp.png)
-  **Data Analysis**: manager, Branch performance.
   ![](https://github.com/BalahC/Library_Management_System/blob/main/Branch_performance_graph-.png)
-  **Data Analysis**: Total member Fines and over due days.
-  ![](https://github.com/BalahC/Library_Management_System/blob/main/Due_Fines.png)
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of my SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.


## Author - SHING The Analyst

This project showcases my SQL skills essential for database management and analysis. For more any open task on SQL and data analysis, connect with me through the following channels:


- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/shingbalahclouston/)


Thank you for your time! Looking forward to work and extracting meaningful insights from your data.
