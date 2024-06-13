@echo OFF

if exist "%ProgramFiles%\LibreWolf\librewolf.exe" call :setAssociations & exit /b 0

PowerShell -NoP -C "Start-Process '%ProgramData%\chocolatey\bin\choco.exe' -ArgumentList 'install','-y','--allow-empty-checksums','librewolf' -NoNewWindow -Wait"

call :setAssociations

rmdir /q /s "%APPDATA%\Microsoft\Windows\Start Menu\Programs\LibreWolf"

for /f "usebackq delims=" %%A in (`dir /b /a:d "%SYSTEMDRIVE%\Users" ^| findstr /v /i /x /c:"Public" /c:"Default User" /c:"All Users"`) do (
	mkdir "%SYSTEMDRIVE%\Users\%%A\.librewolf"
	copy /y "librewolf.overrides.cfg" "%SYSTEMDRIVE%\Users\%%A\.librewolf"

	if exist "%ProgramFiles%\LibreWolf\librewolf.exe" (
		echo 	PowerShell -NoP -C "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%PUBLIC%\Desktop\LibreWolf.lnk'); $S.TargetPath = '%ProgramFiles%\LibreWolf\librewolf.exe'; $S.WorkingDirectory = '%ProgramFiles%\LibreWolf'; $S.Save()"
		PowerShell -NoP -C "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%PUBLIC%\Desktop\LibreWolf.lnk'); $S.TargetPath = '%ProgramFiles%\LibreWolf\librewolf.exe'; $S.WorkingDirectory = '%ProgramFiles%\LibreWolf'; $S.Save()"

		copy /y "%PUBLIC%\Desktop\LibreWolf.lnk" "%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell\Pinned"
	)
)
if not exist "%ProgramFiles%\LibreWolf\librewolf.exe" exit /b 0

PowerShell -NoP -C "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%ProgramData%\\Microsoft\Windows\Start Menu\Programs\LibreWolf.lnk'); $S.TargetPath = '%ProgramFiles%\LibreWolf\librewolf.exe'; $S.WorkingDirectory = '%ProgramFiles%\LibreWolf'; $S.Save()"
PowerShell -NoP -C "$Content = (Get-Content '%~dp0\Layout.xml'); $Content = $Content -replace '%%ALLUSERSPROFILE%%\\Microsoft\\Windows\\Start Menu\\Programs\\Firefox.lnk', '%%ALLUSERSPROFILE%%\\Microsoft\\Windows\\Start Menu\\Programs\\LibreWolf.lnk' | Set-Content '%~dp0\Layout.xml'"

for /f "usebackq tokens=2 delims=\" %%A in (`reg query "HKEY_USERS" ^| findstr /r /x /c:"HKEY_USERS\\S-.*" /c:"HKEY_USERS\\AME_UserHive_[^_]*"`) do (
	reg query "HKU\%%A" | findstr /c:"Volatile Environment" /c:"AME_UserHive_" > NUL 2>&1
		if not errorlevel 1 (
			if "%%A"=="AME_UserHive_Default" (
				call :AFISCALL "%SYSTEMDRIVE%\Users\Default\AppData\Roaming" "%%A"
			) else (
				for /f "usebackq tokens=2* delims= " %%B in (`reg query "HKU\%%A\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "AppData" 2^>^&1 ^| findstr /R /X /C:".*AppData[ ]*REG_SZ[ ].*"`) do (
					call :AFISCALL "%%C" "%%A"
				)
			)
	)
)
exit /b 0

:AFISCALL

setlocal

