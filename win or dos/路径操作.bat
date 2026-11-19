@echo off

set TEST_PATH=%~f0
set RESULT

echo 测试文件路径
echo %TEST_PATH%
echo.

echo 文件绝对路径
for %%I in (%TEST_PATH%) do ( echo %%~fI)
echo %~f0
echo.

echo 文件所在文件夹(带反斜杠)
for %%I in (%TEST_PATH%) do ( echo %%~dpI)
echo %~dp0
echo.

echo 驱动器号
for %%I in (%TEST_PATH%) do ( echo %%~dI)
echo %~d0
echo.

echo 文件所在文件夹(带反斜杠, 不含驱动器号)
for %%I in (%TEST_PATH%) do ( echo %%~pI)
echo %~p0
echo.

echo 文件名(不含扩展名)
for %%I in (%TEST_PATH%) do ( echo %%~nI)
echo %~n0
echo.

echo 扩展名
for %%I in (%TEST_PATH%) do ( echo %%~xI)
echo %~x0
echo.

echo 函数调用: 获取文件名(含扩展名)
call :GetFileName %0
echo %RESULT%
echo.

echo 函数调用: 获取文件名(不含扩展名)
call :GetFileNameWithoutExtName %0
echo %RESULT%
echo.

echo 函数调用: 获取扩展名
call :GetExtName %0
echo %RESULT%
echo.

echo 函数调用: 获取驱动器号
call :GetDirver %0
echo %RESULT%
echo.

echo 函数调用: 获取文件所在文件夹
call :GetDirectory %0
echo %RESULT%
echo.

echo 函数调用: 获取文件路径
call :GetFilePath %0
echo %RESULT%
echo.

pause
goto:eof

rem 获取文件全路径
:GetFilePath
set param=%~1
set RESULT=
for %%I in (%param%) do ( set RESULT=%%~fI)
goto:eof

rem 获取文件名(含扩展名)
:GetFileName
set param=%~1
set RESULT=
for %%I in (%param%) do ( set RESULT=%%~nxI)
goto:eof

rem 获取文件名(不含扩展名)
:GetFileNameWithoutExtName
set param=%~1
set RESULT=
for %%I in (%param%) do ( set RESULT=%%~nI)
goto:eof

rem 获取文件扩展名
:GetExtName
set param=%~1
set RESULT=
for %%I in (%param%) do ( set RESULT=%%~xI)
goto:eof

rem 获取文件驱动器号
:GetDirver
set param=%~1
set RESULT=
for %%I in (%param%) do ( set RESULT=%%~dI)
goto:eof

rem 获取文件所在目录
:GetDirectory
set param=%~1
set RESULT=
for %%I in (%param%) do ( set RESULT=%%~dpI)
set RESULT=%RESULT:~0,-1%
goto:eof
