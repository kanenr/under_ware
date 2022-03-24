
--// wait until game loaded

if not game:IsLoaded() then
    game.Loaded:Wait()
end

--// localizations 

local getupvalues = getupvalues
local getconstants = getconstants
local getinfo = getinfo
local setupvalue = setupvalue
local validlevel = debug.validlevel or debug.isvalidlevel
local replaceclosure = replaceclosure
local getconnections = getconnections
local hookmetamethod = hookmetamethod
local newcclosure = newcclosure
local checkcaller = checkcaller
local getnamecallmethod = getnamecallmethod
local sethiddenproperty = sethiddenproperty
local gethiddenproperty = gethiddenproperty
local firesignal = firesignal

local request = request or syn and syn.request
local protect_gui = syn and function(gui) syn.protect_gui(gui) gui.Parent = game:GetService("CoreGui") end or gethui and function(gui) gui.Parent = gethui() end

local game = game
local workspace = workspace

local setmetatable = setmetatable
local type = type 
local typeof = typeof
local select = select 
local pcall = pcall
local wait = wait
local tick = tick
local getfenv = getfenv 
local setfenv = setfenv

local table_find = table.find 
local table_remove = table.remove
local table_insert = table.insert
local coroutine_yield = coroutine.yield
local coroutine_wrap = coroutine.wrap
local task_wait = task.wait
local task_spawn = task.spawn
local math_random = math.random
local math_clamp = math.clamp
local math_floor = math.floor
local math_abs = math.abs
local math_huge = math.huge
local region3_new = Region3.new
local vector3_new = Vector3.new
local cframe_new = CFrame.new
local cframe_fromeulerangles = CFrame.fromEulerAnglesYXZ
local vector2_new = Vector2.new
local raycast_params_new = RaycastParams.new
local instance_new = Instance.new
local os_time = os.time
local ray_new = Ray.new
local udim2_new = UDim2.new
local string_upper = string.upper
local color3_fromrgb = Color3.fromRGB

--// services handler

local service_cache = {}
local services = setmetatable({}, {
    __index = function(self, index)
        local cached_service = service_cache[index]
        
        if not cached_service then 
            service_cache[index] = select(2, pcall(game.GetService, game, index))
            return service_cache[index]
        end 
        
        return cached_service
    end
})

--// init variables

local player = services.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local ping_stat = services.Stats:WaitForChild("PerformanceStats"):WaitForChild("Ping")

local global_variables = {
    ban_animation_ids = {},
    alert_notifications = {},
    block_all_remotes = false,
    block_all_animations = false,
    spell_cost = {
        ["Armis"] = {{40, 60}, {70, 80}},
        ["Trickstus"] = {{30, 70}, {30, 50}},
        ["Scrupus"] = {{30, 100}, {30, 100}},
        ["Celeritas"] = {{70, 90}, {70, 80}},
        ["Ignis"] = {{80, 95}, {53, 57}},
        ["Gelidus"] = {{80, 95}, {85, 100}},
        ["Viribus"] = {{25, 35}, {60, 70}},
        ["Sagitta Sol"] = {{50, 65}, {40, 60}},
        ["Tenebris"] = {{90, 100}, {40, 60}},
        ["Nocere"] = {{70, 85}, {70, 85}},
        ["Hystericus"] = {{75, 90}, {15, 35}},
        ["Shrieker"] = {{30, 50}, {30, 50}},
        ["Verdien"] = {{75, 100}, {75, 85}},
        ["Contrarium"] = {{80, 95}, {70, 90}},
        ["Floresco"] = {{90, 100}, {80, 95}},
        ["Perflora"] = {{70, 90}, {30, 50}},
        ["Manus Dei"] = {{90, 95}, {50, 60}},
        ["Fons Vitae"] = {{75, 100}, {75, 100}},
        ["Trahere"] = {{75, 85}, {75, 85}},
        ["Furantur"] = {{60, 80}, {60, 80}},
        ["Inferi"] = {{10, 30}, {10, 30}},
        ["Howler"] = {{60, 80}, {60, 80}},
        ["Secare"] = {{90, 95}, {90, 95}},
        ["Ligans"] = {{63, 80}, {63, 80}},
        ["Reditus"] = {{50, 100}, {50, 100}},
        ["Fimbulvetr"] = {{86, 90}, {70, 80}},
        ["Gate"] = {{75, 80}, {75, 80}},
        ["Snarvindur"] = {{60, 75}, {20, 30}},
        ["Hoppa"] = {{40, 60}, {50, 60}},
        ["Percutiens"] = {{60, 70}, {70, 80}},
        ["Dominus"] = {{50, 100}, {50, 100}},
        ["Custos"] = {{45, 65}, {45, 65}},
        ["Claritum"] = {{90, 100}, {90, 100}},
        ["Globus"] = {{70, 100}, {70, 100}},
        ["Intermissum"] = {{70, 100}, {70, 100}},
        ["Sraunus"] = {{1, 50}, {1, 50}},
        ["Nosferatus"] = {{95, 100}, {95, 100}},
        ["Gourdus"] = {{80, 90}, {80, 90}},
        ["Telorum"] = {{80, 90}, {75, 85}},
        ["Velo"] = {{0, 100}, {50, 60}}
    }
}

local global_functions = {
    block_random_player = function()
        local block_player 
        local players_list = services.Players:GetPlayers()

        for index = 1, #players_list do
            local target_player = players_list[index]

            if target_player.Name ~= player.Name then
                block_player = target_player
                break
            end
        end

        services.StarterGui:SetCore("PromptBlockPlayer", block_player)

        local container_frame = services.CoreGui.RobloxGui:WaitForChild("PromptDialog"):WaitForChild("ContainerFrame")

        local confirm_button = container_frame:WaitForChild("ConfirmButton")
        local confirm_button_text = confirm_button:WaitForChild("ConfirmButtonText")
        
        if confirm_button_text.Text == "Block" then  
            wait()
            
            local confirm_position = confirm_button.AbsolutePosition
            
            services.VirtualInputManager:SendMouseButtonEvent(confirm_position.X + 10, confirm_position.Y + 45, 0, true, game, 0)
            task_wait()
            services.VirtualInputManager:SendMouseButtonEvent(confirm_position.X + 10, confirm_position.Y + 45, 0, false, game, 0)
        end
    end,

    is_knocked = function()
        local character = player.Character

        if character then 
            return services.CollectionService:HasTag(character, "Knocked")
        end 

        return false
    end
}

--// check if player is in game

if not player.Character then
    local start_menu = player.PlayerGui:WaitForChild("StartMenu", 5)
    firesignal(start_menu:WaitForChild("Choices"):WaitForChild("Play").MouseButton1Click)
end

--// ui init

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/kanenr/under_ware/main/garbage_ui.lua"))()
local window = library:Window({Name = "Rogue Lineage"})

local tabs = {
    movement = window:Tab({Name = "Movement"}),
    character = window:Tab({Name = "Local"}),
    prevention = window:Tab({Name = "Prevention"}),
    misc = window:Tab({Name = "Misc"}),
    player_visuals = window:Tab({Name = "Player Visuals"}),
    game_visuals = window:Tab({Name = "Game Visuals"}),
    world = window:Tab({Name = "World"}),
    automation = window:Tab({Name = "Automation"}),
    bots = window:Tab({Name = "Bots"}),
    safety = window:Tab({Name = "Safety"}),
    discord = window:Tab({Name = "Discord"})
}

local sections = {
    movement_settings = tabs.movement:Section({Name = "Settings"}),
    local_misc = tabs.character:Section({Name = "Misc"}),
    
    misc_legit = tabs.misc:Section({Name = "Legit"}),
    misc_status = tabs.misc:Section({Name = "Status"}),
    misc_random = tabs.misc:Section({Name = "Random"}),

    prevention_settings = tabs.prevention:Section({Name = "Settings"}),

    game_visuals_combat_visualizer = tabs.game_visuals:Section({Name = "Combat Visualizer"}),
    game_visuals_misc = tabs.game_visuals:Section({Name = "Misc"}),
    game_visuals_trinket = tabs.game_visuals:Section({Name = "Trinkets"}),
    game_visuals_ores = tabs.game_visuals:Section({Name = "Ores"}),
    game_visuals_ingredient = tabs.game_visuals:Section({Name = "Ingredients"}),

    player_visuals_settings = tabs.player_visuals:Section({Name = "Settings"}),
    
    world_settings = tabs.world:Section({Name = "Settings"}),
    spoof_settings = tabs.world:Section({Name = "Spoofing"}),

    automation_settings = tabs.automation:Section({Name = "Settings"}),

    bots_settings = tabs.bots:Section({Name = "Settings"}),

    safety_protection = tabs.safety:Section({Name = "Protection"}),

    discord_join = tabs.discord:Section({Name = "Discord"})
}

--// client anticheat bypass

do
    local function trigger_callback()
        local anticheat_mode = library.flags["Anticheat Mode"]

        if anticheat_mode == "Block" then 
            task_spawn(function()
                global_variables.block_all_remotes = true
                global_variables.block_all_animations = true

                wait(1)

                global_variables.block_all_animations = false
                global_variables.block_all_remotes = false
            end)
        elseif anticheat_mode == "Kick" then 
            player:Kick("Anticheat Triggered")
        end
    end 

    local nil_instances = getnilinstances()
    local ban_animation_ids = {}

    for index = 1, #nil_instances do 
        local value = nil_instances[index]
        
        if value.ClassName == "AnimationTrack" then 
            local animation_instance = value.Animation

            if not animation_instance.Parent then
                ban_animation_ids[animation_instance.AnimationId] = true
            end
        end
    end

    if not ban_animation_ids["rbxassetid://4595066903"] then 
        ban_animation_ids["rbxassetid://4595066903"] = true
    end

    local humanoid = workspace.NPCs:FindFirstChildWhichIsA("Humanoid", true)

    local animation = instance_new("Animation")
    animation.AnimationId = "rbxassetid://180435571"

    local animation_play = humanoid:LoadAnimation(animation).Play

    local old_animation_play
    old_animation_play = replaceclosure(animation_play, newcclosure(function(self, ...)
        if global_variables.block_all_animations then 
            return
        end 

        if typeof(self) == "Instance" and self.ClassName == "AnimationTrack" then
            local animation_id = self.Animation.AnimationId:gsub("[^%w%s_]+", "")

            if ban_animation_ids[animation_id] then 
                return trigger_callback()
            end
        end
        
        return old_animation_play(self, ...)
    end))

    local blacklisted_character_descendants = {}

    local function update_character_blacklist(character)
        wait(1)

        local character_descendants = character:GetDescendants()

        for index = 1, #character_descendants do 
            local descendant = character_descendants[index]
    
            if not ((descendant.ClassName == "Accessory" and (descendant.Name == "Charge" or descendant.Name == "Blindness" or descendant.Name == "DamageMPStack" or descendant.Name == "VisionBlur" or descendant.Name == "Sprint" or descendant.Name == "Climbing" or descendant.Name == "ClimbCooldown")) or (descendant.ClassName == "BodyVelocity" and descendant.Name == "DodgeVel") or (descendant.ClassName == "BodyPosition" and descendant.Name == "BodyPosition")) then 
                blacklisted_character_descendants[descendant] = true
            end
        end
    end

    local character = player.Character or player.CharacterAdded:Wait()

    update_character_blacklist(character)
    player.CharacterAdded:Connect(update_character_blacklist)

    local old_destroy
    old_destroy = replaceclosure(game.Destroy, newcclosure(function(self)
        if typeof(self) == "Instance" and blacklisted_character_descendants[self] then
            return trigger_callback()
        end
        
        return old_destroy(self)
    end))

    local old_remove
    old_remove = replaceclosure(game.Remove, newcclosure(function(self)
        if typeof(self) == "Instance" and blacklisted_character_descendants[self] then
            return trigger_callback()
        end
        
        return old_remove(self)
    end))

    local old_destroy_2
    old_destroy_2 = replaceclosure(game.destroy, newcclosure(function(self)
        if typeof(self) == "Instance" and blacklisted_character_descendants[self] then
            return trigger_callback()
        end
        
        return old_destroy_2(self)
    end))

    local old_remove_2
    old_remove_2 = replaceclosure(game.remove, newcclosure(function(self)
        if typeof(self) == "Instance" and blacklisted_character_descendants[self] then
            return trigger_callback()
        end
        
        return old_remove_2(self)
    end))

    local old_add_item
    old_add_item = replaceclosure(services.Debris.AddItem, newcclosure(function(self, object, duration)
        if blacklisted_character_descendants[object] then
            return trigger_callback()
        end

        return old_add_item(self, object, duration)
    end))

    local old_add_item_2
    old_add_item_2 = replaceclosure(services.Debris.addItem, newcclosure(function(self, object, duration)
        if blacklisted_character_descendants[object] then
            return trigger_callback()
        end

        return old_add_item(self, object, duration)
    end))

    local old_clear_all_children
    old_clear_all_children = replaceclosure(game.ClearAllChildren, newcclosure(function(self)
        local character = player.Character

        if character and self == character then 
            return trigger_callback() 
        end
        
        return old_clear_all_children(self)
    end))

    local old_clear_all_children_2
    old_clear_all_children_2 = replaceclosure(game.clearAllChildren, newcclosure(function(self)
        local character = player.Character

        if character and self == character then 
            return trigger_callback() 
        end
        
        return old_clear_all_children_2(self)
    end))

    local old_coroutine_wrap
    old_coroutine_wrap = replaceclosure(coroutine.wrap, newcclosure(function(func)
        if type(func) == "function" and islclosure(func) then
            local upvalues = getupvalues(func)

            if #upvalues == 1 and upvalues[1] == services.RunService and getinfo(func, "n").name == "" then
                return function() end
            end
        end

        return old_coroutine_wrap(func)
    end))

    local old_namecall
    old_namecall = hookmetamethod(game, "__namecall", function(self, ...)
        local arguments = {...}
        local method = string.lower(getnamecallmethod())

        if ((not checkcaller() and method == "destroy") or method == "remove") and typeof(self) == "Instance" and blacklisted_character_descendants[self] then 
            return trigger_callback()
        elseif method == "additem" and self == services.Debris then 
            local object = arguments[1]

            if typeof(object) == "instance" and blacklisted_character_descendants[object] then
                return trigger_callback()
            end
        elseif method == "clearallchildren" then
            local character = player.Character

            if character and self == character then 
                return trigger_callback()
            end
        elseif method == "play" and typeof(self) == "Instance" and self.ClassName == "AnimationTrack" and ban_animation_ids[self.Animation.AnimationId] then 
            return trigger_callback()
        end

        return old_namecall(self, ...)
    end)

    local connections = getconnections(game.ScriptContext.Error)

    for index = 1, #connections do 
        connections[index]:Disable()
    end
end

--// keyhandler bypass

