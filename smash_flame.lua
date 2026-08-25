-- ScarletRomen UI - Compact & Full Features
local P, RS, WS, UIS, L = game:GetService("Players"), game:GetService("RunService"), game:GetService("Workspace"), game:GetService("UserInputService"), game:GetService("Lighting")
local LP, Cam = P.LocalPlayer, WS.CurrentCamera
local CFG = {THEME = Color3.fromRGB(255, 30, 30), NPC = Color3.fromRGB(255, 215, 0), PLR = Color3.fromRGB(255, 40, 40), NAME = Color3.fromRGB(0, 170, 255)}
local S = {AimNPC=false, AimPlr=false, Aim2D=false, EspNPC=false, EspPlr=false, EspName=false, Fps=false, Bright=false, Ultra=false, Target=nil}

local SG = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui")) SG.ResetOnSpawn = false
local function drag(o)
	local d, i, s, p
	o.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then d, s, p = true, inp.Position, o.Position end end)
	UIS.InputChanged:Connect(function(inp) if d and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then local delta = inp.Position - s o.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end)
	UIS.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then d = false end end)
end

-- 1. HỒNG TÂM DẤU "+" FIX CHUẨN TÂM
local Cross = Instance.new("Frame", SG) Cross.Size, Cross.Position, Cross.AnchorPoint, Cross.BackgroundTransparency = UDim2.new(0, 15, 0, 15), UDim2.new(0.5, 0, 0.5, 0), Vector2.new(0.5, 0.5), 1
local H = Instance.new("Frame", Cross) H.Size, H.Position, H.BackgroundColor3, H.BorderSizePixel = UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0.5, 0), Color3.fromRGB(180,180,180), 0
local V = Instance.new("Frame", Cross) V.Size, V.Position, V.BackgroundColor3, V.BorderSizePixel = UDim2.new(0, 1, 1, 0), UDim2.new(0.5, 0, 0, 0), Color3.fromRGB(180,180,180), 0

local FPSLbl = Instance.new("TextLabel", SG) FPSLbl.Size, FPSLbl.Position, FPSLbl.BackgroundTransparency, FPSLbl.TextColor3, FPSLbl.Font, FPSLbl.Visible = UDim2.new(0, 100, 0, 20), UDim2.new(0, 10, 0, 10), 1, Color3.fromRGB(0,255,150), Enum.Font.SourceSansBold, false

-- 2. LOGO & MAIN FRAME (2 TABS)
local Logo = Instance.new("Frame", SG) Logo.Size, Logo.Position, Logo.BackgroundColor3 = UDim2.new(0, 44, 0, 44), UDim2.new(0.05, 0, 0.2, 0), Color3.fromRGB(15, 15, 15) drag(Logo)
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 8) local LSt = Instance.new("UIStroke", Logo) LSt.Color, LSt.Thickness = CFG.THEME, 2
local LogoBtn = Instance.new("TextButton", Logo) LogoBtn.Size, LogoBtn.BackgroundTransparency, LogoBtn.Text, LogoBtn.TextColor3, LogoBtn.Font, LogoBtn.TextSize = UDim2.new(1, 0, 1, 0), 1, "S", CFG.THEME, Enum.Font.SourceSansBold, 22

local Main = Instance.new("Frame", SG) Main.Size, Main.Position, Main.BackgroundColor3 = UDim2.new(0, 220, 0, 185), UDim2.new(0.12, 0, 0.2, 0), Color3.fromRGB(15, 15, 15) drag(Main)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8) local MSt = Instance.new("UIStroke", Main) MSt.Color, MSt.Thickness = CFG.THEME, 2
LogoBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

local Nav = Instance.new("Frame", Main) Nav.Size, Nav.BackgroundTransparency = UDim2.new(1, 0, 0, 28), 1
local T1Btn = Instance.new("TextButton", Nav) T1Btn.Size, T1Btn.Position, T1Btn.BackgroundColor3, T1Btn.Text, T1Btn.TextColor3, T1Btn.Font = UDim2.new(0.5, -2, 1, 0), UDim2.new(0, 2, 0, 0), CFG.THEME, "Vision", Color3.fromRGB(255,255,255), Enum.Font.SourceSansBold
local T2Btn = Instance.new("TextButton", Nav) T2Btn.Size, T2Btn.Position, T2Btn.BackgroundColor3, T2Btn.Text, T2Btn.TextColor3, T2Btn.Font = UDim2.new(0.5, -2, 1, 0), UDim2.new(0.5, 0, 0, 0), Color3.fromRGB(30,30,30), "Liminal", Color3.fromRGB(180,180,180), Enum.Font.SourceSansBold

local T1Frame = Instance.new("ScrollingFrame", Main) T1Frame.Size, T1Frame.Position, T1Frame.BackgroundTransparency, T1Frame.CanvasSize, T1Frame.ScrollBarThickness = UDim2.new(1, 0, 1, -46), UDim2.new(0, 0, 0, 30), 1, UDim2.new(0,0,0,180), 3 T1Frame.ScrollBarImageColor3 = CFG.THEME
local T2Frame = Instance.new("ScrollingFrame", Main) T2Frame.Size, T2Frame.Position, T2Frame.BackgroundTransparency, T2Frame.CanvasSize, T2Frame.ScrollBarThickness, T2Frame.Visible = UDim2.new(1, 0, 1, -46), UDim2.new(0, 0, 0, 30), 1, UDim2.new(0,0,0,150), 3, false T2Frame.ScrollBarImageColor3 = CFG.THEME
Instance.new("UIListLayout", T1Frame).Padding = UDim.new(0, 4) Instance.new("UIListLayout", T2Frame).Padding = UDim.new(0, 4)

