--[[
Name: "sh_chinese.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Hunger") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Alcoholic Beverage";
ITEM.size = 1;
ITEM.cost = 35;
ITEM.category = "Food"
ITEM.model = "models/props_junk/garbage_glassbottle003a.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Alcoholic Beverages";
ITEM.uniqueID = "alcohol";
ITEM.description = "Alcoholic beverage which restores 20 hunger, but you might feel a bit tipsy!";

-- Called when a player uses the item.
function ITEM:onUse(player)
	player._Hunger.amount = math.Clamp(player._Hunger.amount - 20, 0, 100);
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
