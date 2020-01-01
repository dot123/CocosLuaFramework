-- https://github.com/dot123
-- 客户端管理

ClientMgr = BaseClass("ClientMgr")

-- 初始化
function ClientMgr:init()
	App:init()
	scheduleGlobal(handler(self, self.update))
	SceneMgr:loadScene("GameScene")
end

-- 清除数据
function ClientMgr:clearData()
	App:onReload()
end

-- 定时回调
function ClientMgr:update()
	NetMgr:onUpdate()
	SceneMgr:onUpdate()
end

-- 开始进入游戏
function ClientMgr:onStartEnterGame() 
	self:clearData()
	FormMgr:showForm("UIMain")
end

-- 程序切换到后台
function applicationDidEnterBackground()
	Log:d("applicationDidEnterBackground")
end

-- 程序切换到前台
function applicationWillEnterForeground()
	Log:d("applicationWillEnterForeground")
end

return ClientMgr