--[[
Name: "sh_chinese.lua".
Product: "EvoRP (Roleplay)".
--]]

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Sniper/Tranq Ammunition";
ITEM.size = 1;
ITEM.cost = 250;
ITEM.category = "Weaponry"
ITEM.model = "models/weapons/unloaded/snip_awp_mag.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Sniper/Tranq Ammunition";
ITEM.uniqueID = "snipammo";
ITEM.description = "10 sniper rifle bullets.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	player:GiveAmmo(10, "sniperround");
	return true;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;
-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
