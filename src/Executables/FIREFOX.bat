@echo OFF

echo. & echo Grabbing previous Firefox entries...

for /f "usebackq tokens=2 delims=-" %%A in (`reg query "HKLM\SOFTWARE\Clients\StartMenuInternet" /k /f "Firefox-" ^| findstr /c:"Firefox-"`) do (
	set /a "count1=!count1!+1"
	set "ffBef!count1!=%%A"
	set "par=!par!)"
	set "arg=!arg!if not "%%D"=="%%A" ("
)

PowerShell -NoP -C "Start-Process '%ProgramData%\chocolatey\bin\choco.exe' -ArgumentList 'install','-y','--allow-empty-checksums','firefox' -NoNewWindow -Wait"
PowerShell -NoP -C "Start-Process '%ProgramData%\chocolatey\bin\choco.exe' -ArgumentList 'upgrade','-y','--allow-empty-checksums','firefox' -NoNewWindow -Wait"

call :setAssociations


for /f "usebackq delims=" %%A in (`dir /b /a:d "%SYSTEMDRIVE%\Users" ^| findstr /v /i /x /c:"Public" /c:"Default User" /c:"All Users"`) do (
	echo PowerShell -NoP -C "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell\Pinned\Firefox.lnk'); $S.TargetPath = '%HOMEDRIVE%\Program Files\Mozilla Firefox\firefox.exe'; $S.WorkingDirectory = 'C:\Program Files\Mozilla Firefox'; $S.Save()"
	PowerShell -NoP -C "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SYSTEMDRIVE%\Users\%%A\AppData\Roaming\OpenShell\Pinned\Firefox.lnk'); $S.TargetPath = '%HOMEDRIVE%\Program Files\Mozilla Firefox\firefox.exe'; $S.WorkingDirectory = 'C:\Program Files\Mozilla Firefox'; $S.Save()"
)

if not exist "%~dp0\AME-Firefox-Injection" (
	echo. & echo No supplied AME-Firefox-Injection folder detected.
	exit /b 4
)

:ENTRIES

setlocal EnableDelayedExpansion
set /a "count1=0"

echo. & echo Comparing Firefox entries...
set /a "count2=0"
for /f "usebackq tokens=2 delims=-" %%D in (`reg query "HKLM\SOFTWARE\Clients\StartMenuInternet" /f "Firefox-" ^| findstr /c:"Firefox-"`) do (
	set /a "count2=!count2!+1"
	%arg%set "NewCode=%%D"%par%
)

if "%count1%"=="0" (if "%count2%"=="0" (set "NewCode=NULL"))
endlocal & set "NewCode=%NewCode%"

:CHECKS

set "RunEC=10"
set /a "count0=1"

for /f "usebackq tokens=2 delims=\" %%A in (`reg query "HKEY_USERS" ^| findstr /r /x /c:"HKEY_USERS\\S-.*" /c:"HKEY_USERS\\AME_UserHive_[^_]*"`) do (
	reg query "HKU\%%A" | findstr /c:"Volatile Environment" /c:"AME_UserHive_" > NUL 2>&1
		if not errorlevel 1 (
	if "%%A"=="AME_UserHive_Default" (
		call :AFISCALL "%SYSTEMDRIVE%\Users\Default\AppData\Roaming" "%%A"
			if errorlevel 2 set "RunEC=2"
			if errorlevel 1 set "RunEC=1"
			if errorlevel 0 set "RunEC=0"
	) else (
		for /f "usebackq tokens=2* delims= " %%B in (`reg query "HKU\%%A\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "AppData" 2^>^&1 ^| findstr /R /X /C:".*AppData[ ]*REG_SZ[ ].*"`) do (
			call :AFISCALL "%%C" "%%A"
				if errorlevel 2 set "RunEC=2"
				if errorlevel 1 set "RunEC=1"
				if errorlevel 0 set "RunEC=0"
		)
	)
)
)
exit /b %RunEC%

