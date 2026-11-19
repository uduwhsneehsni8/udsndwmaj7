-- Lyra Library V15 ECLIPSE
-- UI framework for Roblox Studio projects. Safe UI-only library.
-- Place this ModuleScript in ReplicatedStorage and require it from a LocalScript.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Lyra = {}
Lyra.Version = "15.0 ECLIPSE"
Lyra.Themes = {
 Eclipse = {Bg=Color3.fromRGB(12,10,20), Panel=Color3.fromRGB(22,18,34), Panel2=Color3.fromRGB(31,25,46), Accent=Color3.fromRGB(166,108,255), Accent2=Color3.fromRGB(220,130,255), Text=Color3.fromRGB(245,240,255), Muted=Color3.fromRGB(170,157,190), Stroke=Color3.fromRGB(74,52,105)},
 Aurora = {Bg=Color3.fromRGB(8,16,22), Panel=Color3.fromRGB(16,29,38), Panel2=Color3.fromRGB(23,40,50), Accent=Color3.fromRGB(78,220,210), Accent2=Color3.fromRGB(146,255,226), Text=Color3.fromRGB(235,250,250), Muted=Color3.fromRGB(145,180,185), Stroke=Color3.fromRGB(45,90,100)},
 Rose = {Bg=Color3.fromRGB(20,10,18), Panel=Color3.fromRGB(35,18,30), Panel2=Color3.fromRGB(48,24,40), Accent=Color3.fromRGB(255,105,180), Accent2=Color3.fromRGB(255,175,220), Text=Color3.fromRGB(255,240,250), Muted=Color3.fromRGB(190,145,175), Stroke=Color3.fromRGB(105,55,85)},
 Ocean = {Bg=Color3.fromRGB(8,12,22), Panel=Color3.fromRGB(15,22,36), Panel2=Color3.fromRGB(22,31,48), Accent=Color3.fromRGB(75,155,255), Accent2=Color3.fromRGB(125,210,255), Text=Color3.fromRGB(235,245,255), Muted=Color3.fromRGB(145,170,200), Stroke=Color3.fromRGB(45,70,110)},
 Light = {Bg=Color3.fromRGB(235,232,245), Panel=Color3.fromRGB(250,248,255), Panel2=Color3.fromRGB(225,220,240), Accent=Color3.fromRGB(125,70,220), Accent2=Color3.fromRGB(160,100,245), Text=Color3.fromRGB(35,25,50), Muted=Color3.fromRGB(105,90,125), Stroke=Color3.fromRGB(190,175,215)}
}
local function tween(o, t, props, style)
 if not o or not o.Parent then return end
 TweenService:Create(o,TweenInfo.new(t or .2,style or Enum.EasingStyle.Quint,Enum.EasingDirection.Out),props):Play()
