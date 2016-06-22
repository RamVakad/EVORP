--[[
Name: "sh_police_car.lua".
Product: "EvoRP (Roleplay)".
--]]
 
if ( !evorp.plugin.get("Generic") ) then return; end;
 
-- Define the item table.
local ITEM = {};
 
-- Set some information about the item.
ITEM.name = "Police Car";
ITEM.size = 5;
ITEM.cost = 4000;
ITEM.model = "models/LoneWolfie/chev_impala_09.mdl"
ITEM.skin = 6;
ITEM.batch = 1;
ITEM.store = true;
ITEM.plural = "Police Car's";
ITEM.uniqueID = "volvo_s60_pol";
ITEM.description = "A police car exclusive to law enforcers.";
ITEM.class = true;
ITEM.category = "Vehicles"; 


function ITEM:onUse(player)
	if (player:Team() == TEAM_OFFICER or player:Team() == TEAM_COMMANDER or player:Team() == TEAM_HOSS or player:Team() == TEAM_SS) then
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