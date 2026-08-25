-- Name: ScarletRomen (Fixed Skill 2 & Responsive GUI Edition)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local CFG = {
	THEME = Color3.fromRGB(255, 30, 30),
	NPC = Color3.fromRGB(255, 215, 0),
	NPC2D = Color3.fromRGB(0, 150, 255),
	PLR = Color3.fromRGB(255, 40, 40),
	MY_BODY = Color3.fromRGB(170, 0, 255),
	NAME = Color3.fromRGB(0, 170, 255),
	STROKE = Color3.fromRGB(0, 40, 120)
}

local S = {
	AimNPC = false, 
	AimPlr = false, 
	AimPlrWall = false, 
	Aim2D = false, 
	EspNPC = false, 
	EspNPC2D = false, 
	EspPlr = false, 
	EspName = false, 
	Fps = false, 
	Bright = false, 
	Ultra = false, 
	Target = nil
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

-- HÀM KÉO THẢ DRAG & DROP TỐI ƯU CHO TOUCH MOBILE
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

-- HỒNG TÂM MỎNG & CĂN CHÍNH GIỮA MÀN HÌNH
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

-- LOGO DRAGGABLE (ĐÃ PHÓNG TO 50PX & CÁCH LỀ ĐIỆN THOẠI)
local Logo = Instance.new("Frame", SG) 
Logo.Size = UDim2.new(0, 50, 0, 50)
Logo.Position = UDim2.new(0, 20, 0.25, 0)
Logo.BackgroundColor3 = Color3.fromRGB(15, 15, 15) 
makeDraggable(Logo)
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 10)
local LSt = Instance.new("UIStroke", Logo) LSt.Color, LSt.Thickness = CFG.THEME, 2

local LogoBtn = Instance.new("TextButton", Logo) 
LogoBtn.Size, LogoBtn.BackgroundTransparency, LogoBtn.Text, LogoBtn.TextColor3, LogoBtn.Font, LogoBtn.TextSize = UDim2.new(1, 0, 1, 0), 1, "S", CFG.THEME, Enum.Font.SourceSansBold, 24

-- MAIN UI
local Main = Instance.new("Frame", SG) 
Main.Size, Main.Position, Main.BackgroundColor3 = UDim2.new(0, 210, 0, 130), UDim2.new(0, 80, 0.25, 0), Color3.fromRGB(15, 15, 15) 
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

local Footer = Instance.new("TextLabel", Main)
Footer.Size, Footer.Position, Footer.BackgroundTransparency, Footer.Text, Footer.TextColor3, Footer.Font, Footer.TextSize = UDim2.new(1, 0, 0, 12), UDim2.new(0, 0, 1, -12), 1, "by: Scarlet Romen", Color3.fromRGB(150,150,150), Enum.Font.SourceSansItalic, 9

----------------------------------------------------------------
-- TAB SYSTEM (FIX ĐÓNG MỞ TAB)
----------------------------------------------------------------
local function createTabHeader(title, layoutOrder)
	local btn = Instance.new("TextButton", MainScroll)
	btn.Size = UDim2.new(1, -6, 0, 24)
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	btn.Text = "  " .. title .. " [ + ]"
	btn.TextColor3 = Color3.fromRGB(220, 220, 220)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 11
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.LayoutOrder = layoutOrder

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
	local st = Instance.new("UIStroke", btn) st.Color = CFG.THEME st.Thickness = 1

	local container = Instance.new("Frame", MainScroll)
	container.Size = UDim2.new(1, -6, 0, 0)
	container.BackgroundTransparency = 1
	container.Visible = false
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.LayoutOrder = layoutOrder + 1

	local cLayout = Instance.new("UIListLayout", container)
	cLayout.Padding = UDim.new(0, 3)
	cLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local open = false
	btn.MouseButton1Click:Connect(function()
		open = not open
		container.Visible = open
		btn.Text = "  " .. title .. (open and " [ - ]" or " [ + ]")
		btn.BackgroundColor3 = open and CFG.THEME or Color3.fromRGB(25, 25, 25)
	end)

	return container
end

local T1Container = createTabHeader("Vision", 1)
local T2Container = createTabHeader("Liminal", 3)

----------------------------------------------------------------
-- LOGICS & TARGET FINDERS
----------------------------------------------------------------
local function isNPC(m)
	return m and m:IsA("Model") and not Players:GetPlayerFromCharacter(m) and m:FindFirstChildOfClass("Humanoid") and m:FindFirstChildOfClass("Humanoid").Health > 0 and (m:FindFirstChild("Head") or m.PrimaryPart)
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

local function getMyPos()
	local char = LocalPlayer.Character
	if char then
		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head") or char.PrimaryPart
		if root then return root.Position end
	end
	return Camera.CFrame.Position
end

-- FIX LỖI SKILL 2 (RAYCAST CHECK TƯỜNG CHUẨN XÁC)
local function isVisible(targetHeadPos, targetModel)
	local origin = Camera.CFrame.Position
	local direction = targetHeadPos - origin
	local params = RaycastParams.new()
	params.FilterType = RaycastFilterType.Exclude

	local ignoreList = {}
	if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
	-- Loại bỏ các phần tử không có va chạm vật lý
	for _, item in ipairs(Workspace:GetDescendants()) do
		if item:IsA("BasePart") and not item.CanCollide then
			table.insert(ignoreList, item)
		end
	end
	params.FilterDescendantsInstances = ignoreList

	local result = Workspace:Raycast(origin, direction, params)
	if result then
		return result.Instance:IsDescendantOf(targetModel)
	end
	return true
