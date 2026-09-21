#!/bin/bash
# Runs PDBsum1 under a virtual display (PyMOL needs one) with relative links,
# so the /results folder can be opened from the host with any browser.
# Xvfb is started explicitly (xvfb-run hangs when it is container PID 1).
mkdir -p /results
if [ "$1" = "shell" ]; then exec /bin/bash; fi

case " $* " in
  *" -help "*|*" -relinks "*) EXTRA="" ;;
  *) EXTRA="-relinks" ;;
esac

Xvfb :99 -screen 0 1280x1024x24 -nolisten tcp >/dev/null 2>&1 &
XVFB=$!
export DISPLAY=:99
for _ in $(seq 1 50); do [ -e /tmp/.X11-unix/X99 ] && break; sleep 0.2; done

/opt/pdbsum1/exe_linux/pdbsum1 "$@" $EXTRA
RC=$?
kill $XVFB 2>/dev/null

# Make the built-in help pages work outside the container: ship the docs next to
# the results and point the absolute file:///opt/... links at them.
if [ -d /results/ak ] || [ -f /results/index.html ]; then
  [ -d /results/docs ] || cp -r /opt/pdbsum1/docs /results/docs 2>/dev/null
  grep -rlF 'file:///opt/pdbsum1/' --include='*.html' /results 2>/dev/null | while read -r f; do
    d=$(dirname "$f")
    rel=$(realpath --relative-to="$d" /results/docs)
    css=$(realpath --relative-to="$d" /results/css)
    sed -i -e "s#file:///opt/pdbsum1/docs/#$rel/#g" -e "s#file:///opt/pdbsum1/templates/css/#$css/#g" "$f"
  done
fi
exit $RC
