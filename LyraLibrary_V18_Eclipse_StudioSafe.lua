--[[
    LYRA V18 — ECLIPSE UI ENGINE (Studio-safe)
    A standalone Roblox UI framework for LocalScripts / ModuleScripts in Roblox Studio.
    This file intentionally uses PlayerGui and standard Roblox APIs only.
    No executor APIs, CoreGui injection, remote abuse, or exploit functionality.

    Quick start (LocalScript):
        local Lyra = require(path.to.LyraLibrary_V18_Eclipse)
        local ui = Lyra.new({Title="Lyra Eclipse", Subtitle="UI Evolution", Theme="Eclipse", Neon=true})
        local tab = ui:AddTab("Main")
        tab:AddSection("Controls")
        tab:AddButton("Example button", function() print("Clicked") end)
        tab:AddToggle("Example toggle", false, function(v) print(v) end)
        tab:AddSlider("Intensity", 0, 100, 54, function(v) print(v) end)
        tab:AddDropdown("Mode", {"Glass", "Neon", "Soft"}, "Glass", function(v) print(v) end)
        tab:AddInput("Text", "Type here", function(v) print(v) end)

    API:
        ui:SetTheme(name) | ui:SetAccent(Color3) | ui:SetNeon(bool)
        ui:SetNeonIntensity(0..1) | ui:SetMotionPreset(name) | ui:SetPerformanceMode(name)
        ui:CreateSnapshot() | ui:RestoreSnapshot(snapshot) | ui:ResetVisualSettings()
        ui:Notify(title, message, duration) | ui:Destroy()
        ui:AddTab(name) -> tab
        tab:AddSection(title) | AddLabel(text) | AddButton(text, callback)
        AddToggle(text, default, callback) | AddSlider(text, min, max, default, callback)
        AddDropdown(text, options, default, callback) | AddInput(text, placeholder, callback)
        AddColor(text, defaultColor, callback) | AddCard(title, body)
        AddProgress(text, initial 0..1) -> update(value)
]]

local Lyra = {}
Lyra.Version = "18.0.0-ECLIPSE"


local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer


local function clamp(x, a, b) return math.max(a, math.min(b, x)) end
local function round(x) return math.floor(x + 0.5) end
local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do pcall(function() obj[k] = v end) end
    obj.Parent = parent
    return obj
