-- TELCO CUSTOMER CHURN ANALYSIS
-- Purpose: Analyze customer churn, risk, customer value,
--          and potential revenue exposure using MySQL.
-- 1. DATABASE SETUP
CREATE DATABASE IF NOT EXISTS telco_churn;

USE telco_churn;

USE telco_churn;

-- 2. CUSTOMER TABLE
-- Stores customer demographics, services, billing information,
-- churn status, and engineered customer risk/value attributes.
CREATE TABLE customers (
    customerID              VARCHAR(20) PRIMARY KEY,
    gender                   VARCHAR(10),
    SeniorCitizen            VARCHAR(5),
    Partner                  VARCHAR(5),
    Dependents               VARCHAR(5),
    tenure                   INT,
    PhoneService             VARCHAR(5),
    MultipleLines            VARCHAR(20),
    InternetService          VARCHAR(20),
    OnlineSecurity           VARCHAR(20),
    OnlineBackup             VARCHAR(20),
    DeviceProtection         VARCHAR(20),
    TechSupport              VARCHAR(20),
    StreamingTV              VARCHAR(20),
    StreamingMovies          VARCHAR(20),
    Contract                 VARCHAR(20),
    PaperlessBilling         VARCHAR(5),
    PaymentMethod            VARCHAR(30),
    MonthlyCharges           DECIMAL(8,2),
    TotalCharges             DECIMAL(10,2),
    Churn                    VARCHAR(5),
    -- Engineered fields used for customer segmentation
    tenure_group             VARCHAR(20),
    risk_score               DECIMAL(4,1),
    risk_tier                VARCHAR(20),
    value_tier                VARCHAR(20),
    business_segment          VARCHAR(50)
);


-- 3. DATA QUALITY VALIDATION
-- Verify that the customer data contains no duplicate IDs,
-- missing values in key fields, or unexpected churn categories.
-- Check for duplicate customer IDs
SELECT
    customerID,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customerID
HAVING COUNT(*) > 1;


-- Check for missing values in important fields
SELECT
    SUM(customerID IS NULL) AS missing_customer_id,
    SUM(tenure IS NULL) AS missing_tenure,
    SUM(MonthlyCharges IS NULL) AS missing_monthly_charges,
    SUM(TotalCharges IS NULL) AS missing_total_charges,
    SUM(Churn IS NULL) AS missing_churn
FROM customers;


-- Check the available churn categories
-- Expected values: Yes and No
SELECT
    Churn,
    COUNT(*) AS customers
FROM customers
GROUP BY Churn;
-- Review the engineered risk and value attributes
-- for a sample of customers.
SELECT
    customerID,
    risk_tier,
    value_tier,
    business_segment,
    risk_score
FROM customers
LIMIT 10;

-- 4. OVERALL CHURN PERFORMANCE
-- Determine the total customer base, number of churned
-- customers, and overall churn rate.
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM customers;

-- 5. CHURN BY CONTRACT TYPE
-- Identify whether contract length is associated with
-- different customer churn rates.
SELECT
    Contract,
    COUNT(*) AS customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM customers
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- 6. CHURN BY INTERNET SERVICE
-- Compare churn behavior across different internet
-- service types.
SELECT
    InternetService,
    COUNT(*) AS customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM customers
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;

-- 7. CHURN BY PAYMENT METHOD
-- Examine whether payment method is associated with
-- different levels of customer churn.
SELECT
    PaymentMethod,
    COUNT(*) AS customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM customers
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;

-- 8. CHURN BY CUSTOMER RISK TIER
-- Compare churn rates across the engineered risk categories.
-- Critical customers represent the highest-priority group.
SELECT
    risk_tier,
    COUNT(*) AS customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM customers
GROUP BY risk_tier
ORDER BY FIELD(
    risk_tier,
    'Low',
    'Medium',
    'High',
    'Critical'
);


-- 9. CHURN BY TENURE GROUP
-- Analyze whether newer customers have different churn
-- behavior compared with long-term customers.
SELECT
    tenure_group,
    COUNT(*) AS customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM customers
