"""
Eurocode Wind and Snow Actions Calculator
=========================================
Implements the main formulas from:
- EN 1991-1-4 (Wind actions) – qp(z) and external pressure coefficients cpe,10
- EN 1991-1-3 (Snow loads)

This script was originally developed as a personal exam-automation tool
for repetitive calculations in steel industrial building design.

Example values correspond to a typical industrial building in a
Portuguese coastal zone (Viana do Castelo type).
Change the INPUT section for a different geometry or location.
"""

import math

# ============================================================
# INPUTS – change these values for a new problem
# ============================================================

# Geometry
h_column = 6.0          # Column height [m]
span = 25.0             # Frame span [m]
roof_angle_deg = 10.0   # Roof slope [degrees]
building_length = 36.0  # Building length [m]

# Wind
wind_zone = "B"         # "A" or "B" (Portugal National Annex)
terrain_category = 4    # 1=Sea, 2=Rural, 3=Suburban, 4=Urban

# Snow
altitude = 720.0         # Site altitude [m]
snow_zone = 2           # 1, 2 or 3 (Portugal)
Ce = 1.0                # Exposure coefficient (usually 1.0)
Ct = 1.0                # Thermal coefficient (usually 1.0)

# ============================================================
# WIND – Peak velocity pressure qp(z)
# ============================================================

def calculate_qp(h_column, span, roof_angle_deg, wind_zone, terrain_category):
    """Calculate peak velocity pressure qp(z) according to EN 1991-1-4."""

    vb0 = 30.0 if wind_zone.upper() == "B" else 27.0
    vb = 1.0 * 1.0 * vb0

    roof_angle_rad = math.radians(roof_angle_deg)
    height_to_ridge = (span / 2.0) * math.tan(roof_angle_rad)
    z_ridge = h_column + height_to_ridge

    terrain = {
        1: {"z0": 0.005, "zmin": 1.0},
        2: {"z0": 0.05,  "zmin": 3.0},
        3: {"z0": 0.3,   "zmin": 8.0},
        4: {"z0": 1.0,   "zmin": 15.0},
    }
    z0 = terrain[terrain_category]["z0"]
    zmin = terrain[terrain_category]["zmin"]
    z = max(z_ridge, zmin)

    kr = 0.19 * (z0 / 0.05) ** 0.07
    cr = kr * math.log(z / z0)
    vm = cr * vb
    Iv = 1.0 / math.log(z / z0)

    rho = 1.25
    qp = (1 + 7 * Iv) * 0.5 * rho * vm**2 / 1000.0

    return {
        "z_ridge": round(z_ridge, 3),
        "vb": vb,
        "z0": z0,
        "zmin": zmin,
        "z": round(z, 3),
        "kr": round(kr, 4),
        "cr": round(cr, 4),
        "vm": round(vm, 3),
        "Iv": round(Iv, 4),
        "qp": round(qp, 4),
    }


# ============================================================
# EXTERNAL PRESSURE COEFFICIENTS cpe,10
# ============================================================

def _interpolate(x, x1, x2, y1, y2):
    """Linear interpolation."""
    if x2 == x1:
        return y1
    return y1 + (x - x1) * (y2 - y1) / (x2 - x1)


def wall_cpe(h_d_ratio):
    """
    External pressure coefficients for vertical walls (EN 1991-1-4 Table 7.1).
    Returns dict with zones A, B, C, D, E.
    Interpolation for h/d between 0.25, 1.0 and 5.0.
    """
    # Reference values from Table 7.1
    #                h/d=5.0   h/d=1.0   h/d=0.25
    table = {
        "A": (-1.2, -1.2, -1.2),
        "B": (-0.8, -0.8, -0.8),
        "C": (-0.5, -0.5, -0.5),
        "D": ( 0.8,  0.8,  0.7),
        "E": (-0.7, -0.5, -0.3),
    }

    result = {}
    for zone, (v5, v1, v025) in table.items():
        if h_d_ratio >= 5.0:
            val = v5
        elif h_d_ratio <= 0.25:
            val = v025
        elif h_d_ratio > 1.0:
            val = _interpolate(h_d_ratio, 1.0, 5.0, v1, v5)
        else:
            val = _interpolate(h_d_ratio, 0.25, 1.0, v025, v1)
        result[zone] = round(val, 3)
    return result


