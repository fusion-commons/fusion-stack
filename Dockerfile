# The Fusion Commons — fusion-stack
# One container, the open-source fusion toolchain, ready in one command:
#   docker run -it --rm -p 8888:8888 -v "$PWD":/work ghcr.io/fusion-commons/fusion-stack
#
# Tools live in three conda environments (they have mutually incompatible
# dependency pins — see envs/*.yml), driven by the `fus` launcher:
#   fus core       python ...   # equilibrium & analysis (FreeGS, PlasmaPy, ...)
#   fus transport  python ...   # TORAX + cfspopcon (NumPy 2 stack)
#   fus neutronics python ...   # OpenMC
#   fus lab                     # JupyterLab in the core environment

FROM mambaorg/micromamba:2.0.5

COPY --chown=$MAMBA_USER:$MAMBA_USER envs/ /opt/stack/envs/
RUN micromamba create -y -f /opt/stack/envs/core.yml && \
    micromamba create -y -f /opt/stack/envs/transport.yml && \
    micromamba create -y -f /opt/stack/envs/neutronics.yml && \
    micromamba clean --all --yes

# Patch a FreeGS 0.8.2 bug: in critical.find_critical the Jacobian entry J[1,0]
# is missing the [0][0] scalar extraction the other three entries have, so a
# (1,1) spline result lands in a scalar slot and raises "setting an array element
# with a sequence" whenever a critical point's Newton refinement runs (numerics-
# dependent, so it surfaces in CI but not always locally). Add the missing [0][0];
# the trailing grep makes the build fail loudly if the line ever stops matching.
RUN set -e; patched=0; \
    for f in /opt/conda/envs/core/lib/python*/site-packages/freegs/critical.py; do \
      [ -f "$f" ] || continue; \
      sed -i 's/f(R1, Z1, dx=2) \/ R1/f(R1, Z1, dx=2)[0][0] \/ R1/' "$f"; \
      grep -q 'f(R1, Z1, dx=2)\[0\]\[0\] / R1' "$f"; \
      patched=1; \
    done; \
    [ "$patched" = 1 ]

COPY --chown=$MAMBA_USER:$MAMBA_USER bin/fus /usr/local/bin/fus
COPY --chown=$MAMBA_USER:$MAMBA_USER tests/ /opt/stack/tests/

WORKDIR /work
EXPOSE 8888
ENTRYPOINT []
CMD ["fus", "lab"]
