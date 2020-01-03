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

function ConvertTo-RegEx {
<#
.SYNOPSIS
	Short description
.DESCRIPTION
	Long description
.PARAMETER param1
	Param1 Description
.EXAMPLE
	PS> ConvertTo-RegEx
	-> output
.EXAMPLE
	PS> ConvertTo-RegEx param1text
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
		[String]$Text
	)

	Begin {}
	Process {
		$TimerStart = Get-Date

		Write-Debug "Text     : $Text"
		$Alphas = 0
		$Digits = 0
		$SpecC = 0
		$Spaces = 0

		$RegExTextBuffer = "'^"

		for ($x = 0; $x -lt $Text.Length; $x++) {
			Switch -regex ($Text[$x]) {
				'[A-Z]' {
					Write-Debug "Alpha"
					if ($Spaces) {
						Write-Verbose "Spaces: $Spaces"
						$RegExTextBuffer += "\s+"
					}
					$Alphas += 1
					$Spaces = 0
				}
				'[0-9\.]' {
					Write-Debug "Digit"
					if ($Spaces) {
						Write-Verbose "Spaces: $Spaces"
						$RegExTextBuffer += "\s+"
					}
					$Digits += 1
					$Spaces = 0
				}
				'[\-]'  {
					Write-Debug "SpecC"
					if ($Spaces) {
						Write-Verbose "Spaces: $Spaces"
						$RegExTextBuffer += "\s+"
					}
					$SpecC += 1
					$Spaces = 0
				}
				'[\s]'  {
					Write-Debug "Spaces"
					if ($Alphas -and $Digits) {
						Write-Verbose "Alphas & Digits: "
						$Chars = $Alphas+$Digits
						$RegExTextBuffer += "(?<VarX>[A-Z0-9]{$Chars})"
					}
					else {
						if ($Alphas) {
							Write-Verbose "Alphas: $Alphas"
							$RegExTextBuffer += "(?<VarX>[A-Z]{$Alphas})"
						}
						if ($Digits) {
							Write-Verbose "Digits: $Digits"
							$RegExTextBuffer += "(?<VarX>[0-9]{$Digits})"
						}
						if ($SpecC) {
							Write-Verbose "SpecC: $SpecC"
							$RegExTextBuffer += "\-{$SpecC}"
						}
					}
					$Alphas = 0
					$Digits = 0
					$SpecC = 0
					$Spaces += 1
				}
				Default {}
			}
		}
		if ($Alphas -and $Digits) {
			Write-Verbose "Alphas & Digits: "
			$Chars = $Alphas+$Digits
			$RegExTextBuffer += "(?<VarX>[A-Z0-9]{$Chars})"
		}
		else {
			if ($Alphas) {
				Write-Verbose "Alphas: $Alphas"
				$RegExTextBuffer += "(?<VarX>[A-Z]{$Alphas})"
			}
			if ($Digits) {
				Write-Verbose "Digits: $Digits"
				$RegExTextBuffer += "(?<VarX>[0-9]{$Digits})"
			}
			if ($SpecC) {
				Write-Verbose "SpecC: $SpecC"
				$RegExTextBuffer += "\-{$SpecC}"
			}
		}
		Write-Verbose "Chars : $x"
		$RegExTextBuffer += "$'"
		Write-Verbose "Total:  $((Get-Date) - $TimerStart)"
		Return $RegExTextBuffer
	}
	End {}
}