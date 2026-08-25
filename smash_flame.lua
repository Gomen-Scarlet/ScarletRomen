-- Name: ScarletRomen (Team Check ESP Edition)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local SAVE_FILE = "ScarletRomen_Config.json"

local CFG = {
	THEME = Color3.fromRGB(255, 30, 30),
	NPC = Color3.fromRGB(255, 215, 0),
	NPC2D = Color3.fromRGB(0, 150, 255),
	ENEMY = Color3.fromRGB(255, 40, 40),
	ALLY = Color3.fromRGB(0, 255, 100),
	MY_BODY = Color3.fromRGB(170, 0, 255),
	NAME = Color3.fromRGB(0, 170, 255),
	STROKE = Color3.fromRGB(0, 40, 120)
}

local S = {
	AimNPC = false, 
	AimPlr = false, 
	Aim2D = false, 
	EspNPC = false, 
	EspNPC2D = false, 
	EspPlr = false, 
	EspName = false, 
	Fps = false, 
	Bright = false, 
	Ultra = false, 
	BlackScreen = false,
	WhiteScreen = false,
	LockedTargetNPC = nil,
	LockedTargetPlr = nil,
	GuiWidth = 210,
	GuiHeight = 160,
	LogoSize = 50,
	LogoImageId = ""
}

----------------------------------------------------------------
-- GUI BASE
----------------------------------------------------------------
local SG = Instance.new("ScreenGui")
SG.Name = "ScarletRomenUI"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.ScreenInsets = Enum.ScreenInsets.None
SG.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function makeDraggable(guiObject)
	local dragging = false
	local dragInput, dragStart, startPos

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Crosshair
local Cross = Instance.new("Frame", SG)
Cross.Name = "Crosshair"
Cross.Size = UDim2.fromOffset(12, 12)
Cross.AnchorPoint = Vector2.new(0.5, 0.5)
Cross.Position = UDim2.new(0.5, 0, 0.5, 0)
Cross.BackgroundTransparency = 1

local H = Instance.new("Frame", Cross) H.Size, H.Position, H.BackgroundColor3, H.BorderSizePixel = UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0.5, 0), Color3.fromRGB(200,200,200), 0
local V = Instance.new("Frame", Cross) V.Size, V.Position, V.BackgroundColor3, V.BorderSizePixel = UDim2.new(0, 1, 1, 0), UDim2.new(0.5, 0, 0, 0), Color3.fromRGB(200,200,200), 0

local FPSLbl = Instance.new("TextLabel", SG)
FPSLbl.Size, FPSLbl.Position, FPSLbl.BackgroundTransparency, FPSLbl.TextColor3, FPSLbl.Font, FPSLbl.Visible = UDim2.new(0, 100, 0, 20), UDim2.new(0, 10, 0, 30), 1, Color3.fromRGB(0,255,150), Enum.Font.SourceSansBold, false

-- FULLSCREEN OVERLAYS
local OverlayScreen = Instance.new("Frame", SG)
OverlayScreen.Size = UDim2.new(1, 0, 1, 0)
OverlayScreen.Position = UDim2.new(0, 0, 0, 0)
OverlayScreen.BorderSizePixel = 0
OverlayScreen.Visible = false
OverlayScreen.ZIndex = 999

-- LOGO DRAGGABLE
local Logo = Instance.new("Frame", SG) 
Logo.Size = UDim2.new(0, S.LogoSize, 0, S.LogoSize)
Logo.Position = UDim2.new(0.15, 0, 0.4, 0)
Logo.BackgroundColor3 = Color3.fromRGB(15, 15, 15) 
makeDraggable(Logo)
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 10)
local LSt = Instance.new("UIStroke", Logo) LSt.Color, LSt.Thickness = CFG.THEME, 2

local LogoImg = Instance.new("ImageLabel", Logo)
LogoImg.Size = UDim2.new(1, 0, 1, 0)
LogoImg.BackgroundTransparency = 1
LogoImg.Visible = false
Instance.new("UICorner", LogoImg).CornerRadius = UDim.new(0, 10)

local LogoBtn = Instance.new("TextButton", Logo) 
LogoBtn.Size, LogoBtn.BackgroundTransparency, LogoBtn.Text, LogoBtn.TextColor3, LogoBtn.Font, LogoBtn.TextSize = UDim2.new(1, 0, 1, 0), 1, "S", CFG.THEME, Enum.Font.SourceSansBold, 24
LogoBtn.ZIndex = 2