:AFISCALL

setlocal

if exist "%PROGRAMFILES%\Mozilla Firefox\firefox.exe" (
	if not "%~2"=="AME_UserHive_Default" (
		del "%~1\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Firefox.lnk" /q /f
		mkdir "%~1\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
		PowerShell -NoP -C "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%~1\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Firefox.lnk'); $S.TargetPath = '%HOMEDRIVE%\Program Files\Mozilla Firefox\firefox.exe'; $S.WorkingDirectory = 'C:\Program Files\Mozilla Firefox'; $S.Save()"

		reg add "HKU\%~2\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "FavoritesResolve" /t REG_BINARY /d "320300004c0000000114020000000000c0000000000000468300800020000000964fd49c4defd801d66cdb9c4defd801a8b6c6daddacd501970100000000000001000000000000000000000000000000a0013a001f80c827341f105c1042aa032ee45287d668260001002600efbe12000000b938e4724defd801b773bc9c4defd8017514d99c4defd801140056003100000000006355ac3311005461736b42617200400009000400efbe6355ac336355ac332e0000002c9d01000000010000000000000000000000000000008b2592005400610073006b00420061007200000016000e01320097010000874f0749200046494c4545587e312e4c4e4b00007c0009000400efbe6355ac336355ac332e000000309d0100000001000000000000000000520000000000589c4400460069006c00650020004500780070006c006f007200650072002e006c006e006b00000040007300680065006c006c00330032002e0064006c006c002c002d003200320030003600370000001c00220000001e00efbe02005500730065007200500069006e006e006500640000001c00120000002b00efbed66cdb9c4defd8011c00420000001d00efbe02004d006900630072006f0073006f00660074002e00570069006e0064006f00770073002e004500780070006c006f0072006500720000001c0000009b0000001c000000010000001c0000002d000000000000009a00000011000000030000000522c56c1000000000433a5c55736572735c757365725c417070446174615c526f616d696e675c4d6963726f736f66745c496e7465726e6574204578706c6f7265725c517569636b204c61756e63685c557365722050696e6e65645c5461736b4261725c46696c65204578706c6f7265722e6c6e6b000060000000030000a058000000000000006465736b746f702d666268387633650014b5bc69c2059d439b4347f5b6c63660a421c645405bed118152000c2923d22b14b5bc69c2059d439b4347f5b6c63660a421c645405bed118152000c2923d22b45000000090000a03900000031535053b1166d44ad8d7048a748402ea43d788c1d000000680000000048000000a3e237a16911924ea5dfb5374e1db68a000000000000000000000000460300004c0000000114020000000000c0000000000000468300800020000000411d47ab1561d901411d47ab1561d901411d47ab1561d901580400000000000001000000000000000000000000000000ba013a001f80c827341f105c1042aa032ee45287d668260001002600efbe12000000b938e4724defd801b773bc9c4defd801411d47ab1561d901140056003100000000007c56500c11005461736b42617200400009000400efbe6355ac337c56510c2e0000002c9d0100000001000000000000000000000000000000fce08e005400610073006b004200610072000000160028013200580400007c56840c200046697265666f782e6c6e6b00480009000400efbe7c56840c7c56840c2e00000057780000000003000000000000000000000000000000bf560100460069007200650066006f0078002e006c006e006b0000001a00220000001e00efbe02005500730065007200500069006e006e006500640000001a00120000002b00efbe411d47ab1561d9011a00920000001d00efbe02007b00360044003800300039003300370037002d0036004100460030002d0034003400340042002d0038003900350037002d004100330037003700330046003000320032003000300045007d005c004d006f007a0069006c006c0061002000460069007200650066006f0078005c00660069007200650066006f0078002e0065007800650000001a000000950000001c000000010000001c0000002d000000000000009400000011000000030000000522c56c1000000000433a5c55736572735c757365725c417070446174615c526f616d696e675c4d6963726f736f66745c496e7465726e6574204578706c6f7265725c517569636b204c61756e63685c557365722050696e6e65645c5461736b4261725c46697265666f782e6c6e6b000060000000030000a058000000000000006465736b746f702d666268387633650014b5bc69c2059d439b4347f5b6c636600bec6f75f9cced118156000c291f4a8414b5bc69c2059d439b4347f5b6c636600bec6f75f9cced118156000c291f4a8445000000090000a03900000031535053b1166d44ad8d7048a748402ea43d788c1d000000680000000048000000a3e237a16911924ea5dfb5374e1db68a000000000000000000000000" /f
		reg add "HKU\%~2\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /v "Favorites" /t REG_BINARY /d "00a40100003a001f80c827341f105c1042aa032ee45287d668260001002600efbe12000000b938e4724defd801b773bc9c4defd8017514d99c4defd801140056003100000000006355ac3311005461736b42617200400009000400efbe6355ac336355ac332e0000002c9d01000000010000000000000000000000000000008b2592005400610073006b00420061007200000016001201320097010000874f0749200046494c4545587e312e4c4e4b00007c0009000400efbe6355ac336355ac332e000000309d0100000001000000000000000000520000000000589c4400460069006c00650020004500780070006c006f007200650072002e006c006e006b00000040007300680065006c006c00330032002e0064006c006c002c002d003200320030003600370000001c00120000002b00efbed66cdb9c4defd8011c00420000001d00efbe02004d006900630072006f0073006f00660074002e00570069006e0064006f00770073002e004500780070006c006f0072006500720000001c00260000001e00efbe0200530079007300740065006d00500069006e006e006500640000001c00000000ba0100003a001f80c827341f105c1042aa032ee45287d668260001002600efbe12000000b938e4724defd801b773bc9c4defd801411d47ab1561d901140056003100000000007c56500c11005461736b42617200400009000400efbe6355ac337c56510c2e0000002c9d0100000001000000000000000000000000000000fce08e005400610073006b004200610072000000160028013200580400007c56840c200046697265666f782e6c6e6b00480009000400efbe7c56840c7c56840c2e00000057780000000003000000000000000000000000000000bf560100460069007200650066006f0078002e006c006e006b0000001a00220000001e00efbe02005500730065007200500069006e006e006500640000001a00120000002b00efbe411d47ab1561d9011a00920000001d00efbe02007b00360044003800300039003300370037002d0036004100460030002d0034003400340042002d0038003900350037002d004100330037003700330046003000320032003000300045007d005c004d006f007a0069006c006c0061002000460069007200650066006f0078005c00660069007200650066006f0078002e0065007800650000001a000000ff" /f
	)
)

