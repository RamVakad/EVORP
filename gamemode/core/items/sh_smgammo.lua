--[[
Name: "sh_chinese.lua".
Product: "EvoRP (Roleplay)".
--]]

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Pistol/SMG Ammunition";
ITEM.size = 1;
ITEM.cost = 125;
ITEM.category = "Weaponry"
ITEM.model = "models/weapons/unloaded/smg_mp5_mag.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Pistol/SMG Ammunition";
ITEM.uniqueID = "smgammo";
ITEM.description = "Thirty pistol rounds.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	player:GiveAmmo(30, "pistol");
	return true;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
