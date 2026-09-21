#!/bin/bash
# Wrapper for the upstream hbadd binary.
# Upstream hbadd segfaults when given the full current wwPDB components.cif
# (~500 MB, 50k entries). It only needs the definitions of the residue types
# that occur in the structure, so hand it a trimmed dictionary containing just
# those. Everything else is passed through unchanged.
REAL=/opt/pdbsum1/exe_linux/hbadd.real
PDB="$1"; CIF="$2"
if [ $# -lt 2 ] || [ ! -r "$PDB" ] || [ ! -r "$CIF" ]; then exec "$REAL" "$@"; fi
shift 2
TMP=$(mktemp /tmp/hbadd_dict.XXXXXX)
trap 'rm -f "$TMP"' EXIT
CODES=$(awk '/^(ATOM  |HETATM)/{c=substr($0,18,3); gsub(/ /,"",c); if(c!="") s[c]=1} END{for(k in s) print k}' "$PDB")
awk -v list="$CODES" 'BEGIN{n=split(list,a,"\n"); for(i=1;i<=n;i++) w["data_" a[i]]=1}
                      /^data_/{p=($1 in w)} p' "$CIF" > "$TMP"
"$REAL" "$PDB" "$TMP" "$@"
