' Klavye Testi Merkezi - kisayoldan/cift tiklamadan baslatir.
' Konsol, cmd ve shell pencereleri hic acilmaz (Run pencere stili 0 = gizli).
Set oShell = CreateObject("WScript.Shell")
sFolder = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
sScript = sFolder & "klavye-testi.ps1"
sCmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & sScript & """"
oShell.Run sCmd, 0, False
