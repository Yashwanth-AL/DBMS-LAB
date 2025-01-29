CREATE TABLE STUDENT (
    regno VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255),
    major VARCHAR(255),
    bdate DATE
);

CREATE TABLE COURSE (
    course_no INT PRIMARY KEY,
    cname VARCHAR(255),
    dept VARCHAR(255)
);

CREATE TABLE ENROLL (
    regno VARCHAR(50),
    course_no INT,
    sem INT,
    marks INT,
    FOREIGN KEY (regno) REFERENCES STUDENT(regno) ON DELETE CASCADE,
    FOREIGN KEY (course_no) REFERENCES COURSE(course_no) ON DELETE CASCADE
);

CREATE TABLE TEXTBOOK (
    book_ISBN INT PRIMARY KEY,
    book_title VARCHAR(255),
    publisher VARCHAR(255),
    author VARCHAR(255)
);

CREATE TABLE BOOK_ADOPTION (
    course_no INT,
    sem INT,
    book_ISBN INT,
    FOREIGN KEY (course_no) REFERENCES COURSE(course_no) ON DELETE CASCADE,
    FOREIGN KEY (book_ISBN) REFERENCES TEXTBOOK(book_ISBN) ON DELETE CASCADE
);


-- Insert into STUDENT table
INSERT INTO STUDENT (regno, name, major, bdate) VALUES
('S001', 'John Doe', 'Computer Science', '2000-02-15'),
('S002', 'Jane Smith', 'Electrical Engineering', '2001-03-22'),
('S003', 'Mark Brown', 'Mathematics', '1999-07-19');

-- Insert into COURSE table
INSERT INTO COURSE (course_no, cname, dept) VALUES
(1, 'Database Management Systems', 'CS'),
(2, 'Computer Networks', 'CS'),
(3, 'Signals and Systems', 'EE'),
(4, 'Calculus', 'Math');

-- Insert into ENROLL table (Student Enrollments)
INSERT INTO ENROLL (regno, course_no, sem, marks) VALUES
('S001', 1, 2, 95),
('S001', 2, 2, 85),
('S002', 1, 2, 75),
('S002', 3, 2, 80),
('S003', 4, 1, 92);

-- Insert into TEXTBOOK table
INSERT INTO TEXTBOOK (book_ISBN, book_title, publisher, author) VALUES
(987654321, 'Advanced Database Systems', 'Springer', 'John Smith'),
(123456789, 'Computer Networks', 'McGraw-Hill', 'Andrew Tanenbaum'),
(112233445, 'Mathematical Methods for Engineers', 'Wiley', 'Ralph Steadman');

-- Insert into BOOK_ADOPTION table (Book Adoption for Courses)
INSERT INTO BOOK_ADOPTION (course_no, sem, book_ISBN) VALUES
(1, 2, 987654321),  -- DBMS Course adopts "Advanced Database Systems"
(2, 2, 123456789),  -- Computer Networks adopts "Computer Networks"
(4, 1, 112233445);  -- Calculus adopts "Mathematical Methods for Engineers"


-- Add a new textbook and make it adopted by some department
INSERT INTO TEXTBOOK (book_ISBN, book_title, publisher, author)
VALUES (987654321, 'Advanced Database Systems', 'Springer', 'John Smith');

INSERT INTO BOOK_ADOPTION (course_no, sem, book_ISBN)
VALUES (1, 2, 987654321);

-- Produce a list of textbooks (include Course#, Book-ISBN, Book-title) in alphabetical order
-- for courses offered by the 'CS' department that use more than two books
SELECT c.course_no, t.book_ISBN, t.book_title
FROM COURSE c
JOIN BOOK_ADOPTION b ON c.course_no = b.course_no
JOIN TEXTBOOK t ON b.book_ISBN = t.book_ISBN
WHERE c.dept = 'CS'
AND (SELECT COUNT(*) FROM BOOK_ADOPTION ba WHERE ba.course_no = c.course_no) > 2
ORDER BY t.book_title ASC;

-- List any department that has all its adopted books published by a specific publisher
SELECT c.dept
FROM COURSE c
WHERE NOT EXISTS (
    SELECT b.book_ISBN
    FROM BOOK_ADOPTION b
    JOIN TEXTBOOK t ON b.book_ISBN = t.book_ISBN
    WHERE c.course_no = b.course_no AND t.publisher != 'Springer'
);

-- List students who have scored the maximum marks in the 'DBMS' course
SELECT s.*
FROM STUDENT s
JOIN ENROLL e ON s.regno = e.regno
JOIN COURSE c ON c.course_no = e.course_no
WHERE c.cname = 'Database Management Systems'
AND e.marks = (SELECT MAX(marks) FROM ENROLL WHERE course_no = c.course_no);

-- Create a view to display all the courses opted by a student along with marks obtained
CREATE VIEW StudentCourses AS
SELECT c.cname, s.name, e.marks
FROM STUDENT s
JOIN ENROLL e ON s.regno = e.regno
JOIN COURSE c ON c.course_no = e.course_no;


-- Trigger to prevent students from enrolling in a course if marks prerequisite < 40
DELIMITER //
CREATE TRIGGER BeforeEnroll
BEFORE INSERT ON ENROLL
FOR EACH ROW
BEGIN
    IF NEW.marks < 40 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Marks prerequisite not met';
    END IF;
END;
//
DELIMITER ;
