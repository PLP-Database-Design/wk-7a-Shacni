-- Create a new table in 1NF by splitting the multi-valued Products column
CREATE TABLE OrderDetails_1NF AS
SELECT 
    OrderID, 
    CustomerName, 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', n.digit+1), ',', -1)) AS Product
FROM 
    ProductDetail
JOIN 
    (SELECT 0 AS digit UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) n
ON 
    LENGTH(REPLACE(Products, ',', '')) <= LENGTH(Products)-n.digit
WHERE 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', n.digit+1), ',', -1)) != ''
ORDER BY 
    OrderID, Product;
    
-- Create Orders table to store order information (removes partial dependency)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL
);

-- Create OrderItems table to store product details (fully dependent on composite key)
CREATE TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Populate Orders table with distinct order information
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Populate OrderItems table with product details
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;


