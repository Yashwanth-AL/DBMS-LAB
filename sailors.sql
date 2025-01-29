CREATE DATABASE sailors;
USE SAILORS;

CREATE TABLE sailors (
    sid INT NOT NULL PRIMARY KEY,
    sname VARCHAR(25),
    rating INT NOT NULL,
    age INT NOT NULL
);

CREATE TABLE boat (
    bid INT NOT NULL PRIMARY KEY,
    bname VARCHAR(30),
    color VARCHAR(15)
);

CREATE TABLE rservers (
    sid INT NOT NULL,
    bid INT NOT NULL,
    date DATE,
    FOREIGN KEY (sid) REFERENCES sailors(sid) ON DELETE CASCADE,
    FOREIGN KEY (bid) REFERENCES boat(bid) ON DELETE CASCADE
);

INSERT INTO sailors (sid, sname, rating, age)
VALUES
(1, 'Albert', 7, 35),
(2, 'John', 9, 40),
(3, 'Sarah', 8, 29),
(4, 'James', 6, 45),
(5, 'Eva', 9, 32);


INSERT INTO boat (bid, bname, color)
VALUES
(101, 'Stormy', 'Red'),
(102, 'Sea Breeze', 'Blue'),
(103, 'Oceanic', 'Green'),
(104, 'Sunshine', 'Yellow');

INSERT INTO rservers (sid, bid, dte)
VALUES
(1, 101, '2025-01-01'),
(2, 103, '2025-01-02'),
(3, 102, '2025-01-05'),
(2, 104, '2025-01-06'),
(4, 103, '2025-01-07'),
(5, 101, '2025-01-08');


-- Find the colors of boats reserved by Albert
SELECT b.color
FROM boat b, sailors s, rservers r
WHERE s.sid = r.sid AND b.bid = r.bid AND s.sname = 'Albert';

-- Find all sailor IDs with a rating >= 8 or who reserved boat 103
(SELECT sid FROM sailors WHERE rating >= 8)
UNION
(SELECT DISTINCT s.sid FROM sailors s JOIN rservers r ON s.sid = r.sid WHERE r.bid = 103);

-- Find names of sailors who have not reserved a boat whose name contains "storm"
SELECT DISTINCT s.sname
FROM sailors s
LEFT JOIN rservers r ON s.sid = r.sid
LEFT JOIN boat b ON b.bid = r.bid
WHERE r.sid IS NULL OR b.bname NOT LIKE '%storm%'
ORDER BY s.sname ASC;

-- Find names of sailors who reserved all boats
SELECT s.sname
FROM sailors s
WHERE NOT EXISTS (
    SELECT * FROM boat b
    WHERE NOT EXISTS (
        SELECT * FROM rservers r
        WHERE r.sid = s.sid AND r.bid = b.bid
    )
);

-- Find the name and age of the oldest sailor
SELECT sname, age
FROM sailors
WHERE age = (SELECT MAX(age) FROM sailors);

-- For each boat reserved by at least 5 sailors aged >= 40, find the boat ID and average age
SELECT r.bid, AVG(s.age) AS avg_age
FROM rservers r
JOIN sailors s ON r.sid = s.sid
WHERE s.age >= 40
GROUP BY r.bid
HAVING COUNT(DISTINCT r.sid) >= 5;

-- Create a view showing boat names and colors reserved by sailors with a specific rating
CREATE VIEW ReservedBoats AS
SELECT b.bname, b.color, s.rating
FROM boat b
JOIN rservers r ON b.bid = r.bid
JOIN sailors s ON r.sid = s.sid;

-- Trigger to prevent deletion of boats with active reservations
DELIMITER //
CREATE TRIGGER prevent_delete
BEFORE DELETE ON boat
FOR EACH ROW
BEGIN
    DECLARE reservation_count INT;
    SELECT COUNT(*) INTO reservation_count
    FROM rservers
    WHERE bid = OLD.bid;
    IF reservation_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete. Active reservations exist.';
    END IF;
END;
//
DELIMITER ;
