CREATE DATABASE loan_portfolio_risk_analysis;

USE loan_portfolio_risk_analysis;

-- =========================================
-- 1. CUSTOMERS TABLE
-- =========================================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    city VARCHAR(50),
    state VARCHAR(50),
    employment_type VARCHAR(50),
    annual_income DECIMAL(12,2),
    credit_score INT,
    join_date DATE
);

-- =========================================
-- 2. BRANCHES TABLE
-- =========================================

CREATE TABLE branches (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    region VARCHAR(50)
);

-- =========================================
-- 3. LOANS TABLE
-- =========================================

CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    branch_id INT,
    loan_type VARCHAR(50),
    loan_amount DECIMAL(12,2),
    interest_rate DECIMAL(5,2),
    tenure_months INT,
    disbursement_date DATE,
    loan_status VARCHAR(30),
    collateral_value DECIMAL(12,2),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id)
);

-- =========================================
-- 4. REPAYMENTS TABLE
-- =========================================

CREATE TABLE repayments (
    repayment_id INT PRIMARY KEY,
    loan_id INT,
    due_date DATE,
    payment_date DATE,
    emi_amount DECIMAL(10,2),
    amount_paid DECIMAL(10,2),
    payment_status VARCHAR(30),

    FOREIGN KEY (loan_id)
        REFERENCES loans(loan_id)
);

-- =========================================
-- 5. DELINQUENCIES TABLE
-- =========================================

CREATE TABLE delinquencies (
    delinquency_id INT PRIMARY KEY,
    loan_id INT,
    overdue_days INT,
    delinquency_bucket VARCHAR(20),
    penalty_amount DECIMAL(10,2),
    reported_date DATE,

    FOREIGN KEY (loan_id)
        REFERENCES loans(loan_id)
);

-- =========================================
-- 6. LOAN APPLICATIONS TABLE
-- =========================================

