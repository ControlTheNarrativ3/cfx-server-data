if not lib then return end

local Items = require 'modules.items.shared' --[[@as table<string, OxClientItem>]]

local function sendDisplayMetadata(data)
    SendNUIMessage({
		action = 'displayMetadata',
		data = data
	})
end

--- use array of single key value pairs to dictate order
---@param metadata string | table<string, string> | table<string, string>[]
---@param value? string
local function displayMetadata(metadata, value)
	local data = {}

	if type(metadata) == 'string' then
        if not value then return end

        data = { { metadata = metadata, value = value } }
	elseif table.type(metadata) == 'array' then
		for i = 1, #metadata do
			for k, v in pairs(metadata[i]) do
				data[i] = {
					metadata = k,
					value = v,
				}
			end
		end
	else
		for k, v in pairs(metadata) do
			data[#data + 1] = {
				metadata = k,
				value = v,
			}
		end
	end

    if client.uiLoaded then
        return sendDisplayMetadata(data)
    end

    CreateThread(function()
        repeat Wait(100) until client.uiLoaded

        sendDisplayMetadata(data)
    end)
end

exports('displayMetadata', displayMetadata)

---@param _ table?
---@param name string?
---@return table?
local function getItem(_, name)
    if not name then return Items end

	if type(name) ~= 'string' then return end

    name = name:lower()

    if name:sub(0, 7) == 'weapon_' then
        name = name:upper()
    end

    return Items[name]
end

setmetatable(Items --[[@as table]], {
	__call = getItem
})

---@cast Items +fun(itemName: string): OxClientItem
---@cast Items +fun(): table<string, OxClientItem>

local function Item(name, cb)
	local item = Items[name]
	if item then
		if not item.client?.export and not item.client?.event then
			item.effect = cb
		end
	end
end

local ox_inventory = exports[shared.resource]
-----------------------------------------------------------------------------------------------
-- Clientside item use functions
-----------------------------------------------------------------------------------------------

Item('bandage', function(data, slot)
	local maxHealth = GetEntityMaxHealth(cache.ped)
	local health = GetEntityHealth(cache.ped)
	ox_inventory:useItem(data, function(data)
		if data then
			SetEntityHealth(cache.ped, math.min(maxHealth, math.floor(health + maxHealth / 16)))
			lib.notify({ description = 'You feel better already' })
		end
	end)
end)

Item('armour', function(data, slot)
	if GetPedArmour(cache.ped) < 100 then
		ox_inventory:useItem(data, function(data)
			if data then
				SetPlayerMaxArmour(PlayerData.id, 100)
				SetPedArmour(cache.ped, 100)
			end
		end)
	end
end)

client.parachute = false
Item('parachute', function(data, slot)
	if not client.parachute then
		ox_inventory:useItem(data, function(data)
			if data then
				local chute = `GADGET_PARACHUTE`
				SetPlayerParachuteTintIndex(PlayerData.id, -1)
				GiveWeaponToPed(cache.ped, chute, 0, true, false)
				SetPedGadget(cache.ped, chute, true)
				lib.requestModel(1269906701)
				client.parachute = CreateParachuteBagObject(cache.ped, true, true)
				if slot.metadata.type then
					SetPlayerParachuteTintIndex(PlayerData.id, slot.metadata.type)
				end
			end
		end)
	end
end)

Item('phone', function(data, slot)
	local success, result = pcall(function()
		return exports.npwd:isPhoneVisible()
	end)

	if success then
		exports.npwd:setPhoneVisible(not result)
	end
end)

Item('clothing', function(data, slot)
	local metadata = slot.metadata

	if not metadata.drawable then return print('Clothing is missing drawable in metadata') end
	if not metadata.texture then return print('Clothing is missing texture in metadata') end

	if metadata.prop then
		if not SetPedPreloadPropData(cache.ped, metadata.prop, metadata.drawable, metadata.texture) then
			return print('Clothing has invalid prop for this ped')
		end
	elseif metadata.component then
		if not IsPedComponentVariationValid(cache.ped, metadata.component, metadata.drawable, metadata.texture) then
			return print('Clothing has invalid component for this ped')
		end
	else
		return print('Clothing is missing prop/component id in metadata')
	end

	ox_inventory:useItem(data, function(data)
		if data then
			metadata = data.metadata

			if metadata.prop then
				local prop = GetPedPropIndex(cache.ped, metadata.prop)
				local texture = GetPedPropTextureIndex(cache.ped, metadata.prop)

				if metadata.drawable == prop and metadata.texture == texture then
					return ClearPedProp(cache.ped, metadata.prop)
				end

				-- { prop = 0, drawable = 2, texture = 1 } = grey beanie
				SetPedPropIndex(cache.ped, metadata.prop, metadata.drawable, metadata.texture, false);
			elseif metadata.component then
				local drawable = GetPedDrawableVariation(cache.ped, metadata.component)
				local texture = GetPedTextureVariation(cache.ped, metadata.component)

				if metadata.drawable == drawable and metadata.texture == texture then
					return -- item matches (setup defaults so we can strip?)
				end

				-- { component = 4, drawable = 4, texture = 1 } = jeans w/ belt
				SetPedComponentVariation(cache.ped, metadata.component, metadata.drawable, metadata.texture, 0);
			end
		end
	end)
end)

