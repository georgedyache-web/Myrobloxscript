local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Frame = Instance.new("Frame", sg)
local Toggle = Instance.new("TextButton", sg)

Frame.Size = UDim2.new(0, 220, 0, 420) 
Frame.Position = UDim2.new(0.5, -110, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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

-- 1. УЛУЧШЕННЫЙ ПОЛЕТ (Fly)
local flying = false
local speed = 50
CreateButton("Fly (Moveable)", UDim2.new(0.05, 0, 0.05, 0), Color3.fromRGB(50, 50, 50), function()
    flying = not flying
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    
    if flying then
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "FlyBV"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        spawn(function()
            while flying do
                bv.Velocity = char:WaitForChild("Humanoid").MoveDirection * speed
                wait()
            end
            bv:Destroy()
        end)
    end
end)

-- 2. АДМИН-КОМАНДЫ ЧЕРЕЗ ЧАТ
local prefix = ":"
CreateButton("Connect Admin Chat", UDim2.new(0.05, 0, 0.16, 0), Color3.fromRGB(0, 120, 255), function()
    game.Players.LocalPlayer.Chatted:Connect(function(msg)
        local args = string.split(msg, " ")
        if args[1] == prefix.."speed" then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(args[2])
        elseif args[1] == prefix.."jump" then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = tonumber(args[2])
        elseif args[1] == prefix.."re" then
            game.Players.LocalPlayer.Character:BreakJoints()
        end
    end)
    print("Admin Chat Connected! Use :speed, :jump, :re")
end)

-- 3. БЕСКОНЕЧНЫЙ ПРЫЖОК
local infJumpEnabled = false
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJumpEnabled then game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
end)
CreateButton("Inf Jump Toggle", UDim2.new(0.05, 0, 0.27, 0), Color3.fromRGB(50, 50, 50), function()
    infJumpEnabled = not infJumpEnabled
end)

-- 4. ESP
CreateButton("Enable ESP", UDim2.new(0.05, 0, 0.38, 0), Color3.fromRGB(50, 50, 50), function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            local h = Instance.new("Highlight", p.Character)
            h.FillColor = Color3.fromRGB(255, 0, 0)
        end
    end
end)

-- 5. NOCLIP
CreateButton("Noclip", UDim2.new(0.05, 0, 0.49, 0), Color3.fromRGB(50, 50, 50), function()
    game:GetService("RunService").Stepped:Connect(function()
        if game.Players.LocalPlayer.Character then
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
end)

-- 6. RESET
CreateButton("RESET", UDim2.new(0.05, 0, 0.60, 0), Color3.fromRGB(150, 50, 50), function()
    game.Players.LocalPlayer.Character:BreakJoints()
end)
