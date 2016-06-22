--[[
Name: "sh_crowbar.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Hostage Rope";
ITEM.size = 1;
ITEM.cost = 2500;
ITEM.model = "models/als/ROPE/w_ropel.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.category = "Supplies/Misc";
ITEM.plural = "Hostage Ropes";
ITEM.uniqueID = "evorp_rope";
ITEM.description = "A hostage rope, can be used to free people from handcuffs too.";

function ITEM:onUse(player)
    if (player:Team() == TEAM_OFFICER or player:Team() == TEAM_COMMANDER or player:Team() == TEAM_SS or player:Team() == TEAM_HOSS) then
        evorp.player.notify(player, "You can't use this!", 1);
        return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
evorp.item.register(ITEM);
