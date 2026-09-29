-- Place this in a LocalScript inside StarterPlayerScripts or StarterGui
-- This creates a clean, modern UI similar in style to the reference

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- // CONFIGURATION
local CONFIG = {
    Title = "RENZ HUB V1",
    Subtitle = "Join Discord for more",
    AccentColor = Color3.fromRGB(138, 43, 226), -- Purple
    BackgroundColor = Color3.fromRGB(18, 18, 18),
    PanelColor = Color3.fromRGB(28, 28, 28),
    ButtonColor = Color3.fromRGB(40, 40, 40),
    TextColor = Color3.fromRGB(255, 255, 255),
    SubTextColor = Color3.fromRGB(180, 180, 180),
}

-- // MAIN GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomHubUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- // MAIN FRAME
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = CONFIG.BackgroundColor
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = CONFIG.AccentColor
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- // TOP BAR
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = CONFIG.PanelColor
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 8)
topCorner.Parent = topBar

-- Fix bottom corners of top bar
local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 10)
topBarFix.Position = UDim2.new(0, 0, 1, -10)
topBarFix.BackgroundColor3 = CONFIG.PanelColor
topBarFix.BorderSizePixel = 0
topBarFix.Parent = topBar

-- // TITLE
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(0, 200, 0, 25)
titleLabel.Position = UDim2.new(0, 15, 0, 8)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = CONFIG.Title
titleLabel.TextColor3 = CONFIG.TextColor
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

-- // SUBTITLE
local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Name = "Subtitle"
subtitleLabel.Size = UDim2.new(0, 200, 0, 15)
subtitleLabel.Position = UDim2.new(0, 15, 0, 30)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = CONFIG.Subtitle
subtitleLabel.TextColor3 = CONFIG.SubTextColor
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextSize = 11
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.Parent = topBar

-- // SEARCH BAR
local searchBar = Instance.new("Frame")
searchBar.Name = "SearchBar"
searchBar.Size = UDim2.new(0, 200, 0, 30)
searchBar.Position = UDim2.new(0, 250, 0, 10)
searchBar.BackgroundColor3 = CONFIG.BackgroundColor
searchBar.BorderSizePixel = 0
searchBar.Parent = topBar

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 6)
searchCorner.Parent = searchBar

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -10, 1, 0)
searchBox.Position = UDim2.new(0, 10, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.Text = ""
searchBox.PlaceholderText = "Search..."
searchBox.TextColor3 = CONFIG.TextColor
searchBox.PlaceholderColor3 = CONFIG.SubTextColor
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 12
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.Parent = searchBar

-- // CLOSE BUTTON
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = CONFIG.TextColor
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- // MINIMIZE BUTTON
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -75, 0, 10)
minimizeButton.BackgroundColor3 = CONFIG.ButtonColor
minimizeButton.Text = "-"
minimizeButton.TextColor3 = CONFIG.TextColor
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 16
minimizeButton.Parent = topBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeButton

-- // SIDEBAR
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 150, 1, -70)
sidebar.Position = UDim2.new(0, 10, 0, 60)
sidebar.BackgroundColor3 = CONFIG.PanelColor
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 8)
sidebarCorner.Parent = sidebar

-- // SIDEBAR LAYOUT
local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 5)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Parent = sidebar

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 10)
sidebarPadding.PaddingLeft = UDim.new(0, 8)
sidebarPadding.PaddingRight = UDim.new(0, 8)
sidebarPadding.Parent = sidebar

-- // CONTENT AREA
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -180, 1, -70)
contentArea.Position = UDim2.new(0, 170, 0, 60)
contentArea.BackgroundColor3 = CONFIG.PanelColor
contentArea.BorderSizePixel = 0
contentArea.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = contentArea

-- // TAB CONTAINER
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, -20, 0, 35)
tabContainer.Position = UDim2.new(0, 10, 0, 10)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = contentArea

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 20)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabContainer

-- // BUTTON CONTAINER (Scrollable)
local buttonScroll = Instance.new("ScrollingFrame")
buttonScroll.Name = "ButtonScroll"
buttonScroll.Size = UDim2.new(1, -20, 1, -60)
buttonScroll.Position = UDim2.new(0, 10, 0, 50)
buttonScroll.BackgroundTransparency = 1
buttonScroll.BorderSizePixel = 0
buttonScroll.ScrollBarThickness = 4
buttonScroll.ScrollBarImageColor3 = CONFIG.AccentColor
buttonScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
buttonScroll.Parent = contentArea

local buttonGrid = Instance.new("UIGridLayout")
buttonGrid.CellSize = UDim2.new(0, 180, 0, 70)
buttonGrid.CellPadding = UDim2.new(0, 10, 0, 10)
buttonGrid.SortOrder = Enum.SortOrder.LayoutOrder
buttonGrid.Parent = buttonScroll

