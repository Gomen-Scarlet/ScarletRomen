-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- VARIABLES
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- CONFIGURATIONS
local IS_AIM_PLAYER = false
local IS_AIM_NPC = false
local IS_FLYING = false
local ESP_PLAYER_ENABLED = false
local ESP_NPC_ENABLED = false

local FLY_SPEED = 50 
local FOV_RADIUS = 400 

local LOCKED_TARGET_HEAD = nil

-- COLOR CONFIGS
local COLOR_ENEMY = Color3.fromRGB(255, 0, 0)       -- Màu Đỏ (Kẻ địch)
local COLOR_ALLY = Color3.fromRGB(0, 150, 255)      -- Màu Xanh Dương (Đồng đội)
local COLOR_NPC = Color3.fromRGB(255, 215, 0)       -- Màu Vàng (NPC)

----------------------------------------------------------------
-- GIAO DIỆN GUI (TAB "SMASH FLAME" CÓ KÉO THẢ & ĐÓNG MỞ)
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SmashFlameGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Nút mở/đóng Tab
local OpenToggleBtn = Instance.new("TextButton")
OpenToggleBtn.Name = "OpenToggleBtn"
OpenToggleBtn.Size = UDim2.new(0, 120, 0, 35)
OpenToggleBtn.Position = UDim2.new(0, 15, 0.4, 0)
OpenToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
OpenToggleBtn.Text = "Menu: OPEN"
OpenToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
OpenToggleBtn.TextSize = 14
OpenToggleBtn.Font = Enum.Font.SourceSansBold
OpenToggleBtn.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 6)
OpenCorner.Parent = OpenToggleBtn

-- Frame chính (Tab Menu)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Position = UDim2.new(0.1, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

-- Tiêu đề Tab
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleLabel.Text = "SMASH FLAME"
TitleLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleLabel

-- Layout tự sắp xếp Nút
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = MainFrame
UIPadding.PaddingTop = UDim.new(0, 48)

-- Hàm tạo Nút chức năng nhanh
local function createButton(name, text, layoutOrder)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0.9, 0, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 14
	btn.Font = Enum.Font.SourceSansBold
	btn.LayoutOrder = layoutOrder
	btn.Parent = MainFrame
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn
	return btn
end

local BtnSkill1 = createButton("BtnSkill1", "Skill 1: Aim Player [OFF]", 1)
local BtnSkill2 = createButton("BtnSkill2", "Skill 2: Aim NPC [OFF]", 2)
local BtnSkill3 = createButton("BtnSkill3", "Skill 3: ESP Player [OFF]", 3)
local BtnSkill4 = createButton("BtnSkill4", "Skill 4: ESP NPC [OFF]", 4)

----------------------------------------------------------------
-- LOGIC DRAG & DROP (KÉO THẢ TAB) CỰC MƯỢT
----------------------------------------------------------------
local dragging, dragInput, dragStart, startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		updateDrag(input)
	end
end)

-- Ẩn / Hiện Menu Tab
OpenToggleBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
	OpenToggleBtn.Text = MainFrame.Visible and "Menu: OPEN" or "Menu: CLOSED"
	OpenToggleBtn.TextColor3 = MainFrame.Visible and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 50, 50)
end)

----------------------------------------------------------------
-- HELPER FUNCTIONS (KIỂM TRA ĐỒNG ĐỘI & MỤC TIÊU)
----------------------------------------------------------------

-- Kiểm tra có phải đồng đội hay không
local function isAlly(player)
	if player == LocalPlayer then return true end
	if LocalPlayer.Team ~= nil and player.Team ~= nil then
		return LocalPlayer.Team == player.Team
	end
	return false
end

-- Tìm Head Player gần tâm nhất (Không aim đồng đội)
local function findTargetPlayer()
	local closestHead = nil
	local shortestDistance = FOV_RADIUS
	local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and not isAlly(player) and player.Character then
			local head = player.Character:FindFirstChild("Head")
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if head and humanoid and humanoid.Health > 0 then
				local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerPos).Magnitude
					if dist < shortestDistance then
						shortestDistance = dist
						closestHead = head
					end
				end
			end
		end
	end
	return closestHead
