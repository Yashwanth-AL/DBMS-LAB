
CREATE TABLE Customer (
    cust_no INT PRIMARY KEY,
    cname VARCHAR(255),
    city VARCHAR(255)
);

CREATE TABLE Orders (
    order_no INT PRIMARY KEY,
    odate DATE,
    cust_no INT,
    order_amt INT,
    FOREIGN KEY (cust_no) REFERENCES Customer(cust_no) ON DELETE CASCADE
);

CREATE TABLE Item (
    item INT PRIMARY KEY,
    unitprice INT
);

CREATE TABLE Order_item (
    order_no INT,
    item INT,
    qty INT,
    PRIMARY KEY (order_no, item),
    FOREIGN KEY (order_no) REFERENCES Orders(order_no) ON DELETE CASCADE,
    FOREIGN KEY (item) REFERENCES Item(item) ON DELETE CASCADE
);

CREATE TABLE Warehouse (
    warehouse_no INT PRIMARY KEY,
    city VARCHAR(255)
);

CREATE TABLE Shipment (
    order_no INT PRIMARY KEY,
    warehouse_no INT,
    ship_date DATE,
    FOREIGN KEY (order_no) REFERENCES Orders(order_no) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_no) REFERENCES Warehouse(warehouse_no) ON DELETE CASCADE
);


-- Insert Customers
INSERT INTO Customer (cust_no, cname, city) VALUES
(1, 'Kumar', 'Mumbai'),
(2, 'Sharma', 'Delhi'),
(3, 'Ali', 'Chennai');

-- Insert Orders
INSERT INTO Orders (order_no, odate, cust_no, order_amt) VALUES
(101, '2025-01-01', 1, 0),
(102, '2025-01-02', 2, 0),
(103, '2025-01-03', 3, 0);

-- Insert Items
INSERT INTO Item (item, unitprice) VALUES
(1001, 500),
(1002, 300),
(1003, 150);

-- Insert Order Items
INSERT INTO Order_item (order_no, item, qty) VALUES
(101, 1001, 2),
(101, 1002, 1),
(102, 1003, 3),
(103, 1002, 4);

-- Insert Warehouses
INSERT INTO Warehouse (warehouse_no, city) VALUES
(1, 'Mumbai'),
(2, 'Delhi'),
(3, 'Chennai');

-- Insert Shipments
INSERT INTO Shipment (order_no, warehouse_no, ship_date) VALUES
(101, 2, '2025-01-04'),
(102, 1, '2025-01-05'),
(103, 3, '2025-01-06');



-- List Order# and Ship_date for all orders shipped from Warehouse# "W2"
SELECT o.order_no, s.ship_date
FROM Orders o
JOIN Shipment s ON o.order_no = s.order_no
WHERE s.warehouse_no = 2;

-- List Warehouse information for orders supplied to "Kumar"
SELECT o.order_no, w.*
FROM Customer c
JOIN Orders o ON c.cust_no = o.cust_no
JOIN Shipment s ON o.order_no = s.order_no
JOIN Warehouse w ON s.warehouse_no = w.warehouse_no
WHERE c.cname = 'Kumar';

-- Produce a listing: Cname, #ofOrders, Avg_Order_Amt
SELECT c.cname, COUNT(o.order_no) AS no_of_orders, AVG(o.order_amt) AS avg_order_amt
FROM Customer c
LEFT JOIN Orders o ON c.cust_no = o.cust_no
GROUP BY c.cname;

-- Delete all orders for customer "Kumar"
DELETE FROM Orders
WHERE cust_no = (SELECT cust_no FROM Customer WHERE cname = 'Kumar');

-- Find the item with the maximum unit price
SELECT item, unitprice
FROM Item
WHERE unitprice = (SELECT MAX(unitprice) FROM Item);

-- Create a view to display orderID and shipment date of all orders shipped from a warehouse
CREATE VIEW Orders_Warehouse AS
SELECT o.order_no, s.ship_date
FROM Orders o
JOIN Shipment s ON o.order_no = s.order_no;

-- Trigger to update order amount based on quantity and unit price
DELIMITER //
CREATE TRIGGER UpdateOrderAmount
BEFORE INSERT ON Order_item
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET order_amt = (NEW.qty * (SELECT DISTINCT unitprice FROM Item WHERE item = NEW.item))
    WHERE Orders.order_no = NEW.order_no;
END;
//
DELIMITER ;
