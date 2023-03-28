--#region Setup
if getgenv then
    if getgenv().DGEM_LOADED==true then
        repeat task.wait() until true==false
    end
    getgenv().DGEM_LOADED=true
end
local entities={
    AllEntities={"全部","Ambush","Eyes","Glitch","Grundge","Halt","Hide","没有","随机","Rush","Screech","Seek","Shadow","Smiler","Timothy","Trashbag","Trollface"},
    DeveloperEntities={"Trollface", "没有"},
    CustomEntities={"Grundge","Smiler","Trashbag", "None"},
    RegularEntities={"全部", "Ambush", "Eyes", "Glitch", "Halt", "Hide", "随机","没有","Rush","Screech","Seek","Shadow","Timothy"}
}
for _, tb in pairs(entities) do table.sort(tb) end

--#endregion

--#region Window
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
	Name = "小黑子 | 使用的执行器："..(identifyexecutor and identifyexecutor() or syn and "Synapse X" or "Unknown"),
	LoadingTitle = "蔡徐坤🐔🏀",
	LoadingSubtitle = "作者夜（黑子)【源码Sponguss+Zepssy】",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = nil, -- Create a custom folder for your hub/game
		FileName = "L.N.K v1" -- ZEPSYY I TOLD YOU ITS NOT GONNA BE NAMED LINK  
    },
    false,
    KeySettings = {
        Title = "DX的密钥系统",
        Subtitle = "密钥系统",
        Note = "QQ群(731361929)",
        Key = "DXuwu.lol"
    }
})
	
--#endregion
--#region Connections & Variables

workspace.ChildAdded:Connect(function(c)
    if c:FindFirstChild("RushNew") and not c.Parent:GetAttribute("IsCustomEntity") and (c.Parent.Name=="RushMoving" or c.Parent.Name=="AmbushMoving")  then
        Rayfield:Notify({
            Title = "真正的【伺服器】 "..c.Parent.Name=="RushMoving" and "Rush" or "Ambush".." 已生成...",
            Content = "Notification Content",
            Duration = 6.5,

            Image = 4483362458,
            Actions = {
                Ignore = {
                    Name = "好的!",
                    Callback = function() end
                },
                Hide = {
                    Name="Hide!",
                    Callback=function() 
                        for _, wardrobe in pairs(workspace.CurrentRooms:GetDescendants()) do
                            if wardrobe.Name=="Wardrobe" and wardrobe.HiddenPlayer.Value==nil then
                                game.Players.LocalPlayer.Character:PivotTo(wardrobe.Main.CFrame)
                                task.wait(.1)
                                if wardrobe.HiddenPlayer.Value~=nil then continue end
                                fireproximityprompt(wardrobe.HidePrompt)
                                return
                            end
                        end
                    end
                }
            },
        })
    end
end)

--//MAIN VARIABLES\\--
local Debris = game:GetService("Debris")


local player = game.Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local RootPart = Character:FindFirstChild("HumanoidRootPart")
local Humanoid = Character:FindFirstChild("Humanoid")

local allLimbs = {}

for i,v in pairs(Character:GetChildren()) do
    if v:IsA("BasePart") then
        table.insert(allLimbs, v)
    end
end

--//MAIN USABLE FUNCTIONS\\--

function removeDebris(obj, Duration)
    Debris:AddItem(obj, Duration)
end

-- Services

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local ReSt = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local TS = game:GetService("TweenService")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")

local ModuleScripts = {
    MainGame = require(Plr.PlayerGui.MainUI.Initiator.Main_Game),
    SeekIntro = require(Plr.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Cutscenes.SeekIntro),
}
local Connections = {}

-- Functions

local function playSound(soundId, source, properties)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://".. soundId
    sound.PlayOnRemove = true
    
    for i, v in next, properties do
        if i ~= "SoundId" and i ~= "Parent" and i ~= "PlayOnRemove" then
            sound[i] = v
        end
    end

    sound.Parent = source
    sound:Destroy()
end

local function drag(model, dest, speed)
    local reached = false

    Connections.Drag = RS.Stepped:Connect(function(_, step)
        if model.Parent then
            local seekPos = model.PrimaryPart.Position
            local newDest = Vector3.new(dest.X, seekPos.Y, dest.Z)
            local diff = newDest - seekPos
    
            if diff.Magnitude > 0.1 then
                model:SetPrimaryPartCFrame(CFrame.lookAt(seekPos + diff.Unit * math.min(step * speed, diff.Magnitude - 0.05), newDest))
            else
                Connections.Drag:Disconnect()
                reached = true
            end
        else
            Connections.Drag:Disconnect()
        end
    end)

    repeat task.wait() until reached
end

local function jumpscareSeek()
    Hum.Health = 0
    workspace.Ambience_Seek:Stop()

    local func = getconnections(ReSt.Bricks.Jumpscare.OnClientEvent)[1].Function
    debug.setupvalue(func, 1, false)
    func("Seek")
end

