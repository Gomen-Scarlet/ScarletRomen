-- Name: smash flame (Absolute Lock Edition)
-- Type: LocalScript (StarterPlayerScripts / StarterCharacterScripts)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local settings = {
	aimNPC = false,     -- Skill 1
	aimPlayer = false,  -- Skill 2
	espNPC = false,     -- Skill 3
	espPlayer = false   -- Skill 4
}

local MAX_DISTANCE = 1500

--------------------------------------------------------------------------------
-- 1. GIAO DIỆN KÉO THẢ (DRAGGABLE UI)
--------------------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SmashFlameMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 170, 0, 235)
mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Name = "ToggleMenu"
toggleMenuBtn.Size = UDim2.new(1, 0, 0, 40)
toggleMenuBtn.Position = UDim2.new(0, 0, 0, 0)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleMenuBtn.Text = "SMASH FLAME ▲"
toggleMenuBtn.Font = Enum.Font.SourceSansBold
toggleMenuBtn.TextSize = 15
toggleMenuBtn.Parent = mainFrame
Instance.new("UICorner", toggleMenuBtn).CornerRadius = UDim.new(0, 8)

local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(1, 0, 0, 190)
container.Position = UDim2.new(0, 0, 0, 45)
container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
container.BackgroundTransparency = 0.15
container.ClipsDescendants = true
container.Parent = mainFrame
Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Logic kéo thả Window
local dragging, dragInput, dragStart, startPos
local function updateInput(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

toggleMenuBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

toggleMenuBtn.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then updateInput(input) end
end)

-- Tạo Button
local function createSkillButton(name, text, order)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(1, -10, 0, 40)
	btn.Position = UDim2.new(0, 5, 0, 0)
	btn.LayoutOrder = order
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Text = text
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 13
	btn.Parent = container
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, tweenInfo, {Size = UDim2.new(1, -6, 0, 40)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, tweenInfo, {Size = UDim2.new(1, -10, 0, 40)}):Play()
	end)

	return btn
end

local btnSkill1 = createSkillButton("Skill1", "Skill 1: Aim NPC [OFF]", 1)
local btnSkill2 = createSkillButton("Skill2", "Skill 2: Aim Player [OFF]", 2)
local btnSkill3 = createSkillButton("Skill3", "Skill 3: ESP NPC [OFF]", 3)
local btnSkill4 = createSkillButton("Skill4", "Skill 4: ESP Player [OFF]", 4)

local isExpanded = true
toggleMenuBtn.MouseButton1Click:Connect(function()
	isExpanded = not isExpanded
	local targetSize = isExpanded and UDim2.new(1, 0, 0, 190) or UDim2.new(1, 0, 0, 0)
	toggleMenuBtn.Text = isExpanded and "SMASH FLAME ▲" or "SMASH FLAME ▼"
	TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = targetSize
	}):Play()
end)

--------------------------------------------------------------------------------
-- 2. ĐIỀU KHIỂN SKILL & ESP
--------------------------------------------------------------------------------
local function updateButtonVisual(btn, state, activeText, inactiveText)
	local color = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(45, 45, 45)
	local textColor = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
	btn.Text = state and activeText or inactiveText
	TweenService:Create(btn, TweenInfo.new(0.2), {
		BackgroundColor3 = color,
		TextColor3 = textColor
	}):Play()
end

btnSkill1.MouseButton1Click:Connect(function()
	settings.aimNPC = not settings.aimNPC
	if settings.aimNPC then settings.aimPlayer = false end
	updateButtonVisual(btnSkill1, settings.aimNPC, "Skill 1: Aim NPC [ON]", "Skill 1: Aim NPC [OFF]")
	updateButtonVisual(btnSkill2, settings.aimPlayer, "Skill 2: Aim Player [ON]", "Skill 2: Aim Player [OFF]")
end)

