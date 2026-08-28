-- Name: ScarletRomen (Clean UI Edition v3 - Aim Player, ESP Player & Hitbox Update)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local SAVE_FILE = "ScarletRomen_Config.json"

local CFG = {
	THEME = Color3.fromRGB(255, 30, 30),
	NAME = Color3.fromRGB(0, 170, 255),
	STROKE = Color3.fromRGB(0, 40, 120),

	BASIC_LINE = Color3.fromRGB(0, 0, 0),
	TAB_BG = Color3.fromRGB(25, 25, 25),
	MAIN_BG = Color3.fromRGB(15, 15, 15),

	COLOR_SPEED = 0.7
}

local S = {
	AimNPC = false,
	AimPlr = false,
	Aim2D = false,

	EspNPC = false,
	EspNPC2D = false,
	EspPlr = false,
	EspName = false,
	Hitbox = false,

	Fps = false,
	Bright = false,
	Ultra = false,

	BlackScreen = false,
	WhiteScreen = false,

	-- Line Mode: "off" | "mode1" | "mode2" | "mode3"
	LineMode = "off",

	GuiWidth = 210,
	GuiHeight = 160,
	GuiScale = 1,

	LogoSize = 50,
	LogoImageId = "",

	GuiBackgroundImageId = "",
	GuiLocked = false,
	Crosshair = false,
	GuiTransparency = 0.15,

	ScreenDimEnabled = false,
	ScreenDimOpacity = 0.5,

	MusicId = "",
	MusicPlaying = false,
	MusicVolume = 0.5,
	MusicSpeed = 1,

	EspInteract = false
}

----------------------------------------------------------------
-- AIM NPC & ESP NPC (Skill 1 & Skill 3)
----------------------------------------------------------------

local NPC_MAX_DISTANCE = 800
local NPC_REFRESH_INTERVAL = 0.5
local NPC_ESP_COLOR = Color3.fromRGB(255, 230, 0)

local cachedNPCs = {}
local lastNPCRefresh = 0
local lockedNPC = nil
local espHighlights = {}

local function isValidNPC(model)
	if not model or not model:IsA("Model") then return false end
	if Players:GetPlayerFromCharacter(model) then return false end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local head = model:FindFirstChild("Head") or model.PrimaryPart
	if humanoid and head and humanoid.Health > 0 then
		return true
	end
	return false
end

local function refreshNPCCache()
	table.clear(cachedNPCs)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if isValidNPC(obj) then
			table.insert(cachedNPCs, obj)
		end
	end
end

local function getClosestNPC()
	local closest = nil
	local shortestDist = math.huge
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, model in ipairs(cachedNPCs) do
		if isValidNPC(model) then
			local head = model:FindFirstChild("Head") or model.PrimaryPart
			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if onScreen then
				local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
				local dist3D = (head.Position - Camera.CFrame.Position).Magnitude
				if dist3D <= NPC_MAX_DISTANCE and dist2D < shortestDist then
					shortestDist = dist2D
					closest = model
				end
			end
		end
	end
	return closest
end

local function applyNPCESP(model)
	if espHighlights[model] and espHighlights[model].Parent then return end
	local highlight = Instance.new("Highlight")
	highlight.Name = "ScarletESP_NPC"
	highlight.Adornee = model
	highlight.FillColor = NPC_ESP_COLOR
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = NPC_ESP_COLOR
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = model
	espHighlights[model] = highlight
end

local function clearAllNPCESP()
	for _, highlight in pairs(espHighlights) do
		if highlight then highlight:Destroy() end
	end
	table.clear(espHighlights)
end

----------------------------------------------------------------
-- PLAYER UTILS (Team Check, Aim Player, ESP Player, Hitbox)
----------------------------------------------------------------

local playerESPHighlights = {}
local lockedPlayer = nil

local function isTeammate(player)
	if player == LocalPlayer then return true end
	if LocalPlayer.Team and player.Team then
		return LocalPlayer.Team == player.Team
	end
	return false
end

local function getPlayerColor(player)
	if isTeammate(player) then
		return Color3.fromRGB(0, 255, 0) -- Xanh lá cho đồng đội
	else
		return Color3.fromRGB(255, 0, 0) -- Đỏ cho kẻ địch
	end
end

local function isValidPlayer(player)
	if not player or player == LocalPlayer then return false end
	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		local head = char:FindFirstChild("Head")
		if hum and head and hum.Health > 0 then
			return true
		end
	end
	return false
end

local function getClosestPlayerToCenter()
	local closest = nil
	local shortestDist = math.huge
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, plr in ipairs(Players:GetPlayers()) do
		if isValidPlayer(plr) then
			local head = plr.Character:FindFirstChild("Head")
			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if onScreen then
				local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
				if dist2D < shortestDist then
					shortestDist = dist2D
					closest = plr
				end
			end
		end
	end
	return closest
end

local function applyPlayerESP(player)
	local char = player.Character
	if not char then return end

	local color = getPlayerColor(player)
	local highlight = char:FindFirstChild("ScarletESP_Player")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "ScarletESP_Player"
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = char
	end
	highlight.Adornee = char
	highlight.FillColor = color
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = color
	highlight.OutlineTransparency = 0
	playerESPHighlights[player] = highlight
end

local function clearAllPlayerESP()
	for plr, hl in pairs(playerESPHighlights) do
		if hl and hl.Parent then
			hl:Destroy()
		end
	end
	table.clear(playerESPHighlights)
end

----------------------------------------------------------------
-- ESP INTERACT (Skill 8)
----------------------------------------------------------------

local PROMPT_REFRESH_INTERVAL = 0.5
local PROMPT_ESP_COLOR = Color3.fromRGB(255, 140, 0)

local cachedPrompts = {}
local lastPromptRefresh = 0
local promptESP = {}

local function isValidPrompt(prompt)
	return prompt ~= nil and prompt.Parent ~= nil and prompt:IsA("ProximityPrompt") and prompt.Enabled
end

local function refreshPromptCache()
	table.clear(cachedPrompts)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			table.insert(cachedPrompts, obj)
		end
	end
end

