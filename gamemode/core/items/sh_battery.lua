--[[
Name: "sh_battery.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Flashlight") ) then return; end;
if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Battery";
ITEM.size = 2;
ITEM.cost = 100;
ITEM.category = "Supplies/Misc"
ITEM.model = "models/items/car_battery01.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Batteries";
ITEM.uniqueID = "battery";
ITEM.description = "Gives the player unlimited flashlight power.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	if (player._Flashlight == -1) then
		evorp.player.notify(player, "You are already using a battery!", 1);
		
		-- Return false because we cannot use the item.
		return false;
	else
		player._Flashlight = -1;
	end;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
