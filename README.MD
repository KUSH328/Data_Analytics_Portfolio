# DataCo Supply Chain Analytics

**Portfolio author: Kuria Wairore**

This portfolio project brings together exploratory data analysis, SQL business
queries, visual storytelling, a delivery-risk modeling exercise, and an
interactive Power BI report. The goal is to demonstrate an end-to-end analytics
workflow and to make the reasoning behind its findings easy to review.

The repository contains two distinct evidence bases: a 999-row workbook used by
the current Python notebook and a separate, broader-data Power BI report. Their
counts and metrics are not interchangeable. This README describes the files
currently in the repository and keeps sample findings clearly labeled.

## What this project explores

- How sales, order profit, delivery status, and the risk label vary across
  markets, product categories, shipping modes, and time.
- Which order-time attributes are associated with the notebook's
  `Late_delivery_risk` label.
- How a chronological model holdout compares with a simple prior-only baseline.
- How to present analysis for both technical and business audiences.

## Project files

| Path | Purpose |
| --- | --- |
| `01_Dataset/Supply_Chain.xlsx` | Workbook used by the notebook. The current file contains 999 order-item rows. |
| `02_Dataset_Cleaned/Supply_Chain_Cleaned.xlsx` | Cleaned workbook included with the project. |
| `03_Python/DataCo_Supply_Chain_Analysis.ipynb` | Data checks, descriptive analysis, visualizations, and late-risk modeling. |
| `04_Visualizations/` | PNG figures exported by the notebook. |
| `05_SQL/dataco_supply_chain_Analysis.sql` | MySQL queries for KPIs, service, market/category economics, customers, and monthly trends. |
| `06_PowerBI/PowerBi.pbix` | Interactive Power BI report. |
| `08_PowerBI Dashboards/` | Current screenshot exports of the three Power BI pages. |
| `09_Report/DataCo_Global_Supply_Chain_Project_Report.pdf` | Written report with notebook findings and the updated Power BI screenshots. |

## Data and scope

The notebook workbook has **999 order-item rows**, **890 distinct order IDs**,
and **53 columns**. Its order dates run from **January 4, 2015 through
December 1, 2018**. It is an analysis extract, not the complete
180,519-row source dataset.

The notebook reports **USD 243,231.56 in sales**, **USD 26,589.09 in summed
order profit**, and a **50.05% `Late_delivery_risk` label rate** for this
extract. There are no exact duplicate rows. `Product Description` is entirely
missing in the workbook, and `Order Zipcode` is missing in 966 of 999 rows.
These facts describe the local workbook only.

The Power BI screenshots show a separate report view with approximately
**USD 36.78M sales**, **USD 3.97M profit**, **66K orders**, and **54.83% late
delivery**. These dashboard values must not be compared directly with the
notebook figures until the data population, filters, order grain, and metric
definitions have been aligned. In particular, the notebook's
`Late_delivery_risk` target and the dashboard's Late Delivery measure should
not be assumed to have identical definitions.

## Python notebook

Open [the analysis notebook](./03_Python/DataCo_Supply_Chain_Analysis.ipynb)
in VS Code or Jupyter and run its cells from top to bottom. The notebook looks
for `Dataco_Supply_Chain.xlsx` and `Supply_Chain.xlsx` in the project and parent
directories; the workbook currently used is
`01_Dataset/Supply_Chain.xlsx`. It prints the resolved input path and row count.

The notebook:

1. Profiles data types, missing values, distinct values, and exact duplicate
   rows before transforming data.
2. Parses dates and numeric measures in a separate analysis copy.
3. Summarizes sales, order profit, and the binary risk label at the order-item
   grain, while reporting distinct order counts separately.
4. Produces inline charts and saves 300-DPI PNGs to `04_Visualizations/`.
5. Trains and evaluates a logistic-regression model with a group-aware
   chronological split by `Order Id`.

The saved figures cover delivery-status volume, risk rates by shipping mode,
sales distribution, profit by market and category, monthly business trends,
the holdout confusion matrix and ROC curve, and logistic-regression
coefficients.

### Selected notebook findings

| Shipping mode | Order-item rows | Distinct orders | Risk-label rate |
| --- | ---: | ---: | ---: |
| First Class | 25 | 25 | 100.0% |
| Second Class | 300 | 246 | 82.7% |
| Same Day | 16 | 16 | 56.25% |
| Standard Class | 658 | 603 | 33.1% |

These are descriptive rates from a small extract. They do not show that the
shipping mode caused a particular delivery outcome. For example, First Class
has only 25 rows, so its 100% label rate needs validation against a much larger
population before it informs a service decision.

Europe has the largest summed profit in this extract: **USD 14,464.58 across
342 rows**. Monthly coverage is sparse in parts of 2018. Resampling creates
empty months in the time-series chart, so flat zero periods there mean no
sample records were observed in those months; they do not establish that the
business had zero activity.

**Chart-label note:** the notebook's category-profit plotting code selects the
15 largest category profit totals, although the saved chart title says
"lowest 15." The PDF report uses a title that matches the selection performed
by the code.

### Late-risk model

The model uses 17 order-time features and excludes fields that could reveal the
outcome, including actual shipping duration, shipping date, delivery/order
status, identifiers, and realized-profit fields. Whole order IDs stay together
in the chronological split. The notebook used 821 training rows from 712
orders and 178 later holdout rows from 178 orders, with a cutoff on
October 17, 2017.