local function applyPromptESP(prompt)
	if promptESP[prompt] and promptESP[prompt].highlight.Parent then return end

	local target = prompt.Parent
	if not target then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ScarletESP_Interact"
	highlight.Adornee = target
	highlight.FillColor = PROMPT_ESP_COLOR
	highlight.FillTransparency = 0.55
	highlight.OutlineColor = PROMPT_ESP_COLOR
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = target

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ScarletESP_InteractLabel"
	billboard.Size = UDim2.new(0, 150, 0, 26)
	billboard.StudsOffset = Vector3.new(0, 2.2, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = target
	billboard.Parent = target

	local label = Instance.new("TextLabel", billboard)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = PROMPT_ESP_COLOR
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 14
	label.TextStrokeTransparency = 0.4
	label.Text = (prompt.ActionText ~= "" and prompt.ActionText) or "Interact"

	promptESP[prompt] = { highlight = highlight, billboard = billboard }
end

local function clearAllPromptESP()
	for _, data in pairs(promptESP) do
		if data.highlight then data.highlight:Destroy() end
		if data.billboard then data.billboard:Destroy() end
	end
	table.clear(promptESP)
end

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
	local dragInput
	local dragStart
	local startPos

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			if guiObject:GetAttribute("SR_Locked") then
				return
			end

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
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			dragInput = input
		end
	end)

	local uisConn = UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart

			guiObject.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	guiObject.AncestryChanged:Connect(function(_, parent)
		if not parent then
			uisConn:Disconnect()
		end
	end)
end

----------------------------------------------------------------
-- FPS
----------------------------------------------------------------

local FPSLbl = Instance.new("TextLabel", SG)
FPSLbl.Size = UDim2.new(0, 100, 0, 20)
FPSLbl.Position = UDim2.new(0, 10, 0, 30)
FPSLbl.BackgroundTransparency = 1
FPSLbl.TextColor3 = Color3.fromRGB(0, 255, 150)
FPSLbl.Font = Enum.Font.SourceSansBold
FPSLbl.TextSize = 12
FPSLbl.Visible = false
FPSLbl.Text = "FPS: 0"

----------------------------------------------------------------
-- FULLSCREEN OVERLAYS
----------------------------------------------------------------

local OverlayScreen = Instance.new("Frame", SG)
OverlayScreen.Name = "OverlayScreen"
OverlayScreen.Size = UDim2.new(1, 0, 1, 0)
OverlayScreen.Position = UDim2.new(0, 0, 0, 0)
OverlayScreen.BorderSizePixel = 0
OverlayScreen.Visible = false
OverlayScreen.ZIndex = 999

local DimOverlay = Instance.new("Frame", SG)
DimOverlay.Name = "DimOverlay"
DimOverlay.Size = UDim2.new(1, 0, 1, 0)
DimOverlay.Position = UDim2.new(0, 0, 0, 0)
DimOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DimOverlay.BorderSizePixel = 0
DimOverlay.BackgroundTransparency = 1 - S.ScreenDimOpacity
DimOverlay.Visible = false
DimOverlay.ZIndex = 998

----------------------------------------------------------------
-- CROSSHAIR
----------------------------------------------------------------

local Crosshair = Instance.new("TextLabel", SG)
Crosshair.Name = "Crosshair"
Crosshair.Size = UDim2.new(0, 30, 0, 30)
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
Crosshair.BackgroundTransparency = 1
Crosshair.Text = "+"
Crosshair.TextColor3 = Color3.fromRGB(160, 160, 160)
Crosshair.Font = Enum.Font.SourceSansBold
Crosshair.TextSize = 24
Crosshair.Visible = false
Crosshair.ZIndex = 1000

----------------------------------------------------------------
-- LOGO
----------------------------------------------------------------

local Logo = Instance.new("Frame", SG)
Logo.Name = "Logo"
Logo.Size = UDim2.new(0, S.LogoSize, 0, S.LogoSize)
Logo.Position = UDim2.new(0, 10, 0, 10)
Logo.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Logo.ZIndex = 20

makeDraggable(Logo)

Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 10)

local LSt = Instance.new("UIStroke", Logo)
LSt.Color = CFG.BASIC_LINE
LSt.Thickness = 2

local LogoImg = Instance.new("ImageLabel", Logo)
LogoImg.Size = UDim2.new(1, 0, 1, 0)
LogoImg.BackgroundTransparency = 1
LogoImg.Visible = false
LogoImg.ZIndex = 21

Instance.new("UICorner", LogoImg).CornerRadius = UDim.new(0, 10)

local LogoBtn = Instance.new("TextButton", Logo)
LogoBtn.Size = UDim2.new(1, 0, 1, 0)
LogoBtn.BackgroundTransparency = 1
LogoBtn.Text = "S"
LogoBtn.TextColor3 = CFG.THEME
LogoBtn.Font = Enum.Font.SourceSansBold
LogoBtn.TextSize = 24
LogoBtn.ZIndex = 22

----------------------------------------------------------------
-- MAIN GUI
----------------------------------------------------------------

local Main = Instance.new("Frame", SG)
Main.Name = "Main"
Main.Size = UDim2.new(0, S.GuiWidth, 0, S.GuiHeight)
Main.Position = UDim2.new(0, 10, 0.35, 0)
Main.BackgroundColor3 = CFG.MAIN_BG
Main.BackgroundTransparency = 0
Main.ClipsDescendants = true
Main.ZIndex = 10

makeDraggable(Main)

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local MSt = Instance.new("UIStroke", Main)
MSt.Color = CFG.BASIC_LINE
MSt.Thickness = 2

local MainScale = Instance.new("UIScale")
MainScale.Scale = S.GuiScale
MainScale.Parent = Main

local GuiBackground = Instance.new("ImageLabel", Main)
GuiBackground.Name = "GuiBackground"
GuiBackground.Size = UDim2.new(1, 0, 1, 0)
GuiBackground.Position = UDim2.new(0, 0, 0, 0)
GuiBackground.BackgroundTransparency = 1
GuiBackground.ImageTransparency = 0.35
GuiBackground.ScaleType = Enum.ScaleType.Crop
GuiBackground.Visible = false
GuiBackground.ZIndex = 10

local GuiBackgroundCorner = Instance.new("UICorner", GuiBackground)
GuiBackgroundCorner.CornerRadius = UDim.new(0, 8)

LogoBtn.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)

local MainScroll = Instance.new("ScrollingFrame", Main)
MainScroll.Name = "MainScroll"
MainScroll.Size = UDim2.new(1, -6, 1, -18)
MainScroll.Position = UDim2.new(0, 3, 0, 4)
MainScroll.BackgroundTransparency = 1
MainScroll.ScrollBarThickness = 3
MainScroll.ScrollBarImageColor3 = CFG.BASIC_LINE
MainScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
MainScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
MainScroll.ZIndex = 20