local function connectSeek(room)
    local seekMoving = workspace.SeekMoving
    local seekRig = seekMoving.SeekRig

    -- Intro
    
    seekMoving:SetPrimaryPartCFrame(room.RoomStart.CFrame * CFrame.new(0, 0, -15))
    seekRig.AnimationController:LoadAnimation(seekRig.AnimRaise):Play()

    task.spawn(function()
        task.wait(7)
        workspace.Footsteps_Seek:Play()
    end)

    workspace.Ambience_Seek:Play()
    ModuleScripts.SeekIntro(ModuleScripts.MainGame)
    seekRig.AnimationController:LoadAnimation(seekRig.AnimRun):Play()
    Char:SetPrimaryPartCFrame(room.RoomEnd.CFrame * CFrame.new(0, 0, 20))
    ModuleScripts.MainGame.chase = true
    Hum.WalkSpeed = 22
    
    -- Movement

    task.spawn(function()
        local nodes = {}

        for _, v in next, workspace.CurrentRooms:GetChildren() do
            for i2, v2 in next, v:GetAttributes() do
                if string.find(i2, "Seek") and v2 then
                    nodes[#nodes + 1] = v.RoomEnd
                end
            end
        end

        for _, v in next, nodes do
            if seekMoving.Parent and not seekMoving:GetAttribute("IsDead") then
                drag(seekMoving, v.Position, 15)
            end
        end
    end)

    -- Killing

    task.spawn(function()
        while seekMoving.Parent do
            if (Root.Position - seekMoving.PrimaryPart.Position).Magnitude <= 30 and Hum.Health > 0 and not seekMoving.GetAttribute(seekMoving, "IsDead") then
                Connections.Drag:Disconnect()
                workspace.Footsteps_Seek:Stop()
                ModuleScripts.MainGame.chase = false
                Hum.WalkSpeed = 15
                
                -- Crucifix / death

                if not Char.FindFirstChild(Char, "Crucifix") then
                    jumpscareSeek()
                else
                    seekMoving.Figure.Repent:Play()
                    seekMoving:SetAttribute("IsDead", true)
                    workspace.Ambience_Seek.TimePosition = 92.6

                    task.spawn(function()
                        ModuleScripts.MainGame.camShaker:ShakeOnce(35, 25, 0.15, 0.15)
                        task.wait(0.5)
                        ModuleScripts.MainGame.camShaker:ShakeOnce(5, 25, 4, 4)
                    end)

                    -- Crucifix float

                    local model = Instance.new("Model")
                    model.Name = "Crucifix"
                    local hl = Instance.new("Highlight")
                    local crucifix = Char.Crucifix
                    local fakeCross = crucifix.Handle:Clone()
        
                    fakeCross:FindFirstChild("EffectLight").Enabled = true
        
                    ModuleScripts.MainGame.camShaker:ShakeOnce(35, 25, 0.15, 0.15)
        
                    model.Parent = workspace
                    -- hl.Parent = model
                    -- hl.FillTransparency = 1
                    -- hl.OutlineColor = Color3.fromRGB(75, 177, 255)
                    fakeCross.Anchored = true
                    fakeCross.Parent = model
        
                    crucifix:Destroy()
        
                    for i, v in pairs(fakeCross:GetChildren()) do
                        if v.Name == "E" and v:IsA("BasePart") then
                            v.Transparency = 0
                            v.CanCollide = false
                        end
                        if v:IsA("Motor6D") then
                            v.Name = "Motor6D"
                        end
                    end
        


                    -- Seek death

                    task.wait(4)
                    seekMoving.Figure.Scream:Play()
                    playSound(11464351694, workspace, { Volume = 3 })
                    game.TweenService:Create(seekMoving.PrimaryPart, TweenInfo.new(4), {CFrame = seekMoving.PrimaryPart.CFrame - Vector3.new(0, 10, 0)}):Play()
                    task.wait(4)

                    seekMoving:Destroy()
                    fakeCross.Anchored = false
                    fakeCross.CanCollide = true
                    task.wait(0.5)
                    model:Remove()
                end

                break
            end

            task.wait()
        end
    end)
end

-- Setup

local newIdx; newIdx = hookmetamethod(game, "__newindex", newcclosure(function(t, k, v)
    if k == "WalkSpeed" and not checkcaller() then
        if ModuleScripts.MainGame.chase then
            v = ModuleScripts.MainGame.crouching and 17 or 22
        else
            v = ModuleScripts.MainGame.crouching and 10 or 15
        end
    end
    
    return newIdx(t, k, v)
end))

-- Scripts
 
local roomConnection; roomConnection = workspace.CurrentRooms.ChildAdded:Connect(function(room)
    local trigger = room:WaitForChild("TriggerEventCollision", 1)

    if trigger then
        roomConnection:Disconnect()

        local collision = trigger.Collision:Clone()
        collision.Parent = room
        trigger:Destroy()

        local touchedConnection; touchedConnection = collision.Touched:Connect(function(p)
            if p:IsDescendantOf(Char) then
                touchedConnection:Disconnect()

                connectSeek(room)
            end
        end)
    end
end)
--#endregion
--#region Tabs
local MainTab=Window:CreateTab("怪物生成", 4370345144)
local DoorsMods=Window:CreateTab("Doors游戏修改", 10722835155)
local ConfigEntities = Window:CreateTab("修改怪物", 8285095937)
local publicServers = Window:CreateTab("特殊伺服器", 9692125126)
local Tools=Window:CreateTab("物品", 29402763) 
local CharacterMods=Window:CreateTab("人物", 483040244)
local global=Window:CreateTab("公共", 1588352259)
local info= Window:CreateTab("资讯", 4483345998)
--#endregion
    
--region info
info:CreateParagraph({Title = "如何联系作者", Content = "快手号dxuwulol|QQ群731361929"})
info:CreateParagraph({Title = "更新", Content = "Seek十字架,万圣节十字架,MC房间,手电筒"})
info:CreateParagraph({Title = "11.12.2022", Content = "Rayfield UI!!!"})
info:CreateParagraph({Title = "Bugs", Content = "1. 骷髅钥匙无效 "})
info:CreateParagraph({Title = "Notes", Content = "哈哈哈"})

--end region

--#region Special Servers
publicServers:CreateSection("伺服器识别器")
publicServers:CreateLabel("目前的伺服器识别码: "..game.JobId)
publicServers:CreateButton({
    Name="复制目前伺服器识别码",
    Callback=function()
        (syn and syn.write_clipboard or setclipboard)(game.JobId)
    end
})
publicServers:CreateSection("特色")
publicServers:CreateButton({
    Name="进入无人特殊伺服器",
    Callback=function()
        game.Players.LocalPlayer:Kick("\nJoining Special Server... Please Wait")
		wait()
        queue_on_teleport("loadstring(game:HttpGet\"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/source.lua\")()")
		game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end
})
publicServers:CreateButton({
    Name="免费复活",
    Callback=function()
        queue_on_teleport("loadstring(game:HttpGet\"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/source.lua\")()")
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})
publicServers:CreateLabel("注意: 你必须在一个特殊伺服器里面才有效")
publicServers:CreateSection("转换伺服器")
publicServers:CreateButton({
    Name="进入一个随机的特殊伺服器",
	Callback = function()
        local tb=game:GetService("HttpService"):JSONDecode(game:HttpGet(("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"):format(tostring(game.PlaceId))))
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, tb.data[math.random(1,#tb.data)].id, game.Players.LocalPlayer)
        queue_on_teleport("loadstring(game:HttpGet\"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/source.lua\")()")
    end,
})
publicServers:CreateInput({
    Name="进入指定玩家的伺服器",
    PlaceholderText = game.Players.LocalPlayer.Name,
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        local tb=game:GetService("HttpService"):JSONDecode(game:HttpGet(("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"):format(tostring(game.PlaceId))))
        for _, server in pairs(tb.data) do
            for _, player in pairs(server.players) do
                if player.name==Text or player.UserId==Text then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, game.Players.LocalPlayer)
                    queue_on_teleport("loadstring(game:HttpGet\"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/source.lua\")()")
                end
            end
        end
    end,
})
publicServers:CreateInput({
    Name="进入特殊伺服器",
    PlaceholderText = "请填写伺服器识别码",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, Text, game.Players.LocalPlayer)
        queue_on_teleport("loadstring(game:HttpGet\"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/source.lua\")()")
    end,
})
--#endregion
--#region Entity Configuration
local EntitiesFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Entities")

_G.ScreechConfig = false
_G.TimothyConfig = false
_G.HaltConfig = false
_G.GlitchConfig = false

_G.HaltModel = 0
_G.TimothyModel = 0
_G.ScreechModel = 0
_G.GlitchModel = 0

local function connectEntity(entitytype, id, entityname)
    if entitytype == "3d" then
        game:GetService("Debris"):AddItem(game:GetService("ReplicatedStorage"):WaitForChild("Entities"):FindFirstChild(entityname), 0)

        local customentity = game:GetObjects("rbxassetid://"..id)[1]
        customentity.Name = entityname
        customentity.Parent = game:GetService("ReplicatedStorage"):FindFirstChild("Entities")

        local isCustom = Instance.new("StringValue")
        isCustom.Name = "isCustom"
        isCustom.Parent = customentity

        
    elseif entitytype == string.lower("2d") then
        error("怪物不可被修改因为它是2D.")
    end
end

ConfigEntities:CreateSection("3D 怪物")

ConfigEntities:CreateParagraph({Title="注意", Content="此设定只能由开发人员使用，除非你有DOORS的怪物源模型."})

ConfigEntities:CreateToggle({
    Name = "Screech 修订",
	CurrentValue = false,
	Flag = "AddScreechConfig",
	Callback = function(Value)
        _G.ScreechConfig = Value
        game:GetService("RunService").RenderStepped:Connect(function()
            if Value then
                connectEntity("3d", _G.ScreechModel, "Screech")
            else
                connectEntity("3d", "11599277464", "Screech")
            end
        end)
	end,
})

ConfigEntities:CreateInput({
	Name = "设置 Screech 模型",
	PlaceholderText = "ex: 123456789",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        _G.ScreechModel = Text
	end,
})

ConfigEntities:CreateToggle({
    Name = "Glitch 修订",
	CurrentValue = false,
	Flag = "AddGlitchConfig",
	Callback = function(Value)
        _G.GlitchConfig = Value
        game:GetService("RunService").RenderStepped:Connect(function()
            if Value then
                connectEntity("3d", _G.GlitchModel, "Glitch")
            else
                connectEntity("3d", "11689725604", "Glitch")
            end
        end)
	end,
})

ConfigEntities:CreateInput({
	Name = "设置 Glitch Model",
	PlaceholderText = "ex: 123456789",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        _G.GlitchModel = Text
	end,
})

ConfigEntities:CreateToggle({
    Name = "Timothy 修订",
	CurrentValue = false,
	Flag = "AddTimothyConfig",
	Callback = function(Value)
        _G.TimothyConfig = Value
        game:GetService("RunService").RenderStepped:Connect(function()
            if Value then
                connectEntity("3d", _G.TimothyModel, "Spider")
            else
                connectEntity("3d", "11689711982", "Spider")
            end
        end)
	end,
})


ConfigEntities:CreateInput({
	Name = "设置 Timothy 模型",
	PlaceholderText = "ex: 123456789",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        _G.TimothyModel = Text
	end,
})

ConfigEntities:CreateToggle({
    Name = "Halt 修订",
	CurrentValue = false,
	Flag = "AddHaltConfig",
	Callback = function(Value)
        _G.HaltConfig = Value
        game:GetService("RunService").RenderStepped:Connect(function()
            if Value then
                connectEntity("3d", _G.HaltModel, "Shade")
            else
                connectEntity("3d", "11689715035", "Shade")
            end
        end)
	end,
})

ConfigEntities:CreateInput({
	Name = "设置 Halt 模型",
	PlaceholderText = "ex: 123456789",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        _G.HaltModel = Text
	end,
})

ConfigEntities:CreateSection("2D 怪物")
--#endregion
--#region Doors Modifications
--#region UI Mods
DoorsMods:CreateSection("游戏UI修改")

DoorsMods:CreateInput({
	Name = "设置金币数量",
	PlaceholderText = game.Players.LocalPlayer.PlayerGui.PermUI.Topbar.Knobs.Text,
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        require(game.ReplicatedStorage.ReplicaDataModule).event.Knobs:Fire(tonumber(Text))
	end,
})

DoorsMods:CreateInput({
	Name = "设置复活数量",
	PlaceholderText = game.Players.LocalPlayer.PlayerGui.PermUI.Topbar.Revives.Text,
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        require(game.ReplicatedStorage.ReplicaDataModule).event.Revives:Fire(tonumber(Text))
	end,
})

DoorsMods:CreateInput({
	Name = "设置加成数量",
	PlaceholderText = game.Players.LocalPlayer.PlayerGui.PermUI.Topbar.Boosts.Text,
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        require(game.ReplicatedStorage.ReplicaDataModule).event.Boosts:Fire(tonumber(Text))
	end,
})

DoorsMods:CreateInput({
	Name = "设置底下文字",
	PlaceholderText = "就是你的打火机没燃料了什么什么那里...",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        firesignal(game.ReplicatedStorage.Bricks.Caption.OnClientEvent, Text)
	end,
})


DoorsMods:CreateButton({
	Name = "心跳小游戏",
	Callback = function()
        firesignal(game.ReplicatedStorage.Bricks.ClutchHeartbeat.OnClientEvent)
	end,
})

DoorsMods:CreateButton({
	Name = "全成就",
	Callback = function()
        for i,v in pairs(require(game.ReplicatedStorage.Achievements)) do
            spawn(function()
                require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.AchievementUnlock)(nil, i)
            end)
        end
	end,
})
--#endregion
--#region Modify Rooms
DoorsMods:CreateSection("房间修订")