def roof_cpe_transverse(angle):
    """
    External pressure coefficients for duo-pitch roof, wind perpendicular to the ridge
    (transverse / 0°). Zones F, G, H, I, J.
    Values taken from EN 1991-1-4 Table 7.4a (simplified interpolation).
    """
    # Angle key points: 5°, 15°, 30°, 45°, 60°, 75°
    # Each zone can have one or two values (suction / pressure)
    data = {
        "F": {5: [-1.7, 0.0], 15: [-0.9, 0.2], 30: [-0.5, 0.7], 45: [0.0, 0.7], 60: [0.7], 75: [0.8]},
        "G": {5: [-1.2, 0.0], 15: [-0.8, 0.2], 30: [-0.5, 0.7], 45: [0.0, 0.7], 60: [0.7], 75: [0.8]},
        "H": {5: [-0.6, 0.0], 15: [-0.3, 0.2], 30: [-0.2, 0.4], 45: [0.0, 0.6], 60: [0.7], 75: [0.8]},
        "I": {5: [-0.6, 0.0], 15: [-0.4, 0.0], 30: [-0.4, 0.0], 45: [-0.2, 0.0], 60: [-0.2], 75: [-0.2]},
        "J": {5: [-0.6, 0.2], 15: [-1.0, 0.0], 30: [-0.5, 0.0], 45: [-0.3, 0.0], 60: [-0.3], 75: [-0.3]},
    }
    return _interpolate_roof(angle, data)


def roof_cpe_longitudinal(angle):
    """
    External pressure coefficients for duo-pitch roof, wind parallel to the ridge
    (longitudinal / 90°). Zones F, G, H, I.
    """
    data = {
        "F": {5: [-1.6], 15: [-1.3], 30: [-1.1], 45: [-1.1], 60: [-1.1], 75: [-1.1]},
        "G": {5: [-1.3], 15: [-1.3], 30: [-1.4], 45: [-1.4], 60: [-1.2], 75: [-1.2]},
        "H": {5: [-0.7], 15: [-0.6], 30: [-0.8], 45: [-0.9], 60: [-0.8], 75: [-0.8]},
        "I": {5: [-0.6], 15: [-0.5], 30: [-0.5], 45: [-0.5], 60: [-0.5], 75: [-0.5]},
    }
    return _interpolate_roof(angle, data)


def _interpolate_roof(angle, data):
    """Interpolate roof coefficients for a given pitch angle."""
    result = {}
    angles = [5, 15, 30, 45, 60, 75]

    for zone, values in data.items():
        if angle <= 5:
            result[zone] = values[5]
        elif angle >= 75:
            result[zone] = values[75]
        else:
            # Find surrounding angles
            for i in range(len(angles) - 1):
                a1, a2 = angles[i], angles[i + 1]
                if a1 <= angle <= a2:
                    v1 = values[a1]
                    v2 = values[a2]
                    # Interpolate each component
                    interp = []
                    max_len = max(len(v1), len(v2))
                    for k in range(max_len):
                        y1 = v1[k] if k < len(v1) else v1[-1]
                        y2 = v2[k] if k < len(v2) else v2[-1]
                        interp.append(round(_interpolate(angle, a1, a2, y1, y2), 3))
                    result[zone] = interp
                    break
    return result


