#!/bin/bash
# PDBsum1 launcher for Linux / macOS.
#   ./pdbsum1.sh myprotein.pdb            single structure (PDB code taken from name)
#   ./pdbsum1.sh myprotein.pdb abcd       single structure with a 4-character code
#   ./pdbsum1.sh -l list.txt              batch (list.txt: one PDB file name per line, files in ./input)
#   ./pdbsum1.sh -help
# Put PDB files in ./input (a file given from elsewhere is copied there). Results: ./results/index.html
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
IMAGE="${PDBSUM1_IMAGE:-pfglab/pdbsum1:latest}"
INPUT="${PDBSUM1_INPUT:-$HERE/input}"
RESULTS="${PDBSUM1_RESULTS:-$HERE/results}"
mkdir -p "$INPUT" "$RESULTS"

ARGS=()
for a in "$@"; do
  if [ -f "$a" ] && [ "$(cd "$(dirname "$a")" && pwd)" != "$(cd "$INPUT" && pwd)" ]; then
    cp "$a" "$INPUT/"; a="$(basename "$a")"
  fi
  ARGS+=("$a")
done

# A lone file whose name (without extension) is exactly 4 letters/digits, e.g. 1ake.pdb, gets that as its PDB code.
# Otherwise PDBsum1 auto-numbers runs a001, a002, ... - give a code yourself as 2nd argument to control this.
if [ "${#ARGS[@]}" -eq 1 ] && [ -f "$INPUT/${ARGS[0]}" ]; then
  stem="${ARGS[0]%%.*}"
  if [[ "$stem" =~ ^[A-Za-z0-9]{4}$ ]] && [[ ! "${ARGS[0]}" =~ ^pdb[A-Za-z0-9]{4}\.(ent|pdb) ]]; then ARGS+=("${stem,,}"); fi
fi

exec docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp \
  -v "$INPUT":/input:ro -v "$RESULTS":/results \
  "$IMAGE" "${ARGS[@]}"
