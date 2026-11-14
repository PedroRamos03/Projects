"""
Eurocode Buckling and Stability Checks (EN 1993-1-1)
====================================================
Calculates the main reduction factors used in member stability verification:

- χy  : flexural buckling about the strong axis
- χz  : flexural buckling about the weak axis
- χLT : lateral-torsional buckling

Also computes the elastic critical moment Mcr for lateral-torsional buckling.

This script was originally developed as a personal exam-automation tool
for repetitive steel structure calculations.

Example values correspond to a typical IPE 500 (S275) column / beam
in an industrial portal frame.
Change the INPUT section for a different profile or geometry.
"""

import math

# ============================================================
# INPUTS – change these values for a new problem
# ============================================================

# Material
E = 210.0           # Young's modulus [GPa]
G = 81.0            # Shear modulus [GPa]
fy = 275.0          # Yield strength [MPa]

# Geometry of the member (example: IPE 500)
h = 500.0           # Overall depth [mm]
b = 200.0           # Flange width [mm]
tf = 16.0           # Flange thickness [mm]
tw = 10.2           # Web thickness [mm]
iy = 204.0          # Radius of gyration y-y [mm]   (strong axis)
iz = 43.1           # Radius of gyration z-z [mm]   (weak axis)
Iz = 21.42e6        # Second moment of area z-z [mm⁴]
Wpl_y = 2194e3      # Plastic section modulus y-y [mm³]

# Buckling lengths
Le_y = 6.0 * 1.48   # Buckling length strong axis [m]  (example: β = 1.48)
Le_z = 6.0          # Buckling length weak axis [m]
Lcr_LT = 5.0        # Length for lateral-torsional buckling [m]

# Imperfection factors (EN 1993-1-1 Table 6.2 / 6.3)
# For rolled I-section, h/b > 1.2, tf ≤ 40 mm → curve a (α = 0.21) for y-y
# curve b (α = 0.34) for z-z and LT
alpha_y = 0.21
alpha_z = 0.34
alpha_LT = 0.34

# Lateral-torsional buckling parameters
C1 = 1.285          # Factor depending on moment diagram
k = 1.0             # Effective length factor
kw = 1.0            # Warping factor

# ============================================================
# HELPER FUNCTIONS
# ============================================================

def chi_from_lambda(lambda_bar, alpha):
    """Calculate reduction factor χ from non-dimensional slenderness."""
    phi = 0.5 * (1 + alpha * (lambda_bar - 0.2) + lambda_bar**2)
    chi = 1.0 / (phi + math.sqrt(phi**2 - lambda_bar**2))
    return min(chi, 1.0)


def calculate_buckling_factors():
    """Main calculation of χy, χz and χLT."""

    # Convert to SI units
    E_si = E * 1e9          # Pa
    G_si = G * 1e9          # Pa
    fy_si = fy * 1e6        # Pa

    h_si = h / 1000.0
    b_si = b / 1000.0
    tf_si = tf / 1000.0
    tw_si = tw / 1000.0
    iy_si = iy / 1000.0
    iz_si = iz / 1000.0
    Iz_si = Iz * 1e-12      # m⁴
    Wpl_y_si = Wpl_y * 1e-9 # m³

    # λ1
    lambda_1 = math.pi * math.sqrt(E_si / fy_si)

    # ----- Flexural buckling y-y -----
    lambda_y = Le_y / iy_si
    lambda_bar_y = lambda_y / lambda_1
    chi_y = chi_from_lambda(lambda_bar_y, alpha_y)

    # ----- Flexural buckling z-z -----
    lambda_z = Le_z / iz_si
    lambda_bar_z = lambda_z / lambda_1
    chi_z = chi_from_lambda(lambda_bar_z, alpha_z)

    # ----- Lateral-torsional buckling -----
    # Torsional properties
    hm = h_si - tf_si
    Iw = Iz_si * (hm**2) / 4.0
    It = (1.0/3.0) * (2 * b_si * tf_si**3 + (h_si - 2*tf_si) * tw_si**3)

    # Elastic critical moment Mcr
    term1 = (math.pi**2 * E_si * Iz_si) / (k * Lcr_LT)**2
    term2 = (k/kw)**2 * (Iw / Iz_si)
    term3 = ((k * Lcr_LT)**2 * G_si * It) / (math.pi**2 * E_si * Iz_si)
    Mcr = C1 * term1 * math.sqrt(term2 + term3)   # Nm

    lambda_bar_LT = math.sqrt((Wpl_y_si * fy_si) / Mcr)
    chi_LT = chi_from_lambda(lambda_bar_LT, alpha_LT)

    return {
        "lambda_1": round(lambda_1, 2),
        "lambda_bar_y": round(lambda_bar_y, 4),
        "chi_y": round(chi_y, 4),
        "lambda_bar_z": round(lambda_bar_z, 4),
        "chi_z": round(chi_z, 4),
        "Mcr_kNm": round(Mcr / 1000.0, 2),
        "lambda_bar_LT": round(lambda_bar_LT, 4),
        "chi_LT": round(chi_LT, 4),
        "Iw": Iw,
        "It": It,
    }


# ============================================================
# MAIN – run the example
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  EUROCODE – BUCKLING & STABILITY (EN 1993-1-1)")
    print("=" * 60)

    print("\nMaterial")
    print(f"  E  = {E} GPa")
    print(f"  G  = {G} GPa")
    print(f"  fy = {fy} MPa")

    print("\nSection (example IPE 500)")
    print(f"  h × b × tf × tw = {h} × {b} × {tf} × {tw} mm")

    results = calculate_buckling_factors()

    print("\n--- Results ---")
    print(f"  λ1              = {results['lambda_1']}")
    print(f"  λ̄y              = {results['lambda_bar_y']}")
    print(f"  χy              = {results['chi_y']}")
    print(f"  λ̄z              = {results['lambda_bar_z']}")
    print(f"  χz              = {results['chi_z']}")
    print(f"  Mcr             = {results['Mcr_kNm']} kNm")
    print(f"  λ̄LT             = {results['lambda_bar_LT']}")
    print(f"  χLT             = {results['chi_LT']}")

    print("\n" + "=" * 60)
    print("Notes:")
    print("  - These reduction factors are used in the interaction formulae")
    print("    of EN 1993-1-1 §6.3.3 (members subjected to compression + bending).")
    print("  - Always verify the choice of buckling curve (α) and C1 factor")
    print("    against the specific moment diagram and section class.")
    print("  - This script is a calculation helper, not a substitute for")
    print("    engineering judgement or full code verification.")
    print("=" * 60)