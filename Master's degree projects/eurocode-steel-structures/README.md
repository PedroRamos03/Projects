# Eurocode Steel Structures – Calculation Helpers

Personal calculation tools that implement the main formulas from the Eurocodes **Eurocode 1 (EN 1991)** and **Eurocode 3 (EN 1993-1-1)** for the design of steel industrial buildings.

These scripts were engineered to run directly on a **TI-Nspire CX II** Python environment. Because problem-specific geometry and boundary conditions were extracted manually from structural schematics during exams, the scripts use interactive `input()` prompts to ingest pre-processed section properties and load coefficients, automating repetitive code-compliance checks without manual table lookup errors.
Clean, non-interactive Python versions (fully in English) are also provided.

**Important:** These are calculation helpers, not complete design software. Always cross-check critical results with the Eurocode and exercise engineering judgement.

---

## Files

| File | Description |
|------|-------------|
| `wind_and_snow_actions.py` | Peak velocity pressure \(q_p(z)\), external pressure coefficients \(c_{pe,10}\) (walls + roof) and snow load |
| `buckling_and_stability.py` | Flexural buckling factors \(\chi_y\), \(\chi_z\) and lateral-torsional buckling \(M_{cr}\), \(\chi_{LT}\) |
| `wind_and_snow_actions.ipynb` | Original interactive notebook (Portuguese prompts) |
| `buckling_and_stability.ipynb` | Original interactive notebook (Portuguese prompts) |

The `.py` files are the recommended versions for the repository: they are fully in English, non-interactive, and ready to run.

---

## How to use the Python scripts

1. Open the script you need.
2. Edit the **INPUTS** section at the top with the geometry, material and coefficients of your problem.
3. Run:

```bash
python wind_and_snow_actions.py
python buckling_and_stability.py
```

The example values currently in the scripts correspond to a typical industrial portal frame (span ≈ 25 m, column height 6 m, 10° roof, Urban location, IPE 500 section).

---

## What the scripts calculate

### 1. Environmental Actions (`EN 1991-1-3` & `EN 1991-1-4`)
* **Wind Actions:** Computes peak velocity pressure $q_p(z)$, terrain roughness factors $c_r(z)$, exposure coefficients $c_e(z)$, and internal/External pressure coefficients \(c_{pe,10}\) for:
  - Vertical walls (zones A–E) – both wind directions
  - Duo-pitch roof (zones F–J) – transverse and longitudinal wind.
* **Snow Loads:** Evaluates roof snow load distributions ($s = \mu_i C_e C_t s_k$) for pitched and multi-span roofs.

### 2. Member Stability & Resistance (`EN 1993-1-1`)
* **Cross-Section Classification:** Automated Class 1–4 slenderness checks ($c/t$ ratios) for I/H-sections under pure compression, pure bending, and combined $N + M$ loading.
* **Flexural & Lateral-Torsional Buckling (LTB):** Computes elastic critical forces ($N_{cr}$), critical moments ($M_{cr}$), non-dimensional slenderness ($\bar{\lambda}, \bar{\lambda}_{LT}$), reduction factors ($\chi, \chi_{LT}$), and design buckling resistances ($N_{b,Rd}, M_{b,Rd}$).
* **Combined Bending & Axial Compression:** Evaluates interaction factors ($k_{yy}, k_{yz}, k_{zy}, k_{zz}$) using Method 1 (Annex A) and Method 2 (Annex B) interaction equations (Eq. 6.61 & 6.62).


---

## Notes

- All formulas follow the Eurocode structure (EN 1991 and EN 1993).
- Portuguese National Annex values are used for basic wind velocity and snow load on the ground.
- The original notebooks required manual inputs at runtime. The `.py` versions replace those inputs with a clear parameter block at the top of each file.
- Always verify critical coefficients and reduction factors against the official Eurocode tables.