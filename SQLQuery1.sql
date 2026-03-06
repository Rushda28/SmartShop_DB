-- Drop tables in order (Child tables first, then Parent tables)
DROP TABLE IF EXISTS Sales;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Suppliers;
GO

-- Create Tables with all required columns
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    SupplierID INT
);

CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY,
    ProductID INT,
    StockLevel INT,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Email VARCHAR(100),
    RegistrationDate DATE,
    City VARCHAR(50),
    ContactNumber VARCHAR(20)
);

CREATE TABLE Sales (
    SalesID INT PRIMARY KEY,
    OrderDate DATETIME,
    CustomerID INT,
    ProductID INT,
    BranchID INT,
    Quantity INT,
    Price DECIMAL(10,2)
);

-- Populate Products
INSERT INTO Products (ProductID, ProductName, Category, Price, SupplierID) VALUES 
(101, 'Wireless Mouse', 'Electronics', 25.00, 1),
(102, 'Mechanical Keyboard', 'Electronics', 75.00, 1),
(103, 'Office Chair', 'Furniture', 120.00, 2),
(104, 'Desk Lamp', 'Home Decor', 15.00, 2),
(105, 'USB-C Cable', 'Electronics', 10.00, 1);

-- Populate Inventory
INSERT INTO Inventory (InventoryID, ProductID, StockLevel) VALUES (500, 101, 50);

-- Populate 12 Customers for Treemap Density
INSERT INTO Customers (CustomerID, CustomerName, Email, RegistrationDate, City, ContactNumber) VALUES
(1, 'Rachel Zane', 'rachel@law.com', '2026-01-10', 'London', '07700900111'),
(2, 'Mike Ross', 'mike@law.com', '2026-01-12', 'London', '07700900222'),
(3, 'Jessica Pearson', 'jessica@pearson.com', '2026-01-15', 'London', '07700900333'),
(4, 'Harvey Specter', 'harvey@specter.com', '2026-01-20', 'London', '07700900444'),
(5, 'Louis Litt', 'louis@litt.com', '2026-02-01', 'Manchester', '07700900555'),
(6, 'Donna Paulsen', 'donna@specter.com', '2026-02-05', 'Manchester', '07700900666'),
(7, 'Robert Zane', 'robert@zane.com', '2026-02-10', 'Birmingham', '07700900777'),
(8, 'Katrina Bennett', 'katrina@law.com', '2026-02-15', 'Liverpool', '07700900888'),
(9, 'Alex Williams', 'alex@law.com', '2026-02-18', 'Liverpool', '07700900999'),
(10, 'Samantha Wheeler', 'sam@law.com', '2026-02-20', 'Bristol', '07700901000'),
(11, 'Gretchen Bodinski', 'gretchen@law.com', '2026-02-22', 'Bristol', '07700901001'),
(12, 'Sheila Sazs', 'sheila@columbia.edu', '2026-02-25', 'Glasgow', '07700901002');


BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE Inventory SET StockLevel = StockLevel - 1 WHERE ProductID = 101;

        INSERT INTO Sales (SalesID, ProductID, Quantity, OrderDate, BranchID) 
        VALUES (1001, 101, 1, GETDATE(), 5);

        COMMIT TRANSACTION;
        PRINT 'SUCCESS: Transaction Committed.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'ERROR: ' + ERROR_MESSAGE();
    END CATCH;

    SELECT StockLevel FROM Inventory WHERE ProductID = 101;

-- CONCURRENCY DEMO: Locking the 'Last Item'
--Session 1 (User 1 )
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

-- This command selects the item and places an Update Lock on the row
    SELECT StockLevel FROM Inventory WITH (UPDLOCK, ROWLOCK) 
    WHERE ProductID = 101;
    -- (This holds the lock until COMMIT or ROLLBACK is called)

--Session 1 (User 1 )
COMMIT;

Use SmartShopDB
Go


DELETE FROM Sales;

-- Insert Sales for January (High Peak ~ $1,800)
INSERT INTO Sales (SalesID, OrderDate, CustomerID, ProductID, BranchID, Quantity, Price) VALUES 
(1001, '2026-01-05', 1, 1, 5, 2, 800.00), -- Laptop
(1002, '2026-01-15', 2, 101, 5, 1, 25.00),
(1003, '2026-01-20', 3, 2, 5, 4, 50.00);

-- Insert Sales for February (Sharp Dip ~ $400)
INSERT INTO Sales (SalesID, OrderDate, CustomerID, ProductID, BranchID, Quantity, Price) VALUES 
(1004, '2026-02-10', 4, 2, 5, 2, 25.00),
(1005, '2026-02-20', 5, 101, 5, 1, 25.00);

