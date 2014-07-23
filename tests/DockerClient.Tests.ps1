$parent = Split-Path -Parent $PSScriptRoot
. "$parent\DockerClient.ps1"

Describe "DockerClient" {
    Context "when Hostname and Configuration parameters are null" { 
        It "should throw an exception" {
            { DockerClient } | Should Throw
        }

        # This test will fail. Bug in Pester beta that is being resolved
        It "should throw a specific exception message" {
            { DockerClient } | Should Throw "Hostname and/or ConfigurationData must be specified"
        }
    }
}

Describe "getInstallationBlock" {
    $block = getInstallationBlock

    It "should return a scriptblock" {
        $block | Should Not BeNullOrEmpty    
    }

    It "should be an nxScript resource" {
        $block | Should Match "nxScript"
    }
}

Describe "getServiceBlock" {
    $block = getServiceBlock

    It "should return a scriptblock" {
        $block | Should Not BeNullOrEmpty    
    }

    It "should be an nxScript resource" {
        $block | Should Match "nxService"
    }
}

Describe "getImageBlock" {
    Context "when invoked with minimum parameters" {
        $image = "testImage"
        $block = getImageBlock -dockerImage $image
        $getScriptVar = Get-Variable get$image -ValueOnly
        $setScriptVar = Get-Variable set$image -ValueOnly
        $testScriptVar = Get-Variable test$image -ValueOnly

        It "should return a scriptblock" {
            $block | Should Not BeNullOrEmpty    
        }

        It "should be an nxScript resource" {
            $block | Should Match "nxScript"
        }

        It "should depend on the service block" {
            $block | Should Match "DependsOn = \""\[nxService\]DockerService\"""
        }

        It "should set all required nxScript properties" {
            $getScriptVar | Should Not BeNullOrEmpty
            $setScriptVar | Should Not BeNullOrEmpty
            $testScriptVar | Should Not BeNullOrEmpty
        }

        It "should be configured to pull specified image" {
            $setScriptVar | Should Match "docker pull testImage"
        }
    }

    Context "when invoked with isRemovable" {
        $image = "testImage"
        $block = getImageBlock -dockerImage $image -isRemovable $true
        $getScriptVar = Get-Variable get$image -ValueOnly
        $setScriptVar = Get-Variable set$image -ValueOnly
        $testScriptVar = Get-Variable test$image -ValueOnly

        It "should be configured to remove specified image" {
            $setScriptVar | Should Match "docker rmi -f testImage"
        }
    }

    Context "when invoked with missing dockerImage parameter" {
        It "should throw an InvokeMethodOnNull exception" {
            { getImageBlock } | Should Throw "You cannot call a method on a null-valued expression"
        }
    }
}

Describe "getContainerBlock" {
    Context "when invoked with proper parameters" {
        $block = getContainerBlock -containerName "testContainer" -containerImage "testImage"

        It "should return a scriptblock" {
            $block | Should Not BeNullOrEmpty
        }

        It "Should be an nxScript resource" {
            $block | Should Match "nxScript"
        }

        It "should depend on the specified image block" {
            $block | Should Match "DependsOn = \""\[nxScript\]testImage\"""
        }
    }
}

if (Test-Path $PSScriptRoot\DockerClient) { Remove-Item -Recurse $PSScriptRoot\DockerClient }