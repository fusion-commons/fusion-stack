# Smoke test: load the KODEX fleet (kronos-fusion-ml) and run a surrogate,
# proving the Kronos family of codes works inside the stack — the same
# "proven, not just claimed" check the FreeGS equilibrium test applies.
#
# KECON is the generic open techno-economics calculator: it needs no bundled
# datasets, so it is a clean, deterministic in-container check that a KODEX
# surrogate actually runs (no network, no GPU).
import kronos_ml as K

names = K.list_surrogates()
assert len(names) >= 30, f"expected the KODEX fleet, got {len(names)} codes"

lcoe = K.run("KECON", {"capex": 5e9, "opex_per_yr": 1e8,
                       "annual_generation_MWh": 3e6,
                       "discount_rate": 0.07, "lifetime_yr": 30})
val = lcoe.y["lcoe_per_MWh"]
assert val > 0, f"expected a positive LCOE, got {val}"

print(f"KODEX: {len(names)} codes registered; KECON LCOE = {val:.1f} /MWh")
print("SMOKE OK: KODEX fleet imported and a surrogate ran")
