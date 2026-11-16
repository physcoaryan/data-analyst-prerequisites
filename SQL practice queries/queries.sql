-- SQL practice queries
-- TOPICS : SELECT, WHERE, ORDER BY, GROUP BY, HAVING, JOINs, Aggregate Functions, Subqueries, Basic Window Functions

-- Task: Write SQL queries to analyse customer orders, revenue, and product performance.

-- 1. Analyze Customer Orders
-- aim : find the total count of orders and the total spent of customers with multiple purchases

SELECT c.customer_name, COUNT(o.order_id) AS total_orders, SUM(o.quantity * p.price) AS total_spent
FROM customer c 
JOIN order o ON c.customer_id=o.customer_id 
JOIN products p ON o.product_id = p.product_id
WHERE c.signup_date >= '2023-01-01'
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) > 1
ORDER BY total_spent DESC;

-- 2. Revenue Analysis (with subqueries)
-- aim : find avg order value (AOV), then find orders which exceed it...

SELECT order_id, customer_id, order_date, order_total
-- Subquery 1: Calculate the total for each specific order
FROM (
    SELECT o.order_id, o.customer_id, o.order_date, SUM(o.quantity * p.price) AS order_total
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY o.order_id, o.customer_id, o.order_date
) AS order_totals
-- Subquery 2: Find the overall average order value across the entire business
WHERE order_total > (
    SELECT AVG(quantity * price) 
    FROM orders o2 
    JOIN products p2 ON o2.product_id = p2.product_id
)
ORDER BY order_total DESC;

-- 3. Product performance
-- aim : product ranking in categories by the revenue it generated

SELECT category, product_name, total_revenue, RANK() OVER(PARTITION BY category ORDER BY total_revenue DESC) as category_revenue_rank
-- Inner query gets the total revenue per product
FROM (
    SELECT p.category, p.product_name, SUM(o.quantity * p.price) AS total_revenue
    FROM products p
    JOIN orders o ON p.product_id = o.product_id
    GROUP BY p.category, p.product_name
) AS product_sales
ORDER BY category, category_revenue_rank;
