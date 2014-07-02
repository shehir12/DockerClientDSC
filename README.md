# DockerClientDSC
> DSC for Linux configuration script that checks whether or not the required Docker components have been installed on a specified Ubuntu host. This script also provides an example usage of the **nxScript** DSC resource. The DSC for Linux project page can be found here: https://github.com/MSFTOSSMgmt/WPSDSCLinux.

## Prerequisites

Ensure that you have provisioned one or more hosts running Ubuntu Server. At the time of this writing, the `14.04 LTS` release is suitable.

While both CentOS and Oracle Linux have also been tested with PowerShell DSC for Linux, this particular configuration has been developed specifically for Ubuntu.

## Setup
> NOTE: There is an encoding bug in the DSC for Linux nxService resource as mentioned in this issue: https://github.com/MSFTOSSMgmt/WPSDSCLinux/issues/6. Until this is fixed in the WPSDSCLinux repository, a replacement `nxService.py` file has been included in the *DSCforLinuxSetup* folder. Copy this file in to `/opt/omi-1.0.8/lib/Scripts/nxService.py` on your target node(s).

Prior to executing any of the DSC configuration scripts included in this repository, ensure that your targeted node(s) has the required OMI and DSC for Linux components installed. The *DSCforLinuxSetup* folder contains an installation script, `OMIDSCInit.sh`, and an init script, `omiserverinit`, that can be used to assist with this process. The code in the setup files has been provided courtesy of PowerShell Magazine writer Ravikanth C (http://www.powershellmagazine.com/2014/05/21/installing-and-configuring-dsc-for-linux/) and Microsoft Senior Program Manager Kristopher Bash (http://blogs.technet.com/b/privatecloud/archive/2014/05/19/powershell-dsc-for-linux-step-by-step.aspx) respectively.



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

   A sample DSC configuration data file has also been included and can be modified and used in conjunction with or in place of the `Hostname` parameter:

	```powershell
	DockerClient -ConfigurationData .\SampleConfigData.psd1
	```

4. Start the configuration application process on the targeted node

	```powershell
	.\RunDockerClientConfig.ps1 -Hostname $hostname
	```

   The `RunDockerClientConfig.ps1` script can also parse a DSC configuration data file and execute configurations against multiple nodes as such:

	```powershell
	.\RunDockerClientConfig.ps1 -ConfigurationData .\SampleConfigData.psd1
	```

## Images

This is equivalent to running: `docker pull [IMAGE]`.

Using the same Run Configuration steps defined above, execute `DockerClient` with the `-Image` parameter:

```powershell
DockerClient -Hostname $hostname -Image node
```

You can also configure the host for multiple images:

```powershell
DockerClient -Hostname $hostname -Image node,mongo
```

The configuration process can be initiated as before:

```powershell
.\RunDockerClientConfig.ps1 -Hostname $hostname
```

## Containers

To create containers, you can use the `Container` parameter with one or more hashtable. The hashtable(s) passed to this parameter can consist of the following properties:

- Name (required)
- Image (required)
- Port
- Link
- Command

Each property coincides with the the same options available to the `docker run` command.

For example, create a hashtable with the settings for your container:

```powershell
$webContainer = @{Name="web"; Image="anweiss/docker-platynem"; Port="80:80"}
```

Then, using the same Run Configuration steps defined above, execute `DockerClient` with the `-Image` and `-Container` parameters:

```powershell
DockerClient -Hostname $hostname -Image node -Container $webContainer
```

The configuration process can be initiated as before:

```powershell
.\RunDockerClientConfig.ps1 -Hostname $hostname
```