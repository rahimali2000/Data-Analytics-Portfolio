-- ==========================================================
-- SECTION 1: ANALYTICAL PROBLEM STATEMENTS 
-- ==========================================================

-- ==========================================
-- A.	REVENUE AND PAYMENTS
-- ==========================================

-- 1. Total revenue by month (and trend)
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(total_cost) AS total_revenue
FROM laundry_service_db.orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;


-- 2. Which payment method is most used
SELECT
    payment_method,
    COUNT(*) AS usage_count
FROM laundry_service_db.payment
GROUP BY payment_method
ORDER BY usage_count DESC;


-- 3. Does payment method affect how quickly orders get paid?
-- (average days between order_date and payment_date, by payment method)
SELECT
    p.payment_method,
    AVG(DATEDIFF(p.payment_date, o.order_date)) AS avg_days_to_pay,
    COUNT(*) AS num_orders
FROM laundry_service_db.payment p
JOIN laundry_service_db.orders o
    ON p.order_id = o.order_id
GROUP BY p.payment_method
ORDER BY avg_days_to_pay;

SELECT order_id FROM laundry_service_db.payment LIMIT 10;
SELECT order_id FROM laundry_service_db.orders LIMIT 10;


-- 4. What percentage of orders are still "unpaid"
SELECT
    SUM(payment_status = 'unpaid') AS unpaid_count,
    COUNT(*) AS total_orders,
    ROUND(SUM(payment_status = 'unpaid') / COUNT(*) * 100, 2) AS unpaid_percentage
FROM laundry_service_db.orders;


-- 5. How old are the unpaid orders (days since order_date, as of today)
SELECT
    order_id,
    order_date,
    total_cost,
    DATEDIFF(CURDATE(), order_date) AS days_since_order
FROM laundry_service_db.orders
WHERE payment_status = 'unpaid'
ORDER BY days_since_order DESC;


-- 6. Summary: unpaid orders - count, date range, total value
SELECT
    COUNT(*) AS total_unpaid_orders,
    MIN(order_date) AS oldest_unpaid_order,
    MAX(order_date) AS most_recent_unpaid_order,
    SUM(total_cost) AS total_unpaid_revenue,
    ROUND(AVG(DATEDIFF(CURDATE(), order_date)), 1) AS avg_days_unpaid
FROM laundry_service_db.orders
WHERE payment_status = 'unpaid';


-- ==========================================
-- B.	CUSTOMER BEHAVIOR 
-- ==========================================

-- 1. Which customers order most frequently, and what's their average spend?
SELECT
    o.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS order_count,
    ROUND(AVG(o.total_cost), 2) AS avg_spend,
    ROUND(SUM(o.total_cost), 2) AS total_spend
FROM laundry_service_db.orders o
JOIN laundry_service_db.customer c
    ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.first_name, c.last_name
ORDER BY order_count DESC
LIMIT 10;


-- 2. Which states/cities generate the most revenue?

-- By state
SELECT
    c.state,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.total_cost), 2) AS total_revenue
FROM laundry_service_db.orders o
JOIN laundry_service_db.customer c
    ON o.customer_id = c.customer_id
GROUP BY c.state
ORDER BY total_revenue DESC;

-- By city
SELECT
    c.city,
    c.state,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.total_cost), 2) AS total_revenue
FROM laundry_service_db.orders o
JOIN laundry_service_db.customer c
    ON o.customer_id = c.customer_id
GROUP BY c.city, c.state
ORDER BY total_revenue DESC
LIMIT 10;


-- 3. One-time customers vs. repeat customers, and the ratio

-- Step 1: count orders per customer
WITH customer_order_counts AS (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM laundry_service_db.orders
    GROUP BY customer_id
)
-- Step 2: classify and count
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS num_customers,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM customer_order_counts) * 100, 2) AS percentage
FROM customer_order_counts
GROUP BY customer_type;


--            Optional
-- Average spend comparison: one-time vs. repeat customers

