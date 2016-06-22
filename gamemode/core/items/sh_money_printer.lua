--[[
Name: "sh_money_printer.lua".
Product: "EvoRP (Roleplay)".
--]]

if ( !evorp.plugin.get("Generic") ) then return; end;
if ( !evorp.configuration["Contraband"]["evorp_money_printer"] ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Money Printer";
ITEM.size = 3;
ITEM.cost = 750;
ITEM.category = "Contraband"
ITEM.model = "models/evorp/moneyprinter/moneyprinterrrr.mdl";
ITEM.batch = 1;
ITEM.store = true;
ITEM.plural = "Money Printers";
ITEM.uniqueID = "money_printer";
ITEM.description = "A money printer that earns you money over time.";


function ITEM:onUse(player)
	if evorp.team.query(player:Team(), "radio", "") == "R_GOV" then
        evorp.player.notify(player, "You're a part of the government!", 1);
        return false;
    end
    	local max = evorp.configuration["Contraband"]["evorp_money_printer"].maximum;
    	if (player.evorp._Donator > os.time()) then max = max + 1; end
	if (player:GetCount("moneyprinters") == max) then
		evorp.player.notify(player, "You have reached the maximum money printers!", 1);
		
		-- Return false because we're reached the maximum money printers.
		return false;
	else
		local item = ents.Create("evorp_money_printer");
		
		local position = (player:GetPos() + player:GetForward() * 64) + Vector(0,0,64)
		-- Set the position and player of the money printer.
		item:SetPos(position);
		item:SetPlayer(player);
		
		-- Set the unique ID of the money printer.
		item._UniqueID = player:UniqueID();
		
		-- Spawn the item.
		item:Spawn();
		
		-- Increase the player's money printers.
		player:AddCount("moneyprinters", item);
		
		-- Take away the item from the player.
		evorp.inventory.update(player, "money_printer", -1);
		item:CPPISetOwner(player)
		-- Return false because we're going to handle this ourself.
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Called when a player attempts to manufacture an item.
function ITEM:canManufacture(player)
	if (player:GetCount("moneyprinters") == evorp.configuration["Contraband"]["evorp_money_printer"].maximum) then
		evorp.player.notify(player, "You have reached the maximum money printers!", 1);
		
		-- Return false because we're reached the maximum money printers.
		return false;
	end;
end;

-- Register the item.
evorp.item.register(ITEM);