DoorsMods:CreateColorPicker({
    Name="设置房间颜色",
    Color=Color3.fromRGB(89,69,72),
    Flag="RoomColor",
    Callback=function(color)
        local room=workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")]

        if color==Color3.fromRGB(89,69,72) then
            room.LightBase.SurfaceLight.Enabled=true
            room.LightBase.SurfaceLight.Color=Color3.fromRGB(89,69,72)
            for _, thing in pairs(room.Assets:GetDescendants()) do
                if thing:FindFirstChild"LightFixture" then
                    thing.LightFixture.Neon.Color=Color3.fromRGB(195, 161, 141)
                    for _, light in pairs(thing.LightFixture:GetChildren()) do
                        if light:IsA("SpotLight") or light:IsA("PointLight") then
                            light.Color=Color3.fromRGB(235, 167, 98)
                        end
                    end
                end
            end
            return
        end

        room.LightBase.SurfaceLight.Enabled=true
        room.LightBase.SurfaceLight.Color=color
        for _, thing in pairs(room.Assets:GetDescendants()) do
            if thing:FindFirstChild"LightFixture" then
                thing.LightFixture.Neon.Color=color
                for _, light in pairs(thing.LightFixture:GetChildren()) do
                    if light:IsA("SpotLight") or light:IsA("PointLight") then
                        light.Color=color
                    end
                end
            end
        end
    end
})

DoorsMods:CreateParagraph({Title="注意", Content="如果你想重置房间颜色, 填写 89,69,72"})

DoorsMods:CreateButton({
	Name = "生成红房",
	Callback = function()
        firesignal(game.ReplicatedStorage.Bricks.UseEventModule.OnClientEvent, "tryp", workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")], 9e307)
        -- Imagine someone actually waits 90000000000000000... seconds for the red room to run out, would be crazy 
	end,
})

DoorsMods:CreateButton({
	Name = "破坏灯",
	Callback = function()
        firesignal(game.ReplicatedStorage.Bricks.UseEventModule.OnClientEvent, "breakLights", workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")], 0.416, 60) 
	end,
})

DoorsMods:CreateInput({
	Name = "灯闪烁",
	PlaceholderText = "事件【秒】...",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        firesignal(game.ReplicatedStorage.Bricks.UseEventModule.OnClientEvent, "flickerLights", game.Players.LocalPlayer:GetAttribute("CurrentRoom"), tonumber(Text)) 
	end,
})

DoorsMods:CreateInput({
	Name = "设置门的文字",
	PlaceholderText = "你干嘛嘿嘿哟",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        local r=workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")]
        r.Door.Sign.Stinker.Text=Text
        r.Door.Sign.Stinker.Highlight.Text=Text
        r.Door.Sign.Stinker.Shadow.Text=Text
	end,    
})
--#endregion
--#region Modify Entities
DoorsMods:CreateSection("怪物修订")

local EnabledEntities={
    EnabledScreech=false,
    EnabledHalt=false,
    EnabledGlitch=false,
}

DoorsMods:CreateToggle({
    Name = "无视 Screech",
	CurrentValue = false,
	Flag = "IgnoreScreech",
	Callback = function(Value)
        EnabledEntities.EnabledScreech = Value
	end,
})

DoorsMods:CreateToggle({
    Name = "无视 Glitch",
	CurrentValue = false,
	Flag = "IgnoreGlitch",
	Callback = function(Value)
        EnabledEntities.EnabledGlitch = Value
	end,
})

DoorsMods:CreateToggle({
    Name = "无视 Halt",
	CurrentValue = false,
	Flag = "IgnoreHalt",
	Callback = function(Value)
        EnabledEntities.EnabledHalt = Value
	end,
})

workspace.Camera.ChildAdded:Connect(function(c)
    if c.Name == "Screech" then
        wait(0.1)
        if EnabledEntities.EnabledScreech then
            removeDebris(c, 0)
        end
    end

    if c.Name == "Shade" then
        wait(.1)
        if EnabledEntities.EnabledHalt then
            removeDebris(c, 0)
        end
    end
end)

workspace.CurrentRooms.ChildAdded:Connect(function()
    if EnabledEntities.EnabledGlitch then
        local currentRoom=game.Players.LocalPlayer:GetAttribute("CurrentRoom")
        local roomAmt=#workspace.CurrentRooms:GetChildren()
        local lastRoom=game.ReplicatedStorage.GameData.LatestRoom.Value
    
        if roomAmt>=4 and currentRoom<lastRoom-3 then
            game.Players.LocalPlayer.Character:PivotTo(CFrame.new(lastRoom.RoomStart.Position))
        end    
    end
end)
--#endregion
--#region Global Doors Mods

DoorsMods:CreateSection("公共doors修订")

local thanksgivingEnabled=false
DoorsMods:CreateToggle({
	Name = "感恩节模式",
	Callback = function()
        if thanksgivingEnabled then
            return Rayfield:Notify({
                Title = "Error",
                Content = "You have already ran this",
                Duration = 6.5,
                Image = 4483362458,
                Actions = {},
            })
        end
        thanksgivingEnabled=true
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ZepsyyCodesLUA/Utilities/main/DOORSthanksgiving"))()
	end,
})

DoorsMods:CreateButton({
    Name = "MC房间",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/y2WmccLk"))()
    end,
})


--#endregion
--#endregion
--#region Character Mods
local con
local con2
local isJumping=false
CharacterMods:CreateInput({
    Name="设置 Guiding Light",
    PlaceholderText = "文字 1~文字 2",
	RemoveTextAfterFocusLost = true,
    Callback=function(Text)
        game.Players.LocalPlayer.Character.Humanoid.Health=0
        debug.setupvalue(getconnections(game.ReplicatedStorage.Bricks.DeathHint.OnClientEvent)[1].Function, 1, Text:split"~")
    end
})
CharacterMods:CreateLabel("这会让你立即死亡")

CharacterMods:CreateButton({
    Name="立即死亡",
    Callback=function()
        game.Players.LocalPlayer.Character.Humanoid.Health=0
    end
})
CharacterMods:CreateButton({
    Name="复活",
    Callback=function()
        game.ReplicatedStorage.Bricks.Revive:FireServer()
    end
})
CharacterMods:CreateParagraph({Title = "注意", Content = "你需要至少一个复活,这样就可以跳过 \"你只可以复活一次\" 的信息, 或其他东东？？？"})

CharacterMods:CreateToggle({
    Name="哈哈开启跳跃",
    CurrentValue=false,
    Flag="enableJump",
    Callback=function(val)
        if val==true then
            con=game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode==Enum.KeyCode.Space then
                    isJumping=true
                    repeat 
                        task.wait()
                        if game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid"):GetState()==Enum.HumanoidStateType.Freefall then else
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState(3) end
                    until isJumping==false
                end
            end)

            con2=game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode==Enum.KeyCode.Space then
                    isJumping=false
                end
            end)
        else con:Disconnect() con2:Disconnect() end
    end
})

local Speed = 15

local EVC=CharacterMods:CreateToggle({
    Name="开启速度挂",
    CurrentValue=false,
    Callback=function() end
})

CharacterMods:CreateSlider({
    Name="速度",
    Range={15,100},
    Increment=5,
    Suffix="studs/每秒",
    CurrentValue=15,
    Flag="speed",
    Callback=function(val)
        for _, child in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if child.ClassName == "Part" then
                child.CustomPhysicalProperties = PhysicalProperties.new(999, 0.3, 0.5)
            end
        end
        Speed = tonumber(val)
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    if EVC.CurrentValue==true then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Speed end
end)
--#endregion
--#region Tools
--#region Vitamins
_G.VitaminsDurability = 0

Tools:CreateButton({
    Name="拿维他命",
    Callback = function()
        local Vitamins = game:GetObjects("rbxassetid://11685698403")[1]
        local idle = Vitamins.Animations:FindFirstChild("idle")
        local open = Vitamins.Animations:FindFirstChild("open")

        local tweenService = game:GetService("TweenService")

        local sound_open = Vitamins.Handle:FindFirstChild("sound_open")

        local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacteAdded:Wait()
        local hum = char:WaitForChild("Humanoid")

        local idleTrack = hum.Animator:LoadAnimation(idle)
        local openTrack = hum.Animator:LoadAnimation(open)

        local Durability = 35
        local InTrans = false
        local Duration = 10

        local xUsed = tonumber(_G.VitaminsDurability)

        local v1 = {};



        function v1.AddDurability()
            InTrans = true
            hum:SetAttribute("SpeedBoost", 15)
            wait(Duration)
            InTrans = false
            hum:SetAttribute("SpeedBoost", 0)
        end




        function v1.SetupVitamins()
            Vitamins.Parent = game.Players.LocalPlayer.Backpack
            Vitamins.Name = "假的维他命哈哈哈"

            for slotNum, tool in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if tool.Name == "假的维他命哈哈哈" then
                    local slot =game.Players.LocalPlayer.PlayerGui:WaitForChild("MainUI").MainFrame.Hotbar:FindFirstChild(slotNum)
                    -- while task.wait() do
                    --     slot.DurabilityNumber.Text = "x"..xUsed
                    -- end
                    -- slot.DurabilityNumber.Text = "x"..xUsed
                    slot.DurabilityNumber.Visible = true
                    slot.DurabilityNumber.Text = "x"..xUsed

                    Vitamins.Unequipped:Connect(function()
                        slot.DurabilityNumber.Visible = true
                        slot.DurabilityNumber.Text = "x"..xUsed
                    end)

                    Vitamins.Equipped:Connect(function()
                        slot.DurabilityNumber.Visible = true
                    end)

                    Vitamins.Activated:Connect(function()
                        if not InTrans and xUsed > 0 then
                            xUsed = xUsed - 1
                            slot.DurabilityNumber.Visible = true
                            slot.DurabilityNumber.Text = "x"..xUsed
                            openTrack:Play()
                            sound_open:Play()
                    
                            tweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.2), {FieldOfView = 100}):Play()
                            v1.AddDurability()
                        end
                    end)
                end
            end




            Vitamins.Equipped:Connect(function()
                idleTrack:Play()
            end)


            Vitamins.Unequipped:Connect(function()
                idleTrack:Stop()

            end)
        end

        v1.SetupVitamins()

        function v1.AddLoop()
            while task.wait() do
                if InTrans then
                    wait()
                    hum.WalkSpeed = Durability
                else
                    hum.WalkSpeed = 16
                end
            end
        end

        while task.wait() do
            v1.AddLoop()
        end

        return v1


    end
})

