if not game:IsLoaded() then game.Loaded:Wait() end

do
    local ScriptContext = game:GetService("ScriptContext")
    local Player = game:GetService("Players").LocalPlayer
    if not Player then Player = game:GetService("Players"):GetPropertyChangedSignal("LocalPlayer"):Wait(); Player = game:GetService("Players").LocalPlayer end
    local function destroyErrorDetectors()
        if not getconnections then return end
        pcall(function()
            for _,v in ipairs(getconnections(ScriptContext.Error)) do
                pcall(function() if v.Disable then v:Disable() end end)
                pcall(function() if v.Disconnect then v:Disconnect() end end)
            end
        end)
    end
    destroyErrorDetectors()
    Player.CharacterAdded:Connect(function() task.wait(0.5); destroyErrorDetectors() end)
    task.spawn(function() while task.wait(1) do destroyErrorDetectors() end end)
end

-- ═══════════════════════════════════════════════════════════
-- SLIMETIME ESP LIBRARY
-- ═══════════════════════════════════════════════════════════
local Version = "1.1"

do
    if getgenv()._ZH_EspLib and getgenv()._ZH_EspLib.Unload then
        pcall(getgenv()._ZH_EspLib.Unload, getgenv()._ZH_EspLib)
    end
end

local GetService = setmetatable({}, {
    __index = function(_, Name)
        return game:GetService(Name);
    end;
})

local Workspace, Players, RunService, HttpService = GetService["Workspace"], GetService["Players"], GetService["RunService"], GetService["HttpService"];
local LocalPlayer, Camera = Players.LocalPlayer, Workspace.CurrentCamera;
local WorldToViewportPoint, FindFirstChildOfClass, FindFirstChild = Camera.WorldToViewportPoint, game.FindFirstChildOfClass, game.FindFirstChild;

local NewVector3, NewVector2, Dim, Dim2, DimOffset = Vector3.new, Vector2.new, UDim.new, UDim2.new, UDim2.fromOffset;
local NumSeq = NumberSequence.new;
local NumKey = NumberSequenceKeypoint.new;

local Format, Spawn, Clear, Floor, Clamp, Abs, Tan, Rad, Huge, Remove = string.format, task.spawn, table.clear, math.floor, math.clamp, math.abs, math.tan, math.rad, math.huge, table.remove;
local Frame, ZeroVector3, CameraPosition, CachedFocalLength, ViewPortY, Updates = 1 / 60, NewVector3(0,0,0), NewVector3(0,0,0), 0, 0, 0;

local function CameraCache()
    ViewPortY = Camera.ViewportSize.Y;
    CachedFocalLength = ViewPortY / (2 * Tan(Rad(Camera.FieldOfView) * 0.5));
end

CameraCache();

Camera:GetPropertyChangedSignal("FieldOfView"):Connect(CameraCache);
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(CameraCache);

local Library = {
    ['Directory'] = 'Esp',
    ['Cache'] = {},
    ['Holder'] = nil,
    ['Threads'] = {},
    ['Connections'] = {},

    ['Table'] = {
        ['Enabled'] = false,
        ['ShowLocalPlayer'] = false,
        ['Distance'] = 7520,
        ['RefreshRate'] = 60,
        ['Font'] = 'TahomaBold',
        ['FontSize'] = 12,
        ['FontType'] = 'none',

        ['Boxes'] = {
            ['Enabled'] = true,
            ['Type'] = "2D",
            ['Rotation'] = 90,

            ['Box Glow'] = {
                ['Enabled'] = true,
                ['Top'] = Color3.fromRGB(255, 255, 255),
                ['Bot'] = Color3.fromRGB(255, 255, 255),
                ['Transparency'] = {0.75, 0.75},
            },

            ['Gradients'] = {
                ['Top'] = Color3.fromRGB(255, 255, 255),
                ['Bot'] = Color3.fromRGB(255, 255, 255),
            },

            ['Filled'] = {
                ['Enabled'] = false,
                ['Top'] = Color3.fromRGB(255, 255, 255),
                ['Bot'] = Color3.fromRGB(255, 255, 255),
                ['Transparency'] = {1, 0.65},
            },
        },

        ['Bars'] = {
            ['Health Bar'] = {
                ['Enabled'] = true,
                ['Top'] = Color3.fromRGB(0, 255, 0),
                ['Mid'] = Color3.fromRGB(255, 170, 0),
                ['Bot'] = Color3.fromRGB(255, 0, 0),
            },

            ['Armor Bar'] = {
                ['Enabled'] = false,
                ['Top'] = Color3.fromRGB(255, 255, 255),
                ['Mid'] = Color3.fromRGB(220, 220, 220),
                ['Bot'] = Color3.fromRGB(180, 180, 180),
            },
        },

        ['Texts'] = {
            ['Name'] = {
                ['Enabled'] = true,
                ['Color'] = Color3.fromRGB(255, 255, 255),
            },

            ['Distance'] = {
                ['Enabled'] = true,
                ['Color'] = Color3.fromRGB(255, 255, 255),
            },

            ['Weapon'] = {
                ['Enabled'] = true,
                ['Color'] = Color3.fromRGB(255, 255, 255),
            },
        },

        ['Flags'] = {
            ['Walking'] = {
                ['Enabled'] = false,
                ['Color'] = Color3.fromRGB(255, 0, 0),
                ['Text'] = "Walking",
            },
            ['Jumping'] = {
                ['Enabled'] = false,
                ['Color'] = Color3.fromRGB(144, 238, 144),
                ['Text'] = "Jumping",
            },
            ['Swimming'] = {
                ['Enabled'] = false,
                ['Color'] = Color3.fromRGB(0, 255, 255),
                ['Text'] = "Swimming",
            },
        },

        ['Chams'] = {
            ['Enabled'] = false,
            ['FillTransparency'] = 0,
            ['FillColor'] = Color3.fromRGB(255, 255, 255),
            ['OutlineColor'] = Color3.fromRGB(0, 0, 0),
        }
    }
}

local Table = Library['Table'];