btnSkill2.MouseButton1Click:Connect(function()
	settings.aimPlayer = not settings.aimPlayer
	if settings.aimPlayer then settings.aimNPC = false end
	updateButtonVisual(btnSkill2, settings.aimPlayer, "Skill 2: Aim Player [ON]", "Skill 2: Aim Player [OFF]")
	updateButtonVisual(btnSkill1, settings.aimNPC, "Skill 1: Aim NPC [ON]", "Skill 1: Aim NPC [OFF]")
end)

btnSkill3.MouseButton1Click:Connect(function()
	settings.espNPC = not settings.espNPC
	updateButtonVisual(btnSkill3, settings.espNPC, "Skill 3: ESP NPC [ON]", "Skill 3: ESP NPC [OFF]")
end)

btnSkill4.MouseButton1Click:Connect(function()
	settings.espPlayer = not settings.espPlayer
	updateButtonVisual(btnSkill4, settings.espPlayer, "Skill 4: ESP Player [ON]", "Skill 4: ESP Player [OFF]")
end)

local function setESP(model, enable, color)
	local esp = model:FindFirstChild("SmashFlameESP")
	if enable then
		if not esp then
			esp = Instance.new("Highlight")
			esp.Name = "SmashFlameESP"
			esp.Adornee = model
			esp.FillTransparency = 0.4
			esp.OutlineColor = Color3.fromRGB(255, 255, 255)
			esp.OutlineTransparency = 0
			esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			esp.Parent = model
		end
		esp.FillColor = color
	else
		if esp then esp:Destroy() end
	end
end

-- Thuật toán tìm mục tiêu
local function getAimTarget(isSearchingPlayer)
	local closestHead = nil
	local shortestDistance = math.huge
	local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= LocalPlayer.Character then
			local playerObj = Players:GetPlayerFromCharacter(obj)
			local humanoid = obj:FindFirstChildOfClass("Humanoid")
			local head = obj:FindFirstChild("Head") or obj.PrimaryPart

			if humanoid and head and humanoid.Health > 0 then
				local isValidTarget = false
				
				if isSearchingPlayer and playerObj then
					if LocalPlayer.Team and playerObj.Team then
						if playerObj.Team ~= LocalPlayer.Team then isValidTarget = true end
					else
						isValidTarget = true
					end
				elseif not isSearchingPlayer and not playerObj then
					isValidTarget = true
				end

				if isValidTarget then
					local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
					if onScreen then
						local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
						local worldDist = (head.Position - Camera.CFrame.Position).Magnitude
						
						if worldDist <= MAX_DISTANCE and mouseDist < shortestDistance then
							shortestDistance = mouseDist
							closestHead = head
						end
					end
				end
			end
		end
	end
	return closestHead
end

--------------------------------------------------------------------------------
-- 3. ABSOLUTE LOCK ENGINE (RENDERSTEPPED & BINDTORENDERSTEP)
--------------------------------------------------------------------------------
-- Khóa cứng Camera
local function applyAbsoluteLock(targetHead)
	if targetHead then
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
	else
		if Camera.CameraType == Enum.CameraType.Scriptable then
			Camera.CameraType = Enum.CameraType.Custom
		end
	end
end

RunService:BindToRenderStep("SmashFlameAbsoluteLock", Enum.RenderPriority.Camera.Value + 1, function()
	-- 1. Xử lý ESP
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= LocalPlayer.Character then
			local humanoid = obj:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				local playerObj = Players:GetPlayerFromCharacter(obj)
				if playerObj then
					if settings.espPlayer then
						local isAlly = LocalPlayer.Team and playerObj.Team and (playerObj.Team == LocalPlayer.Team)
						local espColor = isAlly and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(255, 30, 30)
						setESP(obj, true, espColor)
					else
						setESP(obj, false)
					end
				else
					if settings.espNPC then
						setESP(obj, true, Color3.fromRGB(255, 215, 0))
					else
						setESP(obj, false)
					end
				end
			else
				setESP(obj, false)
			end
		end
	end

	-- 2. Thực thi Absolute Lock
	local targetHead = nil
	if settings.aimNPC then
		targetHead = getAimTarget(false)
	elseif settings.aimPlayer then
		targetHead = getAimTarget(true)
	end

	applyAbsoluteLock(targetHead)
end)

