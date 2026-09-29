# fusion-stack

> The open-source fusion toolchain, installed and working, in one command.

```bash
docker run -it --rm -p 8888:8888 -v "$PWD":/work ghcr.io/fusion-commons/fusion-stack
```

That starts JupyterLab (open the printed `localhost:8888` link) with the stack ready. Your current directory is mounted at `/work`.

Part of [The Fusion Commons](https://github.com/fusion-commons/index) — the index tells you *what exists*; this repo makes the open core of it *run*.

## What's inside

Real fusion codes have mutually incompatible dependency pins (FreeGS needs NumPy 1.x; TORAX's JAX stack doesn't — we verified the conflict rather than papering over it). So the image ships **three environments**, driven by one launcher:

| Environment | Tools | Why it's separate |
|---|---|---|
| `core` | [FreeGS](https://github.com/freegs-plasma/freegs) · [FreeQDSK](https://github.com/freegs-plasma/FreeQDSK) · [PlasmaPy](https://github.com/PlasmaPy/PlasmaPy) · [OMAS](https://github.com/gafusion/omas) · JupyterLab | Equilibrium and analysis on NumPy 1.x (FreeGS breaks on NumPy 2) |
| `transport` | [TORAX](https://github.com/google-deepmind/torax) · [cfspopcon](https://github.com/cfs-energy/cfspopcon) | The NumPy 2 stack — JAX transport plus operating-point analysis (cfspopcon requires numpy≥2.4) |
| `neutronics` | [OpenMC](https://github.com/openmc-dev/openmc) | Conda-forge build, heavy native dependencies |

```bash
fus core       python my_equilibrium.py    # run in an environment
fus transport  python -m my_torax_run
fus neutronics python my_blanket_model.py
fus lab                                    # JupyterLab (core)
fus list                                   # show environments
```

## Without Docker (HPC / laptop conda users)

The environment files stand alone — use them directly with [micromamba](https://mamba.readthedocs.io) or conda:

```bash
micromamba create -f envs/core.yml
micromamba run -n core python -c "import freegs; print('ready')"
```

## Verified, not hoped

- CI builds the image and runs a **real physics smoke test** on every change: it solves a free-boundary tokamak equilibrium with FreeGS ([tests/first_equilibrium.py](tests/first_equilibrium.py) — the same script as the Commons' hands-on guide, checked against its known answer) plus import checks for every environment. If the badge is green, the stack works.
- The package sets were resolution-tested on macOS and are built fresh on Linux in CI.

## Honest scope (v1)

- **In:** the pip/conda-installable open core — equilibrium, operating-point analysis, transport, neutronics, data standards.
- **Not in (yet):** registration codes (GENE, TRANSP — licenses forbid redistribution; the [index's access table](https://github.com/fusion-commons/index#getting-access-to-licensed-codes) has the front doors), source-build codes (BOUT++, GACODE — planned as image layers), DAGMC/CAD toolchain (heavy; planned), and **nuclear data files** — several GB with their own terms. For OpenMC, download a library from [openmc.org](https://openmc.org) or [FENDL](https://www-nds.iaea.org/fendl/) and set `OPENMC_CROSS_SECTIONS` (mount it into the container with `-v`).

## Contributing

Additions welcome: one environment change per PR, and CI must stay green — the smoke tests are the contract. By contributing you agree your contribution is licensed under Apache-2.0.

## Support

Free, forever. If the stack saves you time, consider a gift to [The Elephant Sanctuary in Tennessee](https://www.elephants.com/donate), The Fusion Commons' chosen cause.

## License

Apache-2.0 (this repository). Every packaged code keeps its own license — check before you build on them.
