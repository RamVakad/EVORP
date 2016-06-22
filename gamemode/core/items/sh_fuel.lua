--[[
Name: "sh_battery.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Flashlight") ) then return; end;
if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Fuel";
ITEM.size = 3;
ITEM.cost = 150;
ITEM.category = "Supplies/Misc"
ITEM.model = "models/props_junk/gascan001a.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Fuel Cans";
ITEM.uniqueID = "fuel";
ITEM.description = "Use when inside a car or while looking at a car to refuel it.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	if not (player:InVehicle()) then
		local ent = player:GetEyeTrace().Entity;
		if not (IsValid(ent)) then evorp.player.notify(player, "Aim at a car!", 1); return false end
		
		if not (ent:GetClass() == "prop_vehicle_jeep") then
			evorp.player.notify(player, "Not a car!", 1)
			return false
		else
			if (player:GetPos():Distance(player:GetEyeTrace().HitPos) > 64) then 
				evorp.player.notify(player, "Too far!", 1)
				return false
			end
			ent._Fuel = 100;
			ent:SetNetworkedInt("fuel", 100)
			evorp.player.notify(player, "Fueled!", 0)
		end
	else
		local ent = player:GetVehicle();
		if not (ent:GetClass() == "prop_vehicle_jeep") then
			evorp.player.notify(player, "Not a car!", 1)
			return false
		else
			ent._Fuel = 100;
			ent:SetNetworkedInt("fuel", 100)
			evorp.player.notify(player, "Fueled!", 0)
		end
	end
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