-- Nút Header (Header Drag Bar)
local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Name = "ToggleMenu"
toggleMenuBtn.Size = UDim2.new(1, 0, 0, 40)
toggleMenuBtn.Position = UDim2.new(0, 0, 0, 0)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleMenuBtn.Text = "SMASH FLAME ▲"
toggleMenuBtn.Font = Enum.Font.SourceSansBold
toggleMenuBtn.TextSize = 15
toggleMenuBtn.Parent = mainFrame
Instance.new("UICorner", toggleMenuBtn).CornerRadius = UDim.new(0, 8)

-- Khung chứa 4 nút Skill
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(1, 0, 0, 190)
container.Position = UDim2.new(0, 0, 0, 45)
container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
container.BackgroundTransparency = 0.15
container.ClipsDescendants = true
container.Parent = mainFrame
Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Logic kéo thả Window (Drag & Drop)
local dragging, dragInput, dragStart, startPos

local function updateInput(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

toggleMenuBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

toggleMenuBtn.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		updateInput(input)
	end
end)

-- Tạo nút bấm Skill
local function createSkillButton(name, text, order)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(1, -10, 0, 40)
	btn.Position = UDim2.new(0, 5, 0, 0)
	btn.LayoutOrder = order
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Text = text
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 13
	btn.Parent = container
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, tweenInfo, {Size = UDim2.new(1, -6, 0, 40)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, tweenInfo, {Size = UDim2.new(1, -10, 0, 40)}):Play()
	end)

	return btn
end

local btnSkill1 = createSkillButton("Skill1", "Skill 1: Aim NPC [OFF]", 1)
local btnSkill2 = createSkillButton("Skill2", "Skill 2: Aim Player [OFF]", 2)
local btnSkill3 = createSkillButton("Skill3", "Skill 3: ESP NPC [OFF]", 3)
local btnSkill4 = createSkillButton("Skill4", "Skill 4: ESP Player [OFF]", 4)

-- Animation Thu Gọn / Mở Rộng Tab
local isExpanded = true
toggleMenuBtn.MouseButton1Click:Connect(function()
	isExpanded = not isExpanded
	local targetSize = isExpanded and UDim2.new(1, 0, 0, 190) or UDim2.new(1, 0, 0, 0)
	toggleMenuBtn.Text = isExpanded and "SMASH FLAME ▲" or "SMASH FLAME ▼"

	TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = targetSize
	}):Play()
end)

--------------------------------------------------------------------------------
-- 2. LOGIC AIM & ESP HỆ THỐNG
--------------------------------------------------------------------------------
local function updateButtonVisual(btn, state, activeText, inactiveText)
	local color = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(45, 45, 45)
	local textColor = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
	btn.Text = state and activeText or inactiveText

	TweenService:Create(btn, TweenInfo.new(0.2), {
		BackgroundColor3 = color,
		TextColor3 = textColor
	}):Play()
end

btnSkill1.MouseButton1Click:Connect(function()
	settings.aimNPC = not settings.aimNPC
	if settings.aimNPC then settings.aimPlayer = false end -- Ưu tiên 1 chế độ Aim
	updateButtonVisual(btnSkill1, settings.aimNPC, "Skill 1: Aim NPC [ON]", "Skill 1: Aim NPC [OFF]")
	updateButtonVisual(btnSkill2, settings.aimPlayer, "Skill 2: Aim Player [ON]", "Skill 2: Aim Player [OFF]")
end)

btnSkill2.MouseButton1Click:Connect(function()
	settings.aimPlayer = not settings.aimPlayer
	if settings.aimPlayer then settings.aimNPC = false end
	updateButtonVisual(btnSkill2, settings.aimPlayer, "Skill 2: Aim Player [ON]", "Skill 2: Aim Player [OFF]")
	updateButtonVisual(btnSkill1, settings.aimNPC, "Skill 1: Aim NPC [ON]", "Skill 1: Aim NPC [OFF]")
end)

