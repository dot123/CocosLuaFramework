
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"

-- 开启垃圾回收功能
function enableGC()
    collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
end

-- 禁止垃圾回收功能
function disableGC()
    collectgarbage("stop")
end

local function main()
	disableGC()

	local director = cc.Director:getInstance()
	director:setAnimationInterval(1 / FPS)    
	if CC_SHOW_FPS then
		director:setDisplayStats(true)
	end

	-- 热更新完成后加载模块
	require "App"
	require("ClientMgr"):init()

	enableGC()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
	print(msg)
end
