
-- ============================================================
-- MACRO DRIVERS & BUILDING MATERIALS TRANSACTIONS ANALYSIS
-- ============================================================

-- 1. Overview of Macro Drivers Dataset
SELECT
    'Macro Drivers Overview' AS analysis_section,
    COUNT(*)                 AS total_weeks,
    MIN(week)                AS earliest_week,
    MAX(week)                AS latest_week,
    ROUND(AVG(mortgage_rate), 4)          AS avg_mortgage_rate,
    ROUND(MIN(mortgage_rate), 4)          AS min_mortgage_rate,
    ROUND(MAX(mortgage_rate), 4)          AS max_mortgage_rate,
    ROUND(AVG(lumber_price_index), 4)     AS avg_lumber_price_index,
    ROUND(MIN(lumber_price_index), 4)     AS min_lumber_price_index,
    ROUND(MAX(lumber_price_index), 4)     AS max_lumber_price_index,
    ROUND(AVG(housing_starts_index), 4)   AS avg_housing_starts_index,
    ROUND(MIN(housing_starts_index), 4)   AS min_housing_starts_index,
    ROUND(MAX(housing_starts_index), 4)   AS max_housing_starts_index,
    ROUND(AVG(season_factor), 4)          AS avg_season_factor
FROM Macro_drivers_cleaned

-- 2. Overview of Building Materials Transactions Dataset
SELECT
    'Building Materials Overview' AS analysis_section,
    COUNT(*)                      AS total_transactions,
    MIN(date)                     AS earliest_date,
    MAX(date)                     AS latest_date,
    ROUND(AVG(revenue), 4)        AS avg_revenue,
    ROUND(MIN(revenue), 4)        AS min_revenue,
    ROUND(MAX(revenue), 4)        AS max_revenue,
    ROUND(AVG(unit_price), 4)     AS avg_unit_price,
    ROUND(MIN(unit_price), 4)     AS min_unit_price,
    ROUND(MAX(unit_price), 4)     AS max_unit_price,
    ROUND(AVG(units), 4)          AS avg_units_sold,
    ROUND(MIN(units), 4)          AS min_units_sold,
    ROUND(MAX(units), 4)          AS max_units_sold,
    ROUND(AVG(mortgage_rate), 4)  AS avg_mortgage_rate_in_transactions
FROM building_materials_transactions_Cleaned;

-- ============================================================
-- 3. Monthly Revenue Trend with Macro Indicators
-- ============================================================
SELECT
    toStartOfMonth(b.date)              AS month,
    ROUND(SUM(b.revenue), 2)            AS total_revenue,
    SUM(b.units)                        AS total_units_sold,
    ROUND(AVG(b.unit_price), 4)         AS avg_unit_price,
    ROUND(AVG(m.mortgage_rate), 4)      AS avg_mortgage_rate,
    ROUND(AVG(m.lumber_price_index), 4) AS avg_lumber_price_index,
    ROUND(AVG(m.housing_starts_index), 4) AS avg_housing_starts_index,
    ROUND(AVG(m.season_factor), 4)      AS avg_season_factor
FROM building_materials_transactions_Cleaned b
LEFT JOIN Macro_drivers_cleaned m
    ON toMonday(b.date) = m.week
GROUP BY month
ORDER BY month;

-- ============================================================
-- 4. Revenue by Product Category with Macro Context
-- ============================================================
SELECT
    b.product_category,
    COUNT(*)                              AS transaction_count,
    ROUND(SUM(b.revenue), 2)             AS total_revenue,
    SUM(b.units)                         AS total_units,
    ROUND(AVG(b.unit_price), 4)          AS avg_unit_price,
    ROUND(AVG(m.mortgage_rate), 4)       AS avg_mortgage_rate,
    ROUND(AVG(m.lumber_price_index), 4)  AS avg_lumber_price_index,
    ROUND(AVG(m.housing_starts_index), 4) AS avg_housing_starts_index
FROM building_materials_transactions_Cleaned b
LEFT JOIN Macro_drivers_cleaned m
    ON toMonday(b.date) = m.week
GROUP BY b.product_category
ORDER BY total_revenue DESC;

-- ============================================================
-- 5. Revenue by Region and Channel with Macro Indicators
-- ============================================================
SELECT
    b.region,
    b.channel,
    COUNT(*)                              AS transaction_count,
    ROUND(SUM(b.revenue), 2)             AS total_revenue,
    SUM(b.units)                         AS total_units,
    ROUND(AVG(m.mortgage_rate), 4)       AS avg_mortgage_rate,
    ROUND(AVG(m.housing_starts_index), 4) AS avg_housing_starts_index,
    ROUND(AVG(m.lumber_price_index), 4)  AS avg_lumber_price_index
