function Global:Get-NTKArtifactClassification {
    param([Parameter(Mandatory=$true)][string]$Path)
    $name = [IO.Path]::GetFileName($Path)
    $classification = if($name -match '(?i)(software-key|wifi.*profile|credential|secret|token|mini?dump)'){'Sensitive'}
        elseif($name -match '(?i)(diagnos|triage|profile|inventory|event|process|network|report)'){'ClientEvidence'}
        else{'Operational'}
    [pscustomobject]@{
        Classification = $classification
        DefaultRetentionDays = if($classification -eq 'Sensitive'){3}elseif($classification -eq 'ClientEvidence'){21}else{14}
        TransferByDefault = ($classification -ne 'Sensitive')
        EncryptionRequiredForTransfer = ($classification -eq 'Sensitive')
    }
}

function Global:Get-NTKArtifactMetadataPath { param([string]$Path) return "$Path.ntk-artifact.json" }

function Global:Get-NTKArtifactMetadata {
    param([Parameter(Mandatory=$true)][string]$Path)
    $metadataPath = Get-NTKArtifactMetadataPath $Path
    if(Test-Path -LiteralPath $metadataPath){
        try { return Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json } catch {}
    }
    $policy = Get-NTKArtifactClassification -Path $Path
    [pscustomobject]@{ SchemaVersion=1; Path=$Path; Classification=$policy.Classification; CreatedAt=(Get-Date).ToString('o'); RetentionDays=$policy.DefaultRetentionDays; Pinned=$false; TransferByDefault=$policy.TransferByDefault; EncryptionRequiredForTransfer=$policy.EncryptionRequiredForTransfer }
}

function Global:Set-NTKArtifactMetadata {
    param([Parameter(Mandatory=$true)][string]$Path,[string]$Classification,[int]$RetentionDays=0,[bool]$Pinned=$false,[string]$Reason='')
    $policy = Get-NTKArtifactClassification -Path $Path
    if(!$Classification){$Classification=$policy.Classification}
    if($RetentionDays -le 0){$RetentionDays=$policy.DefaultRetentionDays}
    $value=[ordered]@{SchemaVersion=1;Path=$Path;Classification=$Classification;CreatedAt=(Get-Date).ToString('o');RetentionDays=$RetentionDays;Pinned=$Pinned;PinReason=$Reason;TransferByDefault=($Classification -ne 'Sensitive');EncryptionRequiredForTransfer=($Classification -eq 'Sensitive')}
    $metadataPath=Get-NTKArtifactMetadataPath $Path
    if(Get-Command Write-NTKAtomicJson -ErrorAction SilentlyContinue){ Write-NTKAtomicJson -Path $metadataPath -Value $value | Out-Null }
    else { $value | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $metadataPath -Encoding UTF8 }
    return [pscustomobject]$value
}

function Global:Write-NTKSensitiveActionAudit {
    param([string]$Action,[string]$ArtifactPath,[string]$Reason)
    $root=if($NTKPaths -and $NTKPaths.Logs){Join-Path $NTKPaths.Logs 'SensitiveActions'}else{Join-Path $env:TEMP 'NetworkToolkit\SensitiveActions'}
    if(!(Test-Path $root)){New-Item -ItemType Directory -Path $root -Force|Out-Null}
    $entry=[ordered]@{Timestamp=(Get-Date).ToString('o');Action=$Action;ArtifactPath=$ArtifactPath;Operator=[Environment]::UserName;ComputerName=$env:COMPUTERNAME;Reason=$Reason}
    Add-Content -LiteralPath (Join-Path $root 'audit.jsonl') -Value ($entry|ConvertTo-Json -Compress) -Encoding UTF8
}

function Global:Protect-NTKTransferFile {
    param([Parameter(Mandatory=$true)][string]$Source,[Parameter(Mandatory=$true)][string]$Destination,[Parameter(Mandatory=$true)][string]$Password)
    if([string]::IsNullOrWhiteSpace($Password)){throw 'Encryption password is required.'}
    $salt=New-Object byte[] 16; $iv=New-Object byte[] 16
    $rng=[Security.Cryptography.RandomNumberGenerator]::Create(); $rng.GetBytes($salt); $rng.GetBytes($iv); $rng.Dispose()
    $derive=New-Object Security.Cryptography.Rfc2898DeriveBytes($Password,$salt,100000)
    $aes=[Security.Cryptography.Aes]::Create(); $aes.Key=$derive.GetBytes(32); $hmacKey=$derive.GetBytes(32); $aes.IV=$iv
    $plain=[IO.File]::ReadAllBytes($Source); $encryptor=$aes.CreateEncryptor(); $cipher=$encryptor.TransformFinalBlock($plain,0,$plain.Length)
    $header=[Text.Encoding]::ASCII.GetBytes('NTKENC1');$payload=$header+$salt+$iv+$cipher
    $hmac=New-Object Security.Cryptography.HMACSHA256 -ArgumentList @(,$hmacKey);$tag=$hmac.ComputeHash($payload)
    [IO.File]::WriteAllBytes($Destination,($payload+$tag))
    $derive.Dispose(); $encryptor.Dispose(); $aes.Dispose();$hmac.Dispose()
    return $Destination
}
