-- =======================================================================================================================
-- =======================================================================================================================

-- Section A — Fundamentals
-- Question 1
-- =======================================================================================================================
-- 1a. Retrieve the first_name, last_name, and email of every customer who lives in Lagos. Sort results
-- alphabetically by last_name, then by first_name.

SELECT 
    first_name, 
    last_name, 
    email
FROM customers
WHERE city = 'Lagos'
ORDER BY last_name ASC, first_name ASC;

-- =======================================================================================================================
-- 1b. List the names of all distinct cities to which SuperMart has shipped at least one order. Sort
-- alphabetically.

SELECT DISTINCT 
    shipping_city
FROM orders
ORDER BY shipping_city ASC;

-- =======================================================================================================================
-- 1c. Display the top 10 most expensive products by unit_price. Show product_name, category_id, and
-- unit_price, ordered from most to least expensive.

SELECT 
    product_name,
    category_id,
    unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 10;

-- =======================================================================================================================
-- 1d. List all employees hired on or after 1st January 2021. Display their full name (first_name and
-- last_name concatenated as one column called full_name), role, hire_date, and salary, ordered by
-- hire_date ascending.

SELECT 
    first_name || ' ' || last_name AS full_name,
    role,
    hire_date,
    salary
FROM employees
WHERE hire_date >= '2021-01-01'
ORDER BY hire_date ASC;

-- Alternative using CONCAT():

SELECT 
    CONCAT(first_name, ' ', last_name) AS full_name,
    role,
    hire_date,
    salary
FROM employees
WHERE hire_date >= '2021-01-01'
ORDER BY hire_date ASC;

-- =======================================================================================================================
-- 1e. Retrieve all orders placed in December across any year. Show order_id, order_date, status, and
-- shipping_city. Order by order_date descending.

SELECT 
    order_id,
    order_date,
    status,
    shipping_city
FROM orders
WHERE EXTRACT(MONTH FROM order_date) = 12
ORDER BY order_date DESC;

-- =======================================================================================================================
-- =======================================================================================================================
-- =======================================================================================================================

-- =======================================================================================================================
-- =======================================================================================================================

-- Section B — Aggregate Functions
-- Question 2
-- =======================================================================================================================
-- 2a. How many orders exist for each status? Display the status, the count, and each status as a
-- percentage of all orders, rounded to 2 decimal places. Label the percentage column pct_of_total. Order
-- by count descending.

SELECT 
    status,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM orders
GROUP BY status
ORDER BY count DESC;

-- 2b. For each product category, calculate the minimum, maximum, and average unit_price of products
-- in that category. Round the average to 2 decimal places. Display category_name (not just the ID). Order
-- by average price descending.

SELECT 
    c.category_name,
    MIN(p.unit_price)            AS min_price,
    MAX(p.unit_price)            AS max_price,
    ROUND(AVG(p.unit_price), 2)  AS avg_price
FROM products p
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY avg_price DESC;

-- 2c. Across all rows in order_items, calculate: the total revenue generated, the average revenue per line
-- item, the maximum revenue from a single line item, and the minimum revenue from a single line item.
-- Round all values to 2 decimal places and label each column clearly.

SELECT 
    ROUND(SUM(quantity * unit_price), 2)  AS total_revenue,
    ROUND(AVG(quantity * unit_price), 2)  AS avg_revenue_per_line,
    ROUND(MAX(quantity * unit_price), 2)  AS max_line_revenue,
    ROUND(MIN(quantity * unit_price), 2)  AS min_line_revenue
FROM order_items;

-- 2d. How many distinct customers have placed at least one order? What is the average number of orders
-- per ordering customer, rounded to 2 decimal places? Display both figures as separate columns in a
-- single result row.

SELECT 
    COUNT(DISTINCT customer_id) AS distinct_customers,
    ROUND( (COUNT(order_id) * 1.0 / COUNT(DISTINCT customer_id)), 2 ) AS avg_orders_per_customer
FROM orders;

-- =======================================================================================================================
-- =======================================================================================================================
-- =======================================================================================================================

-- Section C — Grouping
-- Question 3

-- 3a. Count the number of customers who registered each year between 2018 and 2024. Display the
-- registration year and the count. Order by year ascending.

SELECT 
    EXTRACT(YEAR FROM registration_date) AS registration_year,
    COUNT(*) AS customer_count
