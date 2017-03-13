@{
RootModule = 'WorkdayApi.psm1'
ModuleVersion = '1.0.0'
GUID = 'bd4390dc-a8ad-4bce-8d69-f53ccf8e4163'
Author = 'Nathan Hartley'
CompanyName = 'Peckham, Inc.'
Copyright = '(c) 2015 . All rights reserved.'
Description = 'Provides a means to access the Workday SOAP API in a Powershell friendly manor.'
PowerShellVersion = '3.0'
FunctionsToExport = @(
		'Export-WorkdayDocument',
        'Invoke-WorkdayRequest',
		'Get-WorkdayReport',
		'Get-WorkdayWorker',
        'Remove-WorkdayConfiguration',
		'Set-WorkdayWorkerPhoto',

        'Get-WorkdayEndpoint',
        'Set-WorkdayCredential',
        'Set-WorkdayEndpoint',
        'Save-WorkdayConfiguration'

        'Get-WorkdayWorkerPhone',
		'Set-WorkdayWorkerPhone',
        'Update-WorkdayWorkerPhone',

        'Get-WorkdayWorkerEmail',
		'Set-WorkdayWorkerEmail',
        'Update-WorkdayWorkerEmail'

        'Get-WorkdayWorkerDocument',
        'Set-WorkdayWorkerDocument',

        'Start-WorkdayIntegration',
        'Get-WorkdayIntegrationEvent'

	)
# VariablesToExport = '*'
# AliasesToExport = '*'
# PrivateData = ''
}

