repeat wait() until game.Players.LocalPlayer.Character
print("charloaded")
wait(5)
print("started")
_G.speed = 5 --- 15 or higher = risk

local Plr = game.Players.LocalPlayer

local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
local File = pcall(function()
    AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
end)
if not File then
    table.insert(AllIDs, actualHour)
    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
end
function TPReturner()
    local Site;
    if foundAnything == "" then
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end
    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end
    local num = 0;
    for i,v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _,Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        local delFile = pcall(function()
                            delfile("NotSameServers.json")
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end)
                    end
                end
                num = num + 1
            end
            if Possible == true then
                table.insert(AllIDs, ID)
                wait()
                pcall(function()
                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                    wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                end)
                wait(4)
            end
        end
    end
end

function Teleport()
    while wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end


function To(position)
_G.Tp = (Vector3.new(position.x, position.y, position.z))
spawn(function()
local Chr = Plr.Character
if Chr ~= nil then
local ts = game:GetService("TweenService")
local char = game.Players.LocalPlayer.Character
local hm = char.HumanoidRootPart
_G.YPos = hm.Position.y + 10
local dist = (hm.Position - position).magnitude
local tweenspeed = dist/tonumber(_G.speed*10)
local ti = TweenInfo.new(tonumber(tweenspeed), Enum.EasingStyle.Linear)
local tp = {CFrame = CFrame.new(position)}
_G.TweenThing = ts:Create(hm, ti, tp)
_G.TweenThing:Play()
wait(tonumber(tweenspeed))
_G.TweenThing = nil
end
end)
end

local humanoid = game.Players.LocalPlayer.Character.HumanoidRootPart

wait(1.5)
local ChestFolder = Instance.new("Folder")
ChestFolder.Name = "ChestFolder"
ChestFolder.Parent = game.Workspace

for i, chest in pairs(game.Workspace.Env:GetChildren()) do
    if chest.Name == "Part" then
        if (humanoid.Position - chest.Position).magnitude < 750 then
        chest.Parent = ChestFolder
        else
        chest:Destroy()
        end
    end
end

for i, chest in pairs(ChestFolder:GetChildren()) do
    To(chest.Position + Vector3.new(0, 1, 0))
    repeat
    wait(1)
    until (humanoid.Position - chest.Position).magnitude < 10
    wait(1.25)
    fireclickdetector(chest.ClickDetector)
    wait(.25)
end

wait(0.5)

game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
        syn.queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/StepBroFurious/Script/main/Chestfarm.lua'))()")
    end
end)

Teleport()
