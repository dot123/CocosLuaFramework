
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = false

FPS = 60

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 800,
    height = 1280,
    autoscale = "FIXED_WIDTH",  -- 按比例放缩，宽度铺满屏幕
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio >= 0.75 then
            -- iPad 768*1024(1536*2048) is 4:3 screen
            return {autoscale = "FIXED_HEIGHT"} -- 按比例放缩，高度铺满屏幕
        end
    end
}
