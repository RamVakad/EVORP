--[[
Name: "sh_item.lua".
Product: "EvoRP (Roleplay)".
--]]

evorp.item = {};
evorp.item.stored = {};
evorp.item.cats = {}
evorp.item.catIndex = 1

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Register a new item.
function evorp.item.register(item)
	if (item.category == "Weaponry") then
		item.cost = item.cost * 4;
	end
	if (item.category == "Vehicles") then
		item.cost = item.cost * 2;
	end
	if (item.weapon) then
		local broken = deepcopy(item);
		broken.uniqueID = broken.uniqueID.."Broken"
		broken.name = broken.name.." (BROKEN)"
		broken.plural = broken.plural.." (BROKEN)"
		broken.cost = math.floor(broken.cost * .25)
		broken.description = "A broken weapon, you can attempt to repair it for $"..broken.cost..". Success chance is 50%"
		broken.store = false;
		broken.weapon = false;
		broken.onUse = nil;
		broken.onRepair = true;
		broken.category = "Supplies/Misc"
		evorp.item.stored[broken.uniqueID] = broken;
	end
	evorp.item.stored[item.uniqueID] = item;
	--evorp.configuration["Banned Props"][item.model] = true;
end;

-- Get an item by it's name.
function evorp.item.get(name)
	for k, v in pairs(evorp.item.stored) do
		if (name == v.uniqueID) then return v; end;
		
		-- Check to see if the name matches or is found in the item's name.
		if ( string.find( string.lower(v.name), string.lower(name) ) ) then return v; end;
	end;
end;

-- Add a new category.
function evorp.item.addCat(name, description, access)
	local data = {
		name = name or "",
		description = description or "",
		access = access or "b",
		index = evorp.item.catIndex
	}
	
	evorp.item.cats[data.name] = data;
	evorp.item.catIndex = evorp.item.catIndex + 1;
	
	return data.index
end

-- Retrieve a cat.
function evorp.item.findCat(name)
	local item;
	
	-- Check if we have a number meaning its an index.
	for k, v in pairs(evorp.item.cats) do
		if (string.find(string.lower(v.name), string.lower(name))) then
			if (item) then
				if (string.len(v.name) < string.len(item.name)) then
					item = v;
				end;
			else
				item = v;
			end;
		end;
	end;
	
	-- Return the item that we found.
	return item;
end;

