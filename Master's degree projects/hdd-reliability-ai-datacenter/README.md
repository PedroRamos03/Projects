# HDD Reliability Analysis & Maintenance Policy for an AI Datacenter

Reliability and maintenance-policy study for hard-disk drives in a large-scale AI datacenter.  
The goal was to select the best supplier and the most cost-effective maintenance strategy for 2,000 drives over a 3-year horizon.

**Course:** Engineering and Management of Industrial Maintenance  
**Institution:** Faculty of Engineering, University of Porto (FEUP)

---

## Business Problem

A company is building a new AI training/inference datacenter and must choose among three HDD suppliers:

| Supplier | Model          | Unit Price | Lead Time |
|----------|----------------|------------|-----------|
| Alpha    | WDC-12TB       | €245       | 21 days   |
| Beta     | ST-12TB        | €265       | 28 days   |
| Gamma    | Hitachi-12TB   | €225       | 14 days   |

The decision must minimise total cost of ownership while keeping acceptable reliability.  
Two maintenance policies were compared: **corrective** (run-to-failure) and **preventive** (age-based replacement).

---

## Data

- Source: historical SMART failure records (`hard_drive_failure_data.csv`)
- 2,987 failure events (only failed drives are present → conservative analysis)
- After removing 3 duplicate serial numbers → 2,984 unique failures
- Grouped by supplier:
  - Alpha (WDC): 151 failures
  - Beta (ST*): 2,499 failures
  - Gamma (Hitachi/HGST): 318 failures

For the Laplace test, accumulated failure times were calculated from a common time origin of **31 December 2015** (chosen in the MATLAB script so that all times are positive and consistent). The actual failure dates in the dataset fall mainly between 2016 and 2017.

**Important limitation:** The provided dataset contains only failure records (no censored/surviving drives). Therefore the estimated MTBF values are lower (worst-case) than reality.

---

## Methods

1. **Data cleaning** (MATLAB)
   - Remove duplicate serial numbers
   - Calculate accumulated failure times from a common time origin (31 Dec 2015)
   - Prepare lifetime data for Weibull fitting

2. **Trend analysis** – Laplace test (Excel)
   - Determine whether the failure rate is increasing, decreasing or constant

3. **Parametric modelling** – 2-parameter Weibull (Python + MLE)
   - Shape (β) and scale (η) parameters estimated with `scipy.stats.weibull_min`

4. **Cost modelling**
   - Unit costs taken directly from the problem data:

   | Supplier | Preventive cost (Cp) | Corrective cost (Cf) |
   |----------|----------------------|----------------------|
   | Alpha    | €840                 | €3,645               |
   | Beta     | €860                 | €3,665               |
   | Gamma    | €820                 | €3,625               |

   - Optimal preventive interval (Tp) is only calculated when the Weibull shape parameter β > 1 (wear-out regime).  
     When β <= 1 the failure rate is constant or decreasing, so age-based preventive replacement is not economically justified and only corrective maintenance is considered.
   - When β > 1, Tp is found by minimising the long-run cost per unit time using Simpson integration + Excel GRG solver.

---

## Key Results

### Laplace Test
| Supplier     | ET     | Trend      | Interpretation              |
|--------------|--------|------------|-----------------------------|
| Alpha (WDC)  | –8.61  | Decreasing | Reliability improving        |
| Beta (ST)    | +5.59  | Increasing | Wear-out (degradation)      |
| Gamma        | –3.43  | Decreasing | Reliability improving        |

### Weibull Parameters (MLE)
| Supplier     | β (shape) | η (scale) [days] | Approx. MTBF [days] |
|--------------|-----------|------------------|---------------------|
| Alpha (WDC)  | 1.23      | 219.7            | 205                 |
| Beta (ST)    | 1.33      | 352.5            | 324                 |
| Gamma        | 0.96      | 206.9            | 211                 |

- β > 1 → wear-out → preventive maintenance can be beneficial  
- β ≈ 1 → random failures → corrective maintenance is preferred
- β < 1 → infant mortality → corrective maintenance is preferred  

Only suppliers with β > 1 (Alpha and Beta) were candidates for an optimal preventive interval (Tp). Gamma (β ≈  0.96 ) was evaluated under corrective maintenance only.

### Cost Comparison (3 years, 2,000 drives)

| Supplier     | Best Policy                    | Total Cost of Ownership |
|--------------|--------------------------------|-------------------------|
| **Beta (ST)**| **Preventive (Tp ≈ 394 days)** | **≈ €24.6 M**           |
| Gamma        | Corrective                     | ≈ €38.1 M               |
| Alpha        | Corrective                     | ≈ €39.4 M               |

Beta + systematic preventive replacement every ≈ 13 months is clearly the lowest-cost option (≈ 35 % cheaper than the next best alternative).

---

## Recommendation

**Select supplier Beta (ST) and apply age-based preventive replacement every 394 days.**

Reasons:
- Lowest total cost of ownership
- Predictable wear-out behaviour allows planned maintenance windows (much cheaper than unplanned downtime)
- The higher purchase price is more than compensated by the reduction in corrective interventions

---

## Repository Structure

```text
data/
  hard_drive_failure_data.csv          # Original failure records

matlab/
  detect_duplicates.m                  # Finds duplicate serial numbers
  process_failure_times.m              # Cleans data and computes accumulated times
  prepare_weibull_data.m               # Prepares lifetime + censoring flags

python/
  weibull_mle_analysis.ipynb           # Weibull MLE fitting and diagnostics

excel/
  failure_times_for_laplace.xlsx       # Clean failure times used for Laplace test
  laplace_test_wdc.xlsx                # Laplace test calculation (WDC example)
  optimal_preventive_cost_wdc.xlsm     # Cost minimisation (Simpson + GRG solver)
```

---

## How to Reproduce

1. Place `hard_drive_failure_data.csv` in the `data/` folder.
2. Run the MATLAB scripts in order (they generate the Excel files used later).  
   Note: `process_failure_times.m` has been updated to write `failure_times_for_laplace.xlsx`.
3. Open the Python notebook to obtain the Weibull parameters.
4. The Excel files contain the Laplace tests and the cost-optimisation model.

---

## Notes

- All monetary values and cost structures come directly from the original problem statement.
- The analysis is intentionally conservative because only failed drives were available.
- The project demonstrates a complete reliability → maintenance-policy → cost-optimisation workflow typical in industrial maintenance engineering.
