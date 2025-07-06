copy /y "ame10_settings.exe" "%PROGRAMDATA%\AME"
copy /y "appfetch.exe" "%PROGRAMDATA%\AME"
del /q /f "%WINDIR%\System32\ameck.exe"
del /q /f "%WINDIR%\System32\amecs.exe"
del /q /f "%PROGRAMDATA%\AME\privacy+_settings.exe"

del /q /f "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Ameliorated\AME10 Settings.lnk"

reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AME10 Settings" /f

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AppFetch" /v "DisplayName" /t REG_SZ /d "App Fetch Experimental" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AppFetch" /v "Publisher" /t REG_SZ /d "Ameliorated LLC" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AppFetch" /v "DisplayIcon" /t REG_SZ /d "%PROGRAMDATA%\AME\appfetch.exe" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AppFetch" /v "UninstallString" /t REG_SZ /d """%PROGRAMDATA%\AME\appfetch.exe"" --uninstall" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AppFetch" /v "NoRepair" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AppFetch" /v "NoModify" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AppFetch" /v "EstimatedSize" /t REG_DWORD /d "41062" /f

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AME10 Settings" /v "DisplayName" /t REG_SZ /d "AME10 Settings" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AME10 Settings" /v "Publisher" /t REG_SZ /d "Ameliorated LLC" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AME10 Settings" /v "DisplayIcon" /t REG_SZ /d "%PROGRAMDATA%\AME\ame10_settings.exe" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AME10 Settings" /v "UninstallString" /t REG_SZ /d """%PROGRAMDATA%\AME\ame10_settings.exe"" --uninstall" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AME10 Settings" /v "NoRepair" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AME10 Settings" /v "NoModify" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AME10 Settings" /v "EstimatedSize" /t REG_DWORD /d "19558" /f

mkdir "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Ameliorated"
		
PowerShell -NoP -C "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Ameliorated\AME10 Settings.lnk'); $S.TargetPath = '%PROGRAMDATA%\AME\ame10_settings.exe'; $S.Save()"
PowerShell -NoP -C "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Ameliorated\App Fetch Experimental.lnk'); $S.TargetPath = '%PROGRAMDATA%\AME\appfetch.exe'; $S.Save()"

@echo OFF

for /f "usebackq delims=" %%A in (`dir /b /a:d "%SYSTEMDRIVE%\Users" ^| findstr /v /i /x /c:"Public" /c:"Default User" /c:"All Users"`) do (
	if exist "%PROGRAMFILES%\Open-Shell" (
		mkdir "%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell\Pinned"
		echo PowerShell -NoP -C "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell\Pinned\Configure AME.lnk'); $S.TargetPath = '%WINDIR%\System32\amecs.exe'; $S.Save()"
		PowerShell -NoP -C "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell\Pinned\Configure AME.lnk'); $S.TargetPath = '%WINDIR%\System32\amecs.exe'; $S.Save()"
		echo PowerShell -NoP -C "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell\Pinned\AME10 Settings.lnk'); $S.TargetPath = '%PROGRAMDATA%\AME\ame10_settings.exe'; $S.Save()"
		PowerShell -NoP -C "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell\Pinned\AME10 Settings.lnk'); $S.TargetPath = '%PROGRAMDATA%\AME\ame10_settings.exe'; $S.Save()"
		PowerShell -NoP -C "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell\Pinned\App Fetch Experimental.lnk'); $S.TargetPath = '%PROGRAMDATA%\AME\appfetch.exe'; $S.Save()"
		del /q /f "%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell\Pinned\Configure AME.lnk"
		del /q /f "%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell\Pinned\Central AME Script.lnk"
		del /q /f "%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell\Pinned\Configure AME10.lnk"
		rmdir /q /s "%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\AME"
	)
)