-- Check to see if we're running on the server.
if (SERVER) then
	function evorp.item.use(player, item)
		if (player.evorp._Inventory[item] and player.evorp._Inventory[item] > 0) then
			if (evorp.item.stored[item]) then
				if (evorp.item.stored[item].onUse) then
					if (player:GetNetworkedBool("cuffed") or player:GetNetworkedBool("hostaged")) and (evorp.item.stored[item].category != "Food") then
						return false
					end
					if ( evorp.item.stored[item]:onUse(player) == false ) then
						return false;
					end;

					if (evorp.item.stored[item].category == "Vehicles") or (evorp.item.stored[item].category == "Class Vehicles") then
						if (!evorp.player.hasAccess(player, "v")) then
							evorp.player.notify(player, "You are temporarily banned from using vehicles. Go online for more information!", 1);
							return false;
						else
							local tr = player:GetEyeTraceNoCursor()
						 	local trace = util.QuickTrace( tr.HitPos, Vector(0,0,100000) );
							if (trace.Hit and not trace.HitSky) then
								evorp.player.notify(player, "You can't spawn your vehicle there!", 1);
								return false;
							end
							local spawnvehicle = ents.Create("prop_vehicle_jeep")
							spawnvehicle:SetModel(evorp.item.stored[item].model)
							spawnvehicle:SetPos(tr.HitPos)
							spawnvehicle.VehicleTable = list.Get( "Vehicles" )[ evorp.item.stored[item].uniqueID ]
							player._EVORPVehicle = spawnvehicle
							spawnvehicle._Class = evorp.item.stored[item].class
							spawnvehicle:SetKeyValue("vehiclescript", spawnvehicle.VehicleTable.KeyValues["vehiclescript"])
							if (evorp.item.stored[item].skin) then spawnvehicle:SetSkin(evorp.item.stored[item].skin) end
							spawnvehicle:Spawn()
							hook.Call("PlayerSpawnedVehicle", GAMEMODE, player, spawnvehicle)
							return true
						end
					end
					
					if ( evorp.item.stored[item].weapon ) then
						local team = player:Team()
						if (team == TEAM_PRESIDENT or team == TEAM_PARAMEDIC or team == TEAM_FIREMAN) then 
							evorp.player.notify(player, "You can't use weapons!", 1);
							return false;
						end
						if (!evorp.player.hasAccess(player, "w") and !evorp.item.stored[item].safe) then
							evorp.player.notify(player, "You are temporarily banned from using weapons. Go online for more information!", 1);
							return false;
						end
						if player:HasWeapon(evorp.item.stored[item].uniqueID) then
							evorp.player.notify(player, "You already have this weapon out!", 1);
							return false;
						else
						local alreadyHas = false;
						for k, v in pairs(player:GetWeapons()) do
       							if (evorp.item.stored[v:GetClass()] and evorp.item.stored[v:GetClass()].Heavy) then
       								alreadyHas = true
       							end
						end
						if  (alreadyHas and evorp.item.stored[item].Heavy) then
							evorp.player.notify(player, "You can't have multiple heavy arms out at once!", 1);
							return false;
						end
						    evorp.player.notify(player, "Don't move for 3 seconds to pull your weapon out.", 0);
						    evorp.command.ConCommand(player, "me is searching through his inventory for something.");
						    local position = player:GetPos();

						    timer.Simple(3, function()
							if ( IsValid(player) ) then
								if (player.evorp._Inventory[item] and player.evorp._Inventory[item] > 0) then
									if (player:GetPos() == position) then
										 evorp.command.ConCommand(player, "me pulls out a "..evorp.item.stored[item].name..".");
										 player:Give(evorp.item.stored[item].uniqueID);
										    if(player:GetWeapon(evorp.item.stored[item].uniqueID).Wearable) then
										    	player:GetWeapon(evorp.item.stored[item].uniqueID):BackgunOn();
										    end
				                       					    player:SelectWeapon(evorp.item.stored[item].uniqueID)
				                       					    evorp.inventory.update(player, item, -1);
									else
										evorp.player.notify(player, "You have moved since you started pulling out your weapon!", 1);
									end;
								else
									evorp.player.notify(player, "You no longer have the weapon!", 1);
								end
							end;
						end);
						   
                       					 end;
					end
					if not (evorp.item.stored[item].weapon) then
						evorp.inventory.update(player, item, -1);
					end
					-- Update the player's inventory.
					evorp.player.printConsoleAccess(player:Name() .. " [".. player:SteamID() .. "] ".. "used item (".. evorp.item.stored[item].uniqueID .. ").", "a", player)
					
					-- Return true because we did it successfully.
					return true;
				end;
			end;
		end;
		
		-- Return false because we failed somewhere.
		return false;
	end;
	
	function evorp.item.remove(player, item)
		if (player.evorp._Inventory[item] and player.evorp._Inventory[item] > 0) then
			if (evorp.item.stored[item]) then
				if (evorp.item.stored[item].onRemove) then
					if ( evorp.item.stored[item]:onRemove(player) == false ) then
						return false;
					end;
					
					--Stuff here
					
				end;
			end;
		end;
		
		-- Return false because we failed somewhere.
		return false;
	end;
	
	-- Drops an item from a player.
	function evorp.item.drop(player, item, dropAmount, position)
		if not (dropAmount and tonumber(dropAmount)) then
			return false;
		end
		
			local dropAmount = tonumber(dropAmount);
			if (player.evorp._Inventory[item] and player.evorp._Inventory[item] > 0 and player.evorp._Inventory[item] >= dropAmount) then
				if (evorp.item.stored[item]) then
					--if (!position) then
						--position = player:GetEyeTrace().HitPos
					--end;
					
					-- Check to see if we have an on drop function.
					if (evorp.item.stored[item].onDrop) then
						if ( evorp.item.stored[item]:onDrop(player, position) == false ) then return false; end;
						--[[
						if (evorp.item.stored[item].weapon and player:HasWeapon(evorp.item.stored[item].uniqueID) and player.evorp._Inventory[item] == dropAmount) then
							player:SelectWeapon("evorp_hands");
							player:StripWeapon(item);
						end;
						]]
						if (player:GetCount("vehicles") > 0) and ((evorp.item.stored[item].category == "Class Vehicles") or (evorp.item.stored[item].category == "Vehicles")) then
							evorp.player.notify(player, "You need park all your vehicles before you drop any!", 1);
							return;
						end;
						
						-- Update the player's inventory.
						evorp.player.printConsoleAccess(player:Name() .. " [".. player:SteamID() .. "]".. " dropped item (".. evorp.item.stored[item].uniqueID .. "). Amount = "..dropAmount, "a", player)
						evorp.inventory.update(player, item, -1 * dropAmount);
						
						-- Make the items at that position.
						--[[
						local items = {}
						for i = 1, dropAmount, 1 do
							position.z = position.z + 16 + (i * 2)
							local entity = evorp.item.make( item, position, );
							
							-- Insert the new entity into our items list.
							table.insert(items, entity);
						end;
						
						-- Loop through our created items and no-collide them with each other.
						for k, v in pairs(items) do
							for k2, v2 in pairs(items) do
								if (v != v2) then
									if ( IsValid(v) and IsValid(v2) ) then
										constraint.NoCollide(v, v2, 0, 0);
									end;
								end;
							end;
						end;
						]]--
						--position.z = position.z + 16 + 2
						local droppedi = evorp.item.make (item, (player:GetPos() + player:GetForward() * 64) + Vector(0,0,64), dropAmount)
						droppedi:CPPISetOwner(player);
						-- Return true because we did it successfully.
						return true;
					end;
				end;
			else
				evorp.player.notify(player, "Insufficient quantity!", 1);
			end;
		
		-- Return false because we failed somewhere.
		return false;
	end;
	
	-- Destroys all of a player's item.
	function evorp.item.destroy(player, item)
		if (player.evorp._Inventory[item] and player.evorp._Inventory[item] > 0) then
			if (evorp.item.stored[item]) then
				if (evorp.item.stored[item].onDestroy) then
					if ( evorp.item.stored[item]:onDestroy(player) == false ) then
						return false;
					end;
					
					-- Update the player's inventory.
					evorp.player.printConsoleAccess(player:Name() .. " [".. player:SteamID() .. "]".. " destroyed item (".. evorp.item.stored[item].uniqueID .. ").", "a", player)
					evorp.inventory.update(player, item, -player.evorp._Inventory[item]);
					
					-- Return true because we did it successfully.
					return true;
				end;
			end;
		end;
		
		-- Return false because we failed somewhere.
		return false;
	end;
	
	function evorp.item.repair(player, item)
		if (player.evorp._Inventory[item] and player.evorp._Inventory[item] > 0) then
			if (evorp.item.stored[item].onRepair) then
				local itemOnSuccess = string.gsub(item, "Broken", "")
				--if (evorp.inventory.canFit(player, evorp.item.stored[itemOnSuccess].size)) then
					if (evorp.player.canAfford(player, math.floor(evorp.item.stored[item].cost))) then
						evorp.player.giveMoney(player, -1 *  math.floor(evorp.item.stored[item].cost))
						evorp.inventory.update(player, item, -1);
						if (math.random(100) < 50) then
							evorp.inventory.update(player, itemOnSuccess, 1);
							evorp.player.notify(player, "Repair Successful!", 0);
							evorp.player.printConsoleAccess(player:Name() .. " [".. player:SteamID() .. "]".. " repaired item: (".. evorp.item.stored[item].uniqueID .. ") successfully.", "a", player)
						else
							evorp.player.notify(player, "Repair failed, better luck next time :)", 0);
							evorp.player.printConsoleAccess(player:Name() .. " [".. player:SteamID() .. "]".. " repaired item: (".. evorp.item.stored[item].uniqueID .. ") and failed.", "a", player)
						end
					else
						evorp.player.notify(player, "You don't have enough money to perform this repair!", 0);
					end
				--else
					--evorp.player.notify(player, "Clear up your inventory before attemping this repair!", 0);
				--end
			end
		end
	end

	function evorp.item.Psell(player, item)
		if (player.evorp._Inventory[item] and player.evorp._Inventory[item] > 0) then
			if (player:GetCount("vehicles") > 0) and ((evorp.item.stored[item].category == "Class Vehicles") or (evorp.item.stored[item].category == "Vehicles")) then
				evorp.player.notify(player, "You need park all your vehicles before selling any vehicles!", 1);
				return;
			end;
			if (player:GetCount(item.."Sale") >= player.evorp._Inventory[item]) then
				evorp.player.notify(player, "You can't put anymore of this type of item for sale!", 0);
				return
			end
			local max = 8;
			if (player.evorp._Donator > os.time()) then max = 13; end
			if (player:GetCount("saleitems") >= max) then
				evorp.player.notify(player, "You can't have any items out for sale!", 0);
				return
			end
			local entity = ents.Create("evorp_saleitem")
			entity:SetItem(item, player)
			local multi = 64;
			if (string.find(evorp.item.stored[item].category, "Vehicles")) then
				multi = 64 + 128;
			end
			entity:SetPos((player:GetPos() + player:GetForward() * multi) + Vector(0,0,64) );
			entity:Spawn();
			player:AddCount("saleitems", entity);
			player:AddCount(item.."Sale", entity)
			if not player._SaleItems then player._SaleItems = {} end
			if not player._SaleItems[item] then player._SaleItems[item] = 1; else player._SaleItems[item] = player._SaleItems[item] + 1; end
			entity:CPPISetOwner(player);
			entity:PhysWake();
			evorp.player.printConsoleAccess(player:Name() .. " [".. player:SteamID() .. "]".. " put item up for sale: (".. evorp.item.stored[item].uniqueID .. ").", "a", player)
		end
	end

	-- Sell a players item.
	function evorp.item.sell(player, item)
		if (player.evorp._Inventory[item] and player.evorp._Inventory[item] > 0) then
			if (evorp.item.stored[item]) then
				if (evorp.item.stored[item].onSell) then
					if ( evorp.item.stored[item]:onSell(player) == false ) then
						return false;
					end;
					
					if (player:GetCount("vehicles") > 0) and ((evorp.item.stored[item].category == "Class Vehicles") or (evorp.item.stored[item].category == "Vehicles")) then
						evorp.player.notify(player, "You need park all your vehicles before selling any vehicles!", 1);
						return;
					end;
					evorp.inventory.update(player, item, -1);
					--if (evorp.item.stored[item].category == "Weaponry") then
					--	evorp.player.giveMoney(player, tonumber(evorp.item.stored[item].cost * .8) )
					--else
						evorp.player.giveMoney(player, tonumber(evorp.item.stored[item].cost / 2) )
					--end
					evorp.player.printConsoleAccess(player:Name() .. " [".. player:SteamID() .. "]".. " sold item (".. evorp.item.stored[item].uniqueID .. ").", "a", player)
				end;
			end;
		end;
	end;
	
	-- Makes an item at the specified position.
	function evorp.item.make(item, position, amount)
		local entity = ents.Create("evorp_item");
		
		-- Set the item and the position of the entity and then spawn it.
		entity:SetItem(item, amount);
		entity:SetPos(position);
		entity:Spawn();
		entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
		entity:PhysWake();
		
		-- Return the new entity.
		return entity;
	end;
end;

evorp.item.addCat("Vehicles", "Transportation for everyone.", "b");
evorp.item.addCat("Food", "Required to maintain life and growth.", "b");
evorp.item.addCat("Weaponry", "Useful in a fight.", "b");
evorp.item.addCat("Supplies/Misc", "Misc. items.", "b");
evorp.item.addCat("Black Market", "Controlled and scarce commodities.", "b");
evorp.item.addCat("Contraband", "Illegal goods that earn you money.", "b");
--evorp.item.addCat("Misc.", "All of the other stuff.", "b");
--evorp.item.addCat("Class Vehicles", "Vehicles required for specific roleplay.", "b");
--evorp.item.addCat("Clothing", "Clothes which can only be be worn by donators. (Models)", "b");
--evorp.item.addCat("Pharmaceuticals", "Medicinal drugs.", "b");