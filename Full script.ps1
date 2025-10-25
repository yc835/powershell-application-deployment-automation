
Import-Module WebAdministration

$filerecovery = Read-Host "Want to run recoverfile and DB restore (Y/N)"
if ($filerecovery -eq "Y") {

. \AcrocmdVariable
    
acrocmd recover file --loc=$Location --Credentials=$Credential --arc=$arc --target=$target --Exclude=$FS --overwrite=older
$recovered = (Get-ChildItem -Path $target | Measure-Object).Count
$total = (Get-ChildItem -Path $loc | Measure-Object).Count
$percentage = ($recovered / $total) * 100
Write-Host "Recovery Percentage: $percentage%"
$result = acrocmd recover file --loc=$Location --Credentials=$Credential --arc=$arc --target=$target --Exclude=$FS --overwrite=older
if ($result -eq "0") {
    $recovered = (Get-ChildItem -Path $target | Measure-Object).Count
    $total = (Get-ChildItem -Path $loc | Measure-Object).Count
    $percentage = ($recovered / $total) * 100
    Write-Host "Recovery was successful. Recovery Percentage: $percentage%"
} else {
    Write-Host "Recovery failed. Exiting script..."
    break
}


$continue = Read-Host "Do you want to continue? (Yes/No)"
if ($continue -eq "No") {
    Write-Host "Exiting script..."
    break
}

. \DBVariable.ps1

# Automatically search for the data file
$mdfFile = (Get-ChildItem -Path $dataPath -Filter "*.mdf").Name
$ldfFile = (Get-ChildItem -Path $dataPath -Filter "*.ldf").Name

# Automatically search for the filestream files
$attachmentFile = (Get-ChildItem -Path $filestreamPath -Filter "Attachment").Name
$fsFile = (Get-ChildItem -Path $filestreamPath -Filter "FileSystem").Name




# Build the query string
$query = "USE [master]
GO
CREATE DATABASE [$DBNAME] ON
( FILENAME = N'$dataPath$mdfFile' ),
( FILENAME = N'$dataPath$ldfFile' ),
FILEGROUP [FileStreamGroup] CONTAINS FILESTREAM DEFAULT
( NAME = N'VG_Attachment', FILENAME = N'$filestreamPath$attachmentFile' ),
( NAME = N'VG_FS_FG', FILENAME = N'$filestreamPath$fsFile' )
FOR ATTACH
GO"


# Execute the query
Invoke-Sqlcmd -Query $query

$output = Invoke-Sqlcmd -Query $query -ServerInstance $sqlhostserver -Username $USERACCOUNT -Password $USERPASSWORD
if ($output.Error -eq $null) {
    Write-Host "Database $DBNAME created successfully."
} else {
    Write-Host "Error creating database $DBNAME $($output.Error)"
    break
}


} else {
Write-Host "Skipping DB attach"
}

$continue = Read-Host "Do you want to continue? (Yes/No)"
if ($continue -eq "No") {
    Write-Host "Exiting script..."
    break
}

. \variables.ps1

# Create the new Application Pool
New-Item -Path IIS:\AppPools\$appPoolName

#PipelineMode Select
Import-Module WebAdministration

#Prompt the user to enter pipeline mode
$pipelineMode = (Read-Host "Enter pipeline mode (I for Integrated/C for Classic)").Trim()

switch ($pipelineMode) {
    "I" { $pipelineMode = "Integrated" }
    "C" { $pipelineMode = "Classic" }
}


Set-ItemProperty -Path IIS:\AppPools\$appPoolName -Name "managedPipelineMode" -Value $pipelineMode


#Load user Profile True

$appPool = Get-Item "IIS:\AppPools\$appPoolName"
$appPool.processModel.loadUserProfile = $true
$appPool | Set-Item



#Script for Apppool

# Set the queue length for the new Application Pool
Set-ItemProperty -Path IIS:\AppPools\$appPoolName -Name queueLength -Value 10000
# Set the identity for the new Application Pool 
Set-ItemProperty -Path IIS:\AppPools\$appPoolName -Name "processModel.identityType" -Value $appPoolIdentity
# Set the managed pipeline mode for the new Application Pool
Set-ItemProperty -Path IIS:\AppPools\$appPoolName -Name "managedPipelineMode" -Value $pipelineMode
# Set the custom user and password for the new Application Pool's process model identity
Set-ItemProperty -Path IIS:\AppPools\$appPoolName -Name "processModel.userName" -Value $processModelIdentity
Set-ItemProperty -Path IIS:\AppPools\$appPoolName -Name "processModel.password" -Value $processModelIdentityPassword
Set-ItemProperty -Path IIS:\AppPools\$appPoolName -Name "processModel.identityType" -Value "SpecificUser"


