#Requires -Version 4.0

if (Test-Path "$PSScriptRoot\DockerClient") {
    Remove-Item -Recurse "$PSScriptRoot\DockerClient"
}


Configuration DockerClient
{

<#
.Synopsis
   Generate a configuration for Docker installation on Ubuntu
.DESCRIPTION
   This configuration ensures that the required components for Docker
   are installed on a specified node. A specified image can also be installed.
.PARAMETER Hostname
   The node on which the Docker configuration should be enacted. Use the built-in
   ConfigurationData parameter rather than the Hostname parameter if this configuration
   should be enacted upon more than one node.
.PARAMETER Image
   Docker image to pull.
.PARAMETER ContainerName
   Docker container to create. This parameter requires a valid Image parameter. Since many
   containers might contain the same commands it is important to define ContainerName
   with a descriptive name.
.PARAMETER Command
   Command to run in specified ContainerName. This parameter requires both valid
   Image and ContainerName parameters. 
.EXAMPLE
   . .\DockerClient.ps1
   DockerClient -Hostname mgmt01.contoso.com

   Generates a .mof for configuring Docker components on mgmt01.contoso.com.


   . .\DockerClient.ps1
   DockerClient -Hostname mgmt01.contoso.com -Image node

   Generates a .mof for configuring Docker components on mgmt01.contoso.com. The
   "node" image will also pulled from the Docker Hub repository.


   . .\DockerClient.ps1
   DockerClient -Hostname mgmt01.contoso.com -Image node -ContainerName "Hello World" -Command 'echo "Hello World"'

   Generates a .mof for configuring Docker components on mgmt01.contoso.com. The
   "node" image will be pulled from the Docker Hub repository. A container by the name
   "Hello World" with the command 'echo "Hello World"' will also be configured.
.NOTES
   Ensure that both the OMI and DSC Linux Resource Provider source have been compiled
   and installed on the specified node. Instructions for doing so can be found here:
   https://github.com/MSFTOSSMgmt/WPSDSCLinux.

   Author: Andrew Weiss | Microsoft
           andrew.weiss@microsoft.com
#>

    param
    (
        [Parameter(Position=1)]
        [string]$Hostname,
        [Parameter(Position=2)]
        [string]$Image,
        [Parameter(Position=3)]
        [string]$ContainerName,
        [Parameter(Position=4)]
        [int]$Port,
        [Parameter(Position=5)]
        [string]$LinkedContainer,
        [Parameter(Position=6)]
        [string]$Command
    )

    if (!$PSBoundParameters['Hostname']) {
        if (!$PSBoundParameters['ConfigurationData']) {
            throw "Hostname and/or ConfigurationData must be specified"
        }
    }

    if (($PSBoundParameters['ContainerName'] -or $PSBoundParameters['Command']) -and (!$PSBoundParameters['Image'])) {
        throw "An Image must be specified"
    }

    # Forces user to name containers rather than randomly assigning names
    if (($PSBoundParameters['Command']) -and (!$PSBoundParameters['ContainerName'])) {
        throw "A container in which to run the command must be specified"
    }

    $OFS = [Environment]::Newline
    
    $installationScripts = Get-ChildItem -Recurse -File -Path "scripts\installation" | % { $_.FullName }
    $installationScripts | % {
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($_)
        Set-Variable -Name $fileName -Value (Get-Content $_)
    }

    $bashString = "#!/bin/bash`r`n"

    if ($Image) {
        if ($Image.Contains(':')) {
            $getDockerImage = $bashString + '[[ $(docker images | grep "' + $Image + '" | awk ''{print $2}'') -eq "' + $Image.Split(':')[1] + '" ]] && exit 0 || exit 1'
            $testDockerImage = $bashString + '[[ $(docker images | grep "' + $Image + '" | awk ''{print $2}'') -eq "' + $Image.Split(':')[1] + '" ]] && exit 0 || exit 1'
        } else {
            $getDockerImage = $bashString + '[[ $docker images | grep "' + $Image + '") -gt 0 ]] && exit 0 || exit 1'
            $testDockerImage = $bashString + '[[ $(docker images | grep -c "' + $Image + '") -gt 0 ]] && exit 0 || exit 1'
        }
        $setDockerImage = $bashString + 'docker pull ' + $Image + '; exit 0'
    }

    # Dynamically build Docker container command
    if ($ContainerName) {
        $getDockerContainer = $bashString + '[[ $(docker ps -a | grep -c "' + $ContainerName + '") -eq 1 ]] && exit 0 || exit 1'
        $testDockerContainer = $bashString + '[[ $(docker ps -a | grep -c "' + $ContainerName + '") -eq 1 ]] && exit 0 || exit 1'

        $setDockerContainer = $bashString + '[[ $(docker run -d --name="' + $ContainerName + '"'
        if ($Port) {
            $setDockerContainer += ' -p ' + $Port + ':' + $Port
        }
        
        if ($LinkedContainer) {
            $setDockerContainer += ' --link ' + $LinkedContainer + ':' + $LinkedContainer
        }
        
        if ($Command) {
            $setDockerContainer += ' ' + $Command
        }
        $setDockerContainer += ' ' + $Image + ') ]] && exit 0 || exit 1'
    }

    Import-DscResource -Module nx
   
    if ($PSBoundParameters['ContainerName']) {
        [scriptblock]$dockerConfig = {
            nxScript DockerInstallation
            {
                GetScript = "$getDockerClient"
                SetScript = "$setDockerClient"
                TestScript = "$testDockerClient"
            }

            nxService DockerService
            {
                Name = "docker.io"
                Controller = "init"
                Enabled = $true
                State = "Running"
                DependsOn = "[nxScript]DockerInstallation"
            }

            nxScript DockerImage
            {
                GetScript = "$getDockerImage"
                SetScript = "$setDockerImage"
                TestScript = "$testDockerImage"
                DependsOn = @("[nxService]DockerService", "[nxScript]DockerInstallation")
            }

            nxScript DockerContainer
            {
                GetScript = "$getDockerContainer"
                SetScript = "$setDockerContainer"
                TestScript = "$testDockerContainer"
                DependsOn = "[nxScript]DockerImage"
            }
        }
    } elseif ($PSBoundParameters['Image']) {
        [scriptblock]$dockerConfig = {
            nxScript DockerInstallation
            {
                GetScript = "$getDockerClient"
                SetScript = "$setDockerClient"
                TestScript = "$testDockerClient"
            }

            nxService DockerService
            {
                Name = "docker.io"
                Controller = "init"
                Enabled = $true
                State = "Running"
                DependsOn = "[nxScript]DockerInstallation"
            }

            nxScript DockerImage
            {
                GetScript = "$getDockerImage"
                SetScript = "$setDockerImage"
                TestScript = "$testDockerImage"
                DependsOn = @("[nxService]DockerService", "[nxScript]DockerInstallation")
            }
        }
    } else {
        [scriptblock]$dockerConfig = {
            nxScript DockerInstallation
            {
                GetScript = "$getDockerClient"
                SetScript = "$setDockerClient"
                TestScript = "$testDockerClient"
            }

            nxService DockerService
            {
                Name = "docker.io"
                Controller = "init"
                Enabled = $true
                State = "Running"
                DependsOn = "[nxScript]DockerInstallation"
            }
        }
    }

    Node $AllNodes.Where{$_.Role -eq "Docker Host"}.Nodename
    {
        if ($AllNodes.Where{$_.Role -eq "Docker Host"}.Nodename -eq "$Hostname") {
            throw "Duplicate node detected in configuration data and Hostname parameter"
        }

        $DockerConfig.Invoke()
    }

    Node $Hostname
    {
        $dockerConfig.Invoke()
    }
}