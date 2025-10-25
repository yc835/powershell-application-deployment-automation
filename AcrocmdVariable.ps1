#Acrocmd Variable

. \cridential.ps1


$CInput = Read-Host "Enter the name of the Credential you want to import (US or EU or AP)"
$Credential = Get-Variable -Name $CInput -ValueOnly
Write-Output $Credential

#Location
$locInput = Read-Host "Enter the name of the Location you want to import "
$Location = Get-Variable -Name $locInput -ValueOnly
Write-Output $Location

#Arc
$arcInput = "arc" + $locInput
$arc = Get-Variable -Name $arcInput -ValueOnly
Write-Output $arc

#Exclude
$FSInput = "FS" + $locInput
$FS = Get-Variable -Name $FSInput -ValueOnly
Write-Output $FS

#target
$target = Read-Host "Enter the name of the target you want "

