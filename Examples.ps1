ConvertTo-RegEx -Text '06/27/17                             PARTICIPANT   ACCOUNTING   SUMMARY                            17:16:54'

#Uses:
# ConvertTo-RegEx.ps1 to convert each line of a file to RegEx
# BaseCollect.txt To set the Collection scriptblock in the Export_RegEX or Export_xx-999(9).csv file
# BaseCSV.txt To set the CSV scriptblock in the Export_RegEX or Export_xx-999(9).csv file
# BaseSQL.txt To set the SQL scriptblock in the Export_RegEX or Export_xx-999(9).csv file
# BaseTXT.txt To set the TXT scriptblock in the Export_RegEX or Export_xx-999(9).csv file
Get-RegExLayout -Folder D:\Powershell\Clients\FD\in -Filter 'mixed*.txt' -SplitReportID -SortRegEx -CSV

#Uses 
# RegEx_Reports.csv to identify the ReportID(s) in a file
# Export_xx-999(9).csv to extract the data in a file based on the RegEx and the output selection(s)
Get-ReportData -Folder D:\Powershell\Clients\FD\in -Filter 'mixed*.txt' -SplitReportID -CSV


Scrape-Report -Folder D:\Powershell\Clients\FD\in -Filter 'mixed*.txt' -SplitReportID -CSV
Scrape-Report -Folder D:\Powershell\Clients\FD\in -Filter 'CD*.txt' -SplitReportID -CSV