Tools:CreateInput({
	Name = "维他命数量/耐久",
	PlaceholderText = "ex: 100",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        local durability = tonumber(Text)



        if durability then
            _G.VitaminsDurability = Text
        elseif not durability or durability == '0' then
            Rayfield:Notify({
                Title = "错误",
                Content = "请输入一个有效的数字.",
                Duration = 5,
                Image = 4483362458,
                Actions = {},
            })
        end
	end,    
})
 
Tools:CreateParagraph({Title = "注意", Content = "这些都是假的维他命但是也是有效果的. 其他人是开不见得. 请不要填写分数或小数，这会导致脚本被破坏或无效 ."})
--#endregion

--#region Dropdown
local toolList={"Skeleton Key", "Crucifix","Seek Crucifix","Halloween Crucifix", "Christmas Guns", "Candle", "Gummy Flashlight","Flashlight", "Gun"}
table.sort(toolList)
local toolFuncs={["Skeleton Key"]=function()
    if not isfile("skellyKey.rbxm") then
        writefile("skellyKey.rbxm", game:HttpGet"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/skellyKey.rbxm")
    end
    local keyTool: Tool=game:GetObjects((getcustomasset or getsynasset)("skellyKey.rbxm"))[1]
    keyTool:SetAttribute("uses", 5)

    local function setupRoom(room)
        local thing=loadstring(game:HttpGet"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/skellyKeyRoomRep.lua")()
        local newdoor=thing.CreateDoor({CustomKeyNames={"SkellyKey"}, Sign=true, Light=true, Locked=true})
        newdoor.Model.Parent=workspace
        newdoor.Model:PivotTo(room.Door.Door.CFrame)
        newdoor.Model.Parent=room
        room.Door:Destroy()
        thing.ReplicateDoor({Model=newdoor.Model, Config={CustomKeyNames={"SkellyKey"}}, Debug={OnDoorPreOpened=function() end}})
    end
    keyTool.Equipped:Connect(function()
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            if room.Door:FindFirstChild"Lock" and not room:GetAttribute("Replaced") then
                room:SetAttribute("Replaced", true)
                setupRoom(room)
            end
        end
        con=workspace.CurrentRooms.ChildAdded:Connect(function(room)
            if room.Door:FindFirstChild"Lock" and not room:GetAttribute("Replaced") then
                room:SetAttribute("Replaced", true)
                setupRoom(room)
            end
        end)
    end)
    keyTool.Unequipped:Connect(function() con:Disconnect() end)

    if Plr.PlayerGui.MainUI.ItemShop.Visible then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"))().CreateItem(keyTool, {
            Title = "骷髅钥匙",
            Desc = "傻逼现在没用了",
            Image = "https://static.wikia.nocookie.net/doors-game/images/8/88/Icon_crucifix2.png/revision/latest/scale-to-width-down/350?cb=20220728033038",
            Price = "点赞加关注",
            Stack = 1,
        })
    else keyTool.Parent=game.Players.LocalPlayer.Backpack end