echo. & echo Generating random string...

:GenRND

setlocal EnableDelayedExpansion
set "RNDConsist=abcdefghijklmnopqrstuvwxyz0123456789"
set /a "RND=%RANDOM% %% 36"
set "RNDStr=!RNDStr!!RNDConsist:~%RND%,1!"
if "%RNDStr:~7%"=="" (goto GenRND)
endlocal & set "RNDStr=%RNDStr%"

:: Redundancy, incase the original Firefox installed check fails
if "%NewCode%"=="NULL" (
	echo.
	echo No Firefox install detected
	call :PREFSONLY "%~1"
	exit /b 0
)
if "%NewCode%"=="" (
	echo.
	echo Firefox version already installed
	call :PREFSONLY "%~1"
	exit /b 0
)
if not EXIST "%PROGRAMFILES%\Mozilla Firefox\firefox.exe" (
	echo.
	echo Can't find Firefox.exe
	call :PREFSONLY "%~1"
	exit /b 0
)
if exist "%~1\Mozilla\Firefox\profiles.ini" (
	findstr /c:"%NewCode%" "%~1\Mozilla\Firefox\profiles.ini" > NUL 2>&1
		if not errorlevel 1 (
			echo. & echo Firefox version already in profiles.ini
			call :PREFSONLY "%~1"
			exit /b 0
		)
)

