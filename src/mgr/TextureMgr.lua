-- https://github.com/dot123
-- 网纹理缓存管理器

TextureMgr = BaseClass("TextureMgr")

local CLEAN_INTERVAL = 60
-- 初始化
function TextureMgr:init()
    self.keep  = {}
    self.timeCount = 0
    scheduleGlobal(handler(self, self.update), 1)
end

-- 切换账号
function TextureMgr:onReload()
end

function TextureMgr:update()
    self.timeCount = self.timeCount + 1
    if self.timeCount > CLEAN_INTERVAL then
        AudioMgr:purge()
        --cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        ccs.ActionTimelineCache:getInstance():purge()
        cc.Director:getInstance():purgeCachedData()
        --Log:d(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
        Log:d("当前Lua内存为：" .. (collectgarbage("count") / 1024) .. 'M')
        self.timeCount = 0
    end

    local toRemove = {}
    for i, obj in ipairs(self.keep) do
        if obj.life ~= nil then
            obj.life = obj.life - 1
            if obj.life < 0 then
                obj:release()
                table.insert(toRemove, i)
            end
        end
    end
    for _, obj in pairs(toRemove) do
        table.remove(self.keep, obj)
    end
end

function TextureMgr:keeyTexture(texture, seconds)
    if texture.retain == nil then return end
    texture:retain()
    texture.life = seconds or 0
    table.insert(self.keep, texture)
end

return TextureMgr
