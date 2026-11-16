# Mechanical Engineering & Scientific Computing Portfolio

**Pedro Ramos** — M.Sc. in Mechanical Engineering (Machine Design), Faculty of Engineering of the University of Porto (FEUP)

This repository consolidates computational engineering tools, numerical optimization solvers, reliability models, and upcoming physics-informed machine learning implementations developed across my Master's coursework and independent technical projects.

---

## Repository Structure

```text
.
├── Master's degree projects/
│   ├── eurocode-steel-structures/         # EN 1991 & EN 1993 structural steel design helpers (Python)
│   ├── hdd-reliability-ai-datacenter/     # Weibull MLE reliability & TCO maintenance policy (MATLAB, Python, Excel)
│   ├── hertzian-contact-ehl-lubrication/  # Tribology, EHL film thickness & flash temperature solver (Python)
│   └── welded-beam-design-optimization/   # Constrained NLP Augmented Lagrangian solver (MATLAB)
├── ml-engineering-projects/               # [In Progress] PyTorch surrogate models & PINNs for mechanics
└── README.md
```

---

## 1. Master's Degree Projects (`Master's degree projects/`)

A collection of engineering calculation tools, numerical solvers, and quantitative studies developed during my M.Sc. in Mechanical Engineering at FEUP:

| Project | Domain | Core Methods & Models | Tech Stack |
| :--- | :--- | :--- | :--- |
| **[Welded Beam Design Optimization](./Master's%20degree%20projects/welded-beam-design-optimization/README.md)** | Numerical Optimization & Machine Design | Constrained NLP from scratch using Augmented Lagrangian, Steepest Descent, Conjugate Gradient (Fletcher-Reeves & Polak-Ribière), and Armijo line search | `MATLAB` (Symbolic Math) |
| **[HDD Reliability & Maintenance Policy](./Master's%20degree%20projects/hdd-reliability-ai-datacenter/README.md)** | Industrial Maintenance & Reliability Engineering | Laplace trend test, 2-parameter Weibull MLE fitting ($\beta, \eta$), and 3-year Total Cost of Ownership (TCO) optimization for 2,000 datacenter drives | `Python` (`SciPy`), `MATLAB`, `Excel` |
| **[Eurocode Steel Structures](./Master's%20degree%20projects/eurocode-steel-structures/README.md)** | Structural Engineering & Code Compliance | Automated wind/snow environmental actions (`EN 1991`), cross-section classification, flexural/LTB buckling, and $N+M$ interaction checks (`EN 1993-1-1`) | `Python` (Standard Library & TI-Nspire) |
| **[Hertzian Contact & EHL Lubrication](./Master's%20degree%20projects/hertzian-contact-ehl-lubrication/README.md)** | Tribology & Contact Mechanics | Line/elliptical Hertzian contact stress, ISO VG rheology, Dowson–Higginson & Hamrock–Dowson EHL film thickness ($\Lambda$), and Blok flash temperature ($\Delta T_{\max}$) | `Python` (Standard Library) |

---

## 2. Physics-Informed Machine Learning (`ml-engineering-projects/` — *In Progress*)

Currently expanding this repository with **PyTorch** projects that bridge continuum mechanics, finite element analysis (FEA), and data-driven modeling:
* **Surrogate FEA Modeling:** Neural network regressors trained on analytical and finite element datasets to predict structural deflection and stress concentrations in real time.
* **Physics-Informed Neural Networks (PINNs):** Embedding governing differential equations and boundary conditions directly into loss functions for mechanical systems.
* **Predictive Maintenance & Time-Series Diagnostics:** Deep learning classification and remaining useful life (RUL) estimation on rotating machinery / sensor telemetry.

---

## Core Technical Stack

* **Simulation & CAD:** Finite Element Analysis (FEA), Explicit Dynamic Contact Mechanics (MOOSE), SolidWorks, AutoCAD, GD&T
* **Programming & Scientific Computing:** C++ (MPI), Python (`NumPy`, `SciPy`, `Pandas`, `PyTorch`), MATLAB, LaTeX

---

## Contact

* **LindekIn:** www.linkedin.com/in/pedro-ramos-322470243
* **Focus Areas:** CAE / FEA Simulation, Machine Design & Automation, High-Tech Manufacturing, and Scientific Machine Learning
