CREATE DATABASE enrollment;
USE enrollment;

-- Create tables
CREATE TABLE Student (
    regno VARCHAR(13) PRIMARY KEY,
    name VARCHAR(25) NOT NULL,
    major VARCHAR(25) NOT NULL,
    bdate DATE NOT NULL
);

CREATE TABLE Course (
    course INT PRIMARY KEY,
    cname VARCHAR(30) NOT NULL,
    dept VARCHAR(100) NOT NULL
);

CREATE TABLE Enroll (
    regno VARCHAR(13),
    course INT,
    sem INT NOT NULL,
    marks INT NOT NULL,
    FOREIGN KEY (regno) REFERENCES Student(regno) ON DELETE CASCADE,
    FOREIGN KEY (course) REFERENCES Course(course) ON DELETE CASCADE
);

CREATE TABLE TextBook (
    bookIsbn INT PRIMARY KEY,
    book_title VARCHAR(40) NOT NULL,
    publisher VARCHAR(25) NOT NULL,
    author VARCHAR(25) NOT NULL
);

CREATE TABLE BookAdoption (
    course INT NOT NULL,
    sem INT NOT NULL,
    bookIsbn INT NOT NULL,
    FOREIGN KEY (bookIsbn) REFERENCES TextBook(bookIsbn) ON DELETE CASCADE,
    FOREIGN KEY (course) REFERENCES Course(course) ON DELETE CASCADE
);

-- Insert data
INSERT INTO Student VALUES
("01HF235", "Student_1", "CSE", "2001-05-15"),
("01HF354", "Student_2", "Literature", "2002-06-10"),
("01HF254", "Student_3", "Philosophy", "2000-04-04"),
("01HF653", "Student_4", "History", "2003-10-12"),
("01HF234", "Student_5", "Computer Economics", "2001-10-10");

INSERT INTO Course VALUES
(001, "DBMS", "CS"),
(002, "Literature", "English"),
(003, "Philosophy", "Philosophy"),
(004, "History", "Social Science"),
(005, "Computer Economics", "CS");

INSERT INTO Enroll VALUES
("01HF235", 001, 5, 85),
("01HF354", 002, 6, 87),
("01HF254", 003, 3, 95),
("01HF653", 004, 3, 80),
("01HF234", 005, 5, 75);

INSERT INTO TextBook VALUES
(241563, "Operating Systems", "Pearson", "Silberschatz"),
(532678, "Complete Works of Shakespeare", "Oxford", "Shakespeare"),
(453723, "Immanuel Kant", "Delphi Classics", "Immanuel Kant"),
(278345, "History of the World", "The Times", "Richard Overy"),
(426784, "Behavioural Economics", "Pearson", "David Orrell");

INSERT INTO BookAdoption VALUES
(001, 5, 241563),
(002, 6, 532678),
(003, 3, 453723),
(004, 3, 278345),
(001, 6, 426784);

-- Retrieve data
SELECT * FROM Student;
SELECT * FROM Course;
SELECT * FROM Enroll;
SELECT * FROM BookAdoption;
SELECT * FROM TextBook;

-- Add new textbook and adopt it in a department
INSERT INTO TextBook VALUES
(123456, "Chandan The Autobiography", "Pearson", "Chandan");

INSERT INTO BookAdoption VALUES
(001, 5, 123456);

-- List textbooks for 'CS' department courses that use more than two books
SELECT c.course, t.bookIsbn, t.book_title
FROM Course c
JOIN BookAdoption ba ON c.course = ba.course
JOIN TextBook t ON ba.bookIsbn = t.bookIsbn
WHERE c.dept = 'CS'
AND 2 < (SELECT COUNT(bookIsbn) FROM BookAdoption b WHERE c.course = b.course)
ORDER BY t.book_title;

-- List departments that have all their books from a specific publisher
SELECT DISTINCT c.dept
FROM Course c
WHERE c.dept IN (
    SELECT c.dept
    FROM Course c
    JOIN BookAdoption b ON c.course = b.course
    JOIN TextBook t ON t.bookIsbn = b.bookIsbn
    WHERE t.publisher = 'Pearson'
)
AND c.dept NOT IN (
    SELECT c.dept
    FROM Course c
    JOIN BookAdoption b ON c.course = b.course
    JOIN TextBook t ON t.bookIsbn = b.bookIsbn
    WHERE t.publisher != 'Pearson'
);

-- List students who scored max marks in 'DBMS'
SELECT name FROM Student s
JOIN Enroll e ON s.regno = e.regno
JOIN Course c ON e.course = c.course
WHERE c.cname = "DBMS"
AND e.marks = (
    SELECT MAX(marks)
    FROM Enroll e1
    JOIN Course c1 ON c1.course = e1.course
    WHERE c1.cname = "DBMS"
);

--Views
-- Create a view to display all the courses opted by a student along with marks obtained.
CREATE VIEW CoursesOptedByStudent AS
SELECT c.cname, e.marks 
FROM Course c
JOIN Enroll e ON e.course = c.course
WHERE e.regno = "01HF235";
SELECT * FROM CoursesOptedByStudent;


-- Create trigger to prevent enrollment if marks are below threshold
DELIMITER //
CREATE TRIGGER PreventEnrollment
BEFORE INSERT ON Enroll
FOR EACH ROW
BEGIN
    IF (NEW.marks < 40) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Marks below threshold';
    END IF;
END;//
DELIMITER ;

INSERT INTO Enroll VALUES
("01HF235", 002, 5, 5); -- Will give an error since marks are less than 40
