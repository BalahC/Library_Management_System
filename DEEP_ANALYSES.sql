-- DATA ANALYSEs and PROBLEM SOLVING
-- ### Advanced SQL Operations

SELECT * from employees;
SELECT * from books;
SELECT * from members;
SELECT * from issued_status;
SELECT * from branch;
SELECT * from return_status;

-- Task 13: Identifying Members with Overdue Books & the employees that issued the books
-- Writing a query to identify members who have overdue books (with a 360-day return period). 
-- Displaying the member's name, book title, issue date, and days overdue.


-- Performing multiple joins
-- issued_status == members == books == return_status
-- After that, need to FILTER books returned
-- Then check for overdue books (30_days validity)
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



--Task 14: Updating Book Status on Return
-- Writing a query to update the status of books in the books table to "Yes" 
-- when they are returned (based on entries in the return_status table).

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


-- Task 15: Branch Performance Report
-- Creating a query to generates the performance report for each branch, 
-- showing the number of books issued, the number of books returned, 
-- and the total revenue generated from book rentals.
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


/*
Task 16: CTAS: Creating a Table of Active Members
Using the CREATE TABLE AS (CTAS) statement to create a new table active_members 
containing members who have issued at least one book in the last 6 months.
*/
CREATE TABLE active_member AS
SELECT issued_status.issued_member_id,
		members.member_name,
		members.reg_date,
		members.member_address
FROM issued_status
JOIN members ON members.member_id = issued_status.issued_member_id
WHERE issued_status.issued_date > CURRENT_DATE - INTERVAL '12 months'
GROUP BY 1,2,3,4;

SELECT * FROM books
SELECT * FROM members
SELECT * FROM employees

-- Task 17: Finding Employees with the Most Book Issues Processed
-- finding the top 3 employees who have processed the most book issues.
-- Display the employee name, number of books processed, and their branch.


SELECT issued_status.issued_emp_id,
		employees.emp_name,
		employees.branch_id,
		COUNT(issued_status.issued_id) as nb_books_processed
FROM issued_status JOIN employees
ON employees.emp_id = issued_status.issued_emp_id
GROUP BY 1,2,3
ORDER BY COUNT(issued_status.issued_id) DESC
LIMIT 3;


-- Task 18: Identify Members Issuing High-Risk Books
-- identifying members who have issued books with the status "damaged" in the return_status table. 
-- Displaying their member name, book title, and the number of times they've issued damaged books.    

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


/*
Task 19: Create Table As Select (CTAS)
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:*/

CREATE TABLE fines_pay 
AS
SELECT * ,
		over_due_days.over_due_days * 0.50 as fines
FROM over_due_days;

--Task 20: Finding the total fines by members

SELECT DISTINCT member_name,
		SUM(over_due_days) as over_due,
		SUM(fines) as total_fine
FROM fines_pay
GROUP BY 1
ORDER BY SUM(fines) DESC;


-- SHING The Analyst