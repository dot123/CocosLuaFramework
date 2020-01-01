-- https://github.com/dot123
-- 公共宏定义

Const = {
    WINSIZE = cc.Director:getInstance():getWinSize(),
    VISIBLEORIGIN = cc.Director:getInstance():getVisibleOrigin(),
    VISIBLESIZE = cc.Director:getInstance():getVisibleSize(),
    INTERVAL = cc.Director:getInstance():getAnimationInterval(),
    UI_DESIGN_WIDTH = 800,
    UI_DESIGN_HEIGHT = 1280,
    UI_SCALE = 1,
    
    -- 触摸事件
    TOUCH_BEGAN = "began",
    TOUCH_MOVED = "moved",
    TOUCH_ENDED = "ended",
    TOUCH_CANCELLED = "cancelled",

    -- 控件名称
    UIButton = "ccui.Button",
    UICheckBox = "ccui.CheckBox",
    UIImage = "ccui.ImageView",
    UIAtlasLabel = "ccui.TextAtlas",
    UIBitmapLabel = "ccui.TextBMFont",
    UIProgressBar = "ccui.LoadingBar",
    UISlider = "ccui.Slider",
    UILabel = "ccui.Text",
    UITextField = "ccui.TextField",
    UIPanel = "ccui.Layout",
    UIScrollView = "ccui.ScrollView",
    UIListView = "ccui.ListView",
    UIPageView = "ccui.PageView",
    UIWidget = "ccui.Widget",
}