end
local function corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 12); c.Parent=o; return c end
local function stroke(o,color,thick,trans) local s=Instance.new("UIStroke"); s.Color=color; s.Thickness=thick or 1; s.Transparency=trans or 0; s.Parent=o; return s end
local function pad(o,n) local p=Instance.new("UIPadding"); p.PaddingTop=UDim.new(0,n); p.PaddingBottom=UDim.new(0,n); p.PaddingLeft=UDim.new(0,n); p.PaddingRight=UDim.new(0,n); p.Parent=o; return p end
local function list(o,g) local l=Instance.new("UIListLayout"); l.Padding=UDim.new(0,g or 8); l.SortOrder=Enum.SortOrder.LayoutOrder; l.Parent=o; return l end
local function label(parent,text,size,color,bold) local x=Instance.new("TextLabel"); x.BackgroundTransparency=1; x.Text=text or ""; x.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham; x.TextSize=size or 13; x.TextColor3=color; x.TextXAlignment=Enum.TextXAlignment.Left; x.TextWrapped=true; x.AutomaticSize=Enum.AutomaticSize.Y; x.Size=UDim2.new(1,0,0,0); x.Parent=parent; return x end
local function button(parent,text,theme,height) local b=Instance.new("TextButton"); b.Text=text; b.AutoButtonColor=false; b.Font=Enum.Font.GothamMedium; b.TextSize=13; b.TextColor3=theme.Text; b.BackgroundColor3=theme.Panel2; b.Size=UDim2.new(1,0,0,height or 38); b.Parent=parent; corner(b,10); stroke(b,theme.Stroke,1,.15); b.MouseEnter:Connect(function() tween(b,.14,{BackgroundColor3=theme.Accent}) end); b.MouseLeave:Connect(function() tween(b,.18,{BackgroundColor3=theme.Panel2}) end); b.MouseButton1Down:Connect(function() tween(b,.08,{Size=UDim2.new(1,-4,0,(height or 38)-2)}) end); b.MouseButton1Up:Connect(function() tween(b,.12,{Size=UDim2.new(1,0,0,height or 38)}) end); return b end
local function card(parent,theme,height) local f=Instance.new("Frame"); f.BackgroundColor3=theme.Panel; f.Size=UDim2.new(1,0,0,height or 58); f.Parent=parent; corner(f,12); stroke(f,theme.Stroke,1,.2); return f end
local function makeScroll(parent,theme) local s=Instance.new("ScrollingFrame"); s.BackgroundTransparency=1; s.BorderSizePixel=0; s.Size=UDim2.new(1,0,1,0); s.ScrollBarThickness=3; s.ScrollBarImageColor3=theme.Accent; s.CanvasSize=UDim2.new(); s.AutomaticCanvasSize=Enum.AutomaticSize.Y; s.Parent=parent; pad(s,10); list(s,9); return s end
local function drag(frame,handle)
 local dragging=false; local startPos; local startFrame
 handle.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true; startPos=input.Position; startFrame=frame.Position end end)
 UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then local d=input.Position-startPos; frame.Position=UDim2.new(startFrame.X.Scale,startFrame.X.Offset+d.X,startFrame.Y.Scale,startFrame.Y.Offset+d.Y) end end)
 UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
