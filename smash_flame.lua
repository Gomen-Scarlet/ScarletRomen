-- Name: ScarletRomen (Vertical Collapsible Tabs Edition)
local P, RS, WS, UIS, L = game:GetService("Players"), game:GetService("RunService"), game:GetService("Workspace"), game:GetService("UserInputService"), game:GetService("Lighting")
local LP, Cam = P.LocalPlayer, WS.CurrentCamera
local CFG = {THEME = Color3.fromRGB(255, 30, 30), NPC = Color3.fromRGB(255, 215, 0), PLR = Color3.fromRGB(255, 40, 40), NAME = Color3.fromRGB(0, 170, 255), STROKE = Color3.fromRGB(0, 40, 120)}
local S = {AimNPC=false, AimPlr=false, Aim2D=false, EspNPC=false, EspPlr=false, EspName=false, Fps=false, Bright=false, Ultra=false, Target=nil}

local SG = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui")) SG.ResetOnSpawn = false

local function drag(o)
	local d, i, s, p
	o.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then d, s, p = true, inp.Position, o.Position end end)
	UIS.InputChanged:Connect(function(inp) if d and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then local delta = inp.Position - s o.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end)
	UIS.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then d = false end end)
end

-- 1. FIX HỒNG TÂM CHUẨN TÂM MÀN HÌNH
local Cross = Instance.new("Frame", SG)
Cross.Name = "Crosshair"
Cross.Size = UDim2.fromOffset(14, 14)
Cross.AnchorPoint = Vector2.new(0.5, 0.5)
Cross.Position = UDim2.fromScale(0.5, 0.5)
Cross.BackgroundTransparency = 1

local H = Instance.new("Frame", Cross) H.Size, H.Position, H.BackgroundColor3, H.BorderSizePixel = UDim2.new(1, 0, 0, 2), UDim2.new(0, 0, 0.5, -1), Color3.fromRGB(180,180,180), 0
local V = Instance.new("Frame", Cross) V.Size, V.Position, V.BackgroundColor3, V.BorderSizePixel = UDim2.new(0, 2, 1, 0), UDim2.new(0.5, -1, 0, 0), Color3.fromRGB(180,180,180), 0

local FPSLbl = Instance.new("TextLabel", SG) FPSLbl.Size, FPSLbl.Position, FPSLbl.BackgroundTransparency, FPSLbl.TextColor3, FPSLbl.Font, FPSLbl.Visible = UDim2.new(0, 100, 0, 20), UDim2.new(0, 10, 0, 10), 1, Color3.fromRGB(0,255,150), Enum.Font.SourceSansBold, false

-- 2. LOGO
local Logo = Instance.new("Frame", SG) Logo.Size, Logo.Position, Logo.BackgroundColor3 = UDim2.new(0, 44, 0, 44), UDim2.new(0.05, 0, 0.2, 0), Color3.fromRGB(15, 15, 15) drag(Logo)
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 8) local LSt = Instance.new("UIStroke", Logo) LSt.Color, LSt.Thickness = CFG.THEME, 2
local LogoBtn = Instance.new("TextButton", Logo) LogoBtn.Size, LogoBtn.BackgroundTransparency, LogoBtn.Text, LogoBtn.TextColor3, LogoBtn.Font, LogoBtn.TextSize = UDim2.new(1, 0, 1, 0), 1, "S", CFG.THEME, Enum.Font.SourceSansBold, 22

-- 3. MAIN UI (TAB NẰM DỌC CHỒNG NHAU)
local Main = Instance.new("Frame", SG) Main.Size, Main.Position, Main.BackgroundColor3 = UDim2.new(0, 220, 0, 260), UDim2.new(0.12, 0, 0.2, 0), Color3.fromRGB(15, 15, 15) drag(Main)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10) local MSt = Instance.new("UIStroke", Main) MSt.Color, MSt.Thickness = CFG.THEME, 2
LogoBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- Scrolling Container Chứa Toàn Bộ Nội Dung
local MainScroll = Instance.new("ScrollingFrame", Main)
MainScroll.Size, MainScroll.Position, MainScroll.BackgroundTransparency, MainScroll.ScrollBarThickness = UDim2.new(1, -8, 1, -24), UDim2.new(0, 4, 0, 6), 1, 3
MainScroll.ScrollBarImageColor3 = CFG.THEME
MainScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
MainScroll.CanvasSize = UDim2.new(0,0,0,0)

