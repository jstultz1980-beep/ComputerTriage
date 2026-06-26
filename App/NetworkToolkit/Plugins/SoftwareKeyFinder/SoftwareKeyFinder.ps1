function Global:ConvertTo-NTKProductKey {
    param([byte[]]$DigitalProductId)

    if(!$DigitalProductId -or $DigitalProductId.Length -lt 67){
        return $null
    }

    try {
        $key = [byte[]]$DigitalProductId.Clone()
        $digits = "BCDFGHJKMPQRTVWXY2346789"
        $keyStart = 52
        $keyEnd = 66
        $isWin8OrLater = (($key[66] / 6) -band 1)
        $key[66] = ($key[66] -band 0xF7) -bor (($isWin8OrLater -band 2) * 4)
        $decoded = ""
        $last = 0

        for($index = 24; $index -ge 0; $index--){
            $current = 0
            for($position = $keyEnd; $position -ge $keyStart; $position--){
                $current = ($current * 256) -bxor $key[$position]
                $key[$position] = [math]::Floor($current / 24)
                $current = $current % 24
            }

            $decoded = $digits[$current] + $decoded
            $last = $current

            if(($index % 5) -eq 0 -and $index -ne 0){
                $decoded = "-" + $decoded
            }
        }

        if($isWin8OrLater -eq 1){
            $insertAt = $last
            $decoded = $decoded.Substring(1,$insertAt) + "N" + $decoded.Substring($insertAt + 1)
        }

        return $decoded
    }
    catch {
        return $null
    }
}

function Global:Get-NTKWindowsLicenseKeys {
    $results = New-Object System.Collections.ArrayList

    try {
        $service = Get-CimInstance -ClassName SoftwareLicensingService -ErrorAction Stop
        if($service.OA3xOriginalProductKey){
            [void]$results.Add([pscustomobject]@{
                Product = "Windows OEM firmware key"
                Key = [string]$service.OA3xOriginalProductKey
                Source = "UEFI/BIOS OA3"
                Note = "Original equipment manufacturer key embedded in firmware."
            })
        }
    }
    catch {}

    foreach($registryPath in @(
        "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion"
    )){
        try {
            $value = (Get-ItemProperty -Path $registryPath -ErrorAction Stop).DigitalProductId
            $decoded = ConvertTo-NTKProductKey -DigitalProductId $value
            if($decoded -and !($results | Where-Object Key -eq $decoded)){
                [void]$results.Add([pscustomobject]@{
                    Product = "Windows registry key"
                    Key = $decoded
                    Source = $registryPath
                    Note = "Recovered from the local Windows DigitalProductId value; it may be a generic edition key on digitally licensed devices."
                })
            }
        }
        catch {}
    }

    return @($results)
}

function Global:Get-NTKOfficeLicenseKeys {
    $results = New-Object System.Collections.ArrayList
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Office",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office"
    )

    foreach($basePath in $paths){
        if(!(Test-Path $basePath)){
            continue
        }

        foreach($registrationKey in @(Get-ChildItem -Path $basePath -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '\\Registration\\[^\\]+$' })){
            try {
                $properties = Get-ItemProperty -Path $registrationKey.PSPath -ErrorAction Stop
                $digitalId = if($properties.DigitalProductID){$properties.DigitalProductID}else{$properties.DigitalProductId}
                $decoded = ConvertTo-NTKProductKey -DigitalProductId $digitalId
                $product = if($properties.ProductName){[string]$properties.ProductName}elseif($properties.ConvertedToRetail){"Microsoft Office (converted to retail)"}else{"Microsoft Office registration"}

                if($decoded -and !($results | Where-Object Key -eq $decoded)){
                    [void]$results.Add([pscustomobject]@{
                        Product = $product
                        Key = $decoded
                        Source = $registrationKey.Name
                        Note = "Legacy Office registration key. Microsoft 365 and newer click-to-run installs often do not retain a recoverable full key."
                    })
                }
            }
            catch {}
        }
    }

    return @($results)
}

