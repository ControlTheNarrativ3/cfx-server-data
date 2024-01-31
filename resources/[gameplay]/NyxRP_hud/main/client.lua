
local textFont = 4
local textProportional = 0
local textDropShadow = 0
local textEdge = 2
local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function drawTxt(x, y, width, height, scale, text, r, g, b, a)
    SetTextFont(textFont)
    SetTextProportional(textProportional)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextEdge(textEdge, 0, 0, 0, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.5)
end

local function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.5)
end

local function drawRct(x,y,width,height,r,g,b,a)
	DrawRect(x + width/2, y + height/2, width, height, r, g, b, a)
end


local function DrawAdvancedText(x,y ,w,h,sc, text, r,g,b,a,font,jus)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(sc, sc)
	N_0x4e096588b13ffeca(jus)
	SetTextColour(r, g, b, a)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x - 0.1+w, y - 0.02+h)
end
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

local mph
local kmh
local fuel
local displayHud = false
local x = 0.01135
local y = 0.02
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(150)
		local ped = PlayerPedId()
		if IsPedInAnyVehicle(ped, false) then
			local vehicle = GetVehiclePedIsIn(ped, false)
			local speed = GetEntitySpeed(vehicle)
			if Config.Imperial == true then
				mph = tostring(math.ceil(speed * 2.236936))
			else
				kmh = tostring(math.ceil(speed * 3.6))
			end
			fuel = tostring(math.ceil(GetVehicleFuelLevel(vehicle)))
			displayHud = true
		else
			displayHud = false
			Citizen.Wait(1500)
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
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		if CurrentAllowedSpeed == 30 then
		end
		if CurrentAllowedSpeed == 80 then
		end
		if CurrentAllowedSpeed == 120 then
		end
		Wait(100)
	end
end)


Citizen.CreateThread(function()
	local ped = GetPlayerPed(-1) -- get the player ped
	local veh = GetVehiclePedIsIn(ped, false) -- get the vehicle the player is in
	local vehClass = GetVehicleClass(veh) -- get the class of the vehicle
	local speed = GetEntitySpeed(veh) * 3.6 -- get the speed of the vehicle in km/h

	while true do
		Citizen.Wait(0)

		if displayHud then
			if Config.Imperial == true then
				DrawAdvancedText(0.300 - x, 0.900 - y, 0.005, 0.0028, 0.6, mph, 255, 255, 255, 255, 6, 1)
				DrawAdvancedText(0.335 - x, 0.920 - y, 0.005, 0.0028, 0.6, fuel, 255, 255, 255, 255, 6, 1)
				DrawAdvancedText(0.280 - x, 0.930 - y, 0.005, 0.0028, 0.4, "mph          Fuel", 255, 255, 255, 255, 6, 1)
			else
				-- check if the speed is above CurrentAllowedSpeed
				if speed > CurrentAllowedSpeed * 1.7 then
					DrawAdvancedText(0.362 - x, 0.935 - y, 0.005, 0.0098, 0.3, kmh .. " KM/H", 255, 0, 0, 200, 7, 1)
				elseif speed > CurrentAllowedSpeed then
					DrawAdvancedText(0.362 - x, 0.935 - y, 0.005, 0.0098, 0.3, kmh .. " KM/H", 255, 150, 55, 255, 7, 1)
				else
					DrawAdvancedText(0.362 - x, 0.935 - y, 0.005, 0.0098, 0.3, kmh .. " KM/H", 255, 255, 255, 255, 7, 1)
				end

				DrawAdvancedText(0.330 - x, 0.935 - y, 0.005, 0.0098, 0.3, "Speed: ", 255, 255, 255, 255, 7, 1)
				DrawAdvancedText(0.280 - x, 0.935 - y, 0.005, 0.0098, 0.3, " Fuel: " .. fuel, 255, 255, 255, 255, 7, 1)
				DrawAdvancedText(0.280 - x, 0.999 - y, 0.005, 0.0098, 0.25, " Speed Limit: " .. CurrentAllowedSpeed .. " km/h", 255, 255, 255, 255, 7, 1)
			end
		else
			Citizen.Wait(150)
		end
	end
end)