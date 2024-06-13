for /f "usebackq delims=" %%A in (`dir /b /a:d "%SYSTEMDRIVE%\Users" ^| findstr /v /i /x /c:"Public" /c:"Default User" /c:"All Users"`) do (
	echo mkdir "%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell"
	mkdir "%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell"
	echo mkdir "%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell\Pinned"
	mkdir "%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell\Pinned"

	echo mkdir "%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\nomacs"
	mkdir "%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\nomacs"

	echo PowerShell -NoP -C "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell\Pinned\Terminal.lnk'); $S.TargetPath = '%PROGRAMDATA%\Scoop\GlobalScoopApps\apps\windows-terminal\current\WindowsTerminal.exe'; $S.Save(); $s = $ws.CreateShortcut('%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\nomacs\nomacs - Image Lounge.lnk'); $S.TargetPath = '%HOMEDRIVE%\Program Files\nomacs\bin\nomacs.exe'; $S.WorkingDirectory = 'C:\Program Files\nomacs; $S.Save()"
	PowerShell -NoP -C "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell\Pinned\Terminal.lnk'); $S.TargetPath = '%PROGRAMDATA%\Scoop\GlobalScoopApps\apps\windows-terminal\current\WindowsTerminal.exe'; $S.Save(); $s = $ws.CreateShortcut('%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\nomacs\nomacs - Image Lounge.lnk'); $S.TargetPath = '%HOMEDRIVE%\Program Files\nomacs\bin\nomacs.exe'; $S.WorkingDirectory = 'C:\Program Files\nomacs'; $S.Save()"
)