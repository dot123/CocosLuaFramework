-- https://github.com/dot123
-- 字符串生成器

local StringBuilder = class("StringBuilder")

function StringBuilder:ctor()
    self._buffer = {}
end

function StringBuilder:add(s)
    table.insert(self._buffer, s)
end

function StringBuilder:toString()
    return table.concat(self._buffer)
end

return StringBuilder
