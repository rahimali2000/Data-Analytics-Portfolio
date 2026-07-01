-- ==========================================================
-- LAUNDRY SERVICE PROJECT  ----  DATA CLEANING (MySQL, QUERIES)
-- ==========================================================

-- Sections:
-- 1. Remove Duplicates
-- 2. Standardize Data (dates, currency, column names)
-- 3. Null / Blank Value Checks
-- 4. Final Consistency Checks
-- ==========================================================

-- ==========================================================
-- 1a. CUSTOMERS — DUPLICATE CHECK
-- ==========================================================

WITH duplicate_CTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id, first_name, last_name, email, `phone`,
                          address, state, city, zip
        ) AS row_num
    FROM laundry_service_db.customer
)
SELECT *
FROM duplicate_CTE
WHERE row_num > 1; 

SELECT *
from laundry_service_db.customer;                        

-- No duplicates found

-- ==========================================================
-- 1b. CHANGE OF THE FIELD HEADER NAMES
-- ==========================================================

ALTER TABLE laundry_service_db.customer
CHANGE COLUMN CustomerID customer_id INT,
CHANGE COLUMN FirstName first_name VARCHAR(50),
CHANGE COLUMN LastName last_name VARCHAR(50),
CHANGE COLUMN Email email VARCHAR(100),
CHANGE COLUMN Phone phone VARCHAR(25),
CHANGE COLUMN Address address VARCHAR(255),
CHANGE COLUMN State state VARCHAR(50),
CHANGE COLUMN City city VARCHAR(50),
CHANGE COLUMN Zip zip VARCHAR(10);

DESCRIBE laundry_service_db.customer;

SELECT *
FROM laundry_service_db.customer;

-- ==========================================================
-- 2a. CUSTOMER — clean Phone (remove dashes)
-- ==========================================================
-- Example from the messy dataset: 336-378-1770

SELECT customer_id, phone,
       REPLACE(phone, '-', '') AS phone_cleaned
FROM laundry_service_db.customer
LIMIT 20;

UPDATE laundry_service_db.customer
SET Phone = REPLACE(Phone, '-', '')
WHERE Phone LIKE '%-%';

ALTER TABLE laundry_service_db.customer
MODIFY COLUMN Phone VARCHAR(25);


-- ==========================================================
-- 2b. MACHINE 
-- ==========================================================

SELECT machine_id, installation_date
FROM laundry_service_db.machine
LIMIT 20;


-- ==========================================================
-- 2c. MACHINE_ASSIGNING 
-- ==========================================================

DESCRIBE laundry_service_db.machine;

ALTER TABLE laundry_service_db.machine
MODIFY COLUMN machine_name VARCHAR(100),
MODIFY COLUMN machine_type VARCHAR(50),
MODIFY COLUMN status VARCHAR(50);

SELECT mc_assignment_id, assignment_date
FROM laundry_service_db.machine_assigning
LIMIT 20;

SELECT *
FROM laundry_service_db.machine_assigning;


-- Verify: should return 0 rows
SELECT *
FROM laundry_service_db.machine_assigning
WHERE assignment_date IS NULL;

DESCRIBE laundry_service_db.machine_assigning;


-- ==========================================================
-- 2d. ORDER - fix trailing space in payment_status column
--     clean total_cost currency field
--     Erase of the 'â€' 
-- ==========================================================
  

-- Preview date 
SELECT order_id,
       order_date,    
       pickup_date,   
       delivery_date
FROM laundry_service_db.orders
LIMIT 50;

-- Verify: should return 0 rows
SELECT *
FROM laundry_service_db.orders
WHERE order_date IS NULL OR pickup_date IS NULL OR delivery_date IS NULL;

-- Clean total_cost: remove "$" and convert to DECIMAL
-- Example: $4.63
SELECT order_id, total_cost,
       CAST(REPLACE(total_cost, '$', '') AS DECIMAL(10,2)) AS total_cost_converted
FROM laundry_service_db.orders
LIMIT 20;

UPDATE laundry_service_db.orders
SET total_cost = REPLACE(total_cost, '$', '');

