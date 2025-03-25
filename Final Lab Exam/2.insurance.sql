CREATE DATABASE insurance;
USE insurance;

-- Creating Tables
CREATE TABLE person (
    driver_id VARCHAR(255) PRIMARY KEY,
    driver_name TEXT NOT NULL,
    address TEXT NOT NULL
);

CREATE TABLE car (
    reg_no VARCHAR(255) PRIMARY KEY,
    model TEXT NOT NULL,
    c_year INTEGER
);

CREATE TABLE accident (
    report_no INTEGER PRIMARY KEY,
    accident_date DATE,
    location TEXT
);

CREATE TABLE owns (
    driver_id VARCHAR(255) NOT NULL,
    reg_no VARCHAR(255) NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
    FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE
);

CREATE TABLE participated (
    driver_id VARCHAR(255) NOT NULL,
    reg_no VARCHAR(255) NOT NULL,
    report_no INTEGER NOT NULL,
    damage_amount FLOAT NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
    FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE,
    FOREIGN KEY (report_no) REFERENCES accident(report_no)
);

-- Inserting Data
INSERT INTO person VALUES
    ('D111', 'Driver_1', 'Kuvempunagar, Mysuru'),
    ('D222', 'Smith', 'JP Nagar, Mysuru'),
    ('D333', 'Driver_3', 'Udaygiri, Mysuru'),
    ('D444', 'Driver_4', 'Rajivnagar, Mysuru'),
    ('D555', 'Driver_5', 'Vijayanagar, Mysore');

INSERT INTO car VALUES
    ('KA-20-AB-4223', 'Swift', 2020),
    ('KA-20-BC-5674', 'Mazda', 2017),
    ('KA-21-AC-5473', 'Alto', 2015),
    ('KA-21-BD-4728', 'Triber', 2019),
    ('KA-09-MA-1234', 'Tiago', 2018);

INSERT INTO accident VALUES
    (43627, '2020-04-05', 'Nazarbad, Mysuru'),
    (56345, '2019-12-16', 'Gokulam, Mysuru'),
    (63744, '2020-05-14', 'Vijaynagar, Mysuru'),
    (54634, '2019-08-30', 'Kuvempunagar, Mysuru'),
    (65738, '2021-01-21', 'JSS Layout, Mysuru'),
    (66666, '2021-01-21', 'JSS Layout, Mysuru');

INSERT INTO owns VALUES
    ('D111', 'KA-20-AB-4223'),
    ('D222', 'KA-20-BC-5674'),
    ('D333', 'KA-21-AC-5473'),
    ('D444', 'KA-21-BD-4728'),
    ('D222', 'KA-09-MA-1234');

INSERT INTO participated VALUES
    ('D111', 'KA-20-AB-4223', 43627, 20000),
    ('D222', 'KA-20-BC-5674', 56345, 49500),
    ('D333', 'KA-21-AC-5473', 63744, 15000),
    ('D444', 'KA-21-BD-4728', 54634, 5000),
    ('D222', 'KA-09-MA-1234', 65738, 25000);

-- Queries
-- Find the total number of people who owned a car involved in accidents in 2021
SELECT COUNT(DISTINCT o.driver_id) 
FROM owns o 
JOIN participated p ON o.reg_no = p.reg_no 
JOIN accident a ON p.report_no = a.report_no 
WHERE YEAR(a.accident_date) = 2021;

-- Find the number of accidents involving cars belonging to Smith
SELECT COUNT(DISTINCT p.report_no) 
FROM participated p 
JOIN owns o ON p.reg_no = o.reg_no 
JOIN person pe ON o.driver_id = pe.driver_id 
WHERE pe.driver_name = 'Smith';

-- Add a new accident
INSERT INTO accident VALUES (45562, '2024-04-05', 'Mandya');
INSERT INTO participated VALUES ('D222', 'KA-21-BD-4728', 45562, 50000);

-- Delete the Mazda belonging to Smith
DELETE FROM car
WHERE model = 'Mazda' AND reg_no IN (
    SELECT car.reg_no FROM person p, owns o 
    WHERE p.driver_id = o.driver_id 
    AND o.reg_no = car.reg_no 
    AND p.driver_name = 'Smith'
);

-- Update the damage amount
UPDATE participated
SET damage_amount = 10000
WHERE report_no = 65738 AND reg_no = 'KA-09-MA-1234';

-- Views
--  A view that shows models and year of cars that are involved in accident. 
CREATE VIEW CarsInAccident AS
SELECT DISTINCT model, c_year
FROM car c, participated p
WHERE c.reg_no = p.reg_no;

SELECT * FROM CarsInAccident; 

-- Triggers 
-- Prevent a driver from participating in more than 3 accidents in a given year

DELIMITER //
CREATE TRIGGER check_accident_limit
BEFORE INSERT ON participated
FOR EACH ROW
BEGIN
    DECLARE accident_count INT;
    SELECT COUNT(*) INTO accident_count
    FROM participated p
    JOIN accident a ON p.report_no = a.report_no
    WHERE p.driver_id = NEW.driver_id AND YEAR(a.accident_date) = YEAR(CURDATE());
    
    IF accident_count >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Driver cannot participate in more than 3 accidents in a year';
    END IF;
END//
DELIMITER ;


-- DELIMITER //
-- CREATE TRIGGER PreventParticipation
-- BEFORE INSERT ON participated
-- FOR EACH ROW
-- BEGIN
--     IF 3 <= (
--         SELECT COUNT(*) FROM participated 
--         WHERE driver_id = NEW.driver_id
--     ) THEN
--         SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Driver has already participated in 3 accidents';
--     END IF;
-- END;
-- //
-- DELIMITER ;

-- INSERT INTO participated VALUES ('D222', 'KA-20-AB-4223', 66666, 20000);