-- 01_business_analysis_queries.sql
-- Business analysis SQL queries aligned with the Python Colab notebook.
-- Database: SQLite
-- Tables used: customers, orders, order_items, payments, reviews, products, category_translation

-- ============================================================
-- 1. Monthly sales trend
-- Business question:
-- How do monthly orders and revenue change over time?
-- ============================================================

SELECT
    strftime('%Y-%m', o.order_purchase_timestamp) AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;


-- ============================================================
-- 2. Revenue by customer state
-- Business question:
-- Which states generate the highest revenue?
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    ROUND(
        SUM(oi.price + oi.freight_value) / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- ============================================================
-- 3. Top product categories by revenue
-- Business question:
-- Which product categories contribute the most revenue?
-- ============================================================

SELECT
    COALESCE(ct.product_category_name_english, p.product_category_name) AS product_category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY product_category
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- 4. Payment type analysis
-- Business question:
-- Which payment methods are most commonly used?
-- ============================================================

SELECT
    payment_type,
    COUNT(*) AS payment_count,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- ============================================================
-- 5. Delivery status and customer review score
-- Business question:
-- Do late deliveries affect customer satisfaction?
-- ============================================================

SELECT
    CASE
        WHEN julianday(o.order_delivered_customer_date) <= julianday(o.order_estimated_delivery_date)
        THEN 'On-time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM orders o
JOIN reviews r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;


-- ============================================================
-- 6. Average delivery days by state
-- Business question:
-- Which states experience longer delivery times?
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    ROUND(
        AVG(julianday(o.order_delivered_customer_date) - julianday(o.order_purchase_timestamp)),
        2
    ) AS average_delivery_days,
    ROUND(
        AVG(julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date)),
        2
    ) AS average_delay_days
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING delivered_orders >= 100
ORDER BY average_delivery_days DESC;


-- ============================================================
-- 7. Product categories with low review scores
-- Business question:
-- Which product categories may need customer experience improvement?
-- ============================================================

SELECT
    COALESCE(ct.product_category_name_english, p.product_category_name) AS product_category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
JOIN reviews r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY product_category
HAVING total_orders >= 100
ORDER BY average_review_score ASC
LIMIT 10;


-- ============================================================
-- 8. Customer repeat purchase analysis
-- Business question:
-- What percentage of customers are one-time vs repeat customers?
-- ============================================================

WITH customer_order_counts AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage
FROM customer_order_counts
GROUP BY customer_type;


-- ============================================================
-- 9. RFM base table for customer segmentation
-- Business question:
-- How can customers be prepared for CRM segmentation?
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        date(o.order_purchase_timestamp) AS order_date,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id, o.order_id, order_date
),

latest_date AS (
    SELECT
        MAX(order_date) AS max_order_date
    FROM customer_orders
)

SELECT
    co.customer_unique_id,
    CAST(
        julianday((SELECT max_order_date FROM latest_date)) - julianday(MAX(co.order_date))
        AS INTEGER
    ) AS recency_days,
    COUNT(DISTINCT co.order_id) AS frequency,
    ROUND(SUM(co.order_value), 2) AS monetary_value
FROM customer_orders co
GROUP BY co.customer_unique_id
ORDER BY monetary_value DESC;


-- ============================================================
-- 10. Monthly revenue growth using window function
-- Business question:
-- How does revenue grow or decline month over month?
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS order_month,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
)

SELECT
    order_month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY order_month) AS previous_month_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY order_month)) * 100.0 /
        NULLIF(LAG(total_revenue) OVER (ORDER BY order_month), 0),
        2
    ) AS revenue_growth_percentage
FROM monthly_revenue
ORDER BY order_month;