end

-- Tìm Head NPC gần tâm nhất
local function findTargetNPC()
	local closestHead = nil
	local shortestDistance = FOV_RADIUS
	local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, model in ipairs(Workspace:GetDescendants()) do
		if model:IsA("Model") and not Players:GetPlayerFromCharacter(model) then
			local head = model:FindFirstChild("Head")
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			if head and humanoid and humanoid.Health > 0 then
				local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerPos).Magnitude
					if dist < shortestDistance then
						shortestDistance = dist
						closestHead = head
					end
				end
			end
		end
	end
	return closestHead
end

----------------------------------------------------------------
-- SYSTEM FLY (XỬ LÝ BAY BẰNG LINEARVELOCITY)
----------------------------------------------------------------
local attachment, linearVelocity

local function setupFlight(root)
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "FlyAttachment"
		attachment.Parent = root
	end
	if not linearVelocity then
		linearVelocity = Instance.new("LinearVelocity")
		linearVelocity.Name = "FlyVelocity"
		linearVelocity.MaxForce = 9e9
		linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector3
		linearVelocity.Attachment0 = attachment
		linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
		linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
		linearVelocity.Parent = root
	end
end

local function removeFlight()
	if linearVelocity then linearVelocity:Destroy() linearVelocity = nil end
	if attachment then attachment:Destroy() attachment = nil end
end

----------------------------------------------------------------
-- SYSTEM ESP (HIGHLIGHT BẢO ĐẢM KHÔNG LỖI RÁC SCRIPT)
----------------------------------------------------------------
local function applyHighlight(character, color)
	local hl = character:FindFirstChild("SmashFlameESP")
	if not hl then
		hl = Instance.new("Highlight")
		hl.Name = "SmashFlameESP"
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.FillTransparency = 0.5
		hl.OutlineTransparency = 0
		hl.Parent = character
	end
	hl.FillColor = color
	hl.OutlineColor = color
end

local function removeHighlight(character)
	local hl = character:FindFirstChild("SmashFlameESP")
	if hl then hl:Destroy() end
end

----------------------------------------------------------------
-- RENDERSTEPPED LOOP (AIM & FLY & ESP UPDATE)
----------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	-- 1. XỬ LÝ LOCK-IN AIM
	if (IS_AIM_PLAYER or IS_AIM_NPC) and LOCKED_TARGET_HEAD then
		if LOCKED_TARGET_HEAD.Parent and LOCKED_TARGET_HEAD.Parent:FindFirstChildOfClass("Humanoid") and LOCKED_TARGET_HEAD.Parent:FindFirstChildOfClass("Humanoid").Health > 0 then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, LOCKED_TARGET_HEAD.Position)
		else
			LOCKED_TARGET_HEAD = nil
		end
	end

	-- 2. XỬ LÝ BAY
	if IS_FLYING and root then
		setupFlight(root)
		local moveDirection = Vector3.new(0, 0, 0)
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end

		if moveDirection.Magnitude > 0 then
			linearVelocity.VectorVelocity = moveDirection.Unit * FLY_SPEED
			root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z))
		else
			linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
		end
	else
		removeFlight()
	end

	-- 3. XỬ LÝ ESP PLAYER
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if ESP_PLAYER_ENABLED then
				local color = isAlly(player) and COLOR_ALLY or COLOR_ENEMY
				applyHighlight(player.Character, color)
			else
				removeHighlight(player.Character)
			end
		end
	end

	-- 4. XỬ LÝ ESP NPC
	if ESP_NPC_ENABLED then
		for _, model in ipairs(Workspace:GetDescendants()) do
			if model:IsA("Model") and not Players:GetPlayerFromCharacter(model) then
				local humanoid = model:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health > 0 then
					applyHighlight(model, COLOR_NPC)
				end
			end
		end
	else
		for _, model in ipairs(Workspace:GetDescendants()) do
			if model:IsA("Model") and not Players:GetPlayerFromCharacter(model) then
				removeHighlight(model)
			end
		end
	end
