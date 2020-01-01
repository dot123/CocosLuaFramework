-- https://github.com/dot123
-- 界面基类

BaseForm = BaseClass("BaseForm")

BaseForm.TAG_ACTION_CLOSE = 9999

-- 每次界面打开时调用
function BaseForm:onShow(args)
end

-- 界面已经打开时再次打开时调用
function BaseForm:updateInfo(args)
end

-- 控件被点击
function BaseForm:onClick(btnName, btnNode)
end

-- 定时回调
function BaseForm:onUpdate(dt)
end

-- 每次界面关闭时调用
function BaseForm:onClose()
end

-- 打开界面文件
function BaseForm:showForm(args)
    self.blank = ccui.Layout:create()
    -- 将blank层铺面屏幕
    self.blank:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)

    SceneMgr:getUILayer():addChild(self.blank)

    self.root = tolua.cast(cc.CSLoader:createNode("ui/" .. self.__cname .. ".csb" ), "ccui.Layout")
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:onUpdate(dt) end, 0)
    self.blank:addChild(self.root)

    self:initNodeCache(self.root)

    self:formAlign(ccui.RelativeAlign.centerInParent)

    -- 中上对齐
    self:align(self.topPanel, ccui.RelativeAlign.alignParentTopCenterHorizontal)

    -- 中下对齐
    self:align(self.bottomPanel, ccui.RelativeAlign.alignParentBottomCenterHorizontal)

    Log:d("%s:ShowForm", self.__cname)

    self:onShow(args)

    -- 在渲染前排序 提升性能
    self.root:sortAllChildren()
end

-- 初始化节点缓存(内部调用)
function BaseForm:initNodeCache(parent)
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
            local name = parent:getName()
            local _, q = string.find(name, "btn")
            if q == 3 then
                self:bindTouchEndByNode(parent, handler(self, self.onClick))
            end
            self[name] = parent
            BaseForm:initNodeCache(parent)
        end
    end
    return
end

-- 设置界面的可见性
function BaseForm:setVisible(isVisible)
    if self.blank then
        self.blank:setVisible(isVisible)
    end
end

-- 界面是否可见性
function BaseForm:isVisible()
    if nil == self.blank then return false end
    return self.blank:isVisible()
end

-- 窗体对齐（使用ccui.RelativeAlign）
function BaseForm:formAlign(relativeAlign)
    align(self.root, Const.WINSIZE, relativeAlign)
    local pos = cc.p(self.root:getPositionX(), self.root:getPositionY())
    self:setPosition(pos)
end

-- 设置界面位置
-- 相对于设计分别率的位置(以左下顶点为基准)
function BaseForm:setPosition(pos)
    if not self.root then
        return
    end

    -- 由于ui可能会进行缩放处理，故这里需要先除以缩放比例
    pos.x = pos.x / Const.UI_SCALE
    pos.y = pos.y / Const.UI_SCALE
    self.root:setPosition(pos)
end

-- 对齐
function BaseForm:align(node, relativeAlign)
    if not node then return end 
    local w = (Const.WINSIZE.width - Const.UI_DESIGN_WIDTH) / 2
    local h = (Const.WINSIZE.height - Const.UI_DESIGN_HEIGHT) / 2
    local size = cc.size(Const.UI_DESIGN_WIDTH, Const.UI_DESIGN_HEIGHT)

    local pos = cc.p(0, 0)
    local anchor = cc.p(0, 0)
    if relativeAlign == ccui.RelativeAlign.alignParentTopLeft then
        -- 上左
        pos = cc.p(-w, size.height + h)
        anchor = cc.p(0, 1)
    elseif relativeAlign == ccui.RelativeAlign.alignParentTopCenterHorizontal then
        -- 上中
        pos = cc.p(size.width/2, size.height + h)
        anchor = cc.p(0.5, 1)
    elseif relativeAlign == ccui.RelativeAlign.alignParentTopRight then
        -- 上右
        pos = cc.p(size.width + w, size.height + h)
        anchor = cc.p(1, 1)
    elseif relativeAlign == ccui.RelativeAlign.alignParentLeftCenterVertical then
        -- 中左
        pos = cc.p(-w, size.height/2)
        anchor = cc.p(0, 0.5)
    elseif relativeAlign == ccui.RelativeAlign.centerInParent then
        -- 中
        pos = cc.p(size.width/2, size.height/2)
        anchor = cc.p(0.5, 0.5)
    elseif relativeAlign == ccui.RelativeAlign.alignParentRightCenterVertical then
        -- 中右
        pos = cc.p(size.width + w, size.height/2)
        anchor = cc.p(1, 0.5)
    elseif relativeAlign == ccui.RelativeAlign.alignParentLeftBottom then
    -- 下左（默认）
    elseif relativeAlign == ccui.RelativeAlign.alignParentBottomCenterHorizontal then
        -- 下中
        pos = cc.p(size.width/2, -h)
        anchor = cc.p(0.5, 0)
    elseif relativeAlign == ccui.RelativeAlign.alignParentRightBottom then
        -- 下右
        pos = cc.p(size.width + w, -h)
        anchor = cc.p(1, 0)
    end

    node:ignoreAnchorPointForPosition(false)
    node:setAnchorPoint(anchor)
    node:setPosition(pos)
