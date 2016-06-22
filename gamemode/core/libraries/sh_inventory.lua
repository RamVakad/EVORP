--[[
Name: "sh_inventory.lua".
Product: "EvoRP (Roleplay)".
--]]

evorp.inventory = {};

-- Check if we're running on the server.
if (SERVER) then
	function evorp.inventory.update(player, item, amount, force)
		if (evorp.item.stored[item]) then
			if (amount < 1 or evorp.inventory.canFit(player, evorp.item.stored[item].size * amount) or force) then
				player.evorp._Inventory[item] = (player.evorp._Inventory[item] or 0) + (amount or 0);
				
				-- Check to see if we do not have any of this item now.
				if (player.evorp._Inventory[item] <= 0) then
					if (amount > 0) then
						player.evorp._Inventory[item] = amount;
					else
						player.evorp._Inventory[item] = nil;
					end;
				end;
				
				-- Send a usermessage to the player to tell him his items have been updated.
				umsg.Start("evorp_Inventory_Item", player);
					umsg.String(item);
					umsg.Long(player.evorp._Inventory[item] or 0);
				umsg.End();
				
				-- Return true because we updated the inventory successfully.
				return true;
			else
				return false, "You do not have enough inventory space!";
			end;
		else
			return false, "That is not a valid item!";
		end;
	end;
	
	-- Get the maximum amount of space a player has.
	function evorp.inventory.getMaximumSpace(player)
		local size = 0;
		
		-- Loop through the player's inventory.
		for k, v in pairs(player.evorp._Inventory) do
			if (evorp.item.stored[k]) then
				if (evorp.item.stored[k].size < 0) then
					size = size + (math.abs(evorp.item.stored[k].size) * v);
				end;
			end;
		end;
		
		local maxsize = 150;
		if (player.evorp._Donator > 0) then maxsize = 250; end
		if size > maxsize and !player:IsSuperAdmin() then size = maxsize; end
		-- Return the size.
		return size;
	end;
	
	-- Get the size of a player's inventory.
	function evorp.inventory.getSize(player)
		local size = 0;
		
		-- Loop through the player's inventory.
		for k, v in pairs(player.evorp._Inventory) do
			if (evorp.item.stored[k].size > 0) then
				size = size + (evorp.item.stored[k].size * v);
			end;
		end;
		
		-- Return the size.
		return size;
	end;
	
	-- Check if a player can fit a specified size into their inventory.
	function evorp.inventory.canFit(player, size)
		if ( size < 0 ) then return true; end;
		if ( evorp.inventory.getSize(player) + size > evorp.inventory.getMaximumSpace(player) ) then
			return false;
		else
			return true;
		end;
	end;
	
	-- Called when a player has initialized.
	hook.Add("PlayerInitialized", "evorp.inventory.playerInitialized", function(player)
		timer.Simple(1, function()
			if not (IsValid(player)) then return end
			for k, v in pairs(player.evorp._Inventory) do evorp.inventory.update(player, k, 0, true); end;
		end);
	end);
else
	evorp.inventory.stored = {};
	evorp.inventory.updatePanel = true;
	
	-- Hook into when the server sends the client an inventory item.
	usermessage.Hook("evorp_Inventory_Item", function(msg)
		local item = msg:ReadString();
		local amount = msg:ReadLong();
		
		-- Check to see if the amount is smaller than 1.
		if (amount < 1) then
			evorp.inventory.stored[item] = nil;
		else
			evorp.inventory.stored[item] = amount;
		end;
		
		-- Tell the inventory panel that we should update.
		evorp.inventory.updatePanel = true;
	end);
	
	-- Get the maximum amount of space a player has.
	function evorp.inventory.getMaximumSpace()
		local size = 0;
		
		-- Loop through the player's inventory.
		for k, v in pairs(evorp.inventory.stored) do
			if (evorp.item.stored[k]) then
				if (evorp.item.stored[k].size < 0) then
					size = size + (math.abs(evorp.item.stored[k].size) * v);
				end;
			end;
		end;
		
		local maxsize = 150;
		if (LocalPlayer():GetNetworkedBool("evorp_Donated")) then maxsize = 250; end
		if size > maxsize and !LocalPlayer():IsSuperAdmin() then size = maxsize; end
		-- Return the size.
		return size;
	end;
	
	-- Get the size of the local player's inventory.
	function evorp.inventory.getSize()
		local size = 0;
		
		-- Loop through the player's inventory.
		for k, v in pairs(evorp.inventory.stored) do
			if (evorp.item.stored[k]) then
				if (evorp.item.stored[k].size > 0) then
					size = size + (evorp.item.stored[k].size * v);
				end;
			end;
		end;
		
		-- Return the size.
		return size;
	end;
	
	-- Check if the local player can fit a specified size into their inventory.
	function evorp.inventory.canFit(size)
		if ( evorp.inventory.getSize() + size > evorp.inventory.getMaximumSpace() ) then
			return false;
		else
			return true;
		end;
	end;
end
