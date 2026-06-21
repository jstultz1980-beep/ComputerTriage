Option Explicit

Dim shell, fileSystem, toolkitRoot, appRoot, toolkitScript, arguments, argumentIndex
Set shell = CreateObject("Shell.Application")
Set fileSystem = CreateObject("Scripting.FileSystemObject")
toolkitRoot = fileSystem.GetParentFolderName(WScript.ScriptFullName)
appRoot = fileSystem.BuildPath(toolkitRoot, "App")
toolkitScript = fileSystem.BuildPath(appRoot, "NetworkToolkit.ps1")

If Not fileSystem.FileExists(toolkitScript) Then
    MsgBox "The Network Toolkit application files were not found:" & vbCrLf & toolkitScript, vbCritical, "Network Toolkit"
    WScript.Quit 1
End If

arguments = "-NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File " & Chr(34) & toolkitScript & Chr(34)
For argumentIndex = 0 To WScript.Arguments.Count - 1
    arguments = arguments & " " & Chr(34) & WScript.Arguments(argumentIndex) & Chr(34)
Next
shell.ShellExecute "powershell.exe", arguments, appRoot, "runas", 0
