local player = game.Players.LocalPlayer
local prefix = ":"
local flying = false
local flySpeed = 60
local infJumpEnabled = false
local bv, bg

-- УЛУЧШЕННЫЙ ПОЛЕТ (ВСЕ НАПРАВЛЕНИЯ)
local function toggleFly()
    flying = not flying
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local camera = workspace.CurrentCamera
    
    if flying then
        bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 9e4

        task.spawn(function()
            while flying and char:FindFirstChild("HumanoidRootPart") do
                local camCF = camera.CFrame
                -- Расчет направления на основе джойстика (вперед, назад, влево, вправо)
                local moveDir = (camCF.LookVector * (hum.MoveDirection.Z < 0 and 1 or (hum.MoveDirection.Z > 0 and -1 or 0)) + 
                                camCF.RightVector * (hum.MoveDirection.X > 0 and 1 or (hum.MoveDirection.X < 0 and -1 or 0)))
                
                if hum.MoveDirection.Magnitude > 0 then
                    bv.Velocity = moveDir.Unit * flySpeed
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
        if root:FindFirstChildOfClass("BodyVelocity") then root:FindFirstChildOfClass("BodyVelocity"):Destroy() end
        if root:FindFirstChildOfClass("BodyGyro") then root:FindFirstChildOfClass("BodyGyro"):Destroy() end
    end
end

-- СОЗДАНИЕ ИНТЕРФЕЙСА (GUI)
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Frame = Instance.new("Frame", sg)
local Toggle = Instance.new("TextButton", sg)

Frame.Size = UDim2.new(0, 220, 0, 380) 
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

-- КНОПКИ МЕНЮ
CreateButton("Fly (Omni-Directional)", UDim2.new(0.05, 0, 0.05, 0), Color3.fromRGB(60, 60, 60), toggleFly)
local jumpBtn = CreateButton("Inf Jump: OFF", UDim2.new(0.05, 0, 0.18, 0), Color3.fromRGB(50, 50, 50), function() infJumpEnabled = not infJumpEnabled end)
CreateButton("Enable ESP", UDim2.new(0.05, 0, 0.31, 0), Color3.fromRGB(50, 50, 50), function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character then 
            local h = Instance.new("Highlight", p.Character)
            h.FillColor = Color3.fromRGB(255, 0, 0)
        end
    end
end)
CreateButton("Noclip", UDim2.new(0.05, 0, 0.44, 0), Color3.fromRGB(50, 50, 50), function()
    game:GetService("RunService").Stepped:Connect(function()
        if player.Character then 
            for _, v in pairs(player.Character:GetDescendants()) do 
                if v:IsA("BasePart") then v.CanCollide = false end 
            end 
        end
    end)
end)
CreateButton("Speed (100)", UDim2.new(0.05, 0, 0.57, 0), Color3.fromRGB(50, 50, 50), function()
    if player.Character then player.Character.Humanoid.WalkSpeed = 100 end
end)
CreateButton("RESET CHARACTER", UDim2.new(0.05, 0, 0.85, 0), Color3.fromRGB(150, 50, 50), function()
    if player.Character then player.Character:BreakJoints() end
end)

-- КОМАНДЫ ЧАТА
player.Chatted:Connect(function(msg)
    local args = string.split(msg, " ")
    local cmd = args[1]:lower()
    if cmd == prefix .. "fly" then toggleFly()
    elseif cmd == prefix .. "speed" then player.Character.Humanoid.WalkSpeed = tonumber(args[2])
    elseif cmd == prefix .. "jump" then player.Character.Humanoid.JumpPower = tonumber(args[2])
    elseif cmd == prefix .. "re" then player.Character:BreakJoints() end
end)

-- ОБРАБОТКА ПРЫЖКА И ТЕКСТА
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJumpEnabled and player.Character then 
        local h = player.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState("Jumping") end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        jumpBtn.Text = infJumpEnabled and "Inf Jump: ON" or "Inf Jump: OFF"
        jumpBtn.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    end
end)