local MainLayout = Instance.new("UIListLayout", MainScroll)
MainLayout.Padding = UDim.new(0, 4)
MainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
MainLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Footer = Instance.new("TextLabel", Main)
Footer.Size = UDim2.new(1, 0, 0, 12)
Footer.Position = UDim2.new(0, 0, 1, -12)
Footer.BackgroundTransparency = 1
Footer.Text = "by: Scarlet Romen"
Footer.TextColor3 = Color3.fromRGB(150, 150, 150)
Footer.Font = Enum.Font.SourceSansItalic
Footer.TextSize = 9
Footer.ZIndex = 30

----------------------------------------------------------------
-- TAB SYSTEM
----------------------------------------------------------------

local activeContainer = nil
local tabButtons = {}

local function createTabHeader(title, layoutOrder)
	local tabGroup = Instance.new("Frame", MainScroll)
	tabGroup.Name = title .. "Tab"
	tabGroup.Size = UDim2.new(1, -6, 0, 0)
	tabGroup.BackgroundTransparency = 1
	tabGroup.AutomaticSize = Enum.AutomaticSize.Y
	tabGroup.LayoutOrder = layoutOrder
	tabGroup.ZIndex = 20

	local btn = Instance.new("TextButton", tabGroup)
	btn.Size = UDim2.new(1, 0, 0, 24)
	btn.BackgroundColor3 = CFG.TAB_BG
	btn.Text = "  " .. title
	btn.TextColor3 = Color3.fromRGB(220, 220, 220)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 11
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.ZIndex = 21

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

	local st = Instance.new("UIStroke", btn)
	st.Color = CFG.BASIC_LINE
	st.Thickness = 1

	table.insert(tabButtons, {
		Button = btn,
		Stroke = st
	})

	local container = Instance.new("Frame", tabGroup)
	container.Name = title .. "Container"
	container.Size = UDim2.new(1, 0, 0, 0)
	container.BackgroundTransparency = 1
	container.Visible = false
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.ZIndex = 22

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
	backBtn.ZIndex = 23

	Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 4)

	local function toggleTab(state)
		if state then
			if activeContainer and activeContainer ~= container then
				activeContainer.Visible = false
			end

			container.Visible = true
			activeContainer = container
			btn.Text = "  " .. title
		else
			container.Visible = false
			if activeContainer == container then
				activeContainer = nil
			end
			btn.Text = "  " .. title
		end
	end

	btn.MouseButton1Click:Connect(function()
		toggleTab(not container.Visible)
	end)

	backBtn.MouseButton1Click:Connect(function()
		toggleTab(false)
	end)

	return container, tabGroup
end

local T1Container = createTabHeader("Vision", 1)
local T2Container = createTabHeader("Liminal", 2)
local T3Container = createTabHeader("YinYang", 3)

----------------------------------------------------------------
-- BUTTON HELPERS
----------------------------------------------------------------

local function setToggleButtonVisual(btn, baseText, state)
	btn.Text = baseText .. (state and ": ON" or ": OFF")
	btn.TextColor3 = state
		and Color3.fromRGB(220, 220, 220)
		or Color3.fromRGB(160, 160, 160)
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
	b.ZIndex = 24

	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

	b.MouseButton1Click:Connect(function()
		local st = cb()
		b.Text = text .. (st and ": ON" or ": OFF")
		if st then
			b.TextColor3 = Color3.fromRGB(220, 220, 220)
		else
			b.TextColor3 = Color3.fromRGB(160, 160, 160)
		end
	end)

	return b
end

local function createTextInput(parent, placeholder, defaultText, cb, order)
	local tbFrame = Instance.new("Frame", parent)

	tbFrame.Size = UDim2.new(1, 0, 0, 24)
	tbFrame.BackgroundTransparency = 1
	tbFrame.LayoutOrder = order or 1
	tbFrame.ZIndex = 24

	local input = Instance.new("TextBox", tbFrame)

	input.Size = UDim2.new(1, 0, 1, 0)
	input.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	input.PlaceholderText = placeholder
	input.Text = tostring(defaultText or "")
	input.TextColor3 = Color3.fromRGB(255, 255, 255)
	input.Font = Enum.Font.SourceSansBold
	input.TextSize = 10
	input.ClearTextOnFocus = false
	input.ZIndex = 25

	Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)

	input.FocusLost:Connect(function()
		cb(input.Text)
	end)

	return input
end

----------------------------------------------------------------
-- TAB 4 & 5 & 6
----------------------------------------------------------------

local T4Container = createTabHeader("Interface", 4)
local T5Container = createTabHeader("Interface Settings", 5)
local T6Container = createTabHeader("Music", 6)

----------------------------------------------------------------
-- TAB 1: VISION
----------------------------------------------------------------

local Skill1Btn, Skill2Btn, Aim2DBtn

local function tab1Exclusive(activeKey)
	if activeKey ~= "AimNPC" and S.AimNPC then
		S.AimNPC = false
		setToggleButtonVisual(Skill1Btn, "Skill 1 (Aim NPC Strict & Lock)", false)
		Skill1Btn.TextColor3 = Color3.fromRGB(160, 160, 160)
		lockedNPC = nil
	end

	if activeKey ~= "AimPlr" and S.AimPlr then
		S.AimPlr = false
		setToggleButtonVisual(Skill2Btn, "Skill 2 (Aim Player & Lock)", false)
		Skill2Btn.TextColor3 = Color3.fromRGB(255, 40, 40)
		lockedPlayer = nil
	end

	if activeKey ~= "Aim2D" and S.Aim2D then
		S.Aim2D = false
		setToggleButtonVisual(Aim2DBtn, "Skill 5 (Aim NPC 2D)", false)
	end
end

Skill1Btn = createSkillButton(
	T1Container,
	"Skill 1 (Aim NPC Strict & Lock)",
	function()
		S.AimNPC = not S.AimNPC
		if S.AimNPC then
			tab1Exclusive("AimNPC")
			lockedNPC = getClosestNPC()
		else
			lockedNPC = nil
		end
		return S.AimNPC
	end,
	2
)
Skill1Btn.TextColor3 = Color3.fromRGB(160, 160, 160)

Skill2Btn = createSkillButton(
	T1Container,
	"Skill 2 (Aim Player & Lock)",
	function()
		S.AimPlr = not S.AimPlr
		if S.AimPlr then
			tab1Exclusive("AimPlr")
			lockedPlayer = getClosestPlayerToCenter()
		else
			lockedPlayer = nil
		end
		return S.AimPlr
	end,
	3
)
Skill2Btn.TextColor3 = Color3.fromRGB(255, 40, 40)

local EspNPCBtn = createSkillButton(
	T1Container,
	"Skill 3 (ESP NPC)",
	function()
		S.EspNPC = not S.EspNPC
		if not S.EspNPC then
			clearAllNPCESP()
		end
		return S.EspNPC
	end,
	4
)