FROM customers
WHERE EXTRACT(YEAR FROM registration_date) BETWEEN 2018 AND 2024
GROUP BY registration_year
ORDER BY registration_year ASC;


-- 3b. Which shipping cities received more than 10 delivered orders in total? Display the city name and the
-- count of delivered orders, ordered by count descending.

SELECT 
    shipping_city,
    COUNT(*)            AS delivered_orders
FROM orders
WHERE status = 'Delivered'
GROUP BY shipping_city
HAVING COUNT(*) > 10
ORDER BY delivered_orders DESC;


-- 3c. Find all products whose total quantity sold across all order_items exceeds 50 units. Display
-- product_id, product_name, and total quantity sold. Order by total quantity descending.

SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity) > 50
ORDER BY total_quantity_sold DESC;


-- 3d. Show each employee's full name and the total number of orders they handled. Return only
-- employees who handled 20 or more orders. Order by order count descending.

SELECT 
    e.first_name || ' ' || e.last_name AS full_name,
    COUNT(o.order_id) AS order_count
FROM employees e
JOIN orders o 
    ON e.employee_id = o.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
HAVING COUNT(o.order_id) >= 20
ORDER BY order_count DESC;


-- 3e. For each year in the dataset (2021–2024), show the total number of orders placed and the count of
-- distinct customers who ordered that year. Order by year ascending.

