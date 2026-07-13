$ErrorActionPreference='Stop'
$repoRoot=Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
function Assert-True([bool]$Value,[string]$Message){if(!$Value){throw $Message}}

$definitions=Get-ChildItem (Join-Path $repoRoot 'App\NetworkToolkit\Core') -Filter '*.ps1'|ForEach-Object{
    $file=$_;$tokens=$null;$errors=$null;$ast=[Management.Automation.Language.Parser]::ParseFile($_.FullName,[ref]$tokens,[ref]$errors)
    $ast.FindAll({param($node)$node -is [Management.Automation.Language.FunctionDefinitionAst]},$true)|ForEach-Object{[pscustomobject]@{Name=$_.Name;File=$file.Name}}
}
$duplicates=@($definitions|Group-Object Name|Where-Object Count -gt 1)
Assert-True ($duplicates.Count -eq 0) ('Duplicate core symbols: '+($duplicates.Name -join ', '))

. (Join-Path $repoRoot 'App\NetworkToolkit\Config\ToolCatalog.ps1')
. (Join-Path $repoRoot 'App\NetworkToolkit\Utilities\ToolMetadata.ps1')
. (Join-Path $repoRoot 'App\NetworkToolkit\Utilities\PluginContract.ps1')
. (Join-Path $repoRoot 'App\NetworkToolkit\Plugins\ExternalToolManager\ExternalToolManager.ps1')
$Global:NTKPaths=[pscustomobject]@{Root=(Join-Path $repoRoot 'App\NetworkToolkit')}
$descriptorTest=Test-NTKCanonicalToolDescriptors
Assert-True $descriptorTest.Passed ($descriptorTest.Failures -join '; ')
Assert-True ($descriptorTest.DescriptorCount -ge @(Get-NTKToolCatalog).Count) 'Canonical descriptors omitted shipped tools.'
foreach($required in @('Id','Name','Tab','Section','Kind','EntryPoint','RequiresAdmin','Source')){Assert-True (@(Get-NTKCanonicalToolDescriptors|Where-Object{!($_.PSObject.Properties.Name -contains $required)}).Count -eq 0) "Descriptor field missing: $required"}

$plugins=@(Get-NTKPluginInventory -PluginRoot (Join-Path $repoRoot 'App\NetworkToolkit\Plugins'))
Assert-True ($plugins.Count -eq 21) 'Plugin discovery count changed unexpectedly.'
Assert-True (@($plugins|Where-Object Lifecycle -eq Invalid).Count -eq 0) 'A shipped plugin violates the manifest contract.'

$fixtureRoot=Join-Path $env:TEMP ('TASK-0095-'+[guid]::NewGuid().ToString('N'))
try{
    $enabled=Join-Path $fixtureRoot 'Enabled';$disabled=Join-Path $fixtureRoot 'Disabled';$invalid=Join-Path $fixtureRoot 'Invalid'
    New-Item -ItemType Directory -Path $enabled,$disabled,$invalid -Force|Out-Null
    "@{Name='Fixture';Version='1.0';Script='Fixture.ps1';Enabled=`$true}"|Set-Content (Join-Path $enabled 'PluginManifest.psd1');''|Set-Content (Join-Path $enabled 'Fixture.ps1')
    "@{Name='Disabled';Version='1.0';Script='Disabled.ps1';Enabled=`$false}"|Set-Content (Join-Path $disabled 'PluginManifest.psd1');''|Set-Content (Join-Path $disabled 'Disabled.ps1')
    'not a manifest'|Set-Content (Join-Path $invalid 'PluginManifest.psd1')
    $fixture=@(Get-NTKPluginInventory -PluginRoot $fixtureRoot)
    Assert-True (@($fixture|Where-Object Lifecycle -eq Enabled).Count -eq 1) 'Enabled plugin was not discovered.'
    Assert-True (@($fixture|Where-Object Lifecycle -eq Disabled).Count -eq 1) 'Disabled plugin lifecycle was not honored.'
    Assert-True (@($fixture|Where-Object Lifecycle -eq Invalid).Count -eq 1) 'Invalid plugin was not isolated.'
}finally{if(Test-Path $fixtureRoot){Remove-Item $fixtureRoot -Recurse -Force}}

. (Join-Path $repoRoot 'App\NetworkToolkit\Utilities\OperationResult.ps1')
foreach($state in @('Succeeded','SucceededWithWarnings','Partial','Failed','Blocked','Canceled')){$result=New-NTKOperationResult -Operation Fixture -State $state;Assert-True ($result.state -eq $state -and $null -ne $result.exitCode) "Canonical state failed: $state"}
$quickText=Get-Content (Join-Path $repoRoot 'App\NetworkToolkit\Plugins\QuickDiagnosis\QuickDiagnosis.ps1') -Raw
Assert-True ($quickText -match "AnalysisRole.*InteractiveSnapshot" -and $quickText -match "CanonicalAnalysisCommand.*Invoke-HEPHAESTUSLocalAnalysis") 'Quick Diagnosis role is not reconciled with canonical analysis.'
$guiText=Get-Content (Join-Path $repoRoot 'App\ToolKit-GUI\ToolKit-GUI.ps1') -Raw
Assert-True ($guiText -match 'Get-NTKCanonicalToolDescriptors') 'GUI tabs/search/launch do not consume canonical descriptors.'
Write-Host 'TASK-0095 canonical architecture fixtures passed.' -ForegroundColor Green
