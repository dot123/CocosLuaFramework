-- https://github.com/dot123
-- 事件通知管理器

EventMgr = BaseClass("EventMgr")

-- 初始化
function EventMgr:init()
    self.listeners = {}
end

-- 切换账号
function EventMgr:onReload()
end

function EventMgr:addEventListener(type, listener, cls)
    if not type or not listener then
        return 
    end

    local list = self.listeners[type]

    if not list then
        list = {}
        self.listeners[type] = list
    end

    local idKey = tostring(cls) .. "/" .. tostring(listener)

    if not list[idKey] then
        list[idKey] = (cls and function (...)
            listener(cls, ...)

            return 
        end) or listener

        return list[idKey]
    end
end
function EventMgr:removeEventListener(type, listener, cls)
    if not type or not listener then
        return 
    end

    local list = self.listeners[type]
    local idKey = tostring(cls) .. "/" .. tostring(listener)

    if list and list[idKey] then
        list[idKey] = nil
    end
end

function EventMgr:dispatchEvent(type, ...)
    if not type then
        return 
    end

    local list = self.listeners[type]

    if list then
        for _, v in pairs(list) do
            if v then
                v(...)
            end
        end
    end
end

function EventMgr:hasEventListener(type)
    if not type then
        return false
    end

    return self.listeners[type] ~= nil
end

return EventMgr