SELECT 
    EXTRACT(YEAR FROM order_date) AS order_year,
    COUNT(order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS distinct_customers
FROM orders
WHERE EXTRACT(YEAR FROM order_date) BETWEEN 2021 AND 2024
GROUP BY order_year
ORDER BY order_year ASC;

-- =======================================================================================================================
-- =======================================================================================================================
-- =======================================================================================================================

-- Section D — LIKE & ILIKE
-- Question 4

-- 4a. SuperMart wants to run a Gmail campaign. Retrieve the first_name, last_name, and email of all
-- customers whose email address ends with @gmail.com. Order alphabetically by last_name.

SELECT 
    first_name,
    last_name,
    email
FROM customers
WHERE email LIKE '%@gmail.com'
ORDER BY last_name ASC;


-- 4b. A product manager needs a list of all products whose names include the word "set" anywhere,
-- regardless of case. Use ILIKE. Display product_name, category_id, and unit_price, ordered by
-- unit_price descending.

SELECT 
    product_name,
    category_id,
    unit_price
FROM products
WHERE product_name ILIKE '%set%'
ORDER BY unit_price DESC;


-- 4c. Find all customers whose last name begins with the letters 'Ad' (case-insensitive). Display full name,
-- city, and registration_date.

SELECT 
    first_name || ' ' || last_name AS full_name,
    city,
    registration_date
FROM customers
WHERE last_name ILIKE 'Ad%'
ORDER BY full_name ASC;


-- 4d. Retrieve all products whose names contain "combo", "kit", or "pack" anywhere in the name (case-
-- insensitive). Use ILIKE with OR. Display product_name, category_id, and unit_price.

SELECT 
    product_name,
    category_id,
    unit_price
FROM products
WHERE product_name ILIKE '%combo%'
   OR product_name ILIKE '%kit%'
   OR product_name ILIKE '%pack%'
ORDER BY unit_price DESC;


-- e. Find all customers whose city name contains the letter sequence 'an' (case-insensitive — e.g. Kano,
-- Kaduna). Display first_name, last_name, and city. Order by city, then last_name.

SELECT 
    first_name,
    last_name,
    city
FROM customers
WHERE city ILIKE '%an%'
ORDER BY city ASC, last_name ASC;

-- =======================================================================================================================
-- =======================================================================================================================
-- =======================================================================================================================

-- Section E — JOINs
-- Question 5

-- 5a. Display the 50 most recent orders. For each, show: order_id, the customer's full name, the handling
-- employee's full name, order_date, status, and shipping_city. Use INNER JOINs. Order by order_date
-- descending.

SELECT 
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_full_name,
    e.first_name || ' ' || e.last_name AS employee_full_name,
    o.order_date,
    o.status,
    o.shipping_city
FROM orders o
INNER JOIN customers c 
    ON o.customer_id = c.customer_id
INNER JOIN employees e 
    ON o.employee_id = e.employee_id
ORDER BY o.order_date DESC
LIMIT 50;


-- 5b. List all 800 customers alongside the total number of orders they have placed. Customers who have
-- never ordered should show 0. Display customer_id, full name, city, and order_count. Order by
-- order_count descending, then last_name ascending.

SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    c.city,
    COALESCE(COUNT(o.order_id), 0) AS order_count
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.city
ORDER BY order_count DESC, c.last_name ASC;


-- 5c. Produce a detailed order line report containing every row in order_items. For each row show:
-- order_id, order_date, customer full name, product_name, quantity, unit_price, discount, and a
-- calculated column line_total using the revenue formula. Order by order_id ascending, then
-- product_name ascending.

SELECT 
    o.order_id,
    o.order_date,
    c.first_name || ' ' || c.last_name AS customer_full_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.discount,
    (oi.quantity * oi.unit_price * (1 - oi.discount)) AS line_total
FROM order_items oi
INNER JOIN orders o 
    ON oi.order_id = o.order_id
INNER JOIN customers c 
    ON o.customer_id = c.customer_id
INNER JOIN products p 
    ON oi.product_id = p.product_id
ORDER BY o.order_id ASC, p.product_name ASC;


-- 5d. Show all 35 employees with their full_name, role, region_name (from the regions table), and the
-- total number of orders they have handled. Include employees with zero orders (show 0). Order by total
-- orders descending, then last_name ascending.

SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS full_name,
    e.role,
    r.region_name,
    COALESCE(COUNT(o.order_id), 0) AS total_orders
FROM employees e
INNER JOIN regions r 
    ON e.region_id = r.region_id
LEFT JOIN orders o 
    ON e.employee_id = o.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.role, r.region_name
ORDER BY total_orders DESC, e.last_name ASC;


-- 5e. For each product category, list every product alongside the total number of distinct orders it has
-- appeared in and the total quantity sold. Display category_name, product_name, times_ordered, and
-- total_qty_sold. Order by category_name, then total_qty_sold descending.

SELECT 
    c.category_name,
    p.product_name,
    COUNT(DISTINCT oi.order_id) AS times_ordered,
    SUM(oi.quantity) AS total_qty_sold
FROM order_items oi
INNER JOIN products p 
    ON oi.product_id = p.product_id
INNER JOIN categories c 
    ON p.category_id = c.category_id
GROUP BY c.category_name, p.product_name
ORDER BY c.category_name ASC, total_qty_sold DESC;


-- =======================================================================================================================
-- =======================================================================================================================
-- =======================================================================================================================

-- Section F — CASE Expressions
-- Question 6

-- 6a. Assign a price tier label to every product using the table below. Display product_name,
-- category_name (joined from categories), unit_price, and price_tier. Order by unit_price ascending.
-- Condition Label
-- unit_price < 10,000 'Budget'
-- unit_price between 10,000 and 99,999 'Mid-Range'
-- unit_price >= 100,000 'Premium'

SELECT 
    p.product_name,
    c.category_name,
    p.unit_price,
    CASE
        WHEN p.unit_price < 10000 THEN 'Budget'
        WHEN p.unit_price BETWEEN 10000 AND 99999 THEN 'Mid-Range'
        WHEN p.unit_price >= 100000 THEN 'Premium'
    END AS price_tier
FROM products p
INNER JOIN categories c 
    ON p.category_id = c.category_id
ORDER BY p.unit_price ASC;


-- 6b. Classify each of the 35 employees into a pay band based on their salary. Display full_name, role,
-- salary, and pay_band. Order by salary descending.
-- Condition Label
-- salary >= 100,000 'Executive'
-- salary between 80,000 – 99,999 'Senior'
-- salary < 80,000 'Entry Level'

SELECT 
    e.first_name || ' ' || e.last_name AS full_name,
    e.role,
    e.salary,
    CASE
        WHEN e.salary >= 100000 THEN 'Executive'
        WHEN e.salary BETWEEN 80000 AND 99999 THEN 'Senior'
        WHEN e.salary < 80000 THEN 'Entry Level'
    END AS pay_band
FROM employees e
ORDER BY e.salary DESC;


-- 6c. For each order, calculate the total order value (sum of all its line totals), then classify it using the table
-- below. Display order_id, order_date, status, total_order_value (rounded to 2 dp), and value_category.
-- Order by total_order_value descending.

SELECT 
    o.order_id,
    o.order_date,
    o.status,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_order_value,
    CASE
        WHEN SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) > 500000 THEN 'High Value'
        WHEN SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) BETWEEN 100000 AND 500000 THEN 'Medium Value'
        WHEN SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) < 100000 THEN 'Low Value'
    END AS value_category