end, ["Crucifix"]=function() 
    local function IsVisible(part)
        local vec, found=workspace.CurrentCamera:WorldToViewportPoint(part.Position)
        local onscreen = found and vec.Z > 0
        local cfg = RaycastParams.new()
        cfg.FilterType = Enum.RaycastFilterType.Blacklist
        cfg.FilterDescendantsInstances = {part}
    
        local cast = workspace:Raycast(part.Position, (game.Players.LocalPlayer.Character.UpperTorso.Position - part.Position), cfg)
        if onscreen then
            if cast and (cast and cast.Instance).Parent==game.Players.LocalPlayer.Character then
                return true
            end
        end
    end
    
    local Equipped = false
    
    -- Edit this --
    getgenv().spawnKey = Enum.KeyCode.F4
    ---------------
    
    -- Services
    
    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    
    -- Variables
    
    local Plr = Players.LocalPlayer
    local Char = Plr.Character or Plr.CharacterAdded:Wait()
    local Hum = Char:WaitForChild("Humanoid")
    local Root = Char:WaitForChild("HumanoidRootPart")
    local RightArm = Char:WaitForChild("RightUpperArm")
    local LeftArm = Char:WaitForChild("LeftUpperArm")
    
    local RightC1 = RightArm.RightShoulder.C1
    local LeftC1 = LeftArm.LeftShoulder.C1
    
    local SelfModules = {
        Functions = loadstring(
            game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua")
        )(),
        CustomShop = loadstring(
            game:HttpGet(
                "https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"
            )
        )(),
    }
    
    local ModuleScripts = {
        MainGame = require(Plr.PlayerGui.MainUI.Initiator.Main_Game),
        SeekIntro = require(Plr.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Cutscenes.SeekIntro),
    }
    
    -- Functions

    local function setupCrucifix(tool)
        tool.Equipped:Connect(function()
            Equipped = true
            Char:SetAttribute("Hiding", true)
            for _, v in next, Hum:GetPlayingAnimationTracks() do
                v:Stop()
            end
    
            RightArm.Name = "R_Arm"
            LeftArm.Name = "L_Arm"
    
            RightArm.RightShoulder.C1 = RightC1 * CFrame.Angles(math.rad(-90), math.rad(-15), 0)
            LeftArm.LeftShoulder.C1 = LeftC1
                * CFrame.new(-0.2, -0.3, -0.5)
                * CFrame.Angles(math.rad(-125), math.rad(25), math.rad(25))
        end)
    
        tool.Unequipped:Connect(function()
            Equipped = false
            Char:SetAttribute("Hiding", nil)
            RightArm.Name = "RightUpperArm"
            LeftArm.Name = "LeftUpperArm"
    
            RightArm.RightShoulder.C1 = RightC1
            LeftArm.LeftShoulder.C1 = LeftC1
        end)
    end
    
    -- Scripts
    
    local CrucifixTool = game:GetObjects("rbxassetid://11590476113")[1]
    CrucifixTool.Name = "Crucifix"
    CrucifixTool.Parent = game.Players.LocalPlayer.Backpack
    
    -- game.UserInputService.InputBegan:Connect(function(input, proc)
    --     if proc then return end
    
    --     if input.KeyCode == input.KeyCode[getgenv().spawnKey] then
    --         local CrucifixTool = game:GetObjects("rbxassetid://11590476113")[1]
    --         CrucifixTool.Name = "Crucifix"
    --         CrucifixTool.Parent = game.Players.LocalPlayer.Backpack
    --     end
    -- end)
    -- Input handler
    
    setupCrucifix(CrucifixTool)
    
    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    
    -- Variables
    
    local Plr = Players.LocalPlayer
    local Char = Plr.Character or Plr.CharacterAdded:Wait()
    local Hum = Char:WaitForChild("Humanoid")
    local Root = Char:WaitForChild("HumanoidRootPart")
    
    local dupeCrucifix = Instance.new("BindableEvent")
    local function func(ins)
        wait(.01) -- Wait for the attribute
        if ins:GetAttribute("IsCustomEntity")==true and ins:GetAttribute("ClonedByCrucifix")~=true then
            local Chains = game:GetObjects("rbxassetid://11584227521")[1]
            Chains.Parent = workspace
            local chained = true
            local posTime = false
            local rotTime = false
            local tweenTime = false
            local intFound = true
    
            game:GetService("RunService").RenderStepped:Connect(function()
                if Equipped then
                    if ins.Parent~=nil and ins.PrimaryPart and IsVisible(ins.PrimaryPart) and (Root.Position-ins.PrimaryPart.Position).magnitude <= 25 then
                        local c=ins:Clone()
                        c:SetAttribute("ClonedByCrucifix", true)
                        c.RushNew.Anchored=true
                        c.Parent=ins.Parent
                        ins:Destroy()
                        dupeCrucifix:Fire(6,c.RushNew)
    

                        
                        -- Chains.PrimaryPart.Orientation = Chains.PrimaryPart.Orientation + Vector3.new(0, 3, 0)
    
                        local EntityRoot = c:FindFirstChild("RushNew")
    
                        if EntityRoot then



                            local Fake_FaceAttach = Instance.new("Attachment")
                            Fake_FaceAttach.Parent = EntityRoot
                            

                            for i, beam in pairs(Chains:GetDescendants()) do
                                if beam:IsA("BasePart") then
                                    beam.CanCollide = false
                                end
                                if beam.Name == "Beam" then
                                    beam.Attachment1 = Fake_FaceAttach
                                end
                            end
                            
                            if not posTime then
                                Chains:SetPrimaryPartCFrame(
                                    EntityRoot.CFrame * CFrame.new(0, -3.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
                                )
                                posTime = true
                            end
    
                            task.wait(1.35)
                            if not tweenTime then
    
                                task.spawn(function()
                                    while task.wait() do
                                        if Chains:FindFirstChild('Base') then
                                            Chains.Base.CFrame = Chains.Base.CFrame * CFrame.Angles(0,0 , math.rad(0.5))
                                        end
                                    end
                                end)

                                task.spawn(function()
                                    while task.wait() do
                                        for i, beam in pairs(Chains:GetDescendants()) do
                                            if beam.Name == "Beam" then
                                                beam.TextureLength = beam.TextureLength+0.035
                                            end
                                        end
                                    end
                                end)
    
    
                                game.TweenService
                                    :Create(
                                        EntityRoot,
                                        TweenInfo.new(6),
                                        { CFrame = EntityRoot.CFrame * CFrame.new(0, 50, 0) }
                                    )
                                    :Play()
                                
    
                                tweenTime = true
                                task.wait(1.5)
                                intFound = false
                                game:GetService("Debris"):AddItem(c, 0)
                                game:GetService("Debris"):AddItem(Chains, 0)
                            end
                        end
                    end
                end
            end)
        elseif ins.Name=="Lookman" then
            local c=ins
            task.spawn(function()
                repeat task.wait() until IsVisible(c.Core) and Equipped and c.Core.Attachment.Eyes.Enabled==true
                local pos=c.Core.Position
                dupeCrucifix:Fire(18.364, c.Core)
                task.spawn(function()
                    c:SetAttribute("Killing", true)
                    ModuleScripts.MainGame.camShaker:ShakeOnce(10, 10, 5, 0.15)
                    wait(5)
                    c.Core.Initiate:Stop()
                    for i=1,3 do
                        c.Core.Repent:Play()  
                        c.Core.Attachment.Angry.Enabled=true
                        ModuleScripts.MainGame.camShaker:ShakeOnce(8, 8, 1.3, 0.15)
                        delay(c.Core.Repent.TimeLength, function() c.Core.Attachment.Angry.Enabled=false end)
                        wait(4)
                    end
                    c.Core.Scream:Play();
                    ModuleScripts.MainGame.camShaker:ShakeOnce(8, 8, c.Core.Scream.TimeLength, 0.15);
                    (c.Core:FindFirstChild"whisper" or c.Core:FindFirstChild"Ambience"):Stop()
                    for _, l in pairs(c:GetDescendants()) do
                        if l:IsA("PointLight") then
                            l.Enabled=false
                        end
                    end
                    game:GetService("TweenService"):Create(c.Core, TweenInfo.new(c.Core.Scream.TimeLength, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                        CFrame=CFrame.new(c.Core.CFrame.X, c.Core.CFrame.Y-12, c.Core.CFrame.Z)
                    }):Play()
                end)
                local col=game.Players.LocalPlayer.Character.Collision

                local function CFrameToOrientation(cf)
                    local x, y, z = cf:ToOrientation()
                    return Vector3.new(math.deg(x), math.deg(y), math.deg(z))
                end
                
                while c.Parent~=nil and c.Core.Attachment.Eyes.Enabled==true do
                    -- who's the boss now huh?
                    col.Orientation = CFrameToOrientation(CFrame.lookAt(col.Position, pos)*CFrame.Angles(0, math.pi, 0))
                    task.wait()
                end
            end)
        elseif ins.Name=="Shade" and ins.Parent==workspace.CurrentCamera and ins:GetAttribute("ClonedByCrucifix")==nil then
            task.spawn(function()
                repeat task.wait() until IsVisible(ins) and (Root.Position-ins.Position).Magnitude <= 12.5 and Equipped
                local clone = ins:Clone()
                clone:SetAttribute("ClonedByCrucifix", true)
                clone.CFrame = ins.CFrame
                clone.Parent = ins.Parent
                clone.Anchored = true
                ins:Remove()

                dupeCrucifix:Fire(13, ins)
                ModuleScripts.MainGame.camShaker:ShakeOnce(40, 10, 5, 0.15)
    
                for _, thing in pairs(clone:GetDescendants()) do
                    if thing:IsA("SpotLight") then
                        game:GetService("TweenService"):Create(thing, TweenInfo.new(5), {
                            Brightness=thing.Brightness*5
                        }):Play()
                    elseif thing:IsA("Sound") and thing.Name~="Burst" then
                        game:GetService("TweenService"):Create(thing, TweenInfo.new(5), {
                            Volume=0
                        }):Play()
                    elseif thing:IsA("TouchTransmitter") then thing:Destroy() end
                end
    
                for _, pc in pairs(clone:GetDescendants()) do
                    if pc:IsA("ParticleEmitter") then
                        pc.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.48, Color3.fromRGB(182, 0, 3)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))}
                    end
                end
    
                local Original_color = {}
    
                local light
                light = game.Lighting["Ambience_Shade"]
                game:GetService("TweenService"):Create(light, TweenInfo.new(1), {
    
                }):Play()
    
                wait(5)
    
                clone.Burst.PlaybackSpeed=0.5
                clone.Burst:Stop()
                clone.Burst:Play()
                light.TintColor = Color3.fromRGB(215,253,255)
                game:GetService("TweenService"):Create(clone, TweenInfo.new(6), {
                    CFrame=CFrame.new(clone.CFrame.X, clone.CFrame.Y-12, clone.CFrame.Z)
                }):Play()
                wait(8.2)
    
                game:GetService("Debris"):AddItem(clone, 0)
                game.ReplicatedStorage.Bricks.ShadeResult:FireServer()
            end)
        end
    end

    workspace.ChildAdded:Connect(func)
    workspace.CurrentCamera.ChildAdded:Connect(func)
    for _, thing in pairs(workspace:GetChildren()) do
        func(thing)
    end
    dupeCrucifix.Event:Connect(function(time, entityRoot)
        local Cross = game:GetObjects("rbxassetid://11656343590")[1]
        Cross.Parent = workspace

        local fakeCross = Cross.Handle
    
        -- fakeCross:FindFirstChild("EffectLight").Enabled = true
    
        ModuleScripts.MainGame.camShaker:ShakeOnce(35, 25, 0.15, 0.15)
        -- you tell me i didnt make?
        fakeCross.CFrame = CFrame.lookAt(CrucifixTool.Handle.Position, entityRoot.Position)
        
        -- hl.Parent = model
        -- hl.FillTransparency = 1
        -- hl.OutlineColor = Color3.fromRGB(75, 177, 255)
        fakeCross.Anchored = true
    
        CrucifixTool:Destroy()
    
        -- for i, v in pairs(fakeCross:GetChildren()) do
        --     if v.Name == "E" and v:IsA("BasePart") then
        --         v.Transparency = 0
        --         v.CanCollide = false
        --     end
        --     if v:IsA("Motor6D") then
        --         v.Name = "Motor6D"
        --     end
        -- end
    
        task.wait(time)
        fakeCross.Anchored = false
        fakeCross.CanCollide = true
        task.wait(0.5)
        Cross:Remove()
    end)
    
    if Plr.PlayerGui.MainUI.ItemShop.Visible then
    SelfModules.CustomShop.CreateItem(CrucifixTool, {
        Title = "十字架",
        Desc = "恶魔的噩梦.",
        Image = "https://static.wikia.nocookie.net/doors-game/images/8/88/Icon_crucifix2.png/revision/latest/scale-to-width-down/350?cb=20220728033038",
        Price = "点赞加关注",
        Stack = 1,
    })
    else CrucifixTool.Parent=game.Players.LocalPlayer.Backpack end
end, ["Christmas Guns"]=function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NotTypicalAdmin/ChristmasGuns/main/main"))()
end,
    ["Flashlight"]=function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DXuwu/flashlight-lmao/main/flashlight.lua"))()
end,    
    ["Seek Crucifix"]=function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/RmdComunnityScriptsProvider/AngryHub/main/Seek%20Crucifix.lua"))()
end,
    ["Halloween Crucifix"]=function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Mye123/MyeWareHub/main/Halloween%20Crucifix"))()
