-- Variables
local directions = {
  N = 360, 0,
  NE = 315,
  E = 270,
  SE = 225,
  S = 180,
  SW = 135,
  W = 90,
  NW = 45,
}
-- define the texture dictionary and texture name for the circle sprite
local textureDict = "commonmenu"
local textureName = "header_gradient_script"
-- load the texture dictionary
RequestStreamedTextureDict(textureDict, true)
while not HasStreamedTextureDictLoaded(textureDict) do
    Citizen.Wait(0)
end
local veh = 0;
-- define the position, size, color, and rotation of the circle sprite
local screenX = 0.255 -- screen offset (0.5 = center)
local screenY = 0.945 -- screen offset (0.5 = center)
local width = 0.18 -- texture scaling (0.1 = 10% of the screen width)
local height = 0.09 -- texture scaling (0.1 = 10% of the screen height)
local red = 255 -- sprite color (255 = maximum red)
local green = 255 -- sprite color (0 = minimum green)
local blue = 255 -- sprite color (0 = minimum blue)
local alpha = 255 -- opacity level (255 = fully opaque)
local heading = 0.4 -- texture rotation in degrees (0.0 = no rotation)

Citizen.CreateThread(function()
	while true do
		local ped = GetPlayerPed(-1);
		veh = GetVehiclePedIsIn(ped, false);
    if IsPedInAnyVehicle(ped, false) then
      DrawSprite(textureDict, textureName, screenX, screenY, width, height, heading, red, green, blue, alpha)
    end
    Citizen.Wait(0)
  end
end)

Citizen.CreateThread(function()
	while true do
		local ped = GetPlayerPed(-1);
		veh = GetVehiclePedIsIn(ped, false);

		local coords = GetEntityCoords(ped);
		local zone = GetNameOfZone(coords.x, coords.y, coords.z);

		local var1, var2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
    local hash1 = GetStreetNameFromHashKey(var1);
		local hash2 = GetStreetNameFromHashKey(var2);
		local heading = GetEntityHeading(PlayerPedId());
		
    for k, v in pairs(directions) do
      if (math.abs(heading - v) < 22.5) then
        heading = k;
    
        if (heading == 1) then
          heading = 'N';
          break;
        end

        break;
      end
    end

    local street2;
    if (hash2 == '') then
      street2 = GetLabelText(zone);
    else
      street2 = hash2..', '..GetLabelText(zone);
    end

    local configColor;
    if (config.color) then
      configColor = 'rgb('..config.color.r..', '..config.color.g..', '..config.color.b..')'
    else
      configColor = 'rgb(240,200,80)'
    end

    if (config.position.x == nil or config.position.x == '') then config.position.x = 17.55 end
    if (config.position.y == nil or config.position.y == '') then config.position.y = 3 end
    
    if (config.vehicleCheck == false) then
			SendNUIMessage({
				type = 'open',
				active = true,
        color = configColor,
				direction = heading,
        posX = config.position.x,
        posY = config.position.y,
				street = hash1,
				zone = street2
			})
		else
			if (veh ~= 0) then
        SendNUIMessage({
          type = 'open',
          active = true,
          color = configColor,
          direction = heading,
          posX = config.position.x,
          posY = config.position.y,
          street = hash1,
          zone = street2
        })
      else
        SendNUIMessage({
          type = 'open',
          active = false
        })
      end
		end
		
		Citizen.Wait(500); -- 1s delay
	end
end)

local mph
local kmh
local fuel
local displayHud = false
local x = 0.01135
local y = 0.02
local imperial = false
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(80)
		local ped = PlayerPedId()
		if IsPedInAnyVehicle(ped,false) then
			local vehicle = GetVehiclePedIsIn(ped,false)
			local speed = GetEntitySpeed(vehicle)
			if imperial == true then
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