| Holdout metric | Prior-only baseline | Logistic regression |
| --- | ---: | ---: |
| Accuracy | 0.433 | 0.730 |
| Precision | 0.000 | 0.812 |
| Recall | 0.000 | 0.683 |
| F1 | 0.000 | 0.742 |
| ROC-AUC | 0.500 | 0.744 |
| Average precision | 0.567 | 0.773 |

Precision, recall, and F1 use the notebook's default 0.50 probability
threshold. These are exploratory results on one small holdout, not a production
performance claim. Before using a score operationally, evaluate multiple
future windows, check probability calibration, select a threshold against
intervention capacity and the cost of missed delays, and monitor for drift.
Model coefficients show associations in this sample; they are not causal
effects.

## SQL analysis

The companion script
[dataco_supply_chain_Analysis.sql](./05_SQL/dataco_supply_chain_Analysis.sql)
targets MySQL 8 or later. It creates and selects the `dataco_supply_chain`
database, then queries a table named `datacosupplychain_clean_sql`. Import the
workbook into MySQL under that table name before running the analysis.

The queries calculate executive totals and the risk-label rate, compare
shipping modes, summarize market economics, select categories with negative
average profit per item row, rank the top ten customers by sales, and group
results by month.
Because the source is at order-item grain, use `COUNT(DISTINCT \`Order Id\`)`
when the desired measure is distinct orders rather than item rows.

## Power BI report

Open [PowerBi.pbix](./06_PowerBI/PowerBi.pbix) in Power BI Desktop to use its
filters and drill-down interactions. The report has three pages:

1. **Executive Overview** - Year, Market, and Customer Segment filters; KPI
   cards; market sales, sales/profit trend, shipping-mode risk, category
   profit, customer segments, and delivery status.
2. **Shipping Performance** - Year, Market, and Shipping Mode filters;
   order and delay KPIs; comparisons across markets, modes, and categories;
   and a date trend.
3. **Root Cause Drill-Down** - market and shipping-mode comparisons, a
   decomposition tree, a matrix, and a geographic visual for investigation.

The static screenshots below reflect the current dashboard files. The
Shipping Performance page displays a 100% date-card value and a dense time
trend; the Root Cause page's map is crowded and appears tiled. Verify the
underlying DAX measures, date context, location settings, and filters in Power
BI before treating these visuals as operational evidence.

### Executive Overview

![Executive Overview dashboard](./08_PowerBI%20Dashboards/Executive_Overview.png)

### Shipping Performance

![Shipping Performance dashboard](./08_PowerBI%20Dashboards/Shipping_Performance.png)

### Root Cause Drill-Down

![Root Cause Drill-Down dashboard](./08_PowerBI%20Dashboards/Root_Cause_Drill_Down.png)

## Written report

The [project report](./09_Report/DataCo_Global_Supply_Chain_Project_Report.pdf)
has been updated to use the current notebook results, include its analytical
visualizations, and show the latest Power BI screenshots. The report preserves
the distinction between the notebook sample and the separate Power BI
population.

## Reproducibility

Create a Python environment and install the notebook dependencies:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install pandas numpy matplotlib seaborn scikit-learn openpyxl
```

Then open `03_Python/DataCo_Supply_Chain_Analysis.ipynb` in VS Code or Jupyter.
If running it outside the repository, place the workbook in `01_Dataset/` or
adjust the notebook's input search path. The notebook writes figure exports to
`04_Visualizations/`.

## Limitations and responsible interpretation

- The notebook's 999 rows are not a representative sample of the full
  population; subgroup rates may be unstable.
- `Late_delivery_risk` is the model target. It is distinct from the separate
  `Delivery Status` field, and neither should be substituted for the Power BI
  measure without checking its definition.
- The notebook's monthly view has gaps, especially during 2018.
- Small category and shipping-mode groups need counts and context alongside
  percentages.
- Predictive scores and coefficients do not establish causation or readiness
  for deployment.
- The Power BI totals come from a different report view; align source,
  filters, grain, and DAX before reconciling numbers.

## Skills demonstrated

Data profiling and preparation; exploratory data analysis; Python and pandas;
Matplotlib and Seaborn visualizations; scikit-learn modeling and evaluation;
MySQL aggregation; Power BI report design; KPI interpretation; and
communication of limitations to business audiences.

Additional skills: Tableau, R, and RapidMiner.

## Credits and attribution

**Author and portfolio owner: Kuria Wairore.**

**Acknowledgment:** Thawfeeqa, a fellow data analyst in India, is credited for
her contribution to earlier project materials. This README has been written
for Kuria Wairore's portfolio edition, with prior contributions and data
sources acknowledged rather than presented as uncredited work.

The DataCo supply-chain dataset is distributed on
[Kaggle by Shashwat Tiwari](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis).
The Kaggle listing acknowledges original contributors Fabian Constante,
Fernando Silva, and António Pereira and links to
[Mendeley Data, version 5](https://data.mendeley.com/datasets/8gx2fvg2k6/5)
(DOI: [10.17632/8gx2fvg2k6.5](https://doi.org/10.17632/8gx2fvg2k6.5)).
The Kaggle page lists the dataset under CC0 1.0; consult the source listing for
the license and attribution details.
