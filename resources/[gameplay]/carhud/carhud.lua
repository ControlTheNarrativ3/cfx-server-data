
local MyPed = GetPlayerPed(-1)

-- define the texture dictionary and texture name for the circle sprite
local textureDict = "3dtextures"
local textureName = "mpgroundlogo_cops"

-- load the texture dictionary
RequestStreamedTextureDict(textureDict, true)
while not HasStreamedTextureDictLoaded(textureDict) do
    Citizen.Wait(0)
end



local textFont = 4
local textProportional = 0
local textDropShadow = 0
local textEdge = 2
function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function drawTxt(x, y, width, height, scale, text, r, g, b, a)
    SetTextFont(textFont)
    SetTextProportional(textProportional)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextEdge(textEdge, 0, 0, 0, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.5)
end

function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
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

function drawRct(x,y,width,height,r,g,b,a)
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

local mph
local kmh
local fuel
local displayHud = false
local x = 0.01135
local y = 0.02
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(80)
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
			Citizen.Wait(750)
		end
	end
end)
