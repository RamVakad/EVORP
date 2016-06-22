--[[
Name: "sh_drug_lab.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;
if ( !evorp.configuration["Contraband"]["evorp_drug_lab"] ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Drug Lab";
ITEM.size = 3;
ITEM.cost = 350;
ITEM.category = "Contraband"
ITEM.model = "models/props_lab/crematorcase.mdl";
ITEM.batch = 1;
ITEM.store = true;
ITEM.plural = "Drug Labs";
ITEM.uniqueID = "drug_lab";
ITEM.description = "A drug lab that earns you money over time.";


function ITEM:onUse(player)
     if evorp.team.query(player:Team(), "radio", "") == "R_GOV" then
        evorp.player.notify(player, "You're a part of the government!", 1);
        return false;
    end
	if (player:GetCount("druglabs") == evorp.configuration["Contraband"]["evorp_drug_lab"].maximum) then
		evorp.player.notify(player, "You have reached the maximum drug labs!", 1);
		
		-- Return false because we're reached the maximum drug labs.
		return false;
	else
		local item = ents.Create("evorp_drug_lab");
		local position = (player:GetPos() + player:GetForward() * 64) + Vector(0,0,64)
		-- Set the position and player of the drug lab.
		item:SetPos(position);
		item:SetPlayer(player);
		
		-- Set the unique ID of the drug lab.
		item._UniqueID = player:UniqueID();
		
		-- Spawn the item.
		item:Spawn();
		
		-- Increase the player's drug labs.
		player:AddCount("druglabs", item);
		
		-- Take away the item from the player.
		evorp.inventory.update(player, "drug_lab", -1);
		item:CPPISetOwner(player)
		-- Return false because we're going to handle this ourself.
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position)

end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Called when a player attempts to manufacture an item.
function ITEM:canManufacture(player)
	if (player:GetCount("druglabs") == evorp.configuration["Contraband"]["evorp_drug_lab"].maximum) then
		evorp.player.notify(player, "You have reached the maximum drug labs!", 1);
		
		-- Return false because we're reached the maximum drug labs.
		return false;
	end;
end;

-- Register the item.
evorp.item.register(ITEM);
