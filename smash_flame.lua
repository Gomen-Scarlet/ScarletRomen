-- Name: ScarletRomen (Final Ultimate - Fix Visual UI)
-- Type: LocalScript (Đặt trong StarterPlayerScripts hoặc StarterCharacterScripts)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- CONFIGURATIONS
local CONFIG = {
	NPC_AIM_RANGE = 5000,
	LOGO_ID = "rbxassetid://133227737824937",
	COLOR_THEME = Color3.fromRGB(255, 30, 30), -- Viền đỏ tươi
	COLOR_NPC_ESP = Color3.fromRGB(255, 215, 0), -- Vàng
	COLOR_ENEMY_ESP = Color3.fromRGB(255, 40, 40), -- Đỏ
	COLOR_ALLY_ESP = Color3.fromRGB(40, 255, 40), -- Xanh lá
}

-- STATES
local State = {
	AimNPC = false,
	AimPlayer = false,
	EspNPC = false,
	EspPlayer = false,
	LockedTarget = nil
}

----------------------------------------------------------------
-- HELPER: DRAGGABLE SYSTEM
----------------------------------------------------------------
local function makeDraggable(guiObject)
	local dragging, dragInput, dragStart, startPos
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

----------------------------------------------------------------
-- GUI CREATION
----------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScarletRomenUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 1. HỒNG TÂM DẤU "+" MÀU XÁM (FIX CHUẨN TÂM MÀN HÌNH)
local crosshairFrame = Instance.new("Frame")
crosshairFrame.Name = "Crosshair"
crosshairFrame.Size = UDim2.new(0, 14, 0, 14)
crosshairFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairFrame.BackgroundTransparency = 1
crosshairFrame.Parent = screenGui

local chHorizontal = Instance.new("Frame")
chHorizontal.Size = UDim2.new(1, 0, 0, 2)
chHorizontal.Position = UDim2.new(0, 0, 0.5, -1)
chHorizontal.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
chHorizontal.BorderSizePixel = 0
chHorizontal.Parent = crosshairFrame

local chVertical = Instance.new("Frame")
chVertical.Size = UDim2.new(0, 2, 1, 0)
chVertical.Position = UDim2.new(0.5, -1, 0, 0)
chVertical.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
chVertical.BorderSizePixel = 0
chVertical.Parent = crosshairFrame

-- 2. LOGO ICON VỚI VIỀN ĐỎ (DRAGGABLE & FIX ẢNH RÕ)
local logoContainer = Instance.new("Frame")
logoContainer.Name = "LogoContainer"
logoContainer.Size = UDim2.new(0, 50, 0, 50)
logoContainer.Position = UDim2.new(0.05, 0, 0.2, 0)
logoContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
logoContainer.Parent = screenGui
makeDraggable(logoContainer)

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 8)
logoCorner.Parent = logoContainer

-- Viền đỏ cho logo
local logoStroke = Instance.new("UIStroke")
logoStroke.Color = CONFIG.COLOR_THEME
logoStroke.Thickness = 2
logoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
logoStroke.Parent = logoContainer

local logoButton = Instance.new("ImageButton")
logoButton.Name = "LogoButton"
logoButton.Size = UDim2.new(1, -6, 1, -6)
logoButton.Position = UDim2.new(0, 3, 0, 3)
logoButton.Image = CONFIG.LOGO_ID
logoButton.BackgroundTransparency = 1
logoButton.Parent = logoContainer

local logoBtnCorner = Instance.new("UICorner")
logoBtnCorner.CornerRadius = UDim.new(0, 6)
logoBtnCorner.Parent = logoButton

-- 3. MAIN MENU TAB (DRAGGABLE)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 240, 0, 280)
mainFrame.Position = UDim2.new(0.12, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Visible = true
mainFrame.Parent = screenGui
makeDraggable(mainFrame)

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = CONFIG.COLOR_THEME
mainStroke.Thickness = 2
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = mainFrame

-- Title Bar
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ScarletRomen (Final Ultimate)"
titleLabel.TextColor3 = CONFIG.COLOR_THEME
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

local line = Instance.new("Frame")
line.Size = UDim2.new(1, -20, 0, 2)
line.Position = UDim2.new(0, 10, 0, 40)
line.BackgroundColor3 = CONFIG.COLOR_THEME
line.BorderSizePixel = 0
line.Parent = mainFrame

-- Container chứa 4 nút
local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 1, -50)
container.Position = UDim2.new(0, 0, 0, 50)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local buttonsLayout = Instance.new("UIListLayout")
buttonsLayout.Padding = UDim.new(0, 8)
buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
buttonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
buttonsLayout.Parent = container

-- Toggle Menu qua Logo
logoButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

----------------------------------------------------------------
-- UTILITY FUNCTIONS & ESP LOGIC
----------------------------------------------------------------
local function isValidNPC(model)
	if not model or not model:IsA("Model") then return false end
	if Players:GetPlayerFromCharacter(model) then return false end
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local head = model:FindFirstChild("Head") or model.PrimaryPart
	return humanoid and head and humanoid.Health > 0
