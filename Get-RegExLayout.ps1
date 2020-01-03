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

function Get-RegExLayout {
<#
.SYNOPSIS
	Short description
.DESCRIPTION
	Long description
.PARAMETER param1
	Param1 Description
.EXAMPLE
	PS> Get-RegExLayout
	-> output
.EXAMPLE
	PS> Get-RegExLayout param1text
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
		[Switch]$SortRegEx,
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
		$RegExTable = Import-Csv $RegExCSV -Delimiter ","
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
									if ($Report -ne $null){
										$OutFile = $env:HOMEPATH + "\Export_" + $ReportID
# Export data to CSV file
										if ($CSV) {
											$CSVFile =  $OutFile + ".csv"
											Write-Host $CSVFile
# Pre-load Common scriptblocks
											$obj = New-Object System.Object
											$obj | Add-Member -type NoteProperty -name Dup -value '=IF(D2=D1,TRUE,FALSE)'
											$obj | Add-Member -type NoteProperty -name Type -value 'Collect'
											$obj | Add-Member -type NoteProperty -name Scriptblock -value (Get-Content (Join-Path (Split-Path $RegExCSV) 'BaseCollect.txt') -Raw)
											$obj | Add-Member -type NoteProperty -name RegEx -value ''
											$obj | Add-Member -type NoteProperty -name Example -value ''
											$Report += $obj

											$obj = New-Object System.Object
											$obj | Add-Member -type NoteProperty -name Dup -value '=IF(D2=D1,TRUE,FALSE)'
											$obj | Add-Member -type NoteProperty -name Type -value 'CSV'
											$obj | Add-Member -type NoteProperty -name Scriptblock -value (Get-Content (Join-Path (Split-Path $RegExCSV) 'BaseCSV.txt') -Raw)
											$obj | Add-Member -type NoteProperty -name RegEx -value ''
											$obj | Add-Member -type NoteProperty -name Example -value ''
											$Report += $obj

											$obj = New-Object System.Object
											$obj | Add-Member -type NoteProperty -name Dup -value '=IF(D2=D1,TRUE,FALSE)'
											$obj | Add-Member -type NoteProperty -name Type -value 'SQL'
											$obj | Add-Member -type NoteProperty -name Scriptblock -value (Get-Content (Join-Path (Split-Path $RegExCSV) 'BaseSQL.txt') -Raw)
											$obj | Add-Member -type NoteProperty -name RegEx -value ''
											$obj | Add-Member -type NoteProperty -name Example -value ''
											$Report += $obj

											$obj = New-Object System.Object
											$obj | Add-Member -type NoteProperty -name Dup -value '=IF(D2=D1,TRUE,FALSE)'
											$obj | Add-Member -type NoteProperty -name Type -value 'TXT'
											$obj | Add-Member -type NoteProperty -name Scriptblock -value (Get-Content (Join-Path (Split-Path $RegExCSV) 'BaseTXT.txt') -Raw)
											$obj | Add-Member -type NoteProperty -name RegEx -value ''
											$obj | Add-Member -type NoteProperty -name Example -value ''
											$Report += $obj
											if ($SortRegEx) {
												$Report | Sort-Object -Property RegEx, Type | Export-Csv -path $CSVfile -NoTypeInformation
											}
											else {
												$Report | Export-Csv -path $CSVfile -NoTypeInformation
											}
											$Report = @()
										}
									}
								}
								else {
									$OutFile = $env:HOMEPATH + "\Export_RegEx"
								}
								$ReportID = $Values[$j][1]
								Write-Debug "ReportID : $ReportID"
							}
						}
					}
				}

				if ($CSV) {
# Add RegEx line to Report Object
					$obj = New-Object System.Object
					$obj | Add-Member -type NoteProperty -name Dup -value '=IF(D2=D1,TRUE,FALSE)'
					$obj | Add-Member -type NoteProperty -name Type -value $ReportID
					$obj | Add-Member -type NoteProperty -name Scriptblock -value ''
# Get Regular Expression Layout
					$obj | Add-Member -type NoteProperty -name RegEx -value (ConvertTo-RegEx $Line)
					$obj | Add-Member -type NoteProperty -name Example -value $Line
					$Report += $obj
				}
			}
# Split Reports
			if ($SplitReportID) {
				$OutFile = $env:HOMEPATH + "\Export_" + $ReportID
			}
			else {
				$OutFile = $env:HOMEPATH + "\Export_RegEx"
			}
# Export data to CSV file
			if ($CSV) {
				$CSVFile =  $OutFile + ".csv"
				Write-Host $CSVFile
# Pre-load Common scriptblocks
				$obj = New-Object System.Object
				$obj | Add-Member -type NoteProperty -name Dup -value '=IF(D2=D1,TRUE,FALSE)'
				$obj | Add-Member -type NoteProperty -name Type -value 'Collect'
				$obj | Add-Member -type NoteProperty -name Scriptblock -value (Get-Content (Join-Path (Split-Path $RegExCSV) 'BaseCollect.txt') -Raw)
				$obj | Add-Member -type NoteProperty -name RegEx -value ''
				$obj | Add-Member -type NoteProperty -name Example -value ''
				$Report += $obj

				$obj = New-Object System.Object
				$obj | Add-Member -type NoteProperty -name Dup -value '=IF(D2=D1,TRUE,FALSE)'
				$obj | Add-Member -type NoteProperty -name Type -value 'CSV'
				$obj | Add-Member -type NoteProperty -name Scriptblock -value (Get-Content (Join-Path (Split-Path $RegExCSV) 'BaseCSV.txt') -Raw)
				$obj | Add-Member -type NoteProperty -name RegEx -value ''
				$obj | Add-Member -type NoteProperty -name Example -value ''
				$Report += $obj

				$obj = New-Object System.Object
				$obj | Add-Member -type NoteProperty -name Dup -value '=IF(D2=D1,TRUE,FALSE)'
				$obj | Add-Member -type NoteProperty -name Type -value 'SQL'
				$obj | Add-Member -type NoteProperty -name Scriptblock -value (Get-Content (Join-Path (Split-Path $RegExCSV) 'BaseSQL.txt') -Raw)
				$obj | Add-Member -type NoteProperty -name RegEx -value ''
				$obj | Add-Member -type NoteProperty -name Example -value ''
				$Report += $obj

				$obj = New-Object System.Object
				$obj | Add-Member -type NoteProperty -name Dup -value '=IF(D2=D1,TRUE,FALSE)'
				$obj | Add-Member -type NoteProperty -name Type -value 'TXT'
				$obj | Add-Member -type NoteProperty -name Scriptblock -value (Get-Content (Join-Path (Split-Path $RegExCSV) 'BaseTXT.txt') -Raw)
				$obj | Add-Member -type NoteProperty -name RegEx -value ''
				$obj | Add-Member -type NoteProperty -name Example -value ''
				$Report += $obj
				if ($SortRegEx) {
					$Report | Sort-Object -Property RegEx, Type | Export-Csv -path $CSVfile -NoTypeInformation
				}
				else {
					$Report | Export-Csv -path $CSVfile -NoTypeInformation
				}
			}
# Reset ReportID for next file run
			$ReportID = $null
			$Report = @()
			Write-Verbose "File:  $((Get-Date) - $TimerStart)"
		}
		Write-Verbose "Total:  $((Get-Date) - $TimerStart)"
	}
	End {}
}