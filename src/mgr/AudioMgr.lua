-- https://github.com/dot123
-- 音效管理器

AudioMgr = BaseClass("AudioMgr")

-- 初始化
function AudioMgr:init()
    self.noOpen     = "AUDIO_NO_OPEN"    -- 音效开启参数KEY
    self.audioValue = "AUDIO_VALUE"      -- 音效开启量值KEY
    self.currBgMusic = nil               -- 当前背景乐
    self.list = {}
end

-- 切换账号
function AudioMgr:onReload()
end

-- 获取音效开启参数
function AudioMgr:noOpenAudio()
    local noOpen = cc.UserDefault:getInstance():getBoolForKey(AudioMgr.noOpen)
    return noOpen
end

-- 保存音效开启参数
function AudioMgr:saveLocalAudio(isOpen)
    cc.UserDefault:getInstance():setBoolForKey(AudioMgr.noOpen, not isOpen)
end

-- 获取音效开启量值
function AudioMgr:getAudioValue()
    local value = cc.UserDefault:getInstance():getStringForKey(AudioMgr.audioValue)
    if value == "" then
        value = 1
    end
    return value
end

-- 保存音效开启量值
function AudioMgr:saveAudioValue(value)
    cc.UserDefault:getInstance():setStringForKey(AudioMgr.audioValue, value)
end

-- 设置音效开关
function AudioMgr:setAudio(isOpen)
    self:saveLocalAudio(isOpen)
    if isOpen then
        AudioEngine.resumeMusic()
        AudioEngine.resumeAllEffects()
        self:playMusic(nil, true)
    else
        AudioEngine.pauseMusic()
        AudioEngine.pauseAllEffects()
    end
end

-- 设置音量
function AudioMgr:setVolume(value)
    self:saveAudioValue(value)
    AudioEngine.setMusicVolume(value)
    AudioEngine.setEffectsVolume(value)
end
AudioMgr:setVolume(AudioMgr:getAudioValue()) -- 第一次音量设置

-- 获取单例
function AudioMgr:getInstance()
    return cc.SimpleAudioEngine:getInstance()
end

-- 销毁单例
function AudioMgr:destroyInstance()
    return cc.SimpleAudioEngine:destroyInstance()
end
    
-- 预加载音乐
function AudioMgr:preloadMusic(filename)
    cc.SimpleAudioEngine:getInstance():preloadMusic(filename)
end

-- 清理音效缓存
function AudioMgr:purge()
    for key, _ in pairs(self.list) do
        self:unloadEffect(key)
    end
end

-- 播放背景音乐
function AudioMgr:playMusic(filename, isLoop)
    if filename ~= nil and self.currBgMusic ~= filename then
        self.currBgMusic = filename
    elseif self.currBgMusic == filename and self:isMusicPlaying() then
        return
    end
    AudioMgr:stopMusic(false)
    if self:noOpenAudio() then
        return
    end

    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    self.list[self.currBgMusic] = true
    cc.SimpleAudioEngine:getInstance():playMusic(self.currBgMusic, loopValue)
end

-- 停止背景音乐
function AudioMgr:stopMusic(isReleaseData)
    local releaseDataValue = false
    if nil ~= isReleaseData then
        releaseDataValue = isReleaseData
    end
    cc.SimpleAudioEngine:getInstance():stopMusic(releaseDataValue)
end

-- 暂停背景音乐
function AudioMgr:pauseMusic()
    cc.SimpleAudioEngine:getInstance():pauseMusic()
end

-- 继续播放背景音乐
function AudioMgr:resumeMusic()
    if self:noOpenAudio() then
        return
    end
    cc.SimpleAudioEngine:getInstance():resumeMusic()
end

-- 循环播放
function AudioMgr:rewindMusic()
    cc.SimpleAudioEngine:getInstance():rewindMusic()
end

-- 获取音乐音量
function AudioMgr:getMusicVolume()
    return cc.SimpleAudioEngine:getInstance():getMusicVolume()
end

-- 设置音乐音量
function AudioMgr:setMusicVolume(volume)
    cc.SimpleAudioEngine:getInstance():setMusicVolume(volume)
end

-- 判断是否在音乐是否在播放
function AudioMgr:isMusicPlaying()
    return cc.SimpleAudioEngine:getInstance():isMusicPlaying()
end

-- 判断是否可以开始播放音乐
function AudioMgr:willPlayMusic()
    return cc.SimpleAudioEngine:getInstance():willPlayMusic()
end

-- 预加载音效
function AudioMgr:preloadEffect(filename)
    cc.SimpleAudioEngine:getInstance():preloadEffect(filename)
end

-- 播放音效
function AudioMgr:playEffect(filename, isLoop)
    if self:noOpenAudio() then
        return
    end

    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    self.list[filename] = true
    return cc.SimpleAudioEngine:getInstance():playEffect(filename, loopValue)
end

-- 停止音效
function AudioMgr:stopEffect(handle)
    cc.SimpleAudioEngine:getInstance():stopEffect(handle)
end

-- 卸载音效
function AudioMgr:unloadEffect(filename)
    cc.SimpleAudioEngine:getInstance():unloadEffect(filename)
end

-- 暂停音效
function AudioMgr:pauseEffect(handle)
    cc.SimpleAudioEngine:getInstance():pauseEffect(handle)
end

-- 暂停所有音效
function AudioMgr:pauseAllEffects()
    cc.SimpleAudioEngine:getInstance():pauseAllEffects()
end

-- 恢复音效
function AudioMgr:resumeEffect(handle)
    cc.SimpleAudioEngine:getInstance():resumeEffect(handle)
end

-- 恢复所有音效
function AudioMgr:resumeAllEffects(handle)
    cc.SimpleAudioEngine:getInstance():resumeAllEffects()
end

-- 停止所有音效
function AudioMgr:stopAllEffects()
    cc.SimpleAudioEngine:getInstance():stopAllEffects()
end

-- 获取音效音量
function AudioMgr:getEffectsVolume()
    return cc.SimpleAudioEngine:getInstance():getEffectsVolume()
end

-- 设置音效音量
function AudioMgr:setEffectsVolume(volume)
    cc.SimpleAudioEngine:getInstance():setEffectsVolume(volume)
end

return AudioMgr