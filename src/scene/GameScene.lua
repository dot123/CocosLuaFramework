-- https://github.com/dot123
-- 游戏场景

GameScene = class("GameScene",function()
    return cc.Scene:create()
end)

function GameScene.create()
    local scene = GameScene.new()
    return scene
end

-- 构造函数
function GameScene:ctor()
    self:setName("GameScene")

    -- 设置相应常量
    Const.WINSIZE = cc.Director:getInstance():getWinSize()
    if Const.WINSIZE.width < Const.UI_DESIGN_WIDTH or Const.WINSIZE.height < Const.UI_DESIGN_HEIGHT then
        -- 为了保证 UI 能够显示下，需要进行放缩 UI 层
        -- 注意：此处一定要设置锚点为 (0, 0)，否则界面对其会发生错误
        local scaleW = 1
        if Const.WINSIZE.width < Const.UI_DESIGN_WIDTH then
            scaleW = Const.WINSIZE.width / Const.UI_DESIGN_WIDTH
        end

        local scaleH = 1
        if Const.WINSIZE.height < Const.UI_DESIGN_HEIGHT then
            scaleH = Const.WINSIZE.height / Const.UI_DESIGN_HEIGHT
        end

        if scaleW < scaleH then
            Const.UI_SCALE = scaleW
        else
            Const.UI_SCALE = scaleH
        end
    end

    local uiLayer = cc.Layer:create() -- UI 层
    uiLayer:ignoreAnchorPointForPosition(false)
    uiLayer:setAnchorPoint(cc.p(0, 0))
    uiLayer:setPosition(cc.p(0, 0))
    uiLayer:setScale(Const.UI_SCALE, Const.UI_SCALE)
    uiLayer:setName("uiLayer")
    self:addChild(uiLayer)
    -- Todo这里可以根据业务需要添加各种层

    self:registerScriptHandler(function(ev)
        if ev == "enter" then
            GameScene:onEnter()
        elseif ev == "exit" then
            GameScene:onExit()
        end
    end)
end

-- 开始进入场景
function GameScene:onEnter() 
    ClientMgr:onStartEnterGame()
end

-- 开始退出场景
function GameScene:onExit()
end

return GameScene