end
function Lyra:CreateWindow(config)
 config=config or {}; local player=config.Player or Players.LocalPlayer; local theme=Lyra.Themes[config.Theme or "Eclipse"] or Lyra.Themes.Eclipse
 local gui=Instance.new("ScreenGui"); gui.Name=config.Name or "LyraEclipse"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
 local parent=config.Parent or player:WaitForChild("PlayerGui"); gui.Parent=parent
 local root=Instance.new("Frame"); root.Name="Root"; root.BackgroundColor3=theme.Bg; root.Size=config.Size or UDim2.fromOffset(700,470); root.Position=UDim2.new(.5,-350,.5,-235); root.Parent=gui; corner(root,18); stroke(root,theme.Accent,1.5,.05)
 local scale=Instance.new("UIScale"); scale.Scale=1; scale.Parent=root
 local top=Instance.new("Frame"); top.BackgroundColor3=theme.Panel; top.Size=UDim2.new(1,0,0,52); top.Parent=root; corner(top,18)
 local title=label(top,config.Title or "LYRA ECLIPSE",16,theme.Text,true); title.Position=UDim2.fromOffset(16,0); title.Size=UDim2.new(.7,-16,1,0); title.TextYAlignment=Enum.TextYAlignment.Center
 local close=Instance.new("TextButton"); close.Text="×"; close.Font=Enum.Font.GothamBold; close.TextSize=24; close.TextColor3=theme.Text; close.BackgroundColor3=theme.Panel2; close.Size=UDim2.fromOffset(36,34); close.Position=UDim2.new(1,-44,0,9); close.Parent=top; corner(close,9); close.MouseButton1Click:Connect(function() gui:Destroy() end)
 drag(root,top)
 local side=Instance.new("Frame"); side.BackgroundColor3=theme.Panel; side.Position=UDim2.fromOffset(10,62); side.Size=UDim2.new(0,148,1,-72); side.Parent=root; corner(side,12); pad(side,8); list(side,6)
 local content=Instance.new("Frame"); content.BackgroundTransparency=1; content.Position=UDim2.fromOffset(168,62); content.Size=UDim2.new(1,-178,1,-72); content.Parent=root
 local window={Gui=gui,Root=root,Theme=theme,Tabs={},Current=nil,Content=content,Sidebar=side,Destroyed=false}
 function window:SetTheme(name) local t=Lyra.Themes[name]; if not t then return false end; self.Theme=t; root.BackgroundColor3=t.Bg; top.BackgroundColor3=t.Panel; side.BackgroundColor3=t.Panel; return true end
 function window:Notify(text,kind,duration) local n=card(gui,theme,54); n.AnchorPoint=Vector2.new(1,0); n.Position=UDim2.new(1,-16,0,70); n.Size=UDim2.fromOffset(260,54); n.ZIndex=30; local tx=label(n,text,13,theme.Text,true); tx.Position=UDim2.fromOffset(12,8); tx.Size=UDim2.new(1,-24,1,-16); tx.ZIndex=31; task.delay(duration or 3,function() if n.Parent then tween(n,.25,{BackgroundTransparency=1}); task.wait(.3); n:Destroy() end end); return n end
 function window:AddTab(name,icon)
  local tab={Name=name,Items={},Window=window}; local tb=button(side,(icon and icon.."  " or "")..name,theme,36); local page=makeScroll(content,theme); page.Visible=false
  tb.MouseButton1Click:Connect(function() for _,t in ipairs(window.Tabs) do t.Page.Visible=false end; page.Visible=true; window.Current=tab; tween(tb,.1,{BackgroundColor3=theme.Accent}) end)
  function tab:_item(frame) frame.Parent=page; table.insert(self.Items,frame); return frame end
  function tab:AddSection(text) local l=label(page,text,12,theme.Accent2,true); l.LayoutOrder=#self.Items+1; return l end
  function tab:AddLabel(text) local f=card(page,theme,42); local l=label(f,text,13,theme.Text,false); l.Position=UDim2.fromOffset(12,8); l.Size=UDim2.new(1,-24,1,-16); return f end
  function tab:AddParagraph(titleText,body) local f=card(page,theme,78); local a=label(f,titleText,14,theme.Text,true); a.Position=UDim2.fromOffset(12,10); a.Size=UDim2.new(1,-24,0,20); local b=label(f,body,12,theme.Muted,false); b.Position=UDim2.fromOffset(12,32); b.Size=UDim2.new(1,-24,0,38); return f end
  function tab:AddButton(cfg) cfg=cfg or {}; local b=button(page,cfg.Title or "Button",theme,cfg.Height); b.MouseButton1Click:Connect(function() if cfg.Callback then task.spawn(cfg.Callback) end end); return {Button=b,SetText=function(_,v)b.Text=v end} end
  function tab:AddToggle(cfg) cfg=cfg or {}; local f=card(page,theme,42); local l=label(f,cfg.Title or "Toggle",13,theme.Text,true); l.Position=UDim2.fromOffset(12,0); l.Size=UDim2.new(1,-65,1,0); l.TextYAlignment=Enum.TextYAlignment.Center; local b=button(f,(cfg.Default and "ON" or "OFF"),theme,28); b.Size=UDim2.fromOffset(48,28); b.Position=UDim2.new(1,-58,0,7); local state=cfg.Default==true; local function set(v) state=v==true; b.Text=state and "ON" or "OFF"; b.BackgroundColor3=state and theme.Accent or theme.Panel2; if cfg.Callback then cfg.Callback(state) end end; b.MouseButton1Click:Connect(function() set(not state) end); return {Set=set,Get=function()return state end} end
  function tab:AddSlider(cfg)
   cfg=cfg or {}; local min=cfg.Min or 0; local max=cfg.Max or 100; if max<=min then max=min+1 end
   local val=math.clamp(cfg.Default or min,min,max); local f=card(page,theme,64)
   local l=label(f,(cfg.Title or "Slider").."  •  "..tostring(val),13,theme.Text,true); l.Position=UDim2.fromOffset(12,7); l.Size=UDim2.new(1,-24,0,18)
   local track=Instance.new("Frame"); track.BackgroundColor3=theme.Panel2; track.Position=UDim2.fromOffset(12,36); track.Size=UDim2.new(1,-24,0,8); track.Parent=f; corner(track,4)
   local fill=Instance.new("Frame"); fill.BackgroundColor3=theme.Accent; fill.Size=UDim2.new((val-min)/(max-min),0,1,0); fill.Parent=track; corner(fill,4)
   local hit=Instance.new("TextButton"); hit.Text=""; hit.BackgroundTransparency=1; hit.Size=UDim2.new(1,0,0,24); hit.Position=UDim2.new(0,0,0,-8); hit.Parent=track
   local dragging=false
   local function setFromX(x) local ratio=math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1); val=min+(max-min)*ratio; fill.Size=UDim2.new(ratio,0,1,0); l.Text=(cfg.Title or "Slider").."  •  "..tostring(math.floor(val*100)/100); if cfg.Callback then cfg.Callback(val) end end
   hit.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true; setFromX(input.Position.X) end end)
   UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then setFromX(input.Position.X) end end)
   UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
   return {Set=function(_,v) val=math.clamp(v,min,max); fill.Size=UDim2.new((val-min)/(max-min),0,1,0); l.Text=(cfg.Title or "Slider").."  •  "..tostring(math.floor(val*100)/100); if cfg.Callback then cfg.Callback(val) end end,Get=function()return val end}
  end
  function tab:AddDropdown(cfg) cfg=cfg or {}; local f=card(page,theme,42); local b=button(f,cfg.Title or "Select option",theme,28); b.Position=UDim2.fromOffset(6,7); b.Size=UDim2.new(1,-12,0,28); local choices=cfg.Options or {}; local index=1; b.MouseButton1Click:Connect(function() if #choices>0 then index=index%#choices+1; b.Text=(cfg.Title or "Option")..": " ..tostring(choices[index]); if cfg.Callback then cfg.Callback(choices[index]) end end end); if choices[1] then b.Text=(cfg.Title or "Option")..": " ..tostring(choices[1]) end; return {Get=function()return choices[index] end} end
  function tab:AddColorSwatches(colors,callback) local f=card(page,theme,44); local holder=Instance.new("Frame"); holder.BackgroundTransparency=1; holder.Size=UDim2.new(1,-16,1,-8); holder.Position=UDim2.fromOffset(8,4); holder.Parent=f; local lay=Instance.new("UIListLayout"); lay.FillDirection=Enum.FillDirection.Horizontal; lay.Padding=UDim.new(0,8); lay.Parent=holder; for _,c in ipairs(colors or {theme.Accent}) do local x=Instance.new("TextButton"); x.Text=""; x.BackgroundColor3=c; x.Size=UDim2.fromOffset(30,30); x.Parent=holder; corner(x,10); stroke(x,theme.Text,1,.4); x.MouseButton1Click:Connect(function() if callback then callback(c) end end) end end
  function tab:AddProgress(titleText,percent) local f=card(page,theme,52); local l=label(f,titleText.."  "..tostring(percent).."%",12,theme.Text,true); l.Position=UDim2.fromOffset(12,7); l.Size=UDim2.new(1,-24,0,16); local tr=Instance.new("Frame"); tr.BackgroundColor3=theme.Panel2; tr.Position=UDim2.fromOffset(12,30); tr.Size=UDim2.new(1,-24,0,8); tr.Parent=f; corner(tr,4); local fi=Instance.new("Frame"); fi.BackgroundColor3=theme.Accent; fi.Size=UDim2.new(math.clamp(percent/100,0,1),0,1,0); fi.Parent=tr; corner(fi,4); return {Set=function(_,p) p=math.clamp(p,0,100); fi.Size=UDim2.new(p/100,0,1,0); l.Text=titleText.."  "..p.."%" end} end
  function tab:AddBanner(text,subtitle) local f=card(page,theme,70); f.BackgroundColor3=theme.Panel2; local a=label(f,text,15,theme.Accent2,true); a.Position=UDim2.fromOffset(12,9); a.Size=UDim2.new(1,-24,0,22); local b=label(f,subtitle or "",12,theme.Muted); b.Position=UDim2.fromOffset(12,34); b.Size=UDim2.new(1,-24,0,28); return f end
  function tab:AddStat(titleText,valueText) local f=card(page,theme,66); local a=label(f,titleText,12,theme.Muted,false); a.Position=UDim2.fromOffset(12,8); a.Size=UDim2.new(1,-24,0,18); local b=label(f,valueText,20,theme.Text,true); b.Position=UDim2.fromOffset(12,28); b.Size=UDim2.new(1,-24,0,28); return {Set=function(_,v)b.Text=tostring(v)end} end
  function tab:AddSearch(placeholder,items,callback) local f=card(page,theme,42); local box=Instance.new("TextBox"); box.PlaceholderText=placeholder or "Search..."; box.Text=""; box.ClearTextOnFocus=false; box.Font=Enum.Font.Gotham; box.TextSize=13; box.TextColor3=theme.Text; box.PlaceholderColor3=theme.Muted; box.BackgroundColor3=theme.Panel2; box.Size=UDim2.new(1,-12,0,28); box.Position=UDim2.fromOffset(6,7); box.Parent=f; corner(box,9); box:GetPropertyChangedSignal("Text"):Connect(function() local matches={}; for _,it in ipairs(items or {}) do if string.find(string.lower(tostring(it)),string.lower(box.Text),1,true) then table.insert(matches,it) end end; if callback then callback(matches,box.Text) end end); return box end
  function tab:AddTimeline(items) local f=card(page,theme,math.max(70,#(items or {})*30+12)); local holder=Instance.new("Frame"); holder.BackgroundTransparency=1; holder.Size=UDim2.new(1,-20,1,-12); holder.Position=UDim2.fromOffset(10,6); holder.Parent=f; list(holder,4); for _,it in ipairs(items or {}) do label(holder,"●  "..tostring(it),12,theme.Text,false) end; return f end
  function tab:AddEmptyState(titleText,bodyText) local f=card(page,theme,90); local a=label(f,titleText,15,theme.Text,true); a.Position=UDim2.fromOffset(12,12); a.Size=UDim2.new(1,-24,0,24); local b=label(f,bodyText,12,theme.Muted); b.Position=UDim2.fromOffset(12,40); b.Size=UDim2.new(1,-24,0,40); return f end
  function tab:AddToastDemo(text) return window:Notify(text or "Lyra toast",nil,3) end
  function tab:AddAccordion(titleText,bodyText) local f=card(page,theme,42); local b=button(f,"＋  "..titleText,theme,28); b.Position=UDim2.fromOffset(6,7); b.Size=UDim2.new(1,-12,0,28); local expanded=false; local body=label(f,bodyText,12,theme.Muted); body.Position=UDim2.fromOffset(12,44); body.Size=UDim2.new(1,-24,0,0); body.Visible=false; b.MouseButton1Click:Connect(function() expanded=not expanded; body.Visible=expanded; f.Size=UDim2.new(1,0,0,expanded and 92 or 42); b.Text=(expanded and "−  " or "＋  ")..titleText end); return f end
  function tab:AddKeybind(titleText,key,callback) local f=card(page,theme,42); local b=button(f,titleText.."  ["..tostring(key or "?").."]",theme,28); b.Position=UDim2.fromOffset(6,7); b.Size=UDim2.new(1,-12,0,28); local current=key; local listening=false; b.MouseButton1Click:Connect(function() listening=true; b.Text=titleText.."  [Press key]" end); local conn=UserInputService.InputBegan:Connect(function(inp,gp) if listening and not gp and inp.KeyCode~=Enum.KeyCode.Unknown then current=inp.KeyCode.Name; listening=false; b.Text=titleText.."  ["..current.."]" elseif not gp and inp.KeyCode.Name==current and callback then callback() end end); return {Destroy=function()conn:Disconnect()end,Get=function()return current end} end
  function tab:AddCommandPalette(commands) local f=card(page,theme,42); local b=button(page,"⌘  Open Command Palette",theme,38); b.MouseButton1Click:Connect(function() local picked=commands and commands[1]; if picked and picked.Callback then picked.Callback() end; window:Notify("Palette demo: "..(picked and picked.Name or "No commands")) end); return b end
  table.insert(window.Tabs,tab); if #window.Tabs==1 then page.Visible=true; window.Current=tab end; return tab
 end
 function window:Destroy() if gui then gui:Destroy() end; self.Destroyed=true end
 return window
end
return Lyra
