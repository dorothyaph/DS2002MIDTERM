USE groceryinventory;

DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory (
    product_id VARCHAR(15) NOT NULL,
    product_name VARCHAR(50) NOT NULL,
    category VARCHAR(30) NOT NULL,
    supplier_name VARCHAR(50) NOT NULL,
    supplier_id VARCHAR(15) NOT NULL,
    warehouse_location VARCHAR(100) NOT NULL,
    status ENUM('continued', 'discontinued', 'backordered') NOT NULL DEFAULT 'continued',
    date_received DATE NULL,
    last_order_date DATE NULL,
    expiration_date DATE NULL,
    stock_quantity INT NOT NULL,
    reorder_level INT NOT NULL,
    reorder_quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    sales_volume INT NOT NULL,
    inventory_turnover_rate INT NOT NULL,
    percentage DECIMAL(5,2) NULL,
    PRIMARY KEY (product_id


DELIMITER //

DROP PROCEDURE IF EXISTS PopulateGroceryDateDimension//
CREATE PROCEDURE PopulateGroceryDateDimension(BeginDate DATETIME, EndDate DATETIME)
BEGIN
    DECLARE DateCounter DATETIME;
    DECLARE LastDayOfMon CHAR(1);

    SET DateCounter = BeginDate;

    WHILE DateCounter <= EndDate DO
        -- Determine if it's the last day of the month
        IF MONTH(DateCounter) = MONTH(DATE_ADD(DateCounter, INTERVAL 1 DAY)) THEN
            SET LastDayOfMon = 'N';
        ELSE
            SET LastDayOfMon = 'Y';
        END IF;

        -- Insert data into dim_date based on the grocery inventory data
        INSERT INTO dim_date (
            date_key,
            full_date,
            date_name,
            product_name,
            catagory,
            supplier_name,
            warehouse_local,
            product_id,
            supplier_id,
            status
        )
        SELECT 
            (YEAR(DateCounter) * 10000) + (MONTH(DateCounter) * 100) + DAY(DateCounter) AS date_key,
            DateCounter AS full_date,
            CONCAT(YEAR(DateCounter), '/', LPAD(MONTH(DateCounter), 2, '0'), '/', LPAD(DAY(DateCounter), 2, '0')) AS date_name,
            Product_Name,
            Category,
            Supplier_Name,
            Warehouse_Location,
            Product_ID,
            Supplier_ID,
            Status
        FROM grocery_inventory
        WHERE Status IN ('continued', 'discontinued');

        -- Move to the next date
        SET DateCounter = DATE_ADD(DateCounter, INTERVAL 1 DAY);
    END WHILE;
END//

DELIMITER ;

-- Example call to populate the date dimension table
CALL PopulateGroceryDateDimension('2020-01-01', '2023-12-31');

-- Verify the data
SELECT MIN(full_date) AS BeginDate, MAX(full_date) AS EndDate FROM dim_date;
