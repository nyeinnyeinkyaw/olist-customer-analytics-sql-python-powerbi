-- 00_create_tables_sqlite.sql
-- SQLite table schema aligned with the Python Colab notebook.
-- In the notebook, these tables are also created automatically using pandas.to_sql().
-- This file is included to show the database structure clearly.

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT,
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state TEXT
);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TEXT,
    order_approved_at TEXT,
    order_delivered_carrier_date TEXT,
    order_delivered_customer_date TEXT,
    order_estimated_delivery_date TEXT
);

DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
    order_id TEXT,
    order_item_id INTEGER,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TEXT,
    price REAL,
    freight_value REAL
);

DROP TABLE IF EXISTS payments;
CREATE TABLE payments (
    order_id TEXT,
    payment_sequential INTEGER,
    payment_type TEXT,
    payment_installments INTEGER,
    payment_value REAL
);

DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews (
    review_id TEXT,
    order_id TEXT,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TEXT,
    review_answer_timestamp TEXT
);

DROP TABLE IF EXISTS products;
CREATE TABLE products (
    product_id TEXT PRIMARY KEY,
    product_category_name TEXT,
    product_name_lenght REAL,
    product_description_lenght REAL,
    product_photos_qty REAL,
    product_weight_g REAL,
    product_length_cm REAL,
    product_height_cm REAL,
    product_width_cm REAL
);

DROP TABLE IF EXISTS category_translation;
CREATE TABLE category_translation (
    product_category_name TEXT PRIMARY KEY,
    product_category_name_english TEXT
);