def calculate_cpe(h_column, span, roof_angle_deg, building_length):
    """
    Calculate external pressure coefficients for both wind directions.
    Returns a dictionary with walls and roof coefficients.

    Note on reference height:
    - Transverse wind (0°): h = ridge height
    - Longitudinal wind (90°): h = column / eaves height
    """
    # For transverse wind (0°): b = building length, d = span
    # For longitudinal wind (90°): b = span, d = building length
    h = h_column + (span / 2.0) * math.tan(math.radians(roof_angle_deg))

    # Transverse
    b_trans = building_length
    d_trans = span
    e_trans = min(b_trans, 2 * h)
    hd_trans = h / d_trans

    # Longitudinal
    b_long = span
    d_long = building_length
    e_long = min(b_long, 2 * h_column)
    hd_long = h_column / d_long

    return {
        "geometry": {
            "h_ridge": round(h, 3),
            "e_transverse": round(e_trans, 3),
            "h/d_transverse": round(hd_trans, 3),
            "e_longitudinal": round(e_long, 3),
            "h/d_longitudinal": round(hd_long, 3),
        },
        "walls_transverse": wall_cpe(hd_trans),
        "walls_longitudinal": wall_cpe(hd_long),
        "roof_transverse": roof_cpe_transverse(roof_angle_deg),
        "roof_longitudinal": roof_cpe_longitudinal(roof_angle_deg),
    }


# ============================================================
# SNOW LOAD
# ============================================================

def calculate_snow(altitude, snow_zone, roof_angle_deg, Ce=1.0, Ct=1.0):
    """Calculate characteristic snow load on the roof (EN 1991-1-3 + Portuguese NA)."""
    Cz = {1: 0.30, 2: 0.20, 3: 0.15}[snow_zone]
    sk = Cz * (1 + (altitude / 500.0)**2)

    if roof_angle_deg <= 30:
        mu1 = 0.8
    elif roof_angle_deg < 60:
        mu1 = 0.8 * (60 - roof_angle_deg) / 30
    else:
        mu1 = 0.0

    s = mu1 * Ce * Ct * sk
    return {
        "sk": round(sk, 4),
        "mu1": round(mu1, 4),
        "s": round(s, 4),
    }


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":
    print("=" * 65)
    print("  EUROCODE – WIND AND SNOW ACTIONS (with cpe,10)")
    print("=" * 65)

    print("\nGeometry")
    print(f"  Column height     : {h_column} m")
    print(f"  Span              : {span} m")
    print(f"  Roof angle        : {roof_angle_deg}°")
    print(f"  Building length   : {building_length} m")

    print("\n--- 1. Peak velocity pressure qp(z) ---")
    wind = calculate_qp(h_column, span, roof_angle_deg, wind_zone, terrain_category)
    for k, v in wind.items():
        print(f"  {k:12s} = {v}")

    print("\n--- 2. External pressure coefficients cpe,10 ---")
    cpe = calculate_cpe(h_column, span, roof_angle_deg, building_length)

    print("\n  Geometry parameters:")
    for k, v in cpe["geometry"].items():
        print(f"    {k:20s} = {v}")

    print("\n  Walls – Transverse wind (0°):")
    for zone, val in cpe["walls_transverse"].items():
        print(f"    Zone {zone}: {val}")

    print("\n  Walls – Longitudinal wind (90°):")
    for zone, val in cpe["walls_longitudinal"].items():
        print(f"    Zone {zone}: {val}")

    print("\n  Roof – Transverse wind (0°):")
    for zone, val in cpe["roof_transverse"].items():
        print(f"    Zone {zone}: {val}")

    print("\n  Roof – Longitudinal wind (90°):")
    for zone, val in cpe["roof_longitudinal"].items():
        print(f"    Zone {zone}: {val}")

    print("\n--- 3. Snow load ---")
    snow = calculate_snow(altitude, snow_zone, roof_angle_deg, Ce, Ct)
    for k, v in snow.items():
        print(f"  {k:12s} = {v}")

    print("\n" + "=" * 65)
    print("Notes:")
    print("  - qp is in kN/m²")
    print("  - cpe values follow EN 1991-1-4 Tables 7.1 and 7.4a")
    print("  - Always verify critical coefficients against the official tables")
    print("  - This is a calculation helper, not a substitute for full verification")
    print("=" * 65)