:PROFILENAME

if %count0% GTR 50 (
	echo.
	echo Default-release count exceeded 50
	call :PREFSONLY "%~1"
	exit /b 0
)
if exist "%~1\Mozilla\Firefox\profiles.ini" (
	findstr /c:"Name=default-release" "%~1\Mozilla\Firefox\profiles.ini" > NUL 2>&1
		if not errorlevel 1 (
			findstr /c:"Name=default-release-%count0%" "%~1\Mozilla\Firefox\profiles.ini"
				if not errorlevel 1 (
					set /a "count0=%count0%+1"
					goto PROFILENAME
				) else (
					set "profileName=default-release-%count0%"
				)
		) else (
			set "profileName=default-release"
		)
) else (
	set "profileName=default-release"
)


echo. & echo Injecting profile...
@echo ON

:: This could also be set manually in the profiles.ini file
mkdir "%~1\Mozilla\Firefox\Profiles\%RNDStr%.%profileName%"
robocopy "%~dp0\AME-Firefox-Injection" "%~1\Mozilla\Firefox\Profiles\%RNDStr%.%profileName%" /E /xf "3647222921wleabcEoxlt-eengsairo.sqlite" > NUL
mkdir "%~1\Mozilla\Firefox\Profiles\%RNDStr%.%profileName%\storage\default\moz-extension+++41087662-660a-4251-8c0c-38aa4da5b325^userContextId=4294967295\idb"
copy /y "%~dp0\AME-Firefox-Injection\3647222921wleabcEoxlt-eengsairo.sqlite" "%~1\Mozilla\Firefox\Profiles\%RNDStr%.%profileName%\storage\default\moz-extension+++41087662-660a-4251-8c0c-38aa4da5b325^userContextId=4294967295\idb"

:: Sets profile as the default
echo [Install%NewCode%]>> "%~1\Mozilla\Firefox\profiles.ini"
echo Default=Profiles/%RNDStr%.%profileName%>> "%~1\Mozilla\Firefox\profiles.ini"
echo Locked=^1>> "%~1\Mozilla\Firefox\profiles.ini"
echo.>> "%~1\Mozilla\Firefox\profiles.ini"
echo [Profile0]>> "%~1\Mozilla\Firefox\profiles.ini"
echo Name=%profileName%>> "%~1\Mozilla\Firefox\profiles.ini"
echo IsRelative=^1>> "%~1\Mozilla\Firefox\profiles.ini"
echo Path=Profiles/%RNDStr%.%profileName%>> "%~1\Mozilla\Firefox\profiles.ini"

:: Add prefs to any other Firefox profiles in all users