FROM orders o
INNER JOIN order_items oi 
    ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date, o.status
ORDER BY total_order_value DESC;


-- 6d. Using a single query with CASE inside an aggregate, count how many products in each category fall
-- into each price tier. Display one row per category with columns: category_name, budget_count,
-- mid_range_count, premium_count.

SELECT 
    c.category_name,
    COUNT(CASE WHEN p.unit_price < 10000 THEN 1 END) AS budget_count,
    COUNT(CASE WHEN p.unit_price BETWEEN 10000 AND 99999 THEN 1 END) AS mid_range_count,
    COUNT(CASE WHEN p.unit_price >= 100000 THEN 1 END) AS premium_count
FROM products p
INNER JOIN categories c 
    ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY c.category_name ASC;


-- =======================================================================================================================
-- =======================================================================================================================
-- =======================================================================================================================

-- Section G — Subqueries
-- Question 7


-- 7a. Find all products whose unit_price is above the average unit price of all products in the catalogue.
-- Display product_name, category_id, and unit_price. Order by unit_price descending.

SELECT 
    product_name,
    category_id,
    unit_price
FROM products
WHERE unit_price > (
    SELECT AVG(unit_price) 
    FROM products
)
ORDER BY unit_price DESC;


-- 7b. List all customers who have placed at least one order. Display their full name and city. Solve this using
-- a subquery with IN.

SELECT 
    first_name || ' ' || last_name AS full_name,
    city
FROM customers
WHERE customer_id IN (
    SELECT customer_id 
    FROM orders
);


-- 7c. Find all products that have never appeared in any order. Display product_id, product_name,
-- category_id, and unit_price.

-- Option 1: Using NOT IN
SELECT 
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price
FROM products p
WHERE p.product_id NOT IN (
    SELECT oi.product_id 
    FROM order_items oi
)
ORDER BY p.product_id ASC;

-- Option 2: Using NOT EXISTS

SELECT 
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price
FROM products p
WHERE NOT EXISTS (
    SELECT 1 
    FROM order_items oi
    WHERE oi.product_id = p.product_id
)
ORDER BY p.product_id ASC;



-- 7d. Using subqueries, find the top 5 customers by total lifetime revenue (all statuses, all order items).
-- Display their full name, city, and total lifetime revenue rounded to 2 decimal places.

SELECT 
    sub.customer_full_name,
    sub.city,
    ROUND(sub.total_revenue, 2) AS total_lifetime_revenue
FROM (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_full_name,
        c.city,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS total_revenue
    FROM customers c
    INNER JOIN orders o 
        ON c.customer_id = o.customer_id
    INNER JOIN order_items oi 
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.city
) sub
ORDER BY sub.total_revenue DESC
LIMIT 5;


-- 7e. Find all customers whose total lifetime revenue exceeds the average lifetime revenue across all
-- ordering customers. Display their full name, city, and total revenue (rounded to 2 dp). Order by total
-- revenue descending.

SELECT 
    sub.customer_full_name,
    sub.city,
    ROUND(sub.total_revenue, 2) AS total_revenue
FROM (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_full_name,
        c.city,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS total_revenue
    FROM customers c
    INNER JOIN orders o 
        ON c.customer_id = o.customer_id
    INNER JOIN order_items oi 
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.city
) sub
WHERE sub.total_revenue > (
    SELECT AVG(total_revenue)
    FROM (
        SELECT 
            c.customer_id,
            SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS total_revenue
        FROM customers c
        INNER JOIN orders o 
            ON c.customer_id = o.customer_id
        INNER JOIN order_items oi 
            ON o.order_id = oi.order_id
        GROUP BY c.customer_id
    ) avg_sub
)
ORDER BY sub.total_revenue DESC;



-- =======================================================================================================================
-- =======================================================================================================================
-- =======================================================================================================================

-- Section H — CTEs (Common Table Expressions)
-- Question 8


-- 8a. Using a single CTE, calculate the total revenue per customer across all their orders (all statuses).
-- From the outer query, return only the top 10 customers by revenue. Display customer_id, full name, city,
-- and total_revenue rounded to 2 dp.

WITH customer_revenue AS (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name AS full_name,
        c.city,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS total_revenue
    FROM customers c
    INNER JOIN orders o 
        ON c.customer_id = o.customer_id
    INNER JOIN order_items oi 
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.city
)
SELECT 
    customer_id,
    full_name,
    city,
    ROUND(total_revenue, 2) AS total_revenue
