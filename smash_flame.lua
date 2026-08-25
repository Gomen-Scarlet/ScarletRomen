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

-- MÀU SẮC ESP
local COLOR_ENEMY = Color3.fromRGB(255, 0, 0)       -- Đỏ (Kẻ địch)
local COLOR_ALLY = Color3.fromRGB(0, 150, 255)      -- Xanh Dương (Đồng đội)
local COLOR_NPC = Color3.fromRGB(255, 215, 0)       -- Vàng (NPC)

----------------------------------------------------------------
-- GIAO DIỆN TAB MENU (DÙNG LOGO CỦA BẠN & KÉO THẢ)
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Nút Logo Mở/Đóng Menu (Dùng Asset ID của bạn)
local OpenToggleBtn = Instance.new("ImageButton")
OpenToggleBtn.Name = "OpenToggleBtn"
OpenToggleBtn.Size = UDim2.new(0, 50, 0, 50)
OpenToggleBtn.Position = UDim2.new(0, 15, 0.4, 0)
OpenToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenToggleBtn.Image = "rbxassetid://133227737824937" 
OpenToggleBtn.Parent = ScreenGui

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0.5, 0) -- Bo tròn thành hình tròn
LogoCorner.Parent = OpenToggleBtn

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Color3.fromRGB(255, 0, 0)
LogoStroke.Thickness = 2
LogoStroke.Parent = OpenToggleBtn

-- Frame chính Tab Menu (Không tiêu đề)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 210)
MainFrame.Position = UDim2.new(0.05, 0, 0.45, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = MainFrame

-- UI Layout sắp xếp nút
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = MainFrame
UIPadding.PaddingTop = UDim.new(0, 12)

-- Hàm tạo Nút bấm
local function createButton(name, text, layoutOrder)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0.9, 0, 0, 38)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 13
	btn.Font = Enum.Font.SourceSansBold
	btn.LayoutOrder = layoutOrder
	btn.Parent = MainFrame
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn
	return btn
end

local BtnSkill1 = createButton("BtnSkill1", "skill 1 [Aim Player]", 1)
local BtnSkill2 = createButton("BtnSkill2", "skill 2 [Aim NPC]", 2)
local BtnSkill3 = createButton("BtnSkill3", "skill 3 [ESP Player]", 3)
local BtnSkill4 = createButton("BtnSkill4", "skill 4 [ESP NPC]", 4)

----------------------------------------------------------------
-- LOGIC DRAG & DROP (KÉO THẢ TAB) + BẬT TẮT QUA LOGO
----------------------------------------------------------------
local dragging, dragInput, dragStart, startPos

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
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Click Logo để Đóng/Mở Tab Menu
OpenToggleBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
	LogoStroke.Color = MainFrame.Visible and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(80, 80, 80)
end)

----------------------------------------------------------------
-- LOGIC FUNCTIONS & HELPERS
----------------------------------------------------------------

-- Kiểm tra đồng đội
local function isAlly(player)
	if player == LocalPlayer then return true end
	if LocalPlayer.Team ~= nil and player.Team ~= nil then
		return LocalPlayer.Team == player.Team
	end
	return false
end

-- Tìm Player gần nhất (Không Aim đồng đội)
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

-- Tìm NPC gần nhất
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

-- QUẢN LÝ LỰC BAY
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

-- QUẢN LÝ HIGHLIGHT ESP
local function applyHighlight(model, color)
	local hl = model:FindFirstChild("CustomESP")
	if not hl then
		hl = Instance.new("Highlight")
		hl.Name = "CustomESP"
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.FillTransparency = 0.5
		hl.OutlineTransparency = 0
		hl.Parent = model
	end
	hl.FillColor = color
	hl.OutlineColor = color
end

local function removeHighlight(model)
	local hl = model:FindFirstChild("CustomESP")
	if hl then hl:Destroy() end
end

