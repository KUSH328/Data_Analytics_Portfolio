-- MySQL 8+ business analysis.
-- Import the workbook into datacosupplychain_clean_sql before running these queries.
-- The source is at order-item grain; use COUNT(DISTINCT `Order Id`) for order counts.
CREATE DATABASE IF NOT EXISTS dataco_supply_chain;
USE dataco_supply_chain;

-- Executive KPIs and label coverage.
SELECT
    COUNT(*) AS Order_Lines,
    COUNT(DISTINCT `Order Id`) AS Distinct_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(AVG(`Order Profit Per Order`), 2) AS Avg_Profit_Per_Line,
    ROUND(100 * AVG(CASE WHEN `Late_delivery_risk` IN (0, 1)
                         THEN `Late_delivery_risk` END), 2) AS Late_Risk_Pct
FROM `datacosupplychain_clean_sql`;

-- Service performance by shipping mode.
SELECT
    `Shipping Mode`,
    COUNT(*) AS Order_Lines,
    COUNT(DISTINCT `Order Id`) AS Distinct_Orders,
    SUM(CASE WHEN `Late_delivery_risk` = 1 THEN 1 ELSE 0 END) AS At_Risk_Lines,
    ROUND(100 * AVG(CASE WHEN `Late_delivery_risk` IN (0, 1)
                         THEN `Late_delivery_risk` END), 2) AS Late_Risk_Pct,
    ROUND(AVG(`Days for shipping (real)`), 2) AS Avg_Actual_Shipping_Days,
    ROUND(AVG(`Days for shipment (scheduled)`), 2) AS Avg_Scheduled_Shipping_Days
FROM `datacosupplychain_clean_sql`
GROUP BY `Shipping Mode`
ORDER BY Late_Risk_Pct DESC;

-- Market economics: distinguish revenue from profit.
SELECT
    `Market`,
    COUNT(DISTINCT `Order Id`) AS Distinct_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(AVG(`Order Profit Per Order`), 2) AS Avg_Profit_Per_Line,
    ROUND(100 * AVG(CASE WHEN `Late_delivery_risk` IN (0, 1)
                         THEN `Late_delivery_risk` END), 2) AS Late_Risk_Pct
FROM `datacosupplychain_clean_sql`
GROUP BY `Market`
ORDER BY Total_Profit DESC;

-- Lowest-profit categories, including volume to aid prioritization.
SELECT
    `Category Name`,
    COUNT(*) AS Order_Lines,
    COUNT(DISTINCT `Order Id`) AS Distinct_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(AVG(`Order Profit Per Order`), 2) AS Avg_Profit_Per_Line
FROM `datacosupplychain_clean_sql`
GROUP BY `Category Name`
HAVING AVG(`Order Profit Per Order`) < 0
ORDER BY Avg_Profit_Per_Line ASC;

-- Top customers by sales (IDs only; no personal names are needed for ranking).
SELECT
    `Customer Id`,
    COUNT(DISTINCT `Order Id`) AS Distinct_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit
FROM `datacosupplychain_clean_sql`
GROUP BY `Customer Id`
ORDER BY Total_Sales DESC
LIMIT 10;

-- Monthly trend, ordered by calendar month.
SELECT
    DATE_FORMAT(`order date (DateOrders)`, '%Y-%m-01') AS Order_Month,
    COUNT(DISTINCT `Order Id`) AS Distinct_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(100 * AVG(CASE WHEN `Late_delivery_risk` IN (0, 1)
                         THEN `Late_delivery_risk` END), 2) AS Late_Risk_Pct
FROM `datacosupplychain_clean_sql`
GROUP BY DATE_FORMAT(`order date (DateOrders)`, '%Y-%m-01')
ORDER BY Order_Month;