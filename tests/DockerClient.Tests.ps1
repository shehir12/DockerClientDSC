$parent = Split-Path -Parent $PSScriptRoot
. "$parent\DockerClient.ps1"

Describe "DockerClient" {
    BeforeEach {
        $originalPreference = $global:ErrorActionPreference
        $global:ErrorActionPreference = "Stop"
    }

    AfterEach {
        $global:ErrorActionPreference = $originalPreference
    }

    Context "when Hostname and Configuration parameters are null" {

        It "should throw an exception" {
            { DockerClient } | Should Throw
        }

        It "should throw a specific exception message" {
            $errorMessage = "Hostname and/or ConfigurationData must be specified"
            { DockerClient } | Should Throw $errorMessage
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
        $getScriptVar = Get-Variable -Scope Script get$image -ValueOnly
        $setScriptVar = Get-Variable -Scope Script set$image -ValueOnly
        $testScriptVar = Get-Variable -Scope Script test$image -ValueOnly

        It "should return a scriptblock" {
            $block | Should Not BeNullOrEmpty    
        }

        It "should be an nxScript resource" {
            $block | Should Match "nxScript"
        }

        It "should depend on the service block" {
            $block | Should Match "DependsOn = \""\[nxService\]DockerService\"""
        }

        It "should create required script variables" {
            $vars = Get-Variable | ? Name -like "*$image"
            $vars.Count | Should BeExactly 3
        }

        It "should set all required nxScript properties" {
            $getScriptVar | Should Not BeNullOrEmpty
            $setScriptVar | Should Not BeNullOrEmpty
            $testScriptVar | Should Not BeNullOrEmpty
        }

        It "should be configured to pull specified image" {
            $setScriptVar | Should Match "docker pull testImage; exit 0"
        }
    }

    Context "when invoked with isRemovable and dockerImage contains ':'" {
        # Define image name
        $image = "testImage:latest"
        $imageRoot = $image.Substring(0, $image.IndexOf(':'))
        $imageVersion = $image.Substring($image.IndexOf(':')+1)
        $imageVar = $image.Replace('-', "").Replace(':', "").Replace('/', "")


        $block = getImageBlock -dockerImage $image -isRemovable $true

        $getScriptVar = Get-Variable -Scope Script get$imageVar -ValueOnly
        $setScriptVar = Get-Variable -Scope Script set$imageVar -ValueOnly
        $testScriptVar = Get-Variable -Scope Script test$imageVar -ValueOnly
        
        It "should return a scriptblock" {
            $block | Should Not BeNullOrEmpty    
        }

        It "should be an nxScript resource" {
            $block | Should Match "nxScript"
        }

        It "should depend on the service block" {
            $block | Should Match "DependsOn = \""\[nxService\]DockerService\"""
        }

        It "should create required script variables" {
            $vars = Get-Variable | ? Name -like "*$imageRoot"
            $vars.Count | Should BeExactly 3
        }

        It "should set all required nxScript properties" {
            $getScriptVar | Should Not BeNullOrEmpty
            $setScriptVar | Should Not BeNullOrEmpty
            $testScriptVar | Should Not BeNullOrEmpty
        }

        It "should be configured to remove specified image" {
            $setScriptVar | Should Match "docker rmi -f testImage"
        }

    }

    Context "when invoked with isRemovable" {
        $image = "testImage"
        $block = getImageBlock -dockerImage $image -isRemovable $true
        $getScriptVar = Get-Variable -Scope Script get$image -ValueOnly
        $setScriptVar = Get-Variable -Scope Script set$image -ValueOnly
        $testScriptVar = Get-Variable -Scope Script test$image -ValueOnly

        It "should return a scriptblock" {
            $block | Should Not BeNullOrEmpty    
        }

        It "should be an nxScript resource" {
            $block | Should Match "nxScript"
        }

        It "should depend on the service block" {
            $block | Should Match "DependsOn = \""\[nxService\]DockerService\"""
        }

        It "should create required script variables" {
            $vars = Get-Variable | ? Name -like "*$image"
            $vars.Count | Should BeExactly 3
        }

        It "should set all required nxScript properties" {
            $getScriptVar | Should Not BeNullOrEmpty
            $setScriptVar | Should Not BeNullOrEmpty
            $testScriptVar | Should Not BeNullOrEmpty
        }

        It "should be configured to remove specified image" {
            $setScriptVar | Should Match "docker rmi -f testImage"
        }
    }

    Context "when dockerImages contains ':'" {
        # Define image name
        $image = "testImage:latest"
        $imageRoot = $image.Substring(0, $image.IndexOf(':'))
        $imageVersion = $image.Substring($image.IndexOf(':')+1)
        $imageVar = $image.Replace('-', "").Replace(':', "").Replace('/', "")

        $block = getImageBlock -dockerImage $image
        
        $getScriptVar = Get-Variable -Scope Script get$imageVar -ValueOnly
        $setScriptVar = Get-Variable -Scope Script set$imageVar -ValueOnly
        $testScriptVar = Get-Variable -Scope Script test$imageVar -ValueOnly

        It "should return a scriptblock" {
            $block | Should Not BeNullOrEmpty    
        }

        It "should be an nxScript resource" {
            $block | Should Match "nxScript"
        }

        It "should depend on the service block" {
            $block | Should Match "DependsOn = \""\[nxService\]DockerService\"""
        }

        It "should create required script variables" {
            $vars = Get-Variable | ? Name -like "*$imageRoot"
            $vars.Count | Should BeExactly 3
        }

        It "should set all required nxScript properties" {
            $getScriptVar | Should Not BeNullOrEmpty
            $setScriptVar | Should Not BeNullOrEmpty
            $testScriptVar | Should Not BeNullOrEmpty
        }

        It "should be configured to pull specified image" {
            $setScriptVar | Should Match "docker pull testImage:latest; exit 0"
        }
    }  

    Context "when invoked with missing dockerImage parameter" {
        It "should throw an InvokeMethodOnNull exception" {
            { getImageBlock } | Should Throw "You cannot call a method on a null-valued expression"
        }
    }
}

Describe "getContainerBlock" {
    Context "when invoked with minimum parameters" {
        $containerName = "testContainer"
        $containerImage = "testImage"
        $block = getContainerBlock -containerName $containerName -containerImage $containerImage
        $getScriptVar = Get-Variable -Scope Script get$containerName -ValueOnly
        $setScriptVar = Get-Variable -Scope Script set$containerName -ValueOnly
        $testScriptVar = Get-Variable -Scope Script test$containerName -ValueOnly

        It "should return a scriptblock" {
            $block | Should Not BeNullOrEmpty    
        }

        It "should be an nxScript resource" {
            $block | Should Match "nxScript"
        }

        It "should depend on the image block" {
            $block | Should Match "DependsOn = \""\[nxScript\]testImage\"""
        }

        It "should create required script variables" {
            $vars = Get-Variable | ? Name -like "*$containerName"
            $vars.Count | Should BeExactly 3
        }

        It "should set all required nxScript properties" {
            $getScriptVar | Should Not BeNullOrEmpty
            $setScriptVar | Should Not BeNullOrEmpty
            $testScriptVar | Should Not BeNullOrEmpty
        }

        It "should be configured to run specified container" {
            $setScriptVar | Should Match 'docker run -d --name="testContainer"'
        }
    }
}

if (Test-Path $PSScriptRoot\DockerClient) { Remove-Item -Recurse $PSScriptRoot\DockerClient }