ALTER TABLE laundry_service_db.orders
MODIFY COLUMN total_cost DECIMAL(10,2);

-- Verify: should return 0 rows
SELECT *
FROM laundry_service_db.orders
WHERE total_cost IS NULL;

SELECT DISTINCT payment_status FROM laundry_service_db.orders;

DESCRIBE laundry_service_db.machine_assigning;
DESCRIBE laundry_service_db.orders;
DESCRIBE laundry_service_db.payment;

DESCRIBE laundry_service_db.orders;

-- Preview the conversion first (format: DD/MM/YYYY)
SELECT order_id,
       order_date,    STR_TO_DATE(order_date, '%d/%m/%Y')    AS order_date_converted,
       pickup_date,   STR_TO_DATE(pickup_date, '%d/%m/%Y')   AS pickup_date_converted,
       delivery_date, STR_TO_DATE(delivery_date, '%d/%m/%Y') AS delivery_date_converted
FROM laundry_service_db.orders
LIMIT 40;

-- Convert the actual data
UPDATE laundry_service_db.orders
SET order_date    = STR_TO_DATE(order_date, '%d/%m/%Y'),
    pickup_date   = STR_TO_DATE(pickup_date, '%d/%m/%Y'),
    delivery_date = STR_TO_DATE(delivery_date, '%d/%m/%Y');

-- Change column types to DATE
ALTER TABLE laundry_service_db.orders
MODIFY COLUMN order_date DATE,
MODIFY COLUMN pickup_date DATE,
MODIFY COLUMN delivery_date DATE;

SELECT *
FROM laundry_service_db.orders;

-- Verify: should return 0 rows
SELECT *
FROM laundry_service_db.orders
WHERE order_date IS NULL OR pickup_date IS NULL OR delivery_date IS NULL;

ALTER TABLE laundry_service_db.orders
MODIFY COLUMN payment_status VARCHAR(20),
MODIFY COLUMN notes VARCHAR(255);

-- Erase of the 'â€' 

-- First, see the exact corrupted characters

SELECT DISTINCT notes
FROM laundry_service_db.orders
WHERE notes LIKE '%â€%';


UPDATE laundry_service_db.orders
SET notes = CONCAT(
    SUBSTRING(notes, 1, LOCATE('â€', notes) - 1),
    '-',
    SUBSTRING(notes, LOCATE('â€', notes) + 3)
)
WHERE notes LIKE '%â€%';


SELECT DISTINCT notes
FROM laundry_service_db.orders
WHERE notes LIKE '%Urgent%';

-- ==========================================================
-- 2e. PAYMENT - clean payment_amount currency field
-- ==========================================================

SELECT payment_id, payment_date
FROM laundry_service_db.payment
LIMIT 50;

-- Verify: should return 0 rows | To actually  look for duplicates
SELECT *
FROM laundry_service_db.payment
WHERE payment_date IS NULL;

-- Clean payment_amount: remove "$" and convert to DECIMAL
-- Example: $3.86
SELECT payment_id, payment_amount,
       CAST(REPLACE(payment_amount, '$', '') AS DECIMAL(10,2)) AS payment_amount_converted
FROM laundry_service_db.payment
LIMIT 20;

UPDATE laundry_service_db.payment
SET payment_amount = REPLACE(payment_amount, '$', '');

ALTER TABLE laundry_service_db.payment
MODIFY COLUMN payment_amount DECIMAL(10,2);

-- Verify: should return 0 rows
SELECT *
FROM laundry_service_db.payment
WHERE payment_amount IS NULL;

-- ==========================================================
-- 2f. LAUNDRY_SERVICE — clean price (currency),
--     fix trailing space in description column &
--     split duration_in_hours range into two numeric columns
-- ==========================================================
-- Examples from the raw data: price = $3.72, duration_in_hours = "2-3"

--  Change Service_id to lowercase service_id

ALTER TABLE laundry_service_db.service
CHANGE COLUMN Service_id service_id INT;

UPDATE laundry_service_db.service
SET service_id = REPLACE(service_id, 'Service_id', 'service_id');

DESCRIBE laundry_service_db.service;

SELECT *
FROM laundry_service_db.service;

