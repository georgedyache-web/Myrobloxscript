local player = game.Players.LocalPlayer
local prefix = ":"
local flying = false
local flySpeed = 60
local infJumpEnabled = false
local spectating = false
local spectateIndex = 1

-- 1. [FLY] - ПОЛЕТ (Идеальные углы, все направления)
local function toggleFly()
    flying = not flying
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local camera = workspace.CurrentCamera
    
    if flying then
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        local bg = Instance.new("BodyGyro", root)
        bg.Name = "FlyGyro"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 9e4

        task.spawn(function()
            while flying and char:FindFirstChild("HumanoidRootPart") do
                local moveDir = hum.MoveDirection
                local camCF = camera.CFrame
                if moveDir.Magnitude > 0 then
                    local direction = (camCF.LookVector * -moveDir.Z) + (camCF.RightVector * moveDir.X)
                    bv.Velocity = direction.Unit * flySpeed
                else
                    bv.Velocity = Vector3.new(0, 0.1, 0)
                end
                bg.CFrame = camCF
                task.wait()
            end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end)
    else
        if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
        if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end
    end
end

-- 2. [SPECTATE] - СЛЕЖКА ЗА ЛЮДЬМИ
local function toggleSpectate()
    spectating = not spectating
    local camera = workspace.CurrentCamera
    if spectating then
        local targetPlayers = {}
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player then table.insert(targetPlayers, p) end
        end
        if #targetPlayers > 0 then
            camera.CameraSubject = targetPlayers[1].Character.Humanoid
            print("Следим за: " .. targetPlayers[1].Name)
        end
    else
        camera.CameraSubject = player.Character.Humanoid
    end
end

-- [ИНТЕРФЕЙС GUI]
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Frame = Instance.new("Frame", sg)
local Toggle = Instance.new("TextButton", sg)

Frame.Size = UDim2.new(0, 220, 0, 420) 
Frame.Position = UDim2.new(0.5, -110, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame)

Toggle.Size = UDim2.new(0, 50, 0, 50)
Toggle.Position = UDim2.new(0, 10, 0.5, -25)
Toggle.Text = "Open"
Toggle.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)
Toggle.MouseButton1Click:Connect(function() Frame.Visible = not Frame.Visible end)

local function CreateButton(text, pos, color, func)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(func)
    return btn
end

-- КНОПКИ ФУНКЦИЙ
CreateButton("FLY (Летать везде)", UDim2.new(0.05, 0, 0.05, 0), Color3.fromRGB(60, 60, 60), toggleFly)

local jumpBtn = CreateButton("INF JUMP (Прыжки)", UDim2.new(0.05, 0, 0.16, 0), Color3.fromRGB(50, 50, 50), function() 
    infJumpEnabled = not infJumpEnabled 
end)

CreateButton("NOCLIP (Сквозь стены)", UDim2.new(0.05, 0, 0.27, 0), Color3.fromRGB(50, 50, 50), function()
    game:GetService("RunService").Stepped:Connect(function()
        if player.Character then 
            for _, v in pairs(player.Character:GetDescendants()) do 
                if v:IsA("BasePart") then v.CanCollide = false end 
            end 
        end
    end)
end)

CreateButton("SPECTATE (Слежка)", UDim2.new(0.05, 0, 0.38, 0), Color3.fromRGB(0, 100, 200), toggleSpectate)

CreateButton("ESP (Подсветка)", UDim2.new(0.05, 0, 0.49, 0), Color3.fromRGB(50, 50, 50), function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character then 
            local h = Instance.new("Highlight", p.Character)
            h.FillColor = Color3.fromRGB(255, 0, 0)
        end
    end
end)

CreateButton("SPEED 100", UDim2.new(0.05, 0, 0.60, 0), Color3.fromRGB(50, 50, 50), function()
    if player.Character then player.Character.Humanoid.WalkSpeed = 100 end
end)

CreateButton("RESET", UDim2.new(0.05, 0, 0.85, 0), Color3.fromRGB(150, 50, 50), function()
    if player.Character then player.Character:BreakJoints() end
end)

-- 3. [INF JUMP] - ОБРАБОТКА БЕСКОНЕЧНОГО ПРЫЖКА
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJumpEnabled and player.Character then 
        local h = player.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState("Jumping") end
    end
end)

-- [ЧАТ КОМАНДЫ]
player.Chatted:Connect(function(msg)
    local args = string.split(msg, " ")
    local cmd = args[1]:lower()
    if cmd == prefix .. "fly" then toggleFly()
    elseif cmd == prefix .. "re" then player.Character:BreakJoints() end
end)

-- Обновление текста кнопок прыжка
task.spawn(function()
    while task.wait(0.5) do
        jumpBtn.Text = infJumpEnabled and "Inf Jump: ON" or "Inf Jump: OFF"
        jumpBtn.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    end
end)