function Global:Get-NTKApplicationLicenseEntries {
    $results = New-Object System.Collections.ArrayList
    $seen = @{}
    $valueNamePattern = '^(Product(Key|ID)|Serial(Number)?|License(Key|Code|Number)?|Registration(Code|Key)?|Activation(Key|Code)?)$'
    $skipVendors = @('Microsoft','Policies','Classes','Clients','WOW6432Node','ODBC','Windows','Microsoft OneDrive')

    foreach($basePath in @(
        'HKLM:\SOFTWARE',
        'HKLM:\SOFTWARE\WOW6432Node',
        'HKCU:\SOFTWARE'
    )){
        if(!(Test-Path $basePath)){
            continue
        }

        $queue = New-Object System.Collections.Queue
        foreach($vendorKey in @(Get-ChildItem -Path $basePath -ErrorAction SilentlyContinue | Where-Object { $skipVendors -notcontains $_.PSChildName } | Select-Object -First 500)){
            $queue.Enqueue([pscustomobject]@{ Key = $vendorKey; Depth = 0 })
        }

        while($queue.Count -gt 0){
            $item = $queue.Dequeue()
            try {
                $properties = Get-ItemProperty -Path $item.Key.PSPath -ErrorAction Stop
                foreach($property in @($properties.PSObject.Properties | Where-Object { $_.Name -match $valueNamePattern })){
                    if($null -eq $property.Value -or $property.Value -is [byte[]]){
                        continue
                    }

                    $keyValue = ([string]$property.Value).Trim()
                    if($keyValue.Length -lt 4 -or $keyValue.Length -gt 512){
                        continue
                    }

                    $product = if($properties.DisplayName){[string]$properties.DisplayName}elseif($properties.ProductName){[string]$properties.ProductName}else{$item.Key.PSChildName}
                    $source = ($item.Key.Name -replace '^HKEY_LOCAL_MACHINE','HKLM:' -replace '^HKEY_CURRENT_USER','HKCU:')
                    $identity = "$product|$keyValue"
                    if(!$seen.ContainsKey($identity)){
                        $seen[$identity] = $true
                        [void]$results.Add([pscustomobject]@{
                            Product = $product
                            Key = $keyValue
                            Source = $source
                            Note = "Application registration value '$($property.Name)'. Verify the license with the software vendor before relying on it for transfer or reactivation."
                        })
                    }
                }

                if($item.Depth -lt 2){
                    foreach($child in @(Get-ChildItem -Path $item.Key.PSPath -ErrorAction SilentlyContinue | Select-Object -First 150)){
                        $queue.Enqueue([pscustomobject]@{ Key = $child; Depth = ($item.Depth + 1) })
                    }
                }
            }
            catch {}
        }
    }

    return @($results | Sort-Object Product,Key)
}

function Global:Get-NTKMicrosoftActivationInventory {
    try {
        return @(
            Get-CimInstance -ClassName SoftwareLicensingProduct -ErrorAction Stop |
                Where-Object { $_.PartialProductKey -and $_.Name -match "Windows|Office" } |
                Select-Object Name,Description,LicenseStatus,PartialProductKey
        )
    }
    catch {
        return @()
    }
}

function Global:ConvertTo-NTKKeyFinderHtml {
    param([object]$Value)
    return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}