end,    
    ["Candle"]=function()
    local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
    local CustomShop = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"))()


    local Candle = game:GetObjects("rbxassetid://11630702537")[1]
    Candle.Parent = game.Players.LocalPlayer.Backpack

    local plr = game.Players.LocalPlayer
    local Char = plr.Character or plr.CharacterAdded:Wait()
    local Hum = Char:FindFirstChild("Humanoid")
    local RightArm = Char:FindFirstChild("RightUpperArm")
    local LeftArm = Char:FindFirstChild("LeftUpperArm")
    local RightC1 = RightArm.RightShoulder.C1
    local LeftC1 = LeftArm.LeftShoulder.C1

    local AnimIdle = Instance.new("Animation")
    AnimIdle.AnimationId = "rbxassetid://9982615727"
    AnimIdle.Name = "IDleloplolo"

    local cam = workspace.CurrentCamera

    Candle.Handle.Top.Flame.GuidingLighteffect.EffectLight.LockedToPart = true
    Candle.Handle.Material = Enum.Material.Salt

    local track = Hum.Animator:LoadAnimation(AnimIdle)
    track.Looped = true

    local Equipped = false

    for i,v in pairs(Candle:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end

    Candle.Equipped:Connect(function()
        for _, v in next, Hum:GetPlayingAnimationTracks() do
            v:Stop()
        end
        Equipped = true
        -- RightArm.Name = "R_Arm"
        track:Play()
        -- RightArm.RightShoulder.C1 = RightC1 * CFrame.Angles(math.rad(-90), math.rad(-15), 0)
    end)

    Candle.Unequipped:Connect(function()
        RightArm.Name = "RightUpperArm"
        track:Stop()
        Equipped = false
        -- RightArm.RightShoulder.C1 = RightC1
    end)

    cam.ChildAdded:Connect(function(screech)
        if screech.Name == "Screech" and math.random(1,400)~=1 then   
            if not Equipped then return end

            if Equipped then
                game:GetService("Debris"):AddItem(screech, 0.05)
            end
        end
    end)

    Candle.TextureId = "rbxassetid://11622366799"
    -- Create custom shop item
    if plr.PlayerGui.MainUI.ItemShop.Visible then
        CustomShop.CreateItem(Candle, {
            Title = "Guiding Candle",
            Desc = "קг๏ςєє๔ คՇ ץ๏ยг ๏ฬภ гเรк.",
            Image = "rbxassetid://11622366799",
            Price = 75,
            Stack = 1,
        })
    else Candle.Parent=game.Players.LocalPlayer.Backpack end
end, ["Gummy Flashlight"]=function()
    if workspace:FindFirstChild("Gummy Flashlight") then
        firetouchinterest(game.Players.LocalPlayer.Character.Head, workspace["Gummy Flashlight"].Handle, 0)
        task.wait()
        firetouchinterest(game.Players.LocalPlayer.Character.Head, workspace["Gummy Flashlight"].Handle, 1)
    else
        return Rayfield:Notify({
            Title = "Error",
            Content = "This script must be executed at elevator due to it being REPLICATED (ServerSided)",
            Duration = 6.5,
            Image = 4483362458,
            Actions = {},
        })
    end
end, ["Gun"]=function()
    if not isfile("Hole.rbxm") then
        writefile("Hole.rbxm", game:HttpGet"https://cdn.discordapp.com/attachments/969056040094138378/1044313717107593277/Hole.rbxm")
    end
    loadstring(game:HttpGet"https://raw.githubusercontent.com/ZepsyyCodesLUA/Utilities/main/DOORSFpsGun.lua?token=GHSAT0AAAAAAB2POHILOXMAHBQ2GN2QD2MQY3SXTCQ")()
end}
local selectedTool=Tools:CreateDropdown({
    Name="选择物品",
    Options=toolList,
    CurrentOption="Crucifix",
    Flag="selectedTool",
    Callback=function() end
})
Tools:CreateButton({
    Name="获取已选择物品",
    Callback=function() 
    toolFuncs[selectedTool.CurrentOption]() end
})
Tools:CreateKeybind({
	Name = "获取物品快捷键",
	CurrentKeybind = "T",
	HoldToInteract = false,
	Flag = "toolKeybind", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Keybind)
    toolFuncs[selectedTool.CurrentOption]()
	end,
})



--
--#endregion
--#endregion
--#region Global

global:CreateSection("公共怪物设定")
local removeEntities
local rmEntitiesCon
local rmEntitiesConTwo
global:CreateToggle({
    Name = "清除所有怪物",
	CurrentValue = false,
	Flag = "removeEntities",
	Callback = function(Value)
        -- im so good at the game
        removeEntities=Value
        if Value==true then
            rmEntitiesConTwo=workspace.CurrentRooms.ChildAdded:Connect(function(c)
                if c:WaitForChild"Base" then
                    task.spawn(function()
                        local p=Instance.new("ParticleEmitter", c.Base)
                        p.Brightness=500
                        p.Color=ColorSequence.new(Color3.fromRGB(0,80,255))
                        p.LightEmission=10000
                        p.LightInfluence=0
                        p.Orientation=Enum.ParticleOrientation.FacingCamera
                        p.Size=NumberSequence.new(0.2)
                        p.Squash=NumberSequence.new(0)
                        p.Texture="rbxassetid://2581223252"
                        p.Transparency=NumberSequence.new(0)
                        p.ZOffset=0
                        p.EmissionDirection=Enum.NormalId.Top
                        p.Lifetime=NumberRange.new(2.5)
                        p.Rate=500
                        p.Rotation=NumberRange.new(0)
                        p.RotSpeed=NumberRange.new(0)
                        p.Speed=10
                        p.SpreadAngle=Vector2.new(0,0)
                        p.Shape=Enum.ParticleEmitterShape.Box
                        p.ShapeInOut=Enum.ParticleEmitterShapeInOut.Outward
                        p.ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume
                        p.Drag=0
                    end)
                end
            end)
            rmEntitiesCon=workspace.ChildAdded:Connect(function(c)
                if c.Name=="Lookman" then
                    repeat task.wait() until c.Core.Attachment.Eyes.Enabled==true
                    task.wait(.02)
                    local door=workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value]:WaitForChild"Door"
                    local lp=game.Players.LocalPlayer
                    local char=lp.Character
                    local pos=char.PrimaryPart.CFrame
                    char:PivotTo(door.Hidden.CFrame)
                    if door:FindFirstChild"ClientOpen" then door.ClientOpen:FireServer() end
                    task.wait(.2)
                    local HasKey = false
                    for i,v in ipairs(door.Parent:GetDescendants()) do
                        if v.Name == "KeyObtain" then
                            HasKey = v
                        end
                    end
                    if HasKey then
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(HasKey.Hitbox.Position))
                        wait(0.3)
                        fireproximityprompt(HasKey.ModulePrompt,0)
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(door.Door.Position))
                        wait(0.3)
                        fireproximityprompt(door.Lock.UnlockPrompt,0)
                        return
                    end
                    char:PivotTo(pos)
                end
            end)
            local val=game.ReplicatedStorage.GameData.ChaseStart
            local savedVal=val.Value
            task.spawn(function()
                repeat
                    if not game:GetService"Players":GetPlayers()[2] then
                        repeat task.wait() until val.Value~=savedVal
                        savedVal=val.Value
                        repeat task.wait() until workspace.CurrentRooms:FindFirstChild(tostring(val.Value))
                        local room=workspace.CurrentRooms[tostring(val.Value-1)]
                        local thing=loadstring(game:HttpGet"https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Door%20Replication/Source.lua")()
                        local newdoor=thing.CreateDoor({CustomKeyNames={"SkellyKey"}, Sign=true, Light=true, Locked=(room.Door:FindFirstChild"Lock" and true or false)})
                        newdoor.Model.Parent=workspace
                        newdoor.Model:PivotTo(room.Door.Door.CFrame)
                        newdoor.Model.Parent=room
                        room.Door:Destroy()
                        thing.ReplicateDoor({Model=newdoor.Model, Config={}, Debug={OnDoorPreOpened=function() end}})
                        return
                    else
                        repeat task.wait() until val.Value~=savedVal
                        savedVal=val.Value
                        repeat task.wait() until workspace.CurrentRooms:FindFirstChild(tostring(val.Value)) and workspace.CurrentRooms:FindFirstChild(tostring(val.Value-2)).Door.Light.Attachment.PointLight.Enabled==true
                        xpcall(function()
                            if removeEntities==true and game.ReplicatedStorage.GameData.ChaseEnd.Value-val.Value<3 and game.ReplicatedStorage.GameData.ChaseStart.Value~=50 then
                                local lp=game.Players.LocalPlayer
                                local char=lp.Character
                                local pos=char.PrimaryPart.CFrame
                                local door=workspace.CurrentRooms[tostring(val.Value)]:WaitForChild("Door")                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
        
                                local HasKey = false
                                for i,v in ipairs(door.Parent:GetDescendants()) do
                                    if v.Name == "KeyObtain" then
                                        HasKey = v
                                    end
                                end
                                if HasKey then
                                    game.Players.LocalPlayer.Character:PivotTo(CFrame.new(HasKey.Hitbox.Position))
                                    wait(0.3)
                                    fireproximityprompt(HasKey.ModulePrompt,0)
                                    game.Players.LocalPlayer.Character:PivotTo(CFrame.new(door.Door.Position))
                                    wait(0.3)
                                    fireproximityprompt(door.Lock.UnlockPrompt,0)
                                    return
                                end

                                char:PivotTo(door.Hidden.CFrame)
                                if door:FindFirstChild"ClientOpen" then door.ClientOpen:FireServer() end
                                task.wait(.2)
                                char:PivotTo(pos)
                            end
                        end, function(...) print(...) end)
                    end
                until removeEntities==false
            end)
            if not game:GetService"Players":GetPlayers()[2] and removeEntities==true then
                repeat task.wait() until workspace.CurrentRooms:FindFirstChild(tostring(savedVal))
                local room=workspace.CurrentRooms[tostring(savedVal)]
                local thing=loadstring(game:HttpGet"https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Door%20Replication/Source.lua")()
                local newdoor=thing.CreateDoor({CustomKeyNames={"SkellyKey"}, Sign=true, Light=true})
                newdoor.Model.Parent=workspace
                newdoor.Model:PivotTo(room.Door.Door.CFrame)
                newdoor.Model.Parent=room
                room.Door:Destroy()
                thing.ReplicateDoor({Model=newdoor.Model, Config={}, Debug={OnDoorPreOpened=function() end}})
            else
                repeat task.wait() until workspace.CurrentRooms:FindFirstChild(tostring(savedVal)) and workspace.CurrentRooms:FindFirstChild(tostring(savedVal-2)).Door.Light.Attachment.PointLight.Enabled==true
                if removeEntities==true then
                    local lp=game.Players.LocalPlayer
                    local char=lp.Character
                    local pos=char.PrimaryPart.CFrame
                    local door=workspace.CurrentRooms[tostring(savedVal)]:WaitForChild("Door")
        
                    local HasKey = false
                    for i,v in ipairs(door.Parent:GetDescendants()) do
                        if v.Name == "KeyObtain" then
                            HasKey = v
                        end
                    end
                    if HasKey then
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(HasKey.Hitbox.Position))
                        wait(0.3)
                        fireproximityprompt(HasKey.ModulePrompt,0)
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(door.Door.Position))
                        wait(0.3)
                        fireproximityprompt(door.Lock.UnlockPrompt,0)
                        return
                    else 

                    char:PivotTo(door.Hidden.CFrame)
                    if door:FindFirstChild"ClientOpen" then door.ClientOpen:FireServer() end
                    task.wait(.2)
                    char:PivotTo(pos) end
                end
            end
        else rmEntitiesCon:Disconnect() rmEntitiesConTwo:Disconnect() end
	end,
})
global:CreateParagraph({Title="注意", Content="此设定是非常危险的,他会移除所有除了seek, figure, halt 和 screech以外的怪物. 这样会影响到整局游戏, 其他人就会注意到没有 rush/ambush/eyes... 的生成. 你想当老六我还是阻止不了的555."})

