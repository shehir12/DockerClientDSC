<#
.Synopsis
   Execute generated DSC configuration against specified host.
.DESCRIPTION
   This script is used to enact the generated DSC configuration
   on the specified host. It collects the "root" user's credential and
   initates a CIM session. Upon completion, the CIM session is removed.
.PARAMETER $Hostname
   The node on which the Docker configuration should be enacted.
.EXAMPLE
   .\RunDockerClientConfig.ps1 -Hostname "mgmt01.contoso.com"
.NOTES
   Ensure that the DockerClient.ps1 DSC configuration has been
   executed and a subsequent .mof file has been generated prior to
   running this script.
#>

param
(
    $Hostname
)

$cred = Get-Credential -UserName "root" -Message "Enter password"
$options = New-CimSessionOption -UseSsl -SkipCACheck -SkipCNCheck -SkipRevocationCheck
$session = New-CimSession -Credential $cred -ComputerName $Hostname -Port 5986 -Authentication basic -SessionOption $option
Start-DscConfiguration -CimSession $session -Path .\DockerClient -Verbose -Wait
$session | Remove-CimSession