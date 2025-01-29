-- Creating the Student table
CREATE TABLE Student (
    SID INT PRIMARY KEY,
    NAME VARCHAR(50) NOT NULL,
    BRANCH VARCHAR(10) NOT NULL,
    SEMESTER INT CHECK (SEMESTER BETWEEN 1 AND 8),
    ADDRESS VARCHAR(100),
    PHONE VARCHAR(15) UNIQUE,
    EMAIL VARCHAR(50) UNIQUE
);

-- Inserting 10 students
INSERT INTO Student (SID, NAME, BRANCH, SEMESTER, ADDRESS, PHONE, EMAIL) VALUES
(101, 'Amit Kumar', 'CSE', 5, 'Kuvempunagar', '9876543210', 'amit@example.com'),
(102, 'Bhavya Rao', 'ISE', 4, 'Vijayanagar', '9876543211', 'bhavya@example.com'),
(103, 'Chirag Reddy', 'CSE', 3, 'Kuvempunagar', '9876543212', 'chirag@example.com'),
(104, 'Divya Shetty', 'ECE', 6, 'Jayanagar', '9876543213', 'divya@example.com'),
(105, 'Esha Verma', 'CSE', 2, 'Hebbal', '9876543214', 'esha@example.com'),
(106, 'Farhan Khan', 'EEE', 7, 'Bogadi', '9876543215', 'farhan@example.com'),
(107, 'Gautam Naik', 'CSE', 8, 'Kuvempunagar', '9876543216', 'gautam@example.com'),
(108, 'Vasudev Joshi', 'ISE', 5, 'Saraswathipuram', '9876543217', 'vasudev@example.com'),
(109, 'Ishaan Gupta', 'CSE', 6, 'Jayalakshmipuram', '9876543218', 'ishaan@example.com'),
(110, 'Jaya Narayan', 'ECE', 3, 'Lalithadripura', '9876543219', 'jaya@example.com');

-- (a) Insert a new student
INSERT INTO Student (SID, NAME, BRANCH, SEMESTER, ADDRESS, PHONE, EMAIL) 
VALUES (111, 'Kiran R', 'CSE', 4, 'Kuvempunagar', '9876543220', 'kiranr@example.com');

-- (b) Modify the address of a student based on SID
UPDATE Student 
SET ADDRESS = 'Vijayanagar' 
WHERE SID = 103;

-- (c) Delete a student
DELETE FROM Student 
WHERE SID = 106;

-- (d) List all the students
SELECT * FROM Student;

-- (e) List all the students of the CSE branch
SELECT * FROM Student 
WHERE BRANCH = 'CSE';

-- (f) List all the students of the CSE branch who reside in Kuvempunagar
SELECT * FROM Student 
WHERE BRANCH = 'CSE' AND ADDRESS = 'Kuvempunagar';
