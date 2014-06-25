# DockerClientDSC
> DSC for Linux configuration script that checks whether or not the required Docker components have been installed on a specified Ubuntu host. This script also provides an example usage of the **nxScript** DSC resource.

## Setup

Prior to executing any of the DSC configuration scripts included in this repository, ensure that your targeted node(s) has the required OMI and DSC for Linux components installed. The *DSCforLinuxSetup* folder contains an installation script, `OMIDSCInit.sh`, and an init script, `omiserverinit`, that can be used to assist with this process. The code in these files have been provided courtesy of PowerShell Magazine writer Ravikanth C (http://www.powershellmagazine.com/2014/05/21/installing-and-configuring-dsc-for-linux/) and Microsoft Senior Program Manager Kristopher Bash (http://blogs.technet.com/b/privatecloud/archive/2014/05/19/powershell-dsc-for-linux-step-by-step.aspx) respectively.

## Run Configuration

1. Create a variable to hold the hostname of the targeted node

	```powershell
	$hostname = "mgmt01.contoso.com"
	```

2. Load the DockerClient configuration into the current PowerShell session

	```powershell
	. .\DockerClient.ps1
	```

3. Generate the required DSC configuration .mof file for the targeted node

	```powershell
	DockerClient -Hostname $hostname
	```

4. Start the configuration application process on the targeted node

	```powershell
	.\RunDockerClientConfig.ps1 -Hostname $hostname
	```