-----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------- 
-- USABLES: ammo cases

Item('box_ammo_22', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:box_ammo_22()
	end)
end)

Item('box_ammo_38', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:box_ammo_38()
	end)
end)

Item('box_ammo_44', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:box_ammo_44()
	end)
end)

Item('box_ammo_45', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:box_ammo_45()
	end)
end)

Item('box_ammo_50', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:box_ammo_50()
	end)
end)

Item('box_ammo_9', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:box_ammo_9()
	end)
end)

Item('box_ammo_556m', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:box_ammo_556m()
	end)
end)

Item('box_ammo_762m', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:box_ammo_762m()
	end)
end)

Item('box_ammo_12g', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:box_ammo_12g()
	end)
end)

Item('box_ammo_76251m', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:box_ammo_76251m()
	end)
end)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------- 
-- USABLES: alcohol crates

Item('box_bourgeoix_liquor', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:box_bourgeoix_liquor()
	end)
end)

Item('box_rancho_beer', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:box_rancho_beer()
	end)
end)

Item('box_dusche_beer', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:box_dusche_beer()
	end)
end)

Item('box_blarny_beer', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:box_blarny_beer()
	end)
end)

Item('box_patriot_beer', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:box_patriot_beer()
	end)
end)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------- 
-- USABLES: miliary items

Item('mre_1', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:mrepack()
	end)
end)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------- 
-- USABLES: police items

Item('riotshield', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:riotshield()
	end)
end)

Item('badge_fib', function(data, slot)
	local pos = GetEntityCoords(GetPlayerPed(-1))
    local rped = GetRandomPedAtCoord(pos['x'], pos['y'], pos['z'], 20.05, 20.05, 20.05, 6, _r)
	ox_inventory:useItem(data, function(data)
		if DoesEntityExist(rped) then
            TaskReactAndFleePed(rped, PlayerPedId())
        end
	end)
end)

Item('badge_lspd', function(data, slot)
	local pos = GetEntityCoords(GetPlayerPed(-1))
    local rped = GetRandomPedAtCoord(pos['x'], pos['y'], pos['z'], 20.05, 20.05, 20.05, 6, _r)
	ox_inventory:useItem(data, function(data)
		if DoesEntityExist(rped) then
            TaskReactAndFleePed(rped, PlayerPedId())
        end
	end)
end)

Item('badge_bcso', function(data, slot)
	local pos = GetEntityCoords(GetPlayerPed(-1))
    local rped = GetRandomPedAtCoord(pos['x'], pos['y'], pos['z'], 20.05, 20.05, 20.05, 6, _r)
	ox_inventory:useItem(data, function(data)
		if DoesEntityExist(rped) then
            TaskReactAndFleePed(rped, PlayerPedId())
        end
	end)
end)

Item('badge_lssd', function(data, slot)
	local pos = GetEntityCoords(GetPlayerPed(-1))
    local rped = GetRandomPedAtCoord(pos['x'], pos['y'], pos['z'], 20.05, 20.05, 20.05, 6, _r)
	ox_inventory:useItem(data, function(data)
		if DoesEntityExist(rped) then
            TaskReactAndFleePed(rped, PlayerPedId())
        end
	end)
end)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------- 
-- USABLES: medical items

Item('bandage', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:bandage()
	end)
end)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------- 
-- USABLES: vehicle items

Item('vehkit_repair', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:vehkit_repair()
	end)
end)

Item('vehkit_clean', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:vehkit_clean()
	end)
end)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------- 
-- USABLES: social items

Item('cig_69brand', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:smoke_cigarette()
	end)
end)

Item('cig_redwood', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:smoke_cigarette()
	end)
end)

Item('cig_debonaire', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:smoke_cigarette()
	end)
end)

Item('cigar', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:smoke_cigar()
	end)
end)

Item('vape', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:smoke_vape()
	end)
end)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------- 
-- USABLES: drug items

Item('weed_sativa', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:weed_sativa()
	end)
end)

Item('weed_indica', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:weed_indica()
	end)
end)

Item('weed_hybrid', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:weed_hybrid()
	end)
end)

Item('crack_cocaine', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:crack_cocaine()
	end)
end)

Item('crack_rocks', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:crack_rocks()
	end)
end)

Item('pill_ecstasy', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:pill_ecstasy()
	end)
end)

Item('pill_molly', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:pill_molly()
	end)
end)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------- 
-- USABLES: crime items

Item('bomb_exps', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:bomb_exps()
	end)
end)

Item('bomb_gas', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:bomb_gas()
	end)
end)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------- 
-- USABLES: tool items

Item('divegear', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:divegear()
	end)
end)

Item('clothing_bag', function(data, slot)
	ox_inventory:useItem(data, function(data)
		TriggerEvent('ox_appearance:wardrobe')
	end)
end)

Item('armor_l1', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:armor_l1()
	end)
end)

Item('armor_l2', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:armor_l2()
	end)
end)

Item('armor_l3', function(data, slot)
	ox_inventory:useItem(data, function(data)
		exports['mi_utils']:armor_l3()
	end)
end)
----------------------------------------------------------------------------------------------------

exports('Items', function(item) return getItem(nil, item) end)
exports('ItemList', function(item) return getItem(nil, item) end)

return Items
