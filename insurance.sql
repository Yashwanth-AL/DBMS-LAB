CREATE TABLE PERSON (
    driver_id VARCHAR(18) PRIMARY KEY,
    name VARCHAR(25),
    address VARCHAR(50)
);

CREATE TABLE CAR (
    regno VARCHAR(19) PRIMARY KEY,
    model VARCHAR(10),
    year INT
);

CREATE TABLE ACCIDENT (
    report_number INT NOT NULL PRIMARY KEY,
    acc_date DATE,
    location VARCHAR(50)
);

CREATE TABLE OWNS (
    driver_id VARCHAR(18),
    regno VARCHAR(19),
    FOREIGN KEY (driver_id) REFERENCES PERSON(driver_id) ON DELETE CASCADE,
    FOREIGN KEY (regno) REFERENCES CAR(regno) ON DELETE CASCADE
);

CREATE TABLE PARTICIPATED (
    driver_id VARCHAR(18),
    regno VARCHAR(19),
    report_number INT NOT NULL,
    damage_amt INT NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES PERSON(driver_id) ON DELETE CASCADE,
    FOREIGN KEY (regno) REFERENCES CAR(regno) ON DELETE CASCADE,
    FOREIGN KEY (report_number) REFERENCES ACCIDENT(report_number) ON DELETE CASCADE
);

-- Insert data into PERSON table
INSERT INTO PERSON (driver_id, name, address)
VALUES
('D001', 'Smith', '123 Maple St'),
('D002', 'John', '456 Oak St'),
('D003', 'Alice', '789 Pine St'),
('D004', 'Bob', '321 Elm St'),
('D005', 'Eve', '654 Willow St');

-- Insert data into CAR table
INSERT INTO CAR (regno, model, year)
VALUES
('KA09MA1234', 'Mazda', 2018),
('KA01HY5678', 'Hyundai', 2020),
('KA03TO3456', 'Toyota', 2019),
('KA05FO7890', 'Ford', 2021),
('KA07HO1235', 'Honda', 2022);

-- Insert data into ACCIDENT table
INSERT INTO ACCIDENT (report_number, acc_date, location)
VALUES
(31, '2021-05-20', 'Highway 1'),
(32, '2021-06-15', 'Downtown'),
(33, '2021-07-10', 'City Park'),
(34, '2022-02-20', 'River Bridge');

-- Insert data into OWNS table
INSERT INTO OWNS (driver_id, regno)
VALUES
('D001', 'KA09MA1234'),
('D001', 'KA01HY5678'),
('D002', 'KA03TO3456'),
('D003', 'KA05FO7890'),
('D004', 'KA07HO1235');

-- Insert data into PARTICIPATED table
INSERT INTO PARTICIPATED (driver_id, regno, report_number, damage_amt)
VALUES
('D001', 'KA09MA1234', 31, 15000),
('D001', 'KA01HY5678', 32, 20000),
('D002', 'KA03TO3456', 31, 30000),
('D003', 'KA05FO7890', 33, 25000),
('D004', 'KA07HO1235', 34, 40000);


-- Find the total number of people who owned cars involved in accidents in 2021
SELECT COUNT(DISTINCT P.driver_id) AS total_people_involved
FROM PERSON P
JOIN OWNS O ON P.driver_id = O.driver_id
JOIN PARTICIPATED PA ON O.regno = PA.regno
JOIN ACCIDENT A ON PA.report_number = A.report_number
WHERE YEAR(A.acc_date) = 2021;

-- Find the number of accidents involving cars owned by "Smith"
SELECT COUNT(*) AS accidents_involving_smith
FROM PERSON P
JOIN OWNS O ON P.driver_id = O.driver_id
JOIN PARTICIPATED PA ON O.regno = PA.regno
WHERE P.name = 'Smith';

-- Add a new accident
INSERT INTO ACCIDENT VALUES (78, '2022-01-01', 'ABC Rd');

-- Delete a Mazda owned by "Smith"
DELETE FROM OWNS
WHERE driver_id = (SELECT driver_id FROM PERSON WHERE name = 'Smith')
AND regno IN (SELECT regno FROM CAR WHERE model = 'Mazda');

-- Update the damage amount for a specific car and accident
UPDATE PARTICIPATED
SET damage_amt = 170000
WHERE regno = 'KA09MA1234'
AND report_number = (SELECT report_number FROM ACCIDENT WHERE report_number = 32);

-- Create a view showing models and years of cars involved in accidents
CREATE VIEW AccidentView AS
SELECT DISTINCT C.model, C.year
FROM CAR C
JOIN PARTICIPATED PA ON C.regno = PA.regno;

-- Trigger to prevent drivers from participating in more than 3 accidents in a year
DELIMITER //
CREATE TRIGGER PreventExcessiveAccidents
BEFORE INSERT ON PARTICIPATED
FOR EACH ROW
BEGIN
    DECLARE accident_count INT;
    SELECT COUNT(*) INTO accident_count
    FROM PARTICIPATED PA
    JOIN ACCIDENT A ON PA.report_number = A.report_number
    WHERE PA.driver_id = NEW.driver_id
    AND YEAR(A.acc_date) = YEAR(CURDATE());
    IF accident_count >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Driver cannot participate in more than 3 accidents in a year.';
    END IF;
END;
//
DELIMITER ;
