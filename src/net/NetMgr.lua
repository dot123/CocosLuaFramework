-- https://github.com/dot123
-- 网络管理

NetMgr = {}

require("socket.core")
local msgpack = require("net/msgpack/msgpack")

local Tcp = nil
local IsConnected = false
local TryReConnectCount = 0
local IsConnecting = false

local Host = nil
local Port = nil

-- 待发送的数据
local SendList = {}

-- 所有接收消息
local MsgList = {}

local schedulerId = nil

-- 初始化
function NetMgr:init()
end

-- 切换账号
function NetMgr:onReload()
    MsgList = {}
    SendList = {}
end

-- 当前是不是出于连接中
function NetMgr:isConnected()
    return Tcp ~= nil and IsConnected
end

-- 是否正在连接
function NetMgr:isConnecting()
    return IsConnecting
end

-- 检查ipv6
local function checkIpv6(host)
    local isIpv6 = false

    local addrInfo, err = socket.dns.getaddrinfo(host)

    if addrInfo then
        for k, v in pairs(addrInfo) do
            if v.family == "inet6" then
                isIpv6 = true
                host = v.addr
                break
            end
        end
    end
    return isIpv6, host
end

-- 连接到服务器
function NetMgr:connect(host, port)
    if self:isConnected() then
        EventMgr:dispatchEvent(Event.NETWORK_CONNECTED)
        return
    end

    Log:d("开始连接服务器（%s:%d）", host, port)

    local isIpv6 = false

    local newHost = nil
    local r, e = pcall(function ()
        isIpv6, newHost = checkIpv6(host)
    end)

    if not r then
        isIpv6 = false
    else
        host = newHost
    end

    if isIpv6 then
        Tcp = socket.tcp6()
    else
        Tcp = socket.tcp()
    end

    Tcp:settimeout(1)

    ConnectTime = 0
    SendList = {}

    Host = host
    Port = port

    if not schedulerId then
        schedulerId = scheduleGlobal(handler(self, self.checkConnected), 0.2)
    end
end

-- 断开连接
function NetMgr:disconnect()
    if not NetMgr:isConnected() then return end

    if Tcp ~= nil then
        Tcp:shutdown("both")
        Tcp:close()
        Tcp = nil
        IsConnected = false
    end

    if schedulerId ~= nil then
        unscheduleGlobal(schedulerId)
        schedulerId = nil
    end

    MsgList = {} -- 断开连接清除消息列表
    EventMgr:dispatchEvent(Event.NETWORK_DISCONNECTED)
end

-- 发送数据
function NetMgr:send(msgId, data)
    if not self:isConnected() then 
        return false 
    end

    data = data or {}
    data[msgId] = msgId
    table.insert(SendList, msgpack.pack(data))
    return true
end

-- 定时处理
function NetMgr:onUpdate()
    if not self:isConnected() then 
        return 
    end

    local maxTimes = 10
    while maxTimes >= 0 do
        maxTimes = maxTimes - 1
        if #SendList > 0 then
            local data = SendList[1]
            local dataLen = string.len(data)
            local result, err, send = Tcp:send(data)
            if result == nil then
                Log:e("发送失败，err:" .. err)
                if err == "closed" then
                    NetMgr:disconnect()
                    return
                end
                offset = send
            else
                offset = result
            end

            if offset >= dataLen then
                table.remove(SendList, 1)
            else
            
            end
        else
            break
        end
    end

    self:recv()

    self:processMsg()

    -- 保持连接
    KeepAlive:onUpdate()
end

-- 检查是否连接
function NetMgr:checkConnected()

    if Tcp == nil then
        IsConnecting = false
        return false
    end

    local r, status = Tcp:connect(Host, Port, "*", 0)
    if r == 1 or status == "already connected" then
        IsConnecting = false

        if not self:isConnected() then
            Tcp:settimeout(0)

            IsConnected = true;
            EventMgr:dispatchEvent(Event.NETWORK_CONNECTED)
        end

        if schedulerId ~= nil then
            unscheduleGlobal(schedulerId)
            schedulerId = nil
        end

        return true
    end

    TryReConnectCount = TryReConnectCount + 1

    if (TryReConnectCount > 60) then
        Log:e("连接服务器超时，r = %s，status = %s", tostring(r), status)
        IsConnecting = false

        if schedulerId ~= nil then
            unscheduleGlobal(schedulerId)
            schedulerId = nil
        end

        self:disconnect()

        EventMgr:dispatchEvent(Event.NETWORK_CONNECT_TIMEOUT)
        TryReConnectCount = 0
    end

    return false
end

-- 读取数据
function NetMgr:recv()
    if not self:isConnected() then
        return nil 
    end

    local data, err = Tcp:receive("*a")
    if err and err ~= "timeout" then
        Log:e("recv:" .. err)
        self:disconnect()
    elseif not err then
        table.insert(MsgList, data)
    end
end

-- 处理消息分发
function NetMgr:processMsg()
    while MsgList[1] ~= nil do
        -- 处理消息
        MsgMgr:processMsg(Msg[MsgList[1].msgId], MsgList[1])
        table.remove(MsgList, 1)
    end
end

return NetMgr