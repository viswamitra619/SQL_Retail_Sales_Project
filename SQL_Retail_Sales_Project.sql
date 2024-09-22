# SQL Retail Sales analysis Project
-- Creating Database
create database retail_sales;
use  retail_sales;

 -- Creating a Table
drop table if exists sales;
CREATE TABLE sales (
    transactions_id INT PRIMARY KEY,
    sale_date DATE DEFAULT NULL,
    sale_time TIME DEFAULT NULL,
    customer_id INT DEFAULT NULL,
    gender VARCHAR(15) DEFAULT NULL,
    age INT DEFAULT NULL,
    category VARCHAR(30) DEFAULT NULL,
    quantity INT DEFAULT NULL,
    price_per_unit DOUBLE DEFAULT NULL,
    cogs DOUBLE DEFAULT NULL,
    total_sale DOUBLE DEFAULT NULL
);
 
-- Loading data into table (faster way)  

load data infile "K:\\Data analysis pandas\\SQL Project\\Retail Sales#1 Project\\Retail-Sales-Analysis-SQL-Project--P1-main\\sales.csv"
into table sales
fields terminated by ','
lines terminated by '\r\n' -- if last column values are blank in csv file then use '/r/n'
ignore 1 lines
(transactions_id, @sale_date, sale_time, customer_id, gender, @age, category, @quantity, @price_per_unit, @cogs, @total_sale)
SET
    transactions_id = NULLIF(transactions_id, ''),
    sale_date = IF(@sale_date = '', NULL, @sale_date),  -- Handles empty date
    sale_time = NULLIF(sale_time, ''),
    customer_id = NULLIF(customer_id, ''),
    gender = NULLIF(gender, ''),
    age = IF(@age = '', NULL, @age),  -- Convert empty age to NULL
    category = NULLIF(category, ''),
    quantity = IF(@quantity = '', NULL, @quantity),  -- Convert empty quantity to NULL
    price_per_unit = IF(@price_per_unit = '', NULL, @price_per_unit),  -- Convert empty price_per_unit to NULL
    cogs = IF(@cogs = '', NULL, @cogs),  -- Convert empty cogs to NULL
    total_sale = IF(@total_sale = '', NULL, @total_sale);-- Convert empty total_sale to NULL
   
SELECT 
    COUNT(*)
FROM
    sales;
    
    --  10 elements view starting from 6th element
SELECT * FROM sales
LIMIT 10 OFFSET 5;
    
    -- Finding rows with null values
SELECT * FROM sales
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
        
     -- Deleting rows with null values   
DELETE FROM sales 
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
        
-- Data Analysis & Business Key Problems & Answers
-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold more than 5 in month of Nov-2022?
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)


-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05 
SELECT * FROM sales
WHERE
    sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold more than 5 in month of Nov-2022?
SELECT *, DATE_FORMAT(sale_date, '%Y-%m') AS formated_date
FROM
    sales
WHERE
    category = 'Clothing' AND quantity >= 4
        AND DATE_FORMAT(sale_date, '%Y-%m') = '2022-11';

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT 
   category, SUM(total_sale) AS total_sales
FROM
    sales
GROUP BY category;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT 
    category, AVG(age) AS avg_age_of_customers
FROM
    sales
WHERE
    category = 'Beauty'
GROUP BY category;

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT 
    transactions_id
FROM
    sales
WHERE
    total_sale > 1000;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT 
    category,
    gender,
    COUNT(transactions_id) AS total_transactions
FROM
    sales
GROUP BY category , gender
ORDER BY category DESC;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
select * from
(select  date_format(sale_date, '%Y') as formated_year, date_format(sale_date,'%m') as formated_month, round(avg(total_sale),2) as avg_sale,
rank()over(partition by date_format(sale_date, '%Y') order by round(avg(total_sale),2) desc ) as rank_
 from sales
group by 1,2) as t1
where rank_ = 1;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales
SELECT 
    customer_id, SUM(total_sale) AS total_sales
FROM
    sales
GROUP BY 1
ORDER BY SUM(total_sale) DESC
LIMIT 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT 
    COUNT(DISTINCT customer_id) AS unique_customers, category
FROM
    sales
GROUP BY category;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
SELECT 
    shift, COUNT(transactions_id)
FROM
    (SELECT 
        CASE
                WHEN TIME_FORMAT(sale_time, '%H') <= 12 THEN 'Morning'
                WHEN
                    TIME_FORMAT(sale_time, '%H') > 12
                        AND TIME_FORMAT(sale_time, '%H') <= 17
                THEN
                    'Afternoon'
                WHEN TIME_FORMAT(sale_time, '%H') > 17 THEN 'Evening'
            END AS shift,
            transactions_id
    FROM
        sales) t1
GROUP BY 1
