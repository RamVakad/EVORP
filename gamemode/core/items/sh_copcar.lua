--[[
Name: "sh_police_car.lua".
Product: "EvoRP (Roleplay)".
--]]
 
if ( !evorp.plugin.get("Generic") ) then return; end;
 
-- Define the item table.
local ITEM = {};
 
-- Set some information about the item.
ITEM.name = "Advanced Police Car";
ITEM.size = 5;
ITEM.cost = 7500;
ITEM.model = "models/sentry/taurussho.mdl"
ITEM.skin = 4;
ITEM.batch = 1;
ITEM.store = true;
ITEM.plural = "Secret Service Car's";
ITEM.uniqueID = "r34tdmcop";
ITEM.description = "A police car exclusive to the secret service w/ Photon Lighting.";
ITEM.class = true;
ITEM.category = "Vehicles"; 


function ITEM:onUse(player)
	if (player:Team() == TEAM_COMMANDER or player:Team() == TEAM_OFFICER or player:Team() == TEAM_SS or player:Team() == TEAM_HOSS) then
		return true
	else
		evorp.player.notify(player, "You can't spawn this vehicle.", 1);
		return false
	end
end

function ITEM:onPickup() end;

function ITEM:onDrop() end;

function ITEM:onSell() end;

-- Register the item.
evorp.item.register(ITEM);
