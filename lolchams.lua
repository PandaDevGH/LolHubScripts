local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

local isHighlightingActive = true
local heartbeatConnection

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer.PlayerGui

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(0, 200, 0, 50)
textLabel.Position = UDim2.new(0, 10, 1, -60)
textLabel.BackgroundTransparency = 1
textLabel.Font = Enum.Font.SourceSansBold
textLabel.TextSize = 24
textLabel.Text = "LolChams v0.0.1"
textLabel.Parent = screenGui

local function updateRainbowGradient()
    local t = tick() % 2 / 2
    local hue1 = t
    local hue2 = (t + 0.5) % 1
    
    local color1 = Color3.fromHSV(hue1, 1, 1)
    local color2 = Color3.fromHSV(hue2, 1, 1)
    
    textLabel.TextColor3 = color1
    textLabel.TextStrokeColor3 = color2
    textLabel.TextStrokeTransparency = 0
end

local function isPlayerVisible(player)
    if not LocalPlayer.Character or not player.Character then return false end
    
    local rayOrigin = LocalPlayer.Character.Head.Position
    local rayDirection = (player.Character.Head.Position - rayOrigin).Unit
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection * 1000, raycastParams)
    
    return raycastResult == nil
end

local function highlightPlayer(player)
    if not player.Character then return end
    
    local highlight = player.Character:FindFirstChild("Highlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Parent = player.Character
    end
    
    local isVisible = isPlayerVisible(player)
    print(player.Name .. " is visible: " .. tostring(isVisible))  -- Debug print
    
    highlight.FillTransparency = isVisible and 0 or 0.8  -- 0 for fully opaque when visible
    highlight.OutlineTransparency = isVisible and 0 or 0.5  -- Added outline transparency
    
    if player.Team == LocalPlayer.Team then
        highlight.FillColor = Color3.fromRGB(0, 0, 255)
    else
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
    end
    
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)  -- White outline for better visibility
end

local function updateAllHighlights()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            highlightPlayer(player)
        end
    end
end

local function stopHighlighting()
    isHighlightingActive = false
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
    
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
    end
    
    if screenGui then
        screenGui:Destroy()
    end
end

updateAllHighlights()

heartbeatConnection = RunService.Heartbeat:Connect(function()
    if isHighlightingActive then
        updateAllHighlights()
        updateRainbowGradient()
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if isHighlightingActive then
            highlightPlayer(player)
        end
    end)
end)