function Global:Export-NTKSoftwareKeyReport {
    param(
        [object[]]$RecoveredKeys,
        [object[]]$ActivationInventory
    )

    if(!(Test-Path $NTKPaths.Exports)){
        New-Item -ItemType Directory -Path $NTKPaths.Exports -Force | Out-Null
    }

    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $safeComputer = if($env:COMPUTERNAME){$env:COMPUTERNAME -replace '[^A-Za-z0-9._-]+','_'}else{"Computer"}
    $path = Join-Path $NTKPaths.Exports "software-key-report-$safeComputer-$stamp.html"
    $keyRows = if(@($RecoveredKeys).Count -gt 0){
        (@($RecoveredKeys) | ForEach-Object {
            "<tr><td>$(ConvertTo-NTKKeyFinderHtml $_.Product)</td><td class='key'>$(ConvertTo-NTKKeyFinderHtml $_.Key)</td><td>$(ConvertTo-NTKKeyFinderHtml $_.Source)</td><td>$(ConvertTo-NTKKeyFinderHtml $_.Note)</td></tr>"
        }) -join "`n"
    }
    else{
        "<tr><td colspan='4' class='empty'>No recoverable local product or registration key was found. This is normal for account-managed, subscription, volume-licensed, cloud-activated, or encrypted-license applications.</td></tr>"
    }
    $activationRows = if(@($ActivationInventory).Count -gt 0){
        (@($ActivationInventory) | ForEach-Object {
            "<tr><td>$(ConvertTo-NTKKeyFinderHtml $_.Name)</td><td>$(ConvertTo-NTKKeyFinderHtml $_.LicenseStatus)</td><td>$(ConvertTo-NTKKeyFinderHtml $_.PartialProductKey)</td><td>$(ConvertTo-NTKKeyFinderHtml $_.Description)</td></tr>"
        }) -join "`n"
    }
    else{
        "<tr><td colspan='4' class='empty'>No Windows or Office activation records with a partial key were available.</td></tr>"
    }

    @"
<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Network Toolkit Software Key Report</title><style>
body{margin:0;background:#eef2f6;color:#1f2933;font-family:"Segoe UI",Arial,sans-serif}.top{background:#0f2f4a;color:#fff;padding:28px 36px}.top h1{margin:0;font-size:28px}.top p{margin:8px 0 0;color:#c9d8e5}.wrap{max-width:1240px;margin:0 auto;padding:26px 28px 40px}.notice{background:#fff1cc;border-left:5px solid #b7791f;border-radius:8px;padding:14px 16px;line-height:1.5}.section{margin-top:22px}.section h2{color:#102a43;font-size:20px}table{width:100%;border-collapse:collapse;table-layout:fixed;background:#fff;border:1px solid #d9e1e8;border-radius:8px;overflow:hidden}th,td{text-align:left;vertical-align:top;padding:11px 12px;border-bottom:1px solid #e6edf3;font-size:13px;overflow-wrap:anywhere}th{background:#f6f8fb;color:#425466}tr:last-child td{border-bottom:0}.key{font-family:Consolas,monospace;font-weight:700;letter-spacing:.04em}.empty{color:#66788a;font-style:italic}.footer{margin-top:22px;color:#66788a;font-size:12px}@media print{body{background:#fff}}
</style></head><body><div class="top"><h1>Network Toolkit Software Key Report</h1><p>$(ConvertTo-NTKKeyFinderHtml $env:COMPUTERNAME) | Generated $(Get-Date -Format "g")</p></div><main class="wrap"><div class="notice"><strong>Confidential licensing data:</strong> handle this report as customer-sensitive information. It checks Windows firmware/registry keys, legacy Microsoft Office entries, and explicit local application product/serial/license/registration registry values. It does not attempt to recover browser passwords, Wi-Fi passwords, API tokens, or password/token-style registry values.</div><section class="section"><h2>Recoverable Product And Registration Entries</h2><table><thead><tr><th style="width:22%">Product</th><th style="width:24%">Key Or Registration Value</th><th style="width:24%">Source</th><th>Notes</th></tr></thead><tbody>$keyRows</tbody></table></section><section class="section"><h2>Microsoft Activation Inventory</h2><table><thead><tr><th style="width:35%">Product</th><th style="width:12%">Status</th><th style="width:15%">Last Five</th><th>Description</th></tr></thead><tbody>$activationRows</tbody></table></section><div class="footer">Generated by Network Toolkit. Do not retain this report longer than needed for approved licensing support.</div></main></body></html>
"@ | Set-Content -Path $path -Encoding UTF8

    return $path
}

function Global:Invoke-SoftwareKeyFinder {
    Clear-Host
    Write-Host ""
    Write-Host "SOFTWARE KEY FINDER" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "This performs a read-only local licensing check for Windows, legacy Office, and explicit application registration values." -ForegroundColor Yellow
    Write-Host "It does not retrieve passwords, Wi-Fi keys, browser data, API tokens, or password/token-style registry values." -ForegroundColor DarkGray
    Write-Host ""

    $keys = @(Get-NTKWindowsLicenseKeys) + @(Get-NTKOfficeLicenseKeys) + @(Get-NTKApplicationLicenseEntries)
    $activation = @(Get-NTKMicrosoftActivationInventory)
    $reportPath = Export-NTKSoftwareKeyReport -RecoveredKeys $keys -ActivationInventory $activation

    if($keys.Count -gt 0){
        Write-Host "Recoverable product keys:" -ForegroundColor Green
        $keys | Select-Object Product,Key,Source | Format-Table -Wrap -AutoSize
    }
    else{
        Write-Host "No recoverable local product or registration key was found." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Activation inventory:" -ForegroundColor Cyan
    $activation | Select-Object Name,LicenseStatus,PartialProductKey | Format-Table -Wrap -AutoSize
    Write-Host ""
    Write-Host "Confidential report saved to: $reportPath" -ForegroundColor Green
}

Register-NTKCommand `
    -Name "Software Key Finder" `
    -Command "Invoke-SoftwareKeyFinder" `
    -Category "Software" `
    -Description "Read-only recovery of Windows, legacy Office, and explicit application registration keys, with a confidential HTML report." `
    -Order 640
