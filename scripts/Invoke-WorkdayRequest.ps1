<#
.SYNOPSIS
    Sends XML requests to Workday API, with proper authentication and receives XML response.

.DESCRIPTION
    Sends XML requests to Workday API, with proper authentication and receives XML response.

    Used for all communication to Workday in this module and may be used to send
    custom XML requests.

.PARAMETER Request
    The Workday request XML to be sent to Workday.
    See https://community.workday.com/custom/developer/API/index.html for more information.

.PARAMETER Uri
    Endpoint Uri for the request.

.PARAMETER Username
    Username used to authenticate with Workday. If empty, the value stored
    using Set-WorkdayCredential will be used.

.PARAMETER Password
    Password used to authenticate with Workday. If empty, the value stored
    using Set-WorkdayCredential will be used.

.EXAMPLE
    
$response = Invoke-WorkdayRequest -Request '<bsvc:Server_Timestamp_Get xmlns:bsvc="urn:com.workday/bsvc" />' -Uri https://SERVICE.workday.com/ccx/service/TENANT/Human_Resources/v25.1

$response.Server_Timestamp

wd                   version Server_Timestamp_Data        
--                   ------- ---------------------        
urn:com.workday/bsvc v25.1   2015-12-02T12:18:30.841-08:00

.INPUTS
    Workday XML

.OUTPUTS
    Workday XML
#>

function Invoke-WorkdayRequest {
	[CmdletBinding()]
    [OutputType([XML])]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[xml]$Request,
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[string]$Username,
		[string]$Password
	)

    if ([string]::IsNullOrWhiteSpace($Username)) { $Username = $WorkdayConfiguration.Credential.Username }
    if ([string]::IsNullOrWhiteSpace($Password)) { $Password = $WorkdayConfiguration.Credential.GetNetworkCredential().Password }

	$WorkdaySoapEnvelope = [xml] @'
<soapenv:Envelope xmlns:bsvc="urn:com.workday/bsvc" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
    <soapenv:Header>
        <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
            <wsse:UsernameToken>
                <wsse:Username>IntegrationUser@Tenant</wsse:Username>
                <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">Password</wsse:Password>
            </wsse:UsernameToken>
        </wsse:Security>
    </soapenv:Header>
    <soapenv:Body>
         <bsvc:RequestNode xmlns:bsvc="urn:com.workday/bsvc" />
    </soapenv:Body>
</soapenv:Envelope>
'@

	$WorkdaySoapEnvelope.Envelope.Header.Security.UsernameToken.Username = $Username
	$WorkdaySoapEnvelope.Envelope.Header.Security.UsernameToken.Password.InnerText = $Password
	$WorkdaySoapEnvelope.Envelope.Body.InnerXml = $Request.OuterXml

	Write-Debug "Request: $($WorkdaySoapEnvelope.OuterXml)"
	$headers= @{
		'Content-Type' = 'text/xml;charset=UTF-8'
	}
	
	$response = ''
	$responseXML = $null
	try {
		$response = Invoke-RestMethod -Method Post -UseBasicParsing -Uri $Uri -Headers $headers -Body $WorkdaySoapEnvelope
	}
	catch {
		$reader = New-Object System.IO.StreamReader -ArgumentList $_.Exception.Response.GetResponseStream()
		$response = $reader.ReadToEnd()
		$reader.Close()
	}
	if ($response -is [xml]) {
		$responseXML = $response
		$response = $responseXML.OuterXml
	} else {
		$responseXML = [xml]$response
	}
	Write-Debug "Response: $($response)"
	if ([String]::IsNullOrWhiteSpace($response)) {
		Write-Warning 'Empty Response'
	} else {
        
        [xml]$responseXML.Envelope.Body.InnerXml | Write-Output

        if ($responseXML.Envelope.Body.FirstChild.Name -eq 'SOAP-ENV:Fault') {
            Write-Error "$($responseXML.Envelope.Body.Fault.faultcode): $($responseXML.Envelope.Body.Fault.faultstring)"
        }
	}
}
