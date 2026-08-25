--[[
	ScarletRomen (Final Ultimate)
	- Menu logo (decal 133227737824937) bấm để mở/đóng tab
	- Tab kéo-thả (draggable)
	- Skill 1: Aim NPC (lock camera vào NPC)
	- Skill 2: ESP NPC (highlight màu vàng, nhìn xuyên tường)
	- Tối ưu: không quét toàn bộ Workspace mỗi frame, dùng danh sách NPC được
	  cache lại và refresh định kỳ (0.5s) thay vì GetDescendants() mỗi RenderStepped
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

----------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------
local MAX_DISTANCE = 800          -- phạm vi quét NPC (tăng so với bản cũ)
local NPC_REFRESH_INTERVAL = 0.5  -- giây, thời gian giữa 2 lần quét lại Workspace
local ESP_COLOR = Color3.fromRGB(255, 230, 0) -- vàng
local LOGO_DECAL_ID = "rbxassetid://133227737824937"

local IS_AIM_ENABLED = false
local IS_ESP_ENABLED = false
local lockedNPC = nil

-- Danh sách NPC được cache (chỉ rebuild theo interval, không phải mỗi frame)
local cachedNPCs = {}
local lastRefresh = 0

----------------------------------------------------------------
-- HELPER: kiểm tra NPC hợp lệ
----------------------------------------------------------------
local function isValidNPC(model)
	if not model or not model:IsA("Model") then return false end
	if Players:GetPlayerFromCharacter(model) then return false end -- loại player

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local head = model:FindFirstChild("Head") or model.PrimaryPart
	if humanoid and head and humanoid.Health > 0 then
		return true
	end
	return false
end

-- Rebuild danh sách NPC (chạy ít, đỡ lag hơn quét mỗi frame)
local function refreshNPCCache()
	table.clear(cachedNPCs)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if isValidNPC(obj) then
			table.insert(cachedNPCs, obj)
		end
	end
end

----------------------------------------------------------------
-- ESP
----------------------------------------------------------------
local espHighlights = {} -- [model] = Highlight instance

local function applyESP(model)
	if espHighlights[model] and espHighlights[model].Parent then return end
	local highlight = Instance.new("Highlight")
	highlight.Name = "ScarletESP"
	highlight.Adornee = model
	highlight.FillColor = ESP_COLOR
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = ESP_COLOR
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = model
	espHighlights[model] = highlight
end

local function clearAllESP()
	for model, highlight in pairs(espHighlights) do
		if highlight then highlight:Destroy() end
	end
	table.clear(espHighlights)
end

----------------------------------------------------------------
-- TÌM NPC GẦN TÂM MÀN HÌNH NHẤT (chỉ dùng cache, không quét lại)
----------------------------------------------------------------
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
				if dist3D <= MAX_DISTANCE and dist2D < shortestDist then
					shortestDist = dist2D
					closest = model
				end
			end
		end
	end
	return closest
end

----------------------------------------------------------------
-- UI: LOGO TOGGLE + TAB KÉO-THẢ
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScarletRomenGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- LOGO BUTTON
local LogoButton = Instance.new("ImageButton")
LogoButton.Name = "LogoButton"
LogoButton.Size = UDim2.new(0, 56, 0, 56)
LogoButton.Position = UDim2.new(0, 20, 0, 20)
LogoButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
LogoButton.Image = LOGO_DECAL_ID
LogoButton.ScaleType = Enum.ScaleType.Fit
LogoButton.Parent = ScreenGui

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1, 0)
LogoCorner.Parent = LogoButton

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Color3.fromRGB(255, 215, 0)
LogoStroke.Thickness = 2
LogoStroke.Parent = LogoButton

-- MAIN TAB FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 230)
MainFrame.Position = UDim2.new(0, 90, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 215, 0)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- TITLE BAR (dùng để kéo-thả)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- che góc bo tròn phía dưới titlebar để không bị hở
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
TitleFix.BorderSizePixel = 0
TitleFix.ZIndex = 0
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.Text = "ScarletRomen (Final Ultimate)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -32, 0, 4)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 14
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- CONTAINER SKILL
local SkillContainer = Instance.new("UIListLayout")
SkillContainer.Padding = UDim.new(0, 10)
SkillContainer.Parent = MainFrame