-- MAIN UI DRAGGABLE
local Main = Instance.new("Frame", SG) 
Main.Size, Main.Position, Main.BackgroundColor3 = UDim2.new(0, S.GuiWidth, 0, S.GuiHeight), UDim2.new(0.2, 0, 0.35, 0), Color3.fromRGB(15, 15, 15) 
Main.ClipsDescendants = true
makeDraggable(Main)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local MSt = Instance.new("UIStroke", Main) MSt.Color, MSt.Thickness = CFG.THEME, 2

LogoBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

local MainScroll = Instance.new("ScrollingFrame", Main)
MainScroll.Size, MainScroll.Position, MainScroll.BackgroundTransparency, MainScroll.ScrollBarThickness = UDim2.new(1, -6, 1, -18), UDim2.new(0, 3, 0, 4), 1, 3
MainScroll.ScrollBarImageColor3 = CFG.THEME
MainScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
MainScroll.CanvasSize = UDim2.new(0,0,0,0)

local MainLayout = Instance.new("UIListLayout", MainScroll)
MainLayout.Padding = UDim.new(0, 4)
MainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
MainLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Footer = Instance.new("TextLabel", Main)
Footer.Size, Footer.Position, Footer.BackgroundTransparency, Footer.Text, Footer.TextColor3, Footer.Font, Footer.TextSize = UDim2.new(1, 0, 0, 12), UDim2.new(0, 0, 1, -12), 1, "by: Scarlet Romen", Color3.fromRGB(150,150,150), Enum.Font.SourceSansItalic, 9

----------------------------------------------------------------
-- TAB SYSTEM
----------------------------------------------------------------
local activeContainer = nil

local function createTabHeader(title, layoutOrder)
	local tabGroup = Instance.new("Frame", MainScroll)
	tabGroup.Size = UDim2.new(1, -6, 0, 0)
	tabGroup.BackgroundTransparency = 1
	tabGroup.AutomaticSize = Enum.AutomaticSize.Y
	tabGroup.LayoutOrder = layoutOrder

	local btn = Instance.new("TextButton", tabGroup)
	btn.Size = UDim2.new(1, 0, 0, 24)
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	btn.Text = "  " .. title .. " [ + ]"
	btn.TextColor3 = Color3.fromRGB(220, 220, 220)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 11
	btn.TextXAlignment = Enum.TextXAlignment.Left

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
	local st = Instance.new("UIStroke", btn) st.Color = CFG.THEME st.Thickness = 1

	local container = Instance.new("Frame", tabGroup)
	container.Size = UDim2.new(1, 0, 0, 0)
	container.BackgroundTransparency = 1
	container.Visible = false
	container.AutomaticSize = Enum.AutomaticSize.Y

	local cLayout = Instance.new("UIListLayout", container)
	cLayout.Padding = UDim.new(0, 3)
	cLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	cLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local backBtn = Instance.new("TextButton", container)
	backBtn.Size = UDim2.new(1, 0, 0, 20)
	backBtn.BackgroundColor3 = Color3.fromRGB(45, 15, 15)
	backBtn.Text = " < Back / Close " .. title
	backBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
	backBtn.Font = Enum.Font.SourceSansBold
	backBtn.TextSize = 10
	backBtn.LayoutOrder = 0
	Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 4)

	local function toggleTab(state)
		if state then
			if activeContainer and activeContainer ~= container then
				activeContainer.Visible = false
			end
			container.Visible = true
			activeContainer = container
			btn.Text = "  " .. title .. " [ - ]"
			btn.BackgroundColor3 = CFG.THEME
		else
			container.Visible = false
			if activeContainer == container then activeContainer = nil end
			btn.Text = "  " .. title .. " [ + ]"
			btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		end
	end

	btn.MouseButton1Click:Connect(function() toggleTab(not container.Visible) end)
	backBtn.MouseButton1Click:Connect(function() toggleTab(false) end)

	return container
end

local T1Container = createTabHeader("Vision", 1)
local T2Container = createTabHeader("Liminal", 2)
local T3Container = createTabHeader("YinYang", 3)

