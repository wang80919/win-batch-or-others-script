@echo off

echo 遍历当前路径下的文件夹
rem FOR /D %variable IN (set) DO command [command-parameters]
FOR /D %%i IN (*) DO (
    echo %%i
)
echo.

echo 遍历指定路径下的所有文件
rem FOR /R [[drive:]path] %variable IN (set) DO command [command-parameters]
FOR /R "Test_Dir" %%i IN (*) DO (
    echo %%i
)
echo.

echo 遍历0-10范围内数值, 增量为1
rem FOR /L %variable IN (start,step,end) DO command [command-parameters]
FOR /L %%i IN (1,1,10) DO (
    echo %%i
)
echo.

echo 遍历10-0范围内数值, 增量为1
rem FOR /L %variable IN (start,step,end) DO command [command-parameters]
FOR /L %%i IN (10,-1,0) DO (
    echo %%i
)
echo.

echo 遍历指定文件的内容
rem FOR /F ["options"] %variable IN (file-set) DO command [command-parameters]
FOR /F "usebackq" %%i IN ("text1.txt","text2.txt")  DO (
    echo %%i
)

echo 遍历指定文件的内容
rem FOR /F ["options"] %variable IN (file-set) DO command [command-parameters]
FOR /F "usebackq delims==" %%i IN ("路径操作.bat")  DO (
    echo %%i
)

echo 遍历指定字符串的内容, 使用,分隔(会忽略分隔符后的内容)
rem FOR /F ["options"] %variable IN ("string") DO command [command-parameters]
FOR /F "delims=," %%i IN ("123,456,789,ABC,DEF")  DO (
    echo %%i
)

set TEST_STR="123,456,789,ABC,DEF"
echo 遍历指定字符串的内容, 提取分隔后第2,3,5个字符串 %TEST_STR%
rem FOR /F ["options"] %variable IN ("string") DO command [command-parameters]
FOR /F "tokens=2,3,5 delims=, " %%i IN (%TEST_STR%)  DO (
    echo %%i %%j %%k
)

pause