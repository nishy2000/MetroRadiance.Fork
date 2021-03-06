@ECHO OFF
SETLOCAL enabledelayedexpansion
SET BAT_FOLDER=%~d0%~p0
SET DATE_TIME=%DATE:/=%_%TIME::=%
SET DATE_TIME=%DATE_TIME: =0%
SET SRC_FOLDER=%BAT_FOLDER%..\source
SET WORK_FOLDERNAME=Package_%DATE_TIME%
SET WORK_FOLDER=%BAT_FOLDER%%WORK_FOLDERNAME%
SET SIGNED_FOLER=%WORK_FOLDER%\signed
SET UNSIGNED_FOLER=%WORK_FOLDER%\unsigned
SET CERT_SUBJECT_NAME=nishy software

COLOR F

IF NOT "x-" == "x-%SIGNTOOL%" SET SIGNTOOL=%SIGNTOOL:"=%
ECHO signtool: "%SIGNTOOL%"
IF NOT EXIST "%SIGNTOOL%" (
    ECHO Pease SET SIGNTOOL=sign batch file path
    COLOR 6F
    PAUSE
    COLOR F
    GOTO END
)

mkdir "%WORK_FOLDER%"
PUSHD "%SRC_FOLDER%"

REM  Rebuild modules
ECHO =======================
ECHO Rebuild modules
ECHO -----------------------
dotnet.exe build -c Release --no-incremental --no-dependencies MetroRadiance.Core\MetroRadiance.Core.csproj
IF ERRORLEVEL 1 GOTO ERROR
dotnet.exe build -c Release --no-incremental --no-dependencies MetroRadiance.Chrome\MetroRadiance.Chrome.csproj
IF ERRORLEVEL 1 GOTO ERROR
dotnet.exe build -c Release --no-incremental --no-dependencies MetroRadiance.Chrome.Externals\MetroRadiance.Chrome.Externals.csproj
IF ERRORLEVEL 1 GOTO ERROR
dotnet.exe build -c Release --no-incremental --no-dependencies MetroRadiance\MetroRadiance.csproj
IF ERRORLEVEL 1 GOTO ERROR
dotnet.exe build -c Release --no-incremental --no-dependencies ..\samples\MetroRadiance.Showcase\MetroRadiance.Showcase.csproj
IF ERRORLEVEL 1 GOTO ERROR


REM  Backup unsigned modules
ECHO =======================
ECHO Backup unsigned modules
ECHO -----------------------

mkdir "%UNSIGNED_FOLER%"

REM  MetroRadiance.Showcase modules
XCOPY /D /E "..\samples\MetroRadiance.Showcase\bin\Release" "%UNSIGNED_FOLER%\MetroRadiance.Showcase\"
IF ERRORLEVEL 1 GOTO ERROR

REM  MetroRadiance modules
XCOPY /D /E "MetroRadiance\bin\Release" "%UNSIGNED_FOLER%\MetroRadiance\" > nul
IF ERRORLEVEL 1 GOTO ERROR

REM  MetroRadiance.Chrome.Externals modules
XCOPY /D /E "MetroRadiance.Chrome.Externals\bin\Release" "%UNSIGNED_FOLER%\MetroRadiance.Chrome.Externals\" > nul
IF ERRORLEVEL 1 GOTO ERROR

REM  MetroRadiance.Chrome modules
XCOPY /D /E "MetroRadiance.Chrome\bin\Release" "%UNSIGNED_FOLER%\MetroRadiance.Chrome\" > nul
IF ERRORLEVEL 1 GOTO ERROR

REM  MetroRadiance.Core modules
XCOPY /D /E "MetroRadiance.Core\bin\Release" "%UNSIGNED_FOLER%\MetroRadiance.Core\" > nul
IF ERRORLEVEL 1 GOTO ERROR