----------------------------------------------------------------
-- LOGICS & TARGET FINDERS
----------------------------------------------------------------
local function isEnemy(player)
	if not player or player == LocalPlayer then return false end
	-- Nếu game có hệ thống Team
	if LocalPlayer.Team and player.Team then
		return LocalPlayer.Team ~= player.Team
	end
	-- Nếu là game FFA (Không chia team, ai cũng gây sát thương cho nhau)
	return true
end

local function isStrictNPC(m)
	if not m or not m:IsA("Model") then return false end
	if Players:GetPlayerFromCharacter(m) then return false end
	local hum = m:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	local head = m:FindFirstChild("Head") or m.PrimaryPart
	return head and head:IsA("BasePart")
end

local function isStrictPlayer(m)
	if not m or not m:IsA("Model") or m == LocalPlayer.Character then return false end
	if not Players:GetPlayerFromCharacter(m) then return false end
	local hum = m:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	local head = m:FindFirstChild("Head") or m.PrimaryPart
	return head and head:IsA("BasePart")
end

local function is2DNPC(o)
	if not o or Players:GetPlayerFromCharacter(o) then return false end
	local n = string.lower(o.Name)
	for _, w in ipairs({"wall", "tuong", "part", "baseplate", "building", "floor", "block", "mesh", "roof"}) do if string.find(n, w) then return false end end
	return o:IsA("Decal") or o:IsA("Texture") or o:IsA("BillboardGui")
end

local function getHeadPos(o)
	if o:IsA("Model") then
		local head = o:FindFirstChild("Head") or o.PrimaryPart
		return head and head.Position or o:GetPivot().Position
	elseif o:IsA("BasePart") then
		return o.Position
	elseif o.Parent and o.Parent:IsA("BasePart") then
		return o.Parent.Position
	end
	return nil
end

local function toggleHL(m, color, name, on, trans)
	local h = m:FindFirstChild(name)
	if on then
		if not h then
			h = Instance.new("Highlight", m)
			h.Name = name
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		end
		h.FillColor = color
		h.FillTransparency = trans or 0.5
	elseif h then
		h:Destroy()
	end
end

local function getClosestToCrosshair(chkFunc)
	local cl, sDist = nil, math.huge
	local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, v in ipairs(Workspace:GetDescendants()) do
		if chkFunc(v) then
			local p = getHeadPos(v)
			if p then
				local screenPos, onScreen = Camera:WorldToViewportPoint(p)
				if onScreen then
					local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude
					if distToCenter < sDist then
						sDist = distToCenter
						cl = v
					end
				end
			end
		end
	end
	return cl
end

local function createSkillButton(parent, text, cb, order)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1, 0, 0, 24)
	b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	b.Text = text .. ": OFF"
	b.TextColor3 = Color3.fromRGB(200, 200, 200)
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 10
	b.LayoutOrder = order or 1

	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	b.MouseButton1Click:Connect(function()
		local st = cb()
		b.Text = text .. (st and ": ON" or ": OFF")
		b.BackgroundColor3 = st and CFG.THEME or Color3.fromRGB(35, 35, 35)
	end)
	return b
end

local function createTextInput(parent, placeholder, defaultText, cb, order)
	local tbFrame = Instance.new("Frame", parent)
	tbFrame.Size = UDim2.new(1, 0, 0, 24)
	tbFrame.BackgroundTransparency = 1
	tbFrame.LayoutOrder = order or 1

	local input = Instance.new("TextBox", tbFrame)
	input.Size = UDim2.new(1, 0, 1, 0)
	input.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	input.PlaceholderText = placeholder
	input.Text = tostring(defaultText)
	input.TextColor3 = Color3.fromRGB(255, 255, 255)
	input.Font = Enum.Font.SourceSansBold
	input.TextSize = 10
	Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)

	input.FocusLost:Connect(function()
		cb(input.Text)
	end)

	return input
end

----------------------------------------------------------------
-- SKILLS REGISTER
----------------------------------------------------------------
-- TAB 1: VISION
createSkillButton(T1Container, "Skill 1 (Aim NPC Strict & Lock)", function()
	S.AimNPC = not S.AimNPC
	S.AimPlr, S.Aim2D = false, false
	if not S.AimNPC then S.LockedTargetNPC = nil end
	return S.AimNPC
end, 1)

