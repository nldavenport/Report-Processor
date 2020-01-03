<#
.NOTES
Author: Nathan Davenport
Date  : yyyy/mm/dd

Copyright © 1984-  DRock Development. IslandBoy Holdings. All rights reserved.
Free for all users, as long as this header is included

.SYNOPSIS
Script is an assortment of ...
.DESCRIPTION
The Script module of cmdlets is a group of tools to ...
#>

function Get-ReportData {
<#
.SYNOPSIS
	Short description
.DESCRIPTION
	Long description
.PARAMETER param1
	Param1 Description
.EXAMPLE
	PS> Get-ReportData
	-> output
.EXAMPLE
	PS> Get-ReportData param1text
	-> output
.OUTPUTS
	Output from this cmdlet (if any)
.NOTES
	General notes
#>

	[CmdletBinding()]
	[Alias()]
	[OutputType([int])]
	Param (
		[String]$Folder = "$env:HOMEPATH\Documents\Powershell\Clients\FD\In",
		[String]$Filter = "*.TXT",
		[String]$RegExCSV = "$env:HOMEPATH\Documents\WindowsPowershell\Modules\FDUtils\RegEx_Reports.csv",
		[Switch]$SplitReportID,
		[Switch]$SplitClientID,
		[Switch]$SplitPages,
		[Switch]$CSV,
		[Switch]$XLS,
		[Switch]$SQL,
		[Switch]$TXT
	)

	Begin {}
	Process {
		$TimerStart = Get-Date

#region RegEx Definitions
		$RegExVariables = [regex]'\<(?<variable>[a-zA-Z]+)\>'
		$RegExTable = Import-Csv $RegExCSV -Delimiter ','
#		$RegExTable = (Import-Csv $RegExCSV -Delimiter ',' | Where-Object {$_.Type -eq 'CD-021'})
#endregion

#Get Folder Contents
		$Files = Get-ChildItem $Folder -File -Filter $Filter
		$ReportID = $null

# Scan each file
		Foreach ($File in $Files) {
			Write-Verbose "File     : $File"
			$Report = @()
			$Content = Get-Content (Join-Path $Folder $File)

# Scan each line
			foreach ($Line in $Content) {
				Write-Debug "Line     : $Line"
				$Record = @()

# Against each Regular Expression in a table
				for ($i=0; $i -lt $RegExTable.Count; $i++) {
					Write-Debug "RegEx    : $($RegExTable[$i].RegEx)"
					$Variables = ($RegExVariables).Matches($RegExTable[$i].RegEx)
					Write-Debug "Variables: $Variables"

# If Match is found prepare to gather all values in the string
					if ($Line -match ($RegExTable[$i].RegEx).Trim("'")) {
						Write-Debug "Matches  : $($RegExTable[$i].RegEx)"
						$Values = New-Object System.Collections.Generic.List[object]

# Gather all values in the string
						for ($j=0; $j -lt $Variables.Count; $j++) {
							$Values.Add(($Variables[$j].Groups[1].Value,$Matches.($Variables[$j].Groups[1].Value)))
							Write-Verbose "Values   : $($Values[$j][0] + "`t" + $Values[$j][1])"

# If one of the values is related to the ReportID then get Report specific details to validate
							if ($Values[$j][0] -eq 'ReportID') {
# Split Reports
								if ($SplitReportID) {
									if ($ReportID -ne $null) {
										$OutFile = $env:HOMEPATH + '\' + $ReportID + '_' + ((Get-Date).ToString('yyyyMMddhhmmss'))
										if ($CSV) {
											$Collectblock.invoke()
											$CSVblock.invoke()
											$CSVFile =  $OutFile + '.csv'
											Write-Host $CSVFile
											$Report | Export-Csv -path $CSVfile -NoTypeInformation
											$Report = @()
										}
# Write Reportbuffer to new file
#										if ($ReportID -ne $Values[$j][1]) {
										if ($TXT) {
											$TXTblock.invoke()
										}
#										}
									}
									$ReportID = $Values[$j][1]
									Write-Debug "ReportID : $ReportID"
									$ExportCSV = (Split-Path $RegExCSV -Parent) + '\Export_' + $ReportID + '.csv'
									Write-Debug "ExportCSV: $ExportCSV"
									$ExportTable = Import-Csv $ExportCSV -Delimiter ","

# Load Script blocks for the specific report
									for ($e=0; $e -lt $ExportTable.Count; $e++) {
										Switch ($ExportTable[$e].Type) {
											'Collect' { Write-Debug 'Collect'; $Collectblock = [Scriptblock]::Create($ExportTable[$e].Scriptblock); break }
											'CSV' { Write-Debug 'CSV'; $CSVblock = [Scriptblock]::Create($ExportTable[$e].Scriptblock); break }
											'SQL' { Write-Debug 'SQL'; $SQLblock = [Scriptblock]::Create($ExportTable[$e].Scriptblock); break }
											'TXT' { Write-Debug 'TXT'; $TXTblock = [Scriptblock]::Create($ExportTable[$e].Scriptblock); break }
											Default {}
										}
									}
								}
								else {
									$OutFile = $env:HOMEPATH + '\' + $Values[$j][1] + '_' + ((Get-Date).ToString('yyyyMMddhhmmss'))
								}
								$ReportID = $Values[$j][1]
								Write-Debug "ReportID : $ReportID"
							}
# Use the collect script block to gather all of the data names & values
							$Collectblock.invoke()
							$CSVblock.invoke()
							if ($SQL) {
								if (($ReportID -ne $null) -and ($ReportDt -ne $null)) {
									$SQLblock.invoke()
								}
							}
						}
						$Record += $Values
						break
					}
				}
				$Reportbuffer += $Line + '`r`n'
			}
# Split Reports
			if ($SplitReportID) {
				$OutFile = $env:HOMEPATH + '\' + $ReportID + '_' + ((Get-Date).ToString('yyyyMMddhhmmss'))
			}
			else {
				$OutFile = $env:HOMEPATH + '\Report_' + ((Get-Date).ToString('yyyyMMddhhmmss'))
			}
# Export data to CSV file
			if ($CSV) {
				$CSVblock.invoke()
				$CSVFile =  $OutFile + '.csv'
				Write-Host $CSVFile
				$Report | Export-Csv -path $CSVfile -NoTypeInformation
			}
# Dump broken out report to separate file
			if ($TXT) {
				$TXTblock.invoke()
			}
# Reset ReportID for next file run
			$ReportID = $null
			Write-Verbose "File:  $((Get-Date) - $TimerStart)"
		}
		Write-Verbose "Total:  $((Get-Date) - $TimerStart)"
	}
	End {}
}