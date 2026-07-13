$ErrorActionPreference='Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
. (Join-Path $repoRoot 'Core\Argus\ArgusNormalization.ps1')
. (Join-Path $repoRoot 'Core\Argus\ArgusRecommendations.ps1')
function Assert-True { param([bool]$Condition,[string]$Message) if(!$Condition){throw $Message} }

Assert-True ((Get-ARGUSFindingDomain ([pscustomobject]@{title='Adapter issue';category='network';tags=@()})) -eq 'network') 'Exact network category did not classify.'
Assert-True ((Get-ARGUSFindingDomain ([pscustomobject]@{title='Product catalog';category='general';tags=@('product')})) -eq 'general') 'Substring token produced a false domain match.'
Assert-True ((Get-ARGUSFindingDomain ([pscustomobject]@{title='DC issue';category='general';tags=@('dc')})) -eq 'domainHealth') 'Exact domain tag did not classify.'

$priorities=@('evidence-needed','low','normal','high','urgent') | Sort-Object { Get-ARGUSRecommendationPriorityRank $_ }
Assert-True (($priorities -join ',') -eq 'urgent,high,normal,low,evidence-needed') 'Priority ordering is incorrect.'

$script:ARGUSBundleValidation=[pscustomobject]@{Identity=[pscustomobject]@{runId='RUN-CITE-001';bundleId='NTK-CITE-001'}}
$citation=New-ARGUSCitationRecord -SourceType deterministicFinding -Artifact 'Analysis/findings.json' -JsonPointer '/findings/0' -Field finding -ObservedValue 'Fixture' -TrustRank 4
Assert-True ($citation.runId -eq 'RUN-CITE-001' -and $citation.bundleId -eq 'NTK-CITE-001') 'Citation is not bound to immutable run identity.'

$facts=@([pscustomobject]@{id='F1';domain='network';sourceKind='deterministicFinding';severity='critical';confidence='high';citations=@($citation);statement='x';limitations=@()})
$gaps=@([pscustomobject]@{domain='storage';artifact='x';reason='gap';blockedConclusions=@();recommendedCollection='collect'})
$groups=New-ARGUSDiagnosticGroups -NormalizedAnalysis ([pscustomobject]@{facts=$facts;gaps=$gaps})
$network=@($groups|Where-Object domain -eq network)
Assert-True ($network.Count -eq 1 -and @($network[0].blockedByMissingEvidence).Count -eq 0) 'Mixed-domain evidence gap leaked into the network domain.'

Write-Host 'TASK-0090 ARGUS correctness fixtures passed.'
