-- Name: ScarletRomen (Final Ultimate - 2 Tabs & Ultra Liminal Edition)
-- Type: LocalScript (Đặt trong StarterPlayerScripts hoặc StarterCharacterScripts)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- CONFIGURATIONS
local CONFIG = {
	NPC_AIM_RANGE = 5000,
	LOGO_ID = "rbxassetid://133227737824937",
	COLOR_THEME = Color3.fromRGB(255, 30, 30),
	COLOR_NPC_ESP = Color3.fromRGB(255, 215, 0),
	COLOR_ENEMY_ESP = Color3.fromRGB(255, 40, 40),
	COLOR_ALLY_ESP = Color3.fromRGB(40, 255, 40),
	COLOR_NAME_ESP = Color3.fromRGB(0, 170, 255),
}

-- STATES
local State = {
	AimNPC = false,
	AimPlayer = false,
	AimNPC2D = false,
	EspNPC = false,
	EspPlayer = false,
	EspName = false,
	FpsBooster = false,
	FullBright = false,
	UltraLiminal = false,
	LockedTarget = nil
}

----------------------------------------------------------------
-- DRAGGABLE SYSTEM
----------------------------------------------------------------
local function makeDraggable(guiObject)
	local dragging, dragInput, dragStart, startPos
	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
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

-- 1. FIX HỒNG TÂM DẤU "+" CHUẨN TÂM
local crosshairFrame = Instance.new("Frame")
crosshairFrame.Name = "Crosshair"
crosshairFrame.Size = UDim2.new(0, 15, 0, 15)
crosshairFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairFrame.BackgroundTransparency = 1
crosshairFrame.Parent = screenGui

local chHorizontal = Instance.new("Frame")
chHorizontal.Size = UDim2.new(1, 0, 0, 1)
chHorizontal.Position = UDim2.new(0, 0, 0.5, 0)
chHorizontal.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
chHorizontal.BorderSizePixel = 0
chHorizontal.Parent = crosshairFrame

local chVertical = Instance.new("Frame")
chVertical.Size = UDim2.new(0, 1, 1, 0)
chVertical.Position = UDim2.new(0.5, 0, 0, 0)
chVertical.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
chVertical.BorderSizePixel = 0
chVertical.Parent = crosshairFrame

-- FPS COUNTER DISPLAY
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FPSCounter"
fpsLabel.Size = UDim2.new(0, 100, 0, 20)
fpsLabel.Position = UDim2.new(0, 10, 0, 10)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: --"
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
fpsLabel.TextSize = 14
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.Visible = false
fpsLabel.Parent = screenGui

-- 2. LOGO CONTAINER
local logoContainer = Instance.new("Frame")
logoContainer.Size = UDim2.new(0, 48, 0, 48)
logoContainer.Position = UDim2.new(0.05, 0, 0.2, 0)
logoContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
logoContainer.Parent = screenGui
makeDraggable(logoContainer)

local logoCorner = Instance.new("UICorner") logoCorner.CornerRadius = UDim.new(0, 8) logoCorner.Parent = logoContainer
local logoStroke = Instance.new("UIStroke") logoStroke.Color = CONFIG.COLOR_THEME logoStroke.Thickness = 2 logoStroke.Parent = logoContainer

local logoButton = Instance.new("ImageButton")
logoButton.Size = UDim2.new(1, -4, 1, -4)
logoButton.Position = UDim2.new(0, 2, 0, 2)
logoButton.Image = CONFIG.LOGO_ID
logoButton.BackgroundTransparency = 1
logoButton.Parent = logoContainer

local sLabel = Instance.new("TextLabel")
sLabel.Size = UDim2.new(1, 0, 1, 0)
sLabel.BackgroundTransparency = 1
sLabel.Text = "S"
sLabel.TextColor3 = CONFIG.COLOR_THEME
sLabel.TextSize = 22
sLabel.Font = Enum.Font.SourceSansBold
sLabel.TextStrokeTransparency = 0
sLabel.Parent = logoButton