local MainLayout = Instance.new("UIListLayout", MainScroll)
MainLayout.Padding = UDim.new(0, 6)
MainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
MainLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Footer = Instance.new("TextLabel", Main)
Footer.Size, Footer.Position, Footer.BackgroundTransparency, Footer.Text, Footer.TextColor3, Footer.Font, Footer.TextSize = UDim2.new(1, 0, 0, 16), UDim2.new(0, 0, 1, -18), 1, "by: Scarlet Romen", Color3.fromRGB(150,150,150), Enum.Font.SourceSansItalic, 10

----------------------------------------------------------------
-- CẤU TRÚC TAB DỌC COLLAPSIBLE
----------------------------------------------------------------
local function createTabHeader(title, layoutOrder)
	local btn = Instance.new("TextButton", MainScroll)
	btn.Size = UDim2.new(1, -8, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	btn.Text = "  " .. title .. " [ + ]"
	btn.TextColor3 = Color3.fromRGB(220, 220, 220)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 13
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.LayoutOrder = layoutOrder

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	local st = Instance.new("UIStroke", btn)
	st.Color = CFG.THEME
	st.Thickness = 1

	local container = Instance.new("Frame", MainScroll)
	container.Size = UDim2.new(1, -8, 0, 0)
	container.BackgroundTransparency = 1
	container.Visible = false
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.LayoutOrder = layoutOrder + 1

	local cLayout = Instance.new("UIListLayout", container)
	cLayout.Padding = UDim.new(0, 4)
	cLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local open = false
	btn.MouseButton1Click:Connect(function()
		open = not open
		container.Visible = open
		btn.Text = "  " .. title .. (open and " [ - ]" or " [ + ]")
		btn.BackgroundColor3 = open and CFG.THEME or Color3.fromRGB(25, 25, 25)
		btn.TextColor3 = open and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 220, 220)
	end)

	return container
end

local T1Container = createTabHeader("Vision", 1)
local T2Container = createTabHeader("Liminal", 3)

----------------------------------------------------------------
-- HELPER & CHECK LOGIC
----------------------------------------------------------------
local function isNPC(m) return m and m:IsA("Model") and not P:GetPlayerFromCharacter(m) and m:FindFirstChildOfClass("Humanoid") and m:FindFirstChildOfClass("Humanoid").Health > 0 and (m:FindFirstChild("Head") or m.PrimaryPart) end
local function is2DNPC(o)
	if not o or P:GetPlayerFromCharacter(o) then return false end
	local n = string.lower(o.Name)
	for _, w in ipairs({"wall", "tuong", "part", "baseplate", "building", "floor", "block", "mesh", "roof"}) do if string.find(n, w) then return false end end
	return o:IsA("Decal") or o:IsA("Texture") or o:IsA("BillboardGui")
end

local function getPos(o) return o:IsA("BasePart") and o.Position or (o:IsA("Model") and (o.PrimaryPart and o.PrimaryPart.Position or o:GetPivot().Position)) or (o.Parent and o.Parent:IsA("BasePart") and o.Parent.Position) end

local function toggleHL(m, color, name, on)
	local h = m:FindFirstChild(name)
	if on then
		if not h then h = Instance.new("Highlight", m) h.Name = name h.FillTransparency = 0.5 h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end
		h.FillColor = color
	elseif h then h:Destroy() end
end

local function getClosest(chkFunc)
	local cl, sDist, cntr = nil, math.huge, Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
	for _, v in ipairs(WS:GetDescendants()) do
		if chkFunc(v) then
			local p = getPos(v)
			if p then
				local sp, onS = Cam:WorldToViewportPoint(p)
				if onS then
					local d = (Vector2.new(sp.X, sp.Y) - cntr).Magnitude
					if d < sDist then sDist, cl = d, v end
				end
			end
		end
	end
	return cl
end

local function createSkillButton(parent, text, cb)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1, 0, 0, 30)
	b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	b.Text = text .. ": OFF"
	b.TextColor3 = Color3.fromRGB(200, 200, 200)
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 12

	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	b.MouseButton1Click:Connect(function()
		local st = cb()
		b.Text = text .. (st and ": ON" or ": OFF")
		b.BackgroundColor3 = st and CFG.THEME or Color3.fromRGB(35, 35, 35)
		b.TextColor3 = st and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
	end)
end

