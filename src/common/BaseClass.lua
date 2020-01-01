-- https://github.com/dot123
-- 单例对象

function BaseClass(name, super)
    local obj = { var = {} }
    if name then obj.var.__cname = name end
    local met = {}
    met.__index = function (tbl, key)
        if tbl.var[key] ~= nil then
            return tbl.var[key]
        elseif super then
            return super[key]
        else
            return nil
        end
    end

    met.__newindex = function (tbl, key, value)
        if type(value) ~= "function" then
            tbl.var[key] = value
        else
            rawset(tbl, key, value)
        end
    end
    setmetatable(obj, met)
    return obj
end