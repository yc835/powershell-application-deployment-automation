$Sitename = "Default Web Site"
$APPNAME = Read-Host "Enter the site name"
$app1 = "$APPNAME"
$app2 = "$app1-API"
$app3 = "$app1-ESIGN"
$app4 = "$app1-ETLAPI"
$app5 = "$app1-PLUGIN"
$appuser = "TESTSERVER\svctest"
$pass = "xxxx"

$application = @("$app1", "$app2", "$app3", "$app4", "$app5")

#Pass-through
Set-WebConfiguration -Filter "/system.applicationHost/sites/site[@name='$Sitename']/application[@path='/$app1']/virtualDirectory[@path='/']" -Value @{userName= $appuser; password=$pass}
Set-WebConfiguration -Filter "/system.applicationHost/sites/site[@name='$Sitename']/application[@path='/$app2']/virtualDirectory[@path='/']" -Value @{userName= $appuser; password=$pass}
Set-WebConfiguration -Filter "/system.applicationHost/sites/site[@name='$Sitename']/application[@path='/$app3']/virtualDirectory[@path='/']" -Value @{userName= $appuser; password=$pass}
Set-WebConfiguration -Filter "/system.applicationHost/sites/site[@name='$Sitename']/application[@path='/$app4']/virtualDirectory[@path='/']" -Value @{userName= $appuser; password=$pass}
Set-WebConfiguration -Filter "/system.applicationHost/sites/site[@name='$Sitename']/application[@path='/$app5']/virtualDirectory[@path='/']" -Value @{userName= $appuser; password=$pass}


