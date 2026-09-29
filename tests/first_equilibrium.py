# Smoke test: solve a real free-boundary tokamak equilibrium with FreeGS.
# This is the same script as the index's "Your first equilibrium" guide,
# verified by hand on 2026-09-29 (200.0 kA, poloidal beta 0.027).
import freegs

tokamak = freegs.machine.TestTokamak()
eq = freegs.Equilibrium(tokamak=tokamak,
                        Rmin=0.1, Rmax=2.0,
                        Zmin=-1.0, Zmax=1.0,
                        nx=65, ny=65)
profiles = freegs.jtor.ConstrainPaxisIp(eq, 1e3, 2e5, 2.0)
constrain = freegs.control.constrain(xpoints=[(1.1, -0.6), (1.1, 0.6)],
                                     isoflux=[(1.1, -0.6, 1.1, 0.6)])
freegs.solve(eq, profiles, constrain)

ip_ka = eq.plasmaCurrent() / 1e3
print(f"Plasma current: {ip_ka:.1f} kA")
assert abs(ip_ka - 200.0) < 1.0, f"expected ~200 kA, got {ip_ka:.1f}"
print("SMOKE OK: equilibrium solved")
