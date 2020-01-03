﻿<#
.NOTES
	Author: Nathan Davenport
	Date  : yyyy/mm/dd

	Copyright © 1984-  DRock Development. All rights reserved.
	Free for all users, as long as this header is included

.SYNOPSIS
	Module Manifest
.DESCRIPTION
	Module Manifest for utilities - defines all scripts related to file processing
#>

@{                      
    ModuleVersion     = '1.0.0.0'
#    GUID              = ''
    Author            = 'Nathan Davenport'
    CompanyName       = 'IslandBoy Holdings - DRock Development'
    Copyright         = '© DRock Development 2009. All rights reserved.'
    Description       = 'Module Manifest for BingR - defines all BingR scripts'

    PowerShellVersion = '3.0'

    NestedModules     = 'Scrape-Report.ps1',
			'Get-RegExLayout.ps1',
			'Get-ReportData.ps1'
}