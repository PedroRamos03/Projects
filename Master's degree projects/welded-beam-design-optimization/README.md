# Welded Beam Design Optimization (Classical Nonlinear Programming)

## Overview
This project implements a constrained nonlinear programming (NLP) solver from scratch in **MATLAB** to solve the classic **Welded Beam Design Optimization** benchmark (SMA7). Developed as part of the *Optimization of Mechanical Systems* (*Otimização de Sistemas Mecânicos*) M.Sc. course at the Faculty of Engineering of the University of Porto (FEUP), the objective is to minimize the fabrication cost (weld material and beam stock) of a cantilever beam welded to a rigid support under a vertical tip load, subject to structural, buckling, deflection, and geometric constraints.

---

## Problem Formulation

### Design Variables
The system is parameterized by four continuous geometric design variables (in inches):
* $x_1 = h$: Weld leg thickness
* $x_2 = l$: Length of the welded joint
* $x_3 = t$: Beam cross-section height
* $x_4 = b$: Beam cross-section width

### Objective Function
Minimize total manufacturing cost (proportional to weld volume plus beam volume):
$$\min_{x} f(x) = 1.10471 x_1^2 x_2 + 0.04811 x_3 x_4 (14.0 + x_2)$$

### Constraints & Parameters
* **Applied Load & Material Properties:** $P = 6000\text{ lb}$, $L = 14\text{ in}$, $E = 30 \times 10^6\text{ psi}$, $G = 12 \times 10^6\text{ psi}$
* **Behavioral Constraints (Normalized):**
  1. **Weld Shear Stress:** $\tau(x) / \tau_{\max} - 1 \le 0$, where $\tau_{\max} = 13.6 \times 10^3\text{ psi}$ (combining primary direct shear $\tau'$ and secondary torsional shear $\tau''$)
  2. **Beam Bending Stress:** $\sigma(x) / \sigma_{\max} - 1 \le 0$, where $\sigma_{\max} = 30 \times 10^3\text{ psi}$
  3. **Tip Deflection:** $\delta(x) / \delta_{\max} - 1 \le 0$, where $\delta_{\max} = 0.25\text{ in}$
  4. **Buckling Load:** $1 - P_c(x) / P \le 0$
  5. **Cost/Material Cap:** $(0.10471 x_1^2 + 0.04811 x_3 x_4 (14.0 + x_2)) / 5 - 1 \le 0$
* **Geometric & Side Bounds:**
  * Weld-to-width ratio: $x_1 / x_4 - 1 \le 0$
  * $0.125 \le x_1 \le 2.0\text{ in}$
  * $0.1 \le x_4 \le 2.0\text{ in}$
  * $0.1 \le x_2, x_3 \le 10.0\text{ in}$

---

## Optimization Methodology

To solve the constrained NLP problem without relying on built-in black-box optimizers (`fmincon`), the solver architecture combines:

1. **Augmented Lagrangian Method:** Transforms the nonlinear inequality-constrained problem into a sequence of unconstrained subproblems using slack variable elimination, Lagrange multiplier updates ($\lambda^{k+1} = \max\{0, \lambda^k + \frac{2}{\epsilon^k} g(x^k)\}$), and penalty parameter updates ($\epsilon$). Symbolic differentiation (`syms`) is used to generate exact analytical gradients of the objective and behavioral constraints.
2. **Search Direction Algorithms:**
   * **Steepest Descent:** $d^k = -\nabla \mathcal{L}_a(x^k, \lambda^k, \epsilon^k)$
   * **Nonlinear Conjugate Gradient:** Supports both **Fletcher-Reeves** ($\beta_{FR}$) and **Polak-Ribière** ($\beta_{PR}$) formulations with periodic direction resets every $n=10$ iterations or upon loss of conjugacy.
3. **Modified Armijo Backtracking Line Search:** Determines the step size $\alpha^k$ satisfying the sufficient decrease condition while simultaneously enforcing box/geometric bounds at each trial step.

---

## Results

Starting from the standard benchmark initial point $x^{(0)} = [0.4000, 6.0000, 9.0000, 0.5000]\text{ in}$ ($f(x^{(0)}) = \$5.3904$):

| Case / Solver | $h$ ($x_1$) [in] \vert{} $l$ ($x_2$) [in] \vert{} $t$ ($x_3$) [in] \vert{} $b$ ($x_4$) [in] \vert{} Cost $f(x)$[$] |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Initial Design** | 0.4000 | 6.0000 | 9.0000 | 0.5000 | 5.3904 |
| **Augmented Lagrangian (Steepest Descent)** | 0.2333 | 5.9884 | 8.9856 | 0.2400 | **2.4336** |
| **Literature Global Optimum** | 0.2444 | 6.2177 | 8.2915 | 0.2444 | **2.3810** |

The solver reduces total manufacturing cost by **54.8%** from the initial feasible design, converging within **2.21%** of the known analytical global optimum while strictly satisfying all structural and geometric constraints.

---

## Repository Structure

```text
welded-beam-design-optimization/
├── problem-statement/
│   ├── Problem_page1.jpg           # Problem description, geometry diagram & objective/constraints
│   └── Problem_page2.jpg           # Stress/deflection equations, constants & benchmark optimum
├── main_steepest_descent.m         # Main script: Augmented Lagrangian + Steepest Descent
├── main_conjugate_gradient.m       # Main script: Augmented Lagrangian + Conjugate Gradient (FR & PR)
├── augmented_lagrangian.m          # Augmented Lagrangian objective evaluation
├── grad_augmented_lagrangian.m     # Analytical gradient of the Augmented Lagrangian
├── armijo_line_search.m            # Backtracking Armijo line search with bound checks
├── conjugate_gradient_dir.m        # Conjugate gradient direction & restart logic
└── README.md
```

---

## How to Run

### Prerequisites
* **MATLAB** (tested on R2023b+)
* **Symbolic Math Toolbox** (used for automatic analytical gradient generation via `syms` and `gradient`)

### Execution
1. Clone the repository and navigate to this project folder in MATLAB:
   ```matlab
   cd('faculty-projects/welded-beam-design-optimization')
   ```
2. Run the Steepest Descent solver:
   ```matlab
   main_steepest_descent
   ```
3. Or run the Conjugate Gradient solver (set `mode = 1` for Fletcher-Reeves or `mode = 2` for Polak-Ribière inside the script):
   ```matlab
   main_conjugate_gradient
   ```