end

local function applyHighlight(model, color, name)
	local esp = model:FindFirstChild(name)
	if not esp then
		esp = Instance.new("Highlight")
		esp.Name = name
		esp.Adornee = model
		esp.FillTransparency = 0.5
		esp.OutlineTransparency = 0
		esp.OutlineColor = Color3.fromRGB(255, 255, 255)
		esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		esp.Parent = model
	end
	esp.FillColor = color
end

local function removeHighlight(model, name)
	local esp = model:FindFirstChild(name)
	if esp then esp:Destroy() end
end

local function refreshNpcESP()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if isValidNPC(obj) then
			if State.EspNPC then
				applyHighlight(obj, CONFIG.COLOR_NPC_ESP, "SR_NPC_ESP")
			else
				removeHighlight(obj, "SR_NPC_ESP")
			end
		end
	end
end

local function refreshPlayerESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if State.EspPlayer then
				local isAlly = LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team
				local color = isAlly and CONFIG.COLOR_ALLY_ESP or CONFIG.COLOR_ENEMY_ESP
				applyHighlight(player.Character, color, "SR_PLAYER_ESP")
			else
				removeHighlight(player.Character, "SR_PLAYER_ESP")
			end
		end
	end
end

Workspace.DescendantAdded:Connect(function(obj)
	if State.EspNPC and isValidNPC(obj) then
		applyHighlight(obj, CONFIG.COLOR_NPC_ESP, "SR_NPC_ESP")
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		if State.EspPlayer then
			task.wait(0.5)
			refreshPlayerESP()
		end
	end)
end)

----------------------------------------------------------------
-- TARGET FINDERS
----------------------------------------------------------------
local function getClosestNPC()
	local closest, shortestDist = nil, math.huge
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if isValidNPC(obj) then
			local head = obj:FindFirstChild("Head") or obj.PrimaryPart
			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if onScreen then
				local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
				local worldDist = (head.Position - Camera.CFrame.Position).Magnitude
				if worldDist <= CONFIG.NPC_AIM_RANGE and mouseDist < shortestDist then
					shortestDist = mouseDist
					closest = obj
				end
			end
		end
	end
	return closest
end

local function getClosestPlayer()
	local closest, shortestDist = nil, math.huge
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			local head = player.Character:FindFirstChild("Head")
			if humanoid and head and humanoid.Health > 0 then
				local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
					if dist < shortestDist then
						shortestDist = dist
						closest = player.Character
					end
				end
			end
		end
	end
	return closest
end

----------------------------------------------------------------
-- BUTTON CREATOR
----------------------------------------------------------------
local function createSkillButton(order, text, onClick)
	local btn = Instance.new("TextButton")
	btn.Name = "SkillButton_" .. order
	btn.Size = UDim2.new(0, 200, 0, 42)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.Text = text .. ": OFF"
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	btn.LayoutOrder = order
	btn.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		local active = onClick(btn)
		if active then
			btn.Text = text .. ": ON"
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.BackgroundColor3 = CONFIG.COLOR_THEME
		else
			btn.Text = text .. ": OFF"
			btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		end
	end)
end

createSkillButton(1, "Skill 1 (Aim NPC)", function()
	State.AimNPC = not State.AimNPC
	if State.AimNPC then
		State.AimPlayer = false
		State.LockedTarget = getClosestNPC()
	else
		State.LockedTarget = nil
	end
	return State.AimNPC
end)

createSkillButton(2, "Skill 2 (Aim Player)", function()
	State.AimPlayer = not State.AimPlayer
	if State.AimPlayer then
		State.AimNPC = false
		State.LockedTarget = getClosestPlayer()
	else
		State.LockedTarget = nil
	end
	return State.AimPlayer
end)

createSkillButton(3, "Skill 3 (ESP NPC)", function()
	State.EspNPC = not State.EspNPC
	refreshNpcESP()
	return State.EspNPC
end)

createSkillButton(4, "Skill 4 (ESP Player)", function()
	State.EspPlayer = not State.EspPlayer
	refreshPlayerESP()
	return State.EspPlayer
end)

----------------------------------------------------------------
-- MAIN RENDER LOOP (HARD LOCK)
----------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	if State.AimNPC then
		if not isValidNPC(State.LockedTarget) then
			State.LockedTarget = getClosestNPC()
		end
		if State.LockedTarget then
			local head = State.LockedTarget:FindFirstChild("Head") or State.LockedTarget.PrimaryPart
			if head then
				Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, head.Position)
			end
		end
	elseif State.AimPlayer then
		if not State.LockedTarget or not State.LockedTarget:FindFirstChild("Head") or State.LockedTarget:FindFirstChildOfClass("Humanoid").Health <= 0 then
			State.LockedTarget = getClosestPlayer()
		end
		if State.LockedTarget and State.LockedTarget:FindFirstChild("Head") then
			Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, State.LockedTarget.Head.Position)
		end
	end
end)