local Skill4Btn = createSkillButton(
	T1Container,
	"Skill 4 (ESP Player)",
	function()
		S.EspPlr = not S.EspPlr
		if not S.EspPlr then
			clearAllPlayerESP()
		end
		return S.EspPlr
	end,
	5
)
Skill4Btn.TextColor3 = Color3.fromRGB(255, 40, 40)

Aim2DBtn = createSkillButton(
	T1Container,
	"Skill 5 (Aim NPC 2D)",
	function()
		S.Aim2D = not S.Aim2D
		if S.Aim2D then tab1Exclusive("Aim2D") end
		return S.Aim2D
	end,
	6
)

local EspNPC2DBtn = createSkillButton(
	T1Container,
	"Skill 6 (ESP NPC 2D)",
	function()
		S.EspNPC2D = not S.EspNPC2D
		return S.EspNPC2D
	end,
	7
)

local EspInteractBtn = createSkillButton(
	T1Container,
	"Skill 8 (ESP Interact)",
	function()
		S.EspInteract = not S.EspInteract
		if not S.EspInteract then
			clearAllPromptESP()
		end
		return S.EspInteract
	end,
	8
)
EspInteractBtn.TextColor3 = PROMPT_ESP_COLOR

-- Skill 9: Hitbox Player
local Skill9Btn = createSkillButton(
	T1Container,
	"Skill 9 (Hitbox Player)",
	function()
		S.Hitbox = not S.Hitbox
		if not S.Hitbox then
			-- Restore normal hitboxes when OFF
			for _, plr in ipairs(Players:GetPlayers()) do
				local char = plr.Character
				if char then
					local root = char:FindFirstChild("HumanoidRootPart")
					if root then
						root.Size = Vector3.new(2, 2, 1)
						root.Transparency = 1
					end
				end
			end
		end
		return S.Hitbox
	end,
	10
)
Skill9Btn.TextColor3 = Color3.fromRGB(170, 0, 255)

----------------------------------------------------------------
-- TAB 1 - SKILL 7: LINE MODE
----------------------------------------------------------------

local LineModeBtn = Instance.new("TextButton", T1Container)
LineModeBtn.Size = UDim2.new(1, 0, 0, 24)
LineModeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
LineModeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
LineModeBtn.Font = Enum.Font.SourceSansBold
LineModeBtn.TextSize = 10
LineModeBtn.LayoutOrder = 9
LineModeBtn.ZIndex = 24
Instance.new("UICorner", LineModeBtn).CornerRadius = UDim.new(0, 4)

local function lineModeLabel()
	if S.LineMode == "off" then
		return "Skill 7 (Line Mode): OFF"
	elseif S.LineMode == "mode1" then
		return "Skill 7 (Line Mode): Che do 1"
	elseif S.LineMode == "mode2" then
		return "Skill 7 (Line Mode): Che do 2"
	else
		return "Skill 7 (Line Mode): Che do 3"
	end
end

LineModeBtn.Text = lineModeLabel()

LineModeBtn.MouseButton1Click:Connect(function()
	if S.LineMode == "off" then
		S.LineMode = "mode1"
	elseif S.LineMode == "mode1" then
		S.LineMode = "mode2"
	elseif S.LineMode == "mode2" then
		S.LineMode = "mode3"
	else
		S.LineMode = "off"
	end

	LineModeBtn.Text = lineModeLabel()

	if S.LineMode == "mode2" then
		Main.BackgroundColor3 = CFG.TAB_BG
	else
		Main.BackgroundColor3 = CFG.MAIN_BG
	end
end)

----------------------------------------------------------------
-- TAB 2: LIMINAL
----------------------------------------------------------------

local NamePlayerBtn = createSkillButton(
	T2Container,
	"Skill 1 (ESP Name Player)",
	function()
		S.EspName = not S.EspName
		return S.EspName
	end,
	1
)
NamePlayerBtn.TextColor3 = Color3.fromRGB(255, 40, 40)

local function applyFps(state)
	if state then
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		Lighting.GlobalShadows = false

		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("Texture") or v:IsA("Decal") then
				pcall(function()
					v:Destroy()
				end)
			end
		end
	else
		settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
		Lighting.GlobalShadows = true
	end
end

local FpsBtn = createSkillButton(
	T2Container,
	"Skill 2 (FPS Booster)",
	function()
		S.Fps = not S.Fps
		applyFps(S.Fps)
		return S.Fps
	end,
	2
)

local function applyBright(state)
	if state then
		Lighting.FogEnd = 9e9
		Lighting.Brightness = 2
	else
		Lighting.FogEnd = 1000
		Lighting.Brightness = 1
	end
end

local BrightBtn = createSkillButton(
	T2Container,
	"Skill 3 (Full Bright)",
	function()
		S.Bright = not S.Bright
		applyBright(S.Bright)
		return S.Bright
	end,
	3
)

local function applyUltra(state)
	FPSLbl.Visible = state

	if state then
		Camera.MaxAxisFieldOfView = 40

		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Material = Enum.Material.SmoothPlastic
				v.Color = Color3.fromRGB(120, 120, 120)

			elseif v:IsA("Decal")
				or v:IsA("Texture")
				or v:IsA("Accessory")
				or v:IsA("Shirt")
				or v:IsA("Pants") then

				pcall(function()
					v:Destroy()
				end)
			end
		end
	else
		Camera.MaxAxisFieldOfView = 120
	end
end

local UltraBtn = createSkillButton(
	T2Container,
	"Skill 4 (Ultra Liminal)",
	function()
		S.Ultra = not S.Ultra
		applyUltra(S.Ultra)
		return S.Ultra
	end,
	4
)

----------------------------------------------------------------
-- TAB 3: YINYANG
----------------------------------------------------------------

local guiScaleInput

guiScaleInput = createTextInput(
	T3Container,
	"Skill 1: GUI Scale (0.5 - 3)",
	S.GuiScale,
	function(val)
		local num = tonumber(val)

		if num and num >= 0.5 and num <= 3 then
			S.GuiScale = num
			MainScale.Scale = S.GuiScale
		else
			guiScaleInput.Text = tostring(S.GuiScale)
		end
	end,
	1
)

local logoSizeInput

logoSizeInput = createTextInput(
	T3Container,
	"Skill 2: Enter Logo Size",
	S.LogoSize,
	function(val)
		local num = tonumber(val)

		if num and num >= 20 and num <= 200 then
			S.LogoSize = num

			Logo.Size = UDim2.new(0, S.LogoSize, 0, S.LogoSize)
		else
			logoSizeInput.Text = tostring(S.LogoSize)
		end
	end,
	2
)

