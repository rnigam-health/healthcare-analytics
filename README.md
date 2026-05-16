\# Pharma Sales Force Effectiveness \& IC Analytics



\*\*End-to-end pharma commercial analytics project\*\* — relational data modeling in SQL, 10 analytical queries, and a 4-page Power BI dashboard covering Sales Force Effectiveness (SFE), Incentive Compensation (IC), and Rx performance reporting.

\---



\## Overview



Pharma commercial teams rely on integrated data across field activity, prescriptions, and incentive structures to drive territory strategy and rep performance. This project replicates that analytical workflow end-to-end:



\- \*\*SQL layer:\*\* 6-table relational schema modelling a pharma commercial environment; 10 queries answering real SFE and IC business questions using JOINs, GROUP BY, aggregations, window functions (LAG, RANK), CTEs, and CASE WHEN logic

\- \*\*Power BI layer:\*\* 4-page interactive dashboard with DAX measures for Attainment %, Rx per Call, Revenue, and HCP Coverage % — built on top of the same data model



\---



\## Dataset



Synthetic but structurally realistic pharma commercial data generated in Python:



| Table | Records | Description |

|---|---|---|

| `sales\\\_reps.csv` | 50 | Field reps — territory, region, manager, tenure |

| `hcps.csv` | 500 | Doctors — specialty, A/B/C segment, city |

| `products.csv` | 5 | Brand portfolio across 5 therapy areas |

| `call\\\_activity.csv` | \~13,700 | Rep–HCP visits over 12 months (call type, duration, samples) |

| `prescriptions.csv` | \~17,300 | Monthly Rx records by HCP and product |

| `ic\\\_quotas.csv` | 200 | Quarterly quota, actual units, attainment %, IC payout |



\*\*Data model:\*\* Star schema — `call\\\_activity` and `prescriptions` as fact tables; `sales\\\_reps`, `hcps`, `products` as dimensions.



\---



\## SQL Analysis



10 analytical queries answering real pharma commercial business questions — using JOINs, GROUP BY, aggregations, window functions (LAG, RANK), CTEs, and CASE WHEN logic. See \[`queries\\\_sqlite.sql`](queries\_sqlite.sql).



\*\*Business questions covered:\*\*

\- Which reps have the highest IC attainment this quarter?

\- Which reps convert calls to Rx most efficiently?

\- Are Segment A (high-value) HCPs being adequately covered?

\- Which products are driving revenue? What is the MoM growth trend?

\- Which territories are over- or under-resourced relative to Rx output?

\- How is IC attainment trending quarter-over-quarter?

\- Which managers are delivering the best team performance?



\---



\## Power BI Dashboard



4-page interactive dashboard built on the same data model.



\### Page 1 — Executive Summary

Total Rx by Product · HCP Segment Distribution · Call Volume by Territory · Total Rx KPI (43K) · Top Reps by IC Attainment %



\### Page 2 — Sales Force Performance

Top Reps by Call Volume · Territory-wise Rx Output · Rep-wise Average Attainment %



\### Page 3 — HCP Targeting

Rx by Segment (A/B/C) · Rx by Specialty · HCP Distribution by City



\### Page 4 — IC Analytics

Quarterly Attainment Trend · Manager-wise Attainment · Total IC Payout KPI (₹14M)



\---



\## Key Findings



| Finding | Implication |

|---|---|

| Diabolite (Diabetes) — highest Rx volume | Priority brand for field detailing focus |

| South-2 — highest call volume and Rx output | Best-practice territory; model for replication |

| Segment B is largest HCP group (46%) | Segment A coverage gap — strategic priority |

| Attainment declining Q2 2025 → Q1 2026 | Quota difficulty increasing; needs investigation |

| Sneha Patel's team — consistently highest attainment | Best-practice manager; coaching opportunity |



\---



\## Repository Structure



```

healthcare-analytics/

├── call\\\_activity.csv

├── hcps.csv

├── ic\\\_quotas.csv

├── prescriptions.csv

├── products.csv

├── sales\\\_reps.csv

├── queries\\\_sqlite.sql

└── README.md

```



\---



\## Setup



\### SQL (SQLite)

1\. Download \[DB Browser for SQLite](https://sqlitebrowser.org/dl/)

2\. Create new database → import all 6 CSVs

3\. Open `queries\\\_sqlite.sql` → Execute SQL tab → run queries



\### Power BI

1\. Download \[Power BI Desktop](https://powerbi.microsoft.com/desktop/) (free)

2\. Get Data → Text/CSV → import all 6 CSVs

3\. Set relationships in Model View:



```

sales\\\_reps.rep\\\_id     →  call\\\_activity.rep\\\_id

sales\\\_reps.rep\\\_id     →  ic\\\_quotas.rep\\\_id

hcps.hcp\\\_id           →  call\\\_activity.hcp\\\_id

hcps.hcp\\\_id           →  prescriptions.hcp\\\_id

products.product\\\_id   →  call\\\_activity.product\\\_id

products.product\\\_id   →  prescriptions.product\\\_id

```



\---



\## About



\*\*Rupal N\*\* — MBA Hospital \& Healthcare Management (SIHS Pune, 2026) · MSc Microbiology (Central University of Rajasthan)



Seeking Analyst roles in pharma commercialization, SFE consulting, and healthcare analytics.



\[LinkedIn](#) · \[Portfolio](#)

