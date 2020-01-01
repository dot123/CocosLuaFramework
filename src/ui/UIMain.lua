-- https://github.com/dot123
-- 主界面

local UIMain = BaseClass("UIMain", BaseForm)

-- 每次界面打开时调用
function UIMain:onShow(args)
	--测试加密模块
	local str = "abcdefsgagasg214215125"	--数据
	local key = "K3mxrKO96ekGBHwB"		    --密钥
	local es = zed.encrypt(str, key)	    --加密
	local ds = zed.decrypt(es, key)		    --解密

	print("源数据", str)
	print("加密后",	es)
	print("解密后",	ds)
	
	self.topText:setString(i18n("top"))
	self.bottomText:setString("bottom")
	self.helloText:setString("Hello")

	NetMgr:connect("127.0.0.1", 3563)
	self:hookMsg("MSG_LOGIN")
end

-- 界面已经打开时再次打开时调用
function UIMain:updateInfo(args)
end

-- 控件被点击
function UIMain:onClick(btnName, btnNode)
	Log:d(btnName)

	if btnName == "btnLogin" then
		NetMgr:send(Cmd.CMD_LOGIN, {
			account  = "abc123456",
			password = "pwd123456",
		})
	elseif btnName == "btnClose" then
		os.exit(0)
	end
end

-- 定时回调
function UIMain:onUpdate(dt)
end

-- 每次界面关闭时调用
function UIMain:onClose()
end

-- 回调函数
function UIMain:MSG_LOGIN(data)
	Log:d(data)
end

return UIMain 