createSkillButton(
	T3Container,
	"Skill 3 (Black Screen)",
	function()
		S.BlackScreen = not S.BlackScreen
		S.WhiteScreen = false

		OverlayScreen.Visible = S.BlackScreen
		OverlayScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

		return S.BlackScreen
	end,
	3
)

createSkillButton(
	T3Container,
	"Skill 4 (White Screen)",
	function()
		S.WhiteScreen = not S.WhiteScreen
		S.BlackScreen = false

		OverlayScreen.Visible = S.WhiteScreen
		OverlayScreen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

		return S.WhiteScreen
	end,
	4
)

local function updateLogoImage(id)
	if id and tostring(id) ~= "" then
		LogoImg.Image = "rbxassetid://" .. tostring(id)
		LogoImg.Visible = true
		LogoBtn.Text = ""
	else
		LogoImg.Visible = false
		LogoBtn.Text = "S"
	end
end

local logoInput = createTextInput(
	T3Container,
	"Skill 5: Enter Decal ID...",
	S.LogoImageId,
	function(val)
		S.LogoImageId = tostring(val)
		updateLogoImage(S.LogoImageId)
	end,
	5
)

local function updateGuiBackground(id)
	if id and tostring(id) ~= "" then
		GuiBackground.Image = "rbxassetid://" .. tostring(id)
		GuiBackground.Visible = true
	else
		GuiBackground.Image = ""
		GuiBackground.Visible = false
	end
end

local guiBackgroundInput = createTextInput(
	T3Container,
	"Skill 6: Enter GUI Background Image ID...",
	S.GuiBackgroundImageId,
	function(val)
		S.GuiBackgroundImageId = tostring(val)
		updateGuiBackground(S.GuiBackgroundImageId)
	end,
	6
)

local saveBtn = Instance.new("TextButton", T3Container)

saveBtn.Size = UDim2.new(1, 0, 0, 24)
saveBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
saveBtn.Text = "Skill 7: Save Config"
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Font = Enum.Font.SourceSansBold
saveBtn.TextSize = 10
saveBtn.LayoutOrder = 7
saveBtn.ZIndex = 24

Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 4)

saveBtn.MouseButton1Click:Connect(function()
	if not writefile then
		saveBtn.Text = "Skill 7: Not Supported"

		task.delay(1.2, function()
			saveBtn.Text = "Skill 7: Save Config"
		end)

		return
	end

	local ok = pcall(function()
		local data = HttpService:JSONEncode({
			GuiWidth = S.GuiWidth,
			GuiHeight = S.GuiHeight,
			GuiScale = S.GuiScale,
			LogoSize = S.LogoSize,
			LogoImageId = S.LogoImageId,
			GuiBackgroundImageId = S.GuiBackgroundImageId,
			LineMode = S.LineMode,
			GuiTransparency = S.GuiTransparency,
			GuiLocked = S.GuiLocked,
			Crosshair = S.Crosshair,

			ScreenDimEnabled = S.ScreenDimEnabled,
			ScreenDimOpacity = S.ScreenDimOpacity,

			AimNPC = S.AimNPC,
			AimPlr = S.AimPlr,
			Aim2D = S.Aim2D,
			EspNPC = S.EspNPC,
			EspNPC2D = S.EspNPC2D,
			EspPlr = S.EspPlr,
			EspName = S.EspName,
			Hitbox = S.Hitbox,

			Fps = S.Fps,
			Bright = S.Bright,
			Ultra = S.Ultra
		})

		writefile(SAVE_FILE, data)
	end)

	if ok then
		saveBtn.Text = "Skill 7: Saved!"
	else
		saveBtn.Text = "Skill 7: Save Failed"
	end

	task.delay(1.2, function()
		saveBtn.Text = "Skill 7: Save Config"
	end)
end)

local resetBtn = Instance.new("TextButton", T3Container)

resetBtn.Size = UDim2.new(1, 0, 0, 24)
resetBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
resetBtn.Text = "Skill 8: Reset All"
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.Font = Enum.Font.SourceSansBold
resetBtn.TextSize = 10
resetBtn.LayoutOrder = 8
resetBtn.ZIndex = 24

Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 4)

local confirmFrame = Instance.new("Frame", T3Container)

confirmFrame.Size = UDim2.new(1, 0, 0, 24)
confirmFrame.BackgroundTransparency = 1
confirmFrame.Visible = false
confirmFrame.LayoutOrder = 9
confirmFrame.ZIndex = 24

local yesBtn = Instance.new("TextButton", confirmFrame)

yesBtn.Size = UDim2.new(0.48, 0, 1, 0)
yesBtn.Position = UDim2.new(0, 0, 0, 0)
yesBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
yesBtn.Text = "YES (Confirm)"
yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
yesBtn.Font = Enum.Font.SourceSansBold
yesBtn.TextSize = 9
yesBtn.ZIndex = 25

Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 4)

local noBtn = Instance.new("TextButton", confirmFrame)

noBtn.Size = UDim2.new(0.48, 0, 1, 0)
noBtn.Position = UDim2.new(0.52, 0, 0, 0)
noBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
noBtn.Text = "NO (Cancel)"
noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noBtn.Font = Enum.Font.SourceSansBold
noBtn.TextSize = 9
noBtn.ZIndex = 25

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

	S.GuiWidth = 210
	S.GuiHeight = 160
	S.GuiScale = 1
	S.LogoSize = 50
	S.LogoImageId = ""
	S.GuiBackgroundImageId = ""
	S.LineMode = "off"

	Main.Size = UDim2.new(0, S.GuiWidth, 0, S.GuiHeight)
	Main.BackgroundColor3 = CFG.MAIN_BG
	MainScale.Scale = S.GuiScale
	Logo.Size = UDim2.new(0, S.LogoSize, 0, S.LogoSize)

	guiScaleInput.Text = tostring(S.GuiScale)
	logoSizeInput.Text = tostring(S.LogoSize)
	logoInput.Text = ""
	guiBackgroundInput.Text = ""

	updateLogoImage("")
	updateGuiBackground("")

	LineModeBtn.Text = lineModeLabel()

	confirmFrame.Visible = false
	resetBtn.Visible = true
end)

----------------------------------------------------------------
-- TAB 4: INTERFACE
----------------------------------------------------------------

local function setLogoPosition(pos)
	Logo.Position = pos
end

local function setGuiPosition(pos)
	Main.Position = pos
end

