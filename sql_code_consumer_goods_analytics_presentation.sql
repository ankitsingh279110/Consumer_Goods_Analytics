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




