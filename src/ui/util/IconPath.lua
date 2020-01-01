-- https://github.com/dot123
-- 图片路径管理

local commonPathRoot = "images/ui/common/";
function getCommonIconPath(filename)
    local fullName = commonPathRoot..filename..".png";
    if cc.FileUtils:getInstance():isFileExist(fullName) then
        return fullName;
    else
        return commonPathRoot .. "default.png";
    end
end

local buttonPathRoot = "images/ui/button/";
function getButtonIconPath(filename)
    local fullName = buttonPathRoot..filename..".png";
    if cc.FileUtils:getInstance():isFileExist(fullName) then
        return fullName;
    else
        return buttonPathRoot .. "default.png";
    end
end

local itemPathRoot = "images/ui/item/";
function getItemIconPath(filename)
    local fullName = itemPathRoot..filename..".png";
    if cc.FileUtils:getInstance():isFileExist(fullName) then
        return fullName;
    else
        return itemPathRoot .. "default.png";
    end
end

local equipPathRoot = "images/ui/equip/";
function getEquipIconPath(filename)
    local fullName = equipPathRoot..filename..".png";
    if cc.FileUtils:getInstance():isFileExist(fullName) then
        return fullName;
    else
        return equipPathRoot .. "default.png";
    end
end

-- 获取按钮图标
local buttonPathRoot = "images/ui/button/";
function getButtonIconPath(filename)
    local fullName = buttonPathRoot..filename..".png";
    if cc.FileUtils:getInstance():isFileExist(fullName) then
        return fullName;
    else
        return buttonPathRoot .. "default.png";
    end
end