WITH customer_summary AS (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count,
        SUM(total_cost) AS total_spend,
        AVG(total_cost) AS avg_order_value
    FROM laundry_service_db.orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS num_customers,
    ROUND(AVG(total_spend), 2) AS avg_total_spend_per_customer,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value,
    ROUND(SUM(total_spend), 2) AS combined_revenue
FROM customer_summary
GROUP BY customer_type;

-- TOP-CUSTOMERS

SELECT
    o.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS order_count,
    ROUND(SUM(o.total_cost), 2) AS total_spend,
    ROUND(AVG(o.total_cost), 2) AS avg_order_value
FROM laundry_service_db.orders o
JOIN laundry_service_db.customer c
    ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.first_name, c.last_name
ORDER BY order_count DESC;

--        TOP 10 CUSTOMERS 
SELECT
    o.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS order_count,
    ROUND(SUM(o.total_cost), 2) AS total_spend,
    ROUND(AVG(o.total_cost), 2) AS avg_order_value
FROM laundry_service_db.orders o
JOIN laundry_service_db.customer c
    ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.first_name, c.last_name
ORDER BY order_count ASC
LIMIT 10;

-- ==========================================
-- C.		SERVICE PERFORMANCE
-- ==========================================

-- 1. Which services are most/least popular by order volume?
SELECT
    s.service_name,
    COUNT(sv_assigning_id) AS order_count
FROM laundry_service_db.service_assigning sa
JOIN laundry_service_db.service s
    ON sa.service_id = s.Service_id
GROUP BY s.service_name
ORDER BY order_count DESC;

-- 2. Which services generate the most revenue vs. just the most orders
--    (high volume/low price vs. low volume/high price)
SELECT
    s.service_name,
    s.price,
    COUNT(sv_assigning_id) AS order_count,
    ROUND(s.price * COUNT(sa.sv_assigning_id), 2) AS estimated_revenue
FROM laundry_service_db.service_assigning sa
JOIN laundry_service_db.service s
    ON sa.service_id = s.Service_id
GROUP BY s.service_name, s.price
ORDER BY estimated_revenue DESC;

-- 3. Does service duration (min/max hours) correlate with price?
SELECT
    service_id,
    service_name,
    price,
    duration_min_hours,
    duration_max_hours,
    ROUND((duration_min_hours + duration_max_hours) / 2, 1) AS avg_duration_hours
FROM laundry_service_db.service
ORDER BY price DESC
LIMIT 50;


-- ==========================================
-- D.	OPERATIONS: MACHINES AND STAFF 
-- ==========================================

-- 1. Which machines are "Out of Service" most often
SELECT
    machine_id,
    machine_name,
    machine_type,
    status,
    installation_date
FROM laundry_service_db.machine
WHERE status = 'Out of Service'
ORDER BY machine_id;


-- 1b. Does "Out of Service" correlate with delays?
-- (compare fulfillment time for orders linked to out-of-service machines vs. others)
SELECT
    m.status,
    COUNT(DISTINCT o.order_id) AS num_orders,
    ROUND(AVG(DATEDIFF(o.delivery_date, o.order_date)), 2) AS avg_fulfillment_days
FROM laundry_service_db.orders o
JOIN laundry_service_db.service_assigning sa
    ON o.order_id = sa.order_id
JOIN laundry_service_db.machine m
    ON sa.machine_id = m.machine_id
GROUP BY m.status;


-- 2. Which employees are assigned to the most machines/tasks
SELECT
    ma.employee_id,
    e.first_name,
    e.last_name,
    COUNT(ma.mc_assignment_id) AS assignment_count
FROM laundry_service_db.machine_assigning ma
JOIN laundry_service_db.employees e
    ON ma.employee_id = e.employee_id
GROUP BY ma.employee_id, e.first_name, e.last_name
ORDER BY assignment_count DESC
LIMIT 10;


-- 3. Are certain machine types more prone to "Out of Service" status?
SELECT
    machine_type,
    status,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY machine_type), 1) AS pct_within_type
FROM laundry_service_db.machine
GROUP BY machine_type, status
ORDER BY machine_type, status;

-- ==========================================
-- E.	ORDER FULFILLMENT TIMING
-- ==========================================

-- 1. Average time between order_date and pickup_date,
--    and between pickup_date and delivery_date
SELECT
    ROUND(AVG(DATEDIFF(pickup_date, order_date)), 2) AS avg_days_order_to_pickup,
    ROUND(AVG(DATEDIFF(delivery_date, pickup_date)), 2) AS avg_days_pickup_to_delivery,
    ROUND(AVG(DATEDIFF(delivery_date, order_date)), 2) AS avg_days_order_to_delivery
FROM laundry_service_db.orders;


-- 2. Orders where delivery happened BEFORE pickup (logic problem)
SELECT
    order_id,
    order_date,
    pickup_date,
    delivery_date,
    DATEDIFF(delivery_date, pickup_date) AS days_pickup_to_delivery
FROM laundry_service_db.orders
WHERE delivery_date < pickup_date;

-- Average fulfillment times, EXCLUDING the 73 problem rows
SELECT
    ROUND(AVG(DATEDIFF(pickup_date, order_date)), 2) AS avg_days_order_to_pickup,
    ROUND(AVG(DATEDIFF(delivery_date, pickup_date)), 2) AS avg_days_pickup_to_delivery,
    ROUND(AVG(DATEDIFF(delivery_date, order_date)), 2) AS avg_days_order_to_delivery
FROM laundry_service_db.orders
WHERE delivery_date >= pickup_date;

-- Count of how many orders have this issue
SELECT
    COUNT(*) AS orders_with_delivery_before_pickup,
    (SELECT COUNT(*) FROM laundry_service_db.orders) AS total_orders,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM laundry_service_db.orders), 2) AS pct_affected
FROM laundry_service_db.orders
WHERE delivery_date < pickup_date;


-- 3. Orders with unusually long gaps (e.g. more than 30 days order-to-delivery)
SELECT
    order_id,
    order_date,
    pickup_date,
    delivery_date,
    DATEDIFF(delivery_date, order_date) AS total_days
FROM laundry_service_db.orders
WHERE DATEDIFF(delivery_date, order_date) > 30
ORDER BY total_days DESC;


-- 4. Do certain services correlate with longer fulfillment times?
SELECT
    s.service_name,
    COUNT(DISTINCT o.order_id) AS num_orders,
    ROUND(AVG(DATEDIFF(o.delivery_date, o.order_date)), 2) AS avg_fulfillment_days
FROM laundry_service_db.orders o
JOIN laundry_service_db.service_assigning sa
    ON o.order_id = sa.order_id
JOIN laundry_service_db.service s
    ON sa.service_id = s.Service_id
GROUP BY s.service_name
ORDER BY avg_fulfillment_days DESC;


-- 5. Do certain machines correlate with longer fulfillment times?
SELECT
    m.machine_id,
    m.machine_type,
    m.status,
    COUNT(DISTINCT o.order_id) AS num_orders,
    ROUND(AVG(DATEDIFF(o.delivery_date, o.order_date)), 2) AS avg_fulfillment_days
FROM laundry_service_db.orders o
JOIN laundry_service_db.service_assigning sa
    ON o.order_id = sa.order_id
JOIN laundry_service_db.machine m
    ON sa.machine_id = m.machine_id
GROUP BY m.machine_id, m.machine_type, m.status
ORDER BY avg_fulfillment_days DESC
LIMIT 10;

