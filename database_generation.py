# =========================================
# LOAN PORTFOLIO RISK ANALYSIS
# SYNTHETIC DATA GENERATION SCRIPT
# =========================================

import pandas as pd
import random
from faker import Faker
from datetime import datetime, timedelta

fake = Faker()

NUM_CUSTOMERS = 2000
NUM_BRANCHES = 20
NUM_LOANS = 10000
NUM_REPAYMENTS = 60000
NUM_DELINQUENCIES = 5000
NUM_APPLICATIONS = 15000

# =========================================
# MASTER DATA
# =========================================

loan_types = [
    "Home Loan",
    "Personal Loan",
    "Auto Loan",
    "Business Loan",
    "Education Loan"
]

employment_types = [
    "Salaried",
    "Self-Employed",
    "Business",
    "Freelancer"
]

loan_statuses = [
    "Active",
    "Closed",
    "Defaulted"
]

payment_statuses = [
    "Paid",
    "Late",
    "Missed"
]

approval_statuses = [
    "Approved",
    "Rejected"
]

rejection_reasons = [
    "Low Credit Score",
    "Low Income",
    "High Existing Debt",
    "Incomplete Documents",
    "Employment Instability"
]

delinquency_buckets = [
    "30 DPD",
    "60 DPD",
    "90+ DPD"
]

cities = [
    "Mumbai",
    "Delhi",
    "Bangalore",
    "Hyderabad",
    "Chennai",
    "Pune",
    "Kolkata",
    "Ahmedabad"
]

states = [
    "Maharashtra",
    "Delhi",
    "Karnataka",
    "Telangana",
    "Tamil Nadu",
    "West Bengal",
    "Gujarat"
]

regions = [
    "North",
    "South",
    "East",
    "West"
]

# =========================================
# 1. CUSTOMERS TABLE
# =========================================

customers = []

for customer_id in range(1, NUM_CUSTOMERS + 1):

    employment = random.choice(employment_types)

    if employment == "Salaried":
        income = random.randint(300000, 1500000)

    elif employment == "Business":
        income = random.randint(500000, 3000000)

    elif employment == "Self-Employed":
        income = random.randint(400000, 2000000)

    else:
        income = random.randint(250000, 1200000)

    customer = {
        "customer_id": customer_id,
        "first_name": fake.first_name(),
        "last_name": fake.last_name(),
        "gender": random.choice(["Male", "Female"]),
        "age": random.randint(21, 65),
        "city": random.choice(cities),
        "state": random.choice(states),
        "employment_type": employment,
        "annual_income": income,
        "credit_score": random.randint(300, 900),
        "join_date": fake.date_between(start_date='-5y', end_date='today')
    }

    customers.append(customer)

customers_df = pd.DataFrame(customers)

# =========================================
# 2. BRANCHES TABLE
# =========================================

branches = []

for branch_id in range(1, NUM_BRANCHES + 1):

    branch = {
        "branch_id": branch_id,
        "branch_name": f"Branch_{branch_id}",
        "city": random.choice(cities),
        "state": random.choice(states),
        "region": random.choice(regions)
    }

    branches.append(branch)

branches_df = pd.DataFrame(branches)

# =========================================
# 3. LOANS TABLE
# =========================================

loans = []

for loan_id in range(1, NUM_LOANS + 1):

    loan_amount = random.randint(50000, 5000000)

    loan = {
        "loan_id": loan_id,
        "customer_id": random.randint(1, NUM_CUSTOMERS),
        "branch_id": random.randint(1, NUM_BRANCHES),
        "loan_type": random.choice(loan_types),
        "loan_amount": loan_amount,
        "interest_rate": round(random.uniform(7.0, 18.0), 2),
        "tenure_months": random.choice([12, 24, 36, 60, 120, 240]),
        "disbursement_date": fake.date_between(start_date='-5y', end_date='today'),
        "loan_status": random.choice(loan_statuses),
        "collateral_value": round(loan_amount * random.uniform(0.5, 1.5), 2)
    }

    loans.append(loan)

loans_df = pd.DataFrame(loans)

# =========================================
# 4. REPAYMENTS TABLE
# =========================================

repayments = []

for repayment_id in range(1, NUM_REPAYMENTS + 1):

    emi_amount = random.randint(5000, 100000)

    status = random.choices(
        payment_statuses,
        weights=[70, 20, 10],
        k=1
    )[0]

    due_date = fake.date_between(start_date='-3y', end_date='today')

    if status == "Paid":
        payment_date = due_date

    elif status == "Late":
        payment_date = due_date + timedelta(days=random.randint(1, 30))

    else:
        payment_date = None

    repayment = {
        "repayment_id": repayment_id,
        "loan_id": random.randint(1, NUM_LOANS),
        "due_date": due_date,
        "payment_date": payment_date,
        "emi_amount": emi_amount,
        "amount_paid": emi_amount if status != "Missed" else 0,
        "payment_status": status
    }

    repayments.append(repayment)

repayments_df = pd.DataFrame(repayments)

# =========================================
# 5. DELINQUENCIES TABLE
# =========================================

delinquencies = []

for delinquency_id in range(1, NUM_DELINQUENCIES + 1):

    overdue_days = random.choice([30, 60, 90, 120])

    if overdue_days == 30:
        bucket = "30 DPD"

    elif overdue_days == 60:
        bucket = "60 DPD"

    else:
        bucket = "90+ DPD"

    delinquency = {
        "delinquency_id": delinquency_id,
        "loan_id": random.randint(1, NUM_LOANS),
        "overdue_days": overdue_days,
        "delinquency_bucket": bucket,
        "penalty_amount": random.randint(1000, 25000),
        "reported_date": fake.date_between(start_date='-2y', end_date='today')
    }

    delinquencies.append(delinquency)

delinquencies_df = pd.DataFrame(delinquencies)

# =========================================
# 6. LOAN APPLICATIONS TABLE
# =========================================

applications = []

for application_id in range(1, NUM_APPLICATIONS + 1):

    approval = random.choices(
        approval_statuses,
        weights=[75, 25],
        k=1
    )[0]

    if approval == "Approved":
        rejection_reason = None
    else:
        rejection_reason = random.choice(rejection_reasons)

    application = {
        "application_id": application_id,
        "customer_id": random.randint(1, NUM_CUSTOMERS),
        "application_date": fake.date_between(start_date='-5y', end_date='today'),
        "requested_amount": random.randint(50000, 3000000),
        "approval_status": approval,
        "rejection_reason": rejection_reason
    }

    applications.append(application)

applications_df = pd.DataFrame(applications)

# =========================================
# EXPORT CSV FILES
# =========================================

customers_df.to_csv("customers.csv", index=False)
branches_df.to_csv("branches.csv", index=False)
loans_df.to_csv("loans.csv", index=False)
repayments_df.to_csv("repayments.csv", index=False)
delinquencies_df.to_csv("delinquencies.csv", index=False)
applications_df.to_csv("loan_applications.csv", index=False)

# =========================================
# SUCCESS MESSAGE
# =========================================

print("===================================")
print("DATASETS GENERATED SUCCESSFULLY")
print("===================================")

print(f"Customers: {len(customers_df)}")
print(f"Branches: {len(branches_df)}")
print(f"Loans: {len(loans_df)}")
print(f"Repayments: {len(repayments_df)}")
print(f"Delinquencies: {len(delinquencies_df)}")
print(f"Applications: {len(applications_df)}")
