-- https://github.com/dot123
-- 模块加载管理

require "common/Language"
require "common/CommonTool"
require "common/BaseClass"
require "common/Log"
require "define/EventDefine"
require "define/ShareDefine"
require "net/Msg"
require "ui/util/NodeTool"
require "ui/BaseForm"

local list = {
	"mgr/EventMgr",
	"mgr/TextureMgr",
	"mgr/AudioMgr",
	"net/MsgMgr",
	"net/NetMgr",
	"net/KeepAlive",
	"ui/FormMgr",
	"scene/SceneMgr"
}

local moduleList = {}

-- 加载所有模块
for i = 1, #list do
	local m = require(list[i])
	table.insert(moduleList, m)
end

App = {}

-- 初始化
function App:init()
	for i = 1, #moduleList do
		local m = moduleList[i]
		if type(m) == "table" and m.init then
			m:init()
		end
	end
end

-- 切换账号
function App:onReload()
	for i = 1, #moduleList do
		local m = moduleList[i]
		if type(m) == "table" and m.onReload then
			m:onReload()
		end
	end
end

return App