createSkillButton(T4Container, "Skill 1 (Logo Left)", function()
	setLogoPosition(UDim2.new(0, 10, 0, 10))
	return true
end, 1)

createSkillButton(T4Container, "Skill 2 (Logo Center)", function()
	setLogoPosition(UDim2.new(0.5, -S.LogoSize / 2, 0, 10))
	return true
end, 2)

createSkillButton(T4Container, "Skill 3 (Logo Right)", function()
	setLogoPosition(UDim2.new(1, -S.LogoSize - 10, 0, 10))
	return true
end, 3)

createSkillButton(T4Container, "Skill 4 (GUI Left)", function()
	setGuiPosition(UDim2.new(0, 10, 0.35, 0))
	return true
end, 4)

createSkillButton(T4Container, "Skill 5 (GUI Center)", function()
	setGuiPosition(UDim2.new(0.5, -S.GuiWidth / 2, 0.35, 0))
	return true
end, 5)

createSkillButton(T4Container, "Skill 6 (GUI Right)", function()
	setGuiPosition(UDim2.new(1, -S.GuiWidth - 10, 0.35, 0))
	return true
end, 6)

local GuiLockBtn = createSkillButton(T4Container, "Skill 7 (Lock GUI)", function()
	S.GuiLocked = not S.GuiLocked
	Main:SetAttribute("SR_Locked", S.GuiLocked)
	return S.GuiLocked
end, 7)

----------------------------------------------------------------
-- TAB 5: INTERFACE SETTINGS
----------------------------------------------------------------

local CrosshairBtn = createSkillButton(T5Container, "Skill 1 (Crosshair +)", function()
	S.Crosshair = not S.Crosshair
	Crosshair.Visible = S.Crosshair
	return S.Crosshair
end, 1)

local GuiTransparencyInput

createSkillButton(T5Container, "Skill 2 (Transparent GUI)", function()
	S.GuiTransparency = 0.85
	GuiTransparencyInput.Text = tostring(S.GuiTransparency)
	return true
end, 2)

GuiTransparencyInput = createTextInput(
	T5Container,
	"Skill 3: GUI Transparency (0 - 1)",
	S.GuiTransparency,
	function(val)
		local num = tonumber(val)
		if num and num >= 0 and num <= 1 then
			S.GuiTransparency = num
		else
			GuiTransparencyInput.Text = tostring(S.GuiTransparency)
		end
	end,
	3
)

local ScreenDimBtn = createSkillButton(T5Container, "Skill 4 (Screen Dim)", function()
	S.ScreenDimEnabled = not S.ScreenDimEnabled
	DimOverlay.Visible = S.ScreenDimEnabled
	DimOverlay.BackgroundTransparency = 1 - S.ScreenDimOpacity
	return S.ScreenDimEnabled
end, 4)

local ScreenDimInput

ScreenDimInput = createTextInput(
	T5Container,
	"Skill 4b: Do mo man hinh (0 - 1)",
	S.ScreenDimOpacity,
	function(val)
		local num = tonumber(val)
		if num and num >= 0 and num <= 1 then
			S.ScreenDimOpacity = num
			if S.ScreenDimEnabled then
				DimOverlay.BackgroundTransparency = 1 - num
			end
		else
			ScreenDimInput.Text = tostring(S.ScreenDimOpacity)
		end
	end,
	5
)

----------------------------------------------------------------
-- TAB 6: MUSIC
----------------------------------------------------------------

local MusicSound = Instance.new("Sound")
MusicSound.Name = "SR_Music"
MusicSound.Volume = S.MusicVolume
MusicSound.PlaybackSpeed = S.MusicSpeed
MusicSound.Parent = SoundService

createTextInput(T6Container, "Skill 1: Nhap Sound ID...", S.MusicId, function(val)
	S.MusicId = tostring(val)
	MusicSound.SoundId = "rbxassetid://" .. S.MusicId
end, 1)

createSkillButton(T6Container, "Skill 1b (Phat nhac)", function()
	S.MusicPlaying = not S.MusicPlaying

	if S.MusicPlaying then
		if S.MusicId == "" then
			S.MusicPlaying = false
			return false
		end

		MusicSound.SoundId = "rbxassetid://" .. S.MusicId
		MusicSound:Play()
	else
		MusicSound:Stop()
	end

	return S.MusicPlaying
end, 2)

local musicVolumeInput

musicVolumeInput = createTextInput(T6Container, "Skill 2: Am luong (0 - 1)", S.MusicVolume, function(val)
	local num = tonumber(val)
	if num and num >= 0 and num <= 1 then
		S.MusicVolume = num
		MusicSound.Volume = num
	else
		musicVolumeInput.Text = tostring(S.MusicVolume)
	end
end, 3)

local musicSpeedInput

musicSpeedInput = createTextInput(T6Container, "Skill 3: Toc do nhac (0.1 - 3)", S.MusicSpeed, function(val)
	local num = tonumber(val)
	if num and num >= 0.1 and num <= 3 then
		S.MusicSpeed = num
		MusicSound.PlaybackSpeed = num
	else
		musicSpeedInput.Text = tostring(S.MusicSpeed)
	end
end, 4)

----------------------------------------------------------------
-- AUTO LOAD CONFIG
----------------------------------------------------------------

