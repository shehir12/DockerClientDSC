$OFS = [Environment]::Newline
$get = Get-Content "DockerInstallation\getDockerClient.txt"
$set = Get-Content "DockerInstallation\setDockerClient.txt"
$test = Get-Content "DockerInstallation\testDockerClient.txt"

Configuration DockerClient
{

<#
.Synopsis
   Generate a configuration for Docker installation on Ubuntu
.DESCRIPTION
   This configuration ensures that the required components for Docker
   are installed on a specified node.
.PARAMETER Hostname
   The node on which the Docker configuration should be enacted.
.EXAMPLE
   . .\DockerClient.ps1
   DockerClient -Hostname mgmt01.contoso.com
.NOTES
   Ensure that both the OMI and DSC Linux Resource Provider source have been compiled
   and installed on the specified node. Instructions for doing so can be found here:
   https://github.com/MSFTOSSMgmt/WPSDSCLinux.

   Author: Andrew Weiss | Microsoft
#>

    param
    (
        $Hostname
    )
    Import-DscResource -Module nx
    Node $Hostname
    {
        nxScript DockerInstallation
        {
            GetScript = "$get"
            SetScript = "$set"
            TestScript = "$test"
        }
    }
}