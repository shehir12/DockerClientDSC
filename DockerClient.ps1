$OFS = [Environment]::Newline
$get = Get-Content "DockerInstallation\getDockerClient.txt"
$set = Get-Content "DockerInstallation\setDockerClient.txt"
$test = Get-Content "DockerInstallation\testDockerClient.txt"

Configuration DockerClient
{
    param
    (
        $Hostname
    )
    Import-DscResource -Module nx
    Node $hostname
    {
        nxScript DockerInstallation
        {
            GetScript = "$get"
            SetScript = "$set"
            TestScript = "$test"
        }
    }
}