REM  Sign modules
ECHO =======================
ECHO Sign modules
ECHO -----------------------
SET SIGN_FILES=
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance.Core\bin\Release\net45\MetroRadiance.Core.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance.Core\bin\Release\net462\MetroRadiance.Core.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance.Core\bin\Release\netcoreapp3.1\MetroRadiance.Core.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance.Chrome\bin\Release\net45\MetroRadiance.Chrome.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance.Chrome\bin\Release\netcoreapp3.1\MetroRadiance.Chrome.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance.Chrome.Externals\bin\Release\net45\MetroRadiance.Chrome.Externals.dll"
IF EXIST "MetroRadiance.Chrome.Externals\bin\Release\netcoreapp3.1\MetroRadiance.Chrome.Externals.dll" (
    SET SIGN_FILES=%SIGN_FILES% "MetroRadiance.Chrome.Externals\bin\Release\netcoreapp3.1\MetroRadiance.Chrome.Externals.dll"
)
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\net45\MetroRadiance.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\net45\de\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\net45\fr\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\net45\ja\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\net45\ko\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\net45\zh-Hans\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\net45\zh-Hant\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\net462\MetroRadiance.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\net462\de\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\net462\fr\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\net462\ja\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\net462\ko\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\net462\zh-Hans\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\net462\zh-Hant\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\netcoreapp3.1\MetroRadiance.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\netcoreapp3.1\de\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\netcoreapp3.1\fr\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\netcoreapp3.1\ja\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\netcoreapp3.1\ko\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\netcoreapp3.1\zh-Hans\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "MetroRadiance\bin\Release\netcoreapp3.1\zh-Hant\MetroRadiance.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "..\samples\MetroRadiance.Showcase\bin\Release\net452\MetroRadiance.Showcase.exe"
SET SIGN_FILES=%SIGN_FILES% "..\samples\MetroRadiance.Showcase\bin\Release\net452\ja\MetroRadiance.Showcase.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "..\samples\MetroRadiance.Showcase\bin\Release\net462\MetroRadiance.Showcase.exe"
SET SIGN_FILES=%SIGN_FILES% "..\samples\MetroRadiance.Showcase\bin\Release\net462\ja\MetroRadiance.Showcase.resources.dll"
SET SIGN_FILES=%SIGN_FILES% "..\samples\MetroRadiance.Showcase\bin\Release\netcoreapp3.1\MetroRadiance.Showcase.exe"
SET SIGN_FILES=%SIGN_FILES% "..\samples\MetroRadiance.Showcase\bin\Release\netcoreapp3.1\MetroRadiance.Showcase.dll"
SET SIGN_FILES=%SIGN_FILES% "..\samples\MetroRadiance.Showcase\bin\Release\netcoreapp3.1\ja\MetroRadiance.Showcase.resources.dll"

SETLOCAL
CALL "%SIGNTOOL%" %SIGN_FILES%
ENDLOCAL


REM  Backup signed modules
ECHO =====================
ECHO Backup signed modules
ECHO -----------------------

mkdir "%SIGNED_FOLER%"
mkdir "%SIGNED_FOLER%\net45"
mkdir "%SIGNED_FOLER%\net45\fr"
mkdir "%SIGNED_FOLER%\net45\de"
mkdir "%SIGNED_FOLER%\net45\ko"
mkdir "%SIGNED_FOLER%\net45\ja"
mkdir "%SIGNED_FOLER%\net45\zh-Hans"
mkdir "%SIGNED_FOLER%\net45\zh-Hant"
mkdir "%SIGNED_FOLER%\net452"
mkdir "%SIGNED_FOLER%\net452\ja"
mkdir "%SIGNED_FOLER%\net462"
mkdir "%SIGNED_FOLER%\net462\fr"
mkdir "%SIGNED_FOLER%\net462\de"
mkdir "%SIGNED_FOLER%\net462\ko"
mkdir "%SIGNED_FOLER%\net462\ja"
mkdir "%SIGNED_FOLER%\net462\zh-Hans"
mkdir "%SIGNED_FOLER%\net462\zh-Hant"
mkdir "%SIGNED_FOLER%\netcoreapp3.1"
mkdir "%SIGNED_FOLER%\netcoreapp3.1\fr"
mkdir "%SIGNED_FOLER%\netcoreapp3.1\de"
mkdir "%SIGNED_FOLER%\netcoreapp3.1\ko"
mkdir "%SIGNED_FOLER%\netcoreapp3.1\ja"
mkdir "%SIGNED_FOLER%\netcoreapp3.1\zh-Hans"
mkdir "%SIGNED_FOLER%\netcoreapp3.1\zh-Hant"

REM  MetroRadiance.Core modules
COPY "MetroRadiance.Core\bin\Release\net45\MetroRadiance.Core.dll" "%SIGNED_FOLER%\net45\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "MetroRadiance.Core\bin\Release\net462\MetroRadiance.Core.dll" "%SIGNED_FOLER%\net462\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "MetroRadiance.Core\bin\Release\netcoreapp3.1\MetroRadiance.Core.dll" "%SIGNED_FOLER%\netcoreapp3.1\" >nul
IF ERRORLEVEL 1 GOTO ERROR

