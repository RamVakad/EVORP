--[[
Name: "sh_chinese.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Hunger") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Bait Box";
ITEM.size = 1;
ITEM.cost = 720;
ITEM.category = "Supplies/Misc"
ITEM.model = "models/props_lab/box01a.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Bait Boxes";
ITEM.uniqueID = "bait";
ITEM.description = "Bait required to go fishing.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	player:GiveAmmo(6, "HelicopterGun");
	return true;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