-- 3. MAIN MENU (2 TABS UI)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 230, 0, 220)
mainFrame.Position = UDim2.new(0.12, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Parent = screenGui
makeDraggable(mainFrame)

local mainCorner = Instance.new("UICorner") mainCorner.CornerRadius = UDim.new(0, 8) mainCorner.Parent = mainFrame
local mainStroke = Instance.new("UIStroke") mainStroke.Color = CONFIG.COLOR_THEME mainStroke.Thickness = 2 mainStroke.Parent = mainFrame

-- Tab Navigation Buttons
local navContainer = Instance.new("Frame")
navContainer.Size = UDim2.new(1, 0, 0, 30)
navContainer.BackgroundTransparency = 1
navContainer.Parent = mainFrame

local tab1Btn = Instance.new("TextButton")
tab1Btn.Size = UDim2.new(0.5, -2, 1, 0)
tab1Btn.Position = UDim2.new(0, 2, 0, 0)
tab1Btn.BackgroundColor3 = CONFIG.COLOR_THEME
tab1Btn.Text = "Vision"
tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
tab1Btn.Font = Enum.Font.SourceSansBold
tab1Btn.TextSize = 13
tab1Btn.Parent = navContainer

local tab2Btn = Instance.new("TextButton")
tab2Btn.Size = UDim2.new(0.5, -2, 1, 0)
tab2Btn.Position = UDim2.new(0.5, 0, 0, 0)
tab2Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tab2Btn.Text = "Liminal"
tab2Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
tab2Btn.Font = Enum.Font.SourceSansBold
tab2Btn.TextSize = 13
tab2Btn.Parent = navContainer

local line = Instance.new("Frame")
line.Size = UDim2.new(1, -16, 0, 2)
line.Position = UDim2.new(0, 8, 0, 32)
line.BackgroundColor3 = CONFIG.COLOR_THEME
line.BorderSizePixel = 0
line.Parent = mainFrame

-- Tab Frames
local tab1Frame = Instance.new("ScrollingFrame")
tab1Frame.Size = UDim2.new(1, 0, 1, -52)
tab1Frame.Position = UDim2.new(0, 0, 0, 34)
tab1Frame.BackgroundTransparency = 1
tab1Frame.CanvasSize = UDim2.new(0, 0, 0, 200)
tab1Frame.ScrollBarThickness = 3
tab1Frame.ScrollBarImageColor3 = CONFIG.COLOR_THEME
tab1Frame.Parent = mainFrame

local tab2Frame = Instance.new("ScrollingFrame")
tab2Frame.Size = UDim2.new(1, 0, 1, -52)
tab2Frame.Position = UDim2.new(0, 0, 0, 34)
tab2Frame.BackgroundTransparency = 1
tab2Frame.CanvasSize = UDim2.new(0, 0, 0, 160)
tab2Frame.ScrollBarThickness = 3
tab2Frame.ScrollBarImageColor3 = CONFIG.COLOR_THEME
tab2Frame.Visible = false
tab2Frame.Parent = mainFrame

local layout1 = Instance.new("UIListLayout") layout1.Padding = UDim.new(0, 4) layout1.HorizontalAlignment = Enum.HorizontalAlignment.Center layout1.Parent = tab1Frame
local layout2 = Instance.new("UIListLayout") layout2.Padding = UDim.new(0, 4) layout2.HorizontalAlignment = Enum.HorizontalAlignment.Center layout2.Parent = tab2Frame

local footerLabel = Instance.new("TextLabel")
footerLabel.Size = UDim2.new(1, 0, 0, 16)
footerLabel.Position = UDim2.new(0, 0, 1, -16)
footerLabel.BackgroundTransparency = 1
footerLabel.Text = "by: Scarlet Romen"
footerLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
footerLabel.TextSize = 10
footerLabel.Font = Enum.Font.SourceSansItalic
footerLabel.Parent = mainFrame

-- Tab Switch Logic
tab1Btn.MouseButton1Click:Connect(function()
	tab1Frame.Visible = true
	tab2Frame.Visible = false
	tab1Btn.BackgroundColor3 = CONFIG.COLOR_THEME
	tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	tab2Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	tab2Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

tab2Btn.MouseButton1Click:Connect(function()
	tab1Frame.Visible = false
	tab2Frame.Visible = true
	tab2Btn.BackgroundColor3 = CONFIG.COLOR_THEME
	tab2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	tab1Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	tab1Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

logoButton.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)

----------------------------------------------------------------
-- CHECK LOGIC & HELPER FUNCTIONS
----------------------------------------------------------------
local function isValidNPC(model)
	if not model or not model:IsA("Model") then return false end
	if Players:GetPlayerFromCharacter(model) then return false end
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local head = model:FindFirstChild("Head") or model.PrimaryPart
	return humanoid and head and humanoid.Health > 0
end

-- FIX AIM NPC 2D: LOẠI BỎ TƯỜNG 3D VÀ KHỐI NHÀ CỬA CHẮC CHẮN
local function isValid2DNPC(obj)
	if not obj then return false end
	if Players:GetPlayerFromCharacter(obj) then return false end
	
	local nameLower = string.lower(obj.Name)
	local blacklist = {"wall", "tuong", "part", "baseplate", "building", "floor", "block", "mesh", "wedge", "roof"}
	for _, word in ipairs(blacklist) do
		if string.find(nameLower, word) then return false end
	end

	if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("BillboardGui") then
		return true
	end
	return false
end

local function getTargetPosition(obj)
	if obj:IsA("BasePart") then return obj.Position
	elseif obj:IsA("Model") then return (obj.PrimaryPart and obj.PrimaryPart.Position) or (obj:FindFirstChild("Head") and obj.Head.Position) or obj:GetPivot().Position
	elseif obj:IsA("Decal") or obj:IsA("Texture") then return obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent.Position or nil
	elseif obj:IsA("BillboardGui") then return obj.Adornee and obj.Adornee.Position or (obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent.Position) or nil
	end
	return nil
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
			if State.EspNPC then applyHighlight(obj, CONFIG.COLOR_NPC_ESP, "SR_NPC_ESP")
			else removeHighlight(obj, "SR_NPC_ESP") end
		end
	end
end

local function refreshPlayerESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if State.EspPlayer then
				local isAlly = LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team
				applyHighlight(player.Character, isAlly and CONFIG.COLOR_ALLY_ESP or CONFIG.COLOR_ENEMY_ESP, "SR_PLAYER_ESP")
			else removeHighlight(player.Character, "SR_PLAYER_ESP") end
		end
	end
end

-- TAB 2: ESP NAME PLAYER
local function refreshNameESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local head = player.Character.Head
			local tag = head:FindFirstChild("SR_NameTag")
			if State.EspName then
				if not tag then
					tag = Instance.new("BillboardGui")
					tag.Name = "SR_NameTag"
					tag.Size = UDim2.new(0, 100, 0, 30)
					tag.StudsOffset = Vector3.new(0, 2, 0)
					tag.AlwaysOnTop = true
					tag.Parent = head

					local lbl = Instance.new("TextLabel")
					lbl.Size = UDim2.new(1, 0, 1, 0)
					lbl.BackgroundTransparency = 1
					lbl.Text = player.Name
					lbl.TextColor3 = CONFIG.COLOR_NAME_ESP
					lbl.Font = Enum.Font.SourceSansBold
					lbl.TextSize = 14
					lbl.TextStrokeTransparency = 0
					lbl.Parent = tag
				end
			else
				if tag then tag:Destroy() end
			end
		end
	end
end

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

local function getClosest2DNPC()
	local closest, shortestDist = nil, math.huge
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if isValid2DNPC(obj) then
			local pos = getTargetPosition(obj)
			if pos then
				local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
				if onScreen then
					local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
					local worldDist = (pos - Camera.CFrame.Position).Magnitude
					if worldDist <= CONFIG.NPC_AIM_RANGE and mouseDist < shortestDist then
						shortestDist = mouseDist
						closest = obj
					end
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
local function createSkillButton(parent, text, onClick)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 195, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.Text = text .. ": OFF"
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 12
	btn.Parent = parent

	local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 6) corner.Parent = btn

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

-- TAB 1 SKILLS
createSkillButton(tab1Frame, "Skill 1 (Aim NPC)", function()
	State.AimNPC = not State.AimNPC
	if State.AimNPC then State.AimPlayer, State.AimNPC2D = false, false State.LockedTarget = getClosestNPC() else State.LockedTarget = nil end
	return State.AimNPC
end)

createSkillButton(tab1Frame, "Skill 2 (Aim Player)", function()
	State.AimPlayer = not State.AimPlayer
	if State.AimPlayer then State.AimNPC, State.AimNPC2D = false, false State.LockedTarget = getClosestPlayer() else State.LockedTarget = nil end
	return State.AimPlayer
end)

createSkillButton(tab1Frame, "Skill 3 (ESP NPC)", function()
	State.EspNPC = not State.EspNPC
	refreshNpcESP()
	return State.EspNPC
end)

createSkillButton(tab1Frame, "Skill 4 (ESP Player)", function()
	State.EspPlayer = not State.EspPlayer
	refreshPlayerESP()
	return State.EspPlayer
end)

createSkillButton(tab1Frame, "Skill 5 (Aim NPC 2D)", function()
	State.AimNPC2D = not State.AimNPC2D
	if State.AimNPC2D then State.AimNPC, State.AimPlayer = false, false State.LockedTarget = getClosest2DNPC() else State.LockedTarget = nil end
	return State.AimNPC2D
end)

-- TAB 2 SKILLS
createSkillButton(tab2Frame, "Skill 1 (ESP Name Player)", function()
	State.EspName = not State.EspName
	refreshNameESP()
	return State.EspName
end)

createSkillButton(tab2Frame, "Skill 2 (FPS Booster)", function()
	State.FpsBooster = not State.FpsBooster
	if State.FpsBooster then
		settings().Rendering.QualityLevel = 1
		Lighting.GlobalShadows = false
	else
		Lighting.GlobalShadows = true
	end
	return State.FpsBooster
end)

createSkillButton(tab2Frame, "Skill 3 (Full Bright & No Fog)", function()
	State.FullBright = not State.FullBright
	if State.FullBright then
		Lighting.FogEnd = 9e9
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
	else
		Lighting.FogEnd = 1000
		Lighting.Brightness = 1
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	end
	return State.FullBright
end)

createSkillButton(tab2Frame, "Skill 4 (Ultra Liminal Lag Destroyer)", function()
	State.UltraLiminal = not State.UltraLiminal
	fpsLabel.Visible = State.UltraLiminal
	
	if State.UltraLiminal then
		-- Tầm nhìn gần cực hạn & Trời đen tuyền
		Camera.MaxAxisFieldOfView = 40
		Lighting.Sky:Destroy() local sky = Instance.new("Sky") sky.SkyboxBk = "" sky.SkyboxDn = "" sky.SkyboxFt = "" sky.SkyboxLf = "" sky.SkyboxRt = "" sky.SkyboxUp = "" sky.Parent = Lighting
		
		-- Xóa hiệu ứng ánh sáng, làm mờ
		for _, v in ipairs(Lighting:GetChildren()) do
			if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") then v:Destroy() end
		end
		
		-- Tối ưu triệt để Texture & Skin da xám trọc
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Material = Enum.Material.SmoothPlastic
				v.Color = Color3.fromRGB(120, 120, 120)
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v:Destroy()
			elseif v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") then
				v:Destroy()
			elseif v:IsA("Animator") or v:IsA("AnimationTrack") then
				v:Destroy()
			end
		end
	end
	return State.UltraLiminal
end)

----------------------------------------------------------------
-- RENDER LOOP (HARD LOCK & FPS COUNTER)
----------------------------------------------------------------
local lastTime = tick()
local frameCount = 0

RunService.RenderStepped:Connect(function()
	-- Cập nhật FPS
	frameCount = frameCount + 1
	if tick() - lastTime >= 1 then
		fpsLabel.Text = "FPS: " .. frameCount
		frameCount = 0
		lastTime = tick()
	end

	-- Lock Aim
	if State.AimNPC then
		if not isValidNPC(State.LockedTarget) then State.LockedTarget = getClosestNPC() end
		if State.LockedTarget then
			local head = State.LockedTarget:FindFirstChild("Head") or State.LockedTarget.PrimaryPart
			if head then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, head.Position) end
		end
	elseif State.AimPlayer then
		if not State.LockedTarget or not State.LockedTarget:FindFirstChild("Head") or State.LockedTarget:FindFirstChildOfClass("Humanoid").Health <= 0 then
			State.LockedTarget = getClosestPlayer()
		end
		if State.LockedTarget and State.LockedTarget:FindFirstChild("Head") then
			Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, State.LockedTarget.Head.Position)
		end
	elseif State.AimNPC2D then
		if not State.LockedTarget or not isValid2DNPC(State.LockedTarget) then
			State.LockedTarget = getClosest2DNPC()
		end
		if State.LockedTarget then
			local pos = getTargetPosition(State.LockedTarget)
			if pos then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, pos) end
		end
	end
end)
