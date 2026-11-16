# Kirchhoff–Love Trapezoidal Plate Bending Solver (Rayleigh–Ritz Method)

## Overview
This project implements an analytical-numerical **Rayleigh–Ritz** solver in **MATLAB** to compute the transverse deflection and plane-stress distributions of thin trapezoidal plates under Kirchhoff–Love classical plate theory. Developed for graduate coursework in **Plates and Shells** (*Placas e Cascas*) at the Faculty of Engineering of the University of Porto (FEUP), the solver formulates admissible tensor-product basis functions, verifies boundary conditions symbolically, maps irregular trapezoidal domains via isoparametric shape functions, and evaluates von Mises yield criteria.

---

## Mechanical & Mathematical Formulation

### Governing Equation & Flexural Rigidity
For a thin isotropic plate of uniform thickness $h$, Young's modulus $E$, and Poisson's ratio $\nu$, the flexural rigidity is:
$$D = \frac{E h^3}{12(1 - \nu^2)}$$

The Rayleigh–Ritz approximation expands the transverse deflection field $w(x_1, x_2)$ as a linear combination of $N = p_o^2$ admissible 2D basis functions $\Phi_i(x_1, x_2)$:
$$w(x_1, x_2) = \sum_{i=1}^{p_o^2} q_i \Phi_i(x_1, x_2)$$

### Boundary Conditions & Admissible Basis Functions
Two boundary conditions are implemented on the natural domain $(\xi, \eta) \in [-1, 1]^2$ and verified automatically along all four edges:
1. **Simply Supported (`SSSS`):** Trigonometric sine basis functions satisfying $w = 0$ and $\frac{\partial^2 w}{\partial n^2} = 0$ on all boundaries.
2. **Clamped (`CCCC`):** Up to 25 symmetric and antisymmetric orthogonalized polynomial basis functions satisfying $w = 0$ and $\frac{\partial w}{\partial n} = 0$ on all boundaries.

### Isoparametric Domain Mapping
A 4-node bilinear isoparametric mapping transforms the natural square $(\xi, \eta) \in [-1, 1]^2$ onto a trapezoidal physical geometry defined by base lengths $a$, $c$ and height $b$, assembling the bending stiffness matrix $K_{ij}$ and generalized load vector $P_i$:
$$K_{ij} = \iint_{\Omega} D \left( \frac{\partial^4 \Phi_i}{\partial x_1^4} + 2 \frac{\partial^4 \Phi_i}{\partial x_1^2 \partial x_2^2} + \frac{\partial^4 \Phi_i}{\partial x_2^4} \right) \Phi_j \, d\Omega$$

### Supported Load Cases
* **Case 1:** Uniform pressure $p$ over the entire plate surface
* **Case 2:** Patch pressure $p$ over a rectangular sub-region $[x_{1,\inf}, x_{1,\sup}] \times [x_{2,\inf}, x_{2,\sup}]$
* **Case 3:** Line load $L$ along a horizontal or vertical line (modeled via Dirac delta distributions)
* **Case 4:** Concentrated point force $F$ at $(x_p, y_p)$

### Stress & Yield Evaluation
At the top fiber ($z = h/2$), bending curvatures yield the plane-stress components ($\sigma_{x_1x_1}, \sigma_{x_2x_2}, \tau_{x_1x_2}$) and the **von Mises equivalent stress**:
$$\sigma_{vm} = \sqrt{\sigma_{x_1x_1}^2 - \sigma_{x_1x_1}\sigma_{x_2x_2} + \sigma_{x_2x_2}^2 + 3\tau_{x_1x_2}^2} \le \sigma_y$$

---

## Repository Structure

```text
kirchhoff-plate-ritz-solver/
├── trapezoidal_plate_ritz_solver.m   # Main symbolic-numeric Rayleigh-Ritz solver and 3D post-processor
└── README.md
```

---

## How to Run

### Prerequisites
* **MATLAB** (tested on R2023b+)
* **Symbolic Math Toolbox** (required for `syms`, symbolic differentiation/integration, and coordinate inversion)

### Execution
1. Navigate to the project folder in MATLAB:
   ```matlab
   cd('Master''s degree projects/kirchhoff-plate-ritz-solver')
   ```
2. Configure geometry (`a, b, c, h`), `boundarycase` (`1` = SSSS, `2` = CCCC), `loadcase` (`1`–`4`), and basis order `po` at the top of `trapezoidal_plate_ritz_solver.m`, then run:
   ```matlab
   trapezoidal_plate_ritz_solver
   ```
3. The script outputs stiffness/load matrices, maximum deflection $w_{\max}$, maximum von Mises stress $\sigma_{vm,\max}$ vs. yield strength $\sigma_y$, and 3D surface plots for $w$, $\sigma_{x_1x_1}$, $\sigma_{x_2x_2}$, and $\tau_{x_1x_2}$.