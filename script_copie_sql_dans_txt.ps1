$DirectorySrc = "fichier_sql"
$DirectoryDest = "fichier_txt"

if (-not (Test-Path $DirectoryDest)) {
    New-Item -Path $DirectoryDest -ItemType Directory
}
else{
    Remove-Item -Path $DirectoryDest/*
}

Get-ChildItem $DirectorySrc | ForEach-Object {
    $nom_fichier_temp = $_.Name.Replace(".sql",".txt")
    Copy-Item -Path $DirectorySrc"/"$_ -Destination $DirectoryDest"/"$nom_fichier_temp
}

Write-Host("la copie s'est bien passée")