@echo OFF
for /f "usebackq delims=" %%B in (`dir /B /A:d "%~1\Mozilla\Firefox\Profiles" ^| findstr /v /x /c:"%RNDStr%.%profileName%"`) do (
	if exist "%~1\Mozilla\Firefox\Profiles\%%B\prefs.js" (
		:: Removes lines containing these entries from the profiles prefs.js. This way any old prefs don't overlap with the new prefs
		echo findstr /V /C:""""app.shield.optoutstudies.enabled"""" /C:""""browser.aboutwelcome.enabled"""" /C:""""browser.disableResetPrompt"""" /C:""""browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons"""" /C:""""browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features"""" /C:""""browser.newtabpage.activity-stream.feeds.section.topstories"""" /C:""""browser.newtabpage.activity-stream.feeds.topsites"""" /C:""""browser.newtabpage.activity-stream.section.highlights.includePocket"""" /C:""""browser.newtabpage.activity-stream.section.highlights.includeVisited"""" /C:""""browser.newtabpage.activity-stream.showSponsored"""" /C:""""browser.newtabpage.activity-stream.showSponsoredTopSites"""" /C:""""browser.urlbar.placeholderNam"""" /C:""""browser.urlbar.suggest.quicksuggest.nonsponsored"""" /C:""""browser.urlbar.suggest.quicksuggest.sponsored"""" /C:""""browser.urlbar.suggest.topsites"""" /C:""""datareporting.healthreport.uploadEnabled"""" /C:""""dom.security.https_only_mode"""" /C:""""dom.security.https_only_mode_ever_enabled"""" "%~1\Mozilla\Firefox\Profiles\%%B\prefs.js "^>^> "%TEMP%\prefs.js.tmp"
		findstr /V /C:""""app.shield.optoutstudies.enabled"""" /C:""""browser.aboutwelcome.enabled"""" /C:""""browser.disableResetPrompt"""" /C:""""browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons"""" /C:""""browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features"""" /C:""""browser.newtabpage.activity-stream.feeds.section.topstories"""" /C:""""browser.newtabpage.activity-stream.feeds.topsites"""" /C:""""browser.newtabpage.activity-stream.section.highlights.includePocket"""" /C:""""browser.newtabpage.activity-stream.section.highlights.includeVisited"""" /C:""""browser.newtabpage.activity-stream.showSponsored"""" /C:""""browser.newtabpage.activity-stream.showSponsoredTopSites"""" /C:""""browser.urlbar.placeholderNam"""" /C:""""browser.urlbar.suggest.quicksuggest.nonsponsored"""" /C:""""browser.urlbar.suggest.quicksuggest.sponsored"""" /C:""""browser.urlbar.suggest.topsites"""" /C:""""datareporting.healthreport.uploadEnabled"""" /C:""""dom.security.https_only_mode"""" /C:""""dom.security.https_only_mode_ever_enabled"""" "%~1\Mozilla\Firefox\Profiles\%%B\prefs.js ">> "%TEMP%\prefs.js.tmp"
	)
	:: Filters out a few prefs from AME-Firefox-Injectiont\prefs.js and adds them to prefs.js.tmp
	echo findstr /V /C:""""browser.toolbars.bookmarks.visibility"""" /C:""""extensions.webextensions.uuids"""" /C:""""extensions.webextensions.uuids"""" "%~dp0\AME-Firefox-Injection\prefs.js"^>^> "%TEMP%\prefs.js.tmp"
	findstr /V /C:""""browser.toolbars.bookmarks.visibility"""" /C:""""extensions.webextensions.uuids"""" /C:""""extensions.webextensions.uuids"""" "%~dp0\AME-Firefox-Injection\prefs.js">> "%TEMP%\prefs.js.tmp"
	echo move /y "%TEMP%\prefs.js.tmp" "%~1\Mozilla\Firefox\Profiles\%%B\prefs.js"
	move /y "%TEMP%\prefs.js.tmp" "%~1\Mozilla\Firefox\Profiles\%%B\prefs.js"
	if exist "%~1\Mozilla\Firefox\Profiles\%%B\search.json.mozlz4" echo del /Q /F "%~1\Mozilla\Firefox\Profiles\%%B\search.json.mozlz4" & del /Q /F "%~1\Mozilla\Firefox\Profiles\%%B\search.json.mozlz4"
	echo robocopy "%~dp0\AME-Firefox-Injection" "%~1\Mozilla\Firefox\Profiles\%%B" search.json.mozlz4 /E ^> NUL
	robocopy "%~dp0\AME-Firefox-Injection" "%~1\Mozilla\Firefox\Profiles\%%B" search.json.mozlz4 /E > NUL
	echo PowerShell -NoP -C "%~1\Mozilla\Firefox\Profiles' | Set-Acl '%~1\Mozilla\Firefox\Profiles\%%B\prefs.js'" ^> NUL 2^>^&1
	PowerShell -NoP -C "%~1\Mozilla\Firefox\Profiles' | Set-Acl '%~1\Mozilla\Firefox\Profiles\%%B\prefs.js'" > NUL 2>&1
	echo PowerShell -NoP -C "Get-Acl '%~1\Mozilla\Firefox\Profiles' | Set-Acl '%~1\Mozilla\Firefox\Profiles\%%B\search.json.mozlz4'" ^> NUL 2^>^&1
	PowerShell -NoP -C "Get-Acl '%~1\Mozilla\Firefox\Profiles' | Set-Acl '%~1\Mozilla\Firefox\Profiles\%%B\search.json.mozlz4'" > NUL 2>&1
)

