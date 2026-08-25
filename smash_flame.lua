-- Name: smash flame (Hard Aim Lock - No Camera Sticking)
-- Type: LocalScript (StarterPlayerScripts / StarterCharacterScripts)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local settings = {
	aimNPC = false,
	aimPlayer = false,
	espNPC = false,
	espPlayer = false
}

local MAX_DISTANCE = 1500

--------------------------------------------------------------------------------
-- 1. UI DRAGGABLE & TAB FIX
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
toggleMenuBtn.ZIndex = 2
toggleMenuBtn.Parent = mainFrame
Instance.new("UICorner", toggleMenuBtn).CornerRadius = UDim.new(0, 8)

local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(1, 0, 0, 190)
container.Position = UDim2.new(0, 0, 0, 45)
container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
container.BackgroundTransparency = 0.15
container.ClipsDescendants = true
container.ZIndex = 1
container.Parent = mainFrame
Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Logic kéo thả Window
local dragging, dragStart, startPos
toggleMenuBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

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
	return btn
end

local btnSkill1 = createSkillButton("Skill1", "Skill 1: Aim NPC [OFF]", 1)
local btnSkill2 = createSkillButton("Skill2", "Skill 2: Aim Player [OFF]", 2)
local btnSkill3 = createSkillButton("Skill3", "Skill 3: ESP NPC [OFF]", 3)
local btnSkill4 = createSkillButton("Skill4", "Skill 4: ESP Player [OFF]", 4)

local isExpanded = true
toggleMenuBtn.MouseButton1Click:Connect(function()
	isExpanded = not isExpanded
	toggleMenuBtn.Text = isExpanded and "SMASH FLAME ▲" or "SMASH FLAME ▼"
	
	if isExpanded then
		container.Visible = true
		TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 0, 190)
		}):Play()
	else
		local tween = TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(1, 0, 0, 0)
		})
		tween:Play()
		tween.Completed:Connect(function()
			if not isExpanded then container.Visible = false end
		end)
	end
end)

--------------------------------------------------------------------------------
-- 2. ESP & CACHE
--------------------------------------------------------------------------------
local function updateButtonVisual(btn, state, activeText, inactiveText)
	btn.Text = state and activeText or inactiveText
	btn.BackgroundColor3 = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(45, 45, 45)
	btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
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

local cachedTargets = {}

local function scanWorkspace()
	table.clear(cachedTargets)
	for _, obj in ipairs(Workspace:GetChildren()) do
		if obj:IsA("Model") and obj ~= LocalPlayer.Character then
			local humanoid = obj:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				table.insert(cachedTargets, obj)
			end
		elseif obj:IsA("Folder") then
			for _, child in ipairs(obj:GetChildren()) do
				if child:IsA("Model") and child ~= LocalPlayer.Character then
					local humanoid = child:FindFirstChildOfClass("Humanoid")
					if humanoid and humanoid.Health > 0 then
						table.insert(cachedTargets, child)
					end
				end
			end
		end
	end
end

task.spawn(function()
	while true do
		scanWorkspace()
		task.wait(0.5)
	end
end)

task.spawn(function()
	while true do
		for _, model in ipairs(cachedTargets) do
			if model and model.Parent then
				local playerObj = Players:GetPlayerFromCharacter(model)
				local esp = model:FindFirstChild("SmashFlameESP")

				if playerObj then
					if settings.espPlayer then
						local isAlly = LocalPlayer.Team and playerObj.Team and (playerObj.Team == LocalPlayer.Team)
						local color = isAlly and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(255, 30, 30)
						
						if not esp then
							esp = Instance.new("Highlight")
							esp.Name = "SmashFlameESP"
							esp.Adornee = model
							esp.FillTransparency = 0.4
							esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
							esp.Parent = model
						end
						esp.FillColor = color
					elseif esp then
						esp:Destroy()
					end
				else
					if settings.espNPC then
						if not esp then
							esp = Instance.new("Highlight")
							esp.Name = "SmashFlameESP"
							esp.Adornee = model
							esp.FillTransparency = 0.4
							esp.FillColor = Color3.fromRGB(255, 215, 0)
							esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
							esp.Parent = model
						end
					elseif esp then
						esp:Destroy()
					end
				end
			end
		end
		task.wait(0.1)
	end
end)

--------------------------------------------------------------------------------
-- 3. HARD AIM LOCK ENGINE (Khóa cứng 100%, không trôi)
--------------------------------------------------------------------------------
local function getAimTarget(isSearchingPlayer)
	local closestHead = nil
	local shortestDistance = math.huge
	local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, obj in ipairs(cachedTargets) do
		if obj and obj.Parent then
			local playerObj = Players:GetPlayerFromCharacter(obj)
			local humanoid = obj:FindFirstChildOfClass("Humanoid")
			local head = obj:FindFirstChild("Head") or obj.PrimaryPart

			if humanoid and head and humanoid.Health > 0 then
				local isValid = false
				if isSearchingPlayer and playerObj then
					if not (LocalPlayer.Team and playerObj.Team and playerObj.Team == LocalPlayer.Team) then
						isValid = true
					end
				elseif not isSearchingPlayer and not playerObj then
					isValid = true
				end

				if isValid then
					local worldDist = (head.Position - Camera.CFrame.Position).Magnitude
					if worldDist <= MAX_DISTANCE then
						local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
						if onScreen then
							local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
							if mouseDist < shortestDistance then
								shortestDistance = mouseDist
								closestHead = head
							end
						end
					end
				end
			end
		end
	end
	return closestHead
end

-- RenderStepped ép góc nhìn dính chặt vào mục tiêu ở từng frame
RunService.RenderStepped:Connect(function()
	local targetHead = nil
	
	if settings.aimNPC then
		targetHead = getAimTarget(false)
	elseif settings.aimPlayer then
		targetHead = getAimTarget(true)
	end

	if targetHead then
		-- Khóa cứng Camera về phía đầu mục tiêu
		Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
	end
end)