FROM customer_revenue
ORDER BY total_revenue DESC
LIMIT 10;


-- 8b. Using a CTE, identify the single best-selling product (by total quantity sold) in each category. Display
-- category_name, product_name, and total_qty_sold.

WITH product_sales AS (
    SELECT 
        c.category_name,
        p.product_name,
        SUM(oi.quantity) AS total_qty_sold
    FROM products p
    INNER JOIN categories c 
        ON p.category_id = c.category_id
    INNER JOIN order_items oi 
        ON p.product_id = oi.product_id
    GROUP BY c.category_name, p.product_name
)
SELECT 
    ps.category_name,
    ps.product_name,
    ps.total_qty_sold
FROM product_sales ps
WHERE ps.total_qty_sold = (
    SELECT MAX(ps2.total_qty_sold)
    FROM product_sales ps2
    WHERE ps2.category_name = ps.category_name
)
ORDER BY ps.category_name ASC;


-- 8c. Using two chained CTEs, analyse monthly performance for the year 2023 only:
-- • CTE 1: Total revenue per calendar month in 2023 (all statuses).
-- • CTE 2: The average monthly revenue across all months of 2023.
-- • Final query: Each month number, total revenue (rounded to 2 dp), and a column called
-- vs_average — set to 'Above Average' if that month beat the average, otherwise 'Below Average'.
-- Order by month ascending.

WITH monthly_revenue AS (
    SELECT 
        EXTRACT(MONTH FROM o.order_date) AS month,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS total_revenue
    FROM orders o
    INNER JOIN order_items oi 
        ON o.order_id = oi.order_id
    WHERE EXTRACT(YEAR FROM o.order_date) = 2023
    GROUP BY EXTRACT(MONTH FROM o.order_date)
),
average_revenue AS (
    SELECT AVG(total_revenue) AS avg_monthly_revenue
    FROM monthly_revenue
)
SELECT 
    mr.month,
    ROUND(mr.total_revenue, 2) AS total_revenue,
    CASE 
        WHEN mr.total_revenue > ar.avg_monthly_revenue THEN 'Above Average'
        ELSE 'Below Average'
    END AS vs_average
FROM monthly_revenue mr, average_revenue ar
ORDER BY mr.month ASC;


-- 8d. Using CTEs, produce a customer frequency segmentation report. Calculate how many total orders
-- each customer has placed, then classify each customer using the table below. Return one row per
-- segment showing the segment label and customer_count. Order by customer_count descending.

WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name AS full_name,
        COUNT(o.order_id) AS total_orders
    FROM customers c
    LEFT JOIN orders o 
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT 
    CASE
        WHEN total_orders >= 8 THEN 'High Frequency'
        WHEN total_orders BETWEEN 4 AND 7 THEN 'Regular'
        WHEN total_orders BETWEEN 1 AND 3 THEN 'Occasional'
        WHEN total_orders = 0 THEN 'Inactive'
    END AS segment,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY 
    CASE
        WHEN total_orders >= 8 THEN 'High Frequency'
        WHEN total_orders BETWEEN 4 AND 7 THEN 'Regular'
        WHEN total_orders BETWEEN 1 AND 3 THEN 'Occasional'
        WHEN total_orders = 0 THEN 'Inactive'
    END
ORDER BY customer_count DESC;


-- 8e. Using a CTE, compute the year-over-year total revenue from delivered orders for each year in the
-- dataset (2021, 2022, 2023, and the first half of 2024). Display order_year and total_revenue (rounded to
-- 2 dp). Order by year ascending.

WITH yearly_revenue AS (
    SELECT 
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS total_revenue
    FROM orders o
    INNER JOIN order_items oi 
        ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
      AND (
          EXTRACT(YEAR FROM o.order_date) IN (2021, 2022, 2023)
          OR (EXTRACT(YEAR FROM o.order_date) = 2024 
              AND EXTRACT(MONTH FROM o.order_date) <= 6)
      )
    GROUP BY EXTRACT(YEAR FROM o.order_date)
)
SELECT 
    order_year,
    ROUND(total_revenue, 2) AS total_revenue
FROM yearly_revenue
ORDER BY order_year ASC;



-- =======================================================================================================================
-- =======================================================================================================================
-- =======================================================================================================================


