Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Send-Notification($title, $message) {
    [System.Media.SystemSounds]::Exclamation.Play()
    [System.Windows.Forms.MessageBox]::Show($message, $title, "OK", "Warning") | Out-Null
}

function Get-IPType($ip) {
    $parts = $ip.Split(".") | ForEach-Object { [int]$_ }
    if ($parts | Where-Object { $_ -gt 255 }) { return "Invalid" }
    if ($parts[0] -eq 127) { return "Localhost" }
    if ($parts[0] -eq 10) { return "Private" }
    if ($parts[0] -eq 192 -and $parts[1] -eq 168) { return "Private" }
    if ($parts[0] -eq 172 -and $parts[1] -ge 16 -and $parts[1] -le 31) { return "Private" }
    return "Public"
}

$folder = "test_files"
$pattern = "\b(?:\d{1,3}\.){3}\d{1,3}\b"
$found = @()

Get-ChildItem -Path $folder -File -Recurse | ForEach-Object {
    $file = $_
    Select-String -Path $file.FullName -Pattern $pattern -AllMatches | ForEach-Object {
        $line = $_.LineNumber
        foreach ($m in $_.Matches) {
            $ip = $m.Value
            $type = Get-IPType $ip

            if ($type -eq "Invalid") {
                Write-Host "[Skipped] $ip is not a real IP (line $line)" -ForegroundColor DarkGray
                continue
            }

            if ($type -eq "Public") { $color = "Red" }
            elseif ($type -eq "Private") { $color = "Yellow" }
            else { $color = "Cyan" }

            Write-Host "[$type] $ip in $($file.Name) line $line" -ForegroundColor $color

            $found += [PSCustomObject]@{
                IP   = $ip
                Type = $type
                File = $file.Name
                Line = $line
            }
        }
    }
}

if ($found.Count -gt 0) {
    $public  = @($found | Where-Object Type -eq "Public").Count
    $private = @($found | Where-Object Type -eq "Private").Count
    $local   = @($found | Where-Object Type -eq "Localhost").Count

    Write-Host ""
    Write-Host "========== Summary ==========" -ForegroundColor White
    Write-Host "Public    : $public" -ForegroundColor Red
    Write-Host "Private   : $private" -ForegroundColor Yellow
    Write-Host "Localhost : $local" -ForegroundColor Cyan
    Write-Host "Total     : $($found.Count)" -ForegroundColor White

    $reportName = "report_" + (Get-Date -Format "yyyy-MM-dd_HH-mm") + ".csv"
    $found | Export-Csv -Path $reportName -NoTypeInformation
    Write-Host "Report saved: $reportName" -ForegroundColor Green

    Send-Notification "IP Watcher" "Found $($found.Count) IP addresses`nPublic: $public | Private: $private | Localhost: $local"
} else {
    Write-Host "No IP found. All clean!" -ForegroundColor Green
}