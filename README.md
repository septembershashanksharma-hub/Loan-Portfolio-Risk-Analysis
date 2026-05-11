# Loan Portfolio Risk Analysis

## Project Overview

This project simulates a real-world **loan risk analytics system** used by banks and financial institutions to monitor portfolio health, analyze repayment behavior, identify delinquent customers, and measure overall credit exposure.

The project was built using **SQL-focused data analysis techniques** with a relational database containing 10,000+ financial and risk records across multiple interconnected tables.

Using advanced SQL concepts such as:
- CTEs
- Window Functions
- Ranking
- Aggregations
- Rolling Metrics
- Risk Segmentation

the project identifies high-risk customer groups contributing significantly to portfolio exposure and delinquency trends.

---

# Business Problem

Financial institutions face major challenges in:
- detecting risky borrowers,
- tracking delinquent accounts,
- reducing loan defaults,
- and managing portfolio concentration risk.

This project aims to answer questions such as:
- Which customers contribute the highest risk exposure?
- Which loan categories have the highest delinquency rates?
- How are repayment trends changing over time?
- Which branches or regions carry elevated credit risk?
- What percentage of the portfolio is at risk?

---

# Objectives

- Design a normalized relational database for loan analytics
- Generate and manage large-scale financial datasets
- Perform advanced SQL-based risk analysis
- Analyze repayment and delinquency behavior
- Measure portfolio concentration and exposure
- Build business-ready KPIs for dashboards and reporting

---

# Tech Stack

| Tool | Purpose |
|---|---|
| SQL (PostgreSQL/MySQL) | Data Analysis |
| Python | Data Generation (Optional) |
| Power BI / Tableau | Dashboarding (Optional) |
| GitHub | Version Control |

---

# Database Schema

The project contains multiple interconnected tables:

| Table Name | Description |
|---|---|
| customers | Customer demographic and credit data |
| loans | Loan-level details |
| repayments | EMI and repayment tracking |
| delinquencies | Overdue and default tracking |
| branches | Regional branch information |
| loan_applications | Approved and rejected applications |

---

# Key Analytical Areas

## Credit Risk Analysis
- High-risk customer identification
- Credit score segmentation
- Exposure concentration analysis

## Delinquency Monitoring
- Days past due (DPD)
- Delinquency bucket trends
- Default analysis

## Repayment Analytics
- Collection efficiency
- Recovery rates
- Missed payment behavior

## Portfolio Monitoring
- Loan exposure by region
- Loan type performance
- Branch-wise risk concentration

---

# Advanced SQL Concepts Used

- Complex JOIN operations
- Common Table Expressions (CTEs)
- Window Functions
- DENSE_RANK(), ROW_NUMBER(), LAG()
- Rolling calculations
- Conditional aggregation
- Date-based trend analysis
- Cohort-style segmentation

---

# Example Business Insights

- Identified high-risk customer segments contributing nearly **30% of total portfolio exposure**
- Detected increasing delinquency trends in specific loan categories
- Analyzed repayment behavior across customer income groups
- Measured recovery efficiency across branches and loan products

---

# Project Structure

```text
loan-portfolio-risk-analysis/
│
├── datasets/
│
├── schema/
│   └── create_tables.sql
│
├── queries/
│   ├── beginner_queries.sql
│   ├── intermediate_queries.sql
│   └── advanced_queries.sql
│
├── notebooks/
│
├── dashboard/
│
├── README.md
```

---

# Sample KPIs

- Non-Performing Loan Ratio (NPL)
- Portfolio at Risk (PAR)
- Recovery Rate
- Average Days Past Due
- Delinquency Rate
- Approval vs Rejection Rate
- High-Risk Exposure Share

---

# Future Enhancements

- Predictive default modeling using Machine Learning
- Real-time anomaly detection
- Automated risk scoring system
- Interactive Power BI dashboards
- Time-series forecasting for delinquency trends

---

# Resume Impact

This project demonstrates:
- Strong SQL proficiency
- Financial analytics understanding
- Data modeling skills
- Risk analysis capability
- Business problem-solving approach

---

# Author

**Shashank Sharma**  
Aspiring Data Analyst | SQL | Python | Risk Analytics | Business Intelligence
