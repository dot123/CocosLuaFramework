-- https://github.com/dot123
-- 节点工具

-- start --

--------------------------------
-- 按tag查找布局中的结点
-- @function seekNodeByTag
-- @param node parent 要查找布局的结点
-- @param number tag 要查找的tag
-- @return node

-- end --

function seekNodeByTag(parent, tag)
    if not parent then
        return
    end

    if tag == parent:getTag() then
        return parent
    end

    local findNode
    local children = parent:getChildren()
    local childCount = parent:getChildrenCount()
    if childCount < 1 then
        return
    end
    for i=1, childCount do
        if "table" == type(children) then
            parent = children[i]
        elseif "userdata" == type(children) then
            parent = children:objectAtIndex(i - 1)
        end

        if parent then
            findNode = seekNodeByTag(parent, tag)
            if findNode then
                return findNode
            end
        end
    end

    return
end

-- start --

--------------------------------
-- 按name查找布局中的结点
-- @function seekNodeByName
-- @param node parent 要查找布局的结点
-- @param string name 要查找的name
-- @return node

-- end --

function seekNodeByName(parent, name)
    if not parent then
        return
    end

    if name == parent:getName() then
        return parent
    end

    local findNode
    local children = parent:getChildren()
    local childCount = parent:getChildrenCount()
    if childCount < 1 then
        return
    end

    for i=1, childCount do
        if "table" == type(children) then
            parent = children[i]
        elseif "userdata" == type(children) then
            parent = children:objectAtIndex(i - 1)
        end

        if parent then
            findNode = seekNodeByName(parent, name)
            if findNode then
                return findNode
            end
        end
    end

    return
end


-- start --

--------------------------------
-- 根据路径来查找布局中的结点
-- @function seekNodeByPath
-- @param node parent 要查找布局的结点
-- @param string path 要查找的path
-- @return node

-- end --

function seekNodeByPath(parent, path)
    if not parent then
        return
    end

    local names = string.split(path, '/')

    for i,v in ipairs(names) do
        parent = seekNodeByName(parent, v)
        if not parent then
            return
        end
    end

    return parent
end

local sharedScheduler = cc.Director:getInstance():getScheduler()

-- start --

--------------------------------
-- 计划一个以指定时间间隔执行的全局事件回调，并返回该计划的句柄。
-- @function scheduleGlobal
-- @param function listener 回调函数
-- @param number interval 间隔时间
-- @return mixed#mixed ret (return value: mixed)  schedule句柄

--[[--

计划一个以指定时间间隔执行的全局事件回调，并返回该计划的句柄。 

~~~ lua

local function onInterval(dt)
end
 
-- 每 0.5 秒执行一次 onInterval()
local handle = scheduleGlobal(onInterval, 0.5) 

~~~

]]

-- end --

function scheduleGlobal(listener, interval)
    interval = interval or 0
    return sharedScheduler:scheduleScriptFunc(listener, interval, false)
end

-- start --

--------------------------------
-- 取消一个全局计划
-- @function unscheduleGlobal
-- @param mixed schedule句柄

--[[--

取消一个全局计划 

unscheduleGlobal() 的参数就是 scheduleGlobal() 的返回值。

]]

-- end --

function unscheduleGlobal(handle)
    sharedScheduler:unscheduleScriptEntry(handle)
end

-- start --

--------------------------------
-- 计划一个全局延时回调，并返回该计划的句柄。
-- @function performWithDelayGlobal
-- @param function listener 回调函数
-- @param number time 延迟时间
-- @return mixed#mixed ret (return value: mixed)  schedule句柄

--[[--

计划一个全局延时回调，并返回该计划的句柄。

performWithDelayGlobal() 会在等待指定时间后执行一次回调函数，然后自动取消该计划。

]]

-- end --

function performWithDelayGlobal(listener, time)
    local handle
    handle = sharedScheduler:scheduleScriptFunc(function()
        gf:unscheduleGlobal(handle)
        listener()
    end, time, false)
    return handle
end

-- 创建一个调度器
function schedule(node, callback, interval)
    interval = interval or 0
    local seq = cc.Sequence:create({
        cc.DelayTime:create(interval),
        cc.CallFunc:create(callback),
    })
    local action = cc.RepeatForever:create(seq)
    node:runAction(action)
    return action
end

-- 延时执行
function performWithDelay(node, callback, delay)
    delay = delay or 0
    local action = cc.Sequence:create({
        cc.DelayTime:create(delay),
        cc.CallFunc:create(callback),
    })
    node:runAction(action)
    return action
end

-- 对齐
function align(node, size, relativeAlign)
    local pos = cc.p(0, 0)
    local anchor = cc.p(0, 0)
    if relativeAlign == ccui.RelativeAlign.alignParentTopLeft then
        -- 上左
        pos = cc.p(0, size.height)
        anchor = cc.p(0, 1)
    elseif relativeAlign == ccui.RelativeAlign.alignParentTopCenterHorizontal then
        -- 上中
        pos = cc.p(size.width/2, size.height)
        anchor = cc.p(0.5, 1)
    elseif relativeAlign == ccui.RelativeAlign.alignParentTopRight then
        -- 上右
        pos = cc.p(size.width, size.height)
        anchor = cc.p(1, 1)
    elseif relativeAlign == ccui.RelativeAlign.alignParentLeftCenterVertical then
        -- 中左
        pos = cc.p(0, size.height/2)
        anchor = cc.p(0, 0.5)
    elseif relativeAlign == ccui.RelativeAlign.centerInParent then
        -- 中
        pos = cc.p(size.width/2, size.height/2)
        anchor = cc.p(0.5, 0.5)
    elseif relativeAlign == ccui.RelativeAlign.alignParentRightCenterVertical then
        -- 中右
        pos = cc.p(size.width, size.height/2)
        anchor = cc.p(1, 0.5)
    elseif relativeAlign == ccui.RelativeAlign.alignParentLeftBottom then
    -- 下左（默认）
    elseif relativeAlign == ccui.RelativeAlign.alignParentBottomCenterHorizontal then
        -- 下中
        pos = cc.p(size.width/2, 0)
        anchor = cc.p(0.5, 0)
    elseif relativeAlign == ccui.RelativeAlign.alignParentRightBottom then
        -- 下右
        pos = cc.p(size.width, 0)
        anchor = cc.p(1, 0)
    end

    node:ignoreAnchorPointForPosition(false)
    node:setAnchorPoint(anchor)
    node:setPosition(pos)
end