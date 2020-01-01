-- https://github.com/dot123
-- 网络消息宏定义

Cmd = {
	CMD_LOGIN = 0x0001,  -- 请求登录
	CMD_RELOGIN = 0x0002, -- 请求重新登录(重连)
	CMD_HEARTBEAT = 0x0003,
}

Msg = {
	[0x0401] = "MSG_LOGIN", -- 登录结果
	[0x0402] = "MSG_RELOGIN", -- 重新登录结果
	[0x0403] = "MSG_LOGIN_NOTIFY_OK", -- 登录完毕
	[0x0404] = "MSG_HEARTBEAT", 
}
