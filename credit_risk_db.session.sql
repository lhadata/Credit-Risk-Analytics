CREATE DATABASE credit_risk_db;
-- 1. Tổng quan: tỷ lệ default chung
-- ============================================
SELECT 
    COUNT(*) AS total_loans,
    SUM(loan_status) AS total_default,
    ROUND(AVG(loan_status)::numeric, 4) AS default_rate
FROM loans;
-- ============================================
-- 2. Nhóm vay nào có default rate cao? (theo loan_grade)
-- ============================================
SELECT 
    loan_grade,
    COUNT(*) AS num_loans,
    ROUND(AVG(loan_status)::numeric, 4) AS default_rate
FROM loans
GROUP BY loan_grade
ORDER BY default_rate DESC;
-- ============================================
-- 3. Mục đích vay nào rủi ro cao? (loan_intent)
-- ============================================
SELECT 
    loan_intent,
    COUNT(*) AS num_loans,
    ROUND(AVG(loan_status)::numeric, 4) AS default_rate,
    ROUND(AVG(loan_amnt)::numeric, 0) AS avg_loan_amount
FROM loans
GROUP BY loan_intent
ORDER BY default_rate DESC;
-- ============================================
-- 4. loan_percent_income ảnh hưởng đến default? (binning)
-- ============================================
SELECT 
    CASE 
        WHEN loan_percent_income < 0.1 THEN '0-10%'
        WHEN loan_percent_income < 0.2 THEN '10-20%'
        WHEN loan_percent_income < 0.3 THEN '20-30%'
        WHEN loan_percent_income < 0.4 THEN '30-40%'
        ELSE '40%+'
    END AS income_pct_bucket,
    COUNT(*) AS num_loans,
    ROUND(AVG(loan_status)::numeric, 4) AS default_rate
FROM loans
GROUP BY income_pct_bucket
ORDER BY income_pct_bucket;
-- ============================================
-- 5. debt_to_income_ratio ảnh hưởng đến default?
-- ============================================
SELECT 
    CASE 
        WHEN debt_to_income_ratio < 0.2 THEN 'Low (<20%)'
        WHEN debt_to_income_ratio < 0.4 THEN 'Medium (20-40%)'
        ELSE 'High (>40%)'
    END AS dti_bucket,
    COUNT(*) AS num_loans,
    ROUND(AVG(loan_status)::numeric, 4) AS default_rate
FROM loans
GROUP BY dti_bucket
ORDER BY default_rate DESC;
-- ============================================
-- 6. Employment type & home ownership có khác biệt?
-- ============================================
SELECT 
    employment_type,
    person_home_ownership,
    COUNT(*) AS num_loans,
    ROUND(AVG(loan_status)::numeric, 4) AS default_rate
FROM loans
GROUP BY employment_type, person_home_ownership
ORDER BY default_rate DESC;-- ============================================
-- 7. Lịch sử nợ quá hạn ảnh hưởng thế nào?
-- ============================================
SELECT 
    cb_person_default_on_file,
    past_delinquencies,
    COUNT(*) AS num_loans,
    ROUND(AVG(loan_status)::numeric, 4) AS default_rate
FROM loans
GROUP BY cb_person_default_on_file, past_delinquencies
ORDER BY past_delinquencies;
-- ============================================
-- 8. Khác biệt giữa US/UK/Canada?
-- ============================================
SELECT 
    country,
    COUNT(*) AS num_loans,
    ROUND(AVG(loan_status)::numeric, 4) AS default_rate,
    ROUND(AVG(loan_int_rate)::numeric, 2) AS avg_interest_rate,
    ROUND(AVG(loan_amnt)::numeric, 0) AS avg_loan_amount
FROM loans
GROUP BY country
ORDER BY default_rate DESC;
-- ============================================
-- 9. Phân nhóm "an toàn" vs "rủi ro" dựa trên rule đơn giản
-- (vd: kết hợp loan_grade + dti + past_delinquencies)
-- ============================================
SELECT 
    CASE 
        WHEN loan_grade IN ('A','B') AND past_delinquencies = 0 THEN 'Low Risk'
        WHEN loan_grade IN ('F','G') OR past_delinquencies >= 2 THEN 'High Risk'
        ELSE 'Medium Risk'
    END AS risk_segment,
    COUNT(*) AS num_loans,
    ROUND(AVG(loan_status)::numeric, 4) AS default_rate
FROM loans
GROUP BY risk_segment
ORDER BY default_rate DESC;