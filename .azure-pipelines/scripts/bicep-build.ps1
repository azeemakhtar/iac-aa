# .\.azure-pipelines\scripts\bicep-build.ps1 

$files = Get-ChildItem -Path . -Filter main.bicep -Recurse
foreach ($file in $files) {
    $dir = Split-Path $file.FullName
    Set-Location $dir
    $paramFile = $file.FullName.Replace(".bicep", ".params.json")
    if (Test-Path $paramFile) {
        az bicep build -f $file.FullName --parameters $paramFile
    } else {
        az bicep build -f $file.FullName
    }
}