if readfile and isfile and isfile(SAVE_FILE) then
	local ok = pcall(function()
		local data = HttpService:JSONDecode(readfile(SAVE_FILE))

		if not data then return end

		S.GuiWidth = tonumber(data.GuiWidth) or S.GuiWidth
		S.GuiHeight = tonumber(data.GuiHeight) or S.GuiHeight
		S.GuiScale = tonumber(data.GuiScale) or S.GuiScale
		S.LogoSize = tonumber(data.LogoSize) or S.LogoSize
		S.LogoImageId = data.LogoImageId or S.LogoImageId
		S.GuiBackgroundImageId = data.GuiBackgroundImageId or S.GuiBackgroundImageId

		if data.LineMode ~= nil then S.LineMode = data.LineMode end
		if data.GuiTransparency ~= nil then
			S.GuiTransparency = tonumber(data.GuiTransparency) or S.GuiTransparency
		end
		if data.GuiLocked ~= nil then S.GuiLocked = data.GuiLocked end
		if data.Crosshair ~= nil then S.Crosshair = data.Crosshair end
		if data.ScreenDimEnabled ~= nil then S.ScreenDimEnabled = data.ScreenDimEnabled end
		if data.ScreenDimOpacity ~= nil then
			S.ScreenDimOpacity = tonumber(data.ScreenDimOpacity) or S.ScreenDimOpacity
		end

		Main.Size = UDim2.new(0, S.GuiWidth, 0, S.GuiHeight)
		MainScale.Scale = S.GuiScale
		Logo.Size = UDim2.new(0, S.LogoSize, 0, S.LogoSize)

		guiScaleInput.Text = tostring(S.GuiScale)
		logoSizeInput.Text = tostring(S.LogoSize)
		logoInput.Text = S.LogoImageId
		guiBackgroundInput.Text = S.GuiBackgroundImageId
		GuiTransparencyInput.Text = tostring(S.GuiTransparency)
		ScreenDimInput.Text = tostring(S.ScreenDimOpacity)

		updateLogoImage(S.LogoImageId)
		updateGuiBackground(S.GuiBackgroundImageId)

		LineModeBtn.Text = lineModeLabel()

		if S.LineMode == "mode2" then
			Main.BackgroundColor3 = CFG.TAB_BG
		else
			Main.BackgroundColor3 = CFG.MAIN_BG
		end

		Main:SetAttribute("SR_Locked", S.GuiLocked)
		setToggleButtonVisual(GuiLockBtn, "Skill 7 (Lock GUI)", S.GuiLocked)
		setToggleButtonVisual(CrosshairBtn, "Skill 1 (Crosshair +)", S.Crosshair)

		DimOverlay.Visible = S.ScreenDimEnabled
		DimOverlay.BackgroundTransparency = 1 - S.ScreenDimOpacity
		setToggleButtonVisual(ScreenDimBtn, "Skill 4 (Screen Dim)", S.ScreenDimEnabled)

		if data.AimNPC ~= nil then S.AimNPC = data.AimNPC end
		if data.AimPlr ~= nil then S.AimPlr = data.AimPlr end
		if data.Aim2D ~= nil then S.Aim2D = data.Aim2D end
		if data.EspNPC ~= nil then S.EspNPC = data.EspNPC end
		if data.EspNPC2D ~= nil then S.EspNPC2D = data.EspNPC2D end
		if data.EspPlr ~= nil then S.EspPlr = data.EspPlr end
		if data.Hitbox ~= nil then S.Hitbox = data.Hitbox end

		setToggleButtonVisual(Skill1Btn, "Skill 1 (Aim NPC Strict & Lock)", S.AimNPC)
		if not S.AimNPC then Skill1Btn.TextColor3 = Color3.fromRGB(160, 160, 160) end
		if S.AimNPC then lockedNPC = getClosestNPC() end

		setToggleButtonVisual(Skill2Btn, "Skill 2 (Aim Player & Lock)", S.AimPlr)
		if not S.AimPlr then Skill2Btn.TextColor3 = Color3.fromRGB(255, 40, 40) end
		if S.AimPlr then lockedPlayer = getClosestPlayerToCenter() end

		setToggleButtonVisual(Aim2DBtn, "Skill 5 (Aim NPC 2D)", S.Aim2D)
		setToggleButtonVisual(EspNPCBtn, "Skill 3 (ESP NPC)", S.EspNPC)
		setToggleButtonVisual(EspNPC2DBtn, "Skill 6 (ESP NPC 2D)", S.EspNPC2D)
		setToggleButtonVisual(Skill4Btn, "Skill 4 (ESP Player)", S.EspPlr)
		if not S.EspPlr then Skill4Btn.TextColor3 = Color3.fromRGB(255, 40, 40) end
		setToggleButtonVisual(Skill9Btn, "Skill 9 (Hitbox Player)", S.Hitbox)
		if not S.Hitbox then Skill9Btn.TextColor3 = Color3.fromRGB(170, 0, 255) end

		if data.EspName ~= nil then S.EspName = data.EspName end
		if data.Fps ~= nil then S.Fps = data.Fps end
		if data.Bright ~= nil then S.Bright = data.Bright end
		if data.Ultra ~= nil then S.Ultra = data.Ultra end

		setToggleButtonVisual(NamePlayerBtn, "Skill 1 (ESP Name Player)", S.EspName)
		if not S.EspName then NamePlayerBtn.TextColor3 = Color3.fromRGB(255, 40, 40) end

		setToggleButtonVisual(FpsBtn, "Skill 2 (FPS Booster)", S.Fps)
		setToggleButtonVisual(BrightBtn, "Skill 3 (Full Bright)", S.Bright)
		setToggleButtonVisual(UltraBtn, "Skill 4 (Ultra Liminal)", S.Ultra)

		applyFps(S.Fps)
		applyBright(S.Bright)
		applyUltra(S.Ultra)
	end)

	if not ok then
		warn("[ScarletRomen] Load config bi loi, dung config mac dinh.")
	end
end

----------------------------------------------------------------
-- RENDER LOOP
----------------------------------------------------------------

local frames = 0
local lastT = tick()
local hue = 0