local Fonts = {}; do
    local function FontsRegister(Name, Weight, Style, Asset)
        if not isfile(Asset.Id) then
            writefile(Asset.Id, Asset.Font)
        end

        if isfile(Name .. ".font") then
            delfile(Name .. ".font")
        end

        local Info = {
            name = Name,
            faces = {
                {
                    name = "Normal",
                    weight = Weight,
                    style = Style,
                    assetId = getcustomasset(Asset.Id),
                },
            },
        }

        writefile(Name .. ".font", HttpService:JSONEncode(Info))
        return getcustomasset(Name .. ".font")
    end;

    Fonts.Minecraftia = FontsRegister("Minecraftia", 400, "Normal", {
        Id = "Minecraftia-Regular.ttf",
        Font = game:HttpGet("https://raw.githubusercontent.com/i77lhm/storage/main/fonts/Minecraftia-Regular.ttf"),
    })

    Library.Minecraftia = Font.new(Fonts.Minecraftia, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
end

Library.__index = Library;
getgenv()._ZH_EspLib = Library;

function Library:CreateObjects(Name, Prop)
    local New = Instance.new(Name);

    for Property, Value in Prop or {} do
        New[Property] = Value;
    end;
            
    return New;
end

function Library:CreateThreads(Name, Signal, Callback)
    local Connection = Signal:Connect(Callback);
    self.Threads[Name] = Connection;
    return Connection;
end

Library.Holder = Library:CreateObjects("ScreenGui", {
    Name = "\n",
    Parent = gethui(),
    ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    ResetOnSpawn = false,
    DisplayOrder = 10000,
    IgnoreGuiInset = true,
})

function Library:InitEsp(Data)
    local Objects = Data.Objects

    do
        Objects["TargetHolder"] = self:CreateObjects("Frame", {
            Parent = self.Holder,
            Visible = false,
            BackgroundTransparency = 1,
            Position = Dim2(0, 0, 0, 0),
            Size = Dim2(0, 0, 0, 0),
            BorderSizePixel = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })

        Objects["TopHolder"] = self:CreateObjects("Frame", {
            Parent = Objects["TargetHolder"],
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = true,
            BackgroundTransparency = 1,
            AnchorPoint = NewVector2(0, 1),
            Position = Dim2(0, -2, 0, -5),
            Size = Dim2(1, 4, 0, 0),
            BorderSizePixel = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })

        Objects["BottomHolder"] = self:CreateObjects("Frame", {
            Parent = Objects["TargetHolder"],
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = true,
            BackgroundTransparency = 1,
            Position = Dim2(0, -2, 1, 3),
            Size = Dim2(1, 4, 0, 0),
            BorderSizePixel = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })

        Objects["LeftHolder"] = self:CreateObjects("Frame", {
            Parent = Objects["TargetHolder"],
            AutomaticSize = Enum.AutomaticSize.X,
            Visible = true,
            BackgroundTransparency = 1,
            AnchorPoint = NewVector2(1, 0),
            Position = Dim2(0, -5, 0, -2),
            Size = Dim2(0, 0, 1, 4),
            BorderSizePixel = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })

        Objects["RightHolder"] = self:CreateObjects("Frame", {
            Parent = Objects["TargetHolder"],
            AutomaticSize = Enum.AutomaticSize.X,
            Visible = true,
            BackgroundTransparency = 1,
            Position = Dim2(1, 5, 0, -2),
            Size = Dim2(0, 0, 1, 4),
            BorderSizePixel = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })
    end

    do
        Objects["TopTextHolder"] = self:CreateObjects("Frame", {
            Parent = Objects["TopHolder"],
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = true,
            BackgroundTransparency = 1,
            Position = Dim2(0, 0, 0, 0),
            Size = Dim2(1, 0, 0, 0),
            BorderSizePixel = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })

        Objects["BottomTextHolder"] = self:CreateObjects("Frame", {
            Parent = Objects["BottomHolder"],
            LayoutOrder = 2,
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = true,
            BackgroundTransparency = 1,
            Position = Dim2(0, 0, 0, 0),
            Size = Dim2(1, 0, 0, 0),
            BorderSizePixel = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })

        Objects["LeftTextHolder"] = self:CreateObjects("Frame", {
            Parent = Objects["LeftHolder"],
            AutomaticSize = Enum.AutomaticSize.XY,
            Visible = true,
            BackgroundTransparency = 1,
            Position = Dim2(0, 0, 0, 0),
            Size = Dim2(1, 0, 0, 0),
            BorderSizePixel = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })

        Objects["RightTextHolder"] = self:CreateObjects("Frame", {
            Parent = Objects["RightHolder"],
            LayoutOrder = 2,
            AutomaticSize = Enum.AutomaticSize.XY,
            Visible = true,
            BackgroundTransparency = 1,
            Position = Dim2(0, 0, 0, 0),
            Size = Dim2(0, 0, 0, 0),
            BorderSizePixel = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })
    end

    do
        Objects["LeftBarHolder"] = self:CreateObjects("Frame", {
            Parent = Objects["LeftHolder"],
            AutomaticSize = Enum.AutomaticSize.X,
            Visible = false,
            BackgroundTransparency = 1,
            Position = Dim2(0, 0, 0, 0),
            Size = Dim2(0, 0, 1, 0),
            BorderSizePixel = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })

        Objects["BottomBarHolder"] = self:CreateObjects("Frame", {
            Parent = Objects["BottomHolder"],
            LayoutOrder = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false,
            BackgroundTransparency = 1,
            Position = Dim2(0, 0, 0, 0),
            Size = Dim2(1, 0, 0, 0),
            BorderSizePixel = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })
    end

    do
        self:CreateObjects("UIListLayout", {
            Parent = Objects["TopTextHolder"],
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = Dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        self:CreateObjects("UIListLayout", {
            Parent = Objects["BottomTextHolder"],
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = Dim(0, -1),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        self:CreateObjects("UIListLayout", {
            Parent = Objects["LeftTextHolder"],
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = Dim(0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        self:CreateObjects("UIListLayout", {
            Parent = Objects["RightTextHolder"],
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            Padding = Dim(0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        self:CreateObjects("UIListLayout", {
            Parent = Objects["LeftBarHolder"],
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = Dim(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        self:CreateObjects("UIListLayout", {
            Parent = Objects["BottomBarHolder"],
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = Dim(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        self:CreateObjects("UIListLayout", {
            Parent = Objects["TopHolder"],
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = Dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        self:CreateObjects("UIListLayout", {
            Parent = Objects["BottomHolder"],
            Padding = Dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        self:CreateObjects("UIListLayout", {
            Parent = Objects["LeftHolder"],
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            Padding = Dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        self:CreateObjects("UIListLayout", {
            Parent = Objects["RightHolder"],
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            Padding = Dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
    end

    do
        self:CreateObjects("UIPadding", {
            Parent = Objects["TopTextHolder"],
            PaddingBottom = Dim(0, 0),
        })

        self:CreateObjects("UIPadding", {
            Parent = Objects["BottomTextHolder"],
            PaddingTop = Dim(0, -1)
        })

        self:CreateObjects("UIPadding", {
            Parent = Objects["LeftTextHolder"],
            PaddingTop = Dim(0, -3),
        })

        self:CreateObjects("UIPadding", {
            Parent = Objects["RightTextHolder"],
            PaddingTop = Dim(0, -3),
        })

        self:CreateObjects("UIPadding", {
            Parent = Objects["LeftBarHolder"],
            PaddingRight = Dim(0, 0),
        })

        self:CreateObjects("UIPadding", {
            Parent = Objects["BottomBarHolder"],
            PaddingTop = Dim(0, 2),
        })

        self:CreateObjects("UIPadding", {
            Parent = Objects["LeftHolder"],
            PaddingRight = Dim(0, 1),
        })
    end

    do
        Objects["BoxGlow"] = self:CreateObjects("ImageLabel", {
            Parent = Objects["TargetHolder"],
            Image = "rbxassetid://110204605000367",
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(NewVector2(21, 21), NewVector2(79, 79)),
            AutomaticSize = Enum.AutomaticSize.XY,
            ImageTransparency = 0.65,
            ResampleMode = Enum.ResamplerMode.Pixelated,
            Visible = true,
            BackgroundTransparency = 1,
            Position = Dim2(0, -21, 0, -21),
            Size = Dim2(0, 0, 0, 0),
            BorderSizePixel = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })

        Objects["BoxGlowGradient"] = self:CreateObjects("UIGradient", {
            Parent = Objects["BoxGlow"],
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
            }),
            Transparency = NumSeq({NumKey(0, 0), NumKey(1, 0)}),
        })

        self:CreateObjects("UIPadding", {
            Parent = Objects["BoxGlow"],
            PaddingTop = Dim(0, 21),
            PaddingBottom = Dim(0, 20),
            PaddingLeft = Dim(0, 21),
            PaddingRight = Dim(0, 20),
        })

        Objects["BoxOutlineHolder"] = self:CreateObjects("Frame", {
            Parent = Objects["BoxGlow"],
            Visible = false,
            BackgroundTransparency = 1,
            Position = Dim2(0, 0, 0, 0),
            Size = Dim2(0, 0, 0, 0),
            BorderSizePixel = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })

        Objects["BoxOutline"] = self:CreateObjects("UIStroke", {
            Parent = Objects["BoxOutlineHolder"],
            Thickness = 3,
            LineJoinMode = Enum.LineJoinMode.Miter,
        })

        Objects["BoxOutlineGradient"] = self:CreateObjects("UIGradient", {
            Parent = Objects["BoxOutline"],
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
            }),
            Transparency = NumSeq({NumKey(0, 0), NumKey(1, 0)}),
        })

        Objects["BoxInlineHolder"] = self:CreateObjects("Frame", {
            Parent = Objects["BoxGlow"],
            Visible = false,
            BackgroundTransparency = 1,
            Position = Dim2(0, -1, 0, -1),
            Size = Dim2(0, 0, 0, 0),
            BorderSizePixel = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })

        Objects["BoxInline"] = self:CreateObjects("UIStroke", {
            Parent = Objects["BoxInlineHolder"],
            Color = Color3.fromRGB(255, 255, 255),
            LineJoinMode = Enum.LineJoinMode.Miter,
        })

        Objects["BoxInlineGradient"] = self:CreateObjects("UIGradient", {
            Parent = Objects["BoxInline"],
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
            }),
            Transparency = NumSeq({NumKey(0, 0), NumKey(1, 0)}),
        })

        Objects["BoxFill"] = self:CreateObjects("Frame", {
            Parent = Objects["BoxGlow"],
            Visible = false,
            BackgroundTransparency = 0,
            Position = Dim2(0, 0, 0, 0),
            Size = Dim2(0, 0, 0, 0),
            BorderSizePixel = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })

        Objects["BoxFillGradient"] = self:CreateObjects("UIGradient", {
            Parent = Objects["BoxFill"],
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
            }),
            Transparency = NumSeq({NumKey(0, 1), NumKey(1, 1)}),
        })

        Objects["CornerHolder"] = self:CreateObjects("Frame", {
            Parent = Objects["BoxGlow"],
            Visible = false,
            BackgroundTransparency = 1,
            Position = Dim2(0, -1, 0, -1),
            Size = Dim2(0, 0, 0, 0),
            BorderSizePixel = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })

        for i = 1, 8 do
            Objects["Line_" .. i] = self:CreateObjects("Frame", {
                Parent = Objects["CornerHolder"],
                Visible = false,
                BackgroundTransparency = 0,
                Position = Dim2(0, 0, 0, 0),
                Size = Dim2(0, 0, 0, 0),
                BorderSizePixel = 0,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            })
            self:CreateObjects("UIStroke", {
                Parent = Objects["Line_" .. i],
                Thickness = 1,
                LineJoinMode = Enum.LineJoinMode.Miter,
            })
        end
    end

    do
        Objects["HealthBarOutline"] = self:CreateObjects("Frame", {
            Parent = Objects["LeftBarHolder"],
            ZIndex = 5, LayoutOrder = 0, Visible = false,
            BackgroundTransparency = 0,
            Position = Dim2(0, 0, 0, 0), Size = Dim2(0, 4, 1, 0),
            BorderSizePixel = 0, BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0), ClipsDescendants = false,
        })

        self:CreateObjects("UIStroke", {
            Parent = Objects["HealthBarOutline"],
            Thickness = 1, LineJoinMode = Enum.LineJoinMode.Miter,
        })

        Objects["HealthBar"] = self:CreateObjects("Frame", {
            Parent = Objects["HealthBarOutline"],
            ZIndex = 6, AnchorPoint = NewVector2(0, 1),
            Position = Dim2(0, 0, 1, 0), Size = Dim2(1, 0, 1, 0),
            BorderSizePixel = 0, BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255), ClipsDescendants = true,
        })

        Objects["HealthBarGradient"] = self:CreateObjects("UIGradient", {
            Parent = Objects["HealthBar"],
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Table['Bars']['Health Bar']['Top']),
                ColorSequenceKeypoint.new(0.5, Table['Bars']['Health Bar']['Mid']),
                ColorSequenceKeypoint.new(1, Table['Bars']['Health Bar']['Bot']),
            }),
            Transparency = NumSeq({NumKey(0, 0), NumKey(1, 0)}),
        })

        Objects["HealthBarText"] = self:CreateObjects("TextLabel", {
            Parent = Objects["HealthBarOutline"],
            FontFace = Library.Minecraftia, TextSize = 16, ZIndex = 10,
            TextColor3 = Color3.fromRGB(255, 255, 255), Text = "",
            TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
            AnchorPoint = NewVector2(0.5, 0.5), Position = Dim2(0.5, 0, 1, 0),
            BorderSizePixel = 0, Visible = false, BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY, Size = Dim2(0, 0, 0, 0),
        })

        self:CreateObjects("UIStroke", {
            Parent = Objects["HealthBarText"],
            Color = Color3.fromRGB(0, 0, 0), LineJoinMode = Enum.LineJoinMode.Miter,
        })

        Objects["ArmorBarOutline"] = self:CreateObjects("Frame", {
            Parent = Objects["BottomBarHolder"],
            ZIndex = 5, LayoutOrder = 0, Visible = false,
            BackgroundTransparency = 0,
            Position = Dim2(0, 0, 0, 0), Size = Dim2(1, 0, 0, 4),
            BorderSizePixel = 0, BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0), ClipsDescendants = true,
        })

        self:CreateObjects("UIStroke", {
            Parent = Objects["ArmorBarOutline"],
            Thickness = 1, LineJoinMode = Enum.LineJoinMode.Miter,
        })

        Objects["ArmorBar"] = self:CreateObjects("Frame", {
            Parent = Objects["ArmorBarOutline"],
            ZIndex = 6, AnchorPoint = NewVector2(0, 0),
            Position = Dim2(0, 0, 0, 0), Size = Dim2(1, 0, 1, 0),
            BorderSizePixel = 0, BorderColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })

        Objects["ArmorBarGradient"] = self:CreateObjects("UIGradient", {
            Parent = Objects["ArmorBar"],
            Rotation = 0,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Table['Bars']['Armor Bar']['Top']),
                ColorSequenceKeypoint.new(0.5, Table['Bars']['Armor Bar']['Mid']),
                ColorSequenceKeypoint.new(1, Table['Bars']['Armor Bar']['Bot']),
            }),
            Transparency = NumSeq({NumKey(0, 0), NumKey(1, 0)}),
        })

        Objects["ArmorBarText"] = self:CreateObjects("TextLabel", {
            Parent = Objects["ArmorBar"],
            FontFace = Library.Minecraftia, TextSize = 16, ZIndex = 10,
            TextColor3 = Color3.fromRGB(255, 255, 255), Text = "",
            TextXAlignment = Enum.TextXAlignment.Center,
            AnchorPoint = NewVector2(0.5, 0.5), Position = Dim2(0.5, 0, 0.5, 0),
            BorderSizePixel = 0, Visible = false, BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY, Size = Dim2(0, 0, 0, 0),
        })

        self:CreateObjects("UIStroke", {
            Parent = Objects["ArmorBarText"],
            Color = Color3.fromRGB(0, 0, 0), LineJoinMode = Enum.LineJoinMode.Miter,
        })
    end

    do
        Objects["TargetName"] = self:CreateObjects("TextLabel", {
            Parent = Objects["TopTextHolder"],
            FontFace = Library.Minecraftia, TextSize = 20, LayoutOrder = 2,
            TextColor3 = Table['Texts']['Name']['Color'], Text = "",
            TextXAlignment = Enum.TextXAlignment.Center, BorderSizePixel = 0,
            Visible = false, BackgroundTransparency = 1, ZIndex = 5,
            AutomaticSize = Enum.AutomaticSize.XY, Size = Dim2(0, 0, 0, 0),
        })
        self:CreateObjects("UIStroke", { Parent = Objects["TargetName"], Color = Color3.fromRGB(0, 0, 0), LineJoinMode = Enum.LineJoinMode.Miter })

        Objects["Distance"] = self:CreateObjects("TextLabel", {
            Parent = Objects["BottomTextHolder"],
            FontFace = Library.Minecraftia, TextSize = 16, LayoutOrder = 2,
            TextColor3 = Table['Texts']['Distance']['Color'], Text = "",
            TextXAlignment = Enum.TextXAlignment.Center, BorderSizePixel = 0,
            Visible = false, BackgroundTransparency = 1, ZIndex = 5,
            AutomaticSize = Enum.AutomaticSize.XY, Size = Dim2(0, 0, 0, 0),
        })
        self:CreateObjects("UIStroke", { Parent = Objects["Distance"], Color = Color3.fromRGB(0, 0, 0), LineJoinMode = Enum.LineJoinMode.Miter })

        Objects["WalkFlag"] = self:CreateObjects("TextLabel", {
            Parent = Objects["RightTextHolder"],
            FontFace = Library.Minecraftia, TextSize = 16, LayoutOrder = 1,
            TextColor3 = Table['Flags']['Walking']['Color'], Text = Table['Flags']['Walking']['Text'],
            TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0,
            Visible = false, BackgroundTransparency = 1, ZIndex = 5,
            AutomaticSize = Enum.AutomaticSize.XY, Size = Dim2(0, 0, 0, 0),
        })
        self:CreateObjects("UIStroke", { Parent = Objects["WalkFlag"], Color = Color3.fromRGB(0, 0, 0), LineJoinMode = Enum.LineJoinMode.Miter })

        Objects["JumpFlag"] = self:CreateObjects("TextLabel", {
            Parent = Objects["RightTextHolder"],
            FontFace = Library.Minecraftia, TextSize = 16, LayoutOrder = 2,
            TextColor3 = Table['Flags']['Jumping']['Color'], Text = Table['Flags']['Jumping']['Text'],
            TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0,
            Visible = false, BackgroundTransparency = 1, ZIndex = 5,
            AutomaticSize = Enum.AutomaticSize.XY, Size = Dim2(0, 0, 0, 0),
        })
        self:CreateObjects("UIStroke", { Parent = Objects["JumpFlag"], Color = Color3.fromRGB(0, 0, 0), LineJoinMode = Enum.LineJoinMode.Miter })

        Objects["SwimmingFlag"] = self:CreateObjects("TextLabel", {
            Parent = Objects["RightTextHolder"],
            FontFace = Library.Minecraftia, TextSize = 16, LayoutOrder = 4,
            TextColor3 = Table['Flags']['Swimming']['Color'], Text = Table['Flags']['Swimming']['Text'],
            TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0,
            Visible = false, BackgroundTransparency = 1, ZIndex = 5,
            AutomaticSize = Enum.AutomaticSize.XY, Size = Dim2(0, 0, 0, 0),
        })
        self:CreateObjects("UIStroke", { Parent = Objects["SwimmingFlag"], Color = Color3.fromRGB(0, 0, 0), LineJoinMode = Enum.LineJoinMode.Miter })

        Objects["Weapon"] = self:CreateObjects("TextLabel", {
            Parent = Objects["BottomTextHolder"],
            FontFace = Library.Minecraftia, TextSize = 16, LayoutOrder = 3,
            TextColor3 = Table['Texts']['Weapon']['Color'], Text = "none",
            TextXAlignment = Enum.TextXAlignment.Center, BorderSizePixel = 0,
            Visible = false, BackgroundTransparency = 1, ZIndex = 5,
            AutomaticSize = Enum.AutomaticSize.XY, Size = Dim2(0, 0, 0, 0),
        })
        self:CreateObjects("UIStroke", { Parent = Objects["Weapon"], Color = Color3.fromRGB(0, 0, 0), LineJoinMode = Enum.LineJoinMode.Miter })
    end

    do
        Objects["Highlight"] = self:CreateObjects("Highlight", {
            Parent = self.Holder,
            FillColor = Color3.fromRGB(255, 255, 255),
            OutlineColor = Color3.fromRGB(0, 0, 0),
            FillTransparency = Table['Chams']['FillTransparency'],
            OutlineTransparency = 0,
            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
            Enabled = false,
        })
    end
end

local CornerLayout = {
    {Dim2(0, -1, 0, -1), Dim2(0.3, 0, 0, 1), NewVector2(0, 0), 0},
    {Dim2(0, -1, 0, -1), Dim2(0, 1, 0.3, 0), NewVector2(0, 0), 180},
    {Dim2(1, 1, 0, -1), Dim2(0.3, 0, 0, 1), NewVector2(1, 0), 0},
    {Dim2(1, 1, 0, -1), Dim2(0, 1, 0.3, 0), NewVector2(1, 0), 180},
    {Dim2(0, -1, 1, 1), Dim2(0.3, 0, 0, 1), NewVector2(0, 1), 0},
    {Dim2(0, -1, 1, 1), Dim2(0, 1, 0.3, 0), NewVector2(0, 1), -180},
    {Dim2(1, 1, 1, 1), Dim2(0.3, 0, 0, 1), NewVector2(1, 1), 0},
    {Dim2(1, 1, 1, 1), Dim2(0, 1, 0.3, 0), NewVector2(1, 1), -180},
}

function Library:CalculateBox(Data)
    local RootPart = Data['RootPart']
    if not RootPart then return nil, nil, nil, nil, false end
    local RootScreen, OnScreen = WorldToViewportPoint(Camera, RootPart.Position)
    if not OnScreen then return nil, nil, nil, nil, false end
    local Scale = (RootPart.Size.Y * ViewPortY) / (RootScreen.Z * 2)
    local W, H = 3 * Scale, 4.5 * Scale
    return W, H, RootScreen.X - (W * 0.5), RootScreen.Y - (H * 0.5), OnScreen
end

function Library:AddTarget(Player)
    if Player == LocalPlayer and not Table['ShowLocalPlayer'] then return end
    if self.Cache[Player] then return end

    local Data = {
        ['Player'] = Player, ['Objects'] = {}, ['Conns'] = {},
        ['Character'] = nil, ['RootPart'] = nil, ['Humanoid'] = nil, ['Children'] = nil,
        ['Health'] = 0, ['MaxHealth'] = 100, ['Armor'] = 100, ['MaxArmor'] = 100,
        ['CurrentTool'] = nil, ['Alive'] = false, ['LastChamsT'] = nil,
        ['LastW'] = nil, ['LastH'] = nil, ['LastX'] = nil, ['LastY'] = nil,
        ['WalkActive'] = false, ['JumpActive'] = false, ['FallingActive'] = false, ['SwimmingActive'] = false,
        ['LastGlowTop'] = nil, ['LastGlowBot'] = nil, ['LastGlowT1'] = nil, ['LastGlowT2'] = nil,
        ['LastGradTop'] = nil, ['LastGradBot'] = nil, ['LastFillTop'] = nil, ['LastFillBot'] = nil,
        ['LastFillT1'] = nil, ['LastFillT2'] = nil, ['LastDist'] = nil, ['LastDistColor'] = nil,
        ['LastDisplayName'] = nil, ['LastNameColor'] = nil, ['LastHealthTop'] = nil, ['LastHealthMid'] = nil,
        ['LastHealthBot'] = nil, ['LastHealthFloor'] = nil, ['LastRatio'] = nil,
        ['LastArmorTop'] = nil, ['LastArmorMid'] = nil, ['LastArmorBot'] = nil, ['LastArmorFloor'] = nil,
        ['LastArmorRatio'] = nil, ['LastWeapon'] = nil, ['LastWeaponColor'] = nil,
        ['LastChamsFill'] = nil, ['LastChamsOutline'] = nil,
    }
    Data['CustomGradTop'] = getgenv()._ZH_PlayerESPColor
    Data['CustomGradBot'] = getgenv()._ZH_PlayerESPColor
    self:InitEsp(Data)
    self['Cache'][Player] = Data

    local HealthHandler = {}; do
        function HealthHandler.BindHealth(Humanoid)
            if Data['Conns']['Health'] then Data['Conns']['Health']:Disconnect() end
            if Data['Conns']['Died'] then Data['Conns']['Died']:Disconnect() end
            Data['Humanoid'] = Humanoid
            Data['Health'] = Humanoid.Health
            Data['MaxHealth'] = Humanoid.MaxHealth
            Data['Alive'] = Data['Health'] > 0
            Data['Conns']['Health'] = Humanoid.HealthChanged:Connect(function(NewHealth)
                Data['Alive'] = NewHealth > 0
                Data['Health'] = NewHealth
            end)
            Data['Conns']['Died'] = Humanoid.Died:Connect(function()
                Data['Alive'] = false
            end)
        end
        Data['BindHealth'] = HealthHandler.BindHealth
    end

    local ToolHandler = {}; do
        function ToolHandler.BindTool(Character)
            if Data['Conns']['ToolAdded'] then Data['Conns']['ToolAdded']:Disconnect() end
            if Data['Conns']['ToolRemoved'] then Data['Conns']['ToolRemoved']:Disconnect() end
            if Data['Children'] then
                for _, Child in Data['Children'] do
                    if Child:IsA('Tool') then Data['CurrentTool'] = Child.Name; break end
                end
            end
            Data['Conns']['ToolAdded'] = Character.ChildAdded:Connect(function(Child)
                if Child:IsA('Tool') then Data['CurrentTool'] = Child.Name end
            end)
            Data['Conns']['ToolRemoved'] = Character.ChildRemoved:Connect(function(Child)
                if Child:IsA('Tool') then Data['CurrentTool'] = nil end
            end)
        end
        Data['BindTool'] = ToolHandler.BindTool
    end

    local ChildHandler = {}; do
        function ChildHandler.BindChildren(Character)
            if Data['Conns']['ChildAdded'] then Data['Conns']['ChildAdded']:Disconnect() end
            if Data['Conns']['ChildRemoved'] then Data['Conns']['ChildRemoved']:Disconnect() end
            local Children = Character:GetChildren()
            Data['Children'] = Children
            Data['Conns']['ChildAdded'] = Character.ChildAdded:Connect(function(Child) Children[#Children + 1] = Child end)
            Data['Conns']['ChildRemoved'] = Character.ChildRemoved:Connect(function(Child)
                for I = #Children, 1, -1 do if Children[I] == Child then Remove(Children, I); break end end
            end)
            Data['BindTool'](Character)
        end
        Data['BindChildren'] = ChildHandler.BindChildren
    end

    local FlagsHandler = {}; do
        function FlagsHandler.BindFlags(Humanoid)
            if Data['Conns']['MoveDir'] then Data['Conns']['MoveDir']:Disconnect() end
            if Data['Conns']['StateChange'] then Data['Conns']['StateChange']:Disconnect() end
            local Objects = Data['Objects']
            Data['JumpActive'] = false; Data['WalkActive'] = false; Data['FallingActive'] = false; Data['SwimmingActive'] = false
            Objects['WalkFlag'].Visible = false; Objects['JumpFlag'].Visible = false; Objects['SwimmingFlag'].Visible = false
            Data['Conns']['MoveDir'] = Humanoid:GetPropertyChangedSignal('MoveDirection'):Connect(function()
                local Walking = Humanoid.MoveDirection ~= ZeroVector3
                if Walking and not Data['WalkActive'] then
                    Data['WalkActive'] = true
                    if Data['JumpActive'] then Objects['WalkFlag'].LayoutOrder = 2
                    else Objects['WalkFlag'].LayoutOrder = 1; Objects['JumpFlag'].LayoutOrder = 2 end
                    Objects['WalkFlag'].Visible = Table['Flags']['Walking']['Enabled']
                elseif not Walking and Data['WalkActive'] then
                    Data['WalkActive'] = false; Objects['WalkFlag'].Visible = false
                end
            end)
            Data['Conns']['StateChange'] = Humanoid.StateChanged:Connect(function(_, NewState)
                if NewState == Enum.HumanoidStateType.Jumping and not Data['JumpActive'] then
                    Data['JumpActive'] = true; Objects['JumpFlag'].Visible = Table['Flags']['Jumping']['Enabled']
                    if Data['WalkActive'] then Objects['JumpFlag'].LayoutOrder = 2
                    else Objects['JumpFlag'].LayoutOrder = 1; Objects['WalkFlag'].LayoutOrder = 2 end
                elseif NewState == Enum.HumanoidStateType.Landed and Data['JumpActive'] then
                    Data['JumpActive'] = false; Objects['JumpFlag'].Visible = false
                    if Data['WalkActive'] then Objects['WalkFlag'].LayoutOrder = 1 end
                end
                if NewState == Enum.HumanoidStateType.Swimming and not Data['SwimmingActive'] then
                    Data['SwimmingActive'] = true; Objects['SwimmingFlag'].Visible = Table['Flags']['Swimming']['Enabled']
                elseif NewState ~= Enum.HumanoidStateType.Swimming and Data['SwimmingActive'] then
                    Data['SwimmingActive'] = false; Objects['SwimmingFlag'].Visible = false
                end
            end)
        end
        Data['BindFlags'] = FlagsHandler.BindFlags
    end

    local CharacterHandler = {}; do
        function CharacterHandler.OnCharacter(Character)
            Data['Character'] = Character; Data['RootPart'] = nil; Data['Humanoid'] = nil
            Data['Children'] = nil; Data['Alive'] = false
            Data['WalkActive'] = false; Data['JumpActive'] = false; Data['FallingActive'] = false; Data['SwimmingActive'] = false
            if not Character or not Character.Parent then return end
            local RootPart = FindFirstChild(Character, "HumanoidRootPart")
            if not RootPart then RootPart = Character:WaitForChild('HumanoidRootPart', 10) end
            local Humanoid = FindFirstChildOfClass(Character, 'Humanoid')
            if not Humanoid then Humanoid = Character:WaitForChild('Humanoid', 10) end
            if not RootPart or not Humanoid then return end
            if not Character.Parent then return end
            Data['RootPart'] = RootPart; Data['Humanoid'] = Humanoid
            Data['BindChildren'](Character); Data['BindHealth'](Humanoid)
        end
        Data['Conns']['CharAdded'] = Player.CharacterAdded:Connect(function(Character)
            task.defer(CharacterHandler.OnCharacter, Character)
        end)
        if Player.Character and Player.Character.Parent then
            task.defer(CharacterHandler.OnCharacter, Player.Character)
        end
    end
end

function Library:RemoveTarget(Player)
    local Data = self['Cache'][Player]; if not Data then return end
    for _, Connections in Data['Conns'] do Connections:Disconnect() end
    Clear(Data['Conns'])
    if Data['Objects']['TargetHolder'] then Data['Objects']['TargetHolder']:Destroy() end
    Clear(Data['Objects']); self['Cache'][Player] = nil
end

function Library:Update(Player, Data)
    local Objects = Data['Objects']
    if not Data['RootPart'] then if Objects['TargetHolder'].Visible then Objects['TargetHolder'].Visible = false end; return end
    if not Data['Alive'] then if Objects['TargetHolder'].Visible then Objects['TargetHolder'].Visible = false end; return end

    local RootPos = Data['RootPart'].Position
    local Distance = Floor((CameraPosition - RootPos).Magnitude)
    if Distance > Table['Distance'] then if Objects['TargetHolder'].Visible then Objects['TargetHolder'].Visible = false end; return end

    local W, H, X, Y, OnScreen = self:CalculateBox(Data)
    if not OnScreen or not W then if Objects['TargetHolder'].Visible then Objects['TargetHolder'].Visible = false end; return end
    if not Objects['TargetHolder'].Visible then Objects['TargetHolder'].Visible = true end

    local First = Data['RawX'] == nil
    local LX, LY, LW, LH = Data['RawX'] or X, Data['RawY'] or Y, Data['RawW'] or W, Data['RawH'] or H
    local PosChanged = First or Abs(X - LX) > 1 or Abs(Y - LY) > 1
    local SizeChanged = First or Abs(W - LW) > 1 or Abs(H - LH) > 1

    if PosChanged then
        local FX, FY = Floor(X + 0.5), Floor(Y + 0.5)
        Objects['TargetHolder'].Position = DimOffset(FX, FY)
        Data['RawX'] = X; Data['RawY'] = Y; Data['LastX'] = FX; Data['LastY'] = FY
    end

    if SizeChanged then
        local FW, FH = Floor(W + 0.5), Floor(H + 0.5)
        Objects['TargetHolder'].Size = DimOffset(FW, FH)
        Objects['BoxGlow'].Size = DimOffset(FW, FH)
        Objects['BoxOutlineHolder'].Size = DimOffset(FW, FH)
        Objects['BoxInlineHolder'].Size = DimOffset(FW + 2, FH + 2)
        Objects['BoxFill'].Size = DimOffset(FW, FH)
        Objects['CornerHolder'].Size = DimOffset(FW + 2, FH + 2)
        Data['RawW'] = W; Data['RawH'] = H; Data['LastW'] = FW; Data['LastH'] = FH
    end

    local BoxesCfg = Table['Boxes']
    local TextsCfg = Table['Texts']

    if BoxesCfg['Enabled'] then
        if BoxesCfg['Box Glow']['Enabled'] then
            if Objects['BoxGlow'].ImageTransparency ~= 0 then Objects['BoxGlow'].ImageTransparency = 0 end
            local GlowTop = Data['CustomGradTop'] or BoxesCfg['Box Glow']['Top']
            local GlowBot = Data['CustomGradBot'] or BoxesCfg['Box Glow']['Bot']
            if Data['LastGlowTop'] ~= GlowTop or Data['LastGlowBot'] ~= GlowBot then
                Objects['BoxGlowGradient'].Color = ColorSequence.new({ColorSequenceKeypoint.new(0, GlowTop), ColorSequenceKeypoint.new(1, GlowBot)})
                Data['LastGlowTop'] = GlowTop; Data['LastGlowBot'] = GlowBot
            end
            local T1, T2 = BoxesCfg['Box Glow']['Transparency'][1], BoxesCfg['Box Glow']['Transparency'][2]
            if Data['LastGlowT1'] ~= T1 or Data['LastGlowT2'] ~= T2 then
                Objects['BoxGlowGradient'].Transparency = NumSeq({NumKey(0, T1), NumKey(1, T2)})
                Data['LastGlowT1'] = T1; Data['LastGlowT2'] = T2
            end
        else
            if Objects['BoxGlow'].ImageTransparency ~= 1 then Objects['BoxGlow'].ImageTransparency = 1 end
        end

        local BoxType = BoxesCfg['Type']
        if BoxType == "Corner" then
            if Objects['BoxOutlineHolder'].Visible then Objects['BoxOutlineHolder'].Visible = false end
            if Objects['BoxInlineHolder'].Visible then Objects['BoxInlineHolder'].Visible = false end
            if Objects['BoxFill'].Visible then Objects['BoxFill'].Visible = false end
            if not Objects['CornerHolder'].Visible then Objects['CornerHolder'].Visible = true end
            local GradTop = Data['CustomGradTop'] or BoxesCfg['Gradients']['Top']
            for i = 1, 8 do
                local Line = Objects['Line_' .. i]
                local Stroke = Line:FindFirstChildOfClass('UIStroke')
                local LE = CornerLayout[i]
                Line.Position = LE[1]; Line.Size = LE[2]; Line.AnchorPoint = LE[3]; Line.Rotation = LE[4]
                Line.BackgroundColor3 = GradTop; Line.BackgroundTransparency = 0
                if Stroke then Stroke.Color = GradTop end
                Line.Visible = true
            end
        else
            if Objects['CornerHolder'].Visible then Objects['CornerHolder'].Visible = false end
            for i = 1, 8 do if Objects['Line_' .. i].Visible then Objects['Line_' .. i].Visible = false end end
            if not Objects['BoxOutlineHolder'].Visible then Objects['BoxOutlineHolder'].Visible = true end
            if not Objects['BoxInlineHolder'].Visible then Objects['BoxInlineHolder'].Visible = true end
            local GradTop = Data['CustomGradTop'] or BoxesCfg['Gradients']['Top']
            local GradBot = Data['CustomGradBot'] or BoxesCfg['Gradients']['Bot']
            if Data['LastGradTop'] ~= GradTop or Data['LastGradBot'] ~= GradBot then
                Objects['BoxInlineGradient'].Color = ColorSequence.new({ColorSequenceKeypoint.new(0, GradTop), ColorSequenceKeypoint.new(1, GradBot)})
                Data['LastGradTop'] = GradTop; Data['LastGradBot'] = GradBot
            end
            if BoxesCfg['Filled']['Enabled'] then
                if not Objects['BoxFill'].Visible then Objects['BoxFill'].Visible = true end
                local FillTop = Data['CustomGradTop'] or BoxesCfg['Filled']['Top']
                local FillBot = Data['CustomGradBot'] or BoxesCfg['Filled']['Bot']
                local FillT1, FillT2 = BoxesCfg['Filled']['Transparency'][1], BoxesCfg['Filled']['Transparency'][2]
                if Data['LastFillTop'] ~= FillTop or Data['LastFillBot'] ~= FillBot then
                    Objects['BoxFillGradient'].Color = ColorSequence.new({ColorSequenceKeypoint.new(0, FillTop), ColorSequenceKeypoint.new(1, FillBot)})
                    Data['LastFillTop'] = FillTop; Data['LastFillBot'] = FillBot
                end
                if Data['LastFillT1'] ~= FillT1 or Data['LastFillT2'] ~= FillT2 then
                    Objects['BoxFillGradient'].Transparency = NumSeq({NumKey(0, FillT1), NumKey(1, FillT2)})
                    Data['LastFillT1'] = FillT1; Data['LastFillT2'] = FillT2
                end
            else
                if Objects['BoxFill'].Visible then Objects['BoxFill'].Visible = false end
            end
        end
    else
        if Objects['BoxGlow'].ImageTransparency ~= 1 then Objects['BoxGlow'].ImageTransparency = 1 end
        if Objects['BoxOutlineHolder'].Visible then Objects['BoxOutlineHolder'].Visible = false end
        if Objects['BoxInlineHolder'].Visible then Objects['BoxInlineHolder'].Visible = false end
        if Objects['BoxFill'].Visible then Objects['BoxFill'].Visible = false end
        if Objects['CornerHolder'].Visible then Objects['CornerHolder'].Visible = false end
        for i = 1, 8 do if Objects['Line_' .. i].Visible then Objects['Line_' .. i].Visible = false end end
    end

    if TextsCfg['Name']['Enabled'] then
        if not Objects['TargetName'].Visible then Objects['TargetName'].Visible = true end
        local DisplayName = Data['DisplayName'] or (Player and Player.DisplayName) or "?"
        if Data['LastDisplayName'] ~= DisplayName then Objects['TargetName'].Text = DisplayName; Data['LastDisplayName'] = DisplayName end
        local NameColor = TextsCfg['Name']['Color']
        if Data['LastNameColor'] ~= NameColor then Objects['TargetName'].TextColor3 = NameColor; Data['LastNameColor'] = NameColor end
    else
        if Objects['TargetName'].Visible then Objects['TargetName'].Visible = false end
    end

    if TextsCfg['Distance']['Enabled'] then
        if not Objects['Distance'].Visible then Objects['Distance'].Visible = true end
        if Data['LastDist'] ~= Distance then Objects['Distance'].Text = Format('%dst', Distance); Data['LastDist'] = Distance end
        local DistColor = TextsCfg['Distance']['Color']
        if Data['LastDistColor'] ~= DistColor then Objects['Distance'].TextColor3 = DistColor; Data['LastDistColor'] = DistColor end
    else
        if Objects['Distance'].Visible then Objects['Distance'].Visible = false end
    end

    local HealthCfg = Table['Bars']['Health Bar']
    local ArmorCfg = Table['Bars']['Armor Bar']

    if HealthCfg['Enabled'] then
        local Health = Data['Health'] or 0
        local MaxHealth = Data['MaxHealth'] or 100
        local Ratio = Clamp(Health / MaxHealth, 0, 1)
        if not Objects['LeftBarHolder'].Visible then Objects['LeftBarHolder'].Visible = true end
        if not Objects['HealthBarOutline'].Visible then Objects['HealthBarOutline'].Visible = true end
        local ratioChanged = Data['LastRatio'] ~= Ratio
        if ratioChanged then Objects['HealthBar'].Size = Dim2(1, 0, Ratio, 0); Data['LastRatio'] = Ratio end
        local hue = Ratio * 0.33
        local healthColor = Color3.fromHSV(hue, 1, 1)
        local healthColorDark = Color3.fromHSV(Clamp(hue - 0.05, 0, 0.33), 1, 0.85)
        if Data['LastHealthHue'] ~= hue then
            Objects['HealthBarGradient'].Color = ColorSequence.new({ColorSequenceKeypoint.new(0, healthColor), ColorSequenceKeypoint.new(1, healthColorDark)})
            Data['LastHealthHue'] = hue
        end
        if not Objects['HealthBarText'].Visible then Objects['HealthBarText'].Visible = true end
        local FlooredHealth = Floor(Health)
        if Data['LastHealthFloor'] ~= FlooredHealth or ratioChanged then
            Objects['HealthBarText'].Text = Format('%d', FlooredHealth)
            Objects['HealthBarText'].Position = Dim2(1, -10, 1 - Ratio, 1)
            Data['LastHealthFloor'] = FlooredHealth
        end
    else
        if Objects['HealthBarOutline'].Visible then Objects['HealthBarOutline'].Visible = false end
        if Objects['HealthBarText'].Visible then Objects['HealthBarText'].Visible = false end
        if not ArmorCfg['Enabled'] then if Objects['LeftBarHolder'].Visible then Objects['LeftBarHolder'].Visible = false end end
    end

    if ArmorCfg['Enabled'] then
        local Ratio = Clamp(Data['Armor'] / Data['MaxArmor'], 0, 1)
        if not Objects['BottomBarHolder'].Visible then Objects['BottomBarHolder'].Visible = true end
        if not Objects['ArmorBarOutline'].Visible then Objects['ArmorBarOutline'].Visible = true end
        if Data['LastArmorRatio'] ~= Ratio then Objects['ArmorBar'].Size = Dim2(Ratio, 0, 1, 0); Data['LastArmorRatio'] = Ratio end
        local GradTop, GradMid, GradBot = ArmorCfg['Top'], ArmorCfg['Mid'], ArmorCfg['Bot']
        if Data['LastArmorTop'] ~= GradTop or Data['LastArmorMid'] ~= GradMid or Data['LastArmorBot'] ~= GradBot then
            Objects['ArmorBarGradient'].Color = ColorSequence.new({ColorSequenceKeypoint.new(0, GradTop), ColorSequenceKeypoint.new(0.5, GradMid), ColorSequenceKeypoint.new(1, GradBot)})
            Data['LastArmorTop'] = GradTop; Data['LastArmorMid'] = GradMid; Data['LastArmorBot'] = GradBot
        end
    else
        if Objects['ArmorBarOutline'].Visible then Objects['ArmorBarOutline'].Visible = false end
        if Objects['BottomBarHolder'].Visible then Objects['BottomBarHolder'].Visible = false end
    end

    if TextsCfg['Weapon']['Enabled'] then
        if not Objects['Weapon'].Visible then Objects['Weapon'].Visible = true end
        local WeaponName = Data['CurrentTool'] or "none"
        if Data['LastWeapon'] ~= WeaponName then Objects['Weapon'].Text = WeaponName; Data['LastWeapon'] = WeaponName end
        local WeaponColor = TextsCfg['Weapon']['Color']
        if Data['LastWeaponColor'] ~= WeaponColor then Objects['Weapon'].TextColor3 = WeaponColor; Data['LastWeaponColor'] = WeaponColor end
    else
        if Objects['Weapon'].Visible then Objects['Weapon'].Visible = false end
    end
end

do
    Library:CreateThreads('Renderer', RunService.RenderStepped, function()
        local Now = os.clock()
        if Now - Updates < Frame then return end
        Updates = Now
        CameraPosition = Camera.CFrame.Position
        local PlayerEnabled = Table['Enabled']
        local ChamsCfg = Table['Chams']
        local ChamsOn = ChamsCfg['Enabled']

        for Player, Data in Library['Cache'] do
            if not PlayerEnabled then
                local isLP = (Player == LocalPlayer)
                if not isLP or not Table['ShowLocalPlayer'] then
                    if Data['Objects']['TargetHolder'].Visible then Data['Objects']['TargetHolder'].Visible = false end
                    if Data['Objects']['Highlight'] and Data['Objects']['Highlight'].Enabled then Data['Objects']['Highlight'].Enabled = false end
                    continue
                end
            end
            Library:Update(Player, Data)
            local HL = Data['Objects']['Highlight']
            if HL then
                local Show = ChamsOn and Data['Objects']['TargetHolder'].Visible
                if Show then
                    if not HL.Enabled then HL.Enabled = true end
                    if HL.Adornee ~= Data['Character'] then HL.Adornee = Data['Character'] end
                    local FT = ChamsCfg['FillTransparency']
                    if Data['LastChamsT'] ~= FT then HL.FillTransparency = FT; Data['LastChamsT'] = FT end
                    local FC = ChamsCfg['FillColor']
                    if Data['LastChamsFill'] ~= FC then HL.FillColor = FC; Data['LastChamsFill'] = FC end
                    local OC = ChamsCfg['OutlineColor']
                    if Data['LastChamsOutline'] ~= OC then HL.OutlineColor = OC; Data['LastChamsOutline'] = OC end
                else
                    if HL.Enabled then HL.Enabled = false end
                end
            end
        end
    end)
end

do
    for _, Player in Players:GetPlayers() do Library:AddTarget(Player) end
    Library:CreateThreads('PlayerAdded', Players.PlayerAdded, function(Player) Library:AddTarget(Player) end)
    Library:CreateThreads('PlayerRemoving', Players.PlayerRemoving, function(Player) Library:RemoveTarget(Player) end)
end

do
    function Library:Unload()
        for Player in self['Cache'] do self:RemoveTarget(Player) end
        for _, Conn in self['Connections'] do Conn:Disconnect() end
        Clear(self['Connections'])
        for _, Conn in self['Threads'] do Conn:Disconnect() end
        Clear(self['Threads'])
        if self['Holder'] then self['Holder']:Destroy(); self['Holder'] = nil end
        Clear(self['Cache'])
    end
end

-- ═══════════════════════════════════════════════════════════
-- END SLIMETIME ESP LIBRARY
-- ═══════════════════════════════════════════════════════════

local Esp = getgenv()._ZH_EspLib
local EspTable = Esp.Table
getgenv()._ZH_PlayerESPColor = getgenv()._ZH_PlayerESPColor or Color3.fromRGB(0, 255, 0)

local RS  = game:GetService("RunService")
local PS  = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LT  = game:GetService("Lighting")
local Cam = workspace.CurrentCamera
local LP  = PS.LocalPlayer

local function getChar() return LP.Character end
local function getHRP()  local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

local S = {
    speed=100, infJumpH=50, flySpeed=100, tweenSpeed=100,
    brightness=2, freeCamSens=0.3, freeCamSpeed=0.5, fovVal=70,
}

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/toeerolo-z/ethossuiterewrite/refs/heads/main/ethossuite.lua"))()

local Window = Library:CreateWindow({
    Title = "ZERO HUB",
    Version = "v1.0",
})

local Tog, Opt, Connections = {}, {}, {}
local _cleanupFns = {}
local function onUnload(fn) table.insert(_cleanupFns, fn) end
getgenv()._ZeroWindow = Library
do
    local _origUnload = Window.Unload
    function Window:Unload()
        for _, fn in ipairs(_cleanupFns) do pcall(fn) end
        getgenv()._ZeroWindow = nil
        return _origUnload(self)
    end
end

local function notify(msg, dur)
    task.defer(function()
        pcall(function() Library:Notify({ Title="Zero Hub", Description=msg, Duration=dur or 3 }) end)
    end)
end
local function _flagVal(name) local f=Library.Flags[name]; if type(f)=="table" and f.Value~=nil then return f.Value end; if type(f)=="boolean" then return f end; return false end
local function _flagSet(name,v) local f=Library.Flags[name]; if type(f)=="table" and f.SetValue then pcall(function() f:SetValue(v) end) end end

local Tabs = {}

local CatBball = Window:AddCategory("BASKETBALL")
Tabs.Stamina    = CatBball:AddTab("Inf Stamina")
Tabs.AutoRelease = CatBball:AddTab("Auto Release")

local CatPlayer = Window:AddCategory("PLAYER")
Tabs.Movement = CatPlayer:AddTab("Movement")
Tabs.Utility  = CatPlayer:AddTab("Utility")
Tabs.Misc     = CatPlayer:AddTab("Misc")

local CatESP = Window:AddCategory("ESP")
Tabs.ESP    = CatESP:AddTab("Players")
Tabs.ESPCfg = CatESP:AddTab("Config")

local CatWorld = Window:AddCategory("WORLD")
Tabs.Camera   = CatWorld:AddTab("Camera")
Tabs.Effects  = CatWorld:AddTab("Effects")
Tabs.Perf     = CatWorld:AddTab("Performance")
Tabs.Teleport = CatWorld:AddTab("Teleport")
Tabs.Attach   = CatWorld:AddTab("Attach")

local _settingsTab = Library:CreateSettingsTab(Window)

do
    local menuBox = _settingsTab:AddGroupbox("Auto Hide")
    menuBox:AddToggle("_AutoHide", {
        Text = "Auto Hide Menu",
        Description = "Hide the menu automatically when the script loads (press toggle key to show)",
        Default = false,
        Callback = function(p)
            if p then
                task.defer(function()
                    local main = Window and Window.Screen and Window.Screen:FindFirstChild("Main")
                    if main then
                        main.Visible = false
                        if Window.Cursor then game:GetService("UserInputService").MouseIconEnabled = true end
                        Library:Notify({ Title="Zero Hub", Description="Menu hidden — press "..
                            (Window.ToggleKey and Window.ToggleKey.Name or "RightShift").." to show.", Type="Info", Duration=4 })
                    end
                end)
            end
        end
    })
end

local CharL  = Tabs.Movement:AddGroupbox("Movement")
local CharR  = Tabs.Utility:AddGroupbox("Utility")
local CharR2 = Tabs.Misc:AddGroupbox("Misc")

local VizL   = Tabs.ESP:AddGroupbox("Player ESP")
local VizL2  = Tabs.ESP:AddGroupbox("Local Player ESP")
local VizR   = Tabs.ESPCfg:AddGroupbox("ESP Config")

local StamBox    = Tabs.Stamina:AddGroupbox("Stamina")
local ReleaseBox = Tabs.AutoRelease:AddGroupbox("Auto Release")

local WorldL2 = Tabs.Camera:AddGroupbox("Camera")
local WorldR  = Tabs.Effects:AddGroupbox("Effects")
local WorldR2 = Tabs.Perf:AddGroupbox("FPS Boost")
local WorldR3 = Tabs.Teleport:AddGroupbox("Tools")
local NavL    = Tabs.Teleport:AddGroupbox("Teleport")
local NavR    = Tabs.Attach:AddGroupbox("Attach")
local NavR2   = Tabs.Attach:AddGroupbox("Attach Config")

local _cancelTween = false; local _tweenVersion = 0
local function tweenTo(cf, cancelCheck)
    local hrp=getHRP(); if not hrp then return end
    hrp.AssemblyLinearVelocity=Vector3.zero
    local tweenMode=Library.Options["TweenMode"] and Library.Options["TweenMode"].Value or "Normal"
    local target=cf.Position
    local vim=game:GetService("VirtualInputManager")
    pcall(function() vim:SendKeyEvent(true,Enum.KeyCode.W,false,game) end)
    local function releaseW() pcall(function() vim:SendKeyEvent(false,Enum.KeyCode.W,false,game) end) end
    _tweenVersion=_tweenVersion+1; local myVersion=_tweenVersion
    local function doLerp(from, to)
        if (to-from).Magnitude<1 then return true end
        local done=false; local success=false; local tweenFrame=CFrame.new(from)
        RS:BindToRenderStep("QDTween",Enum.RenderPriority.Input.Value,function(dt)
            if _tweenVersion~=myVersion then RS:UnbindFromRenderStep("QDTween"); done=true; return end
            if _cancelTween then _cancelTween=false; releaseW(); RS:UnbindFromRenderStep("QDTween"); done=true; return end
            if cancelCheck and cancelCheck() then releaseW(); RS:UnbindFromRenderStep("QDTween"); done=true; return end
            local c=getChar(); if not c then RS:UnbindFromRenderStep("QDTween"); done=true; return end
            local h=c:FindFirstChild("HumanoidRootPart"); if not h then RS:UnbindFromRenderStep("QDTween"); done=true; return end
            local mv=to-tweenFrame.Position
            if mv.Magnitude<=1 then h.AssemblyLinearVelocity=Vector3.zero; h.CFrame=CFrame.new(to,to+(to-from).Unit); success=true; RS:UnbindFromRenderStep("QDTween"); done=true; return end
            tweenFrame=tweenFrame+mv.Unit*S.tweenSpeed*dt
            local hDir=Vector3.new(mv.X,0,mv.Z); if hDir.Magnitude>0 then tweenFrame=CFrame.new(tweenFrame.Position,tweenFrame.Position+hDir.Unit) end
            h.AssemblyLinearVelocity=Vector3.zero; h.CFrame=tweenFrame
        end)
        while not done do task.wait() end
        return success
    end
    if tweenMode=="Normal" then
        local p0=hrp.Position; if doLerp(p0,target) then local h=getHRP(); if h then h.CFrame=cf end end
    elseif tweenMode=="Safe" then
        local height=Library.Options["SafeModeHeight"] and Library.Options["SafeModeHeight"].Value or 1000
        local up1=Vector3.new(hrp.Position.X,target.Y+height,hrp.Position.Z); hrp.CFrame=CFrame.new(up1)
        local up2=Vector3.new(target.X,target.Y+height,target.Z)
        if doLerp(up1,up2) then local h=getHRP(); if h then h.CFrame=cf end end
    end
    releaseW()
end

Library:Notify({ Title = "Zero Hub", Description = "Zero Hub v1.0 loaded.", Type = "Success", Duration = 4 })

-- ═══════════════════════════════════════════════════════════
-- MOVEMENT TAB
-- ═══════════════════════════════════════════════════════════
Tog.Fly = CharL:AddToggle("Fly", {
    Text ="Fly", Description = "Fly around the map freely", Default=false,
    Callback=function(p)
        if p then
            RS:BindToRenderStep("QDFly",Enum.RenderPriority.Input.Value,function(dt)
                local c=getChar(); if not c then return end
                local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                if not getgenv()._QD_flyFrame then getgenv()._QD_flyFrame=hrp.CFrame end
                local frame=getgenv()._QD_flyFrame; local cf=Cam.CFrame; local mv=Vector3.zero
                local fmode=Library.Options["FlyMode"] and Library.Options["FlyMode"].Value or "MoveDirection"
                if fmode=="MoveDirection" then
                    local fwd=Vector3.new(cf.LookVector.X,0,cf.LookVector.Z).Unit; local rgt=Vector3.new(cf.RightVector.X,0,cf.RightVector.Z).Unit
                    if UIS:IsKeyDown(Enum.KeyCode.W) then mv=mv+fwd end; if UIS:IsKeyDown(Enum.KeyCode.S) then mv=mv-fwd end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then mv=mv-rgt end; if UIS:IsKeyDown(Enum.KeyCode.D) then mv=mv+rgt end
                else
                    local hum=c:FindFirstChildOfClass("Humanoid")
                    if hum and hum.MoveDirection.Magnitude>0 then
                        local fwd2=Vector3.new(cf.LookVector.X,0,cf.LookVector.Z).Unit; local rgt2=Vector3.new(cf.RightVector.X,0,cf.RightVector.Z).Unit
                        mv=mv+fwd2*hum.MoveDirection:Dot(fwd2)+rgt2*hum.MoveDirection:Dot(rgt2)
                    end
                end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then mv=mv+Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv=mv-Vector3.new(0,1,0) end
                if mv.Magnitude>0 then frame=frame+mv.Unit*S.flySpeed*dt end
                local fwd3=Vector3.new(cf.LookVector.X,0,cf.LookVector.Z)
                if fwd3.Magnitude>0 then frame=CFrame.new(frame.Position,frame.Position+fwd3.Unit) end
                getgenv()._QD_flyFrame=frame; hrp.AssemblyLinearVelocity=Vector3.zero; hrp.CFrame=frame
            end)
        else RS:UnbindFromRenderStep("QDFly"); getgenv()._QD_flyFrame=nil end
    end})
Tog.Fly:AddKeybind({ Default = Enum.KeyCode.Y, Mode = "Toggle" })
Opt.FlySpeed = CharL:AddSlider("FlySpeed", { Text ="Fly Speed", Default=100, Min =0, Max =5000, Rounding =0, Callback=function(v) S.flySpeed=v end })
Opt.FlyMode  = CharL:AddDropdown("FlyMode", { Text ="Fly Mode", Description = "Choose how fly direction works", Values ={"MoveDirection","Camera LookVector"}, Default="MoveDirection", Multi=false, Callback=function() end })
Opt.TweenMode      = CharL:AddDropdown("TweenMode", { Text ="Safe Mode", Description = "Normal goes direct, Safe flies up first to avoid walls", Values ={"Normal","Safe"}, Default="Normal", Multi=false, Callback=function() end })
Opt.SafeModeHeight = CharL:AddSlider("SafeModeHeight", { Text ="Safe Height", Default=1000, Min =0, Max =100000, Rounding =0, Callback=function() end })
CharL:AddButton({ Text ="Cancel Tween", Func =function() _cancelTween=true end })

Tog.Speedhack = CharL:AddToggle("Speedhack", {
    Text ="Speedhack", Description = "Move faster than normal walk speed", Default=false,
    Callback=function(p)
        if p then RS:BindToRenderStep("QDSpeed",Enum.RenderPriority.Input.Value,function(dt)
            local c=getChar(); if not c then return end; local hum=c:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health<=0 then return end
            local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            if hum.MoveDirection.Magnitude>0 then hrp.CFrame=hrp.CFrame+hum.MoveDirection*S.speed*dt end
        end) else RS:UnbindFromRenderStep("QDSpeed") end
    end})
Tog.Speedhack:AddKeybind({ Default = Enum.KeyCode.N, Mode = "Toggle" })
Opt.SpeedhackSpeed = CharL:AddSlider("SpeedhackSpeed", { Text ="Speedhack Speed", Default=100, Min =0, Max =5000, Rounding =0, Callback=function(v) S.speed=v end })

local ijConn=nil
Tog.InfiniteJump = CharL:AddToggle("InfiniteJump", {
    Text ="Infinite Jump", Description = "Jump unlimited times in the air", Default=false,
    Callback=function(p)
        if ijConn then ijConn:Disconnect(); ijConn=nil end
        if p then ijConn=UIS.InputBegan:Connect(function(input,gpe)
            if gpe or input.KeyCode~=Enum.KeyCode.Space then return end
            local hrp=getHRP(); if not hrp then return end
            hrp.AssemblyLinearVelocity=Vector3.new(hrp.AssemblyLinearVelocity.X,S.infJumpH,hrp.AssemblyLinearVelocity.Z)
        end) end
    end})
Tog.InfiniteJump:AddKeybind({ Default = Enum.KeyCode.H, Mode = "Toggle" })
Opt.InfiniteJumpHeight = CharL:AddSlider("InfiniteJumpHeight", { Text ="Jump Height", Default=50, Min =0, Max =1000, Rounding =0, Callback=function(v) S.infJumpH=v end })

local noclipConn=nil
Tog.Noclip = CharL:AddToggle("Noclip", {
    Text ="Noclip", Description = "Walk through walls and solid objects", Default=false,
    Callback=function(p)
        if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
        if not p then return end
        local cached={}; local lastChar=nil
        noclipConn=RS.Heartbeat:Connect(function()
            local c=getChar()
            if c~=lastChar then cached={}; lastChar=c; if c then for _,d in ipairs(c:GetDescendants()) do if d:IsA("BasePart") then cached[#cached+1]=d end end end end
            for _,part in ipairs(cached) do if part.Parent then part.CanCollide=false end end
        end)
    end})
Tog.Noclip:AddKeybind({ Default = Enum.KeyCode.T, Mode = "Toggle" })

local _jumpFixConn = nil
Tog.JumpFix = CharL:AddToggle("JumpFix", {
    Text ="Jump Fix", Description = "Force-enable jumping (bypasses any jump lock)", Default=false,
    Callback=function(p)
        if _jumpFixConn then _jumpFixConn:Disconnect(); _jumpFixConn=nil end
        if not p then return end
        _jumpFixConn = RS.Heartbeat:Connect(function()
            local hum = getHum(); if not hum then return end
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                if hum.JumpPower <= 0 then hum.JumpPower = 50 end
                if hum.JumpHeight <= 0 then hum.JumpHeight = 7.2 end
                hum.UseJumpPower = true
            end)
        end)
    end})

-- ═══════════════════════════════════════════════════════════
-- UTILITY TAB
-- ═══════════════════════════════════════════════════════════
local _noAnimsConn=nil; local _noAnimsCharConn=nil
local function _killAnims()
    local c=getChar(); if not c then return end
    local hum=c:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local anim=hum:FindFirstChildOfClass("Animator"); if not anim then return end
    for _,track in ipairs(anim:GetPlayingAnimationTracks()) do pcall(function() track:Stop(0); track:Destroy() end) end
end
Tog.NoAnims = CharR:AddToggle("NoAnims", {
    Text ="No Anims", Description = "Stop all character animations (survives respawn)", Default=false,
    Callback=function(p)
        if _noAnimsConn then _noAnimsConn:Disconnect(); _noAnimsConn=nil end
        if _noAnimsCharConn then _noAnimsCharConn:Disconnect(); _noAnimsCharConn=nil end
        if p then
            _killAnims()
            _noAnimsConn=RS.Heartbeat:Connect(function() _killAnims() end)
            _noAnimsCharConn=LP.CharacterAdded:Connect(function() task.wait(0.5); if _flagVal("NoAnims") then _killAnims() end end)
        end
    end})

;(function()
    local _animSpeedConn=nil; local _animSpeed=1
    local function applyAnimSpeed(speed)
        pcall(function() local char=getChar(); if not char then return end; local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end; local anim=hum:FindFirstChildOfClass("Animator"); if not anim then return end; for _,track in ipairs(anim:GetPlayingAnimationTracks()) do pcall(function() track:AdjustSpeed(speed) end) end end)
    end
    Tog.AnimSpeed = CharR:AddToggle("AnimSpeed", { Text ="Anim Speed", Description = "Speed up or slow down your animations", Default=false, Callback=function(p) if _animSpeedConn then _animSpeedConn:Disconnect(); _animSpeedConn=nil end; if p then _animSpeedConn=RS.Heartbeat:Connect(function() applyAnimSpeed(_animSpeed) end) else applyAnimSpeed(1) end end })
    Opt.AnimSpeedSlider = CharR:AddSlider("AnimSpeedSlider", { Text ="Speed", Default=1, Min =0.1, Max =200, Rounding =1, Callback=function(v) _animSpeed=v end })
    onUnload(function() if _animSpeedConn then _animSpeedConn:Disconnect(); _animSpeedConn=nil end; applyAnimSpeed(1) end)
end)()

local afkConn=nil; local _afkLoop=false
Tog.AntiAFK = CharR:AddToggle("AntiAFK", { Text ="Anti AFK", Description = "Prevent getting kicked for being idle", Default=false, Callback=function(p)
    if afkConn then afkConn:Disconnect(); afkConn=nil end; _afkLoop=false
    if not p then return end
    _afkLoop=true
    local vim=game:GetService("VirtualInputManager")
    local function nudge() pcall(function() vim:SendKeyEvent(true,Enum.KeyCode.Space,false,game); task.wait(0.1); vim:SendKeyEvent(false,Enum.KeyCode.Space,false,game) end) end
    task.spawn(function() while _afkLoop do task.wait(240); if _afkLoop then nudge() end end end)
end})

CharR:AddButton({ Text ="Kill Self", Func =function() local hum=getHum(); if hum then hum.Health=0 end end })

-- ═══════════════════════════════════════════════════════════
-- MISC TAB
-- ═══════════════════════════════════════════════════════════
;(function()
    local _tpDeathConns = {}
    local _tpDeathPos = nil
    local function cleanupDeathConns()
        for _, c in ipairs(_tpDeathConns) do pcall(function() c:Disconnect() end) end
        table.clear(_tpDeathConns)
    end
    Tog.TPOnDeath = CharR2:AddToggle("TPOnDeath", { Text ="TP Back on Death", Description = "Respawn where you died instead of at spawn", Default=false, Callback=function(p)
        cleanupDeathConns(); _tpDeathPos = nil
        if not p then return end
        local function hookChar(char)
            if not char then return end
            local hum = char:WaitForChild("Humanoid", 5); if not hum then return end
            local hrp = char:WaitForChild("HumanoidRootPart", 5); if not hrp then return end
            _tpDeathPos = hrp.CFrame
            local posConn = RS.Heartbeat:Connect(function()
                if hum.Health > 0 and hrp and hrp.Parent then _tpDeathPos = hrp.CFrame end
            end)
            table.insert(_tpDeathConns, posConn)
            local diedConn; diedConn = hum.Died:Connect(function()
                posConn:Disconnect()
                if not _tpDeathPos then return end
                local savedCF = _tpDeathPos
                task.spawn(function()
                    local newChar = LP.CharacterAdded:Wait(); task.wait(0.5)
                    local newHRP = newChar:WaitForChild("HumanoidRootPart", 10); if not newHRP then return end
                    local newHum = newChar:WaitForChild("Humanoid", 5)
                    if newHum then newHum:WaitForChild("Animator", 3) end
                    task.wait(0.3)
                    if not _flagVal("TPOnDeath") then return end
                    for i = 1, 20 do
                        if not newHRP or not newHRP.Parent then break end
                        newHRP.CFrame = savedCF; newHRP.AssemblyLinearVelocity = Vector3.zero; newHRP.AssemblyAngularVelocity = Vector3.zero
                        task.wait(0.1)
                        if (newHRP.Position - savedCF.Position).Magnitude < 5 then break end
                    end
                end)
            end)
            table.insert(_tpDeathConns, diedConn)
        end
        hookChar(LP.Character)
        local charConn = LP.CharacterAdded:Connect(function(char) task.wait(0.3); hookChar(char) end)
        table.insert(_tpDeathConns, charConn)
    end})
    onUnload(function() cleanupDeathConns() end)
end)()

CharR2:AddLabel("Requires RakNet support in your executor")
do
    local RakNet = raknet or rnet
    local Hooked = false
    local function Hook(Packet)
        if Packet.PacketId == 0x1B then
            local Buffer = Packet.AsBuffer
            buffer.writeu32(Buffer, 1, 0xFFFFFF)
            Packet:SetData(Buffer)
        end
    end
    Tog.RakNetDesync = CharR2:AddToggle("RakNetDesync", {
        Text ="Invisibility", Description = "Become invisible to other players", Default=false,
        Callback=function(p)
            if not RakNet then notify("RakNet not found", 3); _flagSet("RakNetDesync",false); return end
            if p and not Hooked then
                RakNet.add_send_hook(Hook); Hooked = true
                task.delay(1, function() local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.Health = 0 end end)
            elseif not p and Hooked then
                RakNet.remove_send_hook(Hook); Hooked = false
            end
        end})
    onUnload(function() if Hooked and RakNet then pcall(function() RakNet.remove_send_hook(Hook) end); Hooked=false end end)
end

do
    local _chatLogGui = nil
    local _chatLogConns = {}
    local function destroyChatLogger()
        for _, c in ipairs(_chatLogConns) do pcall(function() c:Disconnect() end) end
        _chatLogConns = {}
        if _chatLogGui then pcall(function() _chatLogGui:Destroy() end); _chatLogGui = nil end
    end
    local function buildChatLogger()
        destroyChatLogger()
        local sg = Instance.new("ScreenGui"); sg.Name = "ZH_ChatLogger"; sg.ResetOnSpawn = false; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() sg.Parent = game:GetService("CoreGui") end)
        if not sg.Parent then sg.Parent = LP:FindFirstChildOfClass("PlayerGui") end
        _chatLogGui = sg
        local main = Instance.new("Frame"); main.Name = "MainFrame"; main.Parent = sg
        main.BackgroundColor3 = Color3.fromRGB(43, 43, 43); main.BorderSizePixel = 0
        main.Position = UDim2.new(0.051, 0, 0.117, 0); main.Size = UDim2.new(0, 440, 0, 360)
        main.Active = true; main.Draggable = true; Instance.new("UICorner", main)
        local close = Instance.new("TextButton"); close.Name = "Close"; close.Parent = main
        close.BackgroundTransparency = 1; close.BorderSizePixel = 0
        close.Position = UDim2.new(0.932, 0, 0, 0); close.Size = UDim2.new(0, 30, 0, 30)
        close.Font = Enum.Font.SourceSans; close.Text = "X"; close.TextColor3 = Color3.fromRGB(255, 255, 255); close.TextSize = 22
        close.MouseButton1Click:Connect(function() destroyChatLogger(); if Tog.ChatLogger then pcall(function() Tog.ChatLogger:SetValue(false) end) end end)
        local title = Instance.new("TextLabel"); title.Parent = main; title.BackgroundTransparency = 1; title.BorderSizePixel = 0
        title.Position = UDim2.new(0, 10, 0, 0); title.Size = UDim2.new(0, 200, 0, 30)
        title.Font = Enum.Font.SourceSansBold; title.Text = "Chat Logger"; title.TextColor3 = Color3.fromRGB(255, 255, 255); title.TextSize = 18; title.TextXAlignment = Enum.TextXAlignment.Left
        local logsFrame = Instance.new("ScrollingFrame"); logsFrame.Name = "ChatLogsFrame"; logsFrame.Parent = main
        logsFrame.BackgroundTransparency = 1; logsFrame.BorderSizePixel = 0
        logsFrame.Position = UDim2.new(0, 0, 0.083, 0); logsFrame.Size = UDim2.new(0, 440, 0, 330)
        logsFrame.CanvasSize = UDim2.new(0, 0, 0, 0); logsFrame.ScrollBarThickness = 4; logsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Instance.new("UICorner", logsFrame)
        local layout = Instance.new("UIListLayout"); layout.Parent = logsFrame; layout.SortOrder = Enum.SortOrder.LayoutOrder
        local function createLog(text)
            local lbl = Instance.new("TextLabel"); lbl.Parent = logsFrame; lbl.Text = text
            lbl.BackgroundTransparency = 1; lbl.BorderSizePixel = 0; lbl.Size = UDim2.new(1, 0, 0, 17)
            lbl.Font = Enum.Font.SourceSans; lbl.TextColor3 = Color3.fromRGB(255, 255, 255); lbl.TextSize = 18; lbl.TextWrapped = true; lbl.TextXAlignment = Enum.TextXAlignment.Left
            task.delay(15, function() pcall(function() lbl:Destroy() end) end)
            pcall(function()
                local line = text .. " | date : " .. os.date() .. "\n"
                if isfile and isfile("chatlogs.txt") then if appendfile then appendfile("chatlogs.txt", line) end
                else if writefile then writefile("chatlogs.txt", line) end end
            end)
        end
        for _, plr in ipairs(PS:GetPlayers()) do
            local conn = plr.Chatted:Connect(function(msg) createLog("[" .. plr.Name .. "]: " .. msg) end)
            table.insert(_chatLogConns, conn)
        end
        local addedConn = PS.PlayerAdded:Connect(function(plr)
            local conn = plr.Chatted:Connect(function(msg) createLog("[" .. plr.Name .. "]: " .. msg) end)
            table.insert(_chatLogConns, conn)
        end)
        table.insert(_chatLogConns, addedConn)
    end
    Tog.ChatLogger = CharR2:AddToggle("ChatLogger", { Text = "Chat Logger", Description = "Logs all chat messages to a draggable window and chatlogs.txt", Default = false,
        Callback = function(p) if p then buildChatLogger() else destroyChatLogger() end end })
    onUnload(function() destroyChatLogger() end)
end

-- ═══════════════════════════════════════════════════════════
-- BASKETBALL TAB
-- ═══════════════════════════════════════════════════════════
do
    local _infStamConn = nil
    Tog.InfStamina = StamBox:AddToggle("InfStamina", {
        Text = "Infinite Stamina", Description = "Stamina never drains", Default = false,
        Callback = function(p)
            if _infStamConn then _infStamConn:Disconnect(); _infStamConn = nil end
            if not p then return end
            _infStamConn = RS.Heartbeat:Connect(function()
                local c = getChar(); if not c then return end
                pcall(function() c:SetAttribute("Stamina", 100) end)
            end)
        end
    })
    onUnload(function() if _infStamConn then _infStamConn:Disconnect(); _infStamConn = nil end end)
end

-- ═══════════════════════════════════════════════════════════
-- AUTO RELEASE TAB
-- ═══════════════════════════════════════════════════════════
do
    local ShootEvent = game:GetService("ReplicatedStorage").Events.States.Shoot
    local UpdateSetting = game:GetService("ReplicatedStorage").Events.UpdateSetting
    local _autoReleaseActive = false
    local _releaseConns = {}
    local _savedMeterType = nil

    local function cleanRelease()
        for _, c in ipairs(_releaseConns) do pcall(function() c:Disconnect() end) end
        table.clear(_releaseConns)
    end

    local METER_NAMES = {"VerticalMeter", "HorizontalMeter", "FunnelMeter"}

    local function anyMeterActive(char)
        for _, mName in ipairs(METER_NAMES) do
            local m = char:FindFirstChild(mName)
            if m and m.Enabled then return true end
        end
        return false
    end

    local function hookAllMeters(char)
        local fired = false

        local shootConn = char:GetAttributeChangedSignal("Shooting"):Connect(function()
            if char:GetAttribute("Shooting") then
                fired = false
            end
        end)
        table.insert(_releaseConns, shootConn)

        for _, mName in ipairs(METER_NAMES) do
            local meter = char:FindFirstChild(mName)
            if not meter then continue end

            local timConn = meter:GetAttributeChangedSignal("MeterTiming"):Connect(function()
                if not _autoReleaseActive or fired then return end
                if not char:GetAttribute("Shooting") then return end
                local timing = meter:GetAttribute("MeterTiming") or 0
                local green = meter:GetAttribute("GreenTiming") or 101
                if timing >= green then
                    fired = true
                    pcall(function() ShootEvent:FireServer(false) end)
                end
            end)
            table.insert(_releaseConns, timConn)
        end
    end

    Tog.AutoRelease = ReleaseBox:AddToggle("AutoRelease", {
        Text = "Auto Perfect Release", Description = "Releases your shot at the green window",
        Default = false,
        Callback = function(p)
            cleanRelease()
            _autoReleaseActive = p
            if not p then
                if _savedMeterType then
                    pcall(function() UpdateSetting:FireServer("MeterType", _savedMeterType) end)
                    _savedMeterType = nil
                end
                return
            end
            local c = getChar()
            if c and not anyMeterActive(c) then
                _savedMeterType = "Off"
                pcall(function() UpdateSetting:FireServer("MeterType", "Vertical") end)
                task.wait(0.3)
            end
            c = getChar()
            if c then hookAllMeters(c) end
            local charConn = LP.CharacterAdded:Connect(function(newChar)
                task.wait(1)
                if not _autoReleaseActive then return end
                if not anyMeterActive(newChar) then
                    pcall(function() UpdateSetting:FireServer("MeterType", "Vertical") end)
                    task.wait(0.3)
                end
                hookAllMeters(newChar)
            end)
            table.insert(_releaseConns, charConn)
        end
    })

    onUnload(function()
        _autoReleaseActive = false; cleanRelease()
        if _savedMeterType then
            pcall(function() UpdateSetting:FireServer("MeterType", _savedMeterType) end)
            _savedMeterType = nil
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- ESP TAB
-- ═══════════════════════════════════════════════════════════
;(function()
Tog.PlayerESPEnabled = VizL:AddToggle("PlayerESPEnabled", { Text = "Player ESP", Description = "Show boxes and info on all players", Default = false,
    Callback = function(p) EspTable.Enabled = p end })
Opt.PlayerESPColor = VizL:AddColorPicker("PlayerESPColor", { Default = Color3.fromRGB(0, 255, 0),
    Callback = function(v)
        getgenv()._ZH_PlayerESPColor = v
        for key, data in pairs(Esp.Cache) do
            if data['Player'] then data['CustomGradTop'] = v; data['CustomGradBot'] = v; data['LastGradTop'] = nil; data['LastGradBot'] = nil; data['LastGlowTop'] = nil; data['LastGlowBot'] = nil; data['LastFillTop'] = nil; data['LastFillBot'] = nil end
        end
    end })
Tog.ShowLocalESP = VizL2:AddToggle("ShowLocalESP", { Text = "Show Local Player", Description = "Show ESP on yourself", Default = false,
    Callback = function(p)
        EspTable.ShowLocalPlayer = p
        if p and not Esp.Cache[LP] then Esp:AddTarget(LP)
        elseif not p and Esp.Cache[LP] then Esp:RemoveTarget(LP) end
    end })
Tog.ESPBoxes = VizR:AddToggle("ESPBoxes", { Text = "Boxes", Description = "Show bounding boxes on players", Default = true, Callback = function(p) EspTable.Boxes.Enabled = p end })
Tog.ESPGlow = VizR:AddToggle("ESPGlow", { Text = "Box Glow", Description = "Show glow effect around boxes", Default = true, Callback = function(p) EspTable.Boxes["Box Glow"].Enabled = p end })
Tog.ESPChams = VizR:AddToggle("ESPChams", { Text = "Chams", Description = "Highlight players through walls", Default = false, Callback = function(p) EspTable.Chams.Enabled = p end })
Tog.ESPShowName = VizR:AddToggle("ESPShowName", { Text = "Name", Description = "Display player names", Default = true, Callback = function(p) EspTable.Texts.Name.Enabled = p end })
Tog.ESPShowDist = VizR:AddToggle("ESPShowDist", { Text = "Distance", Description = "Display distance values", Default = true, Callback = function(p) EspTable.Texts.Distance.Enabled = p end })
Tog.ESPShowHP = VizR:AddToggle("ESPShowHP", { Text = "Health Bar", Description = "Display health bars", Default = true, Callback = function(p) EspTable.Bars["Health Bar"].Enabled = p end })
Tog.ESPShowWeapon = VizR:AddToggle("ESPShowWeapon", { Text = "Weapon", Description = "Display equipped weapon name", Default = true, Callback = function(p) EspTable.Texts.Weapon.Enabled = p end })
VizR:AddLabel("Range")
Opt.ESPDist = VizR:AddSlider("ESPDist", { Text = "Max Distance", Default = 7520, Min = 100, Max = 15000, Rounding = 0, Callback = function(v) EspTable.Distance = v end })
VizR:AddLabel("Box Style")
Opt.BoxType = VizR:AddDropdown("BoxType", { Text = "Box Type", Description = "Choose box rendering style", Values = {"2D", "Corner"}, Default = "2D", Multi = false, Callback = function(v) EspTable.Boxes.Type = v end })
VizR:AddLabel("Glow")
Opt.GlowT1 = VizR:AddSlider("GlowT1", { Text = "Glow Top Trans", Default = 0.75, Min = 0, Max = 1, Rounding = 2, Callback = function(v) EspTable.Boxes["Box Glow"].Transparency[1] = v end })
Opt.GlowT2 = VizR:AddSlider("GlowT2", { Text = "Glow Bot Trans", Default = 0.75, Min = 0, Max = 1, Rounding = 2, Callback = function(v) EspTable.Boxes["Box Glow"].Transparency[2] = v end })
VizR:AddLabel("Chams")
Opt.ChamsFillT = VizR:AddSlider("ChamsFillT", { Text = "Chams Fill Trans", Default = 0, Min = 0, Max = 1, Rounding = 2, Callback = function(v) EspTable.Chams.FillTransparency = v end })
Opt.ChamsColor = VizR:AddColorPicker("ChamsColor", { Default = Color3.fromRGB(255, 255, 255),
    Callback = function(v) EspTable.Chams.FillColor = v end })
VizR:AddLabel("Colors")
Opt.BoxTopColor = VizR:AddColorPicker("BoxTopColor", { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) EspTable.Boxes.Gradients.Top = v; EspTable.Boxes["Box Glow"].Top = v end })
Opt.BoxBotColor = VizR:AddColorPicker("BoxBotColor", { Default = Color3.fromRGB(255, 255, 255), Callback = function(v) EspTable.Boxes.Gradients.Bot = v; EspTable.Boxes["Box Glow"].Bot = v end })

onUnload(function() pcall(function() if Esp and Esp.Unload then Esp:Unload() end end) end)
end)()

-- ═══════════════════════════════════════════════════════════
-- CAMERA TAB
-- ═══════════════════════════════════════════════════════════
;(function()
local specTarget=nil; local specConn=nil
local function buildSpecList() local list={"--"}; for _,plr in ipairs(PS:GetPlayers()) do if plr~=LP then table.insert(list,plr.Name) end end; return list end
Opt.SpectatePlayers = WorldL2:AddDropdown("SpectatePlayers", { Text ="Spectate Player", Description = "Watch the game from another player's view", Values =buildSpecList(), Default=nil, Multi=false, Callback=function(v) specTarget=type(v)=="table" and next(v) or v end })
WorldL2:AddButton({ Text ="Spectate / Stop", Func =function()
    if specConn then pcall(function() specConn:Disconnect() end); specConn=nil
        local c=getChar(); Cam.CameraSubject=c and c:FindFirstChildOfClass("Humanoid") or c; Cam.CameraType=Enum.CameraType.Custom; return end
    local name=tostring(specTarget or ""); local plr=PS:FindFirstChild(name); local char=plr and plr.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    Cam.CameraSubject=hum; Cam.CameraType=Enum.CameraType.Custom
    specConn=plr.CharacterAdded:Connect(function(c) task.wait(0.5); local h=c:FindFirstChildOfClass("Humanoid"); if h then Cam.CameraSubject=h end end)
end})

local noFogConn=nil
local _savedFogStart, _savedFogEnd
Tog.NoFog = WorldL2:AddToggle("NoFog", { Text ="No Fog", Description = "Remove fog and haze effects", Default=false,
    Callback=function(p)
        if noFogConn then noFogConn:Disconnect(); noFogConn=nil end
        if p then
            _savedFogStart = _savedFogStart or LT.FogStart
            _savedFogEnd = _savedFogEnd or LT.FogEnd
            LT.FogStart=1e9; LT.FogEnd=1e9
            local atmos=LT:FindFirstChildOfClass("Atmosphere")
            if atmos then atmos.Density=0; atmos.Haze=0; atmos.Glare=0 end
            for _,v in ipairs(LT:GetChildren()) do
                if v:IsA("BlurEffect") then v.Enabled=false end
            end
            noFogConn=RS.Heartbeat:Connect(function()
                if LT.FogEnd<1e8 then LT.FogStart=1e9; LT.FogEnd=1e9 end
                local a=LT:FindFirstChildOfClass("Atmosphere")
                if a and a.Density>0 then a.Density=0; a.Haze=0; a.Glare=0 end
            end)
        else
            LT.FogStart=_savedFogStart or 0; LT.FogEnd=_savedFogEnd or 100000
            local atmos=LT:FindFirstChildOfClass("Atmosphere")
            if atmos then atmos.Density=0.395; atmos.Haze=0; atmos.Glare=0 end
            for _,v in ipairs(LT:GetChildren()) do
                if v:IsA("BlurEffect") then v.Enabled=true end
            end
        end
    end})
Tog.NoAtmosphere = WorldL2:AddToggle("NoAtmosphere", { Text ="No Effects", Description = "Disable bloom, blur, sun rays and color correction", Default=false,
    Callback=function(p)
        for _,v in ipairs(LT:GetChildren()) do
            if v:IsA("PostEffect") then
                pcall(function() v.Enabled = not p end)
            end
        end
        local atmos=LT:FindFirstChildOfClass("Atmosphere")
        if atmos then
            if p then atmos.Density=0; atmos.Offset=0; atmos.Haze=0; atmos.Glare=0
            else atmos.Density=0.395; atmos.Offset=0; atmos.Haze=0; atmos.Glare=0 end
        end
    end})

local fbConn=nil
Tog.FullBright = WorldL2:AddToggle("FullBright", { Text ="FullBright", Description = "Make everything bright with no shadows", Default=false,
    Callback=function(p)
        if fbConn then fbConn:Disconnect(); fbConn=nil end
        if p then fbConn=RS.RenderStepped:Connect(function() LT.Brightness=S.brightness; LT.ClockTime=14; LT.FogEnd=100000; LT.GlobalShadows=false end)
        else LT.Brightness=1; LT.ClockTime=14; LT.FogEnd=1000000; LT.GlobalShadows=true end
    end})
Opt.Brightness = WorldL2:AddSlider("Brightness", { Text ="Brightness", Default=2, Min =0, Max =10, Rounding =1, Callback=function(v) S.brightness=v end })

local _ambientConn=nil; local _ambientColor=Color3.fromRGB(128,128,128)
Tog.CustomAmbient = WorldL2:AddToggle("CustomAmbient", { Text ="World Ambient", Description = "Change the world lighting color", Default=false,
    Callback=function(p)
        if _ambientConn then _ambientConn:Disconnect(); _ambientConn=nil end
        if p then _ambientConn=RS.RenderStepped:Connect(function() LT.Ambient=_ambientColor; LT.OutdoorAmbient=_ambientColor end)
        else LT.Ambient=Color3.fromRGB(0,0,0); LT.OutdoorAmbient=Color3.fromRGB(128,128,128) end
    end})
Opt.WorldAmbient = WorldL2:AddColorPicker("WorldAmbient", { Default=Color3.fromRGB(128,128,128), Callback=function(v) _ambientColor=v; if _ambientConn then LT.Ambient=v; LT.OutdoorAmbient=v end end })

local freecamConns={}; local _fcPitch=0; local _fcYaw=0; local _fcPos=Vector3.zero
Tog.Freecam = WorldL2:AddToggle("Freecam", { Text ="Free Cam", Description = "Fly the camera around freely with WASD", Default=false,
    Callback=function(p)
        for _,c in ipairs(freecamConns) do pcall(function() c:Disconnect() end) end; freecamConns={}
        UIS.MouseBehavior=Enum.MouseBehavior.Default
        if not p then Cam.CameraType=Enum.CameraType.Custom; return end
        local cf=Cam.CFrame; _fcPos=cf.Position
        _fcYaw=math.atan2(-cf.LookVector.X,-cf.LookVector.Z)
        _fcPitch=math.asin(math.clamp(cf.LookVector.Y,-1,1))
        Cam.CameraType=Enum.CameraType.Scriptable
        local rmb=false
        table.insert(freecamConns,UIS.InputBegan:Connect(function(inp,gpe) if gpe then return end; if inp.UserInputType==Enum.UserInputType.MouseButton2 then rmb=true end end))
        table.insert(freecamConns,UIS.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton2 then rmb=false; UIS.MouseBehavior=Enum.MouseBehavior.Default end end))
        table.insert(freecamConns,RS.RenderStepped:Connect(function(dt)
            if rmb then local d=UIS:GetMouseDelta(); _fcYaw=_fcYaw-d.X*S.freeCamSens*0.003; _fcPitch=math.clamp(_fcPitch-d.Y*S.freeCamSens*0.003,-1.55,1.55); UIS.MouseBehavior=Enum.MouseBehavior.LockCurrentPosition
            else UIS.MouseBehavior=Enum.MouseBehavior.Default end
            local rot=CFrame.fromEulerAnglesYXZ(_fcPitch,_fcYaw,0)
            local spd=S.freeCamSpeed*dt*20*(UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 3 or 1)
            if UIS:IsKeyDown(Enum.KeyCode.W) then _fcPos=_fcPos+rot.LookVector*spd end
            if UIS:IsKeyDown(Enum.KeyCode.S) then _fcPos=_fcPos-rot.LookVector*spd end
            if UIS:IsKeyDown(Enum.KeyCode.A) then _fcPos=_fcPos-rot.RightVector*spd end
            if UIS:IsKeyDown(Enum.KeyCode.D) then _fcPos=_fcPos+rot.RightVector*spd end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then _fcPos=_fcPos+Vector3.yAxis*spd end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then _fcPos=_fcPos-Vector3.yAxis*spd end
            Cam.CFrame=CFrame.new(_fcPos)*rot
        end))
    end})
Opt.FreeCamSens  = WorldL2:AddSlider("FreeCamSens", { Text ="Look Sensitivity", Default=0.3, Min =0.1, Max =5, Rounding =1, Callback=function(v) S.freeCamSens=v end })
Opt.FreeCamSpeed = WorldL2:AddSlider("FreeCamSpeed", { Text ="Move Speed", Default=0.5, Min =0.1, Max =50, Rounding =1, Callback=function(v) S.freeCamSpeed=v end })

local _3rdPersonConn = nil
Tog.Force3rdPerson = WorldR:AddToggle("Force3rdPerson", { Text ="Force 3rd Person", Description = "Lock camera in third person view", Default=false,
    Callback=function(p)
        if _3rdPersonConn then _3rdPersonConn:Disconnect(); _3rdPersonConn=nil end
        if p then
            pcall(function() LP.CameraMinViewDistance = 8 end); pcall(function() LP.CameraMode = Enum.CameraMode.Classic end)
            _3rdPersonConn = RS.RenderStepped:Connect(function() pcall(function() LP.CameraMinViewDistance = 8 end); pcall(function() LP.CameraMode = Enum.CameraMode.Classic end) end)
        else pcall(function() LP.CameraMinViewDistance = 0.5 end); pcall(function() LP.CameraMode = Enum.CameraMode.Classic end) end
    end})

local _fovConn = nil
Tog.FOVChanger = WorldR:AddToggle("FOVChanger", { Text ="Custom FOV", Description = "Lock your field of view so the game can't reset it", Default=false,
    Callback=function(p)
        if _fovConn then _fovConn:Disconnect(); _fovConn=nil end
        if p then Cam.FieldOfView=S.fovVal; _fovConn=RS.RenderStepped:Connect(function() if Cam.FieldOfView~=S.fovVal then Cam.FieldOfView=S.fovVal end end)
        else Cam.FieldOfView=70 end
    end})
Opt.FOV = WorldR:AddSlider("FOV", { Text ="Camera FOV", Default=70, Min =0, Max =120, Rounding =1, Callback=function(v) S.fovVal=v; if _fovConn then Cam.FieldOfView=v end end })

local _cursorConn=nil; local _cursorDot=nil; local _cursorRing=nil
Tog.CustomCursor = WorldR:AddToggle("CustomCursor", { Text ="Dot Cursor", Description = "Use a custom dot cursor instead of the default", Default=false,
    Callback=function(p)
        if _cursorConn then _cursorConn:Disconnect(); _cursorConn=nil end
        if _cursorDot then _cursorDot:Remove(); _cursorDot=nil end
        if _cursorRing then _cursorRing:Remove(); _cursorRing=nil end
        UIS.MouseIconEnabled=not p
        if not p then return end
        _cursorDot=Drawing.new("Circle"); _cursorDot.Radius=6; _cursorDot.Filled=true; _cursorDot.Visible=true; _cursorDot.Color=Color3.new(1,1,1); _cursorDot.Transparency=1; _cursorDot.Thickness=1
        _cursorRing=Drawing.new("Circle"); _cursorRing.Radius=10; _cursorRing.Filled=false; _cursorRing.Visible=true; _cursorRing.Color=Color3.new(1,1,1); _cursorRing.Transparency=0.8; _cursorRing.Thickness=1.5
        _cursorConn=RS.RenderStepped:Connect(function()
            local mp=UIS:GetMouseLocation()
            _cursorDot.Position=mp; _cursorRing.Position=mp
        end)
    end})
Tog.CursorFilled = WorldR:AddToggle("CursorFilled", { Text ="Cursor Dot Filled", Description = "Make the cursor dot solid or hollow", Default=true, Callback=function(p) if _cursorDot then _cursorDot.Filled=p end end })
Opt.CursorSize     = WorldR:AddSlider("CursorSize", { Text ="Cursor Size", Default=6, Min =1, Max =20, Rounding =0, Callback=function(v) if _cursorDot then _cursorDot.Radius=v end end })
Opt.CursorRingSize = WorldR:AddSlider("CursorRingSize", { Text ="Ring Size", Default=10, Min =0, Max =30, Rounding =0, Callback=function(v) if _cursorRing then _cursorRing.Radius=v end end })

Tog.CustomCrosshair = WorldR:AddToggle("CustomCrosshair", { Text ="Crosshair", Description = "Show a crosshair in the center of your screen", Default=false,
    Callback=function(p)
        if p then
            if not getgenv()._ZHCrosshair then
                local d=Drawing.new("Square"); d.Size=Vector2.new(14,14); d.Position=Vector2.new(Cam.ViewportSize.X/2-7,Cam.ViewportSize.Y/2-7); d.Color=Color3.new(1,1,1); d.Transparency=1; d.Filled=false; d.Thickness=1; d.Visible=true
                local d2=Drawing.new("Line"); d2.From=Vector2.new(Cam.ViewportSize.X/2-6,Cam.ViewportSize.Y/2); d2.To=Vector2.new(Cam.ViewportSize.X/2+6,Cam.ViewportSize.Y/2); d2.Color=Color3.new(1,1,1); d2.Thickness=1; d2.Visible=true
                local d3=Drawing.new("Line"); d3.From=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2-6); d3.To=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2+6); d3.Color=Color3.new(1,1,1); d3.Thickness=1; d3.Visible=true
                getgenv()._ZHCrosshair={d,d2,d3}
            end
        else
            if getgenv()._ZHCrosshair then for _,d in ipairs(getgenv()._ZHCrosshair) do pcall(function() d:Remove() end) end; getgenv()._ZHCrosshair=nil end
        end
    end})

onUnload(function()
    if _fovConn then _fovConn:Disconnect(); _fovConn=nil end
    if _ambientConn then _ambientConn:Disconnect() end
    if noFogConn then noFogConn:Disconnect(); LT.FogStart=0; LT.FogEnd=100000 end
    if fbConn then fbConn:Disconnect(); LT.GlobalShadows=true; LT.Brightness=1 end
    if specConn then specConn:Disconnect() end
    if _cursorConn then _cursorConn:Disconnect() end
    if _cursorDot then pcall(function() _cursorDot:Remove() end) end
    if _cursorRing then pcall(function() _cursorRing:Remove() end) end
    if _3rdPersonConn then _3rdPersonConn:Disconnect() end
    UIS.MouseIconEnabled=true
    for _,c in ipairs(freecamConns) do pcall(function() c:Disconnect() end) end
    Cam.FieldOfView=70; Cam.CameraType=Enum.CameraType.Custom; UIS.MouseBehavior=Enum.MouseBehavior.Default
end)
end)()

-- ═══════════════════════════════════════════════════════════
-- PERFORMANCE TAB
-- ═══════════════════════════════════════════════════════════
Tog.AntiLag = WorldR2:AddToggle("AntiLag", { Text ="Anti-Lag", Description = "Remove particles and effects for better FPS", Default=false,
    Callback=function(p)
        pcall(function() setfpscap(p and 0 or 60) end)
        if p then LT.GlobalShadows=false; LT.Brightness=2; for _,v in ipairs(workspace:GetDescendants()) do if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then pcall(function() v.Enabled=false end) end end
        else LT.GlobalShadows=true end
    end})
Opt.AntiLagFPSCap = WorldR2:AddSlider("AntiLagFPSCap", { Text ="FPS Cap", Default=0, Min =0, Max =360, Rounding =0, Callback=function(v) pcall(function() setfpscap(v==0 and math.huge or v) end) end })
WorldR2:AddButton({ Text ="Boost FPS", Func =function()
    pcall(function()
        for _,v in ipairs(game:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled=false end
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then v.Enabled=false end
        end
        LT.GlobalShadows=false; LT.Brightness=5
    end)
end})

-- ═══════════════════════════════════════════════════════════
-- TELEPORT TAB
-- ═══════════════════════════════════════════════════════════
WorldR3:AddButton({ Text ="Copy Coordinates", Func =function()
    local hrp=getHRP(); if not hrp then return end
    local p=hrp.Position; setclipboard(string.format("%.2f, %.2f, %.2f",p.X,p.Y,p.Z))
end})

local nearbyConn=nil; local nearbyTracked={}; local _nearbyTimer=0
Tog.NearbyNotifier = WorldR3:AddToggle("NearbyNotifier", { Text ="Nearby Alert", Description = "Alert when a player gets close to you", Default=false,
    Callback=function(p)
        if nearbyConn then nearbyConn:Disconnect(); nearbyConn=nil end; nearbyTracked={}
        if not p then return end
        nearbyConn=RS.Heartbeat:Connect(function()
            local now=tick(); if now-_nearbyTimer<0.5 then return end; _nearbyTimer=now
            local myHRP=getHRP(); if not myHRP then return end
            local dist=Library.Options["NearbyDist"] and Library.Options["NearbyDist"].Value or 500
            for _,plr in ipairs(PS:GetPlayers()) do
                if plr~=LP and plr.Character then
                    local hrp=plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local mag=(myHRP.Position-hrp.Position).Magnitude; local id=plr.UserId
                        if mag<=dist and not nearbyTracked[id] then nearbyTracked[id]=true; notify(plr.Name.." is nearby ["..math.floor(mag).."m]",6)
                        elseif mag>dist and nearbyTracked[id] then nearbyTracked[id]=nil; notify(plr.Name.." left range",3) end
                    end
                end
            end
        end)
    end})
Opt.NearbyDist = WorldR3:AddSlider("NearbyDist", { Text ="Alert Range", Default=500, Min =0, Max =10000, Rounding =0, Callback=function() end })

Opt.Coordinates = NavL:AddInput("Coordinates", { Default="", Placeholder="X, Y, Z", Callback =function() end })
NavL:AddButton({ Text ="Tween To", Func =function()
    local v=Library.Options["Coordinates"] and Library.Options["Coordinates"].Value or ""
    local x,y,z=v:match("([%-%d%.]+)%s*,%s*([%-%d%.]+)%s*,%s*([%-%d%.]+)")
    if x then task.spawn(function() tweenTo(CFrame.new(tonumber(x),tonumber(y),tonumber(z))) end) end
end})
NavL:AddButton({ Text ="Copy Position", Func =function()
    local hrp=getHRP(); if hrp then setclipboard(tostring(hrp.Position)) end
end})
local clickTPConn=nil
Tog.ClickTP = NavL:AddToggle("ClickTP", { Text ="Click TP", Description = "Right-click to teleport anywhere on the map", Default=false,
    Callback=function(p)
        if clickTPConn then clickTPConn:Disconnect(); clickTPConn=nil end
        if p then clickTPConn=UIS.InputBegan:Connect(function(inp,gpe)
            if gpe or inp.UserInputType~=Enum.UserInputType.MouseButton2 then return end
            local ray=Cam:ScreenPointToRay(inp.Position.X,inp.Position.Y)
            local res=workspace:Raycast(ray.Origin,ray.Direction*2000)
            if res then task.spawn(function() tweenTo(CFrame.new(res.Position+Vector3.new(0,3,0))) end) end
        end) end
    end})

-- ═══════════════════════════════════════════════════════════
-- ATTACH TAB
-- ═══════════════════════════════════════════════════════════
;(function()
    local function buildAttachPlrList() local l={"--"}; for _,p in ipairs(PS:GetPlayers()) do if p~=LP then table.insert(l,p.Name) end end; return l end
    Opt.AttachTargetPlayer = NavR:AddDropdown("AttachTargetPlayer", { Text ="Attach Target", Description = "Choose a player to follow", Values =buildAttachPlrList(), Default=nil, Multi=false, Callback=function() end })
end)()
Tog.AttachSelected = NavR:AddToggle("AttachSelected", { Text ="Attach Player", Description = "Follow and stay on top of the selected player", Default=false,
    Callback=function(p)
        if not p then return end
        task.spawn(function()
            while Tog.AttachSelected and _flagVal("AttachSelected") do
                local myHRP=getHRP(); if not myHRP then task.wait(); continue end
                local val=Library.Options["AttachTargetPlayer"] and Library.Options["AttachTargetPlayer"].Value
                local plr=type(val)=="string" and PS:FindFirstChild(val) or val
                if plr and plr~=LP and plr.Character then
                    local hrp=plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local offset=CFrame.new(0,Library.Options["MobsHeight"] and Library.Options["MobsHeight"].Value or 0,Library.Options["MobsDistance"] and Library.Options["MobsDistance"].Value or 0)
                        tweenTo(hrp.CFrame*offset)
                    end
                end
                task.wait()
            end
        end)
    end})
Opt.MobsRange    = NavR2:AddSlider("MobsRange", { Text ="Range", Default=1000, Min =0, Max =10000, Rounding =0, Callback=function() end })
Opt.MobsDistance = NavR2:AddSlider("MobsDistance", { Text ="Distance", Default=0, Min =-50, Max =50, Rounding =0, Callback=function() end })
Opt.MobsHeight   = NavR2:AddSlider("MobsHeight", { Text ="Height", Default=0, Min =-50, Max =50, Rounding =0, Callback=function() end })

-- ═══════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════
onUnload(function()
    pcall(function() RS:UnbindFromRenderStep("QDSpeed") end)
    pcall(function() RS:UnbindFromRenderStep("QDFly") end)
    pcall(function() RS:UnbindFromRenderStep("QDTween") end)
    pcall(function() RS:UnbindFromRenderStep("QDNoSlow") end)
    getgenv()._QD_flyFrame=nil

    if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
    if ijConn then ijConn:Disconnect(); ijConn=nil end
    if _jumpFixConn then _jumpFixConn:Disconnect(); _jumpFixConn=nil end
    if afkConn then afkConn:Disconnect(); afkConn=nil end; _afkLoop=false
    if _noAnimsConn then _noAnimsConn:Disconnect(); _noAnimsConn=nil end
    if _noAnimsCharConn then _noAnimsCharConn:Disconnect(); _noAnimsCharConn=nil end
    if clickTPConn then clickTPConn:Disconnect(); clickTPConn=nil end
    if nearbyConn then nearbyConn:Disconnect(); nearbyConn=nil end
    if getgenv()._ZHCrosshair then for _,d in ipairs(getgenv()._ZHCrosshair) do pcall(function() d:Remove() end) end; getgenv()._ZHCrosshair=nil end

    local c = getChar()
    if c then
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p.CanCollide=true end) end
        end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
            pcall(function() hrp.AssemblyAngularVelocity = Vector3.zero end)
        end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
                if hum:GetState() == Enum.HumanoidStateType.Physics or hum:GetState() == Enum.HumanoidStateType.FallingDown then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)
        end
    end

    pcall(function() Cam.CameraType = Enum.CameraType.Custom end)
    pcall(function() Cam.FieldOfView = 70 end)
    pcall(function() UIS.MouseBehavior = Enum.MouseBehavior.Default end)
    pcall(function() UIS.MouseIconEnabled = true end)
    pcall(function() LP.CameraMinViewDistance = 0.5 end)
    pcall(function() LP.CameraMode = Enum.CameraMode.Classic end)
    local lc = getChar()
    if lc then
        local lhum = lc:FindFirstChildOfClass("Humanoid")
        if lhum then pcall(function() Cam.CameraSubject = lhum end) end
    end
end)

Tabs.ESP:Select()
