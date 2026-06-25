SELECT * FROM walmart;

--1.Total Revenue KPI
SELECT
ROUND(SUM("Weekly_Sales")::numeric,2) AS total_revenue
FROM walmart;

--2.Average Weekly Sales
SELECT
ROUND(AVG("Weekly_Sales")::numeric,2) AS avg_weekly_sales
FROM walmart;

--3.Top 10 Performing Stores
SELECT
"Store",
ROUND(SUM("Weekly_Sales")::numeric,2) AS total_sales
FROM walmart
GROUP BY "Store"
ORDER BY total_sales DESC
LIMIT 10;

--4.Bottom 10 Stores
SELECT
"Store",
ROUND(SUM("Weekly_Sales")::numeric,2) AS total_sales
FROM walmart
GROUP BY "Store"
ORDER BY total_sales
LIMIT 10;

--5.Store Contribution %
SELECT
"Store",
ROUND((100*SUM("Weekly_Sales")/SUM(SUM("Weekly_Sales")) OVER())::numeric,2) AS contribution_percent
FROM walmart
GROUP BY "Store"
ORDER BY contribution_percent DESC;

--6.Monthly Sales Trend
SELECT
TO_CHAR("Date",'YYYY-MM') AS month,
ROUND(SUM("Weekly_Sales")::numeric,2) AS sales
FROM walmart
GROUP BY month
ORDER BY month;

--7.Quarterly Performance
SELECT
EXTRACT(QUARTER FROM "Date") AS quarter,
ROUND(SUM("Weekly_Sales")::numeric,2) AS total_sales
FROM walmart
GROUP BY quarter
ORDER BY quarter;

--8.Holiday vs Non-Holiday Sales
SELECT
"Holiday_Flag",
ROUND(SUM("Weekly_Sales")::numeric,2) AS sales,
ROUND(AVG("Weekly_Sales")::numeric,2) AS avg_sales
FROM walmart
GROUP BY "Holiday_Flag";

--9.Store Ranking Using Window Functions
SELECT
"Store",
SUM("Weekly_Sales") total_sales,
RANK() OVER(
ORDER BY SUM("Weekly_Sales") DESC
) AS rank
FROM walmart
GROUP BY "Store";

--10.Running Total Sales
SELECT
"Date",
SUM("Weekly_Sales") sales,
SUM(SUM("Weekly_Sales"))
OVER(ORDER BY "Date") cumulative_sales
FROM walmart
GROUP BY "Date"
ORDER BY "Date";

--11.4-Week Moving Average
SELECT
"Date",
SUM("Weekly_Sales") sales,
ROUND(
AVG(SUM("Weekly_Sales"))
OVER(
ORDER BY "Date"
ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
)::numeric,2
) moving_average
FROM walmart
GROUP BY "Date"
ORDER BY "Date";

--12.Month-over-Month Growth
WITH monthly_sales AS
(
    SELECT
        TO_CHAR("Date",'YYYY-MM') AS month,
        SUM("Weekly_Sales") AS sales
    FROM walmart
    GROUP BY month
),

growth AS
(
    SELECT
        month,
        sales,
        LAG(sales) OVER(ORDER BY month) AS previous_month
    FROM monthly_sales
)

SELECT
    month,
    ROUND(sales::numeric,2) AS sales,
    ROUND(previous_month::numeric,2) AS previous_month,

    ROUND(
        (
            (sales - previous_month)
            / NULLIF(previous_month,0) * 100
        )::numeric,
        2
    ) AS growth_percentage

FROM growth
ORDER BY month;

--13.Sales Distribution Percentiles
SELECT
PERCENTILE_CONT(0.25)
WITHIN GROUP (ORDER BY "Weekly_Sales") AS q1,

PERCENTILE_CONT(0.50)
WITHIN GROUP (ORDER BY "Weekly_Sales") AS median,

PERCENTILE_CONT(0.75)
WITHIN GROUP (ORDER BY "Weekly_Sales") AS q3
FROM walmart;

--14.Outlier Detection Using Z-Score
SELECT
    "Store",
    "Weekly_Sales",
    ROUND(
        (
            (
                "Weekly_Sales" - AVG("Weekly_Sales") OVER()
            )
            /
            STDDEV("Weekly_Sales") OVER()
        )::numeric,
        2
    ) AS z_score
FROM walmart;

--15.Top 5 Stores Every Year
WITH yearly_store_sales AS (
    SELECT
        EXTRACT(YEAR FROM "Date") AS year,
        "Store",
        SUM("Weekly_Sales") AS sales
    FROM walmart
    GROUP BY
        EXTRACT(YEAR FROM "Date"),
        "Store"
)

SELECT *
FROM (
    SELECT
        year,
        "Store",
        ROUND(sales::numeric, 2) AS sales,
        RANK() OVER (
            PARTITION BY year
            ORDER BY sales DESC
        ) AS ranking
    FROM yearly_store_sales
) t
WHERE ranking <= 5
ORDER BY year, ranking;











