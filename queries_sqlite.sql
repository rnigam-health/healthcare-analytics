-- =====================================================================
-- PHARMA SFE & IC ANALYTICS — SQLite Version
-- Just import the 6 CSVs as tables in DB Browser, then run these queries
-- =====================================================================

-- Q1. TOP 10 REPS BY ATTAINMENT (latest quarter) -- IC analytics
SELECT 
    r.rep_id,
    r.rep_name,
    r.territory,
    r.manager,
    ic.quota_units,
    ic.actual_units,
    ic.attainment_pct,
    ic.payout_inr
FROM ic_quotas ic
JOIN sales_reps r ON r.rep_id = ic.rep_id
WHERE ic.quarter = '2026-Q1'
ORDER BY ic.attainment_pct DESC
LIMIT 10;


-- Q2. CALL-TO-RX CONVERSION BY REP -- SFE effectiveness
SELECT
    r.rep_id,
    r.rep_name,
    r.territory,
    COUNT(DISTINCT c.call_id) AS total_calls,
    COALESCE(SUM(rx.rx_count), 0) AS total_rx,
    ROUND(CAST(COALESCE(SUM(rx.rx_count), 0) AS REAL) / NULLIF(COUNT(DISTINCT c.call_id), 0), 2) AS rx_per_call
FROM sales_reps r
LEFT JOIN call_activity c ON c.rep_id = r.rep_id
LEFT JOIN prescriptions rx 
    ON rx.hcp_id = c.hcp_id 
    AND rx.product_id = c.product_id
GROUP BY r.rep_id, r.rep_name, r.territory
ORDER BY rx_per_call DESC;


-- Q3. HCP SEGMENT COVERAGE -- Targeting analysis
SELECT
    h.segment,
    COUNT(DISTINCT h.hcp_id) AS hcps_in_segment,
    COUNT(DISTINCT c.hcp_id) AS hcps_called,
    ROUND(CAST(COUNT(DISTINCT c.hcp_id) AS REAL) * 100 / COUNT(DISTINCT h.hcp_id), 1) AS coverage_pct,
    COUNT(c.call_id) AS total_calls,
    ROUND(CAST(COUNT(c.call_id) AS REAL) / NULLIF(COUNT(DISTINCT c.hcp_id), 0), 1) AS avg_calls_per_called_hcp
FROM hcps h
LEFT JOIN call_activity c ON c.hcp_id = h.hcp_id
GROUP BY h.segment
ORDER BY h.segment;


-- Q4. PRODUCT-LEVEL MARKET PERFORMANCE
SELECT
    p.product_id,
    p.product_name,
    p.therapy_area,
    SUM(rx.rx_count) AS total_rx,
    SUM(rx.units_dispensed) AS total_units,
    ROUND(SUM(rx.units_dispensed) * p.unit_price / 1000000.0, 2) AS revenue_inr_mn
FROM products p
JOIN prescriptions rx ON rx.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.therapy_area, p.unit_price
ORDER BY revenue_inr_mn DESC;


-- Q5. TERRITORY ALIGNMENT EFFICIENCY
SELECT
    r.territory,
    COUNT(DISTINCT r.rep_id) AS reps_count,
    COUNT(DISTINCT h.hcp_id) AS hcps_count,
    ROUND(CAST(COUNT(DISTINCT h.hcp_id) AS REAL) / NULLIF(COUNT(DISTINCT r.rep_id), 0), 0) AS hcps_per_rep,
    SUM(rx.rx_count) AS total_territory_rx,
    ROUND(CAST(SUM(rx.rx_count) AS REAL) / NULLIF(COUNT(DISTINCT r.rep_id), 0), 0) AS rx_per_rep
FROM sales_reps r
LEFT JOIN hcps h ON h.territory = r.territory
LEFT JOIN prescriptions rx ON rx.hcp_id = h.hcp_id
GROUP BY r.territory
ORDER BY hcps_per_rep DESC;


