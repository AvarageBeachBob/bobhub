local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local vis
local args



local Window = Fluent:CreateWindow({
    Title = "Fluent " .. Fluent.Version,
    SubTitle = "by dawid",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "Notification",
        Content = "This is a notification",
        SubContent = "SubContent", -- Optional
        Duration = 5 -- Set to nil to make the notification not disappear
    })



    Tabs.Main:AddParagraph({
        Title = "Paragraph",
        Content = "This is a paragraph.\nSecond line!"
    })



    Tabs.Main:AddButton({
        Title = "Button",
        Description = "Very important button",
        Callback = function()
            Window:Dialog({
                Title = "Title",
                Content = "This is a dialog",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            print("Confirmed the dialog.")
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Cancelled the dialog.")
                        end
                    }
                }
            })
        end
    })



    local Toggle = Tabs.Main:AddToggle("MyToggle", {Title = "Toggle", Default = false })

    

    Options.MyToggle:SetValue(false)

    local Fish = Tabs.Main:AddInput("Fish", {
        Title = "What fish u wanna appraise",
        Default = "",
        Placeholder = "the fish",
        Numeric = false, -- Only allows numbers
        Finished = true, -- Only calls callback when you press enter
        Callback = function(Value)
            print("Input changed:", Value)
        end
    })

    Fish:OnChanged(function()
        print("Input updated:", Fish.Value)
    end)

    local Weight = Tabs.Main:AddInput("Weight", {
        Title = "Minimum weight",
        Default = "",
        Placeholder = "weight",
        Numeric = true, -- Only allows numbers
        Finished = true, -- Only calls callback when you press enter
        Callback = function(Value)
            print("Input changed:", Value)
        end
    })

    Weight:OnChanged(function()
        print("Input updated:", Weight.Value)
    end)


    Toggle:OnChanged(function()
        print("Toggle changed:", Options.MyToggle.Value)
        if Options.MyToggle.Value then
            for i,v in pairs(game.ReplicatedStorage.playerstats:FindFirstChild(game.Players.LocalPlayer.Name).Inventory:GetChildren())do
                if string.find(v.Name, Options.Fish.Value) then
                    vis = v
                end
            end
        end

        while Options.MyToggle.Value and vis.Weight.Value <= tonumber(Options.Weight.Value) do
            args = {
                [1] = game:GetService("Players").LocalPlayer.Backpack:FindFirstChild(Options.Fish.Value)
            }
            game:GetService("Players").LocalPlayer.PlayerGui.hud.safezone.backpack.events.equip:FireServer(unpack(args))
            workspace.world.npcs.Appraiser.appraiser.appraise:InvokeServer()
            for i,v in pairs(game.ReplicatedStorage.playerstats:FindFirstChild(game.Players.LocalPlayer.Name).Inventory:GetChildren())do
                if string.find(v.Name, Options.Fish.Value) then
                    vis = v
                end
            end
            task.wait(1)
            if  tonumber(Options.Weight.Value) <= vis.Weight.Value then
                Options.MyToggle:SetValue(false)
            end    
        end
    end)

    
end




-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()