end
local function corner(parent, radius)
    return make("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, parent)
end
local function stroke(parent, color, thickness, transparency)
    return make("UIStroke", {Color=color, Thickness=thickness or 1, Transparency=transparency or 0.25}, parent)
end
local function pad(parent, left, right, top, bottom)
    make("UIPadding", {PaddingLeft=UDim.new(0,left or 0), PaddingRight=UDim.new(0,right or 0), PaddingTop=UDim.new(0,top or 0), PaddingBottom=UDim.new(0,bottom or 0)}, parent)
end
local function tween(obj, time, props, style, direction)
    local tw = TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end
local function hexColor(hex)
    hex = tostring(hex):gsub("#", "")
    if #hex ~= 6 then return nil end
    local r, g, b = tonumber(hex:sub(1,2),16), tonumber(hex:sub(3,4),16), tonumber(hex:sub(5,6),16)
    if not r or not g or not b then return nil end
    return Color3.fromRGB(r,g,b)
end
local function copyTable(t)
    local out = {}
    for k,v in pairs(t) do out[k] = v end
    return out
end

local Themes = {
    Eclipse={Background=Color3.fromRGB(8,7,13), Surface=Color3.fromRGB(17,14,25), Surface2=Color3.fromRGB(25,20,36), Accent=Color3.fromRGB(174,91,255), Accent2=Color3.fromRGB(113,55,205), Text=Color3.fromRGB(245,241,255), Muted=Color3.fromRGB(166,153,184), Stroke=Color3.fromRGB(92,49,139), Success=Color3.fromRGB(80,224,150), Danger=Color3.fromRGB(255,84,120)},
    Violet={Background=Color3.fromRGB(9,7,15), Surface=Color3.fromRGB(19,13,30), Surface2=Color3.fromRGB(30,20,46), Accent=Color3.fromRGB(145,75,255), Accent2=Color3.fromRGB(90,42,180), Text=Color3.fromRGB(246,241,255), Muted=Color3.fromRGB(172,155,201), Stroke=Color3.fromRGB(94,55,153), Success=Color3.fromRGB(70,225,145), Danger=Color3.fromRGB(255,82,118)},
    Rose={Background=Color3.fromRGB(13,7,12), Surface=Color3.fromRGB(24,13,23), Surface2=Color3.fromRGB(35,19,34), Accent=Color3.fromRGB(255,105,190), Accent2=Color3.fromRGB(190,50,125), Text=Color3.fromRGB(255,240,250), Muted=Color3.fromRGB(190,155,178), Stroke=Color3.fromRGB(135,55,105), Success=Color3.fromRGB(90,230,150), Danger=Color3.fromRGB(255,90,115)},
    Ocean={Background=Color3.fromRGB(5,9,15), Surface=Color3.fromRGB(10,19,30), Surface2=Color3.fromRGB(16,29,45), Accent=Color3.fromRGB(45,170,245), Accent2=Color3.fromRGB(25,100,190), Text=Color3.fromRGB(235,247,255), Muted=Color3.fromRGB(140,175,200), Stroke=Color3.fromRGB(40,105,160), Success=Color3.fromRGB(75,225,160), Danger=Color3.fromRGB(255,85,115)},
    Emerald={Background=Color3.fromRGB(5,11,9), Surface=Color3.fromRGB(10,20,16), Surface2=Color3.fromRGB(16,31,23), Accent=Color3.fromRGB(45,205,130), Accent2=Color3.fromRGB(20,125,80), Text=Color3.fromRGB(235,255,245), Muted=Color3.fromRGB(145,190,165), Stroke=Color3.fromRGB(35,125,85), Success=Color3.fromRGB(80,230,155), Danger=Color3.fromRGB(255,90,115)},
    Crimson={Background=Color3.fromRGB(12,6,9), Surface=Color3.fromRGB(22,11,16), Surface2=Color3.fromRGB(34,16,24), Accent=Color3.fromRGB(235,55,90), Accent2=Color3.fromRGB(145,25,50), Text=Color3.fromRGB(255,240,245), Muted=Color3.fromRGB(190,145,160), Stroke=Color3.fromRGB(130,35,55), Success=Color3.fromRGB(85,225,150), Danger=Color3.fromRGB(255,90,120)},
    Gold={Background=Color3.fromRGB(11,9,7), Surface=Color3.fromRGB(22,18,12), Surface2=Color3.fromRGB(34,27,18), Accent=Color3.fromRGB(235,180,55), Accent2=Color3.fromRGB(150,105,25), Text=Color3.fromRGB(255,248,230), Muted=Color3.fromRGB(190,170,125), Stroke=Color3.fromRGB(130,95,35), Success=Color3.fromRGB(80,220,140), Danger=Color3.fromRGB(255,85,110)},
    Ice={Background=Color3.fromRGB(8,10,13), Surface=Color3.fromRGB(16,20,27), Surface2=Color3.fromRGB(25,31,42), Accent=Color3.fromRGB(165,220,255), Accent2=Color3.fromRGB(75,135,190), Text=Color3.fromRGB(245,250,255), Muted=Color3.fromRGB(160,185,205), Stroke=Color3.fromRGB(85,125,160), Success=Color3.fromRGB(80,220,150), Danger=Color3.fromRGB(255,90,115)},
    Matrix={Background=Color3.fromRGB(3,8,5), Surface=Color3.fromRGB(7,15,9), Surface2=Color3.fromRGB(10,23,13), Accent=Color3.fromRGB(45,255,95), Accent2=Color3.fromRGB(20,130,45), Text=Color3.fromRGB(230,255,235), Muted=Color3.fromRGB(125,185,140), Stroke=Color3.fromRGB(25,125,55), Success=Color3.fromRGB(70,235,130), Danger=Color3.fromRGB(255,85,115)},
    Monochrome={Background=Color3.fromRGB(8,8,10), Surface=Color3.fromRGB(18,18,21), Surface2=Color3.fromRGB(28,28,32), Accent=Color3.fromRGB(205,205,215), Accent2=Color3.fromRGB(105,105,115), Text=Color3.fromRGB(245,245,248), Muted=Color3.fromRGB(165,165,175), Stroke=Color3.fromRGB(100,100,110), Success=Color3.fromRGB(100,220,160), Danger=Color3.fromRGB(255,90,115)},
    Cyber={Background=Color3.fromRGB(4,8,13), Surface=Color3.fromRGB(8,17,24), Surface2=Color3.fromRGB(14,27,37), Accent=Color3.fromRGB(0,225,255), Accent2=Color3.fromRGB(0,125,160), Text=Color3.fromRGB(235,250,255), Muted=Color3.fromRGB(130,180,195), Stroke=Color3.fromRGB(0,110,140), Success=Color3.fromRGB(75,230,160), Danger=Color3.fromRGB(255,80,120)},
    Sunset={Background=Color3.fromRGB(13,8,8), Surface=Color3.fromRGB(25,15,12), Surface2=Color3.fromRGB(38,22,16), Accent=Color3.fromRGB(255,135,60), Accent2=Color3.fromRGB(185,65,25), Text=Color3.fromRGB(255,245,235), Muted=Color3.fromRGB(205,160,130), Stroke=Color3.fromRGB(145,70,40), Success=Color3.fromRGB(85,225,150), Danger=Color3.fromRGB(255,90,115},
}

local MotionPresets = {
    Smooth={Time=0.22, Style=Enum.EasingStyle.Quad},
    Spring={Time=0.34, Style=Enum.EasingStyle.Back},
    Snappy={Time=0.12, Style=Enum.EasingStyle.Quart},
    Soft={Time=0.4, Style=Enum.EasingStyle.Sine},
    Reduced={Time=0.04, Style=Enum.EasingStyle.Linear},
}


function Lyra.new(config)
    config = config or {}
    local self = {}
    self.ThemeName = Themes[config.Theme] and config.Theme or "Eclipse"
    self.Theme = copyTable(Themes[self.ThemeName])
    self.AccentOverride = nil
    self.NeonEnabled = config.Neon == true
    self.NeonIntensity = clamp(config.NeonIntensity or 0.65, 0, 1)
    self.MotionPreset = config.MotionPreset or "Smooth"
    self.PerformanceMode = config.PerformanceMode or "Balanced"
    self.Glass = config.Glass ~= false
    self.ReducedMotion = config.ReducedMotion == true
    self.Components = {}
    self.Notifications = {}
    self.Snapshots = {}
    self._connections = {}
    self._destroyed = false
    self._tabs = {}
    self._tabButtons = {}
    self._activeTab = nil
    self._currentTabName = nil

    local pg = config.Parent
    if not pg then
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        pg = playerGui
    end
    self.Parent = pg

    local screen = make("ScreenGui", {Name="LyraEclipse", ResetOnSpawn=false, IgnoreGuiInset=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, pg)
    self.Screen = screen
    local main = make("Frame", {Name="Main", AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), Size=config.Size or UDim2.fromOffset(610,430), BackgroundColor3=self.Theme.Background, BackgroundTransparency=self.Glass and 0.08 or 0, BorderSizePixel=0}, screen)
    self.Main = main
    corner(main, 16)
    self.MainStroke = stroke(main, self.Theme.Accent, 1.5, 0.12)
    make("UISizeConstraint", {MinSize=Vector2.new(330,280), MaxSize=Vector2.new(900,700)}, main)
    local scale = make("UIScale", {Scale=1}, main)
    self.UIScale = scale
    local header = make("Frame", {Name="Header", Size=UDim2.new(1,0,0,62), BackgroundColor3=self.Theme.Surface, BackgroundTransparency=self.Glass and 0.12 or 0, BorderSizePixel=0}, main)
    corner(header,16)
    local title = make("TextLabel", {Name="Title", BackgroundTransparency=1, Position=UDim2.fromOffset(18,8), Size=UDim2.new(1,-120,0,24), Font=Enum.Font.GothamBold, Text=config.Title or "Lyra Eclipse", TextColor3=self.Theme.Text, TextSize=17, TextXAlignment=Enum.TextXAlignment.Left}, header)
    local subtitle = make("TextLabel", {Name="Subtitle", BackgroundTransparency=1, Position=UDim2.fromOffset(19,32), Size=UDim2.new(1,-120,0,18), Font=Enum.Font.Gotham, Text=config.Subtitle or "Eclipse UI Engine", TextColor3=self.Theme.Muted, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left}, header)
    self.TitleLabel, self.SubtitleLabel = title, subtitle
    local close = make("TextButton", {Name="Close", AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-12,0,12), Size=UDim2.fromOffset(32,32), BackgroundColor3=self.Theme.Surface2, Text="×", TextColor3=self.Theme.Text, TextSize=22, Font=Enum.Font.Gotham, BorderSizePixel=0, AutoButtonColor=false}, header)
    corner(close,9)
    local mini = make("TextButton", {Name="Minimize", AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-50,0,12), Size=UDim2.fromOffset(32,32), BackgroundColor3=self.Theme.Surface2, Text="−", TextColor3=self.Theme.Text, TextSize=22, Font=Enum.Font.Gotham, BorderSizePixel=0, AutoButtonColor=false}, header)
    corner(mini,9)
    local tabRail = make("ScrollingFrame", {Name="TabRail", Position=UDim2.fromOffset(12,72), Size=UDim2.new(0,140,1,-84), BackgroundColor3=self.Theme.Surface, BackgroundTransparency=0.12, BorderSizePixel=0, ScrollBarThickness=2, ScrollBarImageColor3=self.Theme.Accent, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y}, main)
    corner(tabRail,11); pad(tabRail,8,8,8,8)
    make("UIListLayout", {Padding=UDim.new(0,7), SortOrder=Enum.SortOrder.LayoutOrder}, tabRail)
    local content = make("Frame", {Name="Content", Position=UDim2.fromOffset(164,72), Size=UDim2.new(1,-176,1,-84), BackgroundColor3=self.Theme.Surface, BackgroundTransparency=0.12, BorderSizePixel=0}, main)
    corner(content,11)
    self.Header, self.TabRail, self.Content = header, tabRail, content
    self._dragging = false
    local dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self._dragging=true; dragStart=input.Position; startPos=main.Position
        end
    end)
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then self._dragging=false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if self._dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta=input.Position-dragStart
            main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)
    close.Activated:Connect(function() self:Destroy() end)
    mini.Activated:Connect(function()
        self._minimized = not self._minimized
        if self._minimized then tween(main,0.18,{Size=UDim2.new(main.Size.X.Scale,main.Size.X.Offset,0,62)}); content.Visible=false; tabRail.Visible=false
        else tween(main,0.2,{Size=config.Size or UDim2.fromOffset(610,430)}); content.Visible=true; tabRail.Visible=true end
    end)
    self:_applyResponsive()
    self:_applyTheme()
    if config.ThemeStudio ~= false then self:_createThemeStudio() end
    if config.Playground ~= false then self:_createPlayground() end
    return self
