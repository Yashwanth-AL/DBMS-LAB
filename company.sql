DROP DATABASE IF EXISTS company;
CREATE DATABASE company;
USE company;

CREATE TABLE IF NOT EXISTS Employee (
    ssn VARCHAR(35) PRIMARY KEY,
    name VARCHAR(35) NOT NULL,
    address VARCHAR(255) NOT NULL,
    sex VARCHAR(7) NOT NULL,
    salary INT NOT NULL,
    super_ssn VARCHAR(35),
    d_no INT,
    FOREIGN KEY (super_ssn) REFERENCES Employee(ssn) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Department (
    d_no INT PRIMARY KEY,
    dname VARCHAR(100) NOT NULL,
    mgr_ssn VARCHAR(35),
    mgr_start_date DATE,
    FOREIGN KEY (d_no) REFERENCES Employee(d_no) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS DLocation (
    d_no INT NOT NULL,
    d_loc VARCHAR(100) NOT NULL,
    FOREIGN KEY (d_no) REFERENCES Department(d_no) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Project (
    p_no INT PRIMARY KEY,
    p_name VARCHAR(25) NOT NULL,
    p_loc VARCHAR(25) NOT NULL,
    d_no INT NOT NULL,
    FOREIGN KEY (d_no) REFERENCES Department(d_no) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS WorksOn (
    ssn VARCHAR(35) NOT NULL,
    p_no INT NOT NULL,
    hours INT NOT NULL DEFAULT 0,
    FOREIGN KEY (ssn) REFERENCES Employee(ssn) ON DELETE CASCADE,
    FOREIGN KEY (p_no) REFERENCES Project(p_no) ON DELETE CASCADE
);

ALTER TABLE Employee 
ADD CONSTRAINT FOREIGN KEY (d_no) REFERENCES Department(d_no) ON DELETE CASCADE;

INSERT INTO Employee VALUES
("01NB235", "Chandan_Krishna", "Siddartha Nagar, Mysuru", "Male", 1500000, "01NB235", 5),
("01NB354", "Employee_2", "Lakshmipuram, Mysuru", "Female", 1200000, "01NB235", 2),
("02NB254", "Employee_3", "Pune, Maharashtra", "Male", 1000000, "01NB235", 4),
("03NB653", "Employee_4", "Hyderabad, Telangana", "Male", 2500000, "01NB354", 5),
("04NB234", "Employee_5", "JP Nagar, Bengaluru", "Female", 1700000, "01NB354", 1);

INSERT INTO Department VALUES
(001, "Human Resources", "01NB235", "2020-10-21"),
(002, "Quality Assesment", "03NB653", "2020-10-19"),
(003, "System Assesment", "04NB234", "2020-10-27"),
(005, "Production", "02NB254", "2020-08-16"),
(004, "Accounts", "01NB354", "2020-09-04");

INSERT INTO DLocation VALUES
(001, "Jaynagar, Bengaluru"),
(002, "Vijaynagar, Mysuru"),
(003, "Chennai, Tamil Nadu"),
(004, "Mumbai, Maharashtra"),
(005, "Kuvempunagar, Mysuru");

INSERT INTO Project VALUES
(241563, "System Testing", "Mumbai, Maharashtra", 004),
(532678, "IOT", "JP Nagar, Bengaluru", 001),
(453723, "Product Optimization", "Hyderabad, Telangana", 005),
(278345, "Yeild Increase", "Kuvempunagar, Mysuru", 005),
(426784, "Product Refinement", "Saraswatipuram, Mysuru", 002);

INSERT INTO WorksOn VALUES
("01NB235", 278345, 5),
("01NB354", 426784, 6),
("04NB234", 532678, 3),
("02NB254", 241563, 3),
("03NB653", 453723, 6);

SELECT * FROM Department;
SELECT * FROM Employee;
SELECT * FROM DLocation;
SELECT * FROM Project;
SELECT * FROM WorksOn;

-- Retrieve project numbers for projects involving an employee with last name 'Scott'
SELECT p_no, p_name, name 
FROM Project p, Employee e 
WHERE p.d_no = e.d_no AND e.name LIKE "%Krishna";

-- Show salaries after a 10% raise for employees working on the 'IoT' project
SELECT w.ssn, name, salary AS old_salary, salary * 1.1 AS new_salary 
FROM WorksOn w 
JOIN Employee e ON w.ssn = e.ssn 
WHERE w.p_no = (SELECT p_no FROM Project WHERE p_name = "IOT");

-- Sum, max, min, and average salary of 'Accounts' department
SELECT SUM(salary) AS sal_sum, MAX(salary) AS sal_max, MIN(salary) AS sal_min, AVG(salary) AS sal_avg 
FROM Employee e 
JOIN Department d ON e.d_no = d.d_no 
WHERE d.dname = "Accounts";

-- Employees working on all projects controlled by department 1 (using NOT EXISTS)
SELECT e.name
FROM Employee e
WHERE NOT EXISTS (
    SELECT p.p_no
    FROM Project p
    WHERE p.d_no = 5
    AND p.p_no NOT IN (SELECT w.p_no FROM WorksOn w WHERE w.ssn = e.ssn)
);


-- Departments with more than one employee earning more than Rs. 6,00,000
SELECT d.d_no, COUNT(*) 
FROM Department d 
JOIN Employee e ON e.d_no = d.d_no 
WHERE salary > 600000 
GROUP BY d.d_no 
HAVING COUNT(*) > 1;

-- Create a view showing employee name, department name, and location
CREATE VIEW emp_details AS
SELECT name, dname, d_loc 
FROM Employee e 
JOIN Department d ON e.d_no = d.d_no 
JOIN DLocation dl ON d.d_no = dl.d_no;

SELECT * FROM emp_details;

-- Create a view showing project name, location, and department
CREATE VIEW ProjectDetails AS
SELECT p_name, p_loc, dname
FROM Project p 
NATURAL JOIN Department d;

SELECT * FROM ProjectDetails;

-- Trigger to update manager's start date when assigned
DELIMITER //
CREATE TRIGGER UpdateManagerStartDate
BEFORE INSERT ON Department
FOR EACH ROW
BEGIN
    SET NEW.mgr_start_date = CURDATE();
END;//
DELIMITER ;

INSERT INTO Department (d_no, dname, mgr_ssn) VALUES
(006, "R&D", "01NB354");

-- Trigger to prevent deletion of projects being worked on
DELIMITER //
CREATE TRIGGER PreventDelete
BEFORE DELETE ON Project
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT * FROM WorksOn WHERE p_no = OLD.p_no) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This project has an employee assigned';
    END IF;
END;//
DELIMITER ;

DELETE FROM Project WHERE p_no = 241563;