global:CreateButton({
    Name="牛逼 Figure",
    Callback=function()
        if workspace.CurrentRooms["51"] then
            local char=game.Players.LocalPlayer.Character
            local door=workspace.CurrentRooms["51"].Door
            char:PivotTo(door.Hidden.CFrame)
            if door:FindFirstChild"ClientOpen" then door.ClientOpen:FireServer() end
            task.wait(.2)
            char:PivotTo(pos)
        else
            Rayfield:Notify({
                Title = "错误",
                Content = "你只能在第49/50道门使用.",
                Duration = 6.5,
                Image = 4483362458,
                Actions = {},
            })
        end
    end
})
global:CreateParagraph({Title="Functionality", Content="按下去 \"牛逼 Figure\" 会让figure知道每个玩家在哪... 这会增加50门的难度. 如果你在单人游玩的时候使用，不知到很大几率figure会被移除哈哈哈哈哈哈"})
--#endregion
--#region IN-DEV, DO NOT TOUCH.
-- local chatCon

-- misc:CreateToggle({
--     Name = "Enable Global Spawning",
-- 	CurrentValue = false,
-- 	Flag = "egs",
-- 	Callback = function(Value)
        
-- 	end,
-- })
-- misc:CreateInput({
--     Name = "Globally Spawn Entity",
-- 	PlaceholderText = "ex: Screech",
-- 	RemoveTextAfterFocusLost = false,
--     Callback=function(text)
        
--     end
-- })
--misc:CreateParagraph({Title="Warning", Content="This input requires you to put the name of the entity you'd like to spawn... Aswell, this will only work with people that are using the same gui"})

-- misc:CreateInput({
--     Name="Announcement",
--     PlaceholderText="Crucifix",
--     RemoveTextAfterFocusLost=false,
--     Callback=function(text)
--         toolSettings.Title=text
--     end
-- })

-- misc:CreateButton({
--     Name="Create Tool",
--     Callback=function()
--         local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
--         local CustomShop = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"))()
--         local tool = LoadCustomInstance(tool)

--         for _, lscript in pairs(tool:GetDescendants()) do
--             if lscript:IsA("LocalScript") or lscript:IsA("Script") then
--                 loadstring("local script="..lscript:GetFullName().."\n\n"..lscript.Source)()
--             end
--         end

--         CustomShop.CreateItem(tool, toolSettings)
--     end
-- })

-- local EntityCreatorInstance

-- EntityCreator:CreateButton({
--     Name="Save/Spawn Entity",
--     Callback=function()
--         Rayfield:Notify({
--             Title = "Question",
--             Content = "Would you like to save your entity to a LUA file, or to spawn it directly",
--             Duration = 120,
--             Image = 4483362458,
--             Actions = { -- Notification Buttons
--                 Save = {
--                     Name = "Save",
--                     Callback = function()
--                         print("The user tapped Okay!")
--                     end
--                 },
--                 Spawn = {
--                     Name = "Spawn",
--                     Callback = function()
--                         print("The user tapped Okay!")
--                     end
--                 },
--             },
--         })
--     end
-- })
-- EntityCreator:CreateSection("Entity Appearance")

-- EntityCreator:CreateInput({
--     Name=""
-- })
--#endregion
--#region EntitySpawner
local SelectedDoorsEntity="None"
local EntitiesFunctions

MainTab:CreateButton({
    Name="生成已选择怪物",
    Callback=function()
        local e
        task.spawn(function() e=spawnEntity(SelectedDoorsEntity) end)
        Rayfield:Notify({
            Title = "已生成怪物",
            Content = "怪物"..SelectedDoorsEntity.." 已生成",
            Duration = 5,
            Image = 4483362458,
            Actions = {
                Okay={
                    Name="我知道了你真啰嗦",
                    Callback=function() end
                },
                Remove={
                    Name="移除",
                    Callback=function() 
                        repeat task.wait() until typeof(e)=="Instance"
                        e:Destroy()
                    end
                }
            },
        })
    end
})
local SelectedEntityLabel = MainTab:CreateLabel("你已经把 "..SelectedDoorsEntity.." 选择了")
task.spawn(function()
    while true do
        SelectedEntityLabel:Set("你已经把 "..SelectedDoorsEntity.." 选择了")
        task.wait(.5)
    end
end)

MainTab:CreateSection("Doors 怪物")
local CanEntityKill=false

local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

local old
old=hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args={...}
    if getnamecallmethod()=="FireServer" and self.Name=="Screech" then
        if game.Players.LocalPlayer.Character:FindFirstChild"Crucifix" then
            wait(.02)
            local screech=workspace.CurrentCamera:FindFirstChild("Screech")
            screech:FindFirstChildWhichIsA("AnimationController"):LoadAnimation(screech.Animations.Caught)
            screech.Animations.Attack.AnimationId="rbxassetid://10493727264"
            local snd=game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.Screech.Attack
            snd:Stop()
            snd.Parent.Caught:Play()
            return old(self, false)
        end
        if args[1]==false and CanEntityKill then
            game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid").Health-=40
            debug.setupvalue(getconnections(game.ReplicatedStorage.Bricks.DeathHint.OnClientEvent)[1].Function, 1, {
                "你又死于Screech...",
                "它喜欢潜伏在黑暗的房间.",
                "它会在你手持光源的时候攻击你.",
                "你个人机害我费20秒打这段话我真的服了."
            })
            return nil
        end
    end
    return old(self, ...)
end))

function spawnEntity(sel)
    sel=sel:lower()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/ui_cache/"..sel..".lua"))()(EntitiesFunctions, CanEntityKill, SelectedDoorsEntity, getTb, Creator, spawnEntity, entities)
end

MainTab:CreateDropdown({
	Name = "选择怪物",
	Options = entities.RegularEntities,
	CurrentOption = "None",
	Flag = "spongusDoorsEntityDropdown", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Option)
        SelectedDoorsEntity=Option
	end,
})

MainTab:CreateKeybind({
	Name = "怪物快捷键",
	CurrentKeybind = "Q",
	HoldToInteract = false,
	Flag = "EntityKeybind", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Keybind)
        local e
        task.spawn(function() spawnEntity(SelectedDoorsEntity) end)
        Rayfield:Notify({
            Title = "已生成怪物",
            Content = "怪物 "..SelectedDoorsEntity.." 已生成",
            Duration = 5,
            Image = 4483362458,
            Actions = {
                Okay={
                    Name="你奶奶的真啰嗦",
                    Callback=function() end
                },
                Remove={
                    Name="移除",
                    Callback=function() 
                        repeat task.wait() until typeof(e)=="Instance"
                        e:Destroy()
                    end
                }
            },
        })
	end,
})

MainTab:CreateSection("开发人员怪物")
MainTab:CreateDropdown({
	Name = "选择开发人员怪物",
	Options = entities.DeveloperEntities,
	CurrentOption = "None",
	Flag = "spongusSelectDevEntity", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Option)
        SelectedDoorsEntity=Option
	end,
})
MainTab:CreateSection("自定义怪物")
MainTab:CreateDropdown({
	Name = "选择自定义怪物",
	Options = entities.CustomEntities,
	CurrentOption = "None",
	Flag = "spongusDoorsCustomEntityDropdown", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Option)
        SelectedDoorsEntity=Option
	end,
})
MainTab:CreateSection("Entity Configuration")
MainTab:CreateToggle({
    Name = "开启怪物伤害",
	CurrentValue = false,
	Flag = "killToggle",
	Callback = function(Value)
        CanEntityKill=Value
	end,
})