-- Insert Sales for March (Moderate Rise ~ $500)
INSERT INTO Sales (SalesID, OrderDate, CustomerID, ProductID, BranchID, Quantity, Price) VALUES 
(1006, '2026-03-05', 6, 2, 5, 5, 25.00),
(1007, '2026-03-15', 7, 101, 5, 3, 25.00);

-- Insert Sales for April (Secondary Peak ~ $1,100)
INSERT INTO Sales (SalesID, OrderDate, CustomerID, ProductID, BranchID, Quantity, Price) VALUES 
(1008, '2026-04-10', 8, 1, 5, 1, 800.00), -- Laptop
(1009, '2026-04-25', 9, 2, 5, 4, 25.00);

-- Insert Sales for May (Lowering Trend ~ $400)
INSERT INTO Sales (SalesID, OrderDate, CustomerID, ProductID, BranchID, Quantity, Price) VALUES 
(1010, '2026-05-12', 10, 101, 5, 1, 25.00),
(1011, '2026-05-28', 11, 2, 5, 2, 25.00);

-- Insert Sales for June (Steady/Low ~ $350)
INSERT INTO Sales (SalesID, OrderDate, CustomerID, ProductID, BranchID, Quantity, Price) VALUES 
(1012, '2026-06-15', 12, 101, 5, 1, 25.00);



-- Ensure categories exist in your Product table first
-- Category Distribution: Electronics (Top), Home, Fashion, Health
UPDATE Products SET Category = 'Electronics' WHERE ProductID IN (1, 101);
UPDATE Products SET Category = 'Home & Office' WHERE ProductID = 2;
-- (Assuming other ProductIDs exist for Fashion/Health)

-- Total Quantity breakdown for your 12 Sales:
-- Electronics: 18 units
-- Home & Office: 10 units
-- Fashion: 5 units
-- Health: 2 units

UPDATE Products SET Category = 'Electronics' WHERE ProductID IN (1, 101);
UPDATE Products SET Category = 'Home & Office' WHERE ProductID = 2;
UPDATE Products SET Category = 'Fashion' WHERE ProductID = 3;
UPDATE Products SET Category = 'Health' WHERE ProductID = 4;

-- ELECTRONICS (Quantity: 18) - The "Profit Driver"
INSERT INTO Sales (SalesID, ProductID, CustomerID, Quantity, Price, OrderDate, BranchID) VALUES 
(2001, 1, 1, 5, 800.00, '2026-01-10', 5),
(2002, 101, 2, 8, 25.00, '2026-01-15', 5),
(2003, 1, 3, 5, 800.00, '2026-02-05', 5);

-- HOME & OFFICE (Quantity: 10)
INSERT INTO Sales (SalesID, ProductID, CustomerID, Quantity, Price, OrderDate, BranchID) VALUES 
(2004, 2, 4, 10, 50.00, '2026-03-12', 5);

-- FASHION (Quantity: 5)
INSERT INTO Sales (SalesID, ProductID, CustomerID, Quantity, Price, OrderDate, BranchID) VALUES 
(2005, 3, 5, 5, 40.00, '2026-04-10', 5);

-- HEALTH (Quantity: 2) - The "Niche Market"
INSERT INTO Sales (SalesID, ProductID, CustomerID, Quantity, Price, OrderDate, BranchID) VALUES 
(2006, 4, 6, 2, 15.00, '2026-05-20', 5);

-- Fill remaining customers to reach high-density requirement (12 total)
INSERT INTO Sales (SalesID, ProductID, CustomerID, Quantity, Price, OrderDate, BranchID) VALUES 
(2007, 101, 7, 1, 25.00, '2026-06-01', 5),
(2008, 101, 8, 1, 25.00, '2026-06-05', 5),
(2009, 101, 9, 1, 25.00, '2026-06-10', 5),
(2010, 101, 10, 1, 25.00, '2026-06-15', 5),
(2011, 101, 11, 1, 25.00, '2026-06-20', 5),
(2012, 101, 12, 1, 25.00, '2026-06-25', 5);


-- Ensure Sales records create a clear ranking
-- Customer 1: High Spender ($1,600)
UPDATE Sales SET Quantity = 2, Price = 800 WHERE CustomerID = 1;

-- Customer 2: Medium Spender ($400)
UPDATE Sales SET Quantity = 8, Price = 50 WHERE CustomerID = 2;

-- Customer 3: Regular Spender ($200)
UPDATE Sales SET Quantity = 4, Price = 50 WHERE CustomerID = 3;

-- Customer 4: Lower Spender ($100)
UPDATE Sales SET Quantity = 2, Price = 50 WHERE CustomerID = 4;