end

-- 为指定的控件对象绑定TouchEnd事件
function BaseForm:bindTouchEndByNode(node, func)
    if not node then
        Log:w("BaseForm:bindTouchEndByNode no node")
        return
    end

    -- 事件监听
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            func(sender:getName(), sender, eventType)
        end
     end

    node:addTouchEventListener(listener)
end

-- 控件绑定事件
function BaseForm:bindTouchEndByName(name, func, root)
    if nil == func then
        Log:w("BaseForm:bindTouchEndByName no function.")
        return
    end

    -- 获取子控件
    local node = self:getControl(name, root)
    if nil == node then
        Log:w("BaseForm:bindTouchEndByName no node " .. name)
        return
    end
    self:bindTouchEndByNode(node, func)
end

-- 为指定的控件对象绑定长按事件
-- OneSecondLaterFunc：长按1秒后回调函数         
-- func：普通点击回调
function BaseForm:bindLongPress(node, OneSecondLaterFunc, func)
    if not node then
        Log:w("BaseForm:bindLongPress no node")
        return
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            local callFunc = cc.CallFunc:create(function ()
                OneSecondLaterFunc(sender, eventType)
                self.root:stopAction(self.longPress)
                self.longPress = nil
            end)

            self.longPress = cc.Sequence:create(cc.DelayTime:create(1), callFunc)
            self.root:runAction(self.longPress)
        elseif eventType == ccui.TouchEventType.ended then
            if self.longPress ~= nil then
                self.root:stopAction(self.longPress)
                self.longPress = nil

                if func and type(func) == "function" then
                    func(sender, eventType)
                end
            end
        elseif eventType == ccui.TouchEventType.canceled then
            if self.longPress ~= nil then
                self.root:stopAction(self.longPress)
                self.longPress = nil
            end
        end
    end

    node:addTouchEventListener(listener)
end

-- 获取控件
function BaseForm:getControl(name, root)
    root = root or self.root
    local node = seekNodeByName(root, name)
    if node == nil then
        -- 根据路径来查找布局中的结点
        node = seekNodeByPath(root, name)
    end
    return node
end

-- 设置图片
function BaseForm:setImage(name, path, root)
    if path == nil or string.len(path) == 0 then 
        return 
    end
    local img = self:getControl(name, root)
    if img ~= nil then
        img:loadTexture(path)
    end
end

-- 设置图片大小
function BaseForm:setImageSize(name, size, root)
    local img = self:getControl(name, root)
    if img then
        img:ignoreContentAdaptWithSize(false)
        img:setContentSize(size)
    end
end

-- 设置图片从精灵帧缓存
function BaseForm:setImagePlist(name, path, root)
    if path == nil or string.len(path) == 0 then
        return 
    end

    local sp = cc.SpriteFrameCache:getInstance():getSpriteFrame(path)
    if not sp then
        Log:w("spriteFrameCache [%s] not found \n%s", path)
        return 
    end

    local img = self:getControl(name, Const.UIImage, root)
    if img then
        img:loadTexture(path, ccui.TextureResType.plistType)
    end
end

-- 关闭界面
function BaseForm:closeForm()
    local function func()
        self:onClose()
        self:unhookMsg()

        if nil ~= self.root then
            self.root:removeFromParent()
            self.root = nil
            self.node = nil
        end

        if nil ~= self.blank then 
            self.blank:removeFromParent()
            self.blank = nil
        end
        FormMgr:clearForm(self.__cname)
    end

    -- 在控件的回调函数中调用会引发异常，故要放在action中执行
    local action = cc.CallFunc:create(func)
    action:setTag(BaseForm.TAG_ACTION_CLOSE)
    if self.blank then
        self.blank:runAction(action) 
    end
end

-- 消息回调的函数名
function BaseForm:hookMsg(msg)
    MsgMgr:hook(msg, self, self.__cname)
end

-- 取消该对象所有的hook消息
function BaseForm:unhookMsg()
    MsgMgr:unhookByHooker(self.__cname)
end