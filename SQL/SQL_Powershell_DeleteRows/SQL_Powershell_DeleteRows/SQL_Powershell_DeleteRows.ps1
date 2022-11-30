# PS Modules requiered: sqlserver
# Tested with SQL server 2014 and PS 5.1
# 

<# 
# To see the month use this query
$srv = "SQLsrv"
$testmonth = -52
$querydate = "Select DATEADD(Month, $testmonth, GETDATE()) as date"
Invoke-Sqlcmd -ServerInstance $srv -Query $querydate

#>

#SQL Server Info
$srv = "SQLsrv"
$DB = "DBNAME

# Log Cleaning after deletion of rows.
$querylog = "DECLARE @DbName VARCHAR(25)
DECLARE @DbLog VARCHAR(25)
SET @DbName = DB_NAME()
SET @DbLog = FILE_NAME(2)
EXEC('ALTER DATABASE ' + @DbName + ' SET RECOVERY SIMPLE')
DBCC SHRINKFILE(@DbLog,2)
"

# Copy from here and past it with a diffirent Table name to Run the loop for a diffirent table after this one is done.
# COPY START

# Name of table where you want to delete rows. 
$table = 'Tablename'

# FilterObject / Rowname
$date = 'nameofRow'


# Target month, end target is $endTarget months before todays date. 

$month = -52
$endTarget = -13

# Start of loop

for($month; $month -le $endTarget; $month ++) {

$Runs = ($month - $endTarget ) * -1

Write-Host "Starting deleting of $table where month is $month from todays month. There are $Runs runs left "}

$query = "Delete from $table where $date < DATEADD(Month, $month, GETDATE())"

Invoke-Sqlcmd -ServerInstance $srv -Database $DB -Query $query

Invoke-Sqlcmd -ServerInstance $srv -Database $DB -Query $querylog

}

Write-host "The script is done for $table" 

# COPY END