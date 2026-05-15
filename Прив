-- Загрузка библиотеки интерфейса Orion Lib
local OrionLib = loadstring(game:HttpGet(('https://githubusercontent.com')))()

-- Создание главного окна меню
local Window = OrionLib:MakeWindow({
    Name = "Roblox Mod Menu | GodMode", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "OrionTest"
})

-- Переменные для хранения состояний читов
local godModeActive = false
local loopHealActive = false

-- Создание вкладки "Функции"
local MainTab = Window:MakeTab({
    Name = "Главная",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Функция 1: Бесконечное здоровье (Loop Heal)
MainTab:AddToggle({
    Name = "Бесконечное здоровье (Loop Heal)",
    Default = false,
    Callback = function(Value)
        loopHealActive = Value
        if loopHealActive then
            task.spawn(function()
                while loopHealActive do
                    pcall(function()
                        local player = game:GetService("Players").LocalPlayer
                        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                            local hum = player.Character:FindFirstChildOfClass("Humanoid")
                            if hum.Health > 0 then
                                hum.Health = hum.MaxHealth
                            end
                        end
                    end)
                    task.wait(0.1) -- Проверка и лечение каждые 0.1 сек
                end
            end)
        end
    end
})

-- Функция 2: Отключение состояния смерти (Anti-Die)
MainTab:AddToggle({
    Name = "Анти-Смерть (Блокировать урон)",
    Default = false,
    Callback = function(Value)
        godModeActive = Value
        pcall(function()
            local player = game:GetService("Players").LocalPlayer
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not godModeActive)
            end
        end)
    end
})

-- Дополнительная функция: Настройка скорости (WalkSpeed)
MainTab:AddSlider({
    Name = "Скорость бега",
    Min = 16,
    Max = 150,
    Default = 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        pcall(function()
            game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
        end)
    end    
})

-- Инициализация меню
OrionLib:Init()