REM  MetroRadiance.Chrome modules
COPY "MetroRadiance.Chrome\bin\Release\net45\MetroRadiance.Chrome.dll" "%SIGNED_FOLER%\net45\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "MetroRadiance.Chrome\bin\Release\netcoreapp3.1\MetroRadiance.Chrome.dll" "%SIGNED_FOLER%\netcoreapp3.1\" >nul
IF ERRORLEVEL 1 GOTO ERROR

REM  MetroRadiance.Chrome.Externals modules
COPY "MetroRadiance.Chrome.Externals\bin\Release\net45\MetroRadiance.Chrome.Externals.dll" "%SIGNED_FOLER%\net45\" >nul
IF ERRORLEVEL 1 GOTO ERROR
IF EXIST "MetroRadiance.Chrome.Externals\bin\Release\netcoreapp3.1\MetroRadiance.Chrome.Externals.dll" (
    COPY "MetroRadiance.Chrome.Externals\bin\Release\netcoreapp3.1\MetroRadiance.Chrome.Externals.dll" "%SIGNED_FOLER%\netcoreapp3.1\" >nul
    IF ERRORLEVEL 1 GOTO ERROR
)

REM  MetroRadiance modules
SET COPY_SOURCE=MetroRadiance\bin\Release\net45
SET COPY_DEST=%SIGNED_FOLER%\net45
COPY "%COPY_SOURCE%\MetroRadiance.dll" "%COPY_DEST%\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\fr\MetroRadiance.resources.dll" "%COPY_DEST%\fr\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\de\MetroRadiance.resources.dll" "%COPY_DEST%\de\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\ko\MetroRadiance.resources.dll" "%COPY_DEST%\ko\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\ja\MetroRadiance.resources.dll" "%COPY_DEST%\ja\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\zh-Hans\MetroRadiance.resources.dll" "%COPY_DEST%\zh-Hans\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\zh-Hant\MetroRadiance.resources.dll" "%COPY_DEST%\zh-Hant\" >nul
IF ERRORLEVEL 1 GOTO ERROR

SET COPY_SOURCE=MetroRadiance\bin\Release\net462
SET COPY_DEST=%SIGNED_FOLER%\net462
COPY "%COPY_SOURCE%\MetroRadiance.dll" "%COPY_DEST%\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\fr\MetroRadiance.resources.dll" "%COPY_DEST%\fr\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\de\MetroRadiance.resources.dll" "%COPY_DEST%\de\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\ko\MetroRadiance.resources.dll" "%COPY_DEST%\ko\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\ja\MetroRadiance.resources.dll" "%COPY_DEST%\ja\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\zh-Hans\MetroRadiance.resources.dll" "%COPY_DEST%\zh-Hans\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\zh-Hant\MetroRadiance.resources.dll" "%COPY_DEST%\zh-Hant\" >nul
IF ERRORLEVEL 1 GOTO ERROR

SET COPY_SOURCE=MetroRadiance\bin\Release\netcoreapp3.1
SET COPY_DEST=%SIGNED_FOLER%\netcoreapp3.1
COPY "%COPY_SOURCE%\MetroRadiance.dll" "%COPY_DEST%\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\fr\MetroRadiance.resources.dll" "%COPY_DEST%\fr\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\de\MetroRadiance.resources.dll" "%COPY_DEST%\de\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\ko\MetroRadiance.resources.dll" "%COPY_DEST%\ko\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\ja\MetroRadiance.resources.dll" "%COPY_DEST%\ja\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\zh-Hans\MetroRadiance.resources.dll" "%COPY_DEST%\zh-Hans\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\zh-Hant\MetroRadiance.resources.dll" "%COPY_DEST%\zh-Hant\" >nul
IF ERRORLEVEL 1 GOTO ERROR

REM  MetroRadiance.Showcase modules
COPY "..\samples\MetroRadiance.Showcase\bin\Release\net452\MetroRadiance.Showcase.exe" "%SIGNED_FOLER%\net452\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "..\samples\MetroRadiance.Showcase\bin\Release\net452\ja\MetroRadiance.Showcase.resources.dll" "%SIGNED_FOLER%\net452\ja\" >nul
IF ERRORLEVEL 1 GOTO ERROR