local RainbowBtn = createSkillButton(T1Container, "Skill 2 (Aim Player & Lock)", function()
	S.AimPlr = not S.AimPlr
	S.AimNPC, S.Aim2D = false, false
	if not S.AimPlr then S.LockedTargetPlr = nil end
	return S.AimPlr
end, 2)

createSkillButton(T1Container, "Skill 3 (ESP NPC)", function()
	S.EspNPC = not S.EspNPC
	for _, v in ipairs(Workspace:GetDescendants()) do if isStrictNPC(v) then toggleHL(v, CFG.NPC, "SR_NPC", S.EspNPC) end end
	return S.EspNPC
end, 3)

-- SKILL 4 (ESP Player: Đỏ = Enemy / Xanh = Ally)
createSkillButton(T1Container, "Skill 4 (ESP Player)", function()
	S.EspPlr = not S.EspPlr
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			if p == LocalPlayer then
				toggleHL(p.Character, CFG.MY_BODY, "SR_PLR", S.EspPlr, 0.7)
			else
				local espColor = isEnemy(p) and CFG.ENEMY or CFG.ALLY
				toggleHL(p.Character, espColor, "SR_PLR", S.EspPlr, 0.5)
			end
		end
	end
	return S.EspPlr
end, 4)

createSkillButton(T1Container, "Skill 5 (Aim NPC 2D)", function()
	S.Aim2D = not S.Aim2D S.AimNPC, S.AimPlr = false, false
	return S.Aim2D
end, 5)

createSkillButton(T1Container, "Skill 6 (ESP NPC 2D)", function()
	S.EspNPC2D = not S.EspNPC2D
	for _, v in ipairs(Workspace:GetDescendants()) do
		if is2DNPC(v) then
			local targetObj = (v:IsA("Model") or v:IsA("BasePart")) and v or v.Parent
			if targetObj then toggleHL(targetObj, CFG.NPC2D, "SR_NPC2D", S.EspNPC2D) end
		end
	end
	return S.EspNPC2D
end, 6)

-- TAB 2: LIMINAL
createSkillButton(T2Container, "Skill 1 (ESP Name Player)", function() S.EspName = not S.EspName return S.EspName end, 1)
createSkillButton(T2Container, "Skill 2 (FPS Booster)", function() S.Fps = not S.Fps settings().Rendering.QualityLevel, Lighting.GlobalShadows = S.Fps and 1 or 7, not S.Fps return S.Fps end, 2)
createSkillButton(T2Container, "Skill 3 (Full Bright)", function() S.Bright = not S.Bright Lighting.FogEnd, Lighting.Brightness = S.Bright and 9e9 or 1000, S.Bright and 2 or 1 return S.Bright end, 3)
createSkillButton(T2Container, "Skill 4 (Ultra Liminal)", function()
	S.Ultra = not S.Ultra FPSLbl.Visible = S.Ultra
	if S.Ultra then
		Camera.MaxAxisFieldOfView = 40
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("BasePart") then v.Material, v.Color = Enum.Material.SmoothPlastic, Color3.fromRGB(120, 120, 120)
			elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Animator") then v:Destroy() end
		end
	end
	return S.Ultra
end, 4)

-- TAB 3: YINYANG
local guiWidthInput = createTextInput(T3Container, "Skill 1: Enter GUI Width", S.GuiWidth, function(val)
	local num = tonumber(val)
	if num and num >= 100 and num <= 800 then
		S.GuiWidth = num
		Main.Size = UDim2.new(0, S.GuiWidth, 0, S.GuiHeight)
	end
end, 1)

local logoSizeInput = createTextInput(T3Container, "Skill 2: Enter Logo Size", S.LogoSize, function(val)
	local num = tonumber(val)
	if num and num >= 20 and num <= 200 then
		S.LogoSize = num
		Logo.Size = UDim2.new(0, S.LogoSize, 0, S.LogoSize)
	end
end, 2)

createSkillButton(T3Container, "Skill 3 (Black Screen)", function()
	S.BlackScreen = not S.BlackScreen
	S.WhiteScreen = false
	OverlayScreen.Visible = S.BlackScreen
	OverlayScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	return S.BlackScreen
end, 3)

