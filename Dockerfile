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

COPY --chown=$MAMBA_USER:$MAMBA_USER bin/fus /usr/local/bin/fus
COPY --chown=$MAMBA_USER:$MAMBA_USER tests/ /opt/stack/tests/

WORKDIR /work
EXPOSE 8888
ENTRYPOINT []
CMD ["fus", "lab"]
