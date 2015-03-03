<#
 .Synopsis
 Management cmdlets for example recovery service.

 .Description
 Provides cmdlets for installing the example components
 and managing the restoration of customer data.
 These are generally called from the API server.
#>

Import-Module AWSPowerShell

$USERDATAURI = "http://169.254.169.254/latest/meta-data"

<#
 .Synopsis
 Return the current AWS guest's InstanceId.
#>
function Get-CurrentInstanceId {
    Begin {
        $web = New-Object System.Net.WebClient
        $web.DownloadString( $USERDATAURI + "/instance-id" )
    }
    Process { }
    End { }
}

<#
 .Synopsis
 Set a tag for the current guest.

 .Description
 This requires credentials, which I don't know where to get yet.
#>
function Set-CurrentInstanceIdTag {
    param (
        [Parameter(Mandatory=$true)][string]$key,
        [Parameter(Mandatory=$true)][string]$value
    )

    Begin {
        $id = Get-CurrentInstanceId
        $tag = New-Object amazon.EC2.Model.Tag
        $tag.Key = $key
        $tag.Value = $value
        New-EC2Tag -ResourceId $id -Tag $tag
    }
    Process { }
    End { }
}

$BASE     = "https://s3-us-west-2.amazonaws.com/redgates/windows"
$EXAMPLE  = $BASE + "/example.exe"
$VCREDIST = $BASE + "/vcredist_x64/vcredist_x64.exe"

<#
 .Synopsis
 Download a component of the Example recovery VM from the cloud.

 .Parameter uri
 The cloud URI for the component in the cloud.

 .Parameter target
 The local pathname of the target file for the resource.

 .Example
 Get-ExampleComponent -uri "http://s3.aws.com/bucket/foo.exe" -target "C:\foo.exe"
#>
function Get-ExampleComponent {
    param (
        [Parameter(Mandatory=$true)][string]$uri,
        [Parameter(Mandatory=$true)][string]$target
    )

    # set target to be the basename of the uri
    Begin {
        $web = New-Object System.Net.WebClient
        $web.DownloadFile( $uri, $target )
    }
    Process { }
    End { }
}

<#
 .Synopsis

 .Example
#>
function Get-ExampleInstallDir {
    Begin {
        $property = Get-ItemProperty -Path 'HKLM:Software\Redgates\Example' -Name "Install_Dir"
        $property.Install_Dir
    }
    Process { }
    End { }
}


<#
 .Synopsis

 .Parameter uri

 .Parameter target

 .Example
#>
function Install-VisualCRuntime {
    Begin {
        $target = "C:\vcredist_x64.exe"

        if ( (Test-Path $target) -eq $false ) {
            Get-ExampleComponent -uri $script:VCREDIST -target $target
        }

        Start-Process -wait -FilePath $target -ArgumentList "/q /noreboot"
    }
    Process { }
    End { }
}

<#
 .Synopsis

 .Parameter uri

 .Parameter target

 .Example
#>
function Initialize-ExampleRecovery {
    Begin {
        Write-Output "Install Visual C Runtime"
        Install-VisualCRuntime
        Write-Output "Complete"
    }
    Process {
    }
    End {
    }
}

<#
 .Synopsis

 .Parameter uri

 .Parameter target

 .Example
#>
function Test-BackupSet {
    Begin {
        # check if catalog is present
    }
    Process {
    }
    End {
    }
}

<#
 .Synopsis

 .Description

 .Parameter message
#>
function Invoke-RecoveryNotification {
    param (
        [Parameter(Mandatory=$true)][string]$message
    )

    Begin {
        $property = Get-ItemProperty -Path 'HKLM:Software\Redgates\Example' -Name "Install_Dir"
        $installdir = $property.Install_Dir

        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

        $icon = New-Object System.Windows.Forms.NotifyIcon
        $icon.Icon = "$installdir\megared.ico"
        $icon.BalloonTipIcon = "Info"
        $icon.BalloonTipText = $message
        $icon.BalloonTipTitle = "Recovery Notification"
        $icon.Visible = $True
        $icon.ShowBalloonTip(10000)
    }
    Process {
    }
    End {
    }
}

<#
 .Synopsis

 .Description
 Perhaps this should take a series of strings from a pipe also?

 .Parameter uri

 .Parameter target

 .Example
#>
function Invoke-RecoveryErrorNotification {
    param (
        [Parameter(Mandatory=$true)][string]$message
    )

    Begin {
        $property = Get-ItemProperty -Path 'HKLM:Software\Redgates\Example' -Name "Install_Dir"
        $installdir = $property.Install_Dir

        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

        $icon = New-Object System.Windows.Forms.NotifyIcon
        $icon.Icon = "$installdir\megared.ico"
        $icon.BalloonTipIcon = "Error"
        $icon.BalloonTipText = $message
        $icon.BalloonTipTitle = "Recovery Error"
        $icon.Visible = $True
        $icon.ShowBalloonTip(10000)
    }
    Process {
    }
    End {
    }
}

<#
 .Synopsis

 .Parameter uri

 .Parameter target

 .Example
#>
function Update-ExampleModule {
    Begin {
        $installdir = Get-ExampleInstallDir
        $target = "$installdir\Example.exe"
        Get-ExampleComponent -uri $script:EXAMPLE -target $target
        Start-Process -wait -FilePath $target
        Invoke-RecoveryNotification -message "Updated Example module and imported"
        Import-Module -Global -Force Example
    }
    Process { }
    End { }
}

# vim:autoindent expandtab sw=4