createSkillButton(T3Container, "Skill 4 (White Screen)", function()
	S.WhiteScreen = not S.WhiteScreen
	S.BlackScreen = false
	OverlayScreen.Visible = S.WhiteScreen
	OverlayScreen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	return S.WhiteScreen
end, 4)

local function updateLogoImage(id)
	if id and id ~= "" then
		LogoImg.Image = "rbxassetid://" .. tostring(id)
		LogoImg.Visible = true
		LogoBtn.Text = ""
	else
		LogoImg.Visible = false
		LogoBtn.Text = "S"
	end
end

local logoInput = createTextInput(T3Container, "Skill 5: Enter Decal ID...", S.LogoImageId, function(val)
	S.LogoImageId = val
	updateLogoImage(S.LogoImageId)
end, 5)

-- Skill 6: Save Config
local saveBtn = Instance.new("TextButton", T3Container)
saveBtn.Size = UDim2.new(1, 0, 0, 24)
saveBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
saveBtn.Text = "Skill 6: Save Config"
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Font = Enum.Font.SourceSansBold
saveBtn.TextSize = 10
saveBtn.LayoutOrder = 6
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 4)

saveBtn.MouseButton1Click:Connect(function()
	if writefile then
		local data = HttpService:JSONEncode({
			GuiWidth = S.GuiWidth,
			GuiHeight = S.GuiHeight,
			LogoSize = S.LogoSize,
			LogoImageId = S.LogoImageId
		})
		writefile(SAVE_FILE, data)
	end
end)

-- Skill 7: Reset
local resetBtn = Instance.new("TextButton", T3Container)
resetBtn.Size = UDim2.new(1, 0, 0, 24)
resetBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
resetBtn.Text = "Skill 7: Reset All"
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.Font = Enum.Font.SourceSansBold
resetBtn.TextSize = 10
resetBtn.LayoutOrder = 7
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 4)

local confirmFrame = Instance.new("Frame", T3Container)
confirmFrame.Size = UDim2.new(1, 0, 0, 24)
confirmFrame.BackgroundTransparency = 1
confirmFrame.Visible = false
confirmFrame.LayoutOrder = 8

local yesBtn = Instance.new("TextButton", confirmFrame)
yesBtn.Size = UDim2.new(0.48, 0, 1, 0)
yesBtn.Position = UDim2.new(0, 0, 0, 0)
yesBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
yesBtn.Text = "YES (Confirm)"
yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
yesBtn.Font = Enum.Font.SourceSansBold
yesBtn.TextSize = 9
Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 4)

local noBtn = Instance.new("TextButton", confirmFrame)
noBtn.Size = UDim2.new(0.48, 0, 1, 0)
noBtn.Position = UDim2.new(0.52, 0, 0, 0)
noBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
noBtn.Text = "NO (Cancel)"
noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noBtn.Font = Enum.Font.SourceSansBold
noBtn.TextSize = 9
Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 4)

resetBtn.MouseButton1Click:Connect(function()
	resetBtn.Visible = false
	confirmFrame.Visible = true
end)

noBtn.MouseButton1Click:Connect(function()
	confirmFrame.Visible = false
	resetBtn.Visible = true
end)

yesBtn.MouseButton1Click:Connect(function()
	if isfile and isfile(SAVE_FILE) and delfile then
		delfile(SAVE_FILE)
	end
	S.GuiWidth, S.GuiHeight, S.LogoSize, S.LogoImageId = 210, 160, 50, ""
	Main.Size = UDim2.new(0, S.GuiWidth, 0, S.GuiHeight)
	Logo.Size = UDim2.new(0, S.LogoSize, 0, S.LogoSize)
	guiWidthInput.Text = tostring(S.GuiWidth)
	logoSizeInput.Text = tostring(S.LogoSize)
	logoInput.Text = ""
	updateLogoImage("")
	confirmFrame.Visible = false
	resetBtn.Visible = true
end)

