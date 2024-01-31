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

local vIsPointOnRoad = false
CurrentAllowedSpeed = -1
local ZoneFlags = 0

CreateThread(function()
	local CurrentBuffer = 0
	local ZoneBuffers = {-1, -1, -1, -1}
	local LastKnownZone = -1
	while true do
		local playerPed = GetPlayerPed(-1)
		CurrentBuffer = CurrentBuffer + 1
		if CurrentBuffer > 4 then CurrentBuffer = 1 end
		local cords = GetEntityCoords(playerPed)
		Ignored1, Ignored2, ZoneFlags = GetVehicleNodeProperties(cords.x , cords.y , cords.z)
		vIsPointOnRoad = IsPointOnRoad(cords.x , cords.y , cords.z, nil)
		ZoneBuffers[CurrentBuffer] = ZoneFlags
		if (ZoneBuffers[1] == ZoneBuffers[2]) and (ZoneBuffers[1] == ZoneBuffers[3]) and (ZoneBuffers[1] == ZoneBuffers[4]) then
			local ZT = ZoneBuffers[1]
			LastKnownZone = ZoneBuffers[1]
			local CurDetectedAllowedSpeed = -1
			if ZT == 10 or ZT == 14 then CurDetectedAllowedSpeed = 30 end
			if (ZT == 2 or ZT == 3 or ZT == 6 or ZT == 11 or ZT == 13) or (ZT >= 34 and ZT < 48) then CurDetectedAllowedSpeed = 80 end
			if ZT == 66 or ZT == 82 then CurDetectedAllowedSpeed = 120 end
			if CurDetectedAllowedSpeed > -1 then
				CurrentAllowedSpeed = CurDetectedAllowedSpeed
			end
		end
		local vehicle = GetVehiclePedIsIn(playerPed, true)
		if CurrentAllowedSpeed == 30 then CurrentAllowedSpeed = 30 end
		if CurrentAllowedSpeed == 80 then CurrentAllowedSpeed = 80 end
		if CurrentAllowedSpeed == 120 then CurrentAllowedSpeed = 120 end
		Wait(50)
	end
end)
local function updateSpeedAndVehicle(ped)
    local veh = GetVehiclePedIsIn(ped, false)
    local speed = GetEntitySpeed(veh)
    if Config.Imperial == true then
        local mph = math.ceil(speed * 2.236936)
        return veh, mph
    else
        local kmh = math.ceil(speed * 3.6)
        return veh, kmh
    end
end

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
        local isInVehicle = IsPedInAnyVehicle(ped, false)
        local veh, speed
        local fuel = 0 -- default to 0 when not in a vehicle

        -- Update speed and fuel only if the player is in a vehicle
        if isInVehicle then
            veh, speed = updateSpeedAndVehicle(ped)
            fuel = GetVehicleFuelLevel(veh)
            msec = 250
        end

        -- Prepare the data for the NUI message
        local hudData = {
            action = "UpdateHud",
            health = GetEntityHealth(ped) - 100,
            armour = GetPedArmour(ped),
            hunger = Hunger,
            thirst = Thirst,
            stamina = stamina,
            air = air,
            playerId = GetPlayerServerId(PlayerId()),
            isInVehicle = isInVehicle,
        }

        -- Add vehicle-specific data if the player is in a vehicle
        if isInVehicle then
            hudData.maxSpeed = speed
            hudData.vehicleFuel = fuel
        end

        -- Send the NUI message with the data
        SendNUIMessage(hudData)

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
					Wait(100)
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
        Citizen.Wait(100)
        
        -- Convert the map object to a network ID and configure network properties
        local netid = ObjToNet(mapspawned)
        SetNetworkIdExistsOnAllMachines(netid, true)
        NetworkSetNetworkIdDynamic(netid, true)
        SetNetworkIdCanMigrate(netid, false)
        
        -- Attach the map object to the player, play the map animation, and set map_net flag
        AttachEntityToEntity(mapspawned, GetPlayerPed(PlayerId()), GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 0, true)
        TaskPlayAnim(GetPlayerPed(PlayerId()),  animDict, animName, 1.0, 1.0, -1, 50, 0, false, false, false) -- 50 = 32 + 16 + 2
        map_net = netid
        holdingMap = true
    else
        ClearPedTasks(GetPlayerPed(PlayerId()))
        Citizen.Wait(500)
        -- Clear the map attachment and delete the map object, reset map_net and holdingMap flags
        ClearPedSecondaryTask(GetPlayerPed(PlayerId()))
        DetachEntity(NetToObj(map_net), true, true)
        DeleteEntity(NetToObj(map_net))
        map_net = 0
        holdingMap = false
    end
end)


