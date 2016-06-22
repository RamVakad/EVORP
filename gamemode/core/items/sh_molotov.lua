--[[
Name: "sh_weapon_crowbar.lua".
Product: "evorp (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Molotov";
ITEM.size = 1;
ITEM.cost = 2000;
ITEM.model = "models/props_junk/garbage_glassbottle003a.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.plural = "Molotovs";
ITEM.uniqueID = "evorp_molotov";
ITEM.description = "Great for starting small fires.";
ITEM.category = "Black Market";

-- Called when a player uses the item.
function ITEM:onUse(player)
    if evorp.team.query(player:Team(), "radio", "") == "R_GOV" then
        evorp.player.notify(player, "You can't use this weapon!", 1);
        return false;
    end
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);