$parent = Split-Path -Parent $PSScriptRoot
. "$parent\DockerClient.ps1"

Describe "DockerClient" {
    Context "when Hostname and Configuration parameters are null" { 
		It "should throw an exception" {
            { DockerClient } | Should Throw
        }

        It "should throw a specific exception message" {
            { DockerClient } | Should Throw "Hostname and/or ConfigurationData must be specified"
        }
	}
}

if (Test-Path $PSScriptRoot\DockerClient) { Remove-Item -Recurse $PSScriptRoot\DockerClient }