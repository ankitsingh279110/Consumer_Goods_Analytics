#TASK 1

SELECT
	DISTINCT market FROM dim_customer
	WHERE region = 'APAC' AND customer = "Atliq Exclusive";

#TASK 2

WITH cte1 AS (
    SELECT COUNT(DISTINCT product_code) AS a
    FROM fact_gross_price
    WHERE fiscal_year = 2020
),
cte2 AS (
    SELECT COUNT(DISTINCT product_code) AS b
    FROM fact_gross_price
    WHERE fiscal_year = 2021
)
SELECT
    a AS unique_products_2020,
    b AS unique_products_2021,
    Round(((b - a) / a) * 100,2) AS Percentage_chg
FROM
    cte1, cte2;

#TASK 3

SELECT
    segment,
    COUNT(segment) AS product_count
FROM
    dim_product
GROUP BY
    segment
ORDER BY
    product_count DESC;

#TASK 4

WITH cte1 AS (
    SELECT
        segment,
        COUNT(DISTINCT product_code) AS a
    FROM
        dim_product
    JOIN
        fact_forecast_monthly USING (product_code)
    WHERE
        fiscal_year = 2020
    GROUP BY
        segment
),
cte2 AS (
    SELECT
        segment,
        COUNT(DISTINCT product_code) AS b
    FROM
        dim_product
    JOIN
        fact_forecast_monthly USING (product_code)
    WHERE
        fiscal_year = 2021
    GROUP BY
        segment
)
SELECT
    cte1.segment,
    a AS product_count_2020,
    b AS product_count_2021,
    b - a AS difference
FROM
    cte1
JOIN
    cte2 ON cte1.segment = cte2.segment
  ORDER BY difference;

#TASK 5

SELECT
    fmc.product_code,
    dp.product,
    fmc.manufacturing_cost
FROM
    dim_product dp
JOIN
    fact_manufacturing_cost fmc USING (product_code)
WHERE
    fmc.manufacturing_cost = (SELECT MAX(manufacturing_cost) FROM fact_manufacturing_cost)
    OR fmc.manufacturing_cost = (SELECT MIN(manufacturing_cost) FROM fact_manufacturing_cost)
ORDER BY
    fmc.manufacturing_cost DESC;

#TASK 6

SELECT
    customer_code,
    customer,
    ROUND(AVG(pre_invoice_discount_pct), 4) AS average_discount_percentage
FROM (
    SELECT
        dc.customer_code,
        dc.customer,
        fpid.pre_invoice_discount_pct
    FROM
        fact_pre_invoice_deductions fpid
    JOIN
        dim_customer dc ON fpid.customer_code = dc.customer_code
    WHERE
        dc.market = 'India' AND fpid.fiscal_year = '2021'
) AS subquery
GROUP BY
    customer_code, customer
ORDER BY
    average_discount_percentage DESC
LIMIT 5;

#TASK 7

WITH temp_table AS (
    SELECT 
        customer,
        monthname(date) AS months,
        month(date) AS month_number, 
        year(date) AS year,
        (sold_quantity * gross_price) AS gross_sales
    FROM 
        fact_sales_monthly s
        JOIN fact_gross_price g ON s.product_code = g.product_code
        JOIN dim_customer c ON s.customer_code = c.customer_code
    WHERE 
        customer = "Atliq exclusive"
)
SELECT 
    months,
    year,
    CONCAT(ROUND(SUM(gross_sales) / 1000000, 2), "M") AS gross_sales
FROM 
    temp_table
GROUP BY 
    year, months
ORDER BY 
    year, MIN(month_number);

#TASK 8

WITH temp_table AS (
  SELECT 
    date,
    month(date_add(date, interval 4 month)) AS period,
    get_fiscal_year(date) AS fiscal_year,
    sold_quantity 
  FROM 
    fact_sales_monthly
)
SELECT 
  CASE 
    WHEN period / 3 <= 1 THEN "Q1"
    WHEN period / 3 <= 2 AND period / 3 > 1 THEN "Q2"
    WHEN period / 3 <= 3 AND period / 3 > 2 THEN "Q3"
    WHEN period / 3 <= 4 AND period / 3 > 3 THEN "Q4"
  END AS quarter,
  ROUND(SUM(sold_quantity) / 1000000, 2) AS total_sold_quantity_in_millions 
FROM 
  temp_table
WHERE 
  fiscal_year = 2020
GROUP BY 
  quarter
ORDER BY 
  total_sold_quantity_in_millions;

#TASK 9

WITH sales_summary AS (
    SELECT
        c.channel,
        SUM(s.sold_quantity * g.gross_price) AS total_sales
    FROM
        fact_sales_monthly s
        JOIN fact_gross_price g ON s.product_code = g.product_code
        JOIN dim_customer c ON s.customer_code = c.customer_code
    WHERE
        get_fiscal_year(s.date) = 2021
    GROUP BY
        c.channel
),
sales_percentage AS (
    SELECT
        channel,
        ROUND(total_sales / 1000000, 2) AS gross_sales_in_millions,
        ROUND(total_sales / (SUM(total_sales) OVER ()) * 100, 2) AS percentage
    FROM
        sales_summary
)
SELECT
    channel,
    gross_sales_in_millions,
    percentage
FROM
    sales_percentage
    ORDER BY
	percentage;

#TASK 10

WITH temp_table AS (
    SELECT 
        division,
        fsm.product_code,
        CONCAT(dp.product, '(', dp.variant, ')') AS product,
        SUM(sold_quantity) AS total_sold_quantity,
        RANK() OVER (PARTITION BY division ORDER BY SUM(sold_quantity) DESC) AS rank_order
    FROM
        fact_sales_monthly fsm
        JOIN dim_product dp ON fsm.product_code = dp.product_code
    WHERE
        fiscal_year = 2021
    GROUP BY
        division, product_code
)
SELECT 
    division,
    product_code,
    product,
    total_sold_quantity,
    rank_order
FROM 
    temp_table
WHERE 
    rank_order IN (1, 2, 3);





