-- https://github.com/dot123
-- 界面管理

FormMgr = BaseClass("FormMgr")

-- 初始化
function FormMgr:init()
    self.loadFormDict = {}
end

-- 切换账号
function FormMgr:onReload()
end

-- 打开界面
function FormMgr:showForm(formName, ...)
    local args = {...}
    local form = self.loadFormDict[formName]
    if form then
        form:setVisible(true) 
        if form.blank then
            form.blank:stopAllActions()
        end
        form.root:stopAllActions()
        form:updateInfo(args)

        SceneMgr:getUILayer():reorderChild(form.blank, form.blank:getLocalZOrder())
        SceneMgr:getUILayer():sortAllChildren()

        return form
    end

    form = require('ui/' .. formName)
    if not form then
        Log:w("Not found form:" .. formName)
        return
    end 

    form:showForm(args)
    self.loadFormDict[formName] = form
    return form
end

-- 关闭界面
function FormMgr:closeForm(formName)
    local form = self.loadFormDict[formName]
    if nil == form then
        return 
    end
    form:closeForm()
end

-- 设置显示/隐藏界面
function FormMgr:setVisible(formName, isVisible)
    local form = self.loadFormDict[dlgName]
    if nil ~= form then
        form:setVisible(isVisible)
    end
end

-- 打开/关闭界面
function FormMgr:showOrCloseForm(formName)
    if self:isShowForm(formName) then
        self:closeForm(formName)
    else
        self:showForm(formName)
    end
end

-- 界面是否已打开
function FormMgr:isFormShow(formName)
    return self.loadFormDict[formName] ~= nil
end

-- 获取界面
function FormMgr:getForm(formName)
    return self.loadFormDict[formName]
end

-- 清除界面记录
function FormMgr:clearForm(formName)
    if self.loadFormDict[formName] then
        self.loadFormDict[formName] = nil
    end
end

-- 关闭所有界面
function FormMgr:closeAllForm()
    for formName, form in pairs(self.loadFormDict) do
        form:closeForm()
        self.loadFormDict[formName] = nil
    end
end

-- 给界面发消息
function FormMgr:sendMsg(formName, funcName, ...)
    local form = self.loadFormDict[formName]
    if form == nil then
        return 
    end

    local func = form[funcName]
    if func == nil then
        return 
    end
    
    return func(form, ...)
end

return FormMgr