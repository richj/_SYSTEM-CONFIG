FUNCTION make-shortcut
{
    [cmdletbinding()]
	param ( [string]$SourceExe, [string]$ArgumentsToSourceExe, [string]$DestinationPath )
	$WshShell = New-Object -comObject WScript.Shell
	$Shortcut = $WshShell.CreateShortcut($DestinationPath)
	$Shortcut.TargetPath = $SourceExe
	$Shortcut.windowstyle = 7
	$Shortcut.Arguments = $ArgumentsToSourceExe
	$Shortcut.Save()
}
