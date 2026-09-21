# PDBsum1 in Docker (PFG Lab)

This fork adds a Docker setup on top of the unchanged upstream
[RomanLas/PDBsum1](https://github.com/RomanLas/PDBsum1) files.

```bash
docker build -t pfglab/pdbsum1:latest .   # once (downloads the wwPDB component dictionary, a few minutes)
./pdbsum1.sh myprotein.pdb                # Linux/macOS  -> results/index.html
.\pdbsum1.ps1 myprotein.pdb               # Windows PowerShell
```

Short user guide for biologists (how to run it on the lab VM):
(LaTeX source alongside).

| File | Purpose |
|---|---|
| `Dockerfile` | Ubuntu 22.04 + PyMOL, ImageMagick, Ghostscript; unpacks upstream tarballs; installs the real `components.cif` |
| `docker/entrypoint.sh` | Starts a virtual display, runs PDBsum1 with relative links, makes help/CSS links portable |
| `docker/hbadd-wrapper.sh` | Works around an upstream `hbadd` segfault on the full modern `components.cif` |
| `pdbsum1.sh`, `pdbsum1.ps1` | Launchers for Linux/macOS and Windows |
| `docker-compose.yml` | Alternative way to run (`docker compose run --rm pdbsum1 file.pdb`) |

Note: upstream ships no licence file — check terms before redistributing the image outside the lab.