end)

----------------------------------------------------------------
-- XỬ LÝ SỰ KIỆN NÚT BẤM
----------------------------------------------------------------

-- SKILL 1: AIM PLAYER
BtnSkill1.MouseButton1Click:Connect(function()
	IS_AIM_PLAYER = not IS_AIM_PLAYER
	IS_AIM_NPC = false 
	IS_FLYING = IS_AIM_PLAYER

	BtnSkill2.Text = "Skill 2: Aim NPC [OFF]"
	BtnSkill2.TextColor3 = Color3.fromRGB(255, 255, 255)

	if IS_AIM_PLAYER then
		BtnSkill1.Text = "Skill 1: Aim Player [ACTIVE]"
		BtnSkill1.TextColor3 = Color3.fromRGB(0, 255, 0)
		LOCKED_TARGET_HEAD = findTargetPlayer()
	else
		BtnSkill1.Text = "Skill 1: Aim Player [OFF]"
		BtnSkill1.TextColor3 = Color3.fromRGB(255, 255, 255)
		LOCKED_TARGET_HEAD = nil
		removeFlight()
	end
end)

-- SKILL 2: AIM NPC
BtnSkill2.MouseButton1Click:Connect(function()
	IS_AIM_NPC = not IS_AIM_NPC
	IS_AIM_PLAYER = false 
	IS_FLYING = IS_AIM_NPC

	BtnSkill1.Text = "Skill 1: Aim Player [OFF]"
	BtnSkill1.TextColor3 = Color3.fromRGB(255, 255, 255)

	if IS_AIM_NPC then
		BtnSkill2.Text = "Skill 2: Aim NPC [ACTIVE]"
		BtnSkill2.TextColor3 = Color3.fromRGB(0, 255, 0)
		LOCKED_TARGET_HEAD = findTargetNPC()
	else
		BtnSkill2.Text = "Skill 2: Aim NPC [OFF]"
		BtnSkill2.TextColor3 = Color3.fromRGB(255, 255, 255)
		LOCKED_TARGET_HEAD = nil
		removeFlight()
	end
end)

-- SKILL 3: ESP PLAYER
BtnSkill3.MouseButton1Click:Connect(function()
	ESP_PLAYER_ENABLED = not ESP_PLAYER_ENABLED
	if ESP_PLAYER_ENABLED then
		BtnSkill3.Text = "Skill 3: ESP Player [ACTIVE]"
		BtnSkill3.TextColor3 = Color3.fromRGB(0, 255, 0)
	else
		BtnSkill3.Text = "Skill 3: ESP Player [OFF]"
		BtnSkill3.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end)

-- SKILL 4: ESP NPC
BtnSkill4.MouseButton1Click:Connect(function()
	ESP_NPC_ENABLED = not ESP_NPC_ENABLED
	if ESP_NPC_ENABLED then
		BtnSkill4.Text = "Skill 4: ESP NPC [ACTIVE]"
		BtnSkill4.TextColor3 = Color3.fromRGB(0, 255, 0)
	else
		BtnSkill4.Text = "Skill 4: ESP NPC [OFF]"
		BtnSkill4.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end)

-- Reset trạng thái khi chết
LocalPlayer.CharacterAdded:Connect(function()
	IS_AIM_PLAYER = false
	IS_AIM_NPC = false
	IS_FLYING = false
	LOCKED_TARGET_HEAD = nil
	BtnSkill1.Text = "Skill 1: Aim Player [OFF]"
	BtnSkill1.TextColor3 = Color3.fromRGB(255, 255, 255)
	BtnSkill2.Text = "Skill 2: Aim NPC [OFF]"
	BtnSkill2.TextColor3 = Color3.fromRGB(255, 255, 255)
	removeFlight()
end)
