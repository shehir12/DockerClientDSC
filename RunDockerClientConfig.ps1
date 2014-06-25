param
(
    $Hostname
)

$cred = Get-Credential -UserName "root" -Message "Enter password"
$opt = New-CimSessionOption -UseSsl -SkipCACheck -SkipCNCheck -SkipRevocationCheck
$linuxcomp = New-CimSession -Credential $cred -ComputerName $hostname -Port 5986 -Authentication basic -SessionOption $opt
Start-DscConfiguration -CimSession $linuxcomp -Path .\DockerClient -Verbose -Wait
$linuxcomp | Remove-CimSession