-- Section I — Capstone Challenge
-- Question 9 — Employee Sales Performance Report


WITH order_totals AS (
    -- CTE 1: Calculate revenue per order by summing line items
    SELECT 
        oi.order_id,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS order_revenue
    FROM order_items oi
    GROUP BY oi.order_id
),
employee_perf AS (
    -- CTE 2: Aggregate delivered orders per employee between Jan 2021 and Jun 2024
    SELECT 
        o.employee_id,
        COUNT(o.order_id) AS total_delivered_orders,
        COALESCE(SUM(ot.order_revenue), 0) AS total_revenue,
        COALESCE(AVG(ot.order_revenue), 0) AS avg_order_value,
        COALESCE(MAX(ot.order_revenue), 0) AS best_single_order
    FROM orders o
    INNER JOIN order_totals ot 
        ON o.order_id = ot.order_id
    WHERE o.status = 'Delivered'
      AND o.order_date BETWEEN '2021-01-01' AND '2024-06-30'
    GROUP BY o.employee_id
)
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    e.role,
    r.region_name,
    COALESCE(ep.total_delivered_orders, 0) AS total_delivered_orders,
    ROUND(COALESCE(ep.total_revenue, 0), 2) AS total_revenue,
    ROUND(COALESCE(ep.avg_order_value, 0), 2) AS avg_order_value,
    ROUND(COALESCE(ep.best_single_order, 0), 2) AS best_single_order,
    CASE
        WHEN COALESCE(ep.total_revenue, 0) > 5000000 THEN 'Elite'
        WHEN COALESCE(ep.total_revenue, 0) BETWEEN 1000000 AND 5000000 THEN 'Strong'
        WHEN COALESCE(ep.total_revenue, 0) BETWEEN 100000 AND 999999 THEN 'Developing'
        ELSE 'Inactive'
    END AS performance_band
FROM employees e
LEFT JOIN employee_perf ep 
    ON e.employee_id = ep.employee_id
INNER JOIN regions r 
    ON e.region_id = r.region_id
ORDER BY total_revenue DESC, employee_name ASC;



-- =======================================================================================================================
-- =======================================================================================================================
-- =======================================================================================================================


-- Section J — Bonus Challenge — Extension for Fast Finishers
-- Question 10 — Customer Lifetime Value Report


WITH customer_orders AS (
    -- CTE: Aggregate orders and revenue per customer
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.city,
        EXTRACT(YEAR FROM c.registration_date) AS registration_year,
        COUNT(o.order_id) AS total_orders,
        COUNT(CASE WHEN o.status = 'Delivered' THEN 1 END) AS delivered_orders,
        COUNT(CASE WHEN o.status = 'Cancelled' THEN 1 END) AS cancelled_orders,
        COALESCE(SUM(CASE WHEN o.status = 'Delivered' 
                          THEN (oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)) 
                     END), 0) AS lifetime_revenue,
        COALESCE(AVG(CASE WHEN o.status = 'Delivered' 
                          THEN (oi.quantity * oi.unit_price * (1 - oi.discount / 100.0)) 
                     END), 0) AS avg_order_value
    FROM customers c
    LEFT JOIN orders o 
        ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi 
        ON o.order_id = oi.order_id
    WHERE c.registration_date < '2024-01-01'
      AND o.order_date BETWEEN '2021-01-01' AND '2024-06-30'
    GROUP BY c.customer_id, c.first_name, c.last_name, c.city, c.registration_date
)
SELECT 
    customer_name,
    city,
    registration_year,
    total_orders,
    delivered_orders,
    cancelled_orders,
    ROUND(lifetime_revenue, 2) AS lifetime_revenue,
    ROUND(avg_order_value, 2) AS avg_order_value,
    CASE
        WHEN lifetime_revenue > 500000 AND delivered_orders >= 5 THEN 'VIP'
        WHEN (lifetime_revenue BETWEEN 100000 AND 500000) 
             OR (delivered_orders BETWEEN 2 AND 4) THEN 'Loyal'
        WHEN delivered_orders = 1 THEN 'One-Time Buyer'
        WHEN delivered_orders = 0 AND total_orders > 0 THEN 'No Conversions'
        WHEN total_orders = 0 THEN 'Inactive'
    END AS customer_segment
FROM customer_orders
ORDER BY lifetime_revenue DESC, customer_name ASC;



-- =======================================================================================================================
-- =======================================================================================================================
-- =======================================================================================================================
























































































