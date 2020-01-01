-- https://github.com/dot123
-- 网络消息分发

MsgMgr = {}
 
-- 初始化
function MsgMgr:init()
	self.callbacks = {}
	self.hooks = {}
	self.hookers = {}
	self.hookIndex = 1
end

-- 切换账号
function MsgMgr:onReload()
end

-- 注册消息处理回调
function MsgMgr:regist(msgName, func)

	Log:d("regist " .. msgName)

	if type(func) == "function" then
		self.callbacks[msgName] = func
	elseif type(func) == "table" or type(func) == "userdata" then
		local class = func
		func = class[msgName]
		if func ~= nil then
			self.callbacks[msgName] = function (map)
				func(class, map)
			end
		end
	end 
end

-- 取消消息处理回调
function MsgMgr:unRegist(msgName)
	self.callbacks[msgName] = nil
end

-- 注册消息处理回调
function MsgMgr:hook(msgName, func, hooker)
	local list = self.hooks[msgName]

	if list == nil then
		list = {}
		self.hooks[msgName] = list
	end

	local idx = self.hookIndex

	if type(func) == "function" then
		list[idx] = func
	elseif type(func) == "table" or type(func) == "userdata" then
		local class = func
		func = class[msgName]
		if func ~= nil then
			list[idx] = function (map)
				func(class, map)
			end
		end
	end

	self.hookIndex = idx + 1

	Log:d("hook " .. msgName)

	list = self.hookers[hooker]

	if not list then
		list = {}
		self.hookers[hooker] = list
	end

	table.insert(list, {
		msgName,
		idx
	})

	return idx
end

function MsgMgr:unhook(msgName, idx)
	if idx == nil then
		return 
	end

	local list = self.hooks[msgName]

	if list ~= nil then
		list[idx] = nil

		Log:d("unhook " .. msgName)
	end
end

-- 取消消息处理回调
function MsgMgr:unhookByHooker(hooker)
	local list = self.hookers[hooker]

	if not list then
		return 
	end

	for _, info in pairs(list) do
		self:unhook(info[1], info[2])
	end

	self.hookers[hooker] = nil
end

-- 处理消息
function MsgMgr:processMsg(msgName, data)
	if not data then
		return 
	end

	local str = msgName

	if str ~= nil then
		local callback = self.callbacks[str]

		if type(callback) == "function" then
			callback(data)
		else
			Log:w(str .. " has no callback func.")
		end

		local hookList = self.hooks[str]

		if hookList ~= nil then
			for _, hook in pairs(hookList) do
				if type(hook) == "function" then
					hook(data)
				end
			end
		end
	end 
end


return MsgMgr