end

local function getClosestByRange(chkFunc, checkWall)
	local cl, sDist = nil, math.huge
	local myPos = getMyPos()

	for _, v in ipairs(Workspace:GetDescendants()) do
		if chkFunc(v) then
			local p = getHeadPos(v)
			if p then
				local dist = (p - myPos).Magnitude
				if dist < sDist then
					if not checkWall or isVisible(p, v) then
						sDist = dist
						cl = v
					end
				end
			end
		end
	end
	return cl
end

local function createSkillButton(parent, text, cb)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1, 0, 0, 24)
	b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	b.Text = text .. ": OFF"
	b.TextColor3 = Color3.fromRGB(200, 200, 200)
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 10

	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	b.MouseButton1Click:Connect(function()
		local st = cb()
		b.Text = text .. (st and ": ON" or ": OFF")
		b.BackgroundColor3 = st and CFG.THEME or Color3.fromRGB(35, 35, 35)
	end)
	return b
end

----------------------------------------------------------------
-- SKILLS REGISTER
----------------------------------------------------------------
-- TAB 1: VISION
createSkillButton(T1Container, "Skill 1 (Aim NPC Range)", function()
	S.AimNPC = not S.AimNPC S.AimPlr, S.AimPlrWall, S.Aim2D = false, false, false
	return S.AimNPC
end)

createSkillButton(T1Container, "Skill 2 (Aim Plr Visible)", function()
	S.AimPlr = not S.AimPlr S.AimNPC, S.AimPlrWall, S.Aim2D = false, false, false
	return S.AimPlr
end)

local RainbowBtn = createSkillButton(T1Container, "Skill 2.5 (Aim Plr Wall)", function()
	S.AimPlrWall = not S.AimPlrWall S.AimNPC, S.AimPlr, S.Aim2D = false, false, false
	return S.AimPlrWall
end)

createSkillButton(T1Container, "Skill 3 (ESP NPC)", function()
	S.EspNPC = not S.EspNPC
	for _, v in ipairs(Workspace:GetDescendants()) do if isNPC(v) then toggleHL(v, CFG.NPC, "SR_NPC", S.EspNPC) end end
	return S.EspNPC
end)

createSkillButton(T1Container, "Skill 4 (ESP Player)", function()
	S.EspPlr = not S.EspPlr
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			if p == LocalPlayer then
				toggleHL(p.Character, CFG.MY_BODY, "SR_MY_ESP", S.EspPlr, 0.7)
			else
				toggleHL(p.Character, CFG.PLR, "SR_PLR", S.EspPlr, 0.5)
			end
		end
	end
	return S.EspPlr
end)

createSkillButton(T1Container, "Skill 5 (Aim NPC 2D)", function()
	S.Aim2D = not S.Aim2D S.AimNPC, S.AimPlr, S.AimPlrWall = false, false, false
	return S.Aim2D
end)

createSkillButton(T1Container, "Skill 6 (ESP NPC 2D)", function()
	S.EspNPC2D = not S.EspNPC2D
	for _, v in ipairs(Workspace:GetDescendants()) do
		if is2DNPC(v) then
			local targetObj = (v:IsA("Model") or v:IsA("BasePart")) and v or v.Parent
			if targetObj then toggleHL(targetObj, CFG.NPC2D, "SR_NPC2D", S.EspNPC2D) end
		end
	end
	return S.EspNPC2D
end)

-- TAB 2: LIMINAL
createSkillButton(T2Container, "Skill 1 (ESP Name Player)", function() S.EspName = not S.EspName return S.EspName end)
createSkillButton(T2Container, "Skill 2 (FPS Booster)", function() S.Fps = not S.Fps settings().Rendering.QualityLevel, Lighting.GlobalShadows = S.Fps and 1 or 7, not S.Fps return S.Fps end)
createSkillButton(T2Container, "Skill 3 (Full Bright)", function() S.Bright = not S.Bright Lighting.FogEnd, Lighting.Brightness = S.Bright and 9e9 or 1000, S.Bright and 2 or 1 return S.Bright end)
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
end)

----------------------------------------------------------------
-- RENDER LOOP (CẦU VỒNG + AIM REALTIME)
----------------------------------------------------------------
local frames, lastT = 0, tick()
local hue = 0

RunService.RenderStepped:Connect(function()
	frames = frames + 1
	if tick() - lastT >= 1 then FPSLbl.Text = "FPS: " .. frames frames, lastT = 0, tick() end

	-- Rainbow cho Skill 2.5
	if S.AimPlrWall then
		hue = (hue + 0.005) % 1
		RainbowBtn.BackgroundColor3 = Color3.fromHSV(hue, 0.8, 1)
		RainbowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		RainbowBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	end

	local checkPlrFunc = function(v)
		return v:IsA("Model") and Players:GetPlayerFromCharacter(v) and v ~= LocalPlayer.Character and v:FindFirstChildOfClass("Humanoid") and v:FindFirstChildOfClass("Humanoid").Health > 0
	end

	if S.AimNPC then
		S.Target = getClosestByRange(isNPC, false)
	elseif S.AimPlr then
		S.Target = getClosestByRange(checkPlrFunc, true)
	elseif S.AimPlrWall then
		S.Target = getClosestByRange(checkPlrFunc, false)
	elseif S.Aim2D then
		S.Target = getClosestByRange(is2DNPC, false)
	else
		S.Target = nil
	end

	if S.Target then
		local p = getHeadPos(S.Target)
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