-- AUTO LOAD CONFIG
if readfile and isfile and isfile(SAVE_FILE) then
	pcall(function()
		local data = HttpService:JSONDecode(readfile(SAVE_FILE))
		if data then
			S.GuiWidth = data.GuiWidth or S.GuiWidth
			S.GuiHeight = data.GuiHeight or S.GuiHeight
			S.LogoSize = data.LogoSize or S.LogoSize
			S.LogoImageId = data.LogoImageId or S.LogoImageId

			Main.Size = UDim2.new(0, S.GuiWidth, 0, S.GuiHeight)
			Logo.Size = UDim2.new(0, S.LogoSize, 0, S.LogoSize)
			guiWidthInput.Text = tostring(S.GuiWidth)
			logoSizeInput.Text = tostring(S.LogoSize)
			logoInput.Text = S.LogoImageId
			updateLogoImage(S.LogoImageId)
		end
	end)
end

----------------------------------------------------------------
-- RENDER LOOP
----------------------------------------------------------------
local frames, lastT = 0, tick()
local hue = 0
local flashTimer = 0

RunService.RenderStepped:Connect(function(dt)
	frames = frames + 1
	if tick() - lastT >= 1 then FPSLbl.Text = "FPS: " .. frames frames, lastT = 0, tick() end

	hue = (hue + dt * 0.5) % 1
	
	saveBtn.BackgroundColor3 = Color3.fromHSV(hue, 0.7, 0.8)

	flashTimer = (flashTimer + dt * 4) % (math.pi * 2)
	local lerpFactor = (math.sin(flashTimer) + 1) / 2
	resetBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(255, 255, 255), lerpFactor)
	resetBtn.TextColor3 = Color3.fromRGB(0, 0, 0):Lerp(Color3.fromRGB(255, 0, 0), lerpFactor)

	if S.AimPlr then
		RainbowBtn.BackgroundColor3 = Color3.fromHSV(hue, 0.8, 1)
		RainbowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		RainbowBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	end

	-- Cập nhật động ESP Player liên tục (khi đổi team)
	if S.EspPlr then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then
				if p == LocalPlayer then
					toggleHL(p.Character, CFG.MY_BODY, "SR_PLR", true, 0.7)
				else
					local espColor = isEnemy(p) and CFG.ENEMY or CFG.ALLY
					toggleHL(p.Character, espColor, "SR_PLR", true, 0.5)
				end
			end
		end
	end

	-- AIM LOCK LOGIC
	local currentTarget = nil

	if S.AimNPC then
		if not isStrictNPC(S.LockedTargetNPC) then
			S.LockedTargetNPC = getClosestToCrosshair(isStrictNPC)
		end
		currentTarget = S.LockedTargetNPC
	elseif S.AimPlr then
		if not isStrictPlayer(S.LockedTargetPlr) then
			S.LockedTargetPlr = getClosestToCrosshair(isStrictPlayer)
		end
		currentTarget = S.LockedTargetPlr
	elseif S.Aim2D then
		currentTarget = getClosestToCrosshair(is2DNPC)
	else
		S.LockedTargetNPC = nil
		S.LockedTargetPlr = nil
	end

	if currentTarget then
		local p = getHeadPos(currentTarget)
		if p then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, p) end
	end

	-- ESP Name Player
	if S.EspName then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
				local head = p.Character.Head
				local hum = p.Character:FindFirstChildOfClass("Humanoid")
				local tag = head:FindFirstChild("SR_NameTag")

				if hum and hum.Health > 0 then
					if not tag then
						tag = Instance.new("BillboardGui", head)
						tag.Name = "SR_NameTag"
						tag.Size = UDim2.new(0, 150, 0, 40)
						tag.StudsOffset = Vector3.new(0, 2.5, 0)
						tag.AlwaysOnTop = true

						local lbl = Instance.new("TextLabel", tag)
						lbl.Name = "NameLabel"
						lbl.Size = UDim2.new(1, 0, 1, 0)
						lbl.BackgroundTransparency = 1
						lbl.TextColor3 = CFG.NAME
						lbl.TextStrokeColor3 = CFG.STROKE
						lbl.TextStrokeTransparency = 0
						lbl.Font = Enum.Font.SourceSansBold
						lbl.TextSize = 16
					end
					tag.NameLabel.Text = p.Name .. "\n[" .. math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth) .. " HP]"
				elseif tag then tag:Destroy() end
			end
		end
	else
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character and p.Character:FindFirstChild("Head") then
				local tag = p.Character.Head:FindFirstChild("SR_NameTag")
				if tag then tag:Destroy() end
			end
		end
	end
end)
