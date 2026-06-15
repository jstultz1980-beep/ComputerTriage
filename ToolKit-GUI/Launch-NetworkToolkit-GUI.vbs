Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
toolkitScript = fso.BuildPath(scriptDir, "ToolKit-GUI.ps1")
command = "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -STA -File " & Chr(34) & toolkitScript & Chr(34)
shell.Run command, 1, False
