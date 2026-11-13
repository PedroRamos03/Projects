# Eurocode 1 & Eurocode 3 Structural Steel Design Calculators

Interactive Python calculation scripts developed for rapid structural verification of steel members and industrial buildings under **Eurocode 1 (EN 1991)** and **Eurocode 3 (EN 1993-1-1)** during timed engineering assessments.

## Context & Design Philosophy
These scripts were engineered to run directly on a **TI-Nspire CX II** Python environment. Because problem-specific geometry and boundary conditions were extracted manually from structural schematics during exams, the scripts use interactive `input()` prompts to ingest pre-processed section properties and load coefficients, automating repetitive code-compliance checks without manual table lookup errors.

## Modules Included

### 1. Environmental Actions (`EN 1991-1-3` & `EN 1991-1-4`)
* **Wind Actions:** Computes peak velocity pressure $q_p(z)$, terrain roughness factors $c_r(z)$, exposure coefficients $c_e(z)$, and internal/external surface pressures ($w_e, w_i$) across building zones.
* **Snow Loads:** Evaluates roof snow load distributions ($s = \mu_i C_e C_t s_k$) for pitched and multi-span roofs.

### 2. Member Stability & Resistance (`EN 1993-1-1`)
* **Cross-Section Classification:** Automated Class 1–4 slenderness checks ($c/t$ ratios) for I/H-sections under pure compression, pure bending, and combined $N + M$ loading.
* **Flexural & Lateral-Torsional Buckling (LTB):** Computes elastic critical forces ($N_{cr}$), critical moments ($M_{cr}$), non-dimensional slenderness ($\bar{\lambda}, \bar{\lambda}_{LT}$), reduction factors ($\chi, \chi_{LT}$), and design buckling resistances ($N_{b,Rd}, M_{b,Rd}$).
* **Combined Bending & Axial Compression:** Evaluates interaction factors ($k_{yy}, k_{yz}, k_{zy}, k_{zz}$) using Method 1 (Annex A) and Method 2 (Annex B) interaction equations (Eq. 6.61 & 6.62).

## Tech Stack
* **Python 3** (`math` — zero external dependencies for embedded calculator compatibility)