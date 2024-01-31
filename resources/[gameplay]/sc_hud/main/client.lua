

Citizen.CreateThread(function()
	-- Request minimap Scaleform movie each time to ensure it's loaded
	local minimap = RequestScaleformMovie('minimap')
    -- Enable and disable the bigmap to refresh the minimap state
	SetRadarBigmapEnabled(true, false)
    Citizen.Wait(0)
    SetRadarBigmapEnabled(false, false)
    while true do
        while not HasScaleformMovieLoaded(minimap) do
			Citizen.Wait(100)
		end
        Citizen.Wait(100)
        -- Check if the minimap Scaleform movie is loaded
        if HasScaleformMovieLoaded(minimap) then
            BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
            ScaleformMovieMethodAddParamInt(3)
            EndScaleformMovieMethod()
        else
            -- If not loaded, request it again
            minimap = RequestScaleformMovie('minimap')
        end
    end
end)

CreateThread(function()
    while true do
        local msec = 1000;
        local ped = PlayerPedId()

        local stamina = GetPlayerSprintStaminaRemaining(PlayerId())
        local air = GetPlayerUnderwaterTimeRemaining(PlayerId())

        TriggerEvent('esx_status:getStatus', 'hunger', function(status) 
            Hunger = status.val / 10000 
        end)
        TriggerEvent('esx_status:getStatus', 'thirst', function(status) 
            Thirst = status.val / 10000 
        end)

        SendNUIMessage({
            action = "UpdateHud";
            health = GetEntityHealth(ped) - 100;
            armour = GetPedArmour(ped);
            hunger = Hunger;
            thirst = Thirst;
            stamina = stamina;
            air = air;
            playerId = GetPlayerServerId(PlayerId());
        })

        Wait(msec)
    end
end)


local wasmenuopen = false

Citizen.CreateThread(function()
	while true do
			Wait(0)
			if IsPauseMenuActive() and not wasmenuopen then
					SetCurrentPedWeapon(GetPlayerPed(-1), 0xA2719263, true) -- set unarmed
					TriggerEvent("Map:ToggleMap")
					--TaskStartScenarioInPlace(GetPlayerPed(-1), "WORLD_HUMAN_TOURIST_MAP", 0, false) -- Start the scenario
					wasmenuopen = true
			end
			
			if not IsPauseMenuActive() and wasmenuopen then
					Wait(2000)
					TriggerEvent("Map:ToggleMap")
					wasmenuopen = false
			end
	end
end)

local holdingMap = false
local mapModel = "prop_tourist_map_01"
local animDict = "amb@world_human_tourist_map@male@base"
local animName = "base"
local map_net = 0


-- Register and handle the ToggleMap event
RegisterNetEvent("Map:ToggleMap")
AddEventHandler("Map:ToggleMap", function()
    -- Check if the map is not already being held
    if not holdingMap then
        -- Request the model for the map object
        RequestModel(GetHashKey(mapModel))
        while not HasModelLoaded(GetHashKey(mapModel)) do
            Citizen.Wait(100)
        end

        -- Request the animation dictionary for the map animation
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(100)
        end

        -- Get the player's coordinates and create the map object
        local plyCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
        local mapspawned = CreateObject(GetHashKey(mapModel), plyCoords.x, plyCoords.y, plyCoords.z, true, true, true)
        Citizen.Wait(1000)
        
        -- Convert the map object to a network ID and configure network properties
        local netid = ObjToNet(mapspawned)
        SetNetworkIdExistsOnAllMachines(netid, true)
        NetworkSetNetworkIdDynamic(netid, true)
        SetNetworkIdCanMigrate(netid, false)
        
        -- Attach the map object to the player, play the map animation, and set map_net flag
        AttachEntityToEntity(mapspawned, GetPlayerPed(PlayerId()), GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 0, true)
        TaskPlayAnim(GetPlayerPed(PlayerId()),  animDict, animName, 1.0, -1, -1, 50, 0, false, false, false) -- 50 = 32 + 16 + 2
        map_net = netid
        holdingMap = true
    else
        -- Clear the map attachment and delete the map object, reset map_net and holdingMap flags
        ClearPedSecondaryTask(GetPlayerPed(PlayerId()))
        DetachEntity(NetToObj(map_net), true, true)
        DeleteEntity(NetToObj(map_net))
        map_net = 0
        holdingMap = false
    end
end)