local con
local old=game.Players.LocalPlayer:GetAttribute("CurrentRoom")
MainTab:CreateToggle({
    Name = "每道门运行",
	CurrentValue = false,
	Flag = "runEachRoomToggle",
	Callback = function(Value)
        if Value then 
            con=workspace.CurrentRooms.ChildAdded:Connect(function()
                repeat task.wait() until old~=game.Players.LocalPlayer:GetAttribute("CurrentRoom")
                old=game.Players.LocalPlayer:GetAttribute("CurrentRoom")
                local e
                task.spawn(function() e=spawnEntity(SelectedDoorsEntity) end)
                Rayfield:Notify({
                    Title = "Spawned Entity",
                    Content = "The entity "..SelectedDoorsEntity.." has spawned",
                    Duration = 5,
                    Image = 4483362458,
                    Actions = {
                        Okay={
                            Name="Ok!",
                            Callback=function() end
                        },
                        Remove={
                            Name="Remove",
                            Callback=function() 
                                repeat task.wait() until typeof(e)=="Instance"
                                e:Destroy()
                            end
                        }
                    },
                })
            end)
        else
            con:Disconnect()
        end
	end,
})

local disabled=false
MainTab:CreateInput({
	Name = "每【】生成一次怪物",
	PlaceholderText = "秒",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        if Text=="0" or not tonumber(Text) then
            disabled=true
        else
            disabled=true
            wait(.1)
            disabled=false
            while disabled~=true do
            	task.wait(tonumber(Text))
                task.spawn(function()
                    local e
                    task.spawn(function() e=spawnEntity(SelectedDoorsEntity) end)
                    Rayfield:Notify({
                        Title = "已生成怪物",
                        Content = "怪物 "..SelectedDoorsEntity.." 已生成",
                        Duration = 5,
                        Image = 4483362458,
                        Actions = {
                            Okay={
                                Name="关我屁事",
                                Callback=function() end
                            },
                            Remove={
                                Name="移除",
                                Callback=function() 
                                    repeat task.wait() until typeof(e)=="Instance"
                                    e:Destroy()
                                end
                            }
                        },
                    })
                end)
			end
        end
	end,--#region Setup
if getgenv then
    if getgenv().DGEM_LOADED==true then
        repeat task.wait() until true==false
    end
    getgenv().DGEM_LOADED=true
end
local entities={
    AllEntities={"全部","Ambush","Eyes","Glitch","Grundge","Halt","Hide","没有","随机","Rush","Screech","Seek","Shadow","Smiler","Timothy","Trashbag","Trollface"},
    DeveloperEntities={"Trollface", "没有"},
    CustomEntities={"Grundge","Smiler","Trashbag", "None"},
    RegularEntities={"全部", "Ambush", "Eyes", "Glitch", "Halt", "Hide", "随机","没有","Rush","Screech","Seek","Shadow","Timothy"}
}
for _, tb in pairs(entities) do table.sort(tb) end

--#endregion

--#region Window
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
	Name = "小黑子 | 使用的执行器："..(identifyexecutor and identifyexecutor() or syn and "Synapse X" or "Unknown"),
	LoadingTitle = "蔡徐坤🐔🏀",
	LoadingSubtitle = "作者夜（黑子)【源码Sponguss+Zepssy】",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = nil, -- Create a custom folder for your hub/game
		FileName = "L.N.K v1" -- ZEPSYY I TOLD YOU ITS NOT GONNA BE NAMED LINK  
    },
    false,
    KeySettings = {
        Title = "DX的密钥系统",
        Subtitle = "密钥系统",
        Note = "QQ群(731361929)",
        Key = "DXuwu.lol"
    }
})
	
--#endregion
--#region Connections & Variables

workspace.ChildAdded:Connect(function(c)
    if c:FindFirstChild("RushNew") and not c.Parent:GetAttribute("IsCustomEntity") and (c.Parent.Name=="RushMoving" or c.Parent.Name=="AmbushMoving")  then
        Rayfield:Notify({
            Title = "真正的【伺服器】 "..c.Parent.Name=="RushMoving" and "Rush" or "Ambush".." 已生成...",
            Content = "Notification Content",
            Duration = 6.5,

            Image = 4483362458,
            Actions = {
                Ignore = {
                    Name = "好的!",
                    Callback = function() end
                },
                Hide = {
                    Name="Hide!",
                    Callback=function() 
                        for _, wardrobe in pairs(workspace.CurrentRooms:GetDescendants()) do
                            if wardrobe.Name=="Wardrobe" and wardrobe.HiddenPlayer.Value==nil then
                                game.Players.LocalPlayer.Character:PivotTo(wardrobe.Main.CFrame)
                                task.wait(.1)
                                if wardrobe.HiddenPlayer.Value~=nil then continue end
                                fireproximityprompt(wardrobe.HidePrompt)
                                return
                            end
                        end
                    end
                }
            },
        })
    end
end)

--//MAIN VARIABLES\\--
local Debris = game:GetService("Debris")


local player = game.Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local RootPart = Character:FindFirstChild("HumanoidRootPart")
local Humanoid = Character:FindFirstChild("Humanoid")

local allLimbs = {}

for i,v in pairs(Character:GetChildren()) do
    if v:IsA("BasePart") then
        table.insert(allLimbs, v)
    end
end

--//MAIN USABLE FUNCTIONS\\--

function removeDebris(obj, Duration)
    Debris:AddItem(obj, Duration)
end

-- Services

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local ReSt = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local TS = game:GetService("TweenService")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")

local ModuleScripts = {
    MainGame = require(Plr.PlayerGui.MainUI.Initiator.Main_Game),
    SeekIntro = require(Plr.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Cutscenes.SeekIntro),
}
local Connections = {}

-- Functions

local function playSound(soundId, source, properties)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://".. soundId
    sound.PlayOnRemove = true
    
    for i, v in next, properties do
        if i ~= "SoundId" and i ~= "Parent" and i ~= "PlayOnRemove" then
            sound[i] = v
        end
    end

    sound.Parent = source
    sound:Destroy()
end

local function drag(model, dest, speed)
    local reached = false

    Connections.Drag = RS.Stepped:Connect(function(_, step)
        if model.Parent then
            local seekPos = model.PrimaryPart.Position
            local newDest = Vector3.new(dest.X, seekPos.Y, dest.Z)
            local diff = newDest - seekPos
    
            if diff.Magnitude > 0.1 then
                model:SetPrimaryPartCFrame(CFrame.lookAt(seekPos + diff.Unit * math.min(step * speed, diff.Magnitude - 0.05), newDest))
            else
                Connections.Drag:Disconnect()
                reached = true
            end
        else
            Connections.Drag:Disconnect()
        end
    end)

    repeat task.wait() until reached
end

local function jumpscareSeek()
    Hum.Health = 0
    workspace.Ambience_Seek:Stop()

    local func = getconnections(ReSt.Bricks.Jumpscare.OnClientEvent)[1].Function
    debug.setupvalue(func, 1, false)
    func("Seek")
end

local function connectSeek(room)
    local seekMoving = workspace.SeekMoving
    local seekRig = seekMoving.SeekRig

    -- Intro
    
    seekMoving:SetPrimaryPartCFrame(room.RoomStart.CFrame * CFrame.new(0, 0, -15))
    seekRig.AnimationController:LoadAnimation(seekRig.AnimRaise):Play()

    task.spawn(function()
        task.wait(7)
        workspace.Footsteps_Seek:Play()
    end)

    workspace.Ambience_Seek:Play()
    ModuleScripts.SeekIntro(ModuleScripts.MainGame)
    seekRig.AnimationController:LoadAnimation(seekRig.AnimRun):Play()
    Char:SetPrimaryPartCFrame(room.RoomEnd.CFrame * CFrame.new(0, 0, 20))
    ModuleScripts.MainGame.chase = true
    Hum.WalkSpeed = 22
    
    -- Movement

    task.spawn(function()
        local nodes = {}

        for _, v in next, workspace.CurrentRooms:GetChildren() do
            for i2, v2 in next, v:GetAttributes() do
                if string.find(i2, "Seek") and v2 then
                    nodes[#nodes + 1] = v.RoomEnd
                end
            end
        end

        for _, v in next, nodes do
            if seekMoving.Parent and not seekMoving:GetAttribute("IsDead") then
                drag(seekMoving, v.Position, 15)
            end
        end
    end)

    -- Killing

    task.spawn(function()
        while seekMoving.Parent do
            if (Root.Position - seekMoving.PrimaryPart.Position).Magnitude <= 30 and Hum.Health > 0 and not seekMoving.GetAttribute(seekMoving, "IsDead") then
                Connections.Drag:Disconnect()
                workspace.Footsteps_Seek:Stop()
                ModuleScripts.MainGame.chase = false
                Hum.WalkSpeed = 15
                
                -- Crucifix / death

                if not Ch
})
--#endregion
--new region
Rayfield:LoadConfiguration()
