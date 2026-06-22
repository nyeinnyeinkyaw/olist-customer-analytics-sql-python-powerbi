# Olist E-Commerce Customer Analytics Portfolio

## Project Title
**Customer Retention & Sales Performance Analysis for E-Commerce**

## Project Goal
This project analyzes e-commerce sales, customer behavior, delivery performance, and customer satisfaction using SQL, Python, and Power BI.

The goal is to answer business questions such as:

- Which customer segments generate the most revenue?
- Which product categories perform best?
- How do delivery delays affect customer reviews?
- Which regions/states have the strongest sales performance?
- What business actions can improve customer retention and satisfaction?

## Why This Project Matters
This project is designed for Data Analyst, Business Analyst, CRM Intern, and Marketing Analyst internship applications. It demonstrates practical ability in:

- Data cleaning and preprocessing
- SQL querying and business analysis
- Python data manipulation and feature engineering
- Customer segmentation using RFM analysis
- Dashboard design with Power BI
- Business insight generation

## Dataset
Dataset: Brazilian E-Commerce Public Dataset by Olist

Important tables used:
- customers
- orders
- order_items
- order_payments
- order_reviews
- products
- product_category_name_translation

The raw dataset is not included in this repository. Download it from Kaggle and place the CSV files inside:

```text
data/raw/
```

## Tools Used
- SQL / SQLite
- Python
- Pandas
- NumPy
- Matplotlib
- Power BI
- GitHub

## Repository Structure

```text
olist-customer-analytics/
│
├── data/
│   ├── raw/                  # downloaded Kaggle CSV files
│   └── processed/            # cleaned CSV files for Power BI
│
├── sql/
│   ├── 00_create_tables_sqlite.sql
│   └── 01_business_analysis_queries.sql
│
├── python/
│   └── olist_customer_analytics_template.ipynb
│
├── powerbi/
│   └── dashboard_notes.md
│
├── images/
│   └── dashboard screenshots and charts
│
├── outputs/
│   └── exported analysis tables
│
├── docs/
│   ├── powerbi_dashboard_blueprint.md
│   ├── project_explanation_for_interview.md
│   └── repository_upload_steps.md
│
├── requirements.txt
├── .gitignore
└── README.md
```

## Business Questions

### 1. Sales Performance
- What is the monthly sales trend?
- Which product categories generate the most revenue?
- Which states contribute the highest order volume and revenue?

### 2. CRM / Customer Analysis
- Who are the most valuable customers?
- How can customers be segmented by recency, frequency, and monetary value?
- Which customer groups should receive retention campaigns?

### 3. Customer Satisfaction
- How are review scores distributed?
- Do late deliveries lead to lower review scores?
- Which product categories have lower satisfaction?

### 4. Operational Insights
- Which states have longer delivery times?
- Which products/categories have high freight costs?
- Where can service improvement increase customer satisfaction?

## Main Outputs
After completing this project, the portfolio will include:

- SQL analysis queries
- Python notebook for cleaning, EDA, and customer segmentation
- Power BI dashboard screenshots
- Business insights and recommendations
- GitHub README explaining the project clearly

## Suggested Dashboard Pages

### Page 1: Executive Overview
- Total Revenue
- Total Orders
- Average Review Score
- Average Delivery Days
- Monthly Sales Trend
- Top Product Categories

### Page 2: Customer & CRM Analysis
- RFM Customer Segments
- Revenue by Segment
- Customer Distribution by State
- Repeat vs One-time Customers

### Page 3: Delivery & Satisfaction
- Average Delivery Time
- Late vs On-time Delivery
- Review Score by Delivery Status
- States with High Delivery Delays

### Page 4: Product Performance
- Revenue by Product Category
- Average Freight Cost by Category
- Review Score by Product Category

## Portfolio Summary
This project demonstrates end-to-end data analytics workflow from raw data to business insight:

```text
Raw Data → SQL Database → SQL Analysis → Python Cleaning & Segmentation → Power BI Dashboard → Business Recommendations
```

## Status
In progress.

## Author
Nyein Nyein Kyaw  
Digital Technology for Business Innovation Student  
Mae Fah Luang University
