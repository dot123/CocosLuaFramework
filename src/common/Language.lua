-- https://github.com/dot123
-- 语言管理

i18n = require "common.i18n.init"

i18n.loadFile('common/i18n/en.lua') 
i18n.loadFile('common/i18n/zh.lua') 

i18n.setLocale('zh')