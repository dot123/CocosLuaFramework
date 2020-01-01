/****************************************************************************
 Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#include "AppDelegate.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "cocos2d.h"
#include "scripting/lua-bindings/manual/lua_module_register.h"

#define lua_register(L,n,f) (lua_pushcfunction(L, (f)), lua_setglobal(L, (n)))
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
#include "../proj.win32/ConsoleListener.h"
#endif

#include "zed.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
bool setColor(const char* color)
{
	int k;
	bool bmatch = false;
	if (strcmp(color, "\33[31m") == 0)
	{
		k = 4;
		bmatch = true;
	}
	else if (strcmp(color, "\33[32m") == 0)
	{
		k = 2;
		bmatch = true;
	}
	else if (strcmp(color, "\33[33m") == 0)
	{
		bmatch = true;
		k = 6;
	}
	else if (strcmp(color, "\33[34m") == 0)
	{
		bmatch = true;
		k = 1;
	}
	else if (strcmp(color, "\33[35m") == 0)
	{
		bmatch = true;
		k = 5;
	}
	else if (strcmp(color, "\33[37m") == 0)
	{
		bmatch = true;
		k = 7;
	}

	if (bmatch) {
		SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), k);
	}
	
	return bmatch;
}

int customPrint(lua_State* L)
{
	size_t size = 0;
	const char* lua_str = luaL_checklstring(L, 1, &size);

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 
	char buf[MAX_LOG_LENGTH] = { 0 };
	if (size >= MAX_LOG_LENGTH)
		size = MAX_LOG_LENGTH - 1;
	strncpy(buf, lua_str, size);
	buf[size] = '\n';

	WCHAR wszBuf[MAX_LOG_LENGTH] = { 0 };
	MultiByteToWideChar(CP_UTF8, 0, buf, -1, wszBuf, sizeof(wszBuf));
	WideCharToMultiByte(CP_ACP, 0, wszBuf, -1, buf, sizeof(buf), nullptr, FALSE);

	string str = buf;
#else
	string str = lua_str;
#endif

	string::size_type itemp = 0;
	for (string::size_type ipos = str.find("\33", 0); ; ipos = str.find("\33", ipos + 1))
	{
		if (ipos == string::npos)
		{
			string temp = str.substr(itemp);
			printf("%s", temp.c_str());
			break;
		}

		string temp = str.substr(itemp, ipos - itemp);
		printf("%s", temp.c_str());

		if (setColor(str.substr(ipos, 5).c_str()))
			itemp = ipos + 5;
		else
			itemp = ipos;
	}

	fflush(stdout);

	return 0;
}
#endif

// #define USE_AUDIO_ENGINE 1
// #define USE_SIMPLE_AUDIO_ENGINE 1

#if USE_AUDIO_ENGINE && USE_SIMPLE_AUDIO_ENGINE
#error "Don't use AudioEngine and SimpleAudioEngine at the same time. Please just select one in your game!"
#endif

#if USE_AUDIO_ENGINE
#include "audio/include/AudioEngine.h"
using namespace cocos2d::experimental;
#elif USE_SIMPLE_AUDIO_ENGINE
#include "audio/include/SimpleAudioEngine.h"
using namespace CocosDenshion;
#endif

USING_NS_CC;
using namespace std;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
#if USE_AUDIO_ENGINE
    AudioEngine::end();
#elif USE_SIMPLE_AUDIO_ENGINE
    SimpleAudioEngine::end();
#endif

#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    RuntimeEngine::getInstance()->end();
#endif

}

// if you want a different context, modify the value of glContextAttrs
// it will affect all platforms
void AppDelegate::initGLContextAttrs()
{
    // set OpenGL context attributes: red,green,blue,alpha,depth,stencil,multisamplesCount
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8, 0 };

    GLView::setGLContextAttrs(glContextAttrs);
}

// if you want to use the package manager to install more packages, 
// don't modify or remove this function
static int register_all_packages()
{
    return 0; //flag for packages manager
}

static int register_custom_function(lua_State* L) {
	lua_getglobal(L, "_G");
	if (lua_istable(L, -1))//stack:...,_G,
	{
		luaopen_zed(L);
	}
	lua_pop(L, 1);
	return 1;
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // set default FPS
    Director::getInstance()->setAnimationInterval(1.0 / 60.0f);

    // register lua module
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();
    lua_module_register(L);

	lua_register(L, "customPrint", customPrint);


    register_all_packages();

    LuaStack* stack = engine->getLuaStack();
    stack->setXXTEAKeyAndSign("2dxLua", strlen("2dxLua"), "XXTEA", strlen("XXTEA"));

    register_custom_function(stack->getLuaState());
    
#if CC_64BITS
    FileUtils::getInstance()->addSearchPath("src/64bit");
#endif
    FileUtils::getInstance()->addSearchPath("src");
    FileUtils::getInstance()->addSearchPath("res");
    if (engine->executeScriptFile("main.lua"))
    {
        return false;
    }

#if (COCOS2D_DEBUG > 0) && (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	CCDirector::getInstance()->getScheduler()->scheduleUpdate(ConsoleListener::getInstance(), ConsoleListenerPriority, false);
#endif

    return true;
}

// This function will be called when the app is inactive. Note, when receiving a phone call it is invoked.
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();

#if USE_AUDIO_ENGINE
    AudioEngine::pauseAll();
#elif USE_SIMPLE_AUDIO_ENGINE
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
    SimpleAudioEngine::getInstance()->pauseAllEffects();
#endif

	auto engine = LuaEngine::getInstance();
	engine->executeGlobalFunction("applicationDidEnterBackground");
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();

#if USE_AUDIO_ENGINE
    AudioEngine::resumeAll();
#elif USE_SIMPLE_AUDIO_ENGINE
    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
    SimpleAudioEngine::getInstance()->resumeAllEffects();
#endif

	auto engine = LuaEngine::getInstance();
	engine->executeGlobalFunction("applicationWillEnterForeground");
}