CREATE TABLE loan_applications (
    application_id INT PRIMARY KEY,
    customer_id INT,
    application_date DATE,
    requested_amount DECIMAL(12,2),
    approval_status VARCHAR(20),
    rejection_reason VARCHAR(100),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

-- =========================================
-- INDEXES FOR PERFORMANCE
-- =========================================

CREATE INDEX idx_customer_id
ON loans(customer_id);

CREATE INDEX idx_loan_id
ON repayments(loan_id);

CREATE INDEX idx_delinquency_loan
ON delinquencies(loan_id);

CREATE INDEX idx_application_customer
ON loan_applications(customer_id);

SELECT *
FROM loans;
SELECT *
FROM loan_applications;
SELECT *
FROM repayments;
SELECT *
FROM delinquencies;
SELECT *
FROM customers;
SELECT *
FROM branches;

SELECT COUNT(*) loans
FROM loans;
SELECT COUNT(*) loan_app
FROM loan_applications;
SELECT COUNT(*) repayment
FROM repayments;
SELECT COUNT(*) delinquencies
FROM delinquencies;
SELECT COUNT(*) customers
FROM customers;
SELECT COUNT(*) branches
FROM branches;


-- PHASE 1 — Portfolio Overview (Basic → Intermediate)
-- 1. Find the total loan exposure of the company.

SELECT SUM(loan_amount) AS Total_loan_exposure
FROM loans;

-- 2. Find total exposure by loan type.

SELECT loan_type AS Loan_Category, SUM(loan_amount) AS total_amount
FROM loans
GROUP BY loan_type;

-- 3. Calculate the average loan amount by loan type.

SELECT loan_type AS Loan_Category, AVG(loan_amount) AS average_amount
FROM loans
GROUP BY loan_type;

-- 4. Find the number of active, closed, and defaulted loans.

SELECT loan_status, COUNT(loan_id) AS count_
FROM loans
GROUP BY loan_status;

-- 5. Find top 10 branches with highest loan disbursement amount.

SELECT B.branch_name AS BranchName, SUM(L.loan_amount) AS total_amount
FROM loans L 
LEFT JOIN branches B ON L.branch_id = B.branch_id
GROUP BY B.branch_name 
ORDER BY SUM(L.loan_amount) DESC
LIMIT 10;

-- 6. Find total loan exposure region-wise.

SELECT B.region AS RegionName, SUM(L.loan_amount) AS total_amount
FROM loans L 
LEFT JOIN branches B ON L.branch_id = B.branch_id
GROUP BY B.region 
ORDER BY SUM(L.loan_amount) DESC;

-- 7. Calculate average interest rate by loan type.

SELECT loan_type, AVG(interest_rate) AS avg_interest_rate
FROM loans
GROUP BY loan_type;

-- 8. Find customers having more than 3 active loans.

SELECT C.customer_id, C.first_name, COUNT(L.loan_id) AS number_of_loans
FROM loans L 
LEFT JOIN customers C ON L.customer_id = C.customer_id
WHERE L.loan_status = 'Active'
GROUP BY C.customer_id, C.first_name 
HAVING COUNT(L.loan_id)>3
ORDER BY COUNT(L.loan_id) DESC;

-- PHASE 2 — Customer Risk Analysis
-- 9. Find top 20 customers with highest total loan exposure.

SELECT C.customer_id, C.first_name, SUM(L.loan_amount) AS total_loans
FROM loans L 
LEFT JOIN customers C ON L.customer_id = C.customer_id
GROUP BY C.customer_id, C.first_name 
ORDER BY SUM(L.loan_amount) DESC
LIMIT 20;

-- 10. Identify customers with credit score below 550.

SELECT customer_id, CONCAT(first_name," " ,last_name) AS full_name, credit_score
FROM customers
WHERE credit_score < 550;

-- 11. Find average credit score by employment type.

SELECT employment_type, AVG(credit_score) AS avg_credit_score
FROM customers 
GROUP BY employment_type
ORDER BY AVG(credit_score) DESC;

-- 12. Find customers whose total loan amount exceeds their annual income.

-- For this problem, I will include active and defaulted loans only

WITH tble AS
(SELECT C.customer_id, C.first_name, C.annual_income, 
	   SUM(CASE WHEN L.loan_status = 'Active' OR L.loan_status = 'Defaulted' THEN L.loan_amount END) AS total_loans
FROM loans L 
LEFT JOIN customers C ON L.customer_id = C.customer_id
GROUP BY C.customer_id, C.first_name, C.annual_income
)
SELECT * 
FROM tble
WHERE annual_income < total_loans;

-- 13. Calculate total exposure for low-credit-score customers (<600).

SELECT C.customer_id, C.credit_score, SUM(L.loan_amount) AS total_loan_exposure
FROM loans L 
LEFT JOIN customers C ON L.customer_id = C.customer_id
GROUP BY C.customer_id, C.credit_score
HAVING C.credit_score < 600
ORDER BY SUM(L.loan_amount) DESC;

-- 14. Find the percentage contribution of high-risk customers to total portfolio exposure.

-- We define high-risk customers as: credit score < 550 OR customers having at least one 90+ DPD delinquency

WITH tble AS 
(SELECT SUM(L.loan_amount) AS high_risk_loan_exposure
FROM loans L 
LEFT JOIN customers C ON L.customer_id = C.customer_id
LEFT JOIN delinquencies D ON L.loan_id = D.loan_id
WHERE D.delinquency_bucket = '90+ DPD' OR C.credit_score < 550
GROUP BY C.customer_id, C.first_name
)
SELECT SUM(high_risk_loan_exposure)/25088490969.00 * 100 AS Percentage_contribution
FROM tble;

-- 25088490969.00 from our first query

-- 15. Rank customers based on total loan exposure using window functions.

WITH tble AS
(SELECT C.customer_id, C.first_name, SUM(L.loan_amount) AS total_loans
FROM loans L 
LEFT JOIN customers C ON L.customer_id = C.customer_id
GROUP BY C.customer_id, C.first_name)

SELECT customer_id, total_loans, 
	   ROW_NUMBER()OVER(ORDER BY total_loans DESC) AS ranking
FROM tble;

-- PHASE 3 — Repayment Analysis
-- 16.Calculate overall repayment rate.



-- 17. Find percentage of missed payments.

SELECT COUNT(CASE WHEN payment_status = 'Missed' THEN 1 END)/COUNT(*) * 100 
       AS 
	   perctnge_missed_payments
FROM repayments;

-- 18. Find top 10 loans with highest missed EMI count.

SELECT loan_id , COUNT(loan_id) AS missed_EMIs
FROM repayments
WHERE payment_status = 'Missed'
GROUP BY loan_id
ORDER BY COUNT(loan_id) DESC
LIMIT 10;

-- 19. Calculate average delay days for late payments.

WITH late_days AS
(
SELECT TIMESTAMPDIFF(DAY, due_date, payment_date) AS daydiff
FROM repayments
WHERE payment_status = 'Late'
)
SELECT AVG(daydiff) AS avg_delay_days
FROM late_days;

-- 20. Find repayment performance by loan type.

WITH status_count AS
(SELECT loan_id, COUNT(CASE WHEN payment_status = 'Paid' THEN 1 END) AS paid_count, 
       COUNT(CASE WHEN payment_status = 'Late' THEN 1 END) AS late_count, 
	   COUNT(CASE WHEN payment_status = 'Missed' THEN 1 END) AS missed_count
FROM repayments
GROUP BY loan_id
)
SELECT L.loan_type, SUM(S.paid_count) AS PaidOnTime, SUM(S.late_count) AS PaidLate, SUM(S.missed_count) AS MissedCount
FROM status_count S
LEFT JOIN loans L ON S.loan_id = L.loan_id
GROUP BY L.loan_type;

-- 21. Calculate collection efficiency branch-wise.

SELECT B.branch_name, SUM(R.amount_paid)/SUM(R.emi_amount)* 100 AS Collection_efficiency
FROM loans L
LEFT JOIN branches B ON L.branch_id = B.branch_id
JOIN repayments R ON L.loan_id = R.loan_id 
GROUP BY B.branch_name;

-- 22. Find customers who missed payments consecutively.

WITH repayment_history AS (

    SELECT
        C.customer_id,
        C.first_name,
        C.last_name,
        R.due_date,
        R.payment_status,
        LAG(R.payment_status)OVER(PARTITION BY C.customer_id ORDER BY R.due_date) AS previous_status
    FROM customers C
    INNER JOIN loans L
        ON C.customer_id = L.customer_id

    INNER JOIN repayments R
        ON R.loan_id = L.loan_id
)
SELECT *
FROM repayment_history
WHERE payment_status = 'Missed'
  AND previous_status = 'Missed';



