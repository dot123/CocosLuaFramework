-- https://github.com/dot123
-- 日志管理

Log = {}

local path = "log.log"

local function writeLog(str)
	local f = io.open(path, "a")
	if not f then 
		return 
	end
	f:write(str)
	f:write("\n")
	f:close()
	print(str)
end

local log = print
if cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_WINDOWS then
    log = function(info) cc.Director:getInstance():getConsole():log(info) end
end

--红色
local R = "\27[31m"

--绿色
local G = "\27[32m"

--黄色
local Y = "\27[33m"

--蓝色
local B = "\27[34m"

--紫色
local P = "\27[35m"

--白色
local W = "\27[37m"

-- 打印红色字
function printR(msg)
    customPrint(R..msg..W);
end

-- 打印绿色字
function printG(msg)
    customPrint(G..msg..W);
end

-- 调试信息（保留）
function Log:d(...)
    log("DEBUG : " .. string.format(...))
    -- Log:printStack()
end

function Log:i(...)
	log("INF : " .. string.format(...))
	-- Log:printStack()
end

-- 警告信息
function Log:w(...)
    log("WARNNING : " .. string.format(...))
    Log:printStack()
end

-- 错误信息
function Log:e(...)
    log("ERROR : " .. string.format(...))
    -- Log:printStack()
end

function Log:printStack()
	local ret = ""
	local level = 3
	ret = ret .. "stack traceback: \n"

	while true do
		local info = debug.getinfo(level, "Sln")

		if not info then
			break
		end

		if info.what == "C" then
			ret = ret .. tostring(level) .. "C function\n"
		else
			ret = ret .. string.format("%s:%d in `%s`\n", info.short_src, info.currentline, info.name or "")
		end

		level = level + 1
	end
	log(ret)
end

function Log:traceback()
	log("INF : " .. debug.traceback())
end

-- 临时调试信息（不保留）
function Log:t(...)
    print("trace : ", ...)
end

-- 打印lua表
function Log:printTable(tb, key, level)
    local function printTableFunc(tb, key, level)
        if tb == nil then
            Log:d("null mapping.")
            return 
        end

        level = level or 0

        local strList = {}
        if 0 < level then
            table.insert(strList, string.rep("----", level))
            table.insert(strList, " " .. tostring(key) .. "=")
        end

        table.insert(strList, "{ ")
        if type(tb) == "table" then
            for k, v in pairs(tb) do
                if type(v) == "string" or type(v) == "number" then
                    table.insert(strList, k .. "=" .. v .. ", ")
                elseif type(v) == "table" then
                    printTableFunc(v, k, level + 1)
                end
            end
        end

        table.insert(strList, " }")
        Log:d("%s", table.concat(strList))
    end

    printTableFunc(tb, key, level)
end

return Log
