$taskName = "ACME-Azure-file-mount"

$taskResult = Unregister-ScheduledTask -TaskName $taskName

$taskExists = Get-ScheduledTask -TaskName $taskName

if ($null -ne $taskExists)
{
    Write-Host "Azure files uninstalled."
    exit 0
}
else
{
    Write-Host "Azure files uninstallation failed."
    exit 1
}