-- Q6. MONTH-OVER-MONTH RX TREND BY PRODUCT (window function)
SELECT
    p.product_name,
    rx.rx_month,
    SUM(rx.rx_count) AS monthly_rx,
    LAG(SUM(rx.rx_count)) OVER (PARTITION BY p.product_name ORDER BY rx.rx_month) AS prev_month_rx,
    ROUND(
        100.0 * (SUM(rx.rx_count) - LAG(SUM(rx.rx_count)) OVER (PARTITION BY p.product_name ORDER BY rx.rx_month))
        / NULLIF(LAG(SUM(rx.rx_count)) OVER (PARTITION BY p.product_name ORDER BY rx.rx_month), 0),
        1
    ) AS mom_growth_pct
FROM prescriptions rx
JOIN products p ON p.product_id = rx.product_id
GROUP BY p.product_name, rx.rx_month
ORDER BY p.product_name, rx.rx_month;


-- Q7. UNDERPERFORMING TERRITORIES (call effort high, Rx low)
WITH territory_metrics AS (
    SELECT
        r.territory,
        COUNT(c.call_id) AS total_calls,
        SUM(rx.rx_count) AS total_rx
    FROM sales_reps r
    LEFT JOIN call_activity c ON c.rep_id = r.rep_id
    LEFT JOIN hcps h ON h.territory = r.territory
    LEFT JOIN prescriptions rx ON rx.hcp_id = h.hcp_id
    GROUP BY r.territory
)
SELECT
    territory,
    total_calls,
    total_rx,
    ROUND(CAST(total_rx AS REAL) / NULLIF(total_calls, 0), 2) AS rx_per_call,
    CASE
        WHEN CAST(total_rx AS REAL) / NULLIF(total_calls, 0) < 0.5 THEN 'Underperforming'
        WHEN CAST(total_rx AS REAL) / NULLIF(total_calls, 0) < 1.0 THEN 'Average'
        ELSE 'High Performing'
    END AS performance_flag
FROM territory_metrics
ORDER BY rx_per_call;


-- Q8. SPECIALTY-WISE RX SHARE
SELECT
    h.specialty,
    p.product_name,
    SUM(rx.rx_count) AS rx_count,
    ROUND(100.0 * SUM(rx.rx_count) / SUM(SUM(rx.rx_count)) OVER (PARTITION BY h.specialty), 1) AS pct_share_in_specialty
FROM hcps h
JOIN prescriptions rx ON rx.hcp_id = h.hcp_id
JOIN products p ON p.product_id = rx.product_id
GROUP BY h.specialty, p.product_name
ORDER BY h.specialty, rx_count DESC;


-- Q9. IC PAYOUT DISTRIBUTION ACROSS QUARTERS
SELECT
    quarter,
    COUNT(*) AS reps,
    ROUND(AVG(attainment_pct), 1) AS avg_attainment_pct,
    SUM(payout_inr) AS total_payout_inr,
    ROUND(AVG(payout_inr), 0) AS avg_payout_per_rep,
    SUM(CASE WHEN attainment_pct >= 100 THEN 1 ELSE 0 END) AS reps_meeting_quota,
    SUM(CASE WHEN attainment_pct < 80 THEN 1 ELSE 0 END) AS reps_below_80pct
FROM ic_quotas
GROUP BY quarter
ORDER BY quarter;


-- Q10. REP RANKING WITHIN REGION (window function)
SELECT
    r.region,
    r.rep_name,
    ic.quarter,
    ic.attainment_pct,
    RANK() OVER (PARTITION BY r.region, ic.quarter ORDER BY ic.attainment_pct DESC) AS region_rank
FROM ic_quotas ic
JOIN sales_reps r ON r.rep_id = ic.rep_id
WHERE ic.quarter = '2026-Q1'
ORDER BY r.region, region_rank;
