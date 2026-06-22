-- 01_business_analysis_queries.sql
-- Business analysis SQL queries for the Olist project.
-- These queries are written for SQLite.

-- 1. Monthly revenue trend
SELECT
    strftime('%Y-%m', o.order_purchase_timestamp) AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;

-- 2. Revenue by customer state
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    ROUND(AVG(oi.price + oi.freight_value), 2) AS avg_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- 3. Top product categories by revenue
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name) AS product_category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t ON p.product_category_name = t.product_category_name
LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY product_category
ORDER BY total_revenue DESC
LIMIT 15;

-- 4. Payment type analysis
SELECT
    payment_type,
    COUNT(*) AS payment_count,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS avg_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;

-- 5. Delivery performance by state
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    ROUND(AVG(julianday(o.order_delivered_customer_date) - julianday(o.order_purchase_timestamp)), 2) AS avg_delivery_days,
    ROUND(AVG(julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date)), 2) AS avg_delay_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING delivered_orders >= 100
ORDER BY avg_delivery_days DESC;

-- 6. Review score by delivery status
WITH delivery_status AS (
    SELECT
        o.order_id,
        CASE
            WHEN julianday(o.order_delivered_customer_date) <= julianday(o.order_estimated_delivery_date)
            THEN 'On-time'
            ELSE 'Late'
        END AS delivery_status,
        r.review_score
    FROM orders o
    JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
)
SELECT
    delivery_status,
    COUNT(*) AS review_count,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM delivery_status
GROUP BY delivery_status;

-- 7. RFM base table for customer segmentation
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        date(o.order_purchase_timestamp) AS order_date,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id, o.order_id, order_date
),
max_date AS (
    SELECT MAX(order_date) AS latest_order_date
    FROM customer_orders
)
SELECT
    co.customer_unique_id,
    CAST(julianday((SELECT latest_order_date FROM max_date)) - julianday(MAX(co.order_date)) AS INTEGER) AS recency_days,
    COUNT(DISTINCT co.order_id) AS frequency,
    ROUND(SUM(co.order_value), 2) AS monetary_value
FROM customer_orders co
GROUP BY co.customer_unique_id
ORDER BY monetary_value DESC;

-- 8. Product categories with low review scores
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name) AS product_category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t ON p.product_category_name = t.product_category_name
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY product_category
HAVING total_orders >= 100
ORDER BY avg_review_score ASC
LIMIT 15;

-- 9. Window function: monthly revenue and month-over-month change
WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS order_month,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
)
SELECT
    order_month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY order_month) AS previous_month_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY order_month)) * 100.0 /
        NULLIF(LAG(total_revenue) OVER (ORDER BY order_month), 0), 2
    ) AS revenue_growth_pct
FROM monthly_sales
ORDER BY order_month;

-- 10. Customer repeat purchase rate
WITH customer_order_counts AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS customer_percentage
FROM customer_order_counts
GROUP BY customer_type;
