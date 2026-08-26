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
	STROKE = Color3.fromRGB(0, 40, 120),

	-- Màu khi hiệu ứng Line Color tắt
	BASIC_LINE = Color3.fromRGB(0, 0, 0),

	-- Thời gian hoàn thành một vòng đỏ -> đen -> đỏ
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

	Fps = false,
	Bright = false,
	Ultra = false,

	BlackScreen = false,
	WhiteScreen = false,

	-- Line effect
	LineColorEnabled = true,

	LockedTargetNPC = nil,
	LockedTargetPlr = nil,

	GuiWidth = 210,
	GuiHeight = 160,

	-- Scale tổng thể GUI
	GuiScale = 1,

	LogoSize = 50,
	LogoImageId = "",

	-- Background GUI
	GuiBackgroundImageId = ""
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
	local dragInput
	local dragStart
	local startPos

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

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

	UserInputService.InputChanged:Connect(function(input)
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
-- FULLSCREEN OVERLAY
----------------------------------------------------------------

local OverlayScreen = Instance.new("Frame", SG)
OverlayScreen.Name = "OverlayScreen"
OverlayScreen.Size = UDim2.new(1, 0, 1, 0)
OverlayScreen.Position = UDim2.new(0, 0, 0, 0)
OverlayScreen.BorderSizePixel = 0
OverlayScreen.Visible = false
OverlayScreen.ZIndex = 999

----------------------------------------------------------------
-- LOGO
----------------------------------------------------------------

local Logo = Instance.new("Frame", SG)
Logo.Name = "Logo"
Logo.Size = UDim2.new(0, S.LogoSize, 0, S.LogoSize)
Logo.Position = UDim2.new(0.15, 0, 0.4, 0)
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
Main.Position = UDim2.new(0.2, 0, 0.35, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BackgroundTransparency = 0
Main.ClipsDescendants = true
Main.ZIndex = 10

makeDraggable(Main)

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local MSt = Instance.new("UIStroke", Main)
MSt.Color = CFG.BASIC_LINE
MSt.Thickness = 2

----------------------------------------------------------------
-- GUI SCALE
----------------------------------------------------------------

local MainScale = Instance.new("UIScale")
MainScale.Scale = S.GuiScale
MainScale.Parent = Main

----------------------------------------------------------------
-- GUI BACKGROUND IMAGE
----------------------------------------------------------------

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

----------------------------------------------------------------
-- LOGO OPEN/CLOSE
----------------------------------------------------------------

LogoBtn.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)

----------------------------------------------------------------
-- MAIN SCROLL
----------------------------------------------------------------

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

----------------------------------------------------------------
-- FOOTER
----------------------------------------------------------------

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
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	btn.Text = "  " .. title .. " [ + ]"
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

			btn.Text = "  " .. title .. " [ - ]"
		else
			container.Visible = false

			if activeContainer == container then
				activeContainer = nil
			end

			btn.Text = "  " .. title .. " [ + ]"
		end
	end

	btn.MouseButton1Click:Connect(function()
		toggleTab(not container.Visible)
	end)

	backBtn.MouseButton1Click:Connect(function()
		toggleTab(false)
	end)

	return container
end

local T1Container = createTabHeader("Vision", 1)
local T2Container = createTabHeader("Liminal", 2)
local T3Container = createTabHeader("YinYang", 3)

----------------------------------------------------------------
-- LOGICS & TARGET FINDERS
----------------------------------------------------------------

local function isEnemy(player)
	if not player or player == LocalPlayer then
		return false
	end

	if LocalPlayer.Team and player.Team then
		return LocalPlayer.Team ~= player.Team
	end

	return true
end

local function isStrictNPC(m)
	if not m or not m:IsA("Model") then
		return false
	end

	if Players:GetPlayerFromCharacter(m) then
		return false
	end

	local hum = m:FindFirstChildOfClass("Humanoid")

	if not hum or hum.Health <= 0 then
		return false
	end

	local head = m:FindFirstChild("Head") or m.PrimaryPart

	return head and head:IsA("BasePart")
end

local function isStrictPlayer(m)
	if not m or not m:IsA("Model") then
		return false
	end

	if m == LocalPlayer.Character then
		return false
	end

	if not Players:GetPlayerFromCharacter(m) then
		return false
	end

	local hum = m:FindFirstChildOfClass("Humanoid")

	if not hum or hum.Health <= 0 then
		return false
	end

	local head = m:FindFirstChild("Head") or m.PrimaryPart

	return head and head:IsA("BasePart")
end

local function is2DNPC(o)
	if not o then
		return false
	end

	if Players:GetPlayerFromCharacter(o) then
		return false
	end

	local n = string.lower(o.Name)

	for _, w in ipairs({
		"wall",
		"tuong",
		"part",
		"baseplate",
		"building",
		"floor",
		"block",
		"mesh",
		"roof"
	}) do
		if string.find(n, w) then
			return false
		end
	end

	return o:IsA("Decal")
		or o:IsA("Texture")
		or o:IsA("BillboardGui")
end

local function getHeadPos(o)
	if not o then
		return nil
	end

	if o:IsA("Model") then
		local head = o:FindFirstChild("Head") or o.PrimaryPart

		if head and head:IsA("BasePart") then
			return head.Position
		end

		return o:GetPivot().Position

	elseif o:IsA("BasePart") then
		return o.Position

	elseif o.Parent and o.Parent:IsA("BasePart") then
		return o.Parent.Position
	end

	return nil
end

local function toggleHL(m, color, name, on, trans)
	if not m then
		return
	end

	local h = m:FindFirstChild(name)

	if on then
		if not h then
			h = Instance.new("Highlight")
			h.Name = name
			h.Parent = m
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		end

		h.FillColor = color
		h.FillTransparency = trans or 0.5
	else
		if h then
			h:Destroy()
		end
	end
end

local function getClosestToCrosshair(chkFunc)
	local cl
	local sDist = math.huge

	local centerScreen = Vector2.new(
		Camera.ViewportSize.X / 2,
		Camera.ViewportSize.Y / 2
	)

	for _, v in ipairs(Workspace:GetDescendants()) do
		if chkFunc(v) then
			local p = getHeadPos(v)

			if p then
				local screenPos, onScreen =
					Camera:WorldToViewportPoint(p)

				if onScreen then
					local distToCenter =
						(Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude

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

----------------------------------------------------------------
-- BUTTON HELPERS
----------------------------------------------------------------

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

		-- Không dùng đỏ cố định nữa.
		if st then
			b.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			b.TextColor3 = Color3.fromRGB(200, 200, 200)
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
-- TAB 1: VISION
----------------------------------------------------------------

-- Công tắc Line Color nằm trên cùng Tab 1
local LineColorBtn = createSkillButton(
	T1Container,
	"Line Color Effect",
	function()
		S.LineColorEnabled = not S.LineColorEnabled
		return S.LineColorEnabled
	end,
	1
)

LineColorBtn.Text = "Line Color Effect: ON"

createSkillButton(
	T1Container,
	"Skill 1 (Aim NPC Strict & Lock)",
	function()
		S.AimNPC = not S.AimNPC
		S.AimPlr = false
		S.Aim2D = false

		if not S.AimNPC then
			S.LockedTargetNPC = nil
		end

		return S.AimNPC
	end,
	2
)

local RainbowBtn = createSkillButton(
	T1Container,
	"Skill 2 (Aim Player & Lock)",
	function()
		S.AimPlr = not S.AimPlr
		S.AimNPC = false
		S.Aim2D = false

		if not S.AimPlr then
			S.LockedTargetPlr = nil
		end

		return S.AimPlr
	end,
	3
)

createSkillButton(
	T1Container,
	"Skill 3 (ESP NPC)",
	function()
		S.EspNPC = not S.EspNPC

		for _, v in ipairs(Workspace:GetDescendants()) do
			if isStrictNPC(v) then
				toggleHL(
					v,
					CFG.NPC,
					"SR_NPC",
					S.EspNPC
				)
			end
		end

		return S.EspNPC
	end,
	4
)

createSkillButton(
	T1Container,
	"Skill 4 (ESP Player)",
	function()
		S.EspPlr = not S.EspPlr

		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then
				if p == LocalPlayer then
					toggleHL(
						p.Character,
						CFG.MY_BODY,
						"SR_PLR",
						S.EspPlr,
						0.7
					)
				else
					local espColor =
						isEnemy(p) and CFG.ENEMY or CFG.ALLY

					toggleHL(
						p.Character,
						espColor,
						"SR_PLR",
						S.EspPlr,
						0.5
					)
				end
			end
		end

		return S.EspPlr
	end,
	5
)

createSkillButton(
	T1Container,
	"Skill 5 (Aim NPC 2D)",
	function()
		S.Aim2D = not S.Aim2D
		S.AimNPC = false
		S.AimPlr = false

		return S.Aim2D
	end,
	6
)

createSkillButton(
	T1Container,
	"Skill 6 (ESP NPC 2D)",
	function()
		S.EspNPC2D = not S.EspNPC2D

		for _, v in ipairs(Workspace:GetDescendants()) do
			if is2DNPC(v) then
				local targetObj

				if v:IsA("Model") or v:IsA("BasePart") then
					targetObj = v
				else
					targetObj = v.Parent
				end

				if targetObj then
					toggleHL(
						targetObj,
						CFG.NPC2D,
						"SR_NPC2D",
						S.EspNPC2D
					)
				end
			end
		end

		return S.EspNPC2D
	end,
	7
)

----------------------------------------------------------------
-- TAB 2: LIMINAL
----------------------------------------------------------------

createSkillButton(
	T2Container,
	"Skill 1 (ESP Name Player)",
	function()
		S.EspName = not S.EspName
		return S.EspName
	end,
	1
)

createSkillButton(
	T2Container,
	"Skill 2 (FPS Booster)",
	function()
		S.Fps = not S.Fps

		if S.Fps then
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			Lighting.GlobalShadows = false
		else
			settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
			Lighting.GlobalShadows = true
		end

		return S.Fps
	end,
	2
)

createSkillButton(
	T2Container,
	"Skill 3 (Full Bright)",
	function()
		S.Bright = not S.Bright

		if S.Bright then
			Lighting.FogEnd = 9e9
			Lighting.Brightness = 2
		else
			Lighting.FogEnd = 1000
			Lighting.Brightness = 1
		end

		return S.Bright
	end,
	3
)

createSkillButton(
	T2Container,
	"Skill 4 (Ultra Liminal)",
	function()
		S.Ultra = not S.Ultra
		FPSLbl.Visible = S.Ultra

		if S.Ultra then
			Camera.MaxAxisFieldOfView = 40

			for _, v in ipairs(Workspace:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Material = Enum.Material.SmoothPlastic
					v.Color = Color3.fromRGB(120, 120, 120)

				elseif v:IsA("Decal")
					or v:IsA("Texture")
					or v:IsA("Accessory")
					or v:IsA("Shirt")
					or v:IsA("Pants")
					or v:IsA("Animator") then

					pcall(function()
						v:Destroy()
					end)
				end
			end
		end

		return S.Ultra
	end,
	4
)

----------------------------------------------------------------
-- TAB 3: YINYANG
----------------------------------------------------------------

-- Skill 1 mới: Scale tổng thể GUI
local guiScaleInput = createTextInput(
	T3Container,
	"Skill 1: GUI Scale (0.5 - 3)",
	S.GuiScale,
	function(val)
		local num = tonumber(val)

		if num and num >= 0.5 and num <= 3 then
			S.GuiScale = num
			MainScale.Scale = S.GuiScale
		end
	end,
	1
)

----------------------------------------------------------------
-- LOGO SIZE
----------------------------------------------------------------

local logoSizeInput = createTextInput(
	T3Container,
	"Skill 2: Enter Logo Size",
	S.LogoSize,
	function(val)
		local num = tonumber(val)

		if num and num >= 20 and num <= 200 then
			S.LogoSize = num

			Logo.Size = UDim2.new(
				0,
				S.LogoSize,
				0,
				S.LogoSize
			)
		end
	end,
	2
)

----------------------------------------------------------------
-- BLACK SCREEN
----------------------------------------------------------------

createSkillButton(
	T3Container,
	"Skill 3 (Black Screen)",
	function()
		S.BlackScreen = not S.BlackScreen
		S.WhiteScreen = false

		OverlayScreen.Visible = S.BlackScreen
		OverlayScreen.BackgroundColor3 =
			Color3.fromRGB(0, 0, 0)

		return S.BlackScreen
	end,
	3
)

----------------------------------------------------------------
-- WHITE SCREEN
----------------------------------------------------------------

createSkillButton(
	T3Container,
	"Skill 4 (White Screen)",
	function()
		S.WhiteScreen = not S.WhiteScreen
		S.BlackScreen = false

		OverlayScreen.Visible = S.WhiteScreen
		OverlayScreen.BackgroundColor3 =
			Color3.fromRGB(255, 255, 255)

		return S.WhiteScreen
	end,
	4
)

----------------------------------------------------------------
-- LOGO IMAGE
----------------------------------------------------------------

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

----------------------------------------------------------------
-- GUI BACKGROUND IMAGE
----------------------------------------------------------------

local function updateGuiBackground(id)
	if id and tostring(id) ~= "" then
		GuiBackground.Image =
			"rbxassetid://" .. tostring(id)

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

----------------------------------------------------------------
-- SAVE CONFIG
----------------------------------------------------------------

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
	if writefile then
		local data = HttpService:JSONEncode({
			GuiWidth = S.GuiWidth,
			GuiHeight = S.GuiHeight,
			GuiScale = S.GuiScale,
			LogoSize = S.LogoSize,
			LogoImageId = S.LogoImageId,
			GuiBackgroundImageId = S.GuiBackgroundImageId,
			LineColorEnabled = S.LineColorEnabled
		})

		writefile(SAVE_FILE, data)
	end
end)

----------------------------------------------------------------
-- RESET
----------------------------------------------------------------

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
	S.LineColorEnabled = true

	Main.Size = UDim2.new(
		0,
		S.GuiWidth,
		0,
		S.GuiHeight
	)

	MainScale.Scale = S.GuiScale

	Logo.Size = UDim2.new(
		0,
		S.LogoSize,
		0,
		S.LogoSize
	)

	guiScaleInput.Text = tostring(S.GuiScale)
	logoSizeInput.Text = tostring(S.LogoSize)
	logoInput.Text = ""
	guiBackgroundInput.Text = ""

	updateLogoImage("")
	updateGuiBackground("")

	LineColorBtn.Text = "Line Color Effect: ON"

	confirmFrame.Visible = false
	resetBtn.Visible = true
end)

----------------------------------------------------------------
-- AUTO LOAD CONFIG
----------------------------------------------------------------

if readfile and isfile and isfile(SAVE_FILE) then
	pcall(function()
		local data =
			HttpService:JSONDecode(readfile(SAVE_FILE))

		if data then
			S.GuiWidth =
				tonumber(data.GuiWidth) or S.GuiWidth

			S.GuiHeight =
				tonumber(data.GuiHeight) or S.GuiHeight

			S.GuiScale =
				tonumber(data.GuiScale) or S.GuiScale

			S.LogoSize =
				tonumber(data.LogoSize) or S.LogoSize

			S.LogoImageId =
				data.LogoImageId or S.LogoImageId

			S.GuiBackgroundImageId =
				data.GuiBackgroundImageId
				or S.GuiBackgroundImageId

			if data.LineColorEnabled ~= nil then
				S.LineColorEnabled =
					data.LineColorEnabled
			end

			Main.Size = UDim2.new(
				0,
				S.GuiWidth,
				0,
				S.GuiHeight
			)

			MainScale.Scale = S.GuiScale

			Logo.Size = UDim2.new(
				0,
				S.LogoSize,
				0,
				S.LogoSize
			)

			guiScaleInput.Text =
				tostring(S.GuiScale)

			logoSizeInput.Text =
				tostring(S.LogoSize)

			logoInput.Text =
				S.LogoImageId

			guiBackgroundInput.Text =
				S.GuiBackgroundImageId

			updateLogoImage(S.LogoImageId)
			updateGuiBackground(
				S.GuiBackgroundImageId
			)

			LineColorBtn.Text =
				"Line Color Effect: "
				.. (S.LineColorEnabled and "ON" or "OFF")
		end
	end)
end

----------------------------------------------------------------
-- RENDER LOOP
----------------------------------------------------------------

local frames = 0
local lastT = tick()

local hue = 0

RunService.RenderStepped:Connect(function(dt)

	------------------------------------------------------------
	-- FPS
	------------------------------------------------------------

	frames = frames + 1

	if tick() - lastT >= 1 then
		FPSLbl.Text = "FPS: " .. frames
		frames = 0
		lastT = tick()
	end

	------------------------------------------------------------
	-- RED -> BLACK LINE EFFECT
	------------------------------------------------------------

	if S.LineColorEnabled then
		hue = (hue + dt * CFG.COLOR_SPEED) % 2

		-- 0 -> 1: đỏ -> đen
		-- 1 -> 2: đen -> đỏ
		local alpha

		if hue <= 1 then
			alpha = hue
		else
			alpha = 2 - hue
		end

		local dynamicLine =
			CFG.THEME:Lerp(
				CFG.BASIC_LINE,
				alpha
			)

		-- Main GUI border
		MSt.Color = dynamicLine

		-- Logo border
		LSt.Color = dynamicLine

		-- Tab borders
		for _, tabData in ipairs(tabButtons) do
			if tabData.Stroke then
				tabData.Stroke.Color = dynamicLine
			end

			if tabData.Button then
				if tabData.Button.Text:find("%[ %- %]") then
					tabData.Button.BackgroundColor3 =
						dynamicLine
				end
			end
		end

		-- Scrollbar
		MainScroll.ScrollBarImageColor3 =
			dynamicLine

		-- Save button cũng chạy theo line
		saveBtn.BackgroundColor3 =
			dynamicLine

	else
		-- Tắt hiệu ứng = toàn bộ line đen
		MSt.Color = CFG.BASIC_LINE
		LSt.Color = CFG.BASIC_LINE

		MainScroll.ScrollBarImageColor3 =
			CFG.BASIC_LINE

		saveBtn.BackgroundColor3 =
			Color3.fromRGB(35, 35, 35)

		for _, tabData in ipairs(tabButtons) do
			if tabData.Stroke then
				tabData.Stroke.Color =
					CFG.BASIC_LINE
			end
		end
	end

	------------------------------------------------------------
	-- AIM PLAYER RAINBOW
	------------------------------------------------------------

	if S.AimPlr then
		RainbowBtn.BackgroundColor3 =
			Color3.fromHSV(
				(tick() * 0.2) % 1,
				0.8,
				1
			)

		RainbowBtn.TextColor3 =
			Color3.fromRGB(255, 255, 255)
	else
		RainbowBtn.TextColor3 =
			Color3.fromRGB(200, 200, 200)
	end

	------------------------------------------------------------
	-- ESP PLAYER
	------------------------------------------------------------

	if S.EspPlr then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then

				if p == LocalPlayer then
					toggleHL(
						p.Character,
						CFG.MY_BODY,
						"SR_PLR",
						true,
						0.7
					)
				else
					local espColor =
						isEnemy(p)
						and CFG.ENEMY
						or CFG.ALLY

					toggleHL(
						p.Character,
						espColor,
						"SR_PLR",
						true,
						0.5
					)
				end
			end
		end
	end

	------------------------------------------------------------
	-- AIM LOCK
	------------------------------------------------------------

	local currentTarget = nil

	if S.AimNPC then

		if not isStrictNPC(S.LockedTargetNPC) then
			S.LockedTargetNPC =
				getClosestToCrosshair(isStrictNPC)
		end

		currentTarget = S.LockedTargetNPC

	elseif S.AimPlr then

		if not isStrictPlayer(S.LockedTargetPlr) then
			S.LockedTargetPlr =
				getClosestToCrosshair(isStrictPlayer)
		end

		currentTarget = S.LockedTargetPlr

	elseif S.Aim2D then

		currentTarget =
			getClosestToCrosshair(is2DNPC)

	else
		S.LockedTargetNPC = nil
		S.LockedTargetPlr = nil
	end

	if currentTarget then
		local p = getHeadPos(currentTarget)

		if p then
			Camera.CFrame =
				CFrame.lookAt(
					Camera.CFrame.Position,
					p
				)
		end
	end

	------------------------------------------------------------
	-- ESP NAME PLAYER
	------------------------------------------------------------

	if S.EspName then

		for _, p in ipairs(Players:GetPlayers()) do

			if p ~= LocalPlayer
				and p.Character
				and p.Character:FindFirstChild("Head") then

				local head =
					p.Character.Head

				local hum =
					p.Character:FindFirstChildOfClass(
						"Humanoid"
					)

				local tag =
					head:FindFirstChild("SR_NameTag")

				if hum and hum.Health > 0 then

					if not tag then

						tag = Instance.new(
							"BillboardGui"
						)

						tag.Name =
							"SR_NameTag"

						tag.Parent = head
						tag.Size =
							UDim2.new(
								0,
								150,
								0,
								40
							)

						tag.StudsOffset =
							Vector3.new(
								0,
								2.5,
								0
							)

						tag.AlwaysOnTop = true

						local lbl =
							Instance.new(
								"TextLabel",
								tag
							)

						lbl.Name =
							"NameLabel"

						lbl.Size =
							UDim2.new(
								1,
								0,
								1,
								0
							)

						lbl.BackgroundTransparency = 1

						lbl.TextColor3 =
							CFG.NAME

						lbl.TextStrokeColor3 =
							CFG.STROKE

						lbl.TextStrokeTransparency = 0
						lbl.Font =
							Enum.Font.SourceSansBold

						lbl.TextSize = 16
					end

					tag.NameLabel.Text =
						p.Name
						.. "\n["
						.. math.floor(hum.Health)
						.. " / "
						.. math.floor(hum.MaxHealth)
						.. " HP]"

				elseif tag then
					tag:Destroy()
				end
			end
		end

	else

		for _, p in ipairs(Players:GetPlayers()) do

			if p.Character
				and p.Character:FindFirstChild("Head") then

				local tag =
					p.Character.Head:FindFirstChild(
						"SR_NameTag"
					)

				if tag then
					tag:Destroy()
				end
			end
		end
	end
end)