----------------------------------------------------------------
-- VÒNG LẶP RENDERSTEPPED
----------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	-- 1. LOCK AIM CAMERA
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

	-- 3. ESP PLAYER (ĐỎ CHỦ THỂ / XANH DƯƠNG ĐỒNG ĐỘI)
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

	-- 4. ESP NPC (MÀU VÀNG)
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
-- SỰ KIỆN CLICK NÚT BẤM (SKILLS)
----------------------------------------------------------------

-- SKILL 1: AIM PLAYER
BtnSkill1.MouseButton1Click:Connect(function()
	IS_AIM_PLAYER = not IS_AIM_PLAYER
	IS_AIM_NPC = false 
	IS_FLYING = IS_AIM_PLAYER

	BtnSkill2.Text = "skill 2 [Aim NPC]"
	BtnSkill2.TextColor3 = Color3.fromRGB(255, 255, 255)

	if IS_AIM_PLAYER then
		BtnSkill1.TextColor3 = Color3.fromRGB(0, 255, 0)
		BtnSkill1.Text = "skill 1 [ACTIVE]"
		LOCKED_TARGET_HEAD = findTargetPlayer()
	else
		BtnSkill1.TextColor3 = Color3.fromRGB(255, 255, 255)
		BtnSkill1.Text = "skill 1 [Aim Player]"
		LOCKED_TARGET_HEAD = nil
		removeFlight()
	end
end)

-- SKILL 2: AIM NPC
BtnSkill2.MouseButton1Click:Connect(function()
	IS_AIM_NPC = not IS_AIM_NPC
	IS_AIM_PLAYER = false 
	IS_FLYING = IS_AIM_NPC

	BtnSkill1.Text = "skill 1 [Aim Player]"
	BtnSkill1.TextColor3 = Color3.fromRGB(255, 255, 255)

	if IS_AIM_NPC then
		BtnSkill2.TextColor3 = Color3.fromRGB(0, 255, 0)
		BtnSkill2.Text = "skill 2 [ACTIVE]"
		LOCKED_TARGET_HEAD = findTargetNPC()
	else
		BtnSkill2.TextColor3 = Color3.fromRGB(255, 255, 255)
		BtnSkill2.Text = "skill 2 [Aim NPC]"
		LOCKED_TARGET_HEAD = nil
		removeFlight()
	end
end)

-- SKILL 3: ESP PLAYER
BtnSkill3.MouseButton1Click:Connect(function()
	ESP_PLAYER_ENABLED = not ESP_PLAYER_ENABLED
	if ESP_PLAYER_ENABLED then
		BtnSkill3.TextColor3 = Color3.fromRGB(0, 255, 0)
		BtnSkill3.Text = "skill 3 [ACTIVE]"
	else
		BtnSkill3.TextColor3 = Color3.fromRGB(255, 255, 255)
		BtnSkill3.Text = "skill 3 [ESP Player]"
	end
end)

-- SKILL 4: ESP NPC
BtnSkill4.MouseButton1Click:Connect(function()
	ESP_NPC_ENABLED = not ESP_NPC_ENABLED
	if ESP_NPC_ENABLED then
		BtnSkill4.TextColor3 = Color3.fromRGB(0, 255, 0)
		BtnSkill4.Text = "skill 4 [ACTIVE]"
	else
		BtnSkill4.TextColor3 = Color3.fromRGB(255, 255, 255)
		BtnSkill4.Text = "skill 4 [ESP NPC]"
	end
end)

-- RESET KHI NHÂN VẬT CHẾT
LocalPlayer.CharacterAdded:Connect(function()
	IS_AIM_PLAYER = false
	IS_AIM_NPC = false
	IS_FLYING = false
	LOCKED_TARGET_HEAD = nil
	BtnSkill1.TextColor3 = Color3.fromRGB(255, 255, 255)
	BtnSkill1.Text = "skill 1 [Aim Player]"
	BtnSkill2.TextColor3 = Color3.fromRGB(255, 255, 255)
	BtnSkill2.Text = "skill 2 [Aim NPC]"
	removeFlight()
end)
