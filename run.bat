@echo off  
if not exist %COCOS_CONSOLE_ROOT% (  
echo 未定义 COCOS_CONSOLE_ROOT 环境变量！  
pause  
)
taskkill /f /t /im HelloLua.exe  
start ./simulator/win32/HelloLua.exe

