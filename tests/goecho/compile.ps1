$originalLocation = Get-Location
Set-Location -Path $PSScriptRoot

go build "echo.go"

Set-Location -Path $originalLocation.Path