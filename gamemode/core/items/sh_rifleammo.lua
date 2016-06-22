--[[
Name: "sh_chinese.lua".
Product: "EvoRP (Roleplay)".
--]]

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Rifle Ammunition";
ITEM.size = 1;
ITEM.cost = 200;
ITEM.category = "Weaponry"
ITEM.model = "models/weapons/unloaded/rif_m4a1_mag.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Rifle Ammunition";
ITEM.uniqueID = "rifleammo";
ITEM.description = "30 rifle rounds.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	player:GiveAmmo(30, "smg1");
	return true;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;
-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