COPY "..\samples\MetroRadiance.Showcase\bin\Release\net462\MetroRadiance.Showcase.exe" "%SIGNED_FOLER%\net462\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "..\samples\MetroRadiance.Showcase\bin\Release\net462\ja\MetroRadiance.Showcase.resources.dll" "%SIGNED_FOLER%\net462\ja\" >nul
IF ERRORLEVEL 1 GOTO ERROR

COPY "..\samples\MetroRadiance.Showcase\bin\Release\netcoreapp3.1\MetroRadiance.Showcase.exe" "%SIGNED_FOLER%\netcoreapp3.1\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "..\samples\MetroRadiance.Showcase\bin\Release\netcoreapp3.1\MetroRadiance.Showcase.dll" "%SIGNED_FOLER%\netcoreapp3.1\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "..\samples\MetroRadiance.Showcase\bin\Release\netcoreapp3.1\ja\MetroRadiance.Showcase.resources.dll" "%SIGNED_FOLER%\netcoreapp3.1\ja\" >nul
IF ERRORLEVEL 1 GOTO ERROR

REM  Copy signed resource files to obj folder
ECHO =======================
ECHO Copy signed resource files to obj folder
ECHO -----------------------

REM  MetroRadiance modules
SET COPY_SOURCE=MetroRadiance\bin\Release\net45
SET COPY_DEST=MetroRadiance\obj\Release\net45
COPY "%COPY_SOURCE%\MetroRadiance.dll" "%COPY_DEST%\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\fr\MetroRadiance.resources.dll" "%COPY_DEST%\fr\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\de\MetroRadiance.resources.dll" "%COPY_DEST%\de\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\ko\MetroRadiance.resources.dll" "%COPY_DEST%\ko\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\ja\MetroRadiance.resources.dll" "%COPY_DEST%\ja\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\zh-Hans\MetroRadiance.resources.dll" "%COPY_DEST%\zh-Hans\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\zh-Hant\MetroRadiance.resources.dll" "%COPY_DEST%\zh-Hant\" >nul
IF ERRORLEVEL 1 GOTO ERROR

SET COPY_SOURCE=MetroRadiance\bin\Release\net462
SET COPY_DEST=MetroRadiance\obj\Release\net462
COPY "%COPY_SOURCE%\MetroRadiance.dll" "%COPY_DEST%\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\fr\MetroRadiance.resources.dll" "%COPY_DEST%\fr\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\de\MetroRadiance.resources.dll" "%COPY_DEST%\de\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\ko\MetroRadiance.resources.dll" "%COPY_DEST%\ko\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\ja\MetroRadiance.resources.dll" "%COPY_DEST%\ja\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\zh-Hans\MetroRadiance.resources.dll" "%COPY_DEST%\zh-Hans\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\zh-Hant\MetroRadiance.resources.dll" "%COPY_DEST%\zh-Hant\" >nul
IF ERRORLEVEL 1 GOTO ERROR

SET COPY_SOURCE=MetroRadiance\bin\Release\netcoreapp3.1
SET COPY_DEST=MetroRadiance\obj\Release\netcoreapp3.1
COPY "%COPY_SOURCE%\MetroRadiance.dll" "%COPY_DEST%\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\fr\MetroRadiance.resources.dll" "%COPY_DEST%\fr\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\de\MetroRadiance.resources.dll" "%COPY_DEST%\de\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\ko\MetroRadiance.resources.dll" "%COPY_DEST%\ko\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\ja\MetroRadiance.resources.dll" "%COPY_DEST%\ja\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\zh-Hans\MetroRadiance.resources.dll" "%COPY_DEST%\zh-Hans\" >nul
IF ERRORLEVEL 1 GOTO ERROR
COPY "%COPY_SOURCE%\zh-Hant\MetroRadiance.resources.dll" "%COPY_DEST%\zh-Hant\" >nul
IF ERRORLEVEL 1 GOTO ERROR

REM  MetroRadiance.Showcase modules
COPY "..\samples\MetroRadiance.Showcase\bin\Release\net452\ja\MetroRadiance.Showcase.resources.dll" "..\samples\MetroRadiance.Showcase\obj\Release\net452\ja\MetroRadiance.Showcase.resources.dll" >nul
IF ERRORLEVEL 1 GOTO ERROR

COPY "..\samples\MetroRadiance.Showcase\bin\Release\net462\ja\MetroRadiance.Showcase.resources.dll" "..\samples\MetroRadiance.Showcase\obj\Release\net462\ja\MetroRadiance.Showcase.resources.dll" >nul
IF ERRORLEVEL 1 GOTO ERROR

