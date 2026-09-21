# PDBsum1 (standalone PDBsum Generate) — PFG Lab container
# Build from the repository root:  docker build -t pfglab/pdbsum1:latest .
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates wget imagemagick ghostscript pymol xvfb xauth csh \
        libgfortran5 file \
    && rm -rf /var/lib/apt/lists/*

# ImageMagick 6 blocks PostScript/PDF by default; PDBsum1 needs them.
RUN sed -i -E 's#<policy domain="coder" rights="none" pattern="(PS|PS2|PS3|EPS|PDF|XPS)" />#<policy domain="coder" rights="read|write" pattern="\1" />#' \
        /etc/ImageMagick-6/policy.xml

# Unpack the upstream distribution (only the Linux executables are needed).
WORKDIR /opt
COPY pdbsum1.tar.gz data.tar.gz docs.tar.gz exe_linux.tar.gz /tmp/dist/
RUN for f in /tmp/dist/*.tar.gz; do tar xzf "$f" -C /opt; done && rm -rf /tmp/dist \
    && chmod -R a+rX /opt/pdbsum1 && chmod a+x /opt/pdbsum1/exe_linux/*

# The tarball ships a one-molecule dummy components.cif; replace it with the
# real wwPDB Chemical Component Dictionary (needed by LIGPLOT).
RUN wget -q -O /tmp/components.cif.gz https://files.wwpdb.org/pub/pdb/data/monomers/components.cif.gz \
    && gunzip -c /tmp/components.cif.gz > /opt/pdbsum1/data/components.cif \
    && rm /tmp/components.cif.gz

# Point the parameter file at the container paths.
RUN cp /opt/pdbsum1/params/CATHPARAM_linux /opt/pdbsum1/params/CATHPARAM \
    && sed -i -E \
        -e 's#^(PDBSUM1_DIR\s*=).*#\1 /opt/pdbsum1#' \
        -e 's#^(PDBSUM1_RESULTS_DIR\s*=).*#\1 /results#' \
        /opt/pdbsum1/params/CATHPARAM

# hbadd crashes on the full modern components.cif; see docker/hbadd-wrapper.sh
RUN mv /opt/pdbsum1/exe_linux/hbadd /opt/pdbsum1/exe_linux/hbadd.real
COPY docker/hbadd-wrapper.sh /opt/pdbsum1/exe_linux/hbadd
RUN chmod +x /opt/pdbsum1/exe_linux/hbadd

COPY docker/entrypoint.sh /usr/local/bin/pdbsum1-entrypoint
RUN chmod +x /usr/local/bin/pdbsum1-entrypoint && mkdir -p /results /input

ENV CATHPARAM=/opt/pdbsum1/params/CATHPARAM
VOLUME ["/results"]
WORKDIR /input
ENTRYPOINT ["pdbsum1-entrypoint"]
CMD ["-help"]