RunService.RenderStepped:Connect(function(dt)

	------------------------------------------------------------
	-- FPS COUNTER
	------------------------------------------------------------

	frames = frames + 1
	if tick() - lastT >= 1 then
		FPSLbl.Text = "FPS: " .. frames
		frames = 0
		lastT = tick()
	end

	------------------------------------------------------------
	-- AIM NPC & ESP NPC
	------------------------------------------------------------

	if S.AimNPC or S.EspNPC then
		local now = os.clock()
		if now - lastNPCRefresh >= NPC_REFRESH_INTERVAL then
			refreshNPCCache()
			lastNPCRefresh = now
		end

		if S.EspNPC then
			for _, model in ipairs(cachedNPCs) do
				if isValidNPC(model) then
					applyNPCESP(model)
				end
			end

			for model, highlight in pairs(espHighlights) do
				if not isValidNPC(model) then
					highlight:Destroy()
					espHighlights[model] = nil
				end
			end
		end

		if S.AimNPC then
			if not lockedNPC or not isValidNPC(lockedNPC) then
				lockedNPC = getClosestNPC()
			end

			if lockedNPC then
				local head = lockedNPC:FindFirstChild("Head") or lockedNPC.PrimaryPart
				if head then
					Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
				end
			end
		end
	end

	------------------------------------------------------------
	-- AIM PLAYER (Skill 2)
	------------------------------------------------------------

	if S.AimPlr then
		if not lockedPlayer or not isValidPlayer(lockedPlayer) then
			lockedPlayer = getClosestPlayerToCenter()
		end

		if lockedPlayer and lockedPlayer.Character then
			local head = lockedPlayer.Character:FindFirstChild("Head")
			if head then
				-- Lock Camera vào đầu target
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)

				-- Quay cơ thể người chơi về phía target
				local localChar = LocalPlayer.Character
				if localChar then
					local root = localChar:FindFirstChild("HumanoidRootPart")
					if root then
						local targetPos = Vector3.new(head.Position.X, root.Position.Y, head.Position.Z)
						root.CFrame = CFrame.new(root.Position, targetPos)
					end
				end
			end
		end
	end

	------------------------------------------------------------
	-- ESP PLAYER (Skill 4)
	------------------------------------------------------------

	if S.EspPlr then
		for _, plr in ipairs(Players:GetPlayers()) do
			if isValidPlayer(plr) then
				applyPlayerESP(plr)
			end
		end

		for plr, hl in pairs(playerESPHighlights) do
			if not isValidPlayer(plr) then
				if hl and hl.Parent then hl:Destroy() end
				playerESPHighlights[plr] = nil
			end
		end
	end

	------------------------------------------------------------
	-- HITBOX PLAYER (Skill 9)
	------------------------------------------------------------

	if S.Hitbox then
		for _, plr in ipairs(Players:GetPlayers()) do
			local char = plr.Character
			if char then
				local root = char:FindFirstChild("HumanoidRootPart")
				if root then
					root.Size = Vector3.new(13, 13, 13)
					root.CanCollide = false
					root.Transparency = 0.75

					if plr == LocalPlayer then
						root.Color = Color3.fromRGB(170, 0, 255) -- Hitbox User màu tím
					else
						root.Color = getPlayerColor(plr) -- Đồng đội: Xanh lá, Kẻ địch: Đỏ
					end
				end
			end
		end
	end

	------------------------------------------------------------
	-- ESP INTERACT (Skill 8)
	------------------------------------------------------------

	if S.EspInteract then
		local now2 = os.clock()
		if now2 - lastPromptRefresh >= PROMPT_REFRESH_INTERVAL then
			refreshPromptCache()
			lastPromptRefresh = now2
		end

		for _, prompt in ipairs(cachedPrompts) do
			if isValidPrompt(prompt) then
				applyPromptESP(prompt)
			end
		end

		for prompt, data in pairs(promptESP) do
			if not isValidPrompt(prompt) then
				if data.highlight then data.highlight:Destroy() end
				if data.billboard then data.billboard:Destroy() end
				promptESP[prompt] = nil
			end
		end
	end

	------------------------------------------------------------
	-- LINE MODE
	------------------------------------------------------------

	if S.LineMode == "off" then
		hue = (hue + dt * CFG.COLOR_SPEED) % 2
		local alpha = hue <= 1 and hue or (2 - hue)
		local dynamicLine = CFG.THEME:Lerp(CFG.BASIC_LINE, alpha)

		MSt.Color = dynamicLine
		LSt.Color = dynamicLine

		for _, tabData in ipairs(tabButtons) do
			if tabData.Stroke then
				tabData.Stroke.Color = dynamicLine
			end
		end

		MainScroll.ScrollBarImageColor3 = dynamicLine
		saveBtn.BackgroundColor3 = dynamicLine

	elseif S.LineMode == "mode1" or S.LineMode == "mode2" then
		MSt.Color = CFG.BASIC_LINE
		LSt.Color = CFG.BASIC_LINE

		MainScroll.ScrollBarImageColor3 = CFG.BASIC_LINE
		saveBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

		for _, tabData in ipairs(tabButtons) do
			if tabData.Stroke then
				tabData.Stroke.Color = CFG.BASIC_LINE
			end
		end

		if S.LineMode == "mode2" then
			MSt.Transparency = 1
		end

	elseif S.LineMode == "mode3" then
		hue = (hue + dt * CFG.COLOR_SPEED) % 2
		local alpha = hue <= 1 and hue or (2 - hue)
		local dynamicLine = Color3.fromRGB(255, 40, 40):Lerp(Color3.fromRGB(255, 255, 255), alpha)

		MSt.Color = dynamicLine
		LSt.Color = dynamicLine

		for _, tabData in ipairs(tabButtons) do
			if tabData.Stroke then
				tabData.Stroke.Color = dynamicLine
			end
		end

		MainScroll.ScrollBarImageColor3 = dynamicLine
		saveBtn.BackgroundColor3 = dynamicLine
	end

	------------------------------------------------------------
	-- SKILL BUTTON PULSE COLORS
	------------------------------------------------------------

	local pulse = (math.sin(tick() * 2.5) + 1) / 2
	local activePulseColor = Color3.fromRGB(70, 140, 255):Lerp(Color3.fromRGB(255, 255, 255), pulse)

	if S.AimNPC then
		Skill1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		Skill1Btn.TextColor3 = Color3.fromRGB(160, 160, 160)
	end

	if S.AimPlr then
		Skill2Btn.TextColor3 = activePulseColor
	else
		Skill2Btn.TextColor3 = Color3.fromRGB(255, 40, 40)
	end

	if S.EspPlr then
		Skill4Btn.TextColor3 = activePulseColor
	else
		Skill4Btn.TextColor3 = Color3.fromRGB(255, 40, 40)
	end

	if S.EspName then
		NamePlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		NamePlayerBtn.TextColor3 = Color3.fromRGB(255, 40, 40)
	end

	if S.Hitbox then
		Skill9Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		Skill9Btn.TextColor3 = Color3.fromRGB(170, 0, 255)
	end

	------------------------------------------------------------
	-- INTERFACE SETTINGS
	------------------------------------------------------------

	Crosshair.Visible = S.Crosshair

	local guiAlpha = math.clamp(S.GuiTransparency, 0, 1)
	Main.BackgroundTransparency = guiAlpha

	Logo.BackgroundTransparency = 0.15
	LSt.Transparency = 0.15

	for _, tabData in ipairs(tabButtons) do
		if tabData.Button then
			tabData.Button.BackgroundTransparency = 0.15
		end
		if tabData.Stroke then
			tabData.Stroke.Transparency = 0.15
		end
	end

	if guiAlpha >= 0.5 then
		GuiBackground.Visible = false
		MSt.Transparency = 1
		LSt.Transparency = 1
	elseif S.LineMode ~= "mode2" then
		MSt.Transparency = 0
		LSt.Transparency = 0.15
	end
end)

----------------------------------------------------------------
-- RESET KHI NHAN VAT RESPAWN
----------------------------------------------------------------

LocalPlayer.CharacterAdded:Connect(function()
	lockedNPC = nil
	lockedPlayer = nil
	if not S.EspNPC then
		clearAllNPCESP()
	end
	if not S.EspPlr then
		clearAllPlayerESP()
	end
	if not S.EspInteract then
		clearAllPromptESP()
	end
end)