# Loop through the application names and add the applications
foreach ($appName in $appNames) {
    # Create the variable for the full directory path
    $appDir = "$appBasePath\$appName"
    # Create the application and set the path
    New-WebApplication -Name $appName -Site $siteName -PhysicalPath $appDir -ApplicationPool "$appPoolName"

    # Set the pass-through authentication for the application

 Start-Process powershell.exe -ArgumentList "-File `". \account pass`"" -NoNewWindow
   



}

   
        
   

# Check if main folder already exists and create it if it doesn't
if (!(Test-Path "$VDbasePath\$mainFolder")) {
    New-Item -ItemType Directory -Path "$VDbasePath$mainFolder"
}

# Check if subfolder already exists and create it if it doesn't
if (!(Test-Path "$VDbasePath\$mainFolder\$subFolder")) {
    New-Item -ItemType Directory -Path "$VDbasePath\$mainFolder\$subFolder"
}
# Create a file share for the main folder
if (!(Test-Path "$mainFolder")) {
    New-SmbShare -Name "$mainFolder" -Path "$VDbasePath$mainFolder"
}
 
#VD add

$virtualDirectoryPath = "IIS:\Sites\$siteName\$app1\$mainFolder"
New-Item $virtualDirectoryPath -type VirtualDirectory -physicalPath $VDbasePath\$mainFolder -force 
Set-ItemProperty $virtualDirectoryPath -Name userName -Value $USERACCOUNT
Set-ItemProperty $virtualDirectoryPath -Name password -Value $USERPASSWORD

#Http Response Header

$headername = "Access-Control-Allow-Origin"
Set-WebConfigurationProperty `
    -Filter "system.webServer/httpProtocol/customHeaders" `
    -PSPath "IIS:\Sites\$sitename\$application" -Name . `
    -AtElement @{name=$headerName} `
    -Value @{name=$headerName;value=$headerValue}


$headername1 = "Content-Security-Policy"
Set-WebConfigurationProperty `
    -Filter "system.webServer/httpProtocol/customHeaders" `
    -PSPath "IIS:\Sites\$sitename\$application" -Name . `
    -AtElement @{name=$headerName1} `
    -Value @{name=$headerName1;value=$headerValue1}

#URL Rewrite

#URL Rewrite

$site = "iis:\sites\$siteName\$APPNAME"
set-WebConfigurationProperty -pspath $site -filter "system.webserver/rewrite/rules" -name "." -value @{name='FS-VGV4V1SP1'; patternSyntax='ECMAScript'; stopProcessing='True'}
Set-WebConfigurationProperty -pspath $site -filter "system.webserver/rewrite/rules/rule[@name='FS-VGV4V1SP1']/match" -name "url" -value "$Pattern"
Set-WebConfigurationProperty -pspath $site -filter "system.webServer/rewrite/rules/rule[@name='FS-VGV4V1SP1']/action" -name "type" -value "Redirect"
Set-WebConfigurationProperty -pspath $site -filter "system.webServer/rewrite/rules/rule[@name='FS-VGV4V1SP1']/action" -name "url" -value "$URL"
Set-WebConfigurationProperty -pspath $site -filter "system.webServer/rewrite/rules/rule[@name='FS-VGV4V1SP1']/action" -name "appendQueryString" -value "false"


#SSL Certificate

Set-WebConfiguration -Location "IIS:\Sites\$siteName\$appName" -Filter 'system.webserver/security/access' -Value "Ssl,SslNegotiateCert"

#Export File Log path

Set-WebConfigurationProperty -pspath "$Exportlogpathsite" -filter "appSettings/add[@key='ExportlogFilePath']" -name "value" -value "$Exportlogpath"



#creating session state

Set-WebConfigurationProperty -Filter $sectionPath -Name "sqlConnectionString" -Value $sqlConnectionString -PSPath IIS:\Sites\$siteName\$app1