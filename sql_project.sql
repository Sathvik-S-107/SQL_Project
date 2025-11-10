-- -----------------------------------------------------
-- 1) CREATE DATABASE  (Run this only once)
-- -----------------------------------------------------
CREATE DATABASE sql_project_p2;

-- -----------------------------------------------------
-- 2) CONNECT TO DATABASE
-- -----------------------------------------------------
\c sql_project_p2;

-- -----------------------------------------------------
-- 3) CREATE TABLE
-- -----------------------------------------------------
DROP TABLE IF EXISTS retail_sales;

CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY, 
    sale_date DATE,
    sale_time TEXT,
    customer_id INT,
    gender VARCHAR(15), 
    age INT, 
    category VARCHAR(15), 
    quantity INT,
    price_per_unit FLOAT, 
    cogs FLOAT, 
    total_sale FLOAT
);

-- -----------------------------------------------------
-- 4) IMPORT CSV
-- -----------------------------------------------------
copy public.retail_sales(
    transactions_id, sale_date, sale_time, customer_id,
    gender, age, category, quantity, price_per_unit, cogs, total_sale
)
FROM 'C:/Users/shiva/OneDrive/Desktop/ANALYS~1/RETAIL~1/SQL-RE~1.CSV'
WITH (FORMAT csv, DELIMITER ',', HEADER true);

-- -----------------------------------------------------
-- 5) FIX TIME FORMAT
-- -----------------------------------------------------
UPDATE retail_sales
SET sale_time = REPLACE(sale_time, '.', ':');

ALTER TABLE retail_sales
ALTER COLUMN sale_time TYPE TIME
USING sale_time::time;

-- -----------------------------------------------------
-- 6) VIEW FULL TABLE
-- -----------------------------------------------------
SELECT * FROM public.retail_sales
ORDER BY transactions_id ASC;

-- -----------------------------------------------------
-- 7) FIND ROWS WITH NULL VALUES AND DELETE
-- -----------------------------------------------------
SELECT * FROM retail_sales
WHERE 
      transactions_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR age IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;

DELETE FROM retail_sales
WHERE 
      transactions_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR age IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;


-- -----------------------------------------------------
-- 8) CHECK TOP 10
-- -----------------------------------------------------
SELECT *FROM public.retail_sales
ORDER BY transactions_id ASC
LIMIT 10;

-- -----------------------------------------------------
-- 9) COUNT TOTAL ROWS
-- -----------------------------------------------------
SELECT COUNT(*) AS total_rows
FROM retail_sales;

-- -----------------------------------------------------
-- 10) DATA EXPLORATION
-- -----------------------------------------------------

-- No. of sales 
SELECT COUNT(*) AS total_sales FROM retail_sales;

-- No. of unique customers 
SELECT COUNT( DISTINCT customer_id) AS total_customers FROM retail_sales;

-- No. of unique categories
SELECT DISTINCT category AS total_sale FROM retail_sales;

-- ============================================
-- 11) DATA ANALYSIS & BUSINESS KEY PROBLEMS
-- ============================================


-- Q1. Retrieve all columns for sales made on '2022-11-05'
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q2. Retrieve all transactions where the category is 'Clothing'
--     and quantity sold >= 4 in Nov-2022
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
      AND
	  TO_CHAR(sale_date, 'YYYY-MM')= '2022-11'
      AND
	  quantity>= 4

-- Q3. Calculate total sales (total_sale) for each category
SELECT category, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category

-- Q4. Find average age of customers who purchased items
--     from the 'Beauty' category
SELECT AVG(age) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q5. Find all transactions where total_sale > 1000
SELECT *FROM retail_sales
WHERE total_sale > 1000

-- Q6. Total number of transactions by each gender in each category
SELECT gender, category, COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY gender, category
ORDER BY 1

-- Q7. Average sale for each month.
--     Also find best-selling month each year
SELECT*FROM
(
	SELECT
	    EXTRACT(YEAR FROM sale_date) as year,
	    EXTRACT(YEAR FROM sale_date) as month,
	    AVG(total_sale) AS avg_monthly_sale,
		RANK() OVER(PARTITION BY EXTRACT (YEAR FROM sale_date)ORDER BY AVG (total_sale)DESC) as rank
	FROM retail_sales
	GROUP BY 1,2
) as t1
WHERE rank=1
     
-- Q8. Top 5 customers based on highest total sales
SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Q9. Number of unique customers who purchased items from each category
SELECT category, COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category
ORDER BY unique_customers DESC;

-- Q10. Create sales shifts & count number of orders:
--      Morning  < 12
--      Afternoon 12-17
--      Evening  > 17
SELECT
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY shift
ORDER BY shift;

-- ============================================
-- END OF PROJECT
-- ============================================