FROM building_materials_transactions_Cleaned b
LEFT JOIN Macro_drivers_cleaned m
    ON toMonday(b.date) = m.week
GROUP BY b.region, b.channel
ORDER BY total_revenue DESC;

-- ============================================================
-- 6. Correlation Analysis: Mortgage Rate vs Revenue
-- ============================================================
SELECT
    ROUND(m.mortgage_rate, 2)            AS mortgage_rate_bucket,
    COUNT(*)                             AS transaction_count,
    ROUND(SUM(b.revenue), 2)            AS total_revenue,
    ROUND(AVG(b.revenue), 2)            AS avg_revenue_per_transaction,
    SUM(b.units)                         AS total_units
FROM building_materials_transactions_Cleaned b
LEFT JOIN Macro_drivers_cleaned m
    ON toMonday(b.date) = m.week
WHERE m.mortgage_rate IS NOT NULL
GROUP BY mortgage_rate_bucket
ORDER BY mortgage_rate_bucket;

-- ============================================================
-- 7. Seasonal Analysis: Season Factor vs Revenue
-- ============================================================
SELECT
    ROUND(m.season_factor, 1)            AS season_factor_bucket,
    COUNT(*)                             AS transaction_count,
    ROUND(SUM(b.revenue), 2)            AS total_revenue,
    ROUND(AVG(b.revenue), 2)            AS avg_revenue_per_transaction,
    SUM(b.units)                         AS total_units,
    b.product_category
FROM building_materials_transactions_Cleaned b
LEFT JOIN Macro_drivers_cleaned m
    ON toMonday(b.date) = m.week
WHERE m.season_factor IS NOT NULL
GROUP BY season_factor_bucket, b.product_category
ORDER BY season_factor_bucket, total_revenue DESC;

-- ============================================================
-- 8. Customer Type Analysis with Macro Drivers
-- ============================================================
SELECT
    b.customer_type,
    b.year,
    COUNT(*)                              AS transaction_count,
    ROUND(SUM(b.revenue), 2)             AS total_revenue,
    ROUND(AVG(b.revenue), 2)             AS avg_revenue,
    SUM(b.units)                         AS total_units,
    ROUND(AVG(m.mortgage_rate), 4)       AS avg_mortgage_rate,
    ROUND(AVG(m.housing_starts_index), 4) AS avg_housing_starts_index
FROM building_materials_transactions_Cleaned b
LEFT JOIN Macro_drivers_cleaned m
    ON toMonday(b.date) = m.week
GROUP BY b.customer_type, b.year
ORDER BY b.year, total_revenue DESC;

-- ============================================================
-- 9. Lumber Price Index Impact on Revenue by SKU
-- ============================================================
SELECT
    b.sku,
    b.product_category,
    COUNT(*)                              AS transaction_count,
    ROUND(SUM(b.revenue), 2)             AS total_revenue,
    ROUND(AVG(b.unit_price), 4)          AS avg_unit_price,
    ROUND(AVG(m.lumber_price_index), 4)  AS avg_lumber_price_index,
    ROUND(
        corr(b.revenue, m.lumber_price_index)
    , 4)                                  AS revenue_lumber_correlation
FROM building_materials_transactions_Cleaned b
LEFT JOIN Macro_drivers_cleaned m
    ON toMonday(b.date) = m.week
WHERE m.lumber_price_index IS NOT NULL
GROUP BY b.sku, b.product_category
HAVING transaction_count > 10
ORDER BY revenue_lumber_correlation DESC
LIMIT 20;

-- ============================================================
-- 10. Year-over-Year Revenue Growth with Macro Comparison
-- ============================================================
SELECT
    b.year,
    ROUND(SUM(b.revenue), 2)              AS total_revenue,
    SUM(b.units)                          AS total_units,
    ROUND(AVG(m.mortgage_rate), 4)        AS avg_mortgage_rate,
    ROUND(AVG(m.lumber_price_index), 4)   AS avg_lumber_price_index,
    ROUND(AVG(m.housing_starts_index), 4) AS avg_housing_starts_index,
    ROUND(AVG(m.season_factor), 4)        AS avg_season_factor,
    ROUND(
        (SUM(b.revenue) - lagInFrame(SUM(b.revenue)) OVER (ORDER BY b.year))
        / lagInFrame(SUM(b.revenue)) OVER (ORDER BY b.year) * 100
    , 2)                                  AS yoy_revenue_growth_pct
FROM building_materials_transactions_Cleaned b
LEFT JOIN Macro_drivers_cleaned m
    ON toMonday(b.date) = m.week
GROUP BY b.year
ORDER BY b.year;