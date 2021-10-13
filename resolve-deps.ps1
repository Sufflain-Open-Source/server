$Deps = Get-Content -Path "deps.txt"

Invoke-Expression -Command "raco pkg install --skip-installed --auto $Deps"