do
    local key_handler = services.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Modules"):WaitForChild("KeyHandler")

    local patcher = {}
    patcher.__index = patcher

    local psu_struct = {
        stack_next = "sBgaL",
        register_c = 639954,
        register_bx = "jDWh3",
        register_b = -50014
    }

    function patcher.new(psu_function)
        return setmetatable({
            upvalues = getupvalues(psu_function),
            instructions = nil,
            stack = nil,
            indexes = {},
            current_instruction = 0
        }, patcher)
    end

    function patcher:grab_dependencies()
        for index, upvalue in ipairs(self.upvalues) do 
            if type(upvalue) == "table" then
                if upvalue[0] then
                    local entry = upvalue[0]

                    if entry and type(entry) == "table" then 
                        if entry[psu_struct.stack_next] then 
                            self.instructions = upvalue
                        end
                    end
                else
                    self.stack = upvalue
                end
            end
        end
        
        assert(self.instructions, "unable to find instructions!")
        assert(self.stack, "unable to find stack!")
    end

    function patcher:patch_instruction(old_value, new_value)
        for index, value in next, new_value do 
            old_value[index] = value
        end
    end

    function patcher:patch_method(method, ...)
        if method == 1 then
            local current_instruction = self.current_instruction
            local eq_amount = 0

            while true do
                local instruction = self.instructions[current_instruction] 

                if type(instruction[psu_struct.register_b]) == "table" then 
                    eq_amount = eq_amount + 1
                else
                    eq_amount = 0
                end

                if eq_amount == 2 then 
                    local to_patch_instruction = self.instructions[current_instruction - 1]
                    local go_to_instruction = instruction[psu_struct.register_b]
                
                    self:patch_instruction(to_patch_instruction, go_to_instruction)
                    current_instruction = table_find(self.instructions, go_to_instruction)
                    break
                end

                current_instruction = current_instruction + 1
            end

            self.current_instruction = current_instruction
        elseif method == 2 then 
            local current_instruction = self.current_instruction
            local to_patch_instruction

            while true do 
                local instruction = self.instructions[current_instruction]

                if type(instruction[psu_struct.register_b]) == "table" then 
                    if self.instructions[current_instruction + 2][psu_struct.register_c] == "LocalPlayer" then 
                        local to_patch_instruction = instruction
                        local go_to_instruction = instruction[psu_struct.register_b]

                        self:patch_instruction(to_patch_instruction, go_to_instruction)
                        current_instruction = table_find(self.instructions, go_to_instruction)
                        break
                    end
                end

                current_instruction = current_instruction + 1
            end

            self.current_instruction = current_instruction
        elseif method == 3 then
            local current_instruction = self.current_instruction
            local to_patch_instruction

            while true do 
                local instruction = self.instructions[current_instruction]

                if type(instruction[psu_struct.register_b]) == "table" then 
                    if self.instructions[current_instruction - 3][psu_struct.register_c] == "FindFirstChild" then 
                        local to_patch_instruction = instruction
                        local go_to_instruction = instruction[psu_struct.register_b]

                        self:patch_instruction(to_patch_instruction, go_to_instruction)
                        current_instruction = table_find(self.instructions, go_to_instruction)
                        break
                    end
                end

                current_instruction = current_instruction + 1
            end

            self.current_instruction = current_instruction
        elseif method == 4 then
            local current_instruction = self.current_instruction
            local to_patch_instruction

            while true do 
                local instruction = self.instructions[current_instruction]

                if type(instruction[psu_struct.register_b]) == "table" then 
                    if type(self.instructions[current_instruction + 2][psu_struct.register_bx]) == "table" and type(self.instructions[current_instruction + 5][psu_struct.register_bx]) == "table" then 
                        local to_patch_instruction = instruction
                        local go_to_instruction = instruction[psu_struct.register_b]

                        self:patch_instruction(to_patch_instruction, go_to_instruction)
                        current_instruction = table_find(self.instructions, go_to_instruction)
                        break
                    end
                end

                current_instruction = current_instruction + 1
            end

            self.current_instruction = current_instruction
        elseif method == 5 then
            local current_instruction = self.current_instruction
            local to_patch_instruction

            local arguments = {...}

            while true do 
                local instruction = self.instructions[current_instruction]

                if type(instruction[psu_struct.register_b]) == "table" then 
                    if self.instructions[current_instruction + arguments[1]][psu_struct.register_b] == "EEKEWAEJIWAJDOIWAJDIOJAWDIOJAWODJOAIW" then 
                        local to_patch_instruction = instruction
                        local go_to_instruction = instruction[psu_struct.register_b]

                        self:patch_instruction(to_patch_instruction, go_to_instruction)
                        current_instruction = table_find(self.instructions, go_to_instruction)
                        break
                    end
                end

                current_instruction = current_instruction + 1
            end

            self.current_instruction = current_instruction
        elseif method == 6 then
            local current_instruction = self.current_instruction
            local to_patch_instruction

            while true do 
                local instruction = self.instructions[current_instruction]

                if type(instruction[psu_struct.register_b]) == "table" then 
                    if type(self.instructions[current_instruction + 4][psu_struct.register_b]) == "table" then 
                        local to_patch_instruction = instruction
                        local go_to_instruction = self.instructions[current_instruction + 4][psu_struct.register_b]

                        self:patch_instruction(to_patch_instruction, go_to_instruction)
                        current_instruction = table_find(self.instructions, go_to_instruction)
                        break
                    end
                end

                current_instruction = current_instruction + 1
            end

            self.current_instruction = current_instruction
        elseif method == 7 then
            local current_instruction = self.current_instruction
            local to_patch_instruction

            while true do 
                local instruction = self.instructions[current_instruction]

                if type(instruction[psu_struct.register_b]) == "table" then 
                    local success = true
                    for index = 1, 5 do 
                        if type(self.instructions[current_instruction + index][psu_struct.register_b]) ~= "table" then 
                            success = false
                        end
                    end

                    if success then
                        local to_patch_instruction = instruction
                        local go_to_instruction = instruction[psu_struct.register_b]

                        self:patch_instruction(to_patch_instruction, go_to_instruction)
                        current_instruction = table_find(self.instructions, go_to_instruction)
                        break
                    end
                end

                current_instruction = current_instruction + 1
            end

            self.current_instruction = current_instruction
        end
    end

    function patcher:patch_instructions(patch_type)
        if patch_type == 1 then -- module type
            self.instructions[0] = self.instructions[#self.instructions - 5]
        elseif patch_type == 2 then -- getkey type
            for index = 1, 7 do 
                if index == 5 then 
                    self:patch_method(5, 9)
                    self:patch_method(5, 6)
                    self:patch_method(5, 6)
                else 
                    self:patch_method(index)
                end
            end
        end
    end

    function patcher:patch(patch_type)
        self:grab_dependencies()

        self:patch_instructions(patch_type)
    end

    --// assert(getscripthash(key_handler) == "28607f8aeb5399560e87712f42c5a6700c96c6c4d9f3209004c89bfa7766916410af5b0e6492eafb55c57b261693b192", "KeyHandler Script Updated!")

    local character = player.Character or player.CharacterAdded:Wait()
    local input_script = character:WaitForChild("CharacterHandler"):WaitForChild("Input")

    --// assert(getscripthash(input_script) == "29e1a68e700408e58d97ab1b19afb63a8b50a0c868635d7e8abc4a81002639a3b63f4061a726c7dfc1eecf989da70931", "Input Script Updated!")

    local input_protos = getprotos(getscriptclosure(input_script))

    for index = 1, #input_protos do 
        local proto = input_protos[index]
        local constants = getconstants(proto)
            
        if table_find(constants, "SpeedBoost") and table_find(constants, "HasHammer") then 
            local dodge_function = getproto(proto, 1)
                
            setupvalue(dodge_function, 1, function() end)
            setupvalue(dodge_function, 2,  function(key)
                dodge_fpe_key = tonumber(("%0.50f"):format(key)) -- terrible method
            end)
            setupvalue(dodge_function, 3, tonumber)
            setupvalue(dodge_function, 4, tostring)
            setupvalue(dodge_function, 5, function() end)

            dodge_function()

            break
        end
    end

    local keyhandler_module = require(key_handler)

    local module_patcher = patcher.new(keyhandler_module)
    module_patcher:patch(1)

    local get_key = keyhandler_module()[1]

    local get_key_patcher = patcher.new(get_key)
    get_key_patcher:patch(2)

    local remote_cache = {}
    local character_cache
    local live_folder = workspace:WaitForChild("Live")

    global_variables.remotes = setmetatable({}, {
        __index = function(self, index)
            local cached_remote = remote_cache[index]
            local remote_result

            if player.Character ~= character_cache then
                remote_result = get_key(index == "Dodge" and dodge_fpe_key or index, "plum")

                if remote_result and typeof(remote_result) == "Instance" and remote_result:IsDescendantOf(live_folder) then 
                    character_cache = player.Character

                    remote_cache[index] = remote_result
                    return remote_result
                end
            end
            
            if not cached_remote then 
                remote_result = remote_result or get_key(index == "Dodge" and dodge_fpe_key or index, "plum")

                if remote_result and typeof(remote_result) == "Instance" then
                    remote_cache[index] = remote_result
                end 

                return remote_result
            end 
            
            return cached_remote
        end
    })
end

--// global hooks 

do
    local old_fire_server
    old_fire_server = replaceclosure(instance_new("RemoteEvent").FireServer, newcclosure(function(self, data, ...)
        if global_variables.block_all_remotes then 
            return 
        end 

        if self == global_variables.remotes.Tango then
            local number_value = rawget(data, 2) -- rawget to prevent any metatable detection on data

            if type(number_value) == "number" and (number_value > 3.95 or number_value < 2.05) then 
                return coroutine_yield()
            end
        elseif (library.flags["No Fall Damage"] or library.flags.Flight) and self == global_variables.remotes.ApplyFallDamage then 
            return
        elseif library.flags["Temperature Lock"] and self == global_variables.remotes.SetCurrentArea then 
            return
        elseif library.flags["Anti Backfire"] and typeof(self) == "Instance" then
            local remote_name = self.Name
            local is_snap = remote_name == "RightClick"

            if remote_name == "LeftClick" or is_snap then
                local character = player.Character

                if character then
                    local artifacts_folder = character:FindFirstChild("Artifacts")

                    if artifacts_folder and artifacts_folder:FindFirstChild("PhilosophersStone") then
                        return old_fire_server(self, data, ...)
                    end

                    local spell_tool, mana_object = character:FindFirstChildOfClass("Tool"), character:FindFirstChild("Mana")

                    if mana_object and spell_tool then
                        local spell_cost_data = global_variables.spell_cost[spell_tool.Name]
                        local mana_value = mana_object.Value

                        if spell_cost_data then 
                            local spell_info = spell_cost_data[is_snap and 2 or 1]
                        
                            if (mana_value > spell_info[1] and mana_value < spell_info[2]) or (spell_tool.Name == "Gate" and not character:FindFirstChild("Combat") and character:FindFirstChild("AzaelHorn")) then
                                return old_fire_server(self, data, ...)
                            end

                            return
                        end
                    end
                end
            end
        end

        return old_fire_server(self, data, ...)
    end))

    local old_newindex
    old_newindex = hookmetamethod(game, "__newindex", function(self, index, value)
        if index == "Parent" and value == nil and typeof(self) == "Instance" then 
            local character = player.Character

            if character then
                local character_handler = player.Character:FindFirstChild("CharacterHandler")

                if character_handler then
                    local input = character_handler:FindFirstChild("Input")

                    if input then
                        if self == character_handler or self == input then 
                            return
                        end
                    end
                end
            end
        elseif not checkcaller() and index == "JumpPower" and library.flags["Jump Height"] and player.Character then 
            if (value == 45 or value == 0) then
                if global_variables.character_connection_function and validlevel(5) and getinfo(5, "f").func == global_variables.character_connection_function then 
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

                    if humanoid and self == humanoid then 
                        return old_newindex(self, index, library.flags["Jump Height Value"])
                    end
                end
            end
        end

        return old_newindex(self, index, value)
    end)

    local old_index
    old_index = hookmetamethod(game, "__index", function(self, index)
        if self == player and index == "CameraMaxZoomDistance" and getinfo(3, "s").source:find("Input") then 
            return 50
        end
        
        return old_index(self, index)
    end)
end

-- // local features

do
    local local_movement, local_misc = sections.movement_settings, sections.local_misc

    do -- walk speed / jump height
        local character_connection_upvalue

        local function get_character_connection(character)
            global_variables.character_connection_function = nil
            character:WaitForChild("CharacterHandler"):WaitForChild("Input")

            repeat
                local render_stepped_connections = getconnections(services.RunService.RenderStepped)

                for index = 1, #render_stepped_connections do 
                    local connection = render_stepped_connections[index]
                    local connection_function = connection.Function 
                    
                    if type(connection_function) == "function" and islclosure(connection_function) then 
                        local upvalues = getupvalues(connection_function)
                        
                        if type(upvalues[#upvalues]) == "number" then 
                            global_variables.character_connection_function = connection_function
                            character_connection_upvalue = #upvalues
                            break
                        end
                    end
                end

                if not global_variables.character_connection_function then
                    wait(0.1)
                end
            until global_variables.character_connection_function
        end

        get_character_connection(player.Character or player.CharacterAdded:Wait())
        player.CharacterAdded:Connect(get_character_connection)

        task_spawn(function()
            while task_wait() do
                if library.flags["Walk Speed"] and global_variables.character_connection_function then 
                    setupvalue(global_variables.character_connection_function, character_connection_upvalue, library.flags["Walk Speed Boost"])
                end
            end
        end)

        local_movement:Toggle({Name = "Walk Speed", Callback = function(state)
            if not state then
                if global_variables.character_connection_function then
                    setupvalue(global_variables.character_connection_function, character_connection_upvalue, 0)
                end
            end
        end})

        local_movement:Slider({Name = "Walk Speed Boost", Min = 0, Max = 200})

        local_movement:Toggle({Name = "Jump Height"})
        local_movement:Slider({Name = "Jump Height Value", Min = 1, Max = 300})
    end

    do -- infinite jump
        services.UserInputService.JumpRequest:Connect(function()
            if library.flags["Infinite Jump"] then
                local character = player.Character

                if character then 
                    local humanoid = player.Character:FindFirstChild("Humanoid")

                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end)

        local_movement:Toggle({Name = "Infinite Jump"})
    end


    do -- noclip
        local noclip_params = OverlapParams.new()
        noclip_params.MaxParts = 1
        noclip_params.FilterType = Enum.RaycastFilterType.Blacklist
        noclip_params.FilterDescendantsInstances = {workspace.Live}

        local last_noclip_time = tick()

        services.RunService.Stepped:Connect(function()
            if library.flags.NoClip then
                local character = player.Character

                if character and not global_functions.is_knocked() then
                    local humanoid, humanoid_root_part = character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
                    local head, torso = character:FindFirstChild("Head"), character:FindFirstChild("Torso")

                    if humanoid and humanoid_root_part and head and torso then
                        local fake_humanoid = character:FindFirstChild("FakeHumanoid", true)

                        if fake_humanoid then
                            if #workspace:GetPartsInPart(torso, noclip_params) == 1 then
                                last_noclip_time = tick()

                                local name_part = fake_humanoid.Parent

                                if name_part then
                                    local name_part_head = name_part:FindFirstChild("Head")

                                    if name_part_head then
                                        torso.CanCollide = false
                                        head.CanCollide = false
                                        name_part_head.CanCollide = false

                                        local original_velocity = humanoid_root_part.Velocity
                                        humanoid_root_part.Velocity = vector3_new(original_velocity.X, 2, original_velocity.Z)

                                        humanoid.JumpPower = 0
                                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                end
                            elseif tick() - last_noclip_time <= 0.1 then 
                                humanoid.JumpPower = 0
                            end
                        end
                    end
                end
            end
        end)

        local_misc:Toggle({Name = "NoClip"})
    end

    do -- climb speed
        local climb_speed_constant_index = 79
        local stop_climb_connection

        repeat 
            stop_climb_connection = getconnections(global_variables.remotes.StopClimb.OnClientEvent)[1]
            wait()
        until stop_climb_connection

        local climb_constants = getconstants(getupvalue(stop_climb_connection.Function, 1))

        for index = 1, #climb_constants do 
            if climb_constants[index] == 0.1 and climb_constants[index - 1] == 1.5 then 
                climb_speed_constant_index = index 
                break
            end 
        end

        local function apply_climb_speed(character)
            local climb_speed = library.flags["Climb Speed"] / 10 

            if climb_speed > 0.1 then
                local stop_climb_connection

                character:WaitForChild("CharacterHandler"):WaitForChild("Input")

                repeat 
                    stop_climb_connection = getconnections(global_variables.remotes.StopClimb.OnClientEvent)[1]
                    wait()
                until stop_climb_connection and stop_climb_connection.Function

                setconstant(getupvalue(stop_climb_connection.Function, 1), climb_speed_constant_index, climb_speed)
            end
        end

        player.CharacterAdded:Connect(apply_climb_speed)

        local_misc:Slider({Name = "Climb Speed", Min = 1, Max = 10, Callback = function(value)
            local stop_climb_connection = getconnections(global_variables.remotes.StopClimb.OnClientEvent)[1]

            if stop_climb_connection then
                setconstant(getupvalue(stop_climb_connection.Function, 1), climb_speed_constant_index, value / 10)
            end
        end})
    end

    do -- spider climb  
        local spider_params = raycast_params_new()
        spider_params.FilterType = Enum.RaycastFilterType.Blacklist
        spider_params.FilterDescendantsInstances = {workspace.Live}
        spider_params.IgnoreWater = true

        task_spawn(function()
            while task_wait() do
                if library.flags["Spider Climb"] then
                    local character = player.Character

                    if character then
                        local humanoid_root_part = player.Character:FindFirstChild("HumanoidRootPart")

                        if humanoid_root_part then
                            local raycast_result = workspace:Raycast(humanoid_root_part.Position, humanoid_root_part.CFrame.LookVector * 3, spider_params)
                                
                            if raycast_result then
                                humanoid_root_part.Velocity = vector3_new(humanoid_root_part.Velocity.X, (library.flags["Spider Climb Speed"] + math_random(1, 5)) * 0.9, humanoid_root_part.Velocity.Z)
                            end
                        end
                    end
                end
            end
        end)

        local_movement:Toggle({Name = "Spider Climb"})
        local_movement:Slider({Name = "Spider Climb Speed", Min = 0, Max = 150})
    end

    do -- auto sprint
        local sprint_function
        local stop_sprint = services.ReplicatedStorage:WaitForChild("Requests"):WaitForChild("StopSprint")

        local function apply_auto_sprint(character)
            character:WaitForChild("CharacterHandler"):WaitForChild("Input")
            local humanoid = character:WaitForChild("Humanoid")

            repeat 
                stop_sprint_connection = getconnections(stop_sprint.OnClientEvent)[1].Function
                wait()
            until stop_sprint_connection

            local old_sprint_environment = getfenv(stop_sprint_connection)

            getfenv(stop_sprint_connection).pcall = function(func)
                sprint_function = getupvalue(func, 1)
            end

            stop_sprint_connection()

            setfenv(stop_sprint_connection, old_sprint_environment)

            task_spawn(function()
                while wait(0.1) do
                    if character ~= player.Character then
                        break
                    end 

                    if library.flags["Auto Sprint"] then
                        if not getupvalue(sprint_function, 1) then
                            if humanoid.MoveDirection.Magnitude > 0 then
                                sprint_function(true)
                            end
                        elseif humanoid and humanoid.MoveDirection.Magnitude == 0 then
                            sprint_function(false)
                        end
                    end
                end
            end)
        end

        local character = player.Character or player.CharacterAdded:Wait()

        apply_auto_sprint(character)
        player.CharacterAdded:Connect(apply_auto_sprint)

        local_movement:Toggle({Name = "Auto Sprint"})
    end

    do -- freecam
        local mouse = player:GetMouse()

        local empty_vector = vector3_new(0, 0, 0)

        local move_position = vector2_new(0, 0)
        local move_direction = empty_vector

        local last_right_button_down = Vector2.new(0, 0)
        local right_mouse_button_down = false

        local keys_down = {}
        
        local enum_keycode = Enum.KeyCode
        local zoom_keycode = enum_keycode.Z

        local mouse_movement = Enum.UserInputType.MouseMovement
        local mouse_button_2 = Enum.UserInputType.MouseButton2
        
        local begin_state = Enum.UserInputState.Begin
        local end_state = Enum.UserInputState.End

        local lock_current_position = Enum.MouseBehavior.LockCurrentPosition
        local default_mouse = Enum.MouseBehavior.Default

        local camera_scriptable = Enum.CameraType.Scriptable
        local camera_custom = Enum.CameraType.Custom

        local move_keys = {
            [enum_keycode.D] = vector3_new(1, 0, 0),
            [enum_keycode.A] = vector3_new(-1, 0, 0),
            [enum_keycode.S] = vector3_new(0, 0, 1),
            [enum_keycode.W] = vector3_new(0, 0, -1),
            [enum_keycode.E] = vector3_new(0, 1, 0),
            [enum_keycode.Q] = vector3_new(0, -1, 0)
        }

        services.UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == mouse_movement then
                move_position = move_position + vector2_new(input.Delta.X, input.Delta.Y)
            end
        end)

        local function calculate_movement()
            local new_movement = empty_vector
            
            for index, value in next, keys_down do
                new_movement = new_movement + (move_keys[index] or empty_vector)
            end
            
            return new_movement
        end

        local function input_register(input)
            local key_code = input.KeyCode

            if move_keys[key_code] then
                if input.UserInputState == begin_state then
                    keys_down[key_code] = true
                elseif input.UserInputState == end_state then
                    keys_down[key_code] = nil
                end
            else
                if input.UserInputState == begin_state then
                    if input.UserInputType == mouse_button_2 then
                        right_mouse_button_down = true
                        last_right_button_down = vector2_new(mouse.X, mouse.Y)
                        services.UserInputService.MouseBehavior = lock_current_position
                    end
                else
                    if input.UserInputType == mouse_button_2 then
                        right_mouse_button_down = false
                        services.UserInputService.MouseBehavior = default_mouse
                    end
                end
            end
        end

        mouse.WheelForward:Connect(function()
            camera.CoordinateFrame = camera.CoordinateFrame * cframe_new(0, 0, -5)
        end)

        mouse.WheelBackward:Connect(function()
            camera.CoordinateFrame = camera.CoordinateFrame * cframe_new(0, 0, 5)
        end)

        services.UserInputService.InputBegan:Connect(input_register)
        services.UserInputService.InputEnded:Connect(input_register)

        services.RunService.RenderStepped:Connect(function()
            if library.flags.Freecam then
                camera.CoordinateFrame = cframe_new(camera.CoordinateFrame.Position) * cframe_fromeulerangles(-move_position.Y / 300, -move_position.X / 300, 0) * cframe_new(calculate_movement() * library.flags["Freecam Speed"])
                
                if right_mouse_button_down then
                    local mouse_position = vector2_new(mouse.X, mouse.Y)

                    services.UserInputService.MouseBehavior = lock_current_position
                    move_position = move_position - (last_right_button_down - mouse_position)
                    last_right_button_down = mouse_position
                end
            end
        end)

        local_misc:Toggle({Name = "Freecam", Callback = function(state)
            local character = player.Character
            
            if character then
                local humanoid, torso = character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("Torso")
            
                if humanoid and torso then
                    if state then
                        camera.CameraType = camera_scriptable
                        torso.Anchored = true
                    else
                        camera.CameraType = camera_custom
                        torso.Anchored = false
                        camera.CameraSubject = humanoid
                    end
                end
            end
        end})

        local_misc:Slider({Name = "Freecam Speed", Min = 1, Max = 10})
    end


    do -- flight
        local player_mouse = player:GetMouse()

        local empty_vector = vector3_new(0, 0, 0)
        local move_vectors = {
            w = vector3_new(0, 0, -1),
            s = vector3_new(0, 0, 1),
            d = vector3_new(1, 0, 0),
            a = vector3_new(-1, 0, 0),
            space = vector3_new(0, 1, 0),
            left_control = vector3_new(0, -1, 0)
        }

        task_spawn(function()
            while task_wait() do
                if library.flags.Flight then
                    local character = player.Character

                    if character then
                        local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")

                        if humanoid_root_part then
                            local direction = empty_vector
                            local ping = ping_stat:GetValue()
                            local current_cframe = humanoid_root_part.CFrame
                            
                            if library.flags["Flight While Knocked"] or library.flags["AA Bypass"] then
                                local bone = humanoid_root_part:FindFirstChild("Bone")

                                if bone then
                                    bone:Destroy()
                                end
                            end

                            direction = empty_vector +
                                (services.UserInputService:IsKeyDown("W") and move_vectors.w or empty_vector) +
                                (services.UserInputService:IsKeyDown("S") and move_vectors.s or empty_vector) +
                                (services.UserInputService:IsKeyDown("D") and move_vectors.d or empty_vector) +
                                (services.UserInputService:IsKeyDown("A") and move_vectors.a or empty_vector) +
                                (services.UserInputService:IsKeyDown("Space") and move_vectors.space or empty_vector) +
                                (services.UserInputService:IsKeyDown("LeftControl") and move_vectors.left_control or empty_vector)
                            
                            if ping > 200 then
                                direction = direction * 0.75

                                if ping > 300 then
                                    direction = direction * 0.75

                                    if ping > 500 then
                                        direction = direction * 0.5
                                    end
                                end
                            end

                            direction = direction * (library.flags["Flight Speed"] / 2.5)
                            humanoid_root_part.Velocity = empty_vector
                            humanoid_root_part.RotVelocity = empty_vector
                
                            if not global_functions.is_knocked() then
                                if not library.flags["Disable Flight Fall"] and direction.Y < 0.1 then
                                    humanoid_root_part.Velocity = vector3_new(0, -70 + math_random(1, 7), 0)
                                end
                            end
                
                            current_cframe = current_cframe * cframe_new(direction)
                
                            direction = library.flags["Flight Follow Mouse"] and (player_mouse.Hit.Position - camera.CFrame.Position) or camera.CFrame.lookVector
                            direction = camera.CFrame.Position + (direction.Unit * 10000)
                
                            if current_cframe.Y > 1e9 then -- do not remove pls
                                current_cframe = cframe_new(current_cframe.X, math_clamp(current_cframe.Y, -1000, 1e9), current_cframe.Z)
                            end
                
                            current_cframe = cframe_new(current_cframe.Position, direction)
                            humanoid_root_part.CFrame = current_cframe
                        end
                    end
                end
            end
        end)

        local order_field_cframe = workspace:WaitForChild("Map"):WaitForChild("OrderField").CFrame
        local platform_standing = Enum.HumanoidStateType.PlatformStanding

        task_spawn(function()
            while wait(0.4) do
                if library.flags["AA Bypass"] and library.flags.Flight then
                    local character = player.Character

                    if character and not global_functions.is_knocked() then
                        local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        local bypass_mode = library.flags["AA Bypass Mode"]

                        if humanoid_root_part and humanoid then
                            if bypass_mode == "Default" then
                                local old_cframe = humanoid_root_part.CFrame
                                
                                humanoid_root_part.CFrame = order_field_cframe
                                task_wait()
                                humanoid_root_part.CFrame = old_cframe
                            elseif bypass_mode == "Secondary" then
                                global_variables.remotes.ApplyFallDamage:FireServer({math_random(), math_random(15, 25) / 100}, {})
                            end
                        end
                    end
                end
            end
        end)

        local hit_animation_ids = {
            ["rbxassetid://2604557462"] = true, 
            ["rbxassetid://2604558857"] = true, 
            ["rbxassetid://2604558140"] = true, 
            ["rbxassetid://2604559455"] = true
        }

        local full_health_size = udim2_new(1, 0, 1, 0)

        local function apply_torso_motor_hook(torso, object)
            object:GetPropertyChangedSignal("Part0"):Connect(function()
                if library.flags.Flight and library.flags["AA Bypass"] and object.Part0 ~= torso then
                    object.Part0 = torso
                end
            end)
        end

        local function apply_aa_bypass_hide(character)
            --// anti knock & sound

            local humanoid_root_part = character:WaitForChild("HumanoidRootPart")
            local torso = character:WaitForChild("Torso")
            local humanoid = character:WaitForChild("Humanoid")

            humanoid_root_part:WaitForChild("SLAMJAM").Volume = 0
            humanoid_root_part:WaitForChild("SilverEmit").Parent = services.CoreGui

            local torso_children = torso:GetChildren()

            for index = 1, #torso_children do
                local value = torso_children[index]

                if value.ClassName == "Motor6D" then
                    apply_torso_motor_hook(torso, value)
                end
            end

            
            torso.ChildAdded:Connect(function(object)
                if object.ClassName == "Motor6D" then
                    apply_torso_motor_hook(torso, object)
                end
            end)

            --// anti health

            local gui_slider = player.PlayerGui:WaitForChild("StatGui"):WaitForChild("Container"):WaitForChild("Health"):WaitForChild("Slider")
            
            gui_slider:GetPropertyChangedSignal("Size"):Connect(function()
                if library.flags.Flight and library.flags["AA Bypass"] and gui_slider.Size ~= full_health_size then
                    gui_slider.Size = full_health_size
                end
            end)

            --// anti danger

            local danger_label = player.PlayerGui:WaitForChild("DangerGui"):WaitForChild("TextLabel")

            danger_label:GetPropertyChangedSignal("Visible"):Connect(function()
                if library.flags.Flight and library.flags["AA Bypass"] and danger_label.Visible then
                    danger_label.Visible = false
                end
            end)

            --// anti animation

            humanoid.AnimationPlayed:Connect(function(animation_track)
                if library.flags.Flight and library.flags["AA Bypass"] and hit_animation_ids[animation_track.Animation.AnimationId] then 
                    animation_track:Stop()
                end
            end)
        end
        
        local load_animation = instance_new("Humanoid").LoadAnimation
        
        local combat_anims = services.ReplicatedStorage:WaitForChild("CombatAnims")
        local acro_flip = combat_anims:WaitForChild("AcroFlip")
        local climb_up = combat_anims:WaitForChild("ClimbUp")

        local loaded_flip
        local loaded_climb

        local function apply_flight_animations(character)
            local humanoid = character:WaitForChild("Humanoid")
            
            loaded_flip = load_animation(humanoid, acro_flip)
            loaded_climb = load_animation(humanoid, climb_up)

            local old_selected = nil

            task_spawn(function()
                while wait(0.5) do
                    local selected_animation = (library.flags.Animation == "Rolling" and loaded_flip) or (library.flags.Animation == "Climbing" and loaded_climb)

                    if library.flags["Flight Animations"] and library.flags.Flight and selected_animation then
                        if not selected_animation.IsPlaying then
                            selected_animation:Play()
                        end
                    elseif selected_animation ~= old_selected or not library.flags.Flight then
                        loaded_climb:Stop()
                        loaded_flip:Stop()
                    end

                    old_selected = selected_animation
                end
            end)
        end

        local character = player.Character or player.CharacterAdded:Wait()

        apply_aa_bypass_hide(character)
        apply_flight_animations(character)
        
        player.CharacterAdded:Connect(apply_aa_bypass_hide)
        player.CharacterAdded:Connect(apply_flight_animations)

        local_movement:Toggle({Name = "Flight"})
        local_movement:Slider({Name = "Flight Speed", Min = 1, Max = 5})
        local_movement:Toggle({Name = "Disable Flight Fall"})
        local_movement:Toggle({Name = "AA Bypass", Callback = function(state)
            services.StarterGui:SetCoreGuiEnabled("Health", not state)
        end})
        local_movement:Picker({Name = "AA Bypass Mode", List = {"Default", "Secondary"}, Default = "Default"})
        local_movement:Toggle({Name = "Flight While Knocked"})
        local_movement:Toggle({Name = "Flight Follow Mouse"})
        local_movement:Toggle({Name = "Flight Animations"})
        local_movement:Picker({Name = "Animation", List = {"Rolling", "Climbing"}, Default = "AcroFlip", Callback = function(state)
            if not state then 
                loaded_climb:Stop()
                loaded_flip:Stop()
            end
        end})
    end

    do -- moses
        local terrain_region
        local moses_height_extension =  vector3_new(0, 50, 0)
        local terrain = workspace.Terrain

        local water_material = Enum.Material.Water
        local air_material = Enum.Material.Air

        task_spawn(function()
            while wait() do
                if library.flags.Moses then
                    local character = player.Character

                    if character then 
                        local character_primary_part = player.Character:FindFirstChild("Torso")

                        if character_primary_part then
                            local position = character_primary_part.Position
                            local size = character_primary_part.Size * 5 + moses_height_extension
                            local region = region3_new(position - size, position + size):ExpandToGrid(4)
                            
                            local materials, occupancies = terrain:ReadVoxels(region, 4)
                            local material_size = materials.Size
                            
                            for x_position = 1, material_size.X do
                                for y_position = 1, material_size.Y do
                                    for z_position = 1, material_size.Z do
                                        if materials[x_position][y_position][z_position] == water_material then
                                            materials[x_position][y_position][z_position] = air_material
                                        end
                                    end
                                end
                            end
                            
                            if library.flags.Moses then
                                terrain:WriteVoxels(region, 4, materials, occupancies)
                            end
                        end
                    end
                end
            end
        end)

        local_misc:Toggle({Name = "Moses", Callback = function(state)
            if state then 
                terrain_region = terrain:CopyRegion(terrain.MaxExtents)
            else 
                terrain:PasteRegion(terrain_region, terrain.MaxExtents.Min, true)
            end
        end})
    end

    do -- satan
        local swimming_state = Enum.HumanoidStateType.Swimming

        local function apply_satan(character)
            local humanoid = character:WaitForChild("Humanoid")

            if library.flags["Satan"] then
                humanoid:SetStateEnabled(swimming_state, false)
            end
        end

        local character = player.Character or player.CharacterAdded:Wait()

        apply_satan(character)
        player.CharacterAdded:Connect(apply_satan)

        local_misc:Toggle({Name = "Satan", Callback = function(state)
            local character = player.Character

            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if humanoid then
                    humanoid:SetStateEnabled(swimming_state, not state)
                end
            end
        end})
    end

    do -- jesus
        local terrain = workspace.Terrain

        local jesus_part = instance_new("Part")
        jesus_part.Size = vector3_new(5, 0.1, 5)
        jesus_part.Anchored = true
        jesus_part.CanCollide = false
        jesus_part.Transparency = 1
        jesus_part.Parent = workspace

        local region_size = vector3_new(1, 1, 1)
        local player_down_vector = vector3_new(0, 2, 0)
        local part_down_vector = vector3_new(0, 1, 0)

        local water_material = Enum.Material.Water

        task_spawn(function()
            while wait() do
                if library.flags.Jesus then
                    local character = player.Character

                    if character then 
                        local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")

                        if humanoid_root_part then
                            local position = humanoid_root_part.Position - player_down_vector
                            jesus_part.Position = position - part_down_vector
                            
                            local region = region3_new(position - region_size, position + region_size):ExpandToGrid(4)
                            local current_material = terrain:ReadVoxels(region, 4)[1][1][1]
                            
                            jesus_part.CanCollide = current_material == water_material
                        end
                    end
                end
            end
        end)

        local_misc:Toggle({Name = "Jesus", Callback = function(state)
            if not state and jesus_part.CanCollide then 
                jesus_part.CanCollide = false 
            end
        end})
    end

    do -- anchor
        local function apply_anchor(character)
            local torso = character:WaitForChild("Torso")

            torso.Anchored = library.flags.Anchor
        end 

        player.CharacterAdded:Connect(apply_anchor)

        local_misc:Toggle({Name = "Anchor", Callback = function(state)
            local character = player.Character or player.CharacterAdded:Wait()
            local torso = character:WaitForChild("Torso")

            torso.Anchored = state
        end})
    end

    do -- go to ground lol
        local ground_params = raycast_params_new()
        ground_params.FilterType = Enum.RaycastFilterType.Blacklist
        ground_params.FilterDescendantsInstances = {workspace.Live}
        ground_params.IgnoreWater = false

        local down_vector = vector3_new(0, -1000, 0)

        local_misc:Button({Name = "Ground TP", Callback = function()
            local character = player.Character

            if character then
                local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")
                if humanoid_root_part then
                    local raycast_result = workspace:Raycast(humanoid_root_part.Position, down_vector, ground_params)
                                
                    if raycast_result then
                        humanoid_root_part.CFrame = CFrame.new(raycast_result.Position)
                    end
                end
            end
        end})
    end

    do -- respawn
        local_misc:Button({Name = "Respawn", Callback = function()
            local character = player.Character

            if character then 
                character:BreakJoints()
            end
        end})
    end

    do -- knock
        local_misc:Button({Name = "Knock Player", Callback = function()
            global_variables.remotes.ApplyFallDamage:FireServer({math_random(), 1}, {})
        end})
    end

    do -- straight up suicide
        local_misc:Button({Name = "Suicide", Callback = function()
            local character = player.Character

            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")

                if humanoid then
                    global_variables.remotes.ApplyFallDamage:FireServer({math_random(), 2.69}, {})
                end
            end
        end})
    end

    do 
        local_misc:Button({Name = "Naked", Callback = function()
            local character = player.Character

            if character then
                local character_shirt = character:FindFirstChildOfClass("Shirt")
                local character_pants = character:FindFirstChildOfClass("Pants")

                if character_shirt then
                    character_shirt:Destroy()
                end

                if character_pants then
                    character_pants:Destroy()
                end
            end
        end})
    end
end

--// general features 

do 
    local general_prevention, general_misc, general_legit, general_status = sections.prevention_settings, sections.misc_random, sections.misc_legit, sections.misc_status

    do -- no fall damage
        general_prevention:Toggle({Name = "No Fall Damage"})
    end

    do -- anti stun
        local stuns_list = {
            ["Action"] = true,
            ["NoJump"] = true ,
            ["ClimbCoolDown"] = true,
            ["Sprinting"] = true,
            ["Stun"] = true,
            ["LightAttack"] = true,
        }

        local function apply_anti_stun(character)
            character.ChildAdded:Connect(function(child)
                if library.flags["Anti Stun"] and stuns_list[child.Name] then
                    task_wait()
                    child:Destroy()
                end
            end)
        end
        
        local character = player.Character or player.CharacterAdded:Wait()

        apply_anti_stun(character)
        player.CharacterAdded:Connect(apply_anti_stun)

        general_prevention:Toggle({Name = "Anti Stun", Callback = function(state)
            if state then 
                local character = player.Character

                if character then 
                    local character_children = character:GetChildren()

                    for index = 1, #character_children do 
                        local child = character_children[index]

                        if stuns_list[child.Name] then 
                            child:Destroy()
                        end
                    end
                end
            end
        end})
    end

    do -- anti backfire
        general_prevention:Toggle({Name = "Anti Backfire"})
    end

    do -- anti injuries
        local has_tag_hook
        has_tag_hook = replaceclosure(services.CollectionService.HasTag, function(self, instance, tag)
            if library.flags["Anti Injuries"] and (tag == "BrokenArm" or tag == "BrokenLeg" or tag == "Burned") then 
                return false 
            end

            return has_tag_hook(self, instance, tag)
        end)

        local injury_values = {}
        
        local function apply_anti_injuries(character)
            local boosts = character:WaitForChild("Boosts")

            boosts.ChildAdded:Connect(function(child)
                if library.flags["Anti Injuries"] then
                    if ((child.Name == "SpeedBoost" or child.Name == "DamageMPStack") and child.Value < 0) or ((child.Name == "Blindness" or child.Name == "VisionBlur") and child.Value > 0) then
                        injury_values[child] = child.Value
                        child.Value = 0
                    end
                end
            end)
        end
        
        local character = player.Character or player.CharacterAdded:Wait()

        apply_anti_injuries(character)
        player.CharacterAdded:Connect(apply_anti_injuries)

        general_prevention:Toggle({Name = "Anti Injuries", Callback = function(state)
            local character = player.Character

            if character then
                local boosts_folder = character:WaitForChild("Boosts")
                local boosts_children = boosts_folder:GetChildren()
            
                for index = 1, #boosts_children do
                    local boost = boosts_children[index]

                    if (boost.Name == "DamageMPStack" or boost.Name == "SpeedBoost" or boost.Name == "Blindness" or boost.Name == "VisionBlur") then
                        if state then
                            injury_values[boost] = boost.Value

                            if ((boost.Name == "SpeedBoost" or boost.Name == "DamageMPStack") and boost.Value < 0) or ((boost.Name == "Blindness" or boost.Name == "VisionBlur") and boost.Value > 0) then
                                boost.Value = 0
                            end
                        else
                            boost.Value = injury_values[boost]
                        end 
                    end
                end
            end
        end})
    end
    
    do -- anti mental injuries
        local mental_injuries = {
            Hallucinations = true,
            PsychoInjury = true,
            AttackExcept = true,
            Whispering = true,
            Quivering = true,
            NoControl = true,
            Careless = true,
            Maniacal = true,
            Fearful = true
        }

        local function apply_anti_mental(character)            
            character.ChildAdded:Connect(function(child)
                if library.flags["Anti Mental Injuries"] and child and mental_injuries[child.Name] then
                    child:Destroy()
                end
            end)
        end
        
        local character = player.Character or player.CharacterAdded:Wait()

        apply_anti_mental(character)
        player.CharacterAdded:Connect(apply_anti_mental)

        general_prevention:Toggle({Name = "Anti Mental Injuries", Callback = function(state)
            local character = player.Character

            if character and state then
                local character_children = character:GetChildren()
            
                for index = 1, #character_children do
                    local child = character_children[index]

                    if child and mental_injuries[child.Name] then
                        child:Destroy()
                    end
                end
            end
        end})
    end

    do -- anti eat
        local function apply_anti_eat(character)
            character.ChildAdded:Connect(function(child)
                if library.flags["Anti Shrieker Eat"] and child.Name == "BeingEaten" then 
                    task_wait()
                    child:Destroy()
                end
            end)
        end
        
        local character = player.Character or player.CharacterAdded:Wait()

        apply_anti_eat(character)
        player.CharacterAdded:Connect(apply_anti_eat)

        general_prevention:Toggle({Name = "Anti Shrieker Eat", Callback = function(state)
            if state then 
                local character = player.Character

                if character then
                    local eaten_folder = character:FindFirstChild("BeingEaten")

                    if eaten_folder then
                        eaten_folder:Destroy()
                    end
                end
            end
        end})
    end

    do -- anti curse
        local function apply_anti_curse(character)
            character.ChildAdded:Connect(function(child)
                if library.flags["Anti Curse"] and child.Name == "CurseMP" then 
                    task_wait()
                    child:Destroy()
                end
            end)
        end
        
        local character = player.Character or player.CharacterAdded:Wait()

        apply_anti_curse(character)
        player.CharacterAdded:Connect(apply_anti_curse)

        general_prevention:Toggle({Name = "Anti Curse", Callback = function(state)
            if state then 
                local character = player.Character

                if character then
                    local curse_value = character:FindFirstChild("CurseMP")

                    if curse_value then
                        curse_value:Destroy()
                    end
                end
            end
        end})
    end

    do -- anti fire
        local function apply_anti_fire(character)
            character.ChildAdded:Connect(function(child)
                if library.flags["Anti Fire"] and child.Name == "Burning" then 
                    task_wait()
                    global_variables.remotes.Dodge:FireServer({4, math_random()})
                end
            end)
        end
        
        local character = player.Character or player.CharacterAdded:Wait()

        apply_anti_fire(character)
        player.CharacterAdded:Connect(apply_anti_fire)

        general_prevention:Toggle({Name = "Anti Fire", Callback = function(state)
            if state then 
                local character = player.Character

                if character and character:FindFirstChild("Burning") then 
                    global_variables.remotes.Dodge:FireServer({4, math_random()})
                end
            end
        end})
    end

    do -- bypass orderly barriers
        local order_filter_table = {}

        for index, orderly_barrier in next, workspace:WaitForChild("Map"):GetChildren() do
            if orderly_barrier.Name == "OrderField" then
                table_insert(order_filter_table, orderly_barrier)
            end
        end
        
        local order_params = raycast_params_new()
        order_params.FilterType = Enum.RaycastFilterType.Whitelist
        order_params.FilterDescendantsInstances = order_filter_table

        task_spawn(function()
            while wait() do
                if library.flags["Order Barrier Bypass"] then
                    local character = player.Character

                    if character then
                        local humanoid_root_part = player.Character:FindFirstChild("HumanoidRootPart")
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

                        if humanoid_root_part and humanoid then
                            local raycast_result = workspace:Raycast(humanoid_root_part.Position, humanoid.MoveDirection * 9, order_params)
                                
                            if raycast_result then
                                humanoid_root_part.CFrame = humanoid_root_part.CFrame + humanoid.MoveDirection * 17
                            end
                        end
                    end
                end
            end
        end)

        general_prevention:Toggle({Name = "Order Barrier Bypass"})
    end
    
    do  -- no killbricks
        local world_map = workspace:WaitForChild("Map")
        
        local real_bricks = {}
        local fake_brick = {}

        local down_vector = vector3_new(0, -4500, 0)
        local up_vector = vector3_new(0, 4500, 0)
        
        local kill_brick_names = {
            ["ardoriankillbrick"] = true,
            ["pitkillbrick"] = true,
            ["spectralfire"] = true,
            ["poisonfield"] = true,
            ["cryptkiller"] = true,
            ["killbrick"] = true,
            ["killfire"] = true,
            ["lava"] = true
        }

        for index, part in next, world_map:GetChildren() do 
            if kill_brick_names[part.Name:lower()] then
                local cloned_part = part:Clone()
                local cloned_touch = cloned_part:FindFirstChildOfClass("TouchTransmitter")

                if cloned_touch then
                    cloned_touch:Destroy()
                end

                table_insert(fake_brick, cloned_part)
                table_insert(real_bricks, part)
            end
        end

        general_prevention:Toggle({Name = "Anti Kill Bricks", Callback = function(state)
            for index, brick in next, fake_brick do 
                brick.Parent = state and world_map or nil
            end
            
            for index, brick in next, real_bricks do    
                brick.Parent = state and nil or world_map
                brick.Transparency = state and 1 or 0
                brick.CFrame = brick.CFrame + (state and down_vector or up_vector)
            end
        end})
    end

    do -- anti frostbite
        local function apply_anti_frostbite(character)
            character.ChildAdded:Connect(function(child)
                if library.flags["Anti Frostbite"] and child.Name == "Frostbitten" then 
                    task_wait()
                    child:Destroy()
                end
            end)
        end
        
        local character = player.Character or player.CharacterAdded:Wait()

        apply_anti_frostbite(character)
        player.CharacterAdded:Connect(apply_anti_frostbite)

        general_prevention:Toggle({Name = "Anti Frostbite", Callback = function(state)
            if state then 
                local character = player.Character

                if character then
                    local frost_bite = character:FindFirstChild("Frostbitten")

                    if frost_bite then
                        frost_bite:Destroy()
                    end
                end
            end
        end})
    end

    do -- anti contrarium
        local function apply_anti_contrarium(character)
            character.ChildAdded:Connect(function(child)
                if library.flags["Anti Contrarium"] and child.Name == "ContrariumTag" then 
                    task_wait()
                    child:Destroy()
                end
            end)
        end
        
        local character = player.Character or player.CharacterAdded:Wait()

        apply_anti_contrarium(character)
        player.CharacterAdded:Connect(apply_anti_contrarium)

        general_prevention:Toggle({Name = "Anti Contrarium", Callback = function(state)
            if state then 
                local character = player.Character

                if character then
                    local contrarium_tag = character:FindFirstChild("ContrariumTag")

                    if contrarium_tag then
                        contrarium_tag:Destroy()
                    end
                end
            end
        end})
    end

    do -- anti hystericus
        local function apply_anti_hystericus(character)
            character.ChildAdded:Connect(function(child)
                if library.flags["Anti Hystericus"] and child.Name == "Confused" then 
                    task_wait()
                    child:Destroy()
                end
            end)
        end
        
        local character = player.Character or player.CharacterAdded:Wait()

        apply_anti_hystericus(character)
        player.CharacterAdded:Connect(apply_anti_hystericus)

        general_prevention:Toggle({Name = "Anti Hystericus", Callback = function(state)
            if state then 
                local character = player.Character

                if character then 
                    local confused = character:FindFirstChild("Confused")

                    if confused then 
                        confused:Destroy()
                    end
                end
            end
        end})
    end
    
    do -- prevent grip
        local jumping_state = Enum.HumanoidStateType.Jumping

        local function prevent_grip()
            local character = player.Character

            if not library.flags.Flight and library.flags["Prevent Grip"] then 
                local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local torso = character:FindFirstChild("Torso")

                if humanoid_root_part and humanoid and torso then
                    if humanoid.Health < 25 then
                        local bone = humanoid_root_part:WaitForChild("Bone")
                        bone:Destroy()

                        local original_cframe = humanoid_root_part.CFrame
                        local target_cframe =  cframe_new(original_cframe.X, -785, original_cframe.Z)

                        if not character:FindFirstChild("Danger") then 
                            wait(0.1 + (ping_stat:GetValue() / 900))
                        end

                        global_variables.remotes.Dodge:FireServer({4, math_random()}) -- if on fire

                        while character:FindFirstChild("Danger") do 
                            humanoid_root_part.CFrame = target_cframe
                            humanoid.JumpPower = 0
                            humanoid:ChangeState(jumping_state)
                            task_wait()
                        end
                        
                        character:Destroy()
                        task_wait()
                        player:Kick("prevent grip")
                    end
                end
            end
        end

        services.CollectionService:GetInstanceAddedSignal("Knocked"):Connect(function(object)
            if object == player.Character then 
                prevent_grip()
            end
        end)
            
        general_prevention:Toggle({Name = "Prevent Grip", Callback = function(state)
            if state and global_functions.is_knocked() then 
                prevent_grip()
            end
        end})
    end

    do -- temperature lock
        general_misc:Toggle({Name = "Temperature Lock"})
    end

    do -- spell stacking
        local function apply_spell_stacking(character)
            character.ChildAdded:Connect(function(child)
                if library.flags["Spell Stacking"] and child.Name == "ActiveCast" then 
                    task_wait()
                    child:Destroy()
                end
            end)
        end
        
        local character = player.Character or player.CharacterAdded:Wait()

        apply_spell_stacking(character)
        player.CharacterAdded:Connect(apply_spell_stacking)

        general_misc:Toggle({Name = "Spell Stacking", Callback = function(state)
            if state then 
                local character = player.Character

                if character then
                    local active_cast = character:FindFirstChild("ActiveCast")

                    if active_cast then
                        active_cast:Destroy()
                    end
                end
            end
        end})
    end

    do -- better charge
        local key_code_g = Enum.KeyCode.G
        
        services.UserInputService.InputBegan:Connect(function(input, in_chat)
            if not in_chat and library.flags["Better Charge"] then
                local character = player.Character

                if character and input.KeyCode == key_code_g then

                    global_variables.remotes.SetManaChargeState:FireServer({math_random(1, 10), math_random()})

                    wait(0.1 + (ping_stat:GetValue() / 900))

                    repeat 
                        task_wait()
                        if character and not character:FindFirstChild("Charge") then
                            global_variables.remotes.SetManaChargeState:FireServer({math_random(1, 10), math_random()})
                            wait(0.1 + (ping_stat:GetValue() / 900))
                        end
                    until not services.UserInputService:IsKeyDown("G")
                    
                    global_variables.remotes.SetManaChargeState:FireServer()
                end
            end
        end)

        general_misc:Toggle({Name = "Better Charge"})
    end

    do -- extended leaderboard
        local main_frame = player.PlayerGui:WaitForChild("LeaderboardGui"):WaitForChild("MainFrame")
        
        local extended_size = udim2_new(0.05, 150, 0, 500)
        local original_size = main_frame.Size

        main_frame:GetPropertyChangedSignal("Size"):Connect(function()
            if library.flags["Extended Leaderboard"] then
                main_frame.Size = extended_size
            end
        end)

        general_misc:Toggle({Name = "Extended Leaderboard", Callback = function(state)
            main_frame.Size = state and extended_size or original_size
        end})
    end

    do -- max zoom
        general_misc:Toggle({Name = "Max Camera Zoom", Callback = function(state)
            player.CameraMaxZoomDistance = state and math_huge or 50
        end})
    end

    do -- silent aim
        local function get_nearest_player()
            if not player.Character then 
                return 
            end 
            
            local players_list = services.Players:GetPlayers()
            
            local smallest_distance = math_huge 
            local nearest
            
            for index = 1, #players_list do 
                local target_player = players_list[index]
                
                if target_player ~= player then
                    local target_character = target_player.Character
                    
                    if target_character then 
                        local humanoid_root_part = target_character:FindFirstChild("HumanoidRootPart")
                        
                        if humanoid_root_part then 
                            local distance = player:DistanceFromCharacter(humanoid_root_part.Position)
                            
                            if distance < smallest_distance then 
                                smallest_distance = distance 
                                nearest = target_player
                            end
                        end
                    end
                end
            end
            
            return nearest
        end

        local get_mouse_remote = services.ReplicatedStorage:WaitForChild("Requests"):WaitForChild("GetMouse")

        local function mouse_spoof_callback()
            if library.flags["Silent Aim"] then
                local nearest_player = get_nearest_player()
                
                if nearest_player then 
                    local character = nearest_player.Character 
                
                    if character then 
                        local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")
                        
                        if humanoid_root_part then 
                            local target_screen_point = camera:WorldToScreenPoint(humanoid_root_part.Position)
                            local target_cframe = humanoid_root_part.CFrame + vector3_new(math_random(1, 10) / 10, math_random(1, 10) / 10, math_random(1, 10) / 10)
                            
                            return {
                                Hit = target_cframe, 
                                Target = humanoid_root_part,
                                X = target_screen_point.X,
                                Y = target_screen_point.Y,
                                UnitRay = ray_new(camera.CFrame.Position, target_cframe.LookVector)
                            }
                        end
                    end
                end
            end
            
            return {
                Hit = mouse.Hit, 
                Target = mouse.Target,
                UnitRay = mouse.UnitRay,
                X = mouse.X,
                Y = mouse.Y
            }
        end

        get_mouse_remote.OnClientInvoke = mouse_spoof_callback

        local old_newindex
        old_newindex = hookmetamethod(get_mouse_remote, "__newindex", function(self, index, value)
            if index == "OnClientInvoke" and not checkcaller() then 
                return old_newindex(self, index, mouse_spoof_callback)
            end 
            
            return old_newindex(self, index, value)
        end)

        general_misc:Toggle({Name = "Silent Aim"})
    end

    do -- mana sprint & dash day 0
        local mana_clones = {}

        local function apply_day_zero_mana(character)
            local mana_abilities = character:WaitForChild("ManaAbilities")
            if library.flags["Mana Sprint Day 0"] and not mana_abilities:FindFirstChild("ManaSprint") then
                local mana_sprint = instance_new("StringValue")
                mana_sprint.Name = "ManaSprint"
                mana_clones[mana_sprint] = true
                mana_sprint.Parent = mana_abilities
            end
        end
        
        local character = player.Character or player.CharacterAdded:Wait()

        apply_day_zero_mana(character)
        player.CharacterAdded:Connect(apply_day_zero_mana)

        general_misc:Toggle({Name = "Mana Sprint Day 0", Callback = function(state)
            local character = player.Character

            if character then 
                local mana_abilities = character:FindFirstChild("ManaAbilities")

                if mana_abilities then
                    if state and not mana_abilities:FindFirstChild("ManaSprint") then
                        local mana_sprint = instance_new("StringValue")
                        mana_sprint.Name = "ManaSprint"
                        mana_clones[mana_sprint] = true
                        mana_sprint.Parent = mana_abilities
                    elseif not state then
                        local mana_sprint_clone = mana_abilities:FindFirstChild("ManaSprint")
                        
                        if mana_sprint_clone and mana_clones[mana_sprint_clone] then
                            mana_sprint_clone:Destroy()
                        end
                    end
                end
            end
        end})
    end

    do -- instant log
        general_misc:Button({Name = "Instant Log", Callback = function()
            if player.Character then
                while player.Character:FindFirstChild("Danger") do 
                    task_wait()
                end 
                
                player.Character:Destroy()
                task_wait()
            end
    
            player:Kick("Instant Logged")
        end})
    end

    do -- server hop
        general_misc:Button({Name = "Server Hop", Callback = function()
            global_functions.block_random_player()
            services.TeleportService:Teleport(3016661674)
        end})
    end
    
    do -- inventory value
        local function get_inventory_value()
            local inventory_value = 0

            local backpack_children = player.Backpack:GetChildren()

            for index = 1, #backpack_children do
                local backpack_child = backpack_children[index]
                local silver_value = backpack_child:FindFirstChild("SilverValue")

                if silver_value then 
                    inventory_value = inventory_value + silver_value.Value
                end
            end
            
            return inventory_value
        end 

        local value_label = general_status:Label({Name = "Inventory Value: " .. get_inventory_value()})

        task_spawn(function()
            while wait(1) do
                value_label:Set("Inventory Value: " .. get_inventory_value())
            end
        end)
    end

    do -- last looted timers
        local monster_triggers = workspace:WaitForChild("MonsterSpawns"):WaitForChild("Triggers")
        local castle_rock_snake = monster_triggers:WaitForChild("CastleRockSnake"):WaitForChild("LastSpawned")
        local sunken_evil_eye = monster_triggers:WaitForChild("evileye1"):WaitForChild("LastSpawned")

        local function get_last_looted()
            local castle_delta = os_time() - castle_rock_snake.Value
            local sunken_delta = os_time() - sunken_evil_eye.Value
                
            return tostring(math_floor(castle_delta / 60)) .. "m", tostring(math_floor(sunken_delta / 60)) .. "m"
        end 

        local castle_delta, sunken_delta = get_last_looted()

        local castle_rock_label = general_status:Label({Name = "Castle Rock Last Looted: " .. castle_delta})
        local sunken_label = general_status:Label({Name = "Sunken Last Looted: " .. sunken_delta})

        task_spawn(function()
            while wait(10) do
                local castle_delta, sunken_delta = get_last_looted()

                castle_rock_label:Set("Castle Rock Last Looted: " .. castle_delta)
                sunken_label:Set("Sunken Last Looted: " .. sunken_delta)
            end
        end)
    end

    do -- auto click
        task_spawn(function()
            while wait(0.1) do 
                if library.flags["Auto Click"] then
                    local character = player.Character

                    if character then
                        local character_handler = character:FindFirstChild("CharacterHandler")

                        if character_handler then 
                            local remotes = character_handler:FindFirstChild("Remotes")

                            if remotes then
                                local left_click, left_click_release = remotes:FindFirstChild("LeftClick"), remotes:FindFirstChild("LeftClickRelease")

                                if left_click and left_click_release then
                                    left_click:FireServer({math_random(1, 10), math_random()})
                                    task_wait()
                                    left_click_release:FireServer({math_random(1, 10), math_random()})
                                end
                            end 
                        end
                    end
                end
            end
        end)

        general_legit:Toggle({Name = "Auto Click"})
    end
end

--// visuals features 

do
    local player_visuals_settings = sections.player_visuals_settings
    local visuals_trinket = sections.game_visuals_trinket
    local visuals_ingredient = sections.game_visuals_ingredient
    local visuals_misc = sections.game_visuals_misc
    local visuals_ores = sections.game_visuals_ores
    local visuals_environment = sections.world_settings
    local visuals_combat = sections.game_visuals_combat_visualizer

    do -- show client health & mana
        local stat_screen = instance_new("ScreenGui")
        protect_gui(stat_screen)

        local fake_left_container = instance_new("Frame")
        fake_left_container.AnchorPoint = Vector2.new(0, 1)
        fake_left_container.BackgroundTransparency = 1
        fake_left_container.Position = UDim2.new(0, 0, 0.9, -70)
        fake_left_container.Size = UDim2.new(0, 50, 0.3, 50)
        fake_left_container.SizeConstraint = Enum.SizeConstraint.RelativeYY
        fake_left_container.Parent = stat_screen

        local fake_mana_bar = instance_new("Frame")
        fake_mana_bar.AnchorPoint = Vector2.new(1, 1)
        fake_mana_bar.BackgroundTransparency = 1
        fake_mana_bar.Position = UDim2.new(1, 0, 1, 0)
        fake_mana_bar.Size = UDim2.new(0, 28, 1, 0)
        fake_mana_bar.Parent = fake_left_container

        local health_label = instance_new("TextLabel")
        health_label.Parent = stat_screen
        health_label.AnchorPoint = vector2_new(0.5, 1)
        health_label.BackgroundColor3 = color3_fromrgb(255, 255, 255)
        health_label.BackgroundTransparency = 1.000
        health_label.Position = udim2_new(0.5, 0, 1, -118)
        health_label.ZIndex = 10
        health_label.Font = Enum.Font.Fantasy
        health_label.Text = "100/100"
        health_label.TextColor3 = color3_fromrgb(255, 255, 255)
        health_label.TextSize = 18.000
        health_label.TextStrokeTransparency = 0.500
        health_label.Visible = false

        local mana_label = instance_new("TextLabel")
        mana_label.Size = udim2_new(1, 0, 0, 0)
        mana_label.BackgroundTransparency = 1
        mana_label.Font = Enum.Font.Fantasy
        mana_label.TextColor3 = color3_fromrgb(255, 255, 255)
        mana_label.TextSize = 16
        mana_label.TextStrokeTransparency = 0.5
        mana_label.ZIndex = 3
        mana_label.Parent = fake_mana_bar
        mana_label.Text = "50"

        local normal_overlay = instance_new("Frame")
        normal_overlay.BackgroundColor3 = color3_fromrgb(0, 0, 0)
        normal_overlay.BorderSizePixel = 0
        normal_overlay.BackgroundTransparency = 0.5
        normal_overlay.AnchorPoint = vector2_new(0, 1)
        normal_overlay.BackgroundColor3 = color3_fromrgb(0, 0, 255)
        normal_overlay.Parent = fake_mana_bar
        normal_overlay.Visible = false

        local snap_overlay = instance_new("Frame")
        snap_overlay.BackgroundColor3 = color3_fromrgb(0, 0, 0)
        snap_overlay.BorderSizePixel = 0
        snap_overlay.BackgroundTransparency = 0.5
        snap_overlay.AnchorPoint = vector2_new(0, 1)
        snap_overlay.BackgroundColor3 = color3_fromrgb(255, 0, 0)
        snap_overlay.Parent = fake_mana_bar
        snap_overlay.Visible = false


        local function init_mana_guis(character)
            local mana = character:WaitForChild("Mana")
            
            for index = 1, 9 do
                if index ~= 5 then
                    local mana_increment = instance_new("TextLabel")
                    mana_increment.Size = udim2_new(1, 0, 0, 0)
                    mana_increment.Position = udim2_new(0, 0, index / 10, 0)
                    mana_increment.BackgroundTransparency = 1
                    mana_increment.Font = Enum.Font.Fantasy
                    mana_increment.Text = 100 - index * 10
                    mana_increment.TextColor3 = color3_fromrgb(255, 255, 255)
                    mana_increment.TextSize = 16
                    mana_increment.TextStrokeTransparency = 0.5
                    mana_increment.Visible = false
                    mana_increment.ZIndex = 3
                    mana_increment.Parent = fake_mana_bar
                else
                    mana_label.Position = udim2_new(0, 0, index / 10, 0)
                end

                local mana_line = instance_new("Frame")
                mana_line.BackgroundColor3 = color3_fromrgb(112, 112, 112)
                mana_line.Position = udim2_new(0, 0, index / 10, 0)
                mana_line.Size = udim2_new(1, 0, 0, 1)
                mana_line.BorderSizePixel = 0
                mana_line.Visible = false
                mana_line.ZIndex = 2
                mana_line.Parent = fake_mana_bar
            end
        end

        local function show_stat_guis(character)
            local humanoid = character:WaitForChild("Humanoid")
            local mana = character:WaitForChild("Mana")
            local current_health, max_health = tostring(math_floor(humanoid.Health)), tostring(math_floor(humanoid.MaxHealth))
            local char_shadow = player.PlayerGui:WaitForChild("StatGui"):WaitForChild("Container"):WaitForChild("CharacterName"):WaitForChild("Shadow")

            health_label.Text = ("%s/%s"):format(current_health, max_health)

            if library.flags["Streamer Mode"] then
                char_shadow.Text = "PATRICK BATEMAN"
                char_shadow.Parent.Text = "PATRICK BATEMAN"
            end

            character.ChildAdded:Connect(function(spell_tool)
                if library.flags["Show Spell %"] then
                    if spell_tool.ClassName == "Tool" then
                        local spell_cost_data = global_variables.spell_cost[spell_tool.Name]
                        
                        if spell_cost_data then
                            local normal_cast_info = spell_cost_data[1]

                            normal_overlay.Position = udim2_new(0, 0, 1 -math_abs(normal_cast_info[1] / 100), 0)
                            normal_overlay.Size = udim2_new(1, 0, math_abs(normal_cast_info[1] - normal_cast_info[2]) / 100, 0)
                            normal_overlay.Visible = true

                            local snap_cast_info = spell_cost_data[2]

                            if snap_cast_info then
                                snap_overlay.Position = udim2_new(0, 0, 1 -math_abs(snap_cast_info[1] / 100), 0)
                                snap_overlay.Size = udim2_new(1, 0, math_abs(snap_cast_info[1] - snap_cast_info[2]) / 100, 0)
                                snap_overlay.Visible = true
                            end
                        end
                    end
                end
            end)

            character.ChildRemoved:Connect(function(spell_tool)
                if spell_tool.ClassName == "Tool" then
                    normal_overlay.Visible = false
                    snap_overlay.Visible = false
                end
            end)

            humanoid.HealthChanged:Connect(function()
                if not (library.flags["AA Bypass"] and library.flags.Flight) then
                    current_health, max_health = tostring(math_floor(humanoid.Health)), tostring(math_floor(humanoid.MaxHealth))
                else
                    current_health, max_health = "100", "100"
                end
                health_label.Text = ("%s/%s"):format(current_health, max_health)
            end)

            mana:GetPropertyChangedSignal("Value"):Connect(function()
                if library.flags["Show Mana Amount"] then
                    mana_label.Text = tostring(math_floor(mana.Value))
                end
            end)
        end
    
        local character = player.Character or player.CharacterAdded:Wait()
    
        init_mana_guis(character)
        show_stat_guis(character)
        
        player.CharacterAdded:Connect(show_stat_guis)

        visuals_combat:Toggle({Name = "Show Health Amount", Callback = function(state)
            health_label.Visible = state
        end})
        
        visuals_combat:Toggle({Name = "Show Mana Amount", Callback = function(state)
            local fifty_label = fake_mana_bar:FindFirstChild("fifty_label")

            if fifty_label then
                fifty_label.Visible = (false and (not library.flags["List Mana Increments"] or not state)) or true
                fifty_label.Text = "50"
            end
        end})


        visuals_combat:Toggle({Name = "List Mana Increments", Callback = function(state)
            fake_left_container.Visible = state

            local gui_children = fake_mana_bar:GetChildren()

            for index = 1, #gui_children do
                local child = gui_children[index]

                if child.Name ~= "fifty_label" then
                    child.Visible = state
                end
            end
            
            if state and not library.flags["Show Mana Amount"] then
                mana_label.Text = "50"
            end
        end})

        visuals_combat:Toggle({Name = "Show Spell %"})

        visuals_combat:Toggle({Name = "Streamer Mode", Callback = function(state)
            local char_shadow = player.PlayerGui:WaitForChild("StatGui"):WaitForChild("Container"):WaitForChild("CharacterName"):WaitForChild("Shadow")
            
            if state then
                char_shadow.Text = "PATRICK BATEMAN"
                char_shadow.Parent.Text = "PATRICK BATEMAN"
            end
        end})
    end

    do -- player esp
        local class_tools = {
            ["DRUID"] = "Fons Vitae",
            ["SPY"] = "Rapier",
            ["WRAITH"] = "Dark Eruption",
            ["SHIN"] = "Grapple",
            ["FACE"] = "Shadow Fan",
            ["NECRO"] = "Secare",
            ["DEEP"] = "Chain Pull",
            ["ABYSS"] = "Wrathful Leap",
            ["ONI"] = "Demon Step",
            ["SMITH"] = "Ruby Shard",
            ["BARD"] = "Joyous Dance",
            ["ILLU"] = "Observe",
            ["SIGIL"] = "Flame Charge",
            ["DSAGE"] = "Lightning Drop",
            ["SLAYER"] = "Thunder Spear Crash"
        }

        function make_drawing(drawing_type, properties)
            local drawing = Drawing.new(drawing_type)

            if properties then
                for property_index, property_value in next, properties do
                    drawing[property_index] = property_value
                end
            end

            return drawing
        end

        function round_vector(vector)
            local vector_x, vector_y = vector.X, vector.Y

            return vector2_new(vector_x - vector_x % 1, vector_y - vector_y % 1)
        end

        local function draw_esp(target_player)
            local character = target_player.Character

            if not character then return end
            task_wait()

            local rogue_name = "Unknown"
            local rogue_class = "FRESH"

            local esp_objects = {
                box_main = make_drawing("Square", {Color = color3_fromrgb(255, 255, 255), Thickness = 1.5, ZIndex = 1}),
                box_outline = make_drawing("Square", {Color = color3_fromrgb(0, 0, 0), Thickness = 1.5}),
                health_main = make_drawing("Square", {Color = color3_fromrgb(0, 0, 0), Thickness = 1.5, ZIndex = 1, Filled = true}),
                health_outline = make_drawing("Square", {Color = color3_fromrgb(0, 0, 0), Filled = true}),
                tracer_main = make_drawing("Line", {Color = color3_fromrgb(255, 255, 255), ZIndex = 1, Transparency = 0.5}),
                tracer_outline = make_drawing("Line", {Color = color3_fromrgb(0, 0, 0), Transparency = 0.5}),
                text_main = make_drawing("Text", {Color = color3_fromrgb(255, 255, 255), Center = true, Outline = true, ZIndex = 1, Size = 16}),
                text_extra = make_drawing("Text", {Color = color3_fromrgb(255, 255, 255), Center = true, Outline = true, ZIndex = 1, Size = 16}),
            }

            for class, tool_name in next, class_tools do
                if target_player.Backpack:FindFirstChild(tool_name) then
                    rogue_class = class
                    break
                end
            end

            local fake_humanoid = character:FindFirstChild("FakeHumanoid", true)

            if fake_humanoid then 
                local rogue_name_part = fake_humanoid.Parent

                if rogue_name_part then 
                    rogue_name = rogue_name_part.Name
                end 
            end

            local bind_name = services.HttpService:GenerateGUID()

            services.RunService:BindToRenderStep(bind_name, Enum.RenderPriority.Camera.Value, function()
                if library.flags["Player ESP"] and (library.flags["Show Local"] or target_player ~= player) then
                    local character = target_player.Character

                    if character then 
                        local humanoid, humanoid_root_part = character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")

                        if humanoid_root_part and humanoid and humanoid.Health > 0 then
                            local health_percent = (humanoid.Health / humanoid.MaxHealth)
                            local screen_position, on_screen = camera:WorldToViewportPoint(humanoid_root_part.Position)

                            local orientation = humanoid_root_part.CFrame
                            local height = (camera.CFrame - camera.CFrame.Position) * vector3_new(0, 2.75, 0)
                            local screen_height = math_abs(camera:WorldToScreenPoint(orientation.Position + height).Y - camera:WorldToScreenPoint(orientation.Position - height).Y)
                            local box_size = round_vector(vector2_new(screen_height / 2, screen_height))

                            esp_objects.box_main.Color = library.flags["Player Box Color"]
                            esp_objects.box_main.Size = box_size
                            esp_objects.box_main.Position = round_vector(vector2_new(screen_position.X, screen_position.Y) - (box_size / 2))

                            esp_objects.box_outline.Thickness = esp_objects.box_main.Thickness * 2
                            esp_objects.box_outline.Size = esp_objects.box_main.Size
                            esp_objects.box_outline.Position = esp_objects.box_main.Position
                            
                            esp_objects.text_main.Font = 1
                            esp_objects.text_main.Size = library.flags["Text Size"]
                            esp_objects.text_main.Text = (library.flags["Rogue Name"] and rogue_name) or target_player.Name
                            esp_objects.text_main.Visible = on_screen
                            esp_objects.text_main.Color = library.flags["Player Text Color"]
                            esp_objects.text_main.Position = vector2_new(((esp_objects.box_main.Size.X / 2) + esp_objects.box_main.Position.X), ((screen_position.Y - esp_objects.box_main.Size.Y / 2) - 18))

                            esp_objects.text_extra.Text = ""
                            esp_objects.text_extra.Font = 1
                            esp_objects.text_extra.Visible = on_screen
                            esp_objects.text_extra.Size = library.flags["Text Size"]
                            esp_objects.text_extra.Color = library.flags["Player Text Color"]
                            esp_objects.text_extra.Position = vector2_new(((esp_objects.box_main.Size.X / 2) + esp_objects.box_main.Position.X), (esp_objects.box_main.Size.Y + esp_objects.box_main.Position.Y))

                            if library.flags["Show Distance"] and player.Character then
                                local distance = math_floor(player:DistanceFromCharacter(humanoid_root_part.Position))
                                esp_objects.text_extra.Text = ("(%dm) "):format(distance)
                            end

                            if library.flags["Show Health Bar"] then
                                esp_objects.text_extra.Text = (esp_objects.text_extra.Text .. ("(%d/%d)"):format(humanoid.Health, humanoid.MaxHealth))

                                esp_objects.health_main.Color = color3_fromrgb(0, 255, 0)
                                esp_objects.health_main.Size = vector2_new(2, (-esp_objects.box_main.Size.Y * health_percent))
                                esp_objects.health_main.Position = vector2_new((esp_objects.box_main.Position.X - (esp_objects.box_outline.Thickness + 1)), (esp_objects.box_main.Position.Y + esp_objects.box_main.Size.Y))

                                esp_objects.health_outline.Size = vector2_new(4, (esp_objects.box_main.Size.Y + 2))
                                esp_objects.health_outline.Position = vector2_new((esp_objects.box_main.Position.X - (esp_objects.box_outline.Thickness + 2)), (esp_objects.box_main.Position.Y - 1))
                                esp_objects.health_main.Visible = on_screen
                                esp_objects.health_outline.Visible = esp_objects.health_main.Visible
                            else
                                esp_objects.health_main.Visible = false
                                esp_objects.health_outline.Visible = false
                            end

                            if library.flags["Show Class"] then
                                esp_objects.text_extra.Text = (esp_objects.text_extra.Text .. (" [%s]"):format(tostring(rogue_class)))
                            end
                            
                            if library.flags["Seer Insight"] then
                                local player_weapon = "FIST"

                                local weapon_tool = character:FindFirstChildOfClass("Tool")

                                if weapon_tool then 
                                    player_weapon = weapon_tool.Name:upper()
                                end

                                esp_objects.text_main.Text = (esp_objects.text_main.Text .. ("(%s)"):format(player_weapon))
                            end

                            if library.flags["Show Tracers"] then
                                esp_objects.tracer_main.Color = library.flags["Player Tracer Color"]
                                esp_objects.tracer_main.From = vector2_new(camera.ViewportSize.X / 2,  camera.ViewportSize.Y - 140)
                                esp_objects.tracer_main.To = vector2_new(((esp_objects.box_main.Size.X / 2) + esp_objects.box_main.Position.X), (esp_objects.box_main.Size.Y + esp_objects.box_main.Position.Y))
                                
                                esp_objects.tracer_outline.Thickness = (esp_objects.tracer_main.Thickness * 2)
                                esp_objects.tracer_outline.From = esp_objects.tracer_main.From
                                esp_objects.tracer_outline.To = esp_objects.tracer_main.To
                                esp_objects.tracer_outline.Color = color3_fromrgb(0, 0, 0)

                                esp_objects.tracer_main.Visible = on_screen
                                esp_objects.tracer_outline.Visible = esp_objects.tracer_main.Visible
                            else
                                esp_objects.tracer_main.Visible = false
                                esp_objects.tracer_outline.Visible = false
                            end

                            esp_objects.box_main.Visible = on_screen and library.flags["Show Box"]
                            esp_objects.box_outline.Visible = esp_objects.box_main.Visible
                        else
                            services.RunService:UnbindFromRenderStep(bind_name)

                            for index, object in next, esp_objects do
                                object.Visible = false
                                object:Remove()
                                esp_objects[index] = nil
                            end
                        end
                    else 
                        services.RunService:UnbindFromRenderStep(bind_name)
                        
                        for index, object in next, esp_objects do
                            object.Visible = false
                            object:Remove()
                            esp_objects[index] = nil
                        end
                    end
                else 
                    for index, object in next, esp_objects do
                        object.Visible = false
                    end
                end
            end)
        end

        local players_list = services.Players:GetPlayers()

        for index = 1, #players_list do
            local target_player = players_list[index]
            local target_character = target_player.Character

            if target_character then 
                if target_character:FindFirstChild("Humanoid") and target_character:FindFirstChild("HumanoidRootPart") and target_character:FindFirstChild("FakeHumanoid", true) then 
                    draw_esp(target_player)
                end
            end

            target_player.CharacterAdded:Connect(function(character)
                character:WaitForChild("Humanoid")
                character:WaitForChild("HumanoidRootPart")

                while not character:FindFirstChild("FakeHumanoid", true) do 
                    wait()
                end

                wait(2.5)
                draw_esp(target_player)
            end)
        end
        
        services.Players.PlayerAdded:Connect(function(target_player)
            target_player.CharacterAdded:Connect(function(character)
                character:WaitForChild("Humanoid")
                character:WaitForChild("HumanoidRootPart")
                while not character:FindFirstChild("FakeHumanoid", true) do 
                    wait()
                end

                wait(2.5)
                draw_esp(target_player)
            end)
        end)

        player_visuals_settings:Toggle({Name = "Player ESP"})
        player_visuals_settings:Toggle({Name = "Show Box"})
        player_visuals_settings:Toggle({Name = "Show Health Bar"})
        player_visuals_settings:Toggle({Name = "Show Distance"})
        player_visuals_settings:Toggle({Name = "Show Tracers"})
        player_visuals_settings:Toggle({Name = "Rogue Name"})
        player_visuals_settings:Toggle({Name = "Show Class"})
        player_visuals_settings:Toggle({Name = "Seer Intent"})
        player_visuals_settings:Toggle({Name = "Show Local"})

        player_visuals_settings:ColorPicker({Name = "Player Text Color", Default = color3_fromrgb(255, 255, 255)})
        player_visuals_settings:ColorPicker({Name = "Player Box Color", Default = color3_fromrgb(255, 255, 255)})
        player_visuals_settings:ColorPicker({Name = "Player Tracer Color", Default = color3_fromrgb(255, 255, 255)})
        player_visuals_settings:Slider({Name = "Text Size", Min = 12, Max = 22, Default = 16})
    end

    do -- trinket esp
        local trinket_esp_folder = instance_new("Folder")
        local common_trinket_folder = instance_new("Folder")
        local rare_trinket_folder = instance_new("Folder")
        local artifact_folder = instance_new("Folder")

        common_trinket_folder.Parent = trinket_esp_folder
        rare_trinket_folder.Parent = trinket_esp_folder
        artifact_folder.Parent = trinket_esp_folder

        local trinket_table = {}
        
        protect_gui(trinket_esp_folder)

        local common_trinket_ids = {
            ["5196776695"] = "Ring",
            ["5196551436"] = "Amulet",
            ["5204003946"] = "Goblet",
            ["5196782997"] = "Old Ring",
            ["5196577540"] = "Old Amulet",
            ["2765613127"] = "Idol of the Forgotten"
        }

        local rare_trinket_ids = {
            ["5204453430"] = "Scroll",
            ["4103271893"] = "Candy"
        }

        local function identify_trinket(trinket)
            local trinket_class = trinket.ClassName
            local is_mesh_part, is_union_operation, is_part = trinket.ClassName == "MeshPart", trinket.ClassName == "UnionOperation", trinket.ClassName == "Part"
            
            if (is_mesh_part or is_union_operation) and library.flags["Common Trinkets"] then
                local asset_id = is_mesh_part and trinket.MeshId:gsub("%%20", ""):match("%d+") or is_union_operation and gethiddenproperty(trinket, "AssetId"):gsub("%%20", ""):match("%d+")
                local identified_trinket = common_trinket_ids[asset_id]

                if identified_trinket then
                    return identified_trinket, "common"
                end
            end

            if library.flags["Rare Trinkets"] then
                if is_part then
                    if tostring(gethiddenproperty(trinket, "size")) == "0.40000000596046, 0.5, 0.30000001192093" then 
                        return "Opal", "rare"
                    else 
                        local particle_emitter = trinket:FindFirstChild("ParticleEmitter")

                        if particle_emitter and tostring(particle_emitter.Color):find("0 1 1 1 0 1 1 1 1 0") then
                            local mesh = trinket:FindFirstChild("Mesh")

                            if mesh and mesh.MeshId:gsub("%%20", ""):match("%d+") == "2877143560" then 
                                local part_color = trinket.Color

                                if tostring(part_color) == "0.643137, 0.733333, 0.745098" then 
                                    return "Diamond", "rare"
                                elseif part_color.G > part_color.R and part_color.G > part_color.B then 
                                    return "Emerald", "rare"
                                elseif part_color.R > part_color.G and part_color.R > part_color.B then 
                                    return "Ruby", "rare"
                                elseif part_color.B > part_color.G and part_color.B > part_color.R then 
                                    return "Sapphire", "rare"
                                end
                            end
                        end
                    end 
                elseif is_mesh_part then 
                    local identified_trinket = rare_trinket_ids[trinket.MeshId:gsub("%%20", ""):match("%d+")]

                    if identified_trinket then
                        return identified_trinket, "rare"
                    end
                end
            end

            if library.flags["Artifacts"] then
                if is_part then 
                    local particle_emitter = trinket:FindFirstChild("ParticleEmitter")

                    if particle_emitter and not tostring(particle_emitter.Color):find("0 1 1 1 0 1 1 1 1 0") then 
                        return "Rift Gem", "artifact"
                    else 
                        local orb_particle = trinket:FindFirstChild("OrbParticle")

                        if orb_particle then 
                            local orb_particle_color = tostring(orb_particle.Color)

                            if orb_particle_color:find("0 0.105882 0.596078 0.596078 0 1 0.105882 0.596078 0.596078 0 ") then 
                                return "Ice Essence", "artifact"
                            elseif orb_particle_color:find("0 0.596078 0 0.207843 0 1 0.596078 0 0.207843 0 ") then 
                                return "???", "artifact"
                            end
                        end
                    end
                elseif is_mesh_part and trinket.MeshId:gsub("%%20", ""):match("%d+") == "2520762076" then 
                    return "Howler Friend", "artifact"
                elseif is_union_operation then 
                    if trinket.BrickColor.Name == "Black" then 
                        return "Night Stone", "artifact"
                    else
                        local asset_id = gethiddenproperty(trinket, "AssetId"):gsub("%%20", ""):match("%d+")

                        if asset_id == "3158350180" then 
                            return "Amulet of the White King", "artifact"
                        elseif asset_id == "2998499856" then 
                            return "Lannis Amulet", "artifact"
                        end
                    end
                end

                local attachment = trinket:FindFirstChild("Attachment")

                if attachment then
                    local particle_emitter = attachment:FindFirstChildOfClass("ParticleEmitter")

                    if particle_emitter then 
                        local particle_emitter_color = tostring(particle_emitter.Color)
                        local size = tostring(trinket.Size)

                        if size:find("0.69999998807907, 0.69999998807907, 0.69999998807907") and particle_emitter_color:find("0 0.45098 1 0 0 1 0.482353 1 0 0 ") then 
                            return "Mysterious Artifact", "artifact"
                        elseif size:find("0.69999998807907, 0.69999998807907, 0.69999998807907") and particle_emitter_color:find("0 1 0.8 0 0 1 1 0.501961 0 0 ") then 
                            return "Phoenix Down", "artifact"
                        end
                    end
                end
            end
        end

        local function create_trinket_esp(trinket)
            if trinket_table[trinket] then 
                return
            end

            local trinket_name, trinket_rarity = identify_trinket(trinket)

            if trinket_name and library.flags["Trinket ESP"] then
                if trinket_rarity == "common" and not library.flags["Common Trinkets"] then
                    return
                elseif trinket_rarity == "rare" and not library.flags["Rare Trinkets"] then
                    return
                elseif trinket_rarity == "artifact" and not library.flags["Artifacts"] then
                    return
                end

                trinket_table[trinket] = true

                local trinket_gui = instance_new("BillboardGui")
                trinket_gui.StudsOffset = vector3_new(0, 0.75, 0)
                trinket_gui.Size = udim2_new(0, 200, 0, 50)
                trinket_gui.AlwaysOnTop = true
                trinket_gui.Parent = (trinket_rarity == "common" and common_trinket_folder) or (trinket_rarity == "rare" and rare_trinket_folder) or (trinket_rarity == "artifact" and artifact_folder) or nil
                trinket_gui.Adornee = trinket

                local trinket_name_label = instance_new("TextLabel")
                trinket_name_label.TextColor3 = library.flags["Trinket ESP Color"] or trinket.Color
                trinket_name_label.Size = udim2_new(0, 200, 0, 50)
                trinket_name_label.TextStrokeTransparency = 0.6
                trinket_name_label.BackgroundTransparency = 1
                trinket_name_label.Text = trinket_name
                trinket_name_label.Parent = trinket_gui
                trinket_name_label.TextScaled = false
                trinket_name_label.TextSize = library.flags["Trinket ESP Size"]

                local distance_label = instance_new("TextLabel")
                distance_label.TextColor3 = Color3.new(152, 152, 152)
                distance_label.Size = udim2_new(0, 200, 0, 50)
                distance_label.TextStrokeTransparency = 0.6
                distance_label.BackgroundTransparency = 1
                distance_label.TextScaled = false
                distance_label.Parent = trinket_gui
                distance_label.TextSize = library.flags["Trinket ESP Size"] - 2
                distance_label.Text = ("\n\n\n[%dm]"):format(math_floor((camera.CFrame.Position - trinket.Position).Magnitude))

                task_spawn(function()
                    while wait(library.flags["Trinket ESP Delay"] / 75) do
                        if library.flags["Trinket ESP"] and trinket_gui and trinket_gui.Parent and trinket and trinket.Parent == workspace then
                            trinket_name_label.TextColor3 = library.flags["Trinket ESP Color"] or trinket.Color
                            trinket_name_label.TextSize = library.flags["Trinket ESP Size"]

                            distance_label.TextSize = (library.flags["Trinket ESP Size"] - 2)

                            if library.flags["Show Trinket Distance"] then
                                local distance = math_floor((camera.CFrame.Position - trinket.Position).Magnitude)
                                distance_label.Text = ("\n\n\n[%dm]"):format(distance)
                            else
                                distance_label.Text = ""
                            end
                        else
                            if trinket_gui then
                                trinket_gui:Destroy()
                            end

                            trinket_table[trinket] = nil

                            break
                        end
                    end
                end)
            end
        end

        local function destroy_trinket_esp(rarity)
            if rarity == "common" then
                local common_children = common_trinket_folder:GetChildren()

                for index = 1, #common_children do
                    common_children[index]:Destroy()
                end
            elseif rarity == "rare" then
                local rare_children = rare_trinket_folder:GetChildren()

                for index = 1, #rare_children do
                    rare_children[index]:Destroy()
                end
            elseif rarity == "artifact" then
                local artifact_children = artifact_folder:GetChildren()

                for index = 1, #artifact_children do
                    artifact_children[index]:Destroy()
                end
            end
        end

        local function refresh_trinket_esp()
            if library.flags["Trinket ESP"] then
                local workspace_children = workspace:GetChildren()

                for index = 1, #workspace_children do
                    local object = workspace_children[index]

                    if object.Name == "Part" and object:FindFirstChild("ID") then
                        create_trinket_esp(object)
                    end
                end
            end
        end

        workspace.ChildAdded:Connect(function(object)
            if object.Name == "Part" and object:FindFirstChild("ID") then
                create_trinket_esp(object)
            end
        end)

        visuals_trinket:Toggle({Name = "Trinket ESP", Callback = refresh_trinket_esp})
        visuals_trinket:Toggle({Name = "Show Trinket Distance"})
        visuals_trinket:Slider({Name = "Trinket ESP Size", Min = 9, Max = 22, Default = 13})
        visuals_trinket:Slider({Name = "Trinket ESP Delay", Min = 3, Max = 15, Default = 7})
        visuals_trinket:ColorPicker({Name = "Trinket ESP Color", Default = color3_fromrgb(255, 255, 255)})
        visuals_trinket:Toggle({Name = "Common Trinkets", Callback = function(state) if state then refresh_trinket_esp() else destroy_trinket_esp("common") end end})
        visuals_trinket:Toggle({Name = "Rare Trinkets", Callback = function(state) if state then refresh_trinket_esp() else destroy_trinket_esp("rare") end end})
        visuals_trinket:Toggle({Name = "Artifacts", Callback = function(state) if state then refresh_trinket_esp() else destroy_trinket_esp("artifact") end end})
    end

    do -- ingredient esp
        local ingredient_folder

        for index, instance in next, workspace:GetChildren() do
            if ingredient_folder then 
                break
            end

            if instance.ClassName == "Folder" then
                for index, ingredient in next, instance:GetChildren() do
                    if ingredient.ClassName == "UnionOperation" and ingredient:FindFirstChild("ClickDetector") and ingredient:FindFirstChild("Blacklist") then
                        ingredient_folder = instance
                        break
                    end
                end
            end
        end
        
        local ingredient_ids = {
            ["3293218896"] = "Desert Mist",
            ["2773353559"] = "Blood Thorn",
            ["2960178471"] = "Snowscroom",
            ["2577691737"] = "Lava Flower",
            ["2618765559"] = "Glow Scroom",
            ["2575167210"] = "Moss Plant",
            ["2620905234"] = "Scroom",
            ["2766925289"] = "Trote",
            ["2766925320"] = "Polar Plant",
            ["2766802713"] = "Periashroom",
            ["2766802766"] = "Strange Tentacle",
            ["2766925228"] = "Tellbloom",
            ["2766802731"] = "Dire Flower",   
            ["2573998175"] = "Freeleaf",
            ["2766925214"] = "Crown Flower",
            ["3215371492"] = "Potato",
            ["2766925304"] = "Vile Seed",
            ["3049345298"] = "Zombie Scroom",
            ["2766802752"] = "Orcher Leaf",
            ["2766925267"] = "Creely",
            ["2889328388"] = "Ice Jar",
            ["3049928758"] = "Canewood",
            ["3049556532"] = "Acorn Light",
            ["2766925245"] = "Uncanny Tentacle"
        }

        local ingredient_esp_folder = instance_new("Folder")
        local ingredient_table = {}
        
        protect_gui(ingredient_esp_folder)

        for id, ingredient in next, ingredient_ids do
            local in_folder = instance_new("Folder")
            in_folder.Name = ingredient
            in_folder.Parent = ingredient_esp_folder
        end

        local function identify_ingredient(part)
            local asset_id = gethiddenproperty(part, "AssetId"):gsub("%%20", ""):match("%d+")
            local matched_ingredient = ingredient_ids[asset_id]

            if matched_ingredient then
                return matched_ingredient
            end
        end

        local function create_ingredient_esp(ingredient)
            if ingredient_table[ingredient] then 
                return
            end
            
            local ingredient_name = identify_ingredient(ingredient)

            if ingredient_name and library.flags["Ingredient ESP"] then
                if not library.flags[ingredient_name] then return end
                local folder_parent = ingredient_esp_folder:FindFirstChild(ingredient_name)

                if folder_parent then
                    ingredient_table[ingredient] = true

                    local ingredient_gui = instance_new("BillboardGui")
                    ingredient_gui.StudsOffset = vector3_new(0, 0.75, 0)
                    ingredient_gui.Size = udim2_new(0, 200, 0, 50)
                    ingredient_gui.AlwaysOnTop = true
                    ingredient_gui.Parent = folder_parent
                    ingredient_gui.Adornee = ingredient
                    ingredient_gui.Enabled = false

                    local name_label = instance_new("TextLabel")
                    name_label.TextColor3 = library.flags["Ingredient ESP Color"] or ingredient.Color
                    name_label.Size = udim2_new(0, 200, 0, 50)
                    name_label.TextStrokeTransparency = 0.6
                    name_label.BackgroundTransparency = 1
                    name_label.Text = ingredient_name
                    name_label.Parent = ingredient_gui
                    name_label.TextScaled = false
                    name_label.TextSize = library.flags["Ingredient ESP Size"]

                    local distance_label = instance_new("TextLabel")
                    distance_label.TextColor3 = Color3.new(152, 152, 152)
                    distance_label.Size = udim2_new(0, 200, 0, 50)
                    distance_label.TextStrokeTransparency = 0.6
                    distance_label.BackgroundTransparency = 1
                    distance_label.TextScaled = false
                    distance_label.Parent = ingredient_gui
                    distance_label.TextSize = library.flags["Ingredient ESP Size"] - 2
                    distance_label.Text = ("\n\n\n[%dm]"):format(math_floor((camera.CFrame.Position - ingredient.Position).Magnitude))

                    local last_visble = false
                    task_spawn(function()
                        while wait(library.flags["Ingredient ESP Delay"] / 75) do
                            if player.Character and ingredient and library.flags["Ingredient ESP"] then
                                local distance = player:DistanceFromCharacter(ingredient.Position)

                                if distance > library.flags["Ingredient ESP Range"] then
                                    ingredient_gui.Enabled = false
                                    last_visble = false
                                else
                                    ingredient_gui.Enabled = true
                                    last_visble = true
                                end
                            end

                            if library.flags["Ingredient ESP"] and ingredient_gui and ingredient_gui.Parent and ingredient and ingredient.Parent == ingredient_folder and ingredient.Transparency ~= 1 then
                                if last_visble then
                                    name_label.TextColor3 = library.flags["Ingredient ESP Color"] or ingredient.Color
                                    name_label.TextSize = library.flags["Ingredient ESP Size"]

                                    distance_label.TextSize = (library.flags["Ingredient ESP Size"] - 2)

                                    if library.flags["Ingredient ESP Distance"] then
                                        local distance = math_floor((camera.CFrame.Position - ingredient.Position).Magnitude)
                                        distance_label.Text = ("\n\n\n[%dm]"):format(distance)
                                    else
                                        distance_label.Text = ""
                                    end
                                end
                            else
                                if ingredient_gui then
                                    ingredient_gui:Destroy()
                                end

                                ingredient_table[ingredient] = nil

                                break
                            end
                        end
                    end)
                end
            end
        end

        local function destroy_ingredient_esp(ingredient_type)
            local folder_parent = ingredient_esp_folder:FindFirstChild(ingredient_type)
            
            if folder_parent then
                local folder_children = folder_parent:GetChildren()

                for index = 1, #folder_children do
                    folder_children[index]:Destroy()
                end
            end
        end

        local function refresh_ingredient_esp()
            if library.flags["Ingredient ESP"] then
                local ingredient_folder_children = ingredient_folder:GetChildren()

                for index = 1, #ingredient_folder_children do
                    local object = ingredient_folder_children[index]
                    create_ingredient_esp(object)
                end
            end
        end

        visuals_ingredient:Toggle({Name = "Ingredient ESP", Callback = refresh_ingredient_esp})
        visuals_ingredient:Toggle({Name = "Ingredient ESP Distance"})
        visuals_ingredient:Slider({Name = "Ingredient ESP Range", Min = 25, Max = 5000, Default = 300})
        visuals_ingredient:Slider({Name = "Ingredient ESP Size", Min = 9, Max = 22, Default = 13})
        visuals_ingredient:Slider({Name = "Ingredient ESP Delay", Min = 3, Max = 15, Default = 7})

        for id, ingredient in next, ingredient_ids do
            visuals_ingredient:Toggle({Name = ingredient, Callback = function(state) 
                if state then 
                    refresh_ingredient_esp() 
                else 
                    destroy_ingredient_esp(ingredient) 
                end
            end})
        end
    end

    do -- ore esp
        local ore_esp_folder = instance_new("Folder")
        
        local mythril_folder = instance_new("Folder")
        local iron_folder = instance_new("Folder")
        local copper_folder = instance_new("Folder")
        local tin_folder = instance_new("Folder")

        mythril_folder.Parent = ore_esp_folder
        iron_folder.Parent = ore_esp_folder
        copper_folder.Parent = ore_esp_folder
        tin_folder.Parent = ore_esp_folder
        
        local ore_table = {}
        
        protect_gui(ore_esp_folder)

        local function create_ore_esp(ore)
            if ore_table[ore] then 
                return
            end

            local ore_type = ore.Name:lower()

            if ore and library.flags["Ore ESP"] then
                if (ore_type == "mythril" and not library.flags["Mythril Ore"]) or (ore_type == "iron" and not library.flags["Iron Ore"]) or (ore_type == "copper" and not library.flags["Copper Ore"]) or (ore_type == "tin" and not library.flags["Tin Ore"]) then
                    return
                end

                ore_table[ore] = true

                local ore_gui = instance_new("BillboardGui")
                ore_gui.StudsOffset = vector3_new(0, 0.75, 0)
                ore_gui.Size = udim2_new(0, 200, 0, 50)
                ore_gui.AlwaysOnTop = true
                ore_gui.Parent = (ore_type == "mythril" and mythril_folder) or (ore_type == "iron" and iron_folder) or (ore_type == "copper" and copper_folder) or (ore_type == "tin" and tin_folder) or nil
                ore_gui.Adornee = ore

                local ore_name_label = instance_new("TextLabel")
                ore_name_label.TextColor3 = ore.Color
                ore_name_label.Size = udim2_new(0, 200, 0, 50)
                ore_name_label.TextStrokeTransparency = 0.6
                ore_name_label.BackgroundTransparency = 1
                ore_name_label.Text = ore.Name
                ore_name_label.Parent = ore_gui
                ore_name_label.TextScaled = false
                ore_name_label.TextSize = library.flags["Ore Size"]

                local distance_label = instance_new("TextLabel")
                distance_label.TextColor3 = Color3.new(152, 152, 152)
                distance_label.Size = udim2_new(0, 200, 0, 50)
                distance_label.TextStrokeTransparency = 0.6
                distance_label.BackgroundTransparency = 1
                distance_label.TextScaled = false
                distance_label.Parent = ore_gui
                distance_label.TextSize = library.flags["Ore Size"] - 2
                distance_label.Text = ("\n\n\n[%dm]"):format(math_floor((camera.CFrame.Position - ore.Position).Magnitude))

                task_spawn(function()
                    while wait(library.flags["Ore Delay"] /75) do
                        if library.flags["Ore ESP"] and ore_gui and ore.Transparency ~= 1 then
                            ore_name_label.TextSize = library.flags["Ore Size"]

                            distance_label.TextSize = (library.flags["Ore Size"] - 2)

                            if library.flags["Ore Distance"] then
                                local distance = math_floor((camera.CFrame.Position - ore.Position).Magnitude)
                                distance_label.Text = ("\n\n\n[%dm]"):format(distance)
                            else
                                distance_label.Text = ""
                            end
                        else
                            if ore_gui then
                                ore_gui:Destroy()
                            end

                            ore_table[ore] = nil
                            
                            break
                        end
                    end
                end)
            end
        end

        local function destroy_ore_esp(ore_type)
            local ore_children = ore_type == "mythril" and mythril_folder:GetChildren() or ore_type == "iron" and iron_folder:GetChildren() or ore_type == "copper" and copper_folder:GetChildren() or ore_type == "tin" and tin_folder:GetChildren()
            
            for index = 1, #ore_children do
                ore_children[index]:Destroy()
            end
        end

        local function refresh_ore_esp()
            if library.flags["Ore ESP"] then
                local ore_children = workspace.Ores:GetChildren()

                for index = 1, #ore_children do
                    local object = ore_children[index]
                    create_ore_esp(object)
                end
            end
        end

        workspace.Ores.ChildAdded:Connect(function(object)
            create_ore_esp(object)
        end)

        visuals_ores:Toggle({Name = "Ore ESP", Callback = refresh_ore_esp})
        visuals_ores:Toggle({Name = "Ore Distance"})
        visuals_ores:Slider({Name = "Ore Size", Min = 9, Max = 22, Default = 13})
        visuals_ores:Slider({Name = "Ore Delay", Min = 3, Max = 15, Default = 7})
        visuals_ores:Toggle({Name = "Mythril Ore", Callback = function(state) if state then refresh_ore_esp() else destroy_ore_esp("mythril") end end})
        visuals_ores:Toggle({Name = "Iron Ore", Callback = function(state) if state then refresh_ore_esp() else destroy_ore_esp("iron") end end})
        visuals_ores:Toggle({Name = "Copper Ore", Callback = function(state) if state then refresh_ore_esp() else destroy_ore_esp("copper") end end})
        visuals_ores:Toggle({Name = "Tin Ore", Callback = function(state) if state then refresh_ore_esp() else destroy_ore_esp("tin") end end})
    end

    do -- fallion esp
        local npcs_folder = workspace:WaitForChild("NPCs")
        local fallion = npcs_folder:WaitForChild("Fallion")
        local fallion_esp_folder = instance_new("Folder")       

        protect_gui(fallion_esp_folder)

        local fallion_gui = instance_new("BillboardGui")
        fallion_gui.StudsOffset = vector3_new(0, 0.75, 0)
        fallion_gui.Size = udim2_new(0, 200, 0, 50)
        fallion_gui.AlwaysOnTop = true
        fallion_gui.Parent = fallion_esp_folder
        fallion_gui.Adornee = fallion:WaitForChild("Torso")
        fallion_gui.Enabled = false

        local fallion_name = instance_new("TextLabel")
        fallion_name.TextColor3 = color3_fromrgb(50, 125, 235)
        fallion_name.Size = udim2_new(0, 200, 0, 50)
        fallion_name.TextStrokeTransparency = 0.6
        fallion_name.BackgroundTransparency = 1
        fallion_name.Text = "Fallion"
        fallion_name.Parent = fallion_gui
        fallion_name.TextScaled = false
        fallion_name.TextSize = 14

        visuals_misc:Toggle({Name = "Fallion ESP", Callback = function(state)
            fallion_gui.Enabled = state
        end})
    end
    
    do -- anti-fog 
        local function change_fog()
            wait(1)

            if library.flags["Anti Fog"] then
                services.Lighting.FogColor = color3_fromrgb(254, 254, 254)
                services.Lighting.FogEnd = 100000
                services.Lighting.FogStart = 50
            end
        end

        services.Lighting:GetPropertyChangedSignal("FogEnd"):Connect(change_fog)

        visuals_environment:Toggle({Name = "Anti Fog", Callback = change_fog})
    end


    do -- auto trinket pickup
        local function pickup_trinket(trinket)
            if trinket.Name == "Part" and trinket:FindFirstChild("ID") then 
                local trinket_part = trinket:WaitForChild("Part")
                local pickup = trinket_part:WaitForChild("ClickDetector")
                local activation_distance = pickup.MaxActivationDistance - 5

                task_spawn(function()
                    while not library.flags["Auto Trinket Pickup"] or not player.Character or not player.Character:FindFirstChild("Head") or player:DistanceFromCharacter(trinket_part.Position) > activation_distance do 
                        wait(0.1)
                    end
                    
                    repeat
                        local character = player.Character
                        
                        if character and character:FindFirstChild("Head") and player:DistanceFromCharacter(trinket_part.Position) <= activation_distance then
                            fireclickdetector(pickup)
                        end

                        wait(0.1)
                    until not trinket or not trinket:IsDescendantOf(workspace)
                end)
            end
        end 

        for index, trinket in next, workspace:GetChildren() do
            pickup_trinket(trinket)
        end
        
        workspace.ChildAdded:Connect(pickup_trinket)
        
        visuals_environment:Toggle({Name = "Auto Trinket Pickup"})
    end

    do -- auto ingredient pickup
        local ingredient_folder

        for index, folder in next, workspace:GetChildren() do
            if ingredient_folder then 
                break 
            end 
            
            if folder.ClassName == "Folder" then
                for index, part in next, folder:GetChildren() do
                    if part.ClassName == "UnionOperation" and part:FindFirstChild("ClickDetector") and part:FindFirstChild("Blacklist") then
                        ingredient_folder = folder
                        break
                    end
                end
            end
        end

        local function pickup_ingredient(ingredient)
            local ingredient_pickup = ingredient:WaitForChild("ClickDetector")

            task_spawn(function()
                while not library.flags["Auto Ingredient Pickup"] or not player.Character or not player.Character:FindFirstChild("Head") or player:DistanceFromCharacter(ingredient.Position) > ingredient_pickup.MaxActivationDistance do 
                    wait()
                end
                
                local character = player.Character

                if character and character:FindFirstChild("Head") then
                    fireclickdetector(ingredient_pickup)
                end
            end)
        end
        
        for index, ingredient in next, ingredient_folder:GetChildren() do
            pickup_ingredient(ingredient)
        end
        
        ingredient_folder.ChildAdded:Connect(pickup_ingredient)

        visuals_environment:Toggle({Name = "Auto Ingredient Pickup"})
    end

    do -- auto weapon pickup
        local thrown_folder = workspace:WaitForChild("Thrown")

        local function pickup_weapon(weapon)
            wait(1)
            
            local pickup = weapon:FindFirstChild("ClickDetector")
            
            if weapon:FindFirstChild("Prop") and pickup then 
                local main_part = weapon.ClassName == "Model" and weapon:FindFirstChildWhichIsA("BasePart") or weapon
                local activation_distance = pickup.MaxActivationDistance - 2

                task_spawn(function()
                    while not library.flags["Auto Weapon Pickup"] or not player.Character or not player.Character:FindFirstChild("Head") or player:DistanceFromCharacter(main_part.Position) > activation_distance do 
                        wait(0.1)
                    end
                    
                    repeat
                        local character = player.Character
                        
                        if character and character:FindFirstChild("Head") and player:DistanceFromCharacter(main_part.Position) <= activation_distance then
                            fireclickdetector(pickup)
                        end

                        wait(0.1)
                    until not weapon or not weapon:IsDescendantOf(thrown_folder)
                end)
            end
        end

        thrown_folder.ChildAdded:Connect(pickup_weapon)
        
        visuals_environment:Toggle({Name = "Auto Weapon Pickup"})
    end

    do -- ambience
        local function change_ambience()
            if library.flags["Ambience"] then
                services.Lighting.Ambient = library.flags["Indoor Ambience"]
                services.Lighting.OutdoorAmbient = library.flags["Outdoor Ambience"]
            end
        end

        services.Lighting:GetPropertyChangedSignal("Ambient"):Connect(change_ambience)
        services.Lighting:GetPropertyChangedSignal("OutdoorAmbient"):Connect(change_ambience)

        visuals_environment:Toggle({Name = "Ambience"})
        visuals_environment:ColorPicker({Name = "Indoor Ambience", Default = color3_fromrgb(255, 255, 255), Callback = change_ambience})
        visuals_environment:ColorPicker({Name = "Outdoor Ambience", Default = color3_fromrgb(255, 255, 255), Callback = change_ambience})
    end
    
    do -- set time
        local function change_time()
            if library.flags["Change Time"] then
                services.Lighting.ClockTime = library.flags["Time Hour"]
            end
        end

        services.Lighting:GetPropertyChangedSignal("ClockTime"):Connect(change_time)

        visuals_environment:Toggle({Name = "Change Time"})
        visuals_environment:Slider({Name = "Time Hour", Min = 0, Max = 24, Default = 12, Callback = function(value)
            if library.flags["Change Time"] then
                services.Lighting.ClockTime = value
            end
        end})
    end

    do -- bag notifier
        local thrown_folder = workspace:WaitForChild("Thrown")
        
        thrown_folder.ChildAdded:Connect(function(bag)
            wait()
            
            if (bag.Name == "ToolBag" and library.flags["Item Bag Notifier"]) or (bag.Name == "MoneyBag" and library.flags["Silver Bag Notifier"]) then
                local billboard_gui = bag:FindFirstChildOfClass("BillboardGui")

                if billboard_gui then
                    local text_label = billboard_gui:FindFirstChildOfClass("TextLabel")

                    if text_label then
                        local text_value = text_label.Text

                        local bag_notification = window:Notification({
                            Type = "Message", 
                            Content = {
                                Text = tonumber(text_value) and ("A bag of %s silver has been dropped"):format(text_value) or ("A bag including a %s has been dropped"):format(text_value),
                                ConfirmText = "Okay"
                            }
                        })

                        if library.flags["Auto Clear Notifications"] then
                            repeat 
                                wait(1) 
                            until not bag or not bag:IsDescendantOf(workspace)
                            
                            bag_notification:Close()
                        end
                    end
                end
            end
        end)

        visuals_environment:Toggle({Name = "Item Bag Notifier"})
        visuals_environment:Toggle({Name = "Silver Bag Notifier"})
    end

    do -- rtx mode
        visuals_environment:Toggle({Name = "RTX Mode", Callback = function(state)
            if not library.flags["Lag Reduction"] then
                sethiddenproperty(services.Lighting, "Technology", state and 4 or 3)
            end
        end})
    end

    do -- lag reduction
        visuals_environment:Toggle({Name = "Lag Reduction", Callback = function(state)
            sethiddenproperty(services.Lighting, "Technology", state and 2 or library.flags["RTX Mode"] and 4 or 3)
			sethiddenproperty(workspace.Terrain, "Decoration", not state)
            services.Lighting.GlobalShadows = not state
        end})  
    end
end

do -- spoofing
    local spoof_world = sections.spoof_settings

    do -- silver spoofing
        local player_gui = player.PlayerGui

        local function start_silver_spoofing(character)
            local silver_shadow = player_gui:WaitForChild("CurrencyGui"):WaitForChild("Silver"):WaitForChild("Value"):WaitForChild("Shadow")

            local silver_value = tonumber(library.flags["Silver Value"])

            if silver_value then
                local silver_string = tostring(silver_value)

                silver_shadow.Parent.Text = silver_string
                silver_shadow.Text = silver_string
            end

            silver_shadow:GetPropertyChangedSignal("Text"):Connect(function()
                local silver_value = tonumber(library.flags["Silver Value"])

                if silver_value then
                    local silver_string = tostring(silver_value)

                    silver_shadow.Parent.Text = silver_string
                    silver_shadow.Text = silver_string
                end
            end)
        end

        local character = player.Character or player.CharacterAdded:Wait()

        start_silver_spoofing(character)
        player.CharacterAdded:Connect(start_silver_spoofing)

        spoof_world:Toggle({Name = "Spoof Silver"})  

        spoof_world:Box({Name = "Silver Value", Callback = function(number)
            local future_value = tonumber(number)

            if library.flags["Spoof Silver"] and future_value then
                local currency_gui = player_gui:FindFirstChild("CurrencyGui")

                if currency_gui then
                    local silver_frame = currency_gui:FindFirstChild("Silver")

                    if silver_frame then
                        local silver_text = silver_frame:FindFirstChild("Value")

                        if silver_text then
                            local silver_frame = silver_text:FindFirstChild("Shadow")

                            if silver_frame then
                                local string_value = tostring(future_value)
                                silver_text.Text = string_value
                                silver_frame.Text = string_value
                            end
                        end
                    end
                end                
            end
        end})  
    end
end

--// automation features

do
    local automation_misc, automation_bots = sections.automation_settings, sections.bots_settings
    
    do -- anti afk
        automation_misc:Toggle({Name = "Anti AFK", Callback = function(state)
            for index, connection in next, getconnections(game.Players.LocalPlayer.Idled) do
                if state then 
                    connection:Disable()
                else 
                    connection:Enable()
                end
            end
        end})
    end 

    do -- auto bard
        local function apply_bard(character)
            local bard_gui = player.PlayerGui:WaitForChild("BardGui")
            local boosts = character:WaitForChild("Boosts")
            
            boosts.ChildAdded:Connect(function(child)
                if library.flags["Bard Stacking"] and child.Name == "MusicianBuff" then
                    task_wait()
                    child:Destroy()
                end
            end)

            bard_gui.ChildAdded:Connect(function(note)
                if library.flags["Auto Bard"] then
                    if note.ClassName == "ImageButton" then
                        local outer_ring = note:WaitForChild("OuterRing")

                        repeat 
                            wait() 
                        until outer_ring.Size.X.Offset - 35 <= note.Size.X.Offset

                        firesignal(note.MouseButton1Click)
                    end
                end
            end)
        end

        local character = player.Character or player.CharacterAdded:Wait()

        apply_bard(character)
        player.CharacterAdded:Connect(apply_bard)
        
        automation_misc:Toggle({Name = "Auto Bard"})
        automation_misc:Toggle({Name = "Bard Stacking"})
    end

    do -- auto charge
        local auto_charge = automation_misc:Toggle({Name = "Auto Charge"})
        local spell_adjust = automation_misc:Toggle({Name = "Spell Adjust"})
        local train_climb = automation_misc:Toggle({Name = "Train Climb"})
        
        automation_misc:Toggle({Name = "Snap Train"})
        automation_misc:Slider({Name = "Charge Percent", Min = 0, Max = 100, Default = 50})

        local function apply_auto_charge(character)
            local mana = character:WaitForChild("Mana")

            character.ChildAdded:Connect(function(child)
                if mana and child:IsA("Tool") then
                    local spell_cost_data = global_variables.spell_cost[child.Name]

                    if spell_cost_data then
                        local spell_info = spell_cost_data[1]
                        spell_adjust:Update((spell_info[1] + spell_info[2]) / 2)
                    end
                end
            end)
            
            task_spawn(function()
                while wait(0.1) do
                    if mana then
                        if library.flags["Auto Charge"] and mana.Value <= library.flags["Charge Percent"] and not character:FindFirstChild("ActiveCast") then
                            if library.flags["Train Climb"] then 
                                train_climb:Update(false)
                            end
                            global_variables.remotes.SetManaChargeState:FireServer({math_random(1, 10), math_random()})
                            wait(0.15 + (ping_stat:GetValue() / 900))

                            repeat 
                                task.wait()
                            until (mana.Value >= (library.flags["Charge Percent"] - 1) or not character:FindFirstChild("Charge"))

                            global_variables.remotes.SetManaChargeState:FireServer()

                            if library.flags["Snap Train"] then
                                local tool = character:FindFirstChildOfClass("Tool")

                                if tool and tool:FindFirstChild("Spell") then
                                    services.VirtualUser:ClickButton1(vector2_new.new(0, 0), camera.CFrame)
                                end
                            end
                        end
                        if library.flags["Train Climb"] then 
                            if library.flags["Auto Charge"] then 
                                auto_charge:Update(false)
                            end
                            
                            global_variables.remotes.SetManaChargeState:FireServer({math_random(1, 10), math_random()})
                            wait(0.1 + (ping_stat:GetValue() / 900))

                            repeat wait() until not character:FindFirstChild("Charge")
        
                            global_variables.remotes.SetManaChargeState:FireServer()

                            repeat
                                services.VirtualInputManager:SendKeyEvent(true, "Space", false, game) 
                                task_wait() 
                                services.VirtualInputManager:SendKeyEvent(false, "Space", false, game)
                            until mana.Value == 0 or not library.flags["Train Climb"]
                        end
                    else
                        break
                    end
                end
            end)
        end

        local character = player.Character or player.CharacterAdded:Wait()

        apply_auto_charge(character)
        player.CharacterAdded:Connect(apply_auto_charge)
    end

    do -- day farm
        local function apply_day_farm(character)
            task_spawn(function()
                while wait(1) do
                    if character then
                        if library.flags["Day Farm"]  then
                            local players_list = services.Players:GetPlayers()

                            for index = 1, #players_list do
                                local target_player = players_list[index]
                                
                                if target_player ~= player then
                                    local target_character = target_player.Character
                                    
                                    if target_character then
                                        local target_torso = target_character:FindFirstChild("Torso")
                                        
                                        if target_torso then
                                            if player:DistanceFromCharacter(target_torso.Position) <= library.flags["Day Farm Distance"] then
                                                if library.flags["Day Farm Serverhop"] then
                                                    global_functions.block_random_player()

                                                    character:Destroy()
                                                    task_wait()

                                                    player:Kick("Player Nearby")
                                                    services.TeleportService:Teleport(3016661674)
                                                    break
                                                else 
                                                    character:Destroy()
                                                    task_wait()

                                                    player:Kick("Player Nearby")
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    else
                        break
                    end
                end
            end)
        end

        local character = player.Character or player.CharacterAdded:Wait()

        apply_day_farm(character)
        player.CharacterAdded:Connect(apply_day_farm)

        automation_misc:Toggle({Name = "Day Farm"})

        automation_misc:Toggle({Name = "Day Farm Serverhop"})
        automation_misc:Slider({Name = "Day Farm Distance", Min = 50, Max = 500, Default = 200})
    end
end

--// safety features
do 
    local safety_protection = sections.safety_protection

    do -- chat logs
        local chat_logger = instance_new("ScreenGui")

        protect_gui(chat_logger)

        local rounded_frame = instance_new("Frame")

        rounded_frame.Parent = chat_logger
        rounded_frame.BackgroundColor3 = color3_fromrgb(22, 22, 22)
        rounded_frame.Position = udim2_new(0.112, 0, 0.375, 0)
        rounded_frame.Size = udim2_new(0, 350, 0, 200)
        rounded_frame.Visible = false
        rounded_frame.Draggable = true

        local scrolling_frame = instance_new("ScrollingFrame")

        scrolling_frame.Parent = rounded_frame
        scrolling_frame.Active = true
        scrolling_frame.AnchorPoint = vector2_new(0.5, 0)
        scrolling_frame.BackgroundColor3 = color3_fromrgb(255, 255, 255)
        scrolling_frame.BackgroundTransparency = 1
        scrolling_frame.BorderSizePixel = 0
        scrolling_frame.Position = udim2_new(0.515, 0, 0.085, 10)
        scrolling_frame.Size = udim2_new(0, 325, 0, 165)
        scrolling_frame.CanvasSize = udim2_new(0, 0, 0, 0)
        scrolling_frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrolling_frame.ScrollBarThickness = 0

        local chat_list_layout = instance_new("UIListLayout")

        chat_list_layout.Parent = scrolling_frame
        chat_list_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        chat_list_layout.SortOrder = Enum.SortOrder.LayoutOrder

        local chat_label = instance_new("TextLabel")
        
        chat_label.Parent = rounded_frame
        chat_label.AnchorPoint = vector2_new(0.5, 0)
        chat_label.BackgroundColor3 = color3_fromrgb(255, 255, 255)
        chat_label.BackgroundTransparency = 1
        chat_label.Position = udim2_new(0.5, 0, 0, 0)
        chat_label.Size = udim2_new(0, 0, 0, 25)
        chat_label.Font = Enum.Font.SourceSans
        chat_label.Text = "Chatlogger"
        chat_label.TextColor3 = color3_fromrgb(255, 255, 255)
        chat_label.TextSize = 20
        chat_label.TextYAlignment = Enum.TextYAlignment.Bottom

        local current_drag
        local drag_input
        local drag_start
        local start_pos
        
        rounded_frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                drag_start = input.Position
                start_pos = rounded_frame.Position
                current_drag = true
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        current_drag = false
                    end
                end)
            end
        end)
        
        rounded_frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                drag_input = input
            end
        end)
        
        services.UserInputService.InputChanged:Connect(function(input)
            if input == drag_input and current_drag then
                local Delta = input.Position - drag_start
                rounded_frame.Position = udim2_new(start_pos.X.Scale, start_pos.X.Offset + Delta.X, start_pos.Y.Scale, start_pos.Y.Offset + Delta.Y)
            end
        end)

        local function log_chat(target_player, text)
            if library.flags["Streamer Mode"] and target_player == player then
                return
            end

            local new_text = instance_new("TextButton")
            new_text.Parent = scrolling_frame
            new_text.BackgroundColor3 = color3_fromrgb(255, 255, 255)
            new_text.BackgroundTransparency = 1
            new_text.Size = udim2_new(1, 0, 0, 25)
            new_text.AutoButtonColor = false
            new_text.Font = Enum.Font.SourceSans
            new_text.TextColor3 = color3_fromrgb(255, 255, 255)
            new_text.Text = ("%s: %s"):format(target_player.Name, text)
            local old_text = ("%s: %s"):format(target_player.Name, text)

            local target_character = target_player.Character
            if target_character then
                if target_player.Backpack:FindFirstChild("Observe") or target_character:FindFirstChild("Observe") then
                    new_text.TextColor3 = color3_fromrgb(90, 149, 200)
                end
                local fake_humanoid = target_character:FindFirstChild("FakeHumanoid", true)
                if fake_humanoid then
                    local rogue_name_part = fake_humanoid.Parent
                    new_text.Text = ("%s: %s"):format(rogue_name_part.Name, text)
                    old_text = ("%s: %s"):format(rogue_name_part.Name, text)
                end
            end
            
            new_text.TextSize = 16
            new_text.TextXAlignment = Enum.TextXAlignment.Left

            new_text.MouseButton1Click:Connect(function()
                if target_player and target_player.Character and target_player.Character:FindFirstChild("Humanoid") then
                    camera.CameraSubject = target_player.Character.Humanoid
                end
            end)

            new_text.MouseEnter:Connect(function()
                new_text.Text = ("%s: %s"):format(target_player.Name, text)
            end)

            new_text.MouseLeave:Connect(function()
                new_text.Text = old_text
            end)
            
            scrolling_frame.CanvasPosition = vector2_new(0, 10000)
        end

        local players_list = services.Players:GetPlayers()

        for index = 1, #players_list do
            local target_player = players_list[index]
            
            target_player.Chatted:connect(function(message)
                log_chat(target_player, message)
            end)
        end
        
        services.Players.PlayerAdded:Connect(function(target_player)
            target_player.Chatted:connect(function(message)
                log_chat(target_player, message)
            end)
        end)

        safety_protection:Toggle({Name = "Chatlogger", Callback = function(state)
            rounded_frame.Visible = state
        end})

        local chat_object = player.PlayerGui:WaitForChild("Chat"):WaitForChild("Frame"):WaitForChild("ChatChannelParentFrame")
        
        safety_protection:Toggle({Name = "Roblox Chatlogger", Callback = function(state)
            chat_object.Visible = state
        end})
    end

    do -- notification auto close
        services.Players.PlayerRemoving:Connect(function(target_player)
            if library.flags["Auto Clear Notifications"] then
                local player_notification = global_variables.alert_notifications[target_player.Name]  

                if player_notification then 
                    player_notification:Close()
                end
            end
        end)

        safety_protection:Toggle({Name = "Auto Clear Notifications"})
    end

    do -- click spectate
        local selected_label
        local mouse_button_1 = Enum.UserInputType.MouseButton1

        services.UserInputService.InputBegan:Connect(function(input, proccessed)
            local gui_children = player.PlayerGui.LeaderboardGui.MainFrame.ScrollingFrame:GetChildren()

            for index = 1, #gui_children do
                local value = gui_children[index]

                value.MouseEnter:Connect(function()
                    selected_label = value
                end)

                value.MouseLeave:Connect(function()
                    if selected_label == value then
                        selected_label = nil
                    end
                end)
            end

            if input.UserInputType == mouse_button_1 then
                if selected_label and library.flags["Click Spectate"] then
                    local selected_text = selected_label.Text:gsub("[^%w%s_]+", "")
                    local selected_player = services.Players:FindFirstChild(selected_text)

                    if selected_player then
                        local selected_character = selected_player.Character

                        if selected_character then
                            local selected_humanoid = selected_character:FindFirstChildOfClass("Humanoid")

                            if selected_humanoid then
                                camera.CameraSubject = selected_humanoid
                            end
                        end
                    end
                else
                    local character = player.Character

                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")

                        if humanoid then
                            camera.CameraSubject = humanoid
                        end
                    end
                end
            end
        end)

        safety_protection:Toggle({Name = "Click Spectate", Callback = function(state)
            if not state then
                local camera_subject = camera.CameraSubject
                local character = player.Character 

                if character then 
                    local humanoid = character:FindFirstChildOfClass("Humanoid")

                    if humanoid then 
                        if camera_subject ~= humanoid then
                            camera.CameraSubject = humanoid
                        end
                    end 
                end
            end
        end})
    end

    do -- anticheat mode
        safety_protection:Picker({Name = "Anticheat Mode", List = {"Default", "Kick", "Block"}, Default = "Kick"})
    end

    do -- alerts
        local alert_gui = instance_new("ScreenGui")
        
        protect_gui(alert_gui)
        
        local function create_alert_gui(text)
            local notification_label = instance_new("TextLabel")
            notification_label.Parent = alert_gui
            notification_label.AnchorPoint = vector2_new(0.5, 0.55)
            notification_label.BackgroundTransparency = 1
            notification_label.Position = udim2_new(0.5, 0, 0.55, 0)
            notification_label.Font = Enum.Font.SourceSans
            notification_label.TextColor3 = color3_fromrgb(255, 255, 255)
            notification_label.Text = text
            notification_label.TextSize = 25
            notification_label.TextStrokeTransparency = 0.7
            notification_label.Visible = true

            wait(3)

            notification_label:Destroy()
        end

        local function create_alert(text)
            global_variables.alert_notifications[text:match("(.+) is a %w+")] = window:Notification({
                Type = "Confirm",
                Content = {
                    Text = text, 
                    ConfirmText = "Ignore",
                    DeclineText = "Server Hop",
                    Title = text:match(".+ is a (%w+)"):gsub("^%l", string_upper) .. " Alert"
                }, 
                Callback = function(state)
                    if not state then 
                        global_functions.block_random_player()
                        services.TeleportService:Teleport(3016661674)
                    end
                end
            })

            create_alert_gui(text)
        end

        local function perform_player_checks(target_player)
            if target_player.Character then 
                if target_player.Backpack:FindFirstChild("Observe") or target_player.Character:FindFirstChild("Observe") then 
                    create_alert(target_player.Name .. " is a illusionist!")
                end
            end

            target_player.CharacterAdded:Connect(function(character)
                character:WaitForChild("Humanoid")
                character:WaitForChild("HumanoidRootPart")

                while not character:FindFirstChild("FakeHumanoid", true) do 
                    wait()
                end

                wait(3.5)

                if character and (target_player.Backpack:FindFirstChild("Observe") or character:FindFirstChild("Observe")) then 
                    create_alert(target_player.Name .. " is a illusionist!")
                end
            end)
        end

        local players_list = services.Players:GetPlayers()

        for index = 1, #players_list do
            perform_player_checks(players_list[index])
        end

        services.Players.PlayerAdded:Connect(perform_player_checks)
    end
end