btnSkill3.MouseButton1Click:Connect(function()
	settings.espNPC = not settings.espNPC
	updateButtonVisual(btnSkill3, settings.espNPC, "Skill 3: ESP NPC [ON]", "Skill 3: ESP NPC [OFF]")
end)

btnSkill4.MouseButton1Click:Connect(function()
	settings.espPlayer = not settings.espPlayer
	updateButtonVisual(btnSkill4, settings.espPlayer, "Skill 4: ESP Player [ON]", "Skill 4: ESP Player [OFF]")
end)

-- Tạo / Xóa ESP
local function setESP(model, enable, color)
	local esp = model:FindFirstChild("SmashFlameESP")
	if enable then
		if not esp then
			esp = Instance.new("Highlight")
			esp.Name = "SmashFlameESP"
			esp.Adornee = model
			esp.FillTransparency = 0.4
			esp.OutlineColor = Color3.fromRGB(255, 255, 255)
			esp.OutlineTransparency = 0
			esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			esp.Parent = model
		end
		esp.FillColor = color
	else
		if esp then esp:Destroy() end
	end
end

-- Tìm mục tiêu Aim Lock chuẩn xác
local function getAimTarget(isSearchingPlayer)
	local closestHead = nil
	local shortestDistance = math.huge
	local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= LocalPlayer.Character then
			local playerObj = Players:GetPlayerFromCharacter(obj)
			local humanoid = obj:FindFirstChildOfClass("Humanoid")
			local head = obj:FindFirstChild("Head") or obj.PrimaryPart

			if humanoid and head and humanoid.Health > 0 then
				local isValidTarget = false

				if isSearchingPlayer and playerObj then
					-- Chỉ nhận Player khác, loại bỏ Đồng đội nếu có Team
					if LocalPlayer.Team and playerObj.Team then
						if playerObj.Team ~= LocalPlayer.Team then isValidTarget = true end
					else
						isValidTarget = true
					end
				elseif not isSearchingPlayer and not playerObj then
					-- Chỉ nhận NPC chuẩn (Model không thuộc Player nào)
					isValidTarget = true
				end

				if isValidTarget then
					local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
					if onScreen then
						local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
						local worldDist = (head.Position - Camera.CFrame.Position).Magnitude

						if worldDist <= MAX_DISTANCE and mouseDist < shortestDistance then
							shortestDistance = mouseDist
							closestHead = head
						end
					end
				end
			end
		end
	end
	return closestHead
end

--------------------------------------------------------------------------------
-- 3. GAME LOOP (HARD LOCK & ESP COLORING)
--------------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	-- 1. Xử lý ESP Phân Màu
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= LocalPlayer.Character then
			local humanoid = obj:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				local playerObj = Players:GetPlayerFromCharacter(obj)

				if playerObj then
					-- ESP Player
					if settings.espPlayer then
						local isAlly = LocalPlayer.Team and playerObj.Team and (playerObj.Team == LocalPlayer.Team)
						local espColor = isAlly and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(255, 30, 30) -- Ally: Xanh Dương, Enemy: Đỏ
						setESP(obj, true, espColor)
					else
						setESP(obj, false)
					end
				else
					-- ESP NPC (Vàng)
					if settings.espNPC then
						setESP(obj, true, Color3.fromRGB(255, 215, 0))
					else
						setESP(obj, false)
					end
				end
			else
				setESP(obj, false)
			end
		end
	end

	-- 2. Xử lý Hard Lock Cam
	local targetHead = nil
	if settings.aimNPC then
		targetHead = getAimTarget(false)
	elseif settings.aimPlayer then
		targetHead = getAimTarget(true)
	end

	if targetHead then
		-- Khóa camera trực tiếp 100% vào Head
		Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
	end
end)
