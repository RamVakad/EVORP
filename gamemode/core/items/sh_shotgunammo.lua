--[[
Name: "sh_chinese.lua".
Product: "EvoRP (Roleplay)".
--]]

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Shotgun Ammunition";
ITEM.size = 1;
ITEM.cost = 200;
ITEM.category = "Weaponry"
ITEM.model = "models/items/boxbuckshot.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Shotgun Ammunition";
ITEM.uniqueID = "shotammo";
ITEM.description = "Sixteen buckshot shells.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	player:GiveAmmo(16, "buckshot");
	return true;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;
-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
