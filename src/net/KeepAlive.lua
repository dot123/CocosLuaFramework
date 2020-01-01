-- https://github.com/dot123
-- 保持连接

KeepAlive = {}

-- 初始化
function KeepAlive:init()
    self.isOpen = true
    self.lastHeartTime = 0
    self.lastRecvTime = 0

    MsgMgr:regist("MSG_HEARTBEAT", KeepAlive)
    MsgMgr:regist("MSG_LOGIN_NOTIFY_OK", KeepAlive)  
    MsgMgr:regist("MSG_RELOGIN", KeepAlive)
end

-- 切换账号
function MsgMgr:onReload()
end

-- 打开心跳
function KeepAlive:open()
    if not NetMgr:isConnected() then
        return
    end

    self.isOpen = true
    self.lastHeartTime = os.time()
    self.lastRecvTime = os.time()
end

function KeepAlive:close()
     self.isOpen = false
end

-- 定时回调
function KeepAlive:onUpdate()
    if not self.isOpen then
        return
    end

    local curTime = os.time()
    if curTime > self.lastRecvTime + 30 then
        NetMgr:disconnect()
        self:close()
        return
    end

    if self.lastHeartTime + 10 >= curTime then
        return
    end

    self.lastHeartTime = curTime

    if not NetMgr:isConnected() then
        return
    end

    NetMgr:send(Cmd.CMD_HEARTBEAT, { BeatTime = curTime})
end

function KeepAlive:MSG_HEARTBEAT(data)
    local RecvTime = data.RecvTime
    if self.lastRecvTime < RecvTime then
        self.lastRecvTime = RecvTime
    end
end

function KeepAlive:MSG_LOGIN_NOTIFY_OK(data)
    self:open()
end

-- 重连成功
function KeepAlive:MSG_RELOGIN(data)
    if data.code == 1 then
        self:open()
    end
end

return KeepAlive