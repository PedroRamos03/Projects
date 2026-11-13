# Datacenter Hard Drive Reliability & TCO Optimization

Reliability engineering and maintenance strategy optimization for a 10,000 unit enterprise datacenter storage fleet, evaluating three OEM suppliers (**Alpha / WDC**, **Beta / Seagate**, and **Gamma / Hitachi-HGST**) over a 3-year operational horizon.

## Objectives
1. Model time-to-failure distributions for each supplier using Maximum Likelihood Estimation (MLE).
2. Verify failure rate stationarity and trend behavior across operational time.
3. Determine the optimal supplier selection and preventive vs. corrective maintenance policy to minimize 3-year Total Cost of Ownership (TCO) while maintaining fleet availability above 99%.

## Methodology
* **Data Sanitization:** Handled left-censored / zero-day failure logs (`lifetime <= 0`) via half-interval midpoint imputation (`0.5 days`) to prevent log-likelihood singularities.
* **Weibull Parameter Estimation (MLE):** Fitted 2-parameter Weibull distributions ($f(t) = \frac{\beta}{\eta}\left(\frac{t}{\eta}\right)^{\beta-1}e^{-(t/\eta)^\beta}$) via `scipy.stats.weibull_min`.
* **Trend & Renewal Analysis:** Applied Laplace trend tests to distinguish wear-out mechanisms ($\beta > 1$) from random constant-hazard failures ($\beta \approx 1$), followed by renewal theory cost-rate optimization ($C(T) = \frac{C_p R(T) + C_c [1 - R(T)]}{\int_0^T R(t)\,dt}$).

## Key Results

| Supplier | Sample Size ($N$) | Shape ($\beta$) | Scale ($\eta$, days) | Failure Regime | Optimal Policy |
| :--- | :---: | :---: | :---: | :--- | :--- |
| **Alpha (WDC)**] | 151 | 1.2326 | 219.68 | Mild Wear-Out | Run-to-Failure |
| **Beta (ST)** | 2,502 | 1.3310 | 352.63 | Progressive Wear-Out | Preventive Replacement |
| **Gamma (HGST)** | 318 | 0.9597 | 206.92 | Random / Constant | Run-to-Failure |

* **Recommended Strategy:** Selecting **Supplier Beta (ST)** paired with scheduled preventive replacement eliminates unplanned downtime penalties and achieves the lowest 3-year TCO while exceeding the 99% availability target.

## Tech Stack
* **Python:** `pandas`, `numpy`, `scipy.stats`
