$originalLocation = Get-Location
Set-Location -Path $PSScriptRoot

javac "Echo.java"
jar cfM "Echo.jar" "Echo.class"

Set-Location -Path $originalLocation.Path