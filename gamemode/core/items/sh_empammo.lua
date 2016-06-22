--[[
Name: "sh_chinese.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Hunger") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "EMP Ammunition";
ITEM.size = 1;
ITEM.cost = 500;
ITEM.category = "Black Market"
ITEM.model = "models/Items/combine_rifle_ammo01.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "EMP Ammunition";
ITEM.uniqueID = "empammo";
ITEM.description = "Ammunition for the portable EMP.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	player:GiveAmmo(6, "Gravity");
	return true;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
