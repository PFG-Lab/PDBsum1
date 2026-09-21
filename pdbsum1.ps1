# PDBsum1 launcher for Windows (PowerShell, Docker Desktop must be running).
#   .\pdbsum1.ps1 myprotein.pdb
#   .\pdbsum1.ps1 myprotein.pdb abcd
#   .\pdbsum1.ps1 -l list.txt
# Put PDB files in .\input (a file given from elsewhere is copied there). Results: .\results\index.html
$here    = Split-Path -Parent $MyInvocation.MyCommand.Path
$image   = if ($env:PDBSUM1_IMAGE) { $env:PDBSUM1_IMAGE } else { "pfglab/pdbsum1:latest" }
$input   = Join-Path $here "input"
$results = Join-Path $here "results"
New-Item -ItemType Directory -Force $input, $results | Out-Null

$argList = @()
foreach ($a in $args) {
    if (Test-Path -PathType Leaf $a) {
        $full = (Resolve-Path $a).Path
        if ((Split-Path -Parent $full) -ne (Resolve-Path $input).Path) { Copy-Item $full $input -Force }
        $a = Split-Path -Leaf $full
    }
    $argList += $a
}
if ($argList.Count -eq 1 -and (Test-Path -PathType Leaf (Join-Path $input $argList[0]))) {
    $stem = ($argList[0] -split '\.')[0]
    if ($stem -match '^[A-Za-z0-9]{4}$') { $argList += $stem.ToLower() }
}
docker run --rm -v "${input}:/input:ro" -v "${results}:/results" $image @argList
