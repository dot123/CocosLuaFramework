-- https://github.com/dot123
-- 工具

-- 捕获异常
function catch(func, callback)
    local s, e = xpcall(func, __G__TRACKBACK__)

    if not s and callback and type(callback) == "function" then
        callback()
    end

    return 
end