if not "%~2"=="AME_UserHive_Default" (
	del "%~1\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\LibreWolf.lnk" /q /f
	mkdir "%~1\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
	PowerShell -NoP -C "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%~1\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\LibreWolf.lnk'); $S.TargetPath = '%ProgramFiles%\LibreWolf\librewolf.exe'; $S.WorkingDirectory = '%ProgramFiles%\LibreWolf'; $S.Save()"

::	reg add "HKU\%~2\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "Favorites" /t REG_BINARY /d "00A40100003A001F80C827341F105C1042AA032EE45287D668260001002600EFBE12000000B938E4724DEFD801B773BC9C4DEFD8017514D99C4DEFD801140056003100000000006355AC3311005461736B42617200400009000400EFBE6355AC336355AC332E0000002C9D01000000010000000000000000000000000000008B2592005400610073006B00420061007200000016001201320097010000874F0749200046494C4545587E312E4C4E4B00007C0009000400EFBE6355AC336355AC332E000000309D0100000001000000000000000000520000000000589C4400460069006C00650020004500780070006C006F007200650072002E006C006E006B00000040007300680065006C006C00330032002E0064006C006C002C002D003200320030003600370000001C00120000002B00EFBED66CDB9C4DEFD8011C00420000001D00EFBE02004D006900630072006F0073006F00660074002E00570069006E0064006F00770073002E004500780070006C006F0072006500720000001C00260000001E00EFBE0200530079007300740065006D00500069006E006E006500640000001C00000000B80100003A001F80C827341F105C1042AA032EE45287D668260001002600EFBE12000000B938E4724DEFD801B773BC9C4DEFD8017C6FD6F4F190D90114005600310000000000BB56E4B011005461736B42617200400009000400EFBE6355AC33BB56E4B02E0000002C9D010000000100000000000000000000000000000093BB3D005400610073006B004200610072000000160026013200EB060000BB56EAB220004C49425245577E312E4C4E4B00004C0009000400EFBEBB56ADBABB56ADBA2E000000638C0000000004000000000000000000000000000000F12CFE004C00690062007200650057006F006C0066002E006C006E006B0000001C00220000001E00EFBE02005500730065007200500069006E006E006500640000001C00120000002B00EFBE81D3D8F4F190D9011C008A0000001D00EFBE02007B00360044003800300039003300370037002D0036004100460030002D0034003400340042002D0038003900350037002D004100330037003700330046003000320032003000300045007D005C004C00690062007200650057006F006C0066005C006C00690062007200650077006F006C0066002E0065007800650000001C000000FF" /f
::	reg add "HKU\%~2\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "FavoritesResolve" /t REG_BINARY /d "320300004C0000000114020000000000C0000000000000468300800020000000964FD49C4DEFD801D66CDB9C4DEFD801A8B6C6DADDACD501970100000000000001000000000000000000000000000000A0013A001F80C827341F105C1042AA032EE45287D668260001002600EFBE12000000B938E4724DEFD801B773BC9C4DEFD8017514D99C4DEFD801140056003100000000006355AC3311005461736B42617200400009000400EFBE6355AC336355AC332E0000002C9D01000000010000000000000000000000000000008B2592005400610073006B00420061007200000016000E01320097010000874F0749200046494C4545587E312E4C4E4B00007C0009000400EFBE6355AC336355AC332E000000309D0100000001000000000000000000520000000000589C4400460069006C00650020004500780070006C006F007200650072002E006C006E006B00000040007300680065006C006C00330032002E0064006C006C002C002D003200320030003600370000001C00220000001E00EFBE02005500730065007200500069006E006E006500640000001C00120000002B00EFBED66CDB9C4DEFD8011C00420000001D00EFBE02004D006900630072006F0073006F00660074002E00570069006E0064006F00770073002E004500780070006C006F0072006500720000001C0000009B0000001C000000010000001C0000002D000000000000009A00000011000000030000000522C56C1000000000433A5C55736572735C757365725C417070446174615C526F616D696E675C4D6963726F736F66745C496E7465726E6574204578706C6F7265725C517569636B204C61756E63685C557365722050696E6E65645C5461736B4261725C46696C65204578706C6F7265722E6C6E6B000060000000030000A058000000000000006465736B746F702D666268387633650014B5BC69C2059D439B4347F5B6C63660A421C645405BED118152000C2923D22B14B5BC69C2059D439B4347F5B6C63660A421C645405BED118152000C2923D22B45000000090000A03900000031535053B1166D44AD8D7048A748402EA43D788C1D000000680000000048000000A3E237A16911924EA5DFB5374E1DB68A000000000000000000000000460300004C0000000114020000000000C0000000000000468300800020000000FF45CFF4F190D90181D3D8F4F190D9010F4F6CD6E990D901EB0600000000000001000000000000000000000000000000B8013A001F80C827341F105C1042AA032EE45287D668260001002600EFBE12000000B938E4724DEFD801B773BC9C4DEFD8017C6FD6F4F190D90114005600310000000000BB56E4B011005461736B42617200400009000400EFBE6355AC33BB56E4B02E0000002C9D010000000100000000000000000000000000000093BB3D005400610073006B004200610072000000160026013200EB060000BB56EAB220004C49425245577E312E4C4E4B00004C0009000400EFBEBB56ADBABB56ADBA2E000000638C0000000004000000000000000000000000000000F12CFE004C00690062007200650057006F006C0066002E006C006E006B0000001C00220000001E00EFBE02005500730065007200500069006E006E006500640000001C00120000002B00EFBE81D3D8F4F190D9011C008A0000001D00EFBE02007B00360044003800300039003300370037002D0036004100460030002D0034003400340042002D0038003900350037002D004100330037003700330046003000320032003000300045007D005C004C00690062007200650057006F006C0066005C006C00690062007200650077006F006C0066002E0065007800650000001C000000970000001C000000010000001C0000002D000000000000009600000011000000030000000522C56C1000000000433A5C55736572735C757365725C417070446174615C526F616D696E675C4D6963726F736F66745C496E7465726E6574204578706C6F7265725C517569636B204C61756E63685C557365722050696E6E65645C5461736B4261725C4C69627265576F6C662E6C6E6B000060000000030000A058000000000000006465736B746F702D666268387633650014B5BC69C2059D439B4347F5B6C636607B2FD17D40F8ED118157000C292F898514B5BC69C2059D439B4347F5B6C636607B2FD17D40F8ED118157000C292F898545000000090000A03900000031535053B1166D44AD8D7048A748402EA43D788C1D000000680000000048000000A3E237A16911924EA5DFB5374E1DB68A000000000000000000000000" /f
)

exit /b 0

:setAssociations

for /f "usebackq tokens=2 delims=\" %%A in (`reg query "HKEY_USERS" ^| findstr /r /x /c:"HKEY_USERS\\S-.*" /c:"HKEY_USERS\\AME_UserHive_[^_]*"`) do (
	REM If the "Volatile Environment" key exists, that means it is a proper user. Built in accounts/SIDs don't have this key.
	reg query "HKU\%%A" | findstr /c:"Volatile Environment" /c:"AME_UserHive_" > NUL 2>&1
		if not errorlevel 1 (
			PowerShell -NoP -ExecutionPolicy Bypass -File assoc.ps1 "Placeholder" "%%A" ".html:LibreWolfHTM" ".htm:LibreWolfHTM" "Proto:https:LibreWolfHTM" "Proto:http:LibreWolfHTM"
	)
)