-- // FUNCTION TO CREATE SIDEBAR BUTTONS
local function createSidebarButton(name, order)
    local button = Instance.new("TextButton")
    button.Name = name .. "Tab"
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = CONFIG.ButtonColor
    button.Text = name
    button.TextColor3 = CONFIG.TextColor
    button.Font = Enum.Font.Gotham
    button.TextSize = 13
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.LayoutOrder = order
    button.Parent = sidebar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button
    
    local btnPadding = Instance.new("UIPadding")
    btnPadding.PaddingLeft = UDim.new(0, 10)
    btnPadding.Parent = button
    
    return button
end

-- // FUNCTION TO CREATE TAB HEADERS
local function createTabHeader(name, order, isActive)
    local tab = Instance.new("TextButton")
    tab.Name = name .. "Header"
    tab.Size = UDim2.new(0, 80, 1, 0)
    tab.BackgroundTransparency = 1
    tab.Text = name
    tab.TextColor3 = isActive and CONFIG.TextColor or CONFIG.SubTextColor
    tab.Font = isActive and Enum.Font.GothamBold or Enum.Font.Gotham
    tab.TextSize = 14
    tab.LayoutOrder = order
    tab.Parent = tabContainer
    
    -- Underline for active tab
    if isActive then
        local underline = Instance.new("Frame")
        underline.Name = "Underline"
        underline.Size = UDim2.new(1, 0, 0, 2)
        underline.Position = UDim2.new(0, 0, 1, -2)
        underline.BackgroundColor3 = CONFIG.AccentColor
        underline.BorderSizePixel = 0
        underline.Parent = tab
    end
    
    return tab
end

-- // FUNCTION TO CREATE ACTION BUTTONS
local function createActionButton(title, subtitle, order)
    local button = Instance.new("TextButton")
    button.Name = title .. "Button"
    button.Size = UDim2.new(0, 180, 0, 70)
    button.BackgroundColor3 = CONFIG.ButtonColor
    button.Text = ""
    button.LayoutOrder = order
    button.Parent = buttonScroll
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = button
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.Position = UDim2.new(0, 0, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = CONFIG.TextColor
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.Parent = button
    
    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, 0, 0, 15)
    subLabel.Position = UDim2.new(0, 0, 0, 35)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = subtitle
    subLabel.TextColor3 = CONFIG.SubTextColor
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextSize = 11
    subLabel.Parent = button
    
    return button
end

-- // BUILD THE UI
-- Sidebar buttons
local tabs = {"Steal An Egg", "Finder", "Shader", "Instant TP", "Creator"}
for i, tabName in ipairs(tabs) do
    local btn = createSidebarButton(tabName, i)
    
    -- Highlight the first tab (Steal An Egg)
    if i == 1 then
        btn.BackgroundColor3 = CONFIG.AccentColor
    end
end

-- Tab headers
createTabHeader("No Key", 1, true)
createTabHeader("Has Key", 2, false)

-- Action buttons
createActionButton("KEYLESS HUB", "LOAD", 1)
createActionButton("DIABLO SCRIPT", "LOAD", 2)
createActionButton("INSTANT STEAL", "LOAD", 3)

-- Premium section label
local premiumLabel = Instance.new("TextLabel")
premiumLabel.Size = UDim2.new(1, -20, 0, 25)
premiumLabel.Position = UDim2.new(0, 10, 0, 235)
premiumLabel.BackgroundTransparency = 1
premiumLabel.Text = "Premium Huds"
premiumLabel.TextColor3 = CONFIG.TextColor
premiumLabel.Font = Enum.Font.GothamBold
premiumLabel.TextSize = 14
premiumLabel.TextXAlignment = Enum.TextXAlignment.Left
premiumLabel.Parent = contentArea

-- Premium buttons
createActionButton("SENA HUB 5.2", "LOAD", 4)
createActionButton("SENA HUB NEW", "LOAD", 5)

-- Update canvas size
buttonScroll.CanvasSize = UDim2.new(0, 0, 0, buttonGrid.AbsoluteContentSize.Y + 10)

-- // FUNCTIONALITY
-- Close button
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Minimize button
local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        mainFrame.Size = UDim2.new(0, 600, 0, 50)
    else
        mainFrame.Size = UDim2.new(0, 600, 0, 400)
    end
end)

-- Make draggable
local dragging = false
local dragInput, dragStart, startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Button click handler (example)
for _, btn in ipairs(buttonScroll:GetChildren()) do
    if btn:IsA("TextButton") then
        btn.MouseButton1Click:Connect(function()
            print("Button clicked:", btn.Name)
            -- Add your legitimate game logic here
        end)
    end
end

print("Custom Hub UI loaded successfully!")