----------------------------------------------------------------
-- SKILLS REGISTER
----------------------------------------------------------------
-- TAB 1: VISION
createSkillButton(T1Container, "Skill 1 (Aim NPC)", function() S.AimNPC = not S.AimNPC S.AimPlr, S.Aim2D = false, false S.Target = S.AimNPC and getClosest(isNPC) or nil return S.AimNPC end)
createSkillButton(T1Container, "Skill 2 (Aim Player)", function() S.AimPlr = not S.AimPlr S.AimNPC, S.Aim2D = false, false S.Target = S.AimPlr and getClosest(function(v) return v:IsA("Model") and P:GetPlayerFromCharacter(v) and v ~= LP.Character end) or nil return S.AimPlr end)
createSkillButton(T1Container, "Skill 3 (ESP NPC)", function() S.EspNPC = not S.EspNPC for _, v in ipairs(WS:GetDescendants()) do if isNPC(v) then toggleHL(v, CFG.NPC, "SR_NPC", S.EspNPC) end end return S.EspNPC end)
createSkillButton(T1Container, "Skill 4 (ESP Player)", function() S.EspPlr = not S.EspPlr for _, p in ipairs(P:GetPlayers()) do if p ~= LP and p.Character then toggleHL(p.Character, CFG.PLR, "SR_PLR", S.EspPlr) end end return S.EspPlr end)
createSkillButton(T1Container, "Skill 5 (Aim NPC 2D)", function() S.Aim2D = not S.Aim2D S.AimNPC, S.AimPlr = false, false S.Target = S.Aim2D and getClosest(is2DNPC) or nil return S.Aim2D end)

-- TAB 2: LIMINAL (ESP NAME NÂNG CẤP CHỮ TO + LINE XANH ĐẬM + HP)
createSkillButton(T2Container, "Skill 1 (ESP Name Player)", function()
	S.EspName = not S.EspName
	return S.EspName
end)

createSkillButton(T2Container, "Skill 2 (FPS Booster)", function() S.Fps = not S.Fps settings().Rendering.QualityLevel, L.GlobalShadows = S.Fps and 1 or 7, not S.Fps return S.Fps end)
createSkillButton(T2Container, "Skill 3 (Full Bright)", function() S.Bright = not S.Bright L.FogEnd, L.Brightness = S.Bright and 9e9 or 1000, S.Bright and 2 or 1 return S.Bright end)
createSkillButton(T2Container, "Skill 4 (Ultra Liminal)", function()
	S.Ultra = not S.Ultra FPSLbl.Visible = S.Ultra
	if S.Ultra then
		Cam.MaxAxisFieldOfView = 40
		for _, v in ipairs(WS:GetDescendants()) do
			if v:IsA("BasePart") then v.Material, v.Color = Enum.Material.SmoothPlastic, Color3.fromRGB(120, 120, 120)
			elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Animator") then v:Destroy() end
		end
	end
	return S.Ultra
end)

----------------------------------------------------------------
-- RENDER LOOP (XỬ LÝ AIM & LỰA CHỌN CẬP NHẬT HP REALTIME)
----------------------------------------------------------------
local frames, lastT = 0, tick()
RS.RenderStepped:Connect(function()
	-- Cập nhật FPS
	frames = frames + 1
	if tick() - lastT >= 1 then FPSLbl.Text = "FPS: " .. frames frames, lastT = 0, tick() end

	-- Hard Lock Aim
	if (S.AimNPC or S.AimPlr or S.Aim2D) and S.Target then
		local p = getPos(S.Target)
		if p then Cam.CFrame = CFrame.lookAt(Cam.CFrame.Position, p) end
	end

	-- ESP Name realtime Cập nhật Máu
	if S.EspName then
		for _, p in ipairs(P:GetPlayers()) do
			if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
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
						lbl.TextStrokeColor3 = CFG.STROKE -- Viền xanh đậm
						lbl.TextStrokeTransparency = 0 -- Hiện viền chữ
						lbl.Font = Enum.Font.SourceSansBold
						lbl.TextSize = 18 -- Chữ to rõ hơn
					end
					tag.NameLabel.Text = p.Name .. "\n[" .. math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth) .. " HP]"
				elseif tag then
					tag:Destroy()
				end
			end
		end
	else
		for _, p in ipairs(P:GetPlayers()) do
			if p.Character and p.Character:FindFirstChild("Head") then
				local tag = p.Character.Head:FindFirstChild("SR_NameTag")
				if tag then tag:Destroy() end
			end
		end
	end
end)
