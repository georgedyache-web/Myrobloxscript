local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Frame = Instance.new("Frame", sg)
local Toggle = Instance.new("TextButton", sg)

-- Настройка окна (увеличил высоту для новых кнопок)
Frame.Size = UDim2.new(0, 220, 0, 420) 
Frame.Position = UDim2.new(0.5, -110, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame)

-- Кнопка сворачивания
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
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(func)
    return btn
end

-- 1. Бесконечный прыжок
local infJumpEnabled = false
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJumpEnabled then game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
end)
local jumpBtn = CreateButton("Inf Jump: OFF", UDim2.new(0.05, 0, 0.05, 0), Color3.fromRGB(50, 50, 50), function()
    infJumpEnabled = not infJumpEnabled
end)

-- 2. ESP
CreateButton("Enable ESP", UDim2.new(0.05, 0, 0.16, 0), Color3.fromRGB(50, 50, 50), function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            local h = Instance.new("Highlight", p.Character)
            h.FillColor = Color3.fromRGB(255, 0, 0)
        end
    end
end)

-- 3. Скорость
CreateButton("Speed (100)", UDim2.new(0.05, 0, 0.27, 0), Color3.fromRGB(50, 50, 50), function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
end)

-- 4. Полет (Fly) - удерживает в воздухе
local flying = false
CreateButton("Fly (Toggle)", UDim2.new(0.05, 0, 0.38, 0), Color3.fromRGB(50, 50, 50), function()
    flying = not flying
    local char = game.Players.LocalPlayer.Character.HumanoidRootPart
    local bv = char:FindFirstChild("FlyBV") or Instance.new("BodyVelocity", char)
    bv.Name = "FlyBV"
    if flying then
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
    else
        bv:Destroy()
    end
end)

-- 5. Noclip
CreateButton("Noclip", UDim2.new(0.05, 0, 0.49, 0), Color3.fromRGB(50, 50, 50), function()
    game:GetService("RunService").Stepped:Connect(function()
        for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)
end)

-- 6. Ресет (Reset)
CreateButton("RESET CHARACTER", UDim2.new(0.05, 0, 0.60, 0), Color3.fromRGB(150, 50, 50), function()
    game.Players.LocalPlayer.Character:BreakJoints()
end)

-- 7. Подключение к чату (Chat Logger)
CreateButton("Log Chat to Console", UDim2.new(0.05, 0, 0.71, 0), Color3.fromRGB(0, 100, 200), function()
    print("--- CHAT LOG STARTED ---")
    for _, p in pairs(game.Players:GetPlayers()) do
        p.Chatted:Connect(function(msg)
            print("[" .. p.Name .. "]: " .. msg)
        end)
    end
    game.Players.PlayerAdded:Connect(function(p)
        p.Chatted:Connect(function(msg)
            print("[" .. p.Name .. "]: " .. msg)
        end)
    end)
end)

-- Индикация кнопок (цвета)
spawn(function()
    while wait(0.5) do
        jumpBtn.Text = infJumpEnabled and "Inf Jump: ON" or "Inf Jump: OFF"
        jumpBtn.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    end
end)

