if (-not(Test-Path -Path 'C:\Program Files\Intune scripts'))
{
    New-Item -Path "C:\Program Files\" -Name "Intune scripts" -ItemType "directory"
}

# try to register the task
try
{
    if(-not(Get-ScheduledTask | Where-Object {$_.TaskName -like "ACME-Azure-file-mount" }))
    {
        $taskXml = '<?xml version="1.0" encoding="UTF-16"?>
    <Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
      <RegistrationInfo>
        <Date>2024-06-06T13:07:08.5598173</Date>
        <Author>ACME</Author>
        <URI>\ACME-Azure-file-mount</URI>
      </RegistrationInfo>
      <Triggers>
        <LogonTrigger>
          <Enabled>true</Enabled>
        </LogonTrigger>
      </Triggers>
      <Principals>
        <Principal id="Author">
          <GroupId>S-1-5-32-545</GroupId>
          <RunLevel>LeastPrivilege</RunLevel>
        </Principal>
      </Principals>
      <Settings>
        <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
        <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
        <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
        <AllowHardTerminate>true</AllowHardTerminate>
        <StartWhenAvailable>false</StartWhenAvailable>
        <RunOnlyIfNetworkAvailable>true</RunOnlyIfNetworkAvailable>
        <IdleSettings>
          <StopOnIdleEnd>true</StopOnIdleEnd>
          <RestartOnIdle>false</RestartOnIdle>
        </IdleSettings>
        <AllowStartOnDemand>true</AllowStartOnDemand>
        <Enabled>true</Enabled>
        <Hidden>false</Hidden>
        <RunOnlyIfIdle>false</RunOnlyIfIdle>
        <WakeToRun>false</WakeToRun>
        <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
        <Priority>7</Priority>
      </Settings>
      <Actions Context="Author">
        <Exec>
          <Command>powershell.exe</Command>
          <Arguments>-NonInteractive -WindowStyle Hidden -NoProfile -NoLogo -ExecutionPolicy Bypass -File "C:\Program Files\Intune scripts\azure-mnt.ps1"</Arguments>
        </Exec>
      </Actions>
    </Task>'
        if (Register-ScheduledTask -Xml $taskXml -TaskName "ACME-Azure-file-mount")
        {
            Set-Content -Path "C:\Program Files\Intune scripts\azure_mnt_log.txt" -Value "ACME-Azure-file-mount task registered"
        }
        else
        {
            Set-Content -Path "C:\Program Files\Intune scripts\azure_mnt_log.txt" -Value "ACME-Azure-file-mount scheduled task registration failed"
        }
    }
}
catch
{
    Set-Content -Path "C:\Program Files\Intune scripts\azure_mnt_log.txt" -Value $_.Exception.Message
}

$scriptCode = '
    $shares = @{
        "Y" = @{  # drive letter
            "storageEndpoint" = "endpointname.file.core.windows.net"  # endpoint, ex: yourstorageaccount.file.core.windows.net
            "shareName" = "share name"  # share name, ex: yourshare or yourshare\folder
        }
        "X" = @{  # drive letter
            "storageEndpoint" = "endpointname.file.core.windows.net"  # endpoint, ex: yourstorageaccount.file.core.windows.net
            "shareName" = "share name\child folder 01"  # share name, ex: yourshare or yourshare\folder
        }
    }

    # Mount the drive

    Set-Content -Path "$ENV:USERPROFILE\AZURE_MNT_log.txt" -Value (Get-Date)

    foreach ($share in $shares.GetEnumerator())
    {
        $storageEndpoint = $share.value.storageEndpoint
        $shareName = $share.value.shareName
        $driveLetter = $share.key

        $fullURL = Join-Path $storageEndpoint -ChildPath $shareName

            if (Test-Path -Path "\\$fullURL")
            {
                try
                { 
                $result = New-PSDrive -Name "$driveLetter" -PSProvider "FileSystem" -Root "\\$fullURL" -Persist -Scope Global -ErrorAction SilentlyContinue
                    Add-Content -Path "$ENV:USERPROFILE\AZURE_MNT_log.txt" -Value "$driveLetter - $shareName connected ok"
                }
                catch
                {
                    Add-Content -Path "$ENV:USERPROFILE\AZURE_MNT_log.txt" -Value "$driveLetter - $shareName drive failed"
                }
            }
            else
            {
                Add-Content -Path "$ENV:USERPROFILE\AZURE_MNT_log.txt" -Value "$driveLetter - $shareName access check failed"
                net use ($driveLetter + ":") /delete
            }
    }
'
$scriptCode | Out-File "C:\Program Files\Intune scripts\azure-mnt.ps1"




