GROUP BY tenure_group
ORDER BY FIELD(
    tenure_group,
    '0-6 mo',
    '7-12 mo',
    '13-24 mo',
    '25-48 mo',
    '49-72 mo'
);

-- 10. TECH SUPPORT AND ONLINE SECURITY
-- Examine whether combinations of support and security
-- services are associated with customer churn.
SELECT
    TechSupport,
    OnlineSecurity,
    COUNT(*) AS customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM customers
GROUP BY TechSupport, OnlineSecurity
ORDER BY churn_rate_pct DESC;

-- 11. TENURE AND CONTRACT ANALYSIS
-- Identify combinations of customer tenure and contract
-- type that show higher churn.
SELECT
    tenure_group,
    Contract,
    COUNT(*) AS customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM customers
GROUP BY tenure_group, Contract
ORDER BY tenure_group, churn_rate_pct DESC;

-- 12. CHURNED VS RETAINED CUSTOMERS
-- Compare average tenure, monthly charges, and total charges
-- between customers who churned and those who remained.
SELECT
    Churn,
    COUNT(*) AS customers,
    ROUND(AVG(tenure), 1) AS avg_tenure_months,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charge,
    ROUND(AVG(TotalCharges), 2) AS avg_total_charges
FROM customers
GROUP BY Churn;

-- 13. BUSINESS SEGMENT ANALYSIS
-- Evaluate customer segments based on churn rate and
-- average monthly charges.

SELECT
    business_segment,
    COUNT(*) AS customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charge
FROM customers
GROUP BY business_segment
ORDER BY churn_rate_pct DESC;

-- 14. RISK AND CUSTOMER VALUE MATRIX
-- Identify which combinations of customer risk and value
-- should receive the highest retention priority.
SELECT
    risk_tier,
    value_tier,
    COUNT(*) AS customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charge
FROM customers
GROUP BY risk_tier, value_tier
ORDER BY
    FIELD(risk_tier, 'Critical', 'High', 'Medium', 'Low'),
    FIELD(value_tier, 'High Value', 'Medium Value', 'Low Value');
    
-- 15. HIGH-PRIORITY RETENTION TARGETS
-- Find currently active customers classified as Critical risk.
-- These customers may require immediate retention attention.
SELECT
    customerID,
    Contract,
    InternetService,
    tenure,
    MonthlyCharges,
    risk_score,
    risk_tier,
    value_tier,
    business_segment
FROM customers
WHERE Churn = 'No'
  AND risk_tier = 'Critical'
ORDER BY MonthlyCharges DESC
LIMIT 20;

-- 16. HISTORICAL REVENUE ASSOCIATED WITH CHURNED CUSTOMERS
-- Estimate the accumulated charges associated with customers
-- who have already churned.
SELECT
    COUNT(*) AS churned_customers,
    ROUND(SUM(TotalCharges), 2) AS lifetime_revenue_lost,
    ROUND(AVG(TotalCharges), 2) AS avg_lifetime_value_at_churn
FROM customers
WHERE Churn = 'Yes';

-- 17. REVENUE AT RISK BY BUSINESS SEGMENT
-- Estimate current monthly and annualized revenue exposure
-- among active High- and Critical-risk customers.
SELECT
    business_segment,
    COUNT(*) AS at_risk_customers,
    ROUND(SUM(MonthlyCharges), 2) AS monthly_revenue_at_risk,
    ROUND(SUM(MonthlyCharges) * 12, 2) AS annual_revenue_at_risk
FROM customers
WHERE Churn = 'No'
  AND risk_tier IN ('High', 'Critical')
GROUP BY business_segment
ORDER BY monthly_revenue_at_risk DESC;


-- 18. CRITICAL HIGH-VALUE CUSTOMERS
-- Identify the highest-priority segment based on both
-- customer risk and customer value.
SELECT
    COUNT(*) AS high_value_at_risk_customers,
    ROUND(SUM(MonthlyCharges), 2) AS monthly_revenue_at_risk,
    ROUND(SUM(MonthlyCharges) * 12, 2) AS annual_revenue_at_risk
FROM customers
WHERE Churn = 'No'
  AND business_segment = 'Critical - High Value at Risk';