end


function Lyra:_applyResponsive()
    local camera=workspace.CurrentCamera
    if not camera then return end
    local size=camera.ViewportSize
    if size.X < 560 then
        self.UIScale.Scale=clamp(size.X/610,0.72,0.95)
        self.Main.Size=UDim2.fromOffset(610,430)
    else
        self.UIScale.Scale=1
    end
end

function Lyra:_getAccent() return self.AccentOverride or self.Theme.Accent end
function Lyra:_motion()
    if self.ReducedMotion or self.PerformanceMode=="Low" then return MotionPresets.Reduced end
    return MotionPresets[self.MotionPreset] or MotionPresets.Smooth
end
function Lyra:_applyTheme()
    if self._destroyed then return end
    local t=self.Theme; local accent=self:_getAccent()
    local bg=self.Main
    bg.BackgroundColor3=t.Background
    if self.MainStroke then self.MainStroke.Color=accent; self.MainStroke.Transparency=self.NeonEnabled and 0.05 or 0.22 end
    self.Header.BackgroundColor3=t.Surface
    self.TitleLabel.TextColor3=t.Text; self.SubtitleLabel.TextColor3=t.Muted
    self.TabRail.BackgroundColor3=t.Surface; self.TabRail.ScrollBarImageColor3=accent
    self.Content.BackgroundColor3=t.Surface
    for _,obj in ipairs(self.Components) do
        if obj and obj.Parent then
            local role=obj:GetAttribute("LyraRole")
            if role=="toggleTrack" then
                local enabled=obj:GetAttribute("LyraEnabled") == true
                obj.BackgroundColor3=enabled and accent or t.Surface2
                local knob=obj:FindFirstChild("Knob")
                if knob then knob.BackgroundColor3=t.Text end
                local st=obj:FindFirstChildOfClass("UIStroke"); if st then st.Color=enabled and accent or t.Stroke end
            elseif role=="sliderFill" then obj.BackgroundColor3=accent
            elseif role=="sliderKnob" then obj.BackgroundColor3=t.Text
            elseif role=="accentStroke" then obj.Color=accent; obj.Transparency=self.NeonEnabled and (1-self.NeonIntensity*0.8) or 0.35
            elseif role=="neonStroke" then obj.Color=accent; obj.Transparency=self.NeonEnabled and (1-self.NeonIntensity*0.75) or 0.5
            elseif role=="accentButton" then obj.BackgroundColor3=accent; obj.TextColor3=t.Text
            elseif role=="label" then obj.TextColor3=t.Text
            elseif role=="mutedLabel" then obj.TextColor3=t.Muted
            elseif role=="surface" then obj.BackgroundColor3=t.Surface
            elseif role=="surface2" then obj.BackgroundColor3=t.Surface2
            elseif role=="input" then obj.BackgroundColor3=t.Surface2; obj.TextColor3=t.Text
            elseif role=="tabButton" then
                local active=obj:GetAttribute("LyraActive") == true
                obj.BackgroundColor3=active and accent or t.Surface2
                obj.TextColor3=active and t.Text or t.Muted
            elseif role=="neonStroke" then
                obj.Color=accent; obj.Transparency=self.NeonEnabled and (1-self.NeonIntensity*0.75) or 0.45
            elseif role=="progressFill" then obj.BackgroundColor3=accent
            elseif role=="card" then obj.BackgroundColor3=t.Surface2
            end
        end
    end
