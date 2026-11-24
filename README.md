# Data Quality Checker

Automated data quality checks for a relational PostgreSQL database, written in Python.
The project loads the public [Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
(9 related tables) into PostgreSQL, runs 25 SQL checks against it and produces a report
with the number of failing rows and examples for every check.

## What it does

1. **Loads** the CSV files into PostgreSQL as raw tables without constraints, so that
   problems in the data are not rejected by the database but can be detected by the checks.
2. **Checks** the data with SQL queries of five kinds:
   - orphaned references (a foreign key points to a record that does not exist),
   - missing values,
   - duplicates,
   - outliers and implausible values,
   - invalid formats and inconsistent dates.
3. **Reports** the result: a console summary and a Markdown report with the status of each
   check, the number of failing rows and sample rows.

## Project structure

```
data-quality-checker/
├── sql/
│   ├── schema.sql        # raw tables (no keys or constraints)
│   └── checks.sql        # all data quality checks
├── src/
│   ├── load_data.py      # loads CSV files into the database
│   ├── run_checks.py     # runs the checks and writes the report
│   └── check_connection.py
├── reports/
│   └── dq_report.md      # example report from a real run
├── .env.example          # database connection settings (template)
└── requirements.txt
```

## Requirements

- Python 3.12
- PostgreSQL 16 (developed and tested on Ubuntu under WSL)
- The Olist dataset (CSV files) from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

## Setup

```bash
git clone https://github.com/julia-zakharuk/data-quality-checker.git
cd data-quality-checker
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Download the dataset and put the 9 CSV files into the `data/` folder.

Create the database and a dedicated user:

```bash
sudo -u postgres psql -c "CREATE USER dq_user WITH PASSWORD 'change_me';"
sudo -u postgres psql -c "CREATE DATABASE olist_dq OWNER dq_user;"
```

Create the connection settings and put your password into `.env`:

```bash
cp .env.example .env
```

Create the tables and load the data:

```bash
psql -h localhost -U dq_user -d olist_dq -f sql/schema.sql
python src/load_data.py
```

## Run the checks

```bash
python src/run_checks.py
```

The console shows the status of every check, and the full report is written to
`reports/dq_report.md`. Use `--strict` to exit with code 1 if any check fails
(useful in automation):

```bash
python src/run_checks.py --strict
```

## How checks are defined

Every check is a block in `sql/checks.sql`: a header line and a `SELECT` that returns
the rows that **fail** the check. A check passes when the query returns no rows.

```sql
-- check: orders_orphan_customer | orphan | Orders whose customer_id is not in customers
SELECT o.order_id, o.customer_id
FROM orders o
LEFT JOIN customers c ON c.customer_id = o.customer_id
WHERE o.customer_id IS NOT NULL AND c.customer_id IS NULL;
```

To add a check, append a new block to the file. No Python changes are needed.

## Example results

Run on the Olist dataset: 25 checks, 13 passed, 12 failed. The full report with sample
rows is in [`reports/dq_report.md`](reports/dq_report.md).

| Check | Type | Failed rows |
|---|---|---:|
| `products_orphan_category` | orphan | 2 |
| `orders_delivered_without_delivery_date` | missing | 8 |
| `orders_delivered_without_approval` | missing | 14 |
| `products_missing_category` | missing | 610 |
| `order_reviews_duplicate_review_id` | duplicate | 789 |
| `geolocation_duplicate_rows` | duplicate | 128,174 |
| `orders_slow_delivery` | outlier | 306 |
| `order_payments_nonpositive_value` | outlier | 9 |
| `products_nonpositive_dimensions` | outlier | 4 |
| `geolocation_outside_brazil` | outlier | 42 |
| `sellers_invalid_city` | format | 24 |
| `orders_inconsistent_dates` | consistency | 189 |

All referential checks between the main tables (orders, customers, order items, payments,
reviews, products, sellers) passed: the dataset has no orphaned references there.

Notes on how to read the numbers:

- For duplicate checks the count is the number of duplicated values (groups), not the
  number of extra rows. `products_orphan_category` counts distinct categories.
- Thresholds are assumptions for this dataset: delivery longer than 60 days and
  coordinates outside a rough bounding box of Brazil.
- A failed check shows a data quality issue worth looking at, not necessarily an error
  in the source system. For example, the many repeated rows in the geolocation table
  are expected for a table that is not keyed.

## Limitations

- The checks are written for the Olist schema; other datasets need their own `checks.sql`.
- Tables are loaded as a raw layer without keys and constraints on purpose.
- The project runs locally. There is no scheduling or orchestration.

## Data

The Olist dataset is published by Olist on Kaggle. See the dataset page for its license
and terms of use. The data files are not included in this repository.
