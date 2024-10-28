$taskName = "ACME-Azure-file-mount"

$taskExists = Get-ScheduledTask -TaskName $taskName

if ($null -ne $taskExists)
{
    Write-Host "Azure files installed."
    exit 0
}
else
{
    Write-Host "Azure files installation failed."
    exit 1
}