end
function Lyra:_register(obj, role)
    if obj then obj:SetAttribute("LyraRole",role); table.insert(self.Components,obj) end
    return obj
end
function Lyra:SetTheme(name)
    if not Themes[name] then return false end
    self.ThemeName=name; self.Theme=copyTable(Themes[name]); self.AccentOverride=nil; self:_applyTheme(); return true
end
function Lyra:GetThemeNames()
    local out={}; for n in pairs(Themes) do table.insert(out,n) end; table.sort(out); return out
end
function Lyra:SetAccent(color)
    if typeof(color)=="Color3" then self.AccentOverride=color; self:_applyTheme(); return true end
    return false
end
function Lyra:SetNeon(enabled) self.NeonEnabled=enabled==true; self:_applyTheme() end
function Lyra:SetNeonIntensity(value) self.NeonIntensity=clamp(value,0,1); self:_applyTheme() end
function Lyra:SetMotionPreset(name) if MotionPresets[name] then self.MotionPreset=name; return true end return false end
function Lyra:SetReducedMotion(enabled) self.ReducedMotion=enabled==true end
function Lyra:SetPerformanceMode(mode) if mode=="Low" or mode=="Balanced" or mode=="High" then self.PerformanceMode=mode; self:_applyTheme(); return true end return false end
function Lyra:SetGlass(enabled) self.Glass=enabled==true; self.Main.BackgroundTransparency=self.Glass and 0.08 or 0; self.Content.BackgroundTransparency=self.Glass and 0.12 or 0; self.TabRail.BackgroundTransparency=self.Glass and 0.12 or 0; return true end
function Lyra:CreateSnapshot()
    local snap={ThemeName=self.ThemeName,AccentOverride=self.AccentOverride,NeonEnabled=self.NeonEnabled,NeonIntensity=self.NeonIntensity,MotionPreset=self.MotionPreset,PerformanceMode=self.PerformanceMode,Glass=self.Glass,ReducedMotion=self.ReducedMotion}
    table.insert(self.Snapshots,snap); return snap
