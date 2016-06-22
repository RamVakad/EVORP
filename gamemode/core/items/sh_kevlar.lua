--[[
Name: "sh_kevlar.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Kevlar";
ITEM.size = 2;
ITEM.cost = 1500;
ITEM.category = "Black Market"
ITEM.model = "models/props_c17/suitcase_passenger_physics.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Kevlars";
ITEM.uniqueID = "kevlar";
ITEM.description = "Reduces damage the player receives by 50%.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	if (player._ScaleDamage == 0.5) then
		evorp.player.notify(player, "You are already wearing Kevlar!", 1);
		
		-- Return false because we cannot use the item.
		return false;
	else
		player._ScaleDamage = 0.5;
	end;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
