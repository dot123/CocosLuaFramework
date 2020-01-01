-- https://github.com/dot123
-- 场景管理

SceneMgr = {}

local currentScene

-- 初始化
function SceneMgr:init()
end

-- 切换账号
function SceneMgr:onReload()
end

-- 获取当前场景
function SceneMgr:getCurrentScene()
    return currentScene
end

-- 加载场景
function SceneMgr:loadScene(sceneName)
    if sceneName == "GameScene" then 
        local scene = require("scene/GameScene")
        local gameScene = scene.create()
        currentScene = gameScene
    end

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(currentScene)
    else
        cc.Director:getInstance():runWithScene(currentScene)
    end
end

-- 定时回调
function SceneMgr:onUpdate()

end

-- 获取UI层
function SceneMgr:getUILayer()
    if currentScene then
        return currentScene:getChildByName("uiLayer")
    end
    return nil
end

return SceneMgr