end
function Lyra:RestoreSnapshot(s)
    if type(s)~="table" then return false end
    if Themes[s.ThemeName] then self.ThemeName=s.ThemeName; self.Theme=copyTable(Themes[s.ThemeName]) end
    self.AccentOverride=s.AccentOverride; self.NeonEnabled=s.NeonEnabled==true; self.NeonIntensity=clamp(s.NeonIntensity or 0.65,0,1)
    self.MotionPreset=MotionPresets[s.MotionPreset] and s.MotionPreset or "Smooth"; self.PerformanceMode=s.PerformanceMode or "Balanced"; self.Glass=s.Glass~=false; self.ReducedMotion=s.ReducedMotion==true
    self:SetGlass(self.Glass); self:_applyTheme(); return true
end
function Lyra:ResetVisualSettings()
    self:SetTheme("Eclipse"); self.NeonEnabled=false; self.NeonIntensity=0.65; self.MotionPreset="Smooth"; self.PerformanceMode="Balanced"; self.Glass=true; self.ReducedMotion=false; self:_applyTheme()
end
function Lyra:Notify(titleText, message, duration)
    duration=duration or 3.5
    local t=self.Theme; local accent=self:_getAccent()
    local note=make("Frame",{Size=UDim2.fromOffset(280,76),Position=UDim2.new(1,300,0,20),AnchorPoint=Vector2.new(1,0),BackgroundColor3=t.Surface2,BorderSizePixel=0},self.Screen)
    corner(note,12); local st=stroke(note,accent,1.2,0.1)
    make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-24,0,20),Font=Enum.Font.GothamBold,Text=tostring(titleText or "Lyra"),TextColor3=t.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left},note)
    make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,30),Size=UDim2.new(1,-24,0,36),Font=Enum.Font.Gotham,Text=tostring(message or ""),TextColor3=t.Muted,TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top},note)
    tween(note,0.3,{Position=UDim2.new(1,-12,0,20)},Enum.EasingStyle.Back)
    table.insert(self.Notifications,{Title=titleText,Message=message,Time=os.time()})
    task.delay(duration,function() if note.Parent then tween(note,0.22,{Position=UDim2.new(1,300,0,20)}); task.delay(0.24,function() note:Destroy() end) end end)
    return note
end
function Lyra:Destroy()
    if self._destroyed then return end; self._destroyed=true
    for _,c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
    if self.Screen then self.Screen:Destroy() end
end


