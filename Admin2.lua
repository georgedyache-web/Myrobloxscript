local player = game.Players.LocalPlayer
local prefix = ":"
local flying = false
local flySpeed = 50
local infJumpEnabled = false
local bv, bg

-- Функция управления полетом
local function toggleFly()
    flying = not flying
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    
    if flying then
        bv = Instance.new("BodyVelocity", root)
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        bg = Instance.new("BodyGyro", root)
        bg.Name = "FlyGyro"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 9e4

        task.spawn(function()
            while flying and char:FindFirstChild("HumanoidRootPart") do
                local moveDir = char:WaitForChild("Humanoid").MoveDirection
                if moveDir.Magnitude > 0 then
                    bv.Velocity = camera.CFrame.LookVector * flySpeed
                else
                    bv.Velocity = Vector3.new(0, 0.1, 0)
                end
                bg.CFrame = camera.CFrame
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

-- Интерфейс (GUI)
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Frame = Instance.new("Frame", sg)
local Toggle = Instance.new("TextButton", sg)

Frame.Size = UDim2.new(0, 220, 0, 380) 
Frame.Position = UDim2.new(0.5, -110, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame)

Toggle.Size = UDim2.new(0, 45, 0, 45)
Toggle.Position = UDim2.new(0, 10, 0.5, -22)
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

-- Кнопки в меню
CreateButton("Fly (Camera)", UDim2.new(0.05, 0, 0.05, 0), Color3.fromRGB(50, 50, 50), toggleFly)

local jumpBtn = CreateButton("Inf Jump: OFF", UDim2.new(0.05, 0, 0.18, 0), Color3.fromRGB(50, 50, 50), function()
    infJumpEnabled = not infJumpEnabled
end)

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

CreateButton("RESET", UDim2.new(0.05, 0, 0.85, 0), Color3.fromRGB(150, 50, 50), function()
    player.Character:BreakJoints()
end)

-- Обработка бесконечного прыжка
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJumpEnabled and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

-- ОБРАБОТЧИК ЧАТА (Команды)
player.Chatted:Connect(function(msg)
    local args = string.split(msg, " ")
    local cmd = args[1]:lower()

    if cmd == prefix .. "fly" then
        toggleFly()
    elseif cmd == prefix .. "speed" then
        local s = tonumber(args[2])
        if s and player.Character then player.Character.Humanoid.WalkSpeed = s end
    elseif cmd == prefix .. "jump" then
        local j = tonumber(args[2])
        if j and player.Character then 
            player.Character.Humanoid.JumpPower = j
            player.Character.Humanoid.UseJumpPower = true
        end
    elseif cmd == prefix .. "re" then
        if player.Character then player.Character:BreakJoints() end
    end
end)

-- Обновление текста кнопок
task.spawn(function()
    while task.wait(0.5) do
        jumpBtn.Text = infJumpEnabled and "Inf Jump: ON" or "Inf Jump: OFF"
        jumpBtn.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    end
end)
