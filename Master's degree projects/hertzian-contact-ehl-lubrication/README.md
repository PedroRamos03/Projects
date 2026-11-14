# Hertzian Contact & Elastohydrodynamic Lubrication (EHL) Solver

Interactive Python script built for **TI-Nspire CX II** to automate Hertzian contact stress, elastohydrodynamic (EHL) lubricant film thickness, and thermal flash-temperature calculations for ISO VG industrial lubricants in non-conformal machine elements (gears, rolling bearings, and cam-follower pairs).

## Context
Designed as an exam-ready verification tool: preliminary geometric radii and load distributions are derived from the mechanical assembly drawing, after which the script executes the coupled tribological equations interactively.

## Engineering Models Implemented
* **Equivalent Contact Geometry & Elasticity:** Computes reduced radius of curvature ($R'$) and effective elastic modulus ($E^*$) for line (cylindrical) and elliptical (point) contacts.
* **Hertzian Dry Contact:** Calculates maximum contact pressure ($p_0$), mean pressure ($p_m$), contact half-width ($b$) or semi-axes ($a, b$), and maximum subsurface shear stress ($\tau_{\max}$).
* **Lubricant Rheology (ISO VG Grades):** Evaluates dynamic viscosity ($\eta_0$) at operating temperature and pressure-viscosity coefficients ($\alpha$).
* **EHL Film Thickness & Regime:** Computes minimum and central film thickness ($h_{\min}, h_c$) via **Dowson–Higginson** (line contact) and **Hamrock–Dowson** (elliptical contact) equations, determining the specific film thickness ($\Lambda = h_{\min} / \sigma^*$) to classify boundary, mixed, or full-film lubrication.
* **Thermal Analysis:** Estimates friction power loss and Blok's maximum surface flash temperature rise ($\Delta T_{\max}$) to assess scuffing risk.

## Tech Stack
* **Python 3** (`math` — standalone standard-library implementation)