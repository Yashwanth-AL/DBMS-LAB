# DBMS-LAB Course Content / Syllabus

## Program 1
Consider a structure named Student with attributes as SID, NAME, BRANCH, SEMESTER, ADDRESS. Write a program in C/C++ to perform the following operations using the concept of files:

a. Insert a new student
b. Modify the address of the student based on SID
c. Delete a student
d. List all the students
e. List all the students of the CSE branch
f. List all the students of the CSE branch and reside in Kuvempunagar.


## Program 2
Create a table for the structure Student with attributes as SID, NAME, BRANCH, SEMESTER, ADDRESS, PHONE, EMAIL. Insert at least 10 tuples and perform the following operations using SQL:

a. Insert a new student
b. Modify the address of the student based on SID
c. Delete a student
d. List all the students
e. List all the students of the CSE branch
f. List all the students of the CSE branch and reside in Kuvempunagar.


## Program 3, 4, 5, 6
Data Definition Language (DDL) commands in RDBMS

Consider the database schemas given below. Write ER diagram and schema diagram. The primary keys are underlined and the data types are specified. Create tables for the following schema listed below by properly specifying the primary keys and foreign keys. Enter at least five tuples for each relation. Alter tables by adding and dropping different types of constraints. Also, add and drop fields in the relational schemas of the listed problems. Perform delete and update operations.

A. Sailors Database
SAILORS (sid, sname, rating, age)
BOAT(bid, bname, color)
RESERVES (sid, bid, date)
B. Insurance Database
PERSON (driver_id#: string, name: string, address: string)
CAR (regno: string, model: string, year: int)
ACCIDENT (report_number: int, acc_date: date, location: string)
OWNS (driver_id#: string, regno: string)
PARTICIPATED(driver_id#: string, regno: string, report_number: int, damage_amount: int)
C. Order Processing Database
Customer (Cust#: int, cname: string, city: string)
Order (order#: int, odate: date, cust#: int, order_amt: int)
Order-item (order#: int, item#: int, qty: int)
Item (item#: int, unitprice: int)
Shipment (order#: int, warehouse#: int, ship_date: date)
Warehouse (warehouse#: int, city: string)
D. Student Enrollment in Courses and Books Adopted for Each Course
STUDENT (regno: string, name: string, major: string, bdate: date)
COURSE (course#: int, cname: string, dept: string)
ENROLL (regno: string, course#: int, sem: int, marks: int)
BOOK_ADOPTION (course#: int, sem: int, book_ISBN: int)
TEXT (book_ISBN: int, book_title: string, publisher: string, author: string)
E. Company Database
EMPLOYEE (SSN, Name, Address, Sex, Salary, SuperSSN, DNo)
DEPARTMENT (DNo, DName, MgrSSN, MgrStartDate)
DLOCATION (DNo, DLoc)
PROJECT (PNo, PName, PLocation, DNo)
WORKS_ON (SSN, PNo, Hours)


## Program 7, 8, 9, 10
Data Manipulation Language (DML) and Data Control Language (DCL)

Write valid DML statements to retrieve tuples from the databases. The query may contain appropriate DML and DCL commands such as:

Select with %like, between, where clause
Order by
Set Operations
Exists and not exists
Join operations
Aggregate functions
Group by
Group by having
Nested and correlated nested queries
Grant and revoke permissions.


## Program 11, 12
Views and Triggers

i. Views: Creation and manipulating content.
ii. Triggers: Creation and execution of database triggers on every insert, delete, and update operation.
Program 13
Laboratory Test: (Note: questions no. 1 and 2 are only for practice)