-- Clean price
SELECT service_id, price,
       CAST(REPLACE(price, '$', '') AS DECIMAL(10,2)) AS price_converted
FROM laundry_service_db.service
LIMIT 20;

UPDATE laundry_service_db.service
SET price = REPLACE(price, '$', '');

ALTER TABLE laundry_service_db.service
MODIFY COLUMN price DECIMAL(10,2);

-- Verify: should return 0 rows
SELECT *
FROM laundry_service_db.service
WHERE price IS NULL;


SELECT *
FROM laundry_service_db.service;


-- ==========================================================
-- 3. NULL / BLANK VALUE CHECKS (across all tables)
-- ==========================================================

-- Customer
SELECT *
FROM laundry_service_db.customer
WHERE customer_id IS NULL OR TRIM(first_name) = '' OR TRIM(last_name) = ''
   OR TRIM(email) = '' OR `phone` IS NULL OR TRIM(address) = ''
   OR TRIM(state) = '' OR TRIM(city) = '' OR zip IS NULL;
   
-- Accurate Data --- No Missing  Values, No NULL 

-- Employees
SELECT *
FROM laundry_service_db.employees
WHERE employee_id IS NULL OR TRIM(first_name) = '' OR TRIM(last_name) = ''
   OR TRIM(position) = '' OR TRIM(email) = '' OR phone_number IS NULL;

-- Accurate Data --- No Missing  Values, No NULL 

-- Machine
SELECT *
FROM laundry_service_db.machine
WHERE machine_id IS NULL OR TRIM(machine_name) = '' OR TRIM(machine_type) = ''
   OR TRIM(status) = '' OR installation_date IS NULL;
   
   -- No Missing  Values, No NULL 

-- Machine Assigning
SELECT *
FROM laundry_service_db.machine_assigning
WHERE mc_assignment_id IS NULL OR employee_id IS NULL OR machine_id IS NULL
   OR assignment_date IS NULL OR TRIM(assignment_description) = '';

-- Order
SELECT *
FROM laundry_service_db.orders
WHERE order_id IS NULL OR customer_id IS NULL OR order_date IS NULL
   OR pickup_date IS NULL OR delivery_date IS NULL
   OR total_cost IS NULL OR TRIM(payment_status) = '';
   
UPDATE laundry_service_db.orders
SET payment_status = TRIM(payment_status);

SELECT *
FROM laundry_service_db.orders;

-- Payment
SELECT *
FROM laundry_service_db.payment
WHERE payment_id IS NULL OR order_id IS NULL OR payment_date IS NULL
   OR payment_amount IS NULL OR TRIM(payment_method) = '';

-- Service
SELECT *
FROM laundry_service_db.service
WHERE service_id IS NULL OR TRIM(service_name) = '' OR TRIM(description) = ''
   OR price IS NULL OR duration_max_hours AND duration_min_hours IS NULL; 
	

SELECT *
FROM laundry_service_db.service;

-- Service Assigning
SELECT *
FROM laundry_service_db.service_assigning
WHERE sv_assigning_id IS NULL OR order_id IS NULL
   OR service_id IS NULL OR machine_id IS NULL;

-- NO NULL, NO MISSING VALUES


-- ==========================================================
-- 4. FINAL CONSISTENCY CHECKS (look for spelling/casing issues)
-- ==========================================================

SELECT DISTINCT state          FROM laundry_service_db.customer ORDER BY 1;
SELECT DISTINCT city           FROM laundry_service_db.customer ORDER BY 1;
SELECT DISTINCT status         FROM laundry_service_db.machine ORDER BY 1;
SELECT DISTINCT payment_method FROM laundry_service_db.payment ORDER BY 1;
SELECT DISTINCT payment_status FROM laundry_service_db.orders ORDER BY 1;
SELECT DISTINCT service_name   FROM laundry_service_db.service ORDER BY 1;
SELECT DISTINCT position       FROM laundry_service_db.employees ORDER BY 1;


-- ===============================================================================
-- DATA IS NOW READY FOR ANALYSIS (Power BI / SQL) FOR ANSWERING BUSINESS QUETIONS
-- ===============================================================================