function Lyra:_createThemeStudio()
    local tab=self:AddTab("Theme Studio",true)
    tab:AddSection("Eclipse Theme Laboratory")
    tab:AddLabel("Preview themes and accent colors live. Active controls react to the selected palette.")
    tab:AddDropdown("Preset theme",self:GetThemeNames(),self.ThemeName,function(name) self:SetTheme(name) end)
    tab:AddToggle("Neon effects",self.NeonEnabled,function(v) self:SetNeon(v) end)
    tab:AddSlider("Neon intensity",0,100,round(self.NeonIntensity*100),function(v) self:SetNeonIntensity(v/100) end)
    tab:AddToggle("Glass transparency",self.Glass,function(v) self:SetGlass(v) end)
    tab:AddDropdown("Motion preset",{"Smooth","Spring","Snappy","Soft","Reduced"},self.MotionPreset,function(v) self:SetMotionPreset(v); self:SetReducedMotion(v=="Reduced") end)
    tab:AddDropdown("Performance mode",{"Low","Balanced","High"},self.PerformanceMode,function(v) self:SetPerformanceMode(v) end)
    tab:AddButton("Snapshot visual settings",function() local s=self:CreateSnapshot(); self:Notify("Snapshot","Visual settings snapshot created.") end)
    tab:AddButton("Restore latest snapshot",function() local s=self.Snapshots[#self.Snapshots]; if s then self:RestoreSnapshot(s); self:Notify("Snapshot","Latest visual snapshot restored.") else self:Notify("Snapshot","No snapshots yet.") end end)
    tab:AddButton("Reset visual settings",function() self:ResetVisualSettings(); self:Notify("Reset","Visual settings restored to defaults.") end)
    tab:AddSection("Theme Mirror")
    tab:AddDropdown("Compare theme",self:GetThemeNames(),"Violet",function(name)
        local preview=self._mirrorPreview
        if preview then preview.BackgroundColor3=Themes[name].Surface2; preview:FindFirstChild("PreviewAccent").BackgroundColor3=Themes[name].Accent; preview:FindFirstChild("PreviewText").Text="Preview: "..name end
    end)
    local mirror=make("Frame",{Size=UDim2.new(1,-8,0,88),BackgroundColor3=self.Theme.Surface2,BorderSizePixel=0},tab.Container); corner(mirror,10); stroke(mirror,self.Theme.Stroke,1,0.35)
    make("Frame",{Name="PreviewAccent",Position=UDim2.fromOffset(10,10),Size=UDim2.fromOffset(38,6),BackgroundColor3=self.Theme.Accent,BorderSizePixel=0},mirror)
    make("TextLabel",{Name="PreviewText",BackgroundTransparency=1,Position=UDim2.fromOffset(10,22),Size=UDim2.new(1,-20,0,24),Font=Enum.Font.GothamBold,Text="Preview: "..self.ThemeName,TextColor3=self.Theme.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left},mirror)
    self._mirrorPreview=mirror
end
function Lyra:_createPlayground()
    local tab=self:AddTab("Playground",true)
    tab:AddSection("Component Factory")
    tab:AddLabel("Live preview of the universal component styles.")
    tab:AddButton("Glass Button",function() self:Notify("Component Factory","Glass interaction preview") end,"Glass")
    tab:AddToggle("Preview Toggle",false,function(v) self:Notify("State",v and "Enabled" or "Disabled",1.5) end)
    tab:AddSlider("Preview Slider",0,100,35,function() end)
    tab:AddDropdown("Variant",{"Glass","Neon","Soft","Minimal","Premium","Outline","Gradient","Floating","Holographic"},"Glass",function(v) self:Notify("Variant",v,1.5) end)
end


function Lyra:AddTab(name, internal)
    local tab={Name=name,Owner=self,Internal=internal==true,Rows={},_order=#self._tabs+1}
    local btn=make("TextButton",{Name="Tab_"..tostring(name),Size=UDim2.new(1,0,0,34),BackgroundColor3=self.Theme.Surface2,Text=tostring(name),TextColor3=self.Theme.Muted,TextSize=12,Font=Enum.Font.GothamMedium,BorderSizePixel=0,AutoButtonColor=false},self.TabRail)
    corner(btn,8); self:_register(btn,"tabButton"); btn:SetAttribute("LyraActive",false)
    local container=make("ScrollingFrame",{Name="TabContent_"..name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=self:_getAccent(),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},self.Content)
    pad(container,10,10,10,10); make("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},container)
    tab.Button=btn; tab.Container=container; table.insert(self._tabs,tab); table.insert(self._tabButtons,btn)
    btn.Activated:Connect(function() self:_selectTab(tab) end)
    if not self._activeTab then self:_selectTab(tab) end
    function tab:AddSection(text)
        local owner=self.Owner
        local label=make("TextLabel",{Size=UDim2.new(1,-2,0,25),BackgroundTransparency=1,Text=tostring(text),TextColor3=owner:_getAccent(),Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left},self.Container)
        owner:_register(label,"label"); return label
    end
    function tab:AddLabel(text)
        local owner=self.Owner
        local label=make("TextLabel",{Size=UDim2.new(1,-2,0,28),BackgroundTransparency=1,Text=tostring(text),TextColor3=owner.Theme.Muted,Font=Enum.Font.Gotham,TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},self.Container)
        owner:_register(label,"mutedLabel"); return label
    end
    function tab:AddCard(titleText,bodyText)
        local owner=self.Owner; local card=make("Frame",{Size=UDim2.new(1,-2,0,78),BackgroundColor3=owner.Theme.Surface2,BorderSizePixel=0},self.Container); corner(card,10); owner:_register(card,"card")
        local cardTitle=make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,9),Size=UDim2.new(1,-24,0,20),Text=tostring(titleText),TextColor3=owner.Theme.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},card); owner:_register(cardTitle,"label")
        local cardBody=make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,30),Size=UDim2.new(1,-24,0,38),Text=tostring(bodyText),TextColor3=owner.Theme.Muted,Font=Enum.Font.Gotham,TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top},card); owner:_register(cardBody,"mutedLabel"); return card
    end
    function tab:AddButton(text,callback,variant)
        local owner=self.Owner; local b=make("TextButton",{Size=UDim2.new(1,-2,0,36),BackgroundColor3=owner:_getAccent(),Text=tostring(text),TextColor3=owner.Theme.Text,Font=Enum.Font.GothamMedium,TextSize=12,BorderSizePixel=0,AutoButtonColor=false},self.Container); corner(b,9); owner:_register(b,"accentButton")
        if variant=="Glass" then b.BackgroundTransparency=0.25; owner:_register(b,"surface2") end
        local st=stroke(b,owner:_getAccent(),1,owner.NeonEnabled and 0.1 or 0.5); owner:_register(st,"accentStroke")
        b.Activated:Connect(function() local m=owner:_motion(); tween(b,m.Time,{BackgroundTransparency=0.12},m.Style); task.delay(m.Time,function() if b.Parent then tween(b,m.Time,{BackgroundTransparency=0},m.Style) end end); if callback then task.spawn(callback) end end)
        return b
    end
    function tab:AddToggle(text,default,callback)
        local owner=self.Owner; local row=make("Frame",{Size=UDim2.new(1,-2,0,40),BackgroundColor3=owner.Theme.Surface2,BorderSizePixel=0},self.Container); corner(row,9)
        local label=make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-72,1,0),Text=tostring(text),TextColor3=owner.Theme.Text,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},row); owner:_register(label,"label")
        local track=make("TextButton",{Name="Track",AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.fromOffset(42,22),BackgroundColor3=owner.Theme.Surface,Text="",BorderSizePixel=0,AutoButtonColor=false},row); corner(track,11); local ts=stroke(track,owner.Theme.Stroke,1,0.2)
        local knob=make("Frame",{Name="Knob",Size=UDim2.fromOffset(16,16),Position=UDim2.fromOffset(3,3),BackgroundColor3=owner.Theme.Text,BorderSizePixel=0},track); corner(knob,8)
        owner:_register(track,"toggleTrack"); track:SetAttribute("LyraEnabled",default==true); owner:_register(ts,"neonStroke")
        local enabled=default==true
        local function set(v,fire)
            enabled=v==true; track:SetAttribute("LyraEnabled",enabled); owner:_applyTheme()
            local m=owner:_motion(); tween(knob,m.Time,{Position=enabled and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3)},m.Style)
            if fire and callback then task.spawn(callback,enabled) end
        end
        track.Activated:Connect(function() set(not enabled,true) end); set(enabled,false)
        return {Set=set,Get=function() return enabled end,Frame=row}
    end
    function tab:AddSlider(text,minValue,maxValue,default,callback)
        local owner=self.Owner; minValue=minValue or 0; maxValue=maxValue or 100; default=clamp(default or minValue,minValue,maxValue)
        local row=make("Frame",{Size=UDim2.new(1,-2,0,52),BackgroundColor3=owner.Theme.Surface2,BorderSizePixel=0},self.Container); corner(row,9)
        make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,4),Size=UDim2.new(1,-70,0,20),Text=tostring(text),TextColor3=owner.Theme.Text,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},row)
        local valueLabel=make("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,4),Size=UDim2.fromOffset(55,20),Text=tostring(round(default)),TextColor3=owner.Theme.Muted,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right},row); owner:_register(valueLabel,"mutedLabel")
        local bar=make("Frame",{Position=UDim2.fromOffset(12,32),Size=UDim2.new(1,-24,0,6),BackgroundColor3=owner.Theme.Surface,BorderSizePixel=0},row); corner(bar,4)
        local fill=make("Frame",{Size=UDim2.new((default-minValue)/(maxValue-minValue),0,1,0),BackgroundColor3=owner:_getAccent(),BorderSizePixel=0},bar); corner(fill,4); owner:_register(fill,"sliderFill")
        local knob=make("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new((default-minValue)/(maxValue-minValue),0,0.5,0),Size=UDim2.fromOffset(12,12),BackgroundColor3=owner.Theme.Text,BorderSizePixel=0},bar); corner(knob,6); owner:_register(knob,"sliderKnob")
        local hit=make("TextButton",{Position=UDim2.fromOffset(0,25),Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text="",BorderSizePixel=0},row)
        local value=default; local dragging=false
        local function update(x,fire)
            local pct=clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); value=minValue+(maxValue-minValue)*pct
            fill.Size=UDim2.new(pct,0,1,0); knob.Position=UDim2.new(pct,0,0.5,0); valueLabel.Text=tostring(round(value))
            if fire and callback then task.spawn(callback,value) end
        end
        hit.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true; update(input.Position.X,true) end end)
        hit.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
        UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then update(input.Position.X,true) end end)
        return {Set=function(v) value=clamp(v,minValue,maxValue); local p=(value-minValue)/(maxValue-minValue); fill.Size=UDim2.new(p,0,1,0); knob.Position=UDim2.new(p,0,0.5,0); valueLabel.Text=tostring(round(value)) end,Get=function() return value end,Frame=row}
    end
    function tab:AddDropdown(text,options,default,callback)
        local owner=self.Owner; options=options or {}; local row=make("Frame",{Size=UDim2.new(1,-2,0,58),BackgroundColor3=owner.Theme.Surface2,BorderSizePixel=0},self.Container); corner(row,9)
        make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,5),Size=UDim2.new(1,-24,0,18),Text=tostring(text),TextColor3=owner.Theme.Text,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},row)
        local button=make("TextButton",{Position=UDim2.fromOffset(10,27),Size=UDim2.new(1,-20,0,24),BackgroundColor3=owner.Theme.Surface,Text=tostring(default or options[1] or "Select"),TextColor3=owner.Theme.Muted,Font=Enum.Font.Gotham,TextSize=11,BorderSizePixel=0,AutoButtonColor=false},row); corner(button,7); owner:_register(button,"input")
        local list=make("Frame",{Position=UDim2.new(0,10,1,3),Size=UDim2.new(1,-20,0,0),BackgroundColor3=owner.Theme.Surface,Visible=false,ClipsDescendants=true,BorderSizePixel=0,ZIndex=20},row); corner(list,7); stroke(list,owner:_getAccent(),1,0.25)
        local layout=make("UIListLayout",{Padding=UDim.new(0,2)},list)
        local current=default or options[1]; local open=false
        for _,opt in ipairs(options) do
            local item=make("TextButton",{Size=UDim2.new(1,0,0,26),BackgroundColor3=owner.Theme.Surface2,Text=tostring(opt),TextColor3=owner.Theme.Text,TextSize=11,Font=Enum.Font.Gotham,BorderSizePixel=0,AutoButtonColor=false,ZIndex=21},list)
            item.Activated:Connect(function() current=opt; button.Text=tostring(opt); open=false; list.Visible=false; list.Size=UDim2.new(1,-20,0,0); if callback then task.spawn(callback,opt) end end)
        end
        button.Activated:Connect(function() open=not open; list.Visible=open; list.Size=open and UDim2.new(1,-20,0,math.min(#options*28,140)) or UDim2.new(1,-20,0,0) end)
        return {Get=function() return current end,Set=function(v) current=v; button.Text=tostring(v) end,Frame=row}
    end
    function tab:AddInput(text,placeholder,callback)
        local owner=self.Owner; local row=make("Frame",{Size=UDim2.new(1,-2,0,54),BackgroundColor3=owner.Theme.Surface2,BorderSizePixel=0},self.Container); corner(row,9)
        make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,4),Size=UDim2.new(1,-24,0,18),Text=tostring(text),TextColor3=owner.Theme.Text,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},row)
        local input=make("TextBox",{Position=UDim2.fromOffset(10,25),Size=UDim2.new(1,-20,0,24),BackgroundColor3=owner.Theme.Surface,Text="",PlaceholderText=placeholder or "Enter text",PlaceholderColor3=owner.Theme.Muted,TextColor3=owner.Theme.Text,Font=Enum.Font.Gotham,TextSize=11,ClearTextOnFocus=false,BorderSizePixel=0},row); corner(input,7); owner:_register(input,"input")
        input.FocusLost:Connect(function(enter) if callback then task.spawn(callback,input.Text,enter) end end); return input
    end
    function tab:AddColor(text,defaultColor,callback)
        local owner=self.Owner; local row=make("Frame",{Size=UDim2.new(1,-2,0,48),BackgroundColor3=owner.Theme.Surface2,BorderSizePixel=0},self.Container); corner(row,9)
        make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-60,1,0),Text=tostring(text),TextColor3=owner.Theme.Text,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},row)
        local swatch=make("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),Size=UDim2.fromOffset(34,24),BackgroundColor3=defaultColor or owner:_getAccent(),Text="",BorderSizePixel=0,AutoButtonColor=false},row); corner(swatch,7); stroke(swatch,owner.Theme.Text,1,0.5)
        swatch.Activated:Connect(function() owner:Notify("Color Preview","Use ui:SetAccent(Color3.fromRGB(r,g,b)) to set a custom accent.") end)
        return swatch
    end
    function tab:AddProgress(text,initial)
        local owner=self.Owner; local row=make("Frame",{Size=UDim2.new(1,-2,0,45),BackgroundColor3=owner.Theme.Surface2,BorderSizePixel=0},self.Container); corner(row,9)
        make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,3),Size=UDim2.new(1,-24,0,17),Text=tostring(text),TextColor3=owner.Theme.Text,Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},row)
        local bar=make("Frame",{Position=UDim2.fromOffset(12,25),Size=UDim2.new(1,-24,0,7),BackgroundColor3=owner.Theme.Surface,BorderSizePixel=0},row); corner(bar,4)
        local fill=make("Frame",{Size=UDim2.new(clamp(initial or 0,0,1),0,1,0),BackgroundColor3=owner:_getAccent(),BorderSizePixel=0},bar); corner(fill,4); owner:_register(fill,"progressFill")
        return function(v) fill.Size=UDim2.new(clamp(v,0,1),0,1,0) end
    end
    return tab
end
function Lyra:_selectTab(tab)
    self._activeTab=tab; self._currentTabName=tab.Name
    for _,t in ipairs(self._tabs) do
        t.Container.Visible=t==tab
        t.Button:SetAttribute("LyraActive",t==tab)
    end
    self:_applyTheme()
end

Lyra.Themes=Themes
Lyra.MotionPresets=MotionPresets
return Lyra
