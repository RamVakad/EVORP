--[[
Name: "sh_kevlar.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Hotwire Kit";
ITEM.size = 2;
ITEM.cost = 750;
ITEM.category = "Black Market"
ITEM.model = "models/props_c17/tools_wrench01a.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Hotwire Kits";
ITEM.uniqueID = "hotwire";
ITEM.description = "Use this inside a car to force start it.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	if not (IsValid(player:GetVehicle()) and player:GetVehicle():GetClass() == "prop_vehicle_jeep") then
		evorp.player.notify(player, "You are not in a car!", 1);
		return false;
	end
	local veh = player:GetVehicle();
	if (veh:GetNetworkedBool("HotWired")) then
		evorp.player.notify(player, "This car is already hot wired!", 0);
		return false;
	end
	timer.Simple(1, function()
		if (IsValid(player:GetVehicle()) and player:GetVehicle() == veh) then
			evorp.command.ConCommand(player, "me breaks the ignition shaft.");
		else
			return false;
		end
	end)
	timer.Simple(2.5, function()
		if (IsValid(player:GetVehicle()) and player:GetVehicle() == veh) then
			evorp.command.ConCommand(player, "me attempts to hotwire the vehicle.");
		else
			return false;
		end
	end)
	timer.Simple(3, function()
		if (IsValid(player:GetVehicle()) and player:GetVehicle() == veh) then
			evorp.command.ConCommand(player, "me successfully force ignites the engine of the car.");
			veh:SetNetworkedBool("HotWired", true)
			veh:Fire("TurnOn", "" , 0);
		else
			return false;
		end
	end)
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
