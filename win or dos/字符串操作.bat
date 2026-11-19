@echo off

set TEST_STR=FlameCyclone1024Good

echo 测试字符串
echo %TEST_STR%
echo.

echo 截取第0个字符开始的12个字符
echo %TEST_STR:~0,12%
echo.

echo 截取第12个字符之后的字符
echo %TEST_STR:~12%
echo.

echo 截取第12个字符开始, 倒数第4个字符前结束
echo %TEST_STR:~12,-4%
echo.

echo 截取倒数第8个字符开始的4个字符
echo %TEST_STR:~-8,4%
echo.

echo 截取倒数第8个字符开始, 倒数第1个字符前结束
echo %TEST_STR:~-8,-1%
echo.

echo 截取最后4个字符
echo %TEST_STR:~-4%
echo.

pause