# Variables for the DB file paths

$DBNAME = "$APPNAME"
#$dataPath = (Read-Host "Enter the DB base path without Space").Trim()
#$filestreamPath = (Read-Host "Enter the DB Filestreem base path without Space").Trim()

#DB ldf & mdf path
$dataPath = (Read-Host "Enter the DB base path for (mdf & ldf) without Space (or press N for Skipping)").Trim()

#DBFILESTEEM PATH
$filestreamPath = (Read-Host "Enter the DB base path for (FILESTREEM) without Space (or press N for Skipping)").Trim()