local Footer = Instance.new("TextLabel", Main) Footer.Size, Footer.Position, Footer.BackgroundTransparency, Footer.Text, Footer.TextColor3, Footer.Font, Footer.TextSize = UDim2.new(1,0,0,14), UDim2.new(0,0,1,-14), 1, "by: Scarlet Romen", Color3.fromRGB(150,150,150), Enum.Font.SourceSansItalic, 10

T1Btn.MouseButton1Click:Connect(function() T1Frame.Visible, T2Frame.Visible = true, false T1Btn.BackgroundColor3, T2Btn.BackgroundColor3 = CFG.THEME, Color3.fromRGB(30,30,30) end)
T2Btn.MouseButton1Click:Connect(function() T1Frame.Visible, T2Frame.Visible = false, true T2Btn.BackgroundColor3, T1Btn.BackgroundColor3 = CFG.THEME, Color3.fromRGB(30,30,30) end)

----------------------------------------------------------------
-- LOGICS & TARGET FINDERS
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

----------------------------------------------------------------
-- BUTTON CREATOR
----------------------------------------------------------------
local function addBtn(parent, text, cb)
	local b = Instance.new("TextButton", parent) b.Size, b.BackgroundColor3, b.Text, b.TextColor3, b.Font, b.TextSize = UDim2.new(0, 190, 0, 30), Color3.fromRGB(30, 30, 30), text..": OFF", Color3.fromRGB(200, 200, 200), Enum.Font.SourceSansBold, 12
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
	b.MouseButton1Click:Connect(function()
		local st = cb()
		b.Text = text .. (st and ": ON" or ": OFF")
		b.BackgroundColor3 = st and CFG.THEME or Color3.fromRGB(30, 30, 30)
	end)
end

-- TAB 1 SKILLS
addBtn(T1Frame, "Skill 1 (Aim NPC)", function() S.AimNPC = not S.AimNPC S.AimPlr, S.Aim2D = false, false S.Target = S.AimNPC and getClosest(isNPC) or nil return S.AimNPC end)
addBtn(T1Frame, "Skill 2 (Aim Player)", function() S.AimPlr = not S.AimPlr S.AimNPC, S.Aim2D = false, false S.Target = S.AimPlr and getClosest(function(v) return v:IsA("Model") and P:GetPlayerFromCharacter(v) and v ~= LP.Character end) or nil return S.AimPlr end)
addBtn(T1Frame, "Skill 3 (ESP NPC)", function() S.EspNPC = not S.EspNPC for _, v in ipairs(WS:GetDescendants()) do if isNPC(v) then toggleHL(v, CFG.NPC, "SR_NPC", S.EspNPC) end end return S.EspNPC end)
addBtn(T1Frame, "Skill 4 (ESP Player)", function() S.EspPlr = not S.EspPlr for _, p in ipairs(P:GetPlayers()) do if p ~= LP and p.Character then toggleHL(p.Character, CFG.PLR, "SR_PLR", S.EspPlr) end end return S.EspPlr end)
addBtn(T1Frame, "Skill 5 (Aim NPC 2D)", function() S.Aim2D = not S.Aim2D S.AimNPC, S.AimPlr = false, false S.Target = S.Aim2D and getClosest(is2DNPC) or nil return S.Aim2D end)

-- TAB 2 SKILLS
addBtn(T2Frame, "Skill 1 (ESP Name)", function()
	S.EspName = not S.EspName
	for _, p in ipairs(P:GetPlayers()) do
		if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
			local tag = p.Character.Head:FindFirstChild("SR_Name")
			if S.EspName and not tag then
				tag = Instance.new("BillboardGui", p.Character.Head) tag.Name, tag.Size, tag.StudsOffset, tag.AlwaysOnTop = "SR_Name", UDim2.new(0, 100, 0, 30), Vector3.new(0, 2, 0), true
				local l = Instance.new("TextLabel", tag) l.Size, l.BackgroundTransparency, l.Text, l.TextColor3, l.Font = UDim2.new(1,0,1,0), 1, p.Name, CFG.NAME, Enum.Font.SourceSansBold
			elseif not S.EspName and tag then tag:Destroy() end
		end
	end
	return S.EspName
end)

addBtn(T2Frame, "Skill 2 (FPS Booster)", function() S.Fps = not S.Fps settings().Rendering.QualityLevel, L.GlobalShadows = S.Fps and 1 or 7, not S.Fps return S.Fps end)
addBtn(T2Frame, "Skill 3 (Full Bright)", function() S.Bright = not S.Bright L.FogEnd, L.Brightness = S.Bright and 9e9 or 1000, S.Bright and 2 or 1 return S.Bright end)
addBtn(T2Frame, "Skill 4 (Ultra Liminal)", function()
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
-- RENDER LOOP
----------------------------------------------------------------
local frames, lastT = 0, tick()
RS.RenderStepped:Connect(function()
	frames = frames + 1
	if tick() - lastT >= 1 then FPSLbl.Text = "FPS: " .. frames frames, lastT = 0, tick() end

	if (S.AimNPC or S.AimPlr or S.Aim2D) and S.Target then
		local p = getPos(S.Target)
		if p then Cam.CFrame = CFrame.lookAt(Cam.CFrame.Position, p) end
	end
end)
