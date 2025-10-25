#common Variable



$APPNAME = (Read-Host "Enter the app name").Trim()
$USERACCOUNT = (Read-Host "Enter the user account (or press N for default):").Trim()
if($USERACCOUNT -eq "N") {
    $USERACCOUNT = "TESTSERVER\svctest"
}
$USERPASSWORD = (Read-Host "Enter the user password (or press N for default):").Trim()
if($USERPASSWORD -eq "N") {
    $USERPASSWORD = "xxxxx"
}
$SITEBASEPATH = (Read-Host "Enter the site base path without Space").Trim()

#$appuser = $USERACCOUNT

#$pass = $USERPASSWORD


##Variables for Apppool

# Set the name of the new Application Pool
$appPoolName = $APPNAME

$appPoolIdentity = "SpecificUser"

# Set the custom user and password for the new Application Pool's process model identity
$processModelIdentity = $USERACCOUNT
$processModelIdentityPassword = ConvertTo-SecureString $USERPASSWORD -AsPlainText -Force

#app creation variable

#$appPoolName = "MyAppPool"
$app1 = "$APPNAME"
$app2 = "$app1-API"
$app3 = "$app1-ESIGN"
$app4 = "$app1-ETLAPI"
$app5 = "$app1-PLUGIN"
# Set the variables for the site name, application paths, and user credentials
$siteName = (Read-Host "Enter the Web site name (or press N for default):").Trim()
if($siteName -eq "N") {
    $siteName = "Default Web Site"
}
$appBasePath = "$SITEBASEPATH"
$appNames = @("$app1", "$app2", "$app3", "$app4", "$app5")
#$sitecreationuser = "$USERACCOUNT"
#$sitecreationuserpassword = $USERPASSWORD 

#SessionState

$sqlhostserver = (Read-Host "if it is testserver Enter N:").Trim()
if($sqlhostserver -eq "N") {
    $sqlhostserver = "XXX"
Write-Host $sqlhostserver
}

$sectionPath = "system.web/sessionState"

$sqlConnectionString = "Server=$sqlhostserve;Database=ASPState;Integrated Security=true"


#For VirtualDirectory

# Set the base path variable

# Check if data path exists
$basePathVar = Read-Host "Enter the Virtualdirector Path" force




# Set the base path with a single backslash
$VDbasePath = "$basePathVar`\"

# Set the name of the main folder
$mainFolder = "FS$APPNAME"

# Set the name of the subfolder
$subFolder = "ETLLog"

#Defining header
$headerValue = "$APPNAME"
$headerValue1 = "default-src 'self' 'unsafe-eval' https://test.example.net 'unsafe-inline'; object-src 'self' ;img-src 'self' data:"

#Defining URL Rewrite

$Pattern = "FSVGV4V1SP1VALIDATION/Docs/*"
$URL = "https://$siteName/$APPNAME/viewevidence.aspx?file"

#Defining Export File log path

$Exportlogpath = "$VDbasePath\$mainFolder\$subFolder"
$Exportlogpathsite = "IIS:\Sites\$siteName\$app3"