local SkillPadding = Instance.new("UIPadding")
SkillPadding.PaddingTop = UDim.new(0, 46)
SkillPadding.PaddingLeft = UDim.new(0, 12)
SkillPadding.PaddingRight = UDim.new(0, 12)
SkillPadding.Parent = MainFrame

-- Hàm tạo nút skill toggle
local function createSkillButton(text, order)
	local btn = Instance.new("TextButton")
	btn.Name = text
	btn.Size = UDim2.new(1, 0, 0, 44)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 15
	btn.LayoutOrder = order
	btn.Parent = MainFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(80, 80, 80)
	stroke.Thickness = 1
	stroke.Parent = btn

	return btn
end

local AimNPCButton = createSkillButton("Skill 1: Aim NPC [OFF]", 1)
local ESPNPCButton = createSkillButton("Skill 2: ESP NPC [OFF]", 2)

----------------------------------------------------------------
-- LOGO TOGGLE MỞ/ĐÓNG TAB
----------------------------------------------------------------
local isOpen = false
local function setTabVisible(state)
	isOpen = state
	MainFrame.Visible = state
end

LogoButton.MouseButton1Click:Connect(function()
	setTabVisible(not isOpen)
end)

CloseButton.MouseButton1Click:Connect(function()
	setTabVisible(false)
end)

----------------------------------------------------------------
-- KÉO-THẢ TAB (dùng TitleBar làm tay cầm)
----------------------------------------------------------------
local function makeDraggable(frame, handle)
	local dragging = false
	local dragStart, startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

makeDraggable(MainFrame, TitleBar)

-- Logo cũng kéo-thả được (không xung đột với Click vì dùng threshold nhỏ)
do
	local dragging = false
	local dragStart, startPos
	local moved = false

	LogoButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = false
			dragStart = input.Position
			startPos = LogoButton.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	LogoButton.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			if delta.Magnitude > 3 then moved = true end
			LogoButton.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

----------------------------------------------------------------
-- SKILL BUTTON EVENTS
----------------------------------------------------------------
AimNPCButton.MouseButton1Click:Connect(function()
	IS_AIM_ENABLED = not IS_AIM_ENABLED
	if IS_AIM_ENABLED then
		AimNPCButton.Text = "Skill 1: Aim NPC [ON]"
		AimNPCButton.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
		lockedNPC = getClosestNPC()
	else
		AimNPCButton.Text = "Skill 1: Aim NPC [OFF]"
		AimNPCButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		lockedNPC = nil
	end
end)

ESPNPCButton.MouseButton1Click:Connect(function()
	IS_ESP_ENABLED = not IS_ESP_ENABLED
	if IS_ESP_ENABLED then
		ESPNPCButton.Text = "Skill 2: ESP NPC [ON]"
		ESPNPCButton.BackgroundColor3 = Color3.fromRGB(150, 130, 0)
	else
		ESPNPCButton.Text = "Skill 2: ESP NPC [OFF]"
		ESPNPCButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		clearAllESP()
	end
end)

----------------------------------------------------------------
-- MAIN LOOP (tối ưu: refresh cache theo interval, không quét mỗi frame)
----------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	if not (IS_AIM_ENABLED or IS_ESP_ENABLED) then return end

	local now = os.clock()
	if now - lastRefresh >= NPC_REFRESH_INTERVAL then
		refreshNPCCache()
		lastRefresh = now
	end

	-- ESP: chỉ áp/gỡ dựa trên cache, không tạo lại nếu đã có
	if IS_ESP_ENABLED then
		for _, model in ipairs(cachedNPCs) do
			if isValidNPC(model) then
				applyESP(model)
			end
		end
		-- dọn ESP của NPC đã chết/biến mất
		for model, highlight in pairs(espHighlights) do
			if not isValidNPC(model) then
				highlight:Destroy()
				espHighlights[model] = nil
			end
		end
	end

	-- AIM: khóa camera vào NPC gần tâm màn hình nhất
	if IS_AIM_ENABLED then
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
end)

-- Reset khi nhân vật respawn
LocalPlayer.CharacterAdded:Connect(function()
	IS_AIM_ENABLED = false
	IS_ESP_ENABLED = false
	lockedNPC = nil
	clearAllESP()
	AimNPCButton.Text = "Skill 1: Aim NPC [OFF]"
	AimNPCButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	ESPNPCButton.Text = "Skill 2: ESP NPC [OFF]"
	ESPNPCButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
end)