COPY "..\samples\MetroRadiance.Showcase\bin\Release\netcoreapp3.1\ja\MetroRadiance.Showcase.resources.dll" "..\samples\MetroRadiance.Showcase\obj\Release\netcoreapp3.1\ja\MetroRadiance.Showcase.resources.dll" >nul
IF ERRORLEVEL 1 GOTO ERROR


REM  Packaging
ECHO =======================
ECHO Packaging
ECHO -----------------------

dotnet.exe pack -c Release --no-build -o "%WORK_FOLDER%" MetroRadiance.Core\MetroRadiance.Core.csproj
IF ERRORLEVEL 1 GOTO ERROR
dotnet.exe pack -c Release --no-build -o "%WORK_FOLDER%" MetroRadiance.Chrome\MetroRadiance.Chrome.csproj
IF ERRORLEVEL 1 GOTO ERROR
dotnet.exe pack -c Release --no-build -o "%WORK_FOLDER%" MetroRadiance.Chrome.Externals\MetroRadiance.Chrome.Externals.csproj
IF ERRORLEVEL 1 GOTO ERROR
dotnet.exe pack -c Release --no-build -o "%WORK_FOLDER%" MetroRadiance\MetroRadiance.csproj
IF ERRORLEVEL 1 GOTO ERROR
dotnet.exe pack -c Release --no-build -o "%WORK_FOLDER%" ..\samples\MetroRadiance.Showcase\MetroRadiance.Showcase.csproj
IF ERRORLEVEL 1 GOTO ERROR


REM  Backup packages
ECHO =======================
ECHO Backup packages
ECHO -----------------------

FOR %%i in (%WORK_FOLDER%\*.nupkg) do (
    COPY "%%i" "%SIGNED_FOLER%" > nul
    MOVE "%%i" "%UNSIGNED_FOLER%\%%~ni_unsigned%%~xi" > nul
)

REM  Create MetroRadiance.Fork.Showcase folder
ECHO =======================
ECHO Create MetroRadiance.Fork.Showcase folder
ECHO -----------------------

XCOPY /D /E "%UNSIGNED_FOLER%\MetroRadiance.Showcase" "%SIGNED_FOLER%\MetroRadiance.Fork.Showcase\" > nul
IF ERRORLEVEL 1 GOTO ERROR
XCOPY /D /E /Y "%SIGNED_FOLER%\net45" "%SIGNED_FOLER%\MetroRadiance.Fork.Showcase\net452\" > nul
IF ERRORLEVEL 1 GOTO ERROR
XCOPY /D /E /Y "%SIGNED_FOLER%\net452" "%SIGNED_FOLER%\MetroRadiance.Fork.Showcase\net452\" > nul
IF ERRORLEVEL 1 GOTO ERROR
XCOPY /D /E /Y "%SIGNED_FOLER%\net45" "%SIGNED_FOLER%\MetroRadiance.Fork.Showcase\net462\" > nul
IF ERRORLEVEL 1 GOTO ERROR
XCOPY /D /E /Y "%SIGNED_FOLER%\net462" "%SIGNED_FOLER%\MetroRadiance.Fork.Showcase\net462\" > nul
IF ERRORLEVEL 1 GOTO ERROR
XCOPY /D /E /Y "%SIGNED_FOLER%\netcoreapp3.1" "%SIGNED_FOLER%\MetroRadiance.Fork.Showcase\netcoreapp3.1\" > nul
IF ERRORLEVEL 1 GOTO ERROR

REM  Sign packages
ECHO =======================
ECHO Sign packages
ECHO -----------------------

FOR %%i in ("%WORK_FOLDER%\signed\*.nupkg") do (
    echo sign: %%~ni%%~xi
    "%BAT_FOLDER%nuget.exe" sign "%%i" -Verbosity quiet -CertificateSubjectName "%CERT_SUBJECT_NAME%"  -Timestamper "http://sha256timestamp.ws.symantec.com/sha256/timestamp" 
    IF ERRORLEVEL 1 GOTO ERROR
)

GOTO END

:ERROR
ECHO ERROR occurred
COLOR C1
PAUSE
COLOR F

:END
ECHO =======================
ECHO Output folder: "%WORK_FOLDERNAME%"

POPD
ENDLOCAL
EXIT /B