echo. & echo Successfully injected custom Firefox configs.
endlocal & exit /b 0

:PREFSONLY

:: uBlock Origin could be installed automatically here, however that would involve overwriting the old extension.json etc
:: files, which, if the user had previous extensions, could cause issues.

@echo. & echo Injecting config files...

if exist "%TEMP%\prefs.js.tmp" del /q /f "%TEMP%\prefs.js.tmp" > NUL

set /a "count3=0"

@echo OFF

if exist "%~1\Mozilla\Firefox\Profiles" (
	for /f "usebackq delims=" %%A in (`dir /B /A:d "%~1\Mozilla\Firefox\Profiles"`) do (
		set /a "count3=%count3%+1"
		if exist "%~1\Mozilla\Firefox\Profiles\%%A\prefs.js" (
			:: Removes lines containing these entries from the profiles prefs.js. This way any old prefs don't overlap with the new prefs
			echo findstr /V /C:""""app.shield.optoutstudies.enabled"""" /C:""""browser.aboutwelcome.enabled"""" /C:""""browser.disableResetPrompt"""" /C:""""browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons"""" /C:""""browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features"""" /C:""""browser.newtabpage.activity-stream.feeds.section.topstories"""" /C:""""browser.newtabpage.activity-stream.feeds.topsites"""" /C:""""browser.newtabpage.activity-stream.section.highlights.includePocket"""" /C:""""browser.newtabpage.activity-stream.section.highlights.includeVisited"""" /C:""""browser.newtabpage.activity-stream.showSponsored"""" /C:""""browser.newtabpage.activity-stream.showSponsoredTopSites"""" /C:""""browser.urlbar.placeholderNam"""" /C:""""browser.urlbar.suggest.quicksuggest.nonsponsored"""" /C:""""browser.urlbar.suggest.quicksuggest.sponsored"""" /C:""""browser.urlbar.suggest.topsites"""" /C:""""datareporting.healthreport.uploadEnabled"""" /C:""""dom.security.https_only_mode"""" /C:""""dom.security.https_only_mode_ever_enabled"""" "%~1\Mozilla\Firefox\Profiles\%%A\prefs.js "^>^> "%TEMP%\prefs.js.tmp"
			findstr /V /C:""""app.shield.optoutstudies.enabled"""" /C:""""browser.aboutwelcome.enabled"""" /C:""""browser.disableResetPrompt"""" /C:""""browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons"""" /C:""""browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features"""" /C:""""browser.newtabpage.activity-stream.feeds.section.topstories"""" /C:""""browser.newtabpage.activity-stream.feeds.topsites"""" /C:""""browser.newtabpage.activity-stream.section.highlights.includePocket"""" /C:""""browser.newtabpage.activity-stream.section.highlights.includeVisited"""" /C:""""browser.newtabpage.activity-stream.showSponsored"""" /C:""""browser.newtabpage.activity-stream.showSponsoredTopSites"""" /C:""""browser.urlbar.placeholderNam"""" /C:""""browser.urlbar.suggest.quicksuggest.nonsponsored"""" /C:""""browser.urlbar.suggest.quicksuggest.sponsored"""" /C:""""browser.urlbar.suggest.topsites"""" /C:""""datareporting.healthreport.uploadEnabled"""" /C:""""dom.security.https_only_mode"""" /C:""""dom.security.https_only_mode_ever_enabled"""" "%~1\Mozilla\Firefox\Profiles\%%A\prefs.js ">> "%TEMP%\prefs.js.tmp"
		)
		:: Filters out a few prefs from AME-Firefox-Injectiont\prefs.js and adds them to prefs.js.tmp
		echo findstr /V /C:""""browser.toolbars.bookmarks.visibility"""" /C:""""extensions.webextensions.uuids"""" /C:""""extensions.webextensions.uuids"""" "%~dp0\AME-Firefox-Injection\prefs.js"^>^> "%TEMP%\prefs.js.tmp"
		findstr /V /C:""""browser.toolbars.bookmarks.visibility"""" /C:""""extensions.webextensions.uuids"""" /C:""""extensions.webextensions.uuids"""" "%~dp0\AME-Firefox-Injection\prefs.js">> "%TEMP%\prefs.js.tmp"
		echo move /y "%TEMP%\prefs.js.tmp" "%~1\Mozilla\Firefox\Profiles\%%A\prefs.js"
		move /y "%TEMP%\prefs.js.tmp" "%~1\Mozilla\Firefox\Profiles\%%A\prefs.js"
		if exist "%~1\Mozilla\Firefox\Profiles\%%A\search.json.mozlz4" echo del /Q /F "%~1\Mozilla\Firefox\Profiles\%%A\search.json.mozlz4" & del /Q /F "%~1\Mozilla\Firefox\Profiles\%%A\search.json.mozlz4"
		echo robocopy "%~dp0\AME-Firefox-Injection" "%~1\Mozilla\Firefox\Profiles\%%A" search.json.mozlz4 /E ^> NUL
		robocopy "%~dp0\AME-Firefox-Injection" "%~1\Mozilla\Firefox\Profiles\%%A" search.json.mozlz4 /E > NUL
	
		echo PowerShell -NoP -C "Get-Acl '%~1\Mozilla\Firefox\Profiles' | Set-Acl '%~1\Mozilla\Firefox\Profiles\%%A\prefs.js'" ^> NUL 2^>^&1
		PowerShell -NoP -C "Get-Acl '%~1\Mozilla\Firefox\Profiles' | Set-Acl '%~1\Mozilla\Firefox\Profiles\%%A\prefs.js'" > NUL 2>&1
		echo PowerShell -NoP -C "Get-Acl '%~1\Mozilla\Firefox\Profiles' | Set-Acl '%~1\Mozilla\Firefox\Profiles\%%A\search.json.mozlz4'" ^> NUL 2^>^&1
		PowerShell -NoP -C "Get-Acl '%~1\Mozilla\Firefox\Profiles' | Set-Acl '%~1\Mozilla\Firefox\Profiles\%%A\search.json.mozlz4'" > NUL 2>&1
	)
)

if %count3% EQU 0 (
	echo. & echo Failed! No profiles detected
	endlocal & exit /b 2
) else (
	echo. & echo Successfully injected custom Firefox configs.
	endlocal & exit /b 1
)

exit /b 0

:setAssociations

for /f "usebackq tokens=2 delims=\" %%A in (`reg query "HKEY_USERS" ^| findstr /r /x /c:"HKEY_USERS\\S-.*" /c:"HKEY_USERS\\AME_UserHive_[^_]*"`) do (
	REM If the "Volatile Environment" key exists, that means it is a proper user. Built in accounts/SIDs don't have this key.
	reg query "HKU\%%A" | findstr /c:"Volatile Environment" /c:"AME_UserHive_" > NUL 2>&1
		if not errorlevel 1 (
			PowerShell -NoP -ExecutionPolicy Bypass -File assoc.ps1 "Placeholder" "%%A" ".html:FirefoxHTML-308046B0AF4A39CB" ".htm:FirefoxHTML-308046B0AF4A39CB" "Proto:https:FirefoxURL-308046B0AF4A39CB" "Proto:http:FirefoxURL-308046B0AF4A39CB"
	)
)