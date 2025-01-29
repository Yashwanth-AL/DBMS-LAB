CREATE TABLE DEPARTMENT (
    DNo INT PRIMARY KEY,
    DName VARCHAR(25),
    MgrSSN INT,
    MgrStartDate DATE
);

CREATE TABLE DLOCATION (
    DNo INT PRIMARY KEY,
    DLoc VARCHAR(255),
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo) ON DELETE CASCADE
);

CREATE TABLE EMPLOYEE (
    SSN INT PRIMARY KEY,
    Name VARCHAR(25),
    Address VARCHAR(255),
    Sex CHAR(1),
    Salary FLOAT,
    SuperSSN INT,
    DNo INT,
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo) ON DELETE CASCADE
);

CREATE TABLE PROJECT (
    PNo INT PRIMARY KEY,
    PName VARCHAR(255),
    PLocation VARCHAR(255),
    DNo INT,
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo) ON DELETE CASCADE
);

CREATE TABLE WORKS_ON (
    SSN INT,
    PNo INT,
    Hours INT,
    PRIMARY KEY (SSN, PNo),
    FOREIGN KEY (SSN) REFERENCES EMPLOYEE(SSN) ON DELETE CASCADE,
    FOREIGN KEY (PNo) REFERENCES PROJECT(PNo) ON DELETE CASCADE
);

INSERT INTO DEPARTMENT (DNo, DName, MgrSSN, MgrStartDate)
VALUES 
(1, 'Accounts', 123456789, '2010-05-15'),
(2, 'HR', 234567890, '2012-08-22'),
(3, 'Engineering', 345678901, '2015-03-10');


INSERT INTO DLOCATION (DNo, DLoc)
VALUES 
(1, 'New York'),
(2, 'Chicago'),
(3, 'San Francisco');

INSERT INTO EMPLOYEE (SSN, Name, Address, Sex, Salary, SuperSSN, DNo)
VALUES 
(123456789, 'John Scott', '123 Main St, NY', 'M', 55000, NULL, 1),
(234567890, 'Jane Doe', '456 Elm St, Chicago', 'F', 60000, 123456789, 2),
(345678901, 'Michael Scott', '789 Oak St, SF', 'M', 70000, NULL, 3),
(456789012, 'Sara Brown', '101 Pine St, SF', 'F', 65000, 345678901, 3);

INSERT INTO PROJECT (PNo, PName, PLocation, DNo)
VALUES 
(101, 'IoT', 'San Francisco', 3),
(102, 'Cloud Computing', 'Chicago', 2),
(103, 'Blockchain', 'New York', 1);

INSERT INTO WORKS_ON (SSN, PNo, Hours)
VALUES 
(123456789, 101, 40),
(234567890, 102, 30),
(345678901, 103, 35),
(456789012, 101, 40);


-- List all project numbers involving employees whose last name is 'Scott'
SELECT DISTINCT P.PNo
FROM PROJECT P
JOIN WORKS_ON W ON P.PNo = W.PNo
JOIN EMPLOYEE E ON W.SSN = E.SSN
WHERE E.Name LIKE '%Scott';

-- Show resulting salaries if every employee working on the 'IoT' project gets a 10% raise
UPDATE EMPLOYEE
SET Salary = Salary * 1.10
WHERE SSN IN (
    SELECT W.SSN
    FROM WORKS_ON W
    JOIN PROJECT P ON W.PNo = P.PNo
    WHERE P.PName = 'IoT'
);

-- Find the sum of salaries, max salary, min salary, and avg salary for 'Accounts' department
SELECT 
    SUM(Salary) AS TotalSalary,
    MAX(Salary) AS MaxSalary,
    MIN(Salary) AS MinSalary,
    AVG(Salary) AS AvgSalary
FROM EMPLOYEE
WHERE DNo = (SELECT DNo FROM DEPARTMENT WHERE DName = 'Accounts');

-- Retrieve names of employees who work on all projects controlled by department #5
SELECT E.Name
FROM EMPLOYEE E
WHERE NOT EXISTS (
    SELECT P.PNo
    FROM PROJECT P
    WHERE P.DNo = 5
    AND NOT EXISTS (
        SELECT W.PNo
        FROM WORKS_ON W
        WHERE W.SSN = E.SSN AND W.PNo = P.PNo
    )
);

-- Retrieve department numbers and employee counts for departments with > 5 employees
SELECT DNo, COUNT(*) AS NumEmployees
FROM EMPLOYEE
GROUP BY DNo
HAVING COUNT(*) > 5;


-- Create a view showing name, department name, and location of all employees
CREATE VIEW EmployeeDetails AS
SELECT E.Name, D.DName AS DeptName, DL.DLoc AS DeptLocation
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DNo = D.DNo
JOIN DLOCATION DL ON D.DNo = DL.DNo;


-- Trigger to prevent deletion of projects currently being worked on
DELIMITER //
CREATE TRIGGER preventProjectDeletion
BEFORE DELETE ON PROJECT
FOR EACH ROW
BEGIN
    DECLARE project_count INT;
    SELECT COUNT(*) INTO project_count
    FROM WORKS_ON
    WHERE PNo = OLD.PNo;
    IF project_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete project currently being worked on.';
    END IF;
END;
//
DELIMITER ;
