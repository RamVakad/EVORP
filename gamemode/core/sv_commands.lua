--[[
Name: "sv_commands.lua".
Product: "EvoRP (Roleplay)".
--]]

--[[
evorp.command.add("/pickup", "b", 0, function(player, arguments)
	AnswerCall(player, arguments)
end, "Commands", "", "Pickup an incoming call");

evorp.command.add("/text", "b", 1, function(player, arguments)
	SMS(player, arguments)
end, "Commands", "<text>", "Send a text message to a player");

evorp.command.add("/hangup", "b", 0, function(player, arguments)
	HangCall(player, arguments)
end, "Commands", "", "Decline incoming call or hangup active conversation.");

evorp.command.add("/t", "b", 1, function(player, arguments)
	TalkCall(player, arguments)
end, "Commands", "<text>", "Text to the active conversation.");

evorp.command.add("/call", "b", 1, function(player, arguments)
end, "Commands", "<name>", "Make a call.");

evorp.command.add("buypoints", "b", 1, function(player, arguments)
	local quantity = tonumber(arguments[1])
	if (quantity) then
		local money = 50 * quantity;
		if (player.evorp._Money >= money) then
			evorp.player.giveMoney(player, (-1 * money));
			player:PS_GivePoints(quantity);
			evorp.player.notify(player, "Transaction successfull. ", 0);
		else
			evorp.player.notify(target, "You don't have enough money!", 1);
		end
	end;
end, "Commands", "<points>", "Trades $50 for 1 Point (Point Shop).");
]]
evorp.command.add("crash", "b", 0, function(player, arguments)
		local weps = { }
   		for wep in player.evorp._Weps:gmatch("[^%s]+") do table.insert(weps, wep) end
	  	for k, v in pairs( weps ) do
	        if (!player:HasWeapon(v) and evorp.item.stored[v]) then
	        	player:Give(v);
	        end
	        table.remove(weps, k)
    	end
    	evorp.player.notify(player, "You have recovered weapons from your previous crash.", 0);
end, "Commands", "", "Returns the weapons you had before crashing.");

evorp.command.add("unown", "a", 0, function(player, arguments)
	local trace = player:GetEyeTrace();
	if (trace.Entity and IsValid(trace.Entity) and evorp.entity.isDoor(trace.Entity) and !trace.Entity:GetNetworkedBool("evorp_Unownable")) then
		if not (trace.EntityGetNetworkedBool("evorp_Unownable")) then
			evorp.player.takeDoor(trace.Entity._Owner, trace.Entity)
			evorp.player.notify(player, "Door has been reset!", 1);
		end
	else
		evorp.player.notify(player, "You need to look at a valid entity!", 1);
	end
end, "Commands", "", "Resets ownership of door that you are looking at.");

evorp.command.add("setprice", "b", 1, function(player, arguments)
	local price = tonumber(arguments[1])
	if (price and price > 0) then
		local trace = player:GetEyeTrace();
		local item = trace.Entity;
		if not (item:GetClass() == "evorp_saleitem") then
			evorp.player.notify(player, "You are not aiming a sale item!", 1);
			return
		end
		if not (item._Playe == player) then
			evorp.player.notify(player, "That is not your sale item!", 1);
			return;
		end
		local ratio = price / evorp.item.stored[item._Item].cost
		local maxratio = 1.5
		if (string.find(evorp.item.stored[item._Item].category, "Vehicles") or string.find(item._UniqueID, "Broken")) then
			maxratio = 1;
		end
		if (ratio > maxratio) then
			evorp.player.notify(player, "You are setting the price too high!", 1);
			return;
		end
		item._Price = price;
		item:SetNetworkedInt("evorp_Price", price)
	else
		evorp.player.notify(player, "Invalid number!", 1);
	end
end, "Commands", "<price>", "Sets the price of your sale item.");

--[[
evorp.command.add("addexp", "a", 1, function(player, arguments)
	local target = evorp.player.get(arguments[1])
	if (target) then
		target.evorp._PointsRP = target.evorp._PointsRP + 1;
		evorp.player.notify(player, "You have given "..target:Nick().." an experince point.", 0);
		evorp.player.notify(target, "You have received an experince point!", 0);
	else
		evorp.player.notify(player, "Player not found!", 1);
	end;
end, "Admin Commands", "<player>", "Add an experience point for a player.");
]]
evorp.command.add("getmoney", "b", 0, function(player, arguments)
	-- Check if we got a valid target.
	if (player.evorp._DonorCredits >= 2) then
		player.evorp._DonorCredits = player.evorp._DonorCredits - 2;
		evorp.player.giveMoney(player, 50000);
		evorp.player.notify(player, "You have traded 2 donator credits for $50000!", 0);
		evorp.player.saveData(player)
		exsto.GetPlugin("logs"):SaveEvent(player:Nick().." ["..player:SteamID().."] used getmoney.", "donate")
	else
		evorp.player.notify(player, "You do not have enough donator credits!", 1);
	end;
end, "Commands", "", "Trade 2 donator credits for Money Pack ($50000).");

evorp.command.add("holsterattachmentkit", "b", 0, function(player, arguments)
	evorp.player.holsterAttachment(player)
end, "Commands", "", "Holster your attachment kit.");

evorp.command.add("getvip", "b", 0, function(player, arguments)
	-- Check if we got a valid target.
	if (player.evorp._DonorCredits >= 20) then
		player.evorp._DonorCredits = player.evorp._DonorCredits - 20;
		local days = 45;
		if (player.evorp._Donator < os.time()) then
			player.evorp._Donator = os.time()
		end
		player.evorp._Donator = player.evorp._Donator + (86400 * days);
		evorp.player.giveMoney(player, 150000);
		
		-- Set some Donator only player variables.
		player._SpawnTime = player._SpawnTime / 2;
		player._KnockOutTime = player._KnockOutTime / 2;
		player:SetNetworkedBool("evorp_Donator", true)
		player:SetNetworkedBool("evorp_Donated", true)
		evorp.player.notify(player, "You have traded 15 donator credits for VIP Status!", 0);
		evorp.player.saveData(player)
		exsto.GetPlugin("logs"):SaveEvent(player:Nick().." ["..player:SteamID().."] used getvip.", "donate")
	else
		evorp.player.notify(player, "You do not have enough donator credits!", 1);
	end;
end, "Commands", "", "Trade 15 donator credits for VIP Status Pack.");
--[[
evorp.command.add("trade", "a", 1, function(player, arguments)
	local target = evorp.player.get(arguments[1])
	if (target) then
		PS.Trading:RequestTrade(player, target)
	end
end, "Commands", "<player>", "Trade pointshop items with another player.");
]]
evorp.command.add("history", "a", 1, function(player, arguments)
	if not (player.SqlWait) then player.SqlWait = 0 end;
	if (player.SqlWait > CurTime()) then
		evorp.player.notify(player, "Wait atleast 30 seconds before using this command again.", 1);
		return
	end
	player.SqlWait = CurTime() + 30;
	local target = evorp.player.get(arguments[1]);
	local clear = true;
	if (target) then
		GetDBConnection():Query("SELECT * FROM bans WHERE _SteamID = '"..tmysql.escape(target:SteamID()).."'", function(result)
				if (result and type(result) == "table" and #result > 0) then
					for index,value in ipairs(result) do
						local column = result[index];
						local bantime = tonumber(column._Until) - tonumber(column._When);
						bantime = bantime/3600;
						local access = column._Access;
						player:PrintMessage( HUD_PRINTCONSOLE, target:Name().." - "..access.." = "..bantime.." hour(s) for "..column._Why.."." )
					end;
				end;
		end, 1);
	else
		evorp.player.notify(player, "Target not found!", 1);
	end
end, "Admin Commands", "<player>", "Prints the player's ban history in the console.");

evorp.command.add("administrator", "a", 1, function(player, arguments)
	if !(player:SteamID() == GetCManagerID()) then
		evorp.player.notify(player, "You can't use this command.", 1);
		return;
	end
	if not (player.SqlWait) then player.SqlWait = 0 end;
	if (player.SqlWait > CurTime()) then
		evorp.player.notify(player, "Wait atleast 30 seconds before using this command again.", 1);
		return
	end
	player.SqlWait = CurTime() + 30;
	local target = evorp.player.get(arguments[1]);
	if (target) then
		if (target.evorp._AdminLevel < 3) then
			target.evorp._AdminLevel = 3;
			target:SetUserGroup( "admin" )
			target:SetRank("admin")
			evorp.player.saveData(target)
			evorp.player.notify(target, "You are now an Administrator!", 0);
			evorp.player.notify(player, "Target has been made an administrator!", 0);
			evorp.player.notifyAll(player:Name().." made "..target:Name().." an administrator.");
			exsto.GetPlugin("logs"):SaveEvent(player:Nick().." ["..player:SteamID().."] used /administrator on "..target:Nick().." ["..target:SteamID().."]", "donate")
		end
	else
		evorp.player.notify(player, "Target not found!", 1);
	end
end, "Super Admin Commands", "<player>", "Makes a player an admin.");

evorp.command.add("superadmin", "a", 1, function(player, arguments)
	if !(player:SteamID() == GetCManagerID()) then
		evorp.player.notify(player, "You can't use this command.", 1);
		return;
	end
	if not (player.SqlWait) then player.SqlWait = 0 end;
	if (player.SqlWait > CurTime()) then
		evorp.player.notify(player, "Wait atleast 30 seconds before using this command again.", 1);
		return
	end
	player.SqlWait = CurTime() + 30;
	local target = evorp.player.get(arguments[1]);
	if (target) then
		if (target.evorp._AdminLevel < 4) then
			target.evorp._AdminLevel = 4;
			target:SetUserGroup( "superadmin" )
			target:SetRank("superadmin")
			evorp.player.saveData(target)
			evorp.player.notify(target, "You are now a Super Administrator!", 0);
			evorp.player.notify(player, "Target has been made a super administrator!", 0);
			evorp.player.notifyAll(player:Name().." made "..target:Name().." a super administrator.");
			exsto.GetPlugin("logs"):SaveEvent(player:Nick().." ["..player:SteamID().."] used /superadmin on "..target:Nick().." ["..target:SteamID().."]", "donate")
		end
	else
		evorp.player.notify(player, "Target not found!", 1);
	end
end, "Super Admin Commands", "<player>", "Makes a player a super admin.");

evorp.command.add("moderator", "a", 1, function(player, arguments)
	if !(player:SteamID() == GetCManagerID()) then
		evorp.player.notify(player, "You can't use this command.", 1);
		return;
	end
	if not (player.SqlWait) then player.SqlWait = 0 end;
	if (player.SqlWait > CurTime()) then
		evorp.player.notify(player, "Wait atleast 30 seconds before using this command again.", 1);
		return
	end
	player.SqlWait = CurTime() + 30;
	local target = evorp.player.get(arguments[1]);
	if (target) then
		if (target.evorp._AdminLevel < 2) then
			target.evorp._AdminLevel = 2;
			target:SetUserGroup( "moderator" )
			target:SetRank("moderator")
			evorp.player.saveData(target)
			evorp.player.notify(target, "You are now a Moderator!", 0);
			evorp.player.notify(player, "Target has been made a moderator!", 0);
			evorp.player.notifyAll(player:Name().." made "..target:Name().." a moderator.");
			exsto.GetPlugin("logs"):SaveEvent(player:Nick().." ["..player:SteamID().."] used /moderator on "..target:Nick().." ["..target:SteamID().."]", "donate")
		end
	else
		evorp.player.notify(player, "Target not found!", 1);
	end
end, "Super Admin Commands", "<player>", "Makes a player an admin.");

evorp.command.add("removestaff", "a", 1, function(player, arguments)
	if !(player:SteamID() == GetCManagerID()) then
		evorp.player.notify(player, "You can't use this command.", 1);
		return;
	end
	if not (player.SqlWait) then player.SqlWait = 0 end;
	if (player.SqlWait > CurTime()) then
		evorp.player.notify(player, "Wait atleast 30 seconds before using this command again.", 1);
		return
	end
	player.SqlWait = CurTime() + 30;
	local target = evorp.player.get(arguments[1]);
	if (target) then
		if (target.evorp._AdminLevel > 1) then
			target.evorp._AdminLevel = 0;
			target:SetUserGroup( "guest" )
			target:SetRank("guest")
			evorp.player.saveData(target)
			evorp.player.notify(target, "You have been demoted!", 0);
			evorp.player.notify(player, "Target has been demoted!", 0);
			evorp.player.notifyAll(player:Name().." demoted "..target:Name()..".");
			exsto.GetPlugin("logs"):SaveEvent(player:Nick().." ["..player:SteamID().."] used /removestaff on "..target:Nick().." ["..target:SteamID().."]", "donate")
		end
	else
		evorp.player.notify(player, "Target not found!", 1);
	end
end, "Super Admin Commands", "<player>", "Strips player of power.");

evorp.command.add("trusted", "a", 1, function(player, arguments)
	if !(player.evorp._AdminLevel > 3) then
		evorp.player.notify(player, "You can't use this command.", 1);
		return;
	end
	if not (player.SqlWait) then player.SqlWait = 0 end;
	if (player.SqlWait > CurTime()) then
		evorp.player.notify(player, "Wait atleast 30 seconds before using this command again.", 1);
		return
	end
	player.SqlWait = CurTime() + 30;
	local target = evorp.player.get(arguments[1]);
	if (target) then
		if (target.evorp._AdminLevel == -1) then
			evorp.player.notify(player, "Target cannot be made trusted, he already was one!", 0);
			return
		end
		if (target.evorp._AdminLevel == 0) then
			target.evorp._AdminLevel = 1;
			target:SetUserGroup( "trailmod" )
			target:SetRank("trailmod")
			evorp.player.saveData(target)
			evorp.player.notify(target, "You are now a Trusted member!", 0);
			evorp.player.notify(player, "Target has been made a trusted member!", 0);
			evorp.player.notifyAll(player:Name().." made "..target:Name().." a trusted member.");
			exsto.GetPlugin("logs"):SaveEvent(player:Nick().." ["..player:SteamID().."] used /trusted on "..target:Nick().." ["..target:SteamID().."]", "donate")
		end
	else
		evorp.player.notify(player, "Target not found!", 1);
	end
end, "Super Admin Commands", "<player>", "Changes a player's rank to trusted.");



evorp.command.add("untrust", "a", 1, function(player, arguments)
	if !(player.evorp._AdminLevel > 2) then
		evorp.player.notify(player, "You can't use this command.", 1);
		return;
	end
	if not (player.SqlWait) then player.SqlWait = 0 end;
	if (player.SqlWait > CurTime()) then
		evorp.player.notify(player, "Wait atleast 30 seconds before using this command again.", 1);
		return
	end
	player.SqlWait = CurTime() + 30;
	local target = evorp.player.get(arguments[1]);
	if (target) then
		if (target.evorp._AdminLevel == 1) then
			target.evorp._AdminLevel = -1;
			target:SetUserGroup( "guest" )
			target:SetRank("guest")
			evorp.player.saveData(target)
			evorp.player.notify(target, "You are no longer a Trusted member!", 1);
			evorp.player.notify(player, "Target has been removed as a trusted member!", 0);
			evorp.player.notifyAll(player:Name().." revoked "..target:Name().."'s Trusted access.");
			exsto.GetPlugin("logs"):SaveEvent(player:Nick().." ["..player:SteamID().."] used /untrusted on "..target:Nick().." ["..target:SteamID().."]", "donate")
		end
	else
		evorp.player.notify(player, "Target not found!", 1);
	end
end, "Super Admin Commands", "<player>", "Prints the player's ban history in the console.");

evorp.command.add("historyid", "a", 1, function(player, arguments)
	local steamid = tmysql.escape(arguments[1]);
	if not (player.SqlWait) then player.SqlWait = 0 end;
	if (player.SqlWait > CurTime()) then
		evorp.player.notify(player, "Wait atleast 30 seconds before using this command again.", 1);
		return
	end
	player.SqlWait = CurTime() + 30;
	local clear = true;
	GetDBConnection():Query("SELECT * FROM bans WHERE _SteamID = '"..steamid.."'", function(result)
			if (result and type(result) == "table" and #result > 0) then
				clear = false;
				for index,value in ipairs(result) do
					local column = result[index];
					local bantime = tonumber(column._Until) - tonumber(column._When);
					bantime = bantime/3600;
					local access = column._Access;
					player:PrintMessage( HUD_PRINTCONSOLE, steamid.." - "..access.." = "..bantime.." hour(s) for "..column._Why.."." )
				end;
			end;
	end, 1);
	if (clear) then
		player:PrintMessage( "The given SteamID has a clean ban history." )
	end
end, "Admin Commands", "<steamid>", "Prints the ban history of a steamid in the console.");

evorp.command.add("ban", "a", 4, function(player, arguments)
	local target = evorp.player.get(arguments[1])
	
	if not (tonumber(arguments[3]) or tonumber(arguments[3]) < 0) then 
		evorp.player.notify(player, "Invalid arguments!", 1);
		return false; 
	end;
	
	-- Check if we got a valid target.
	if (target) then
		local access = arguments[2];

		if (access == "") then evorp.player.notify(player, "You need to specify an access!", 1); return false; end;

		for i = 1, #access do
		   	local c = access:sub(i,i)
		    	if ( c == "a" or c == "s" ) then
				evorp.player.notify(player, "You cannot take 'a' or 's' access!", 1);
				-- Return here because they tried to take invalid access.
				return;
			end;
		end
		access = string.lower(access);
		
		local name = tmysql.escape(target:Name());
		local steamID = tmysql.escape(target:SteamID());
		local uniqueID = tmysql.escape(target:UniqueID());
		
		local bname = tmysql.escape(player:Name());
		local bsteamID = tmysql.escape(player:SteamID());
		local buniqueID = tmysql.escape(player:UniqueID());
		
		local _Why = tmysql.escape(table.concat(arguments, " ", 4))
		
		local timeS = os.time() + (tonumber(arguments[3]) * 3600);
		
		if(tonumber(arguments[3]) == 0) then timeS = 0; _Why = "(Permanent) ".._Why; end
		
		GetDBConnection():Query("INSERT INTO bans (_Name, _UniqueID, _SteamID, _When, _Until, _Why, _BannedBy, _BannedByUniqueID, _BannedBySteamID, _Access) VALUES ('"..name.."', '"..uniqueID.."', '"..steamID.."', '"..os.time().."', '"..timeS.."', '".._Why.."', '"..bname.."', '"..buniqueID.."', '"..bsteamID.."', '"..access.."')")

		-- Take the access from the player.
		evorp.player.takeAccess(target, access);
		evorp.player.holsterAll(target);
		target:KillSilent();
		-- Print a message to every player telling them that we gave this player some access.
		evorp.player.notifyAll(player:Name().." took "..target:Name().."'s '"..arguments[2].."' access for: ".._Why..".");
		local column = {}
		column._Until = timeS;
		column._Access = access;
		table.insert(target._Bans, column)
		if (arguments[2] == "b") then
			target:Kick("You received a "..arguments[3].." hour game ban.");
		end
	else
		evorp.player.notify(player, arguments[1].." is not a valid player!", 1);
	end;
end, "Admin Commands", "<player> <access> <time_in_hours> <reason>", "Ban a player's access for X hours.");

evorp.command.add("banid", "a", 4, function(player, arguments)
	local steamID = tmysql.escape(arguments[1]);

	if not (tonumber(arguments[3]) or tonumber(arguments[3]) < 0) then 
		evorp.player.notify(player, "Invalid arguments!", 1);
		return false; 
	end;

	GetDBConnection():Query("SELECT * FROM players WHERE _SteamID = '"..steamID.."'", function(result)
		if (result and type(result) == "table" and #result > 0) then
			for index,value in ipairs(result) do
				local column = result[index];
				local name = tmysql.escape(column._Name)
				local uniqueID = tmysql.escape(column._UniqueID)
				local access = arguments[2];

				if (access == "") then evorp.player.notify(player, "You need to specify an access!", 1); return false; end;

				for i = 1, #access do
				   	local c = access:sub(i,i)
				    	if ( c == "a" or c == "s" ) then
						evorp.player.notify(player, "You cannot take 'a' or 's' access!", 1);
						-- Return here because they tried to take invalid access.
						return;
					end;
				end
				access = string.lower(access);
				local bname = tmysql.escape(player:Name());
				local bsteamID = tmysql.escape(player:SteamID());
				local buniqueID = tmysql.escape(player:UniqueID());
				
				local _Why = tmysql.escape(table.concat(arguments, " ", 4))
				
				local timeS = os.time() + (tonumber(arguments[3]) * 3600);
				
				if(tonumber(arguments[3]) == 0) then timeS = 0; _Why = "(Permanent) ".._Why; end
				
				GetDBConnection():Query("INSERT INTO bans (_Name, _UniqueID, _SteamID, _When, _Until, _Why, _BannedBy, _BannedByUniqueID, _BannedBySteamID, _Access) VALUES ('"..name.."', '"..uniqueID.."', '"..steamID.."', '"..os.time().."', '"..timeS.."', '".._Why.."', '"..bname.."', '"..buniqueID.."', '"..bsteamID.."', '"..access.."')")
				
				-- Take the access from the player.
				-- Print a message to every player telling them that we gave this player some access.
				evorp.player.notifyAll(player:Name().." took ["..steamID.."]'s '"..arguments[2].."' access.");
			end
		else
			evorp.player.notify(player, arguments[1].." was not found in the database! (Invalid?)", 1);
			return;
		end;
	end, 1);
end, "Admin Commands", "<SteamID> <access> <time_in_hours> <reason>", "Ban an offline player's access for <time> seconds.");

evorp.command.add("unban", "a", 2, function(player, arguments)
	if not (tonumber(arguments[1])) then 
		evorp.player.notify(player, "Invalid arguments!", 1);
		return false; 
	end;
	local banID = tonumber(arguments[1])
	if (banID < 1) then
		evorp.player.notify(player, "Invalid arguments!", 1);
		return false; 
	end;
	GetDBConnection():Query("SELECT * FROM bans WHERE _Key = "..banID, function(result)
		if (result and type(result) == "table" and #result > 0) then
			for index,value in ipairs(result) do
				local column = result[index];
				if (os.time() < tonumber(column._Until) or tonumber(column._Until) == 0) then
					local _Why = tmysql.escape(column._Why.." (Unbanned by "..player:Nick().."["..player:SteamID().."]"..": "..table.concat(arguments, " ", 2)..")")
					GetDBConnection():Query("UPDATE bans SET _Until = '"..os.time().."', _Why = '".._Why.."'  WHERE _Key = "..column._Key)
					evorp.player.notify(player, "BanID: "..arguments[1].." has been unbanned.", 0);
				end
			end;
		else
			evorp.player.notify(player, "BanID: "..arguments[1].." was not found in the database! (Invalid?)", 1);
		end;
	end, 1);
end, "Admin Commands", "<banid> <reason>", "Unban using BanID.");

-- A command to demote a player.
evorp.command.add("demote", "b", 1, function(player, arguments)
	local target = evorp.player.get(arguments[1])
	
	-- Check if we got a valid target.
	if (target) then
		if ( hook.Call("PlayerCanDemote", GAMEMODE, player, target) ) then
			local team = target:Team();
			
			-- Demote the player from their current team.
			evorp.player.demote(target);
			
			-- Call a hook.
			hook.Call("PlayerDemote", GAMEMODE, player, target, team);
		end;
	else
		evorp.player.notify(player, arguments[1].." is not a valid player!", 1);
	end;
end, "Commands", "<player>", "Demote a player from their current team if you are their leader.");

-- A command to give a player an item.
evorp.command.add("item", "s", 3, function(player, arguments)
	local target = evorp.player.get(arguments[1])
	local quantity = tonumber(arguments[3])
	-- Check if we got a valid target.
	if (target) then
		local item = evorp.item.get(arguments[2])
		
		-- Check if this is a valid item.
		if (item) then
			if (quantity) then
				local success, fault = evorp.inventory.update(target, item.uniqueID, quantity);
				
				-- Check if we didn't succeed.
				if (!success) then
					evorp.player.notify(player, target:Name().." does not have enough space!", 1);
				else
					evorp.player.notify(player, "You have given "..target:Name().." "..item.name.."("..quantity..")", 0);
					evorp.player.notify(target, player:Name().." has given you "..item.name.."("..quantity..")", 0);
				end;
			end;
		else
			evorp.player.notify(player, "This is not a valid item!", 1);
		end;
	else
		evorp.player.notify(player, arguments[1].." is not a valid player!", 1);
	end;
end, "Super Admin Commands", "<player> <item> <quantity>", "Give an item to a player.");

-- A command to privately message a player.
evorp.command.add("clearlaws", "b", 0, function(player, arguments)
	
	-- Check if we got a valid target.
	if (player:Team() == TEAM_PRESIDENT or player:IsAdmin()) then
		evorp.help.clearLaws();
		evorp.player.notify(player, "Laws cleared!", 0);
	else
		evorp.player.notify(player, "Only the president may use this command!", 1);
	end;
end, "President Commands", "", "Clears the 'Laws' from the F1 Menu.");

-- A command to privately message a player.
evorp.command.add("pm", "b", 2, function(player, arguments)
	local target = evorp.player.get(arguments[1])
	
	-- Check if we got a valid target.
	if (target) then
		player._LastPM = target;
		if (player != target) then
			local text = table.concat(arguments, " ", 2);
			
			-- Check if the there is enough text.
			if (text == "") then
				evorp.player.notify(player, "You did not specify enough text!", 1);
				
				-- Return because there wasn't enough text.
				return;
			end;
			
			-- Print a message to both players participating in the private message.
			evorp.chatBox.add(player, target, "pmto", text);
			evorp.chatBox.add(target, player, "pm", text);
		else
			evorp.player.notify(player, "You cannot send a private message yourself!", 1);
		end;
	else
		evorp.player.notify(player, arguments[1].." is not a valid player!", 1);
	end;
end, "Commands", "<player> <text>", "Privately message a player.");

-- A command to privately message a player.
evorp.command.add("admin", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ", 1);
	
	-- Check if the there is enough text.
	if (text == "") then
		evorp.player.notify(player, "You did not specify enough text!", 1);
		
		-- Return because there wasn't enough text.
		return;
	end;
	if not (player:IsAdmin()) then evorp.chatBox.add(player, player, "admin", text); end
	for k, v in ipairs( g_Player.GetAll() ) do -- Loop through all of the players.
		if (v:IsAdmin()) then
			evorp.chatBox.add(v, player, "admin", text);
		end;
	end 

end, "Commands", "<text>", "Call an admin for help.");

evorp.command.add("m", "b", 1, function(player, arguments)
	if not (player._LastPM) then return end
	local target = player._LastPM;
	
	-- Check if we got a valid target.
	if (target) then
		if (player != target) then
			local text = table.concat(arguments, " ", 1);
			
			-- Check if the there is enough text.
			if (text == "") then
				evorp.player.notify(player, "You did not specify enough text!", 1);
				
				-- Return because there wasn't enough text.
				return;
			end;
			
			-- Print a message to both players participating in the private message.
			evorp.chatBox.add(player, player, "pm", text);
			evorp.chatBox.add(target, player, "pm", text);
		else
			evorp.player.notify(player, "You cannot send a private message yourself!", 1);
		end;
	else
		evorp.player.notify(player, arguments[1].." is not a valid player!", 1);
	end;
end, "Commands", "<text>", "PM the last player you PM'd.");


-- A command to drop money.
evorp.command.add("dropmoney", "b", 1, function(player, arguments)
	local position = player:GetEyeTrace().HitPos;
	
	-- Get the amount of money.
	local money = tonumber(arguments[1]);
	
	if (player:GetCount("moneyd") > 4) then
		evorp.player.notify(player, "You already dropped alot of money, pick it up first!", 1);
		return;
	end

	-- Check if it's a valid amount of money.
	if (money and money > 0) then
		money = math.floor(money);
		
		-- Check to see if the amount is greater than 25.
		if (money >= 1) then
			if ( evorp.player.canAfford(player, money) ) then
				evorp.player.giveMoney(player, -money);
				
				-- Create the money entity.
				local entity = ents.Create("evorp_money");
				
				-- Set the amount and position of the money.
				entity:SetAmount(money);
				entity:SetPos( position + Vector(0, 0, 16 ) );
				player:AddCount("moneyd", entity);
				-- Spawn the money entity.
				entity:Spawn();
				entity:CPPISetOwner(player)
			else
				local amount = money - player.evorp._Money;
				
				-- Print a message to the player telling them how much they need.
				evorp.player.notify(player, "You need another $"..amount.."!", 1);
			end;
		else
			evorp.player.notify(player, "You need to drop a minimum of $1!", 1);
		end;
	else
		evorp.player.notify(player, "This is not a valid amount!", 1);
	end;
end, "Commands", "<amount>", "Drop money at your target position.");

evorp.command.add("givemoney", "b", 1, function(player, arguments)
	local tEnt = player:GetEyeTrace().Entity;
	
	-- Get the amount of money.
	local money = tonumber(arguments[1]);

	-- Check if it's a valid amount of money.
	if (money and money > 0) then
		if not (tEnt and IsValid(tEnt) and tEnt:IsPlayer()) then
			evorp.player.notify(player, "You need to aim at a player!", 1);
			return false;
		end
		money = math.floor(money);
		
		-- Check to see if the amount is greater than 25.
		if (money >= 25) then
			if ( evorp.player.canAfford(player, money) ) then
				evorp.player.giveMoney(player, -money);
				evorp.player.giveMoney(tEnt, money);
				evorp.player.notify(player, "You gave "..tEnt:Nick().." $"..money, 0);
				evorp.player.notify(tEnt, player:Nick().." gave you $"..money, 0);
			else
				local amount = money - player.evorp._Money;
				
				-- Print a message to the player telling them how much they need.
				evorp.player.notify(player, "You need another $"..amount.."!", 1);
			end;
		else
			evorp.player.notify(player, "You need to give a minimum of $25!", 1);
		end;
	else
		evorp.player.notify(player, "This is not a valid amount!", 1);
	end;
end, "Commands", "<amount>", "Give money to the person you're aiming at.");

-- A command to write a note.
evorp.command.add("note", "b", 1, function(player, arguments)
	if (player:GetCount("notes") == evorp.configuration["Maximum Notes"]) then
		evorp.player.notify(player, "You've hit the notes limit!", 1);
	else
		local position = player:GetEyeTrace().HitPos;
		
		-- Check to see if this position is too far away.
		if (player:GetPos():Distance(position) <= 128) then
			local text = table.concat(arguments, " ");
			
			-- Check if the there is enough text.
			if (text == "") then
				evorp.player.notify(player, "You did not specify enough text!", 1);
				
				-- Return because there wasn't enough text.
				return;
			end;
			
			-- Check if the there is too much text.
			if (string.len(text) > 125) then
				evorp.player.notify(player, "Notes can be a maximum of 125 characters!", 1);
				
				-- Return because there was too much text.
				return;
			end;
			
			-- Create the money entity.
			local entity = ents.Create("evorp_note");
			
			-- Set the amount and position of the money.
			entity:SetText(text);
			entity:SetPos( position + Vector(0, 0, 16 ) );
			
			-- Spawn the money entity.
			entity:Spawn();
			entity:CPPISetOwner(player);
			-- Add this entity to our notes count.
			player:AddCount("notes", entity);
			
			-- Add this to our undo table.
			undo.Create("Note");
				undo.SetPlayer(player);
				undo.AddEntity(entity);
			undo.Finish();
		else
			evorp.player.notify(player, "You cannot create a note so far away!", 1);
		end;
	end;
end, "Commands", "<text>", "Write a note at your target position.");

-- A command to change your job.
evorp.command.add("job", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Check if the there is enough text.
	if (player:Team() != TEAM_CITIZEN) then
		evorp.player.notify(player, "You cannot change your job description!", 1);
		
		-- Return because there wasn't enough text.
		return;
	end;

	-- Check if the there is enough text.
	if (text == "") then
		evorp.player.notify(player, "You did not specify enough text!", 1);
		
		-- Return because there wasn't enough text.
		return;
	end;
	
	-- Check the length of the arguments.
	if ( string.len(text) <= 48 ) then
		player._Job = text;
		
		-- Print a message to the player.
		evorp.player.printMessage(player, "You have changed your job to '"..player._Job.."'.");
	else
		evorp.player.notify(player, "Your job can be a maximum of 48 characters!", 1);
	end;
end, "Commands", "<text>", "Change your job. (Custom Roleplay)");

-- A command to change your description.
evorp.command.add("description", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Check if the there is enough text.
	if (text == "") then
		evorp.player.notify(player, "You did not specify enough text!", 1);
		
		-- Return because there wasn't enough text.
		return;
	end;
	
	-- Check the length of the arguments.
	if ( string.len(text) <= 48 ) then
		player.evorp._Description = text;
		
		-- Print a message to the player.
		evorp.player.printMessage(player, "You have changed your description to '"..player.evorp._Description.."'.");
	else
		evorp.player.notify(player, "Your description can be a maximum of 48 characters!", 1);
	end;
end, "Commands", "<text>", "Change your description. (Custom Roleplay)");

-- A command to change your in-character name..
evorp.command.add("icname", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Check if the there is enough text.
	if (text == "") then
		evorp.player.notify(player, "You did not specify enough text!", 1);
		
		-- Return because there wasn't enough text.
		return;
	end;
	
	-- Check the length of the arguments.
	if ( string.len(text) <= 48 ) then
		player.evorp._NameIC = text;
		
		-- Print a message to the player.
		evorp.player.printMessage(player, "You have changed your in character name to '"..player.evorp._NameIC.."'.");
	else
		evorp.player.notify(player, "Your job can be a maximum of 48 characters!", 1);
	end;
end, "Commands", "<text>", "Change your in-character name.");

-- A command to change your clan.
evorp.command.add("setguild", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Check the length of the arguments.
	if ( string.len(text) <= 48 ) then
			player.evorp._Clan = text;
			
			-- Print a message to the player.
			evorp.player.printMessage(player, "You have changed your guild to '"..player.evorp._Clan.."'.");
	else
		evorp.player.notify(player, "Your clan can be a maximum of 48 characters!", 1);
	end;
end, "Commands", "<text>", "Change your clan. Default is Clanless.");

-- A command to change your gender.
evorp.command.add("gender", "b", 1, function(player, arguments)
	if (arguments[1] == "male" or arguments[1] == "female") then
		if (player._Gender == arguments[1]) then
			evorp.player.notify(player, "You are already a "..arguments[1].."!", 1);
		else
			if (arguments[1] == "male") then
				player._NextSpawnGender = "Male";
			else
				player._NextSpawnGender = "Female";
			end;
			
			-- Notify them about their new gender.
			evorp.player.notify(player, "You will be a "..arguments[1].." the next time you spawn.", 0);
		end;
	else
		evorp.player.notify(player, "That is not a valid gender!", 1);
	end;
end, "Commands", "<male|female>", "Change your gender.");

-- A command to yell in character.
evorp.command.add("y", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Check if the there is enough text.
	if (text == "") then
		evorp.player.notify(player, "You did not specify enough text!", 1);
		
		-- Return because there wasn't enough text.
		return;
	end;
	
	-- Print a message to other players within a radius of the player's position.
	evorp.chatBox.addInRadius(player, "yell", text, player:GetPos(), evorp.configuration["Talk Radius"] * 2);
end, "Commands", "<text>", "Yell to players near you.");

-- A command to do 'me' style text.
evorp.command.add("me", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Check if the there is enough text.
	if (text == "") then
		evorp.player.notify(player, "You did not specify enough text!", 1);
		
		-- Return because there wasn't enough text.
		return;
	end;
	
	-- Print a message to other players within a radius of the player's position.
	evorp.chatBox.addInRadius(player, "me", text, player:GetPos(), evorp.configuration["Talk Radius"] * 1);
end, "Commands", "<text>", "e.g: <your name> cries a river.");

-- A command to whisper in character.
evorp.command.add("w", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Check if the there is enough text.
	if (text == "") then
		evorp.player.notify(player, "You did not specify enough text!", 1);
		
		-- Return because there wasn't enough text.
		return;
	end;
	
	-- Print a message to other players within a radius of the player's position.
	evorp.chatBox.addInRadius(player, "whisper", text, player:GetPos(), evorp.configuration["Talk Radius"] / 2);
end, "Commands", "<text>", "Whisper to players near you.");

-- A command to send an advert to all players.
evorp.command.add("advert", "b", 1, function(player, arguments)
	if (!evorp.player.hasAccess(player, "y")) then evorp.player.notify(player, "You are temporarily banned from using /advert.", 1); return false; end;
	if ( evorp.player.canAfford(player, evorp.configuration["Advert Cost"]) ) then
		local text = table.concat(arguments, " ");
		
		-- Check if the there is enough text.
		if (text == "") then
			evorp.player.notify(player, "You did not specify enough text!", 1);
			
			-- Return because there wasn't enough text.
			return;
		end;
		
		-- Print a message to all players.
		evorp.chatBox.add(nil, player, "advert", text);
		
		-- Take away the advert cost from the player's money.
		evorp.player.giveMoney(player, -evorp.configuration["Advert Cost"]);
	else
		local amount = evorp.configuration["Advert Cost"] - player.evorp._Money;
		
		-- Print a message to the player telling them how much they need.
		evorp.player.notify(player, "You need another $"..amount.."!", 1);
	end;
end, "Commands", "<text>", "Send an advert to all players ($"..evorp.configuration["Advert Cost"]..").");

-- A command to change your team.
evorp.command.add("team", "b", 1, function(player, arguments)
	local team = evorp.team.get(arguments[1]);
	if not (player._NextTeamTry) then player._NextTeamTry = 0 end
	if (player:GetNetworkedBool("cuffed") or player:GetNetworkedBool("hostaged")) then
		evorp.player.notify(player, "You can't change team while handcuffed or hostaged!", 1);
		return;
	end
	if (CurTime() < player._NextTeamTry) then
		evorp.player.notify(player, "You may not change your job yet!", 1)
		return;
	end
	-- Check if the team exists.
	if (team) then
		if ( g_Team.NumPlayers(team.index) >= team.limit ) then
			evorp.player.notify(player, "This team is full!", 1);
		else
			if (player:Team() != team.index) then
				if ( hook.Call("PlayerCanJoinTeam", GAMEMODE, player, team.index) ) then
					--evorp.player.holsterAll(player);
					
					-- Check if the player can join this team.
					local success, fault = evorp.team.make(player, team.index);
					
					-- Check if it was unsuccessful.
					if (!success) then evorp.player.notify(player, fault, 1); else player._NextTeamTry = CurTime() + 60 end
				end;
			end;
		end;
	else
		evorp.player.notify(player, "This is not a valid team!", 1);
	end;
end, "Commands", "<team>", "Change your team.");

-- A command to perform inventory action on an item.
evorp.command.add("inventory", "b", 3, function(player, arguments)
    if ( player:Alive() ) then
        local item = arguments[1];
        local amount = player.evorp._Inventory[item];
         
        -- Check if the item exists.
        if ( evorp.item.stored[item] ) then

            if (amount and amount > 0) then
                if (arguments[2] == "drop") then
                  -- local position = player:GetEyeTrace().HitPos;
					
                    -- Check to see if this position is too far away.
                    --if (player:GetPos():Distance(position) <= 128) then
		evorp.item.drop(player, item, arguments[3], position)
                    --else
                        --evorp.player.notify(player, "You cannot drop so far away!", 1);
                    --end;
                elseif (arguments[2] == "use") then
                    if ( player._NextUseItem and player._NextUseItem > CurTime() ) then
                        evorp.player.notify(player, "You cannot use another item for "..math.ceil( player._NextUseItem - CurTime() ).." second(s)!", 1);
                         
                        -- Return because we cannot use it.
                        return;
                    else
                        player._NextUseItem = CurTime() + 2;
                    end;
                     
                    -- Check if the player is in a vehicle.
                    if ( player:InVehicle() and  evorp.item.stored[item].category != "Food" and item != "fuel" and item != "repairkit" and item != "hotwire") then
                        evorp.player.notify(player, "You cannot use this item while inside a vehicle!", 1);
						
                        -- Return because we cannot use it.
                        return;
                    end;
                    
		if (evorp.item.stored[item].weapon) then
			player._NextHolsterWeapon = CurTime() + 5;
		end;
		if(evorp.item.stored[item].category == "Vehicles") then
			local tr = { } 
			tr.start = player:GetPos() 
			tr.endpos = tr.start + Vector( 0, 0, 100000 ) 
			tr.filter = player
			tr = util.TraceLine( tr )
			if not tr.HitSky then
				evorp.player.notify(player, "You can't spawn your vehicle there, sorry!", 1);
				return
			end
		end
		if(evorp.item.stored[item].category == "Vehicles") and (player:GetPos():Distance(player:GetEyeTrace().HitPos) < 140 or player:GetPos():Distance(player:GetEyeTrace().HitPos) > 700)  then
			evorp.player.notify(player, "You can't spawn your vehicle that nearby/far away.", 1);
			return;
		end
	-- Use the item.
		evorp.item.use(player, item)        
                elseif (arguments[2] == "sell") then
                    	evorp.item.sell(player, item)
	elseif (arguments[2] == "remove") then
        		evorp.item.remove(player, item)
        	elseif (arguments[2] == "psell") then
                   	evorp.item.Psell(player, item)
                elseif (arguments[2] == "repair") then
                   	evorp.item.repair(player, item)
                end;
            else
                evorp.player.notify(player, "You do not own a "..evorp.item.stored[item].name.."!", 1);
            end;
        end;
    else
        evorp.player.notify(player, "You cannot do that in this state!", 1);
    end;
end, "Commands", "<item> <drop|use|sell> <amount>", "Perform an inventory action on an item.", true);

-- A command to holster your current weapon.
evorp.command.add("holster", "b", 0, function(player, arguments)
	if ( player:Alive() ) then
		local weapon = player:GetActiveWeapon();
		
		-- Check if they can holster another weapon yet.
		if ( player._NextHolsterWeapon and player._NextHolsterWeapon > CurTime() ) then
			evorp.player.notify(player, "You cannot holster for "..math.ceil( player._NextHolsterWeapon - CurTime() ).." second(s)!", 1);
			
			-- Return false because we cannot manufacture it.
			return false;
		else
			player._NextHolsterWeapon = CurTime() + 5;
		end;
		
		-- Check if the weapon is a valid entity.
		if ( IsValid(weapon) ) then
			local class = weapon:GetClass();
			
			-- Check if this is a valid item.
			if ( evorp.item.stored[class] ) then
				local position = player:GetPos();
				evorp.player.notify(player, "Don't move for 3 seconds to complete the holstering process.", 0);
				    timer.Simple(3, function()
					if ( IsValid(player) ) then
						if (player:GetPos() == position) then
							evorp.command.ConCommand(player, "me holsters his "..evorp.item.stored[class].name..".");
							if (player._SpawnWeapons[class]) then
								player:StripWeapon(class);
								player:EmitSound("weapons/weapon_holster" .. math.random(1, 3) .. ".wav", 65, 100)
								-- Select their hands.
								player:SelectWeapon("evorp_hands");
								player._SpawnWeapons[class] = false;
							else
								if ( hook.Call("PlayerCanHolster", GAMEMODE, player, class) ) then
										local success, fault = evorp.inventory.update(player, class, 1);
										
										-- Check if we didn't succeed.
										if (!success) then
											evorp.player.notify(player, fault, 1);
										else
											if IsValid(player.BackGun) then
										 		player.BackGun:Remove()
										 	end
											player:StripWeapon(class);
											player:EmitSound("weapons/weapon_holster" .. math.random(1, 3) .. ".wav", 65, 100)
											-- Select their hands.
											player:SelectWeapon("evorp_hands");
										end;
								end;
							end
						else
							evorp.player.notify(player, "You have moved since you started holstering your weapon!", 1);
						end;
					end;
				end);
				
			else
				evorp.player.notify(player, "You may not holster your current weapon.", 1);
			end;
		else
			evorp.player.notify(player, "You may not holster your current weapon.", 1);
		end;
	else
		evorp.player.notify(player, "You can't holster when your're dead!", 1);
	end;
end, "Commands", nil, "Holster your current weapon.");

evorp.command.add("holsterall", "b", 0, function(player, arguments)
	if ( player:Alive() ) then
		
		-- Check if they can holster another weapon yet.
		if ( player._NextHolsterWeapon and player._NextHolsterWeapon > CurTime() ) then
			evorp.player.notify(player, "You cannot holster for "..math.ceil( player._NextHolsterWeapon - CurTime() ).." second(s)!", 1);
			
			-- Return false because we cannot manufacture it.
			return false;
		else
			player._NextHolsterWeapon = CurTime() + 5;
			local position = player:GetPos();
			evorp.player.notify(player, "Don't move for 3 seconds to complete the holstering process.", 0);
			timer.Simple(3, function()
				if ( IsValid(player) ) then
					if (player:GetPos() == position) then
						evorp.player.holsterAll(player)
					else
						evorp.player.notify(player, "You have moved since you started holstering!", 1);
					end;
				end;
			end)
		end;

	else
		evorp.player.notify(player, "You can't holster when your're dead!", 1);
	end;
end, "Commands", nil, "Holster all your weapons.");

-- A command to perform an action on a door.
evorp.command.add("door", "b", 1, function(player, arguments)
	if ( player:Alive() ) then
		local door = player:GetEyeTrace().Entity;
		
		-- Check if the player is aiming at a door.
		if ( IsValid(door) and evorp.entity.isDoor(door) ) then
			if ( IsValid(door._Owner) ) then
				if (arguments[1] == "purchase") then
					if (door._Owner == player) then
						evorp.player.notify(player, "You already own this door!", 1);
					else
						evorp.player.notify(player, "This door is owned by "..door._Owner:Name().."!", 1);
					end;
				elseif (arguments[1] == "sell") then
					if (door._Owner == player) then
						if (!door._Unsellable) then
							evorp.player.takeDoor(player, door);
						else
							evorp.player.notify(player, "This door cannot be sold!", 1);
						end;
					else
						evorp.player.notify(player, "This door is owned by "..door._Owner:Name().."!", 1);
					end;
				elseif (arguments[1] == "access") then
					if (door._Owner == player) then
						local entID = tonumber(arguments[2]);
						
						-- Check if it is a valid entity ID.
						if (entID) then
							local target = g_Player.GetByID(entID);
							
							-- Check if we have a valid target.
							if ( IsValid(target) ) then
								local uniqueID = target:UniqueID();
								
								-- Check if the player has access already.
								if (door._Access[uniqueID]) then
									door._Access[uniqueID] = false;
								else
									door._Access[uniqueID] = true;
								end;
							else
								evorp.player.notify(player, "This is not a valid player!", 1);
							end;
						else
							evorp.player.notify(player, "This is not a valid entity ID!", 1);
						end;
					else
						evorp.player.notify(player, "This door is owned by "..door._Owner:Name().."!", 1);
					end;
				elseif (arguments[1] == "name") then
					if (door._Owner == player) then
						local name = table.concat(arguments, " ", 2);
						
						-- Check if the name has any text.
						if (name != "") then
							if ( string.len(name) <= 32 ) then
								door:SetNetworkedString("evorp_Name", name);
							else
								evorp.player.notify(player, "Door names can be a maximum of 32 characters!", 1);
							end;
						else
							evorp.player.notify(player, "This is not a valid name!", 1);
						end;
					else
						evorp.player.notify(player, "This door is owned by "..door._Owner:Name().."!", 1);
					end;
				end;
			else
				if (arguments[1] == "purchase") then
					if ( hook.Call("PlayerCanOwnDoor", GAMEMODE, player, door) ) then
						local doors = 0;
						
						-- Loop through the entities in the map.
						for k, v in pairs( ents.GetAll() ) do
							if ( evorp.entity.isDoor(v) ) then
								if (v._Owner == player) then doors = doors + 1; end;
							end;
						end;
						
						-- Check if we have already got the maximum doors.
						if (doors == evorp.configuration["Maximum Doors"]) then
							evorp.player.notify(player, "You've hit the doors limit!", 1);
						else
							local cost = evorp.configuration["Door Cost"];
							
							-- Check if the player can afford this door.
							if ( evorp.player.canAfford(player, cost) ) then
								evorp.player.giveMoney(player, -cost);
								
								-- Get the name from the arguments.
								local name = string.sub(table.concat(arguments, " ", 2), 1, 24);
								
								-- Check if the name has any text.
								if (name != "") then
									evorp.player.giveDoor(player, door, name);
								else
									evorp.player.giveDoor(player, door);
								end;
							else
								local amount = cost - player.evorp._Money;
								
								-- Print a message to the player telling them how much they need.
								evorp.player.notify(player, "You need another $"..amount.."!", 1);
							end;
						end;
					end;
				elseif (arguments[1] == "sell") then
					evorp.player.notify(player, "This door does not have an owner!", 1);
				elseif (arguments[1] == "access") then
					evorp.player.notify(player, "This door does not have an owner!", 1);
				elseif (arguments[1] == "name") then
					evorp.player.notify(player, "This door does not have an owner!", 1);
				end;
			end;
		else
			evorp.player.notify(player, "This is not a valid door!", 1);
		end;
	else
		evorp.player.notify(player, "You can't buy doors when you're dead!", 1);
	end;
end, "Commands", "<purchase|sell>", "Perform an action on the door you're looking at.", true);

-- A command to manufacture an item.
evorp.command.add("buy", "b", 1, function(player, arguments)
	local item = evorp.item.get(arguments[1]);
	
	-- Check if the item exists.
	if (item) then
		if (item.category) then
			if (!table.HasValue(evorp.team.query(player:Team(), "canmake", {}), item.category)) then
				evorp.player.notify(player, "You may not manufacture this item.", 1);
				
				-- Return false because we're not a member of the required team.
				return false;
			end;
		end;
		
		
		-- Check if they can manufacture this item yet.
		if ( player._NextManufactureItem and player._NextManufactureItem > CurTime() ) then
			evorp.player.notify(player, "You cannot manufacture another item for "..math.ceil( player._NextManufactureItem - CurTime() ).." second(s)!", 1);
			
			-- Return false because we cannot manufacture it.
			return false;
		else
			player._NextManufactureItem = CurTime() + (3 * item.batch);
		end;
		
		-- Check if the player is alive.
		if ( player:Alive() ) then
			if ( evorp.player.canAfford(player, item.cost * item.batch) ) then
				if (!item.store) then
					return;
				end;
				
				-- Get a player's eye position.
				local position = player:GetEyeTrace().HitPos
				
				--if not (player:GetPos():Distance(position) <= 256) then
					--evorp.player.notify(player, "You manufacture items so far away!", 1);
					--return;
				--end;

				-- Take the cost the from player.
				
				--[[
				-- Make the items at that position.
				local items = {}
				for i = 1, item.batch, 1 do
					position.z = position.z + 16 + (i * 2)
					local entity = evorp.item.make( item.uniqueID, position );
					
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

				-- Loop through our created items.
				for k, v in pairs(items) do
					if (item.onManufacture) then item:onManufacture(player, v); end;
				end;
				]]--
				position.z = position.z + 16 + 2
				
				--evorp.item.make (item.uniqueID, position, item.batch)
				if (evorp.inventory.canFit(player, item.size * item.batch)) then
					evorp.player.giveMoney( player, -(item.cost * item.batch) );
					evorp.inventory.update( player, item.uniqueID, item.batch);
					evorp.player.notify(player, "Your item(s) are in your inventory.", 0);
					--[[
					if not (player.evorp._Donator < os.time()) then
						if (math.random(1,10) <= 4) then
							evorp.player.giveMoney( player, math.Round((item.cost * .20)) );
							evorp.player.notify(player, "You earned donator rebate: "..math.Round((item.cost * .20)).."!", 0);
						end
					end;
					]]
				else
					evorp.player.notify(player, "Not enough inventory space!", 1);
				end
			else
				local amount = (item.cost * item.batch) - player.evorp._Money;
				
				-- Print a message to the player telling them how much they need.
				evorp.player.notify(player, "You need $"..amount.." more!", 1);
			end;
		else
			evorp.player.notify(player, "You cannot do that in this state!", 1);
		end;
	else
		evorp.player.notify(player, "This is not a valid item!", 1);
	end;
end, "Commands", "<item>", "Manufacture items.", true);

-- A command to warrant a player.
evorp.command.add("warrant", "b", 2, function(player, arguments)
	--if not (tonumber(arguments[3])) then evorp.player.notify(player, "Invalid argument!", 1); return false; end;
	
	--local arrestTime = tonumber(arguments[3])
	local arrestTime = 150
	if (arrestTime > 300 or arrestTime < 60) then
		evorp.player.notify(player, "The arrest time can only be between 60 and 300 seconds!", 1);
		return;
	end;
	
	local target = evorp.player.get(arguments[1])
	
	-- Get the class of the warrant.
	local class = string.lower(arguments[2] or "");
	
	-- Check if a second argument was specified.
	if (class == "search" or class == "arrest") then
		if (target) then
			if ( target:Alive() ) then
				if (target._Warranted != class) then
					if (!target.evorp._Arrested and class == "arrest") or (class == "search") then
						if (CurTime() > target._CannotBeWarranted) then
							if ( hook.Call("PlayerCanWarrant", GAMEMODE, player, target, class) ) then
								hook.Call("PlayerWarrant", GAMEMODE, player, target, class);
								target._ArrestTime = arrestTime;
								if(target.evorp._Donator > os.time()) then target._ArrestTime = arrestTime/2; end;
								-- Warrant the player.
								evorp.player.warrant(target, class);
							end;
						else
							evorp.player.notify(player, target:Name().." has only just spawned!", 1);
						end;
					else
						evorp.player.notify(player, target:Name().." is already arrested! Did he escape?!", 1);
					end;
				else
					if (class == "search") then
						evorp.player.notify(player, target:Name().." is already warranted for a search!", 1);
					elseif (class == "arrest") then
						evorp.player.notify(player, target:Name().." is already warranted for an arrest!", 1);
					end;
				end;
			else
				evorp.player.notify(player, target:Name().." is dead and cannot be warranted!", 1);
			end;
		else
			evorp.player.notify(player, arguments[1].." is not a valid player!", 1);
		end;
	else
		evorp.player.notify(player, "Invalid argument!", 1);
	end;
end, "President Commands", "<player> <search|arrest>", "Warrant a player for an arrest/search. President/Commander");

-- A command to unwarrant a player.
evorp.command.add("unwarrant", "b", 1, function(player, arguments)
	local target = evorp.player.get(arguments[1])
	
	-- Check to see if we got a valid target.
	if (target) then
		if (target._Warranted) then
			if ( hook.Call("PlayerCanUnwarrant", GAMEMODE, player, target) ) then
				hook.Call("PlayerUnwarrant", GAMEMODE, player, target);
				
				-- Unwarrant the player.
				evorp.player.warrant(target, false);
			end;
		else
			evorp.player.notify(player, target:Name().." does not have a warrant!", 1);
		end;
	else
		evorp.player.notify(player, arguments[1].." is not a valid player!", 1);
	end;
end, "President Commands", "<player>", "Unwarrant a player.");

--A command to wakeup
evorp.command.add("wakeup", "b", 0, function(player, arguments)
	if (!player._Sleeping) then
		evorp.player.notify(player, "You're not sleeping!", 1) 
		return false; 
	end;
	if (player:Alive() and !player:GetNetworkedBool("FakeDeathing")) then
		evorp.player.knockOut(player, false);
		player._Sleeping = false;
	end
	
end, "Commands", nil, "Wake up.");

evorp.command.add("stolen", "b", 0, function(player, arguments)
	if (player._EVORPVehicle) and (IsValid(player._EVORPVehicle)) then
		local car = player._EVORPVehicle;
		if (car:GetNetworkedBool("evStolen")) then
			car:SetNetworkedBool("evStolen", false);
			evorp.player.notify(player, "Your car is no longer reported as stolen!", 0);
		else
			car:SetNetworkedBool("evStolen", true);
			evorp.player.notify(player, "You have reported your car as stolen!", 0);
		end
	else
		evorp.player.notify(player, "You don't have a spawned car!", 1);
	end
end, "Commands", nil, "Report your car stolen/not stolen.");

evorp.command.add("exit", "b", 1, function(player, arguments)
	local car;
	if (player:InVehicle()) then
		car = player:GetVehicle()
		if car.PartOf then car = car.PartOf; end
	else
		car = player:GetEyeTrace().Entity;
	end

	if ( IsValid(car) and evorp.entity.isDoor(car) and evorp.player.hasDoorAccess(player, car) ) then
		local target = evorp.player.get(arguments[1])
		if (target) then
			local targetCar = false;
			if target:InVehicle() then
				targetCar = target:GetVehicle()
				if targetCar.PartOf then targetCar = targetCar.PartOf; end
			end
			if (targetCar and targetCar == car) then
				target:ExitVehicle();
				evorp.player.notify(player, "You've been kicked out of the car!", 1);
			else
				evorp.player.notify(player, "Target not in your car!", 1);
			end
		else
			evorp.player.notify(player, "Target not found.", 1);
		end
	else
		evorp.player.notify(player, "Not a car/no access/not in a car.", 1);
	end
	
end, "Commands", "<player>", "Kick players out of the car (car access required).");

-- A command to sleep
evorp.command.add("sleep", "b", 0, function(player, arguments)
		if(player._Sleeping) then return; end;
		
		local position = player:GetPos();
		
		-- Check if the sleep waiting time is greater than 0.
		if (evorp.configuration["Sleep Waiting Time"] > 0) then
			evorp.player.notify(player, "Stand still for "..evorp.configuration["Sleep Waiting Time"].." second(s) to fall asleep.", 0);
		end;
		
		-- Create a timer to check if the player has moved since we started.
		timer.Create("Sleep: "..player:UniqueID(), evorp.configuration["Sleep Waiting Time"], 1, function()
			if ( IsValid(player) ) then
				if (player:GetPos() == position) then
					evorp.player.knockOut(player, true);
					-- Set sleeping to true because we are now sleeping.
					player._Sleeping = true;
				else
					if (evorp.configuration["Sleep Waiting Time"] > 0) then
						evorp.player.notify(player, "You have moved since you started sleeping!", 1);
					end;
				end;
			end;
		end);
end, "Commands", nil, "Go to sleep.");

-- A command to send a message to all players on the same team.
evorp.command.add("radio", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Say a message as a radio broadcast.
	evorp.player.sayRadio(player, text);
end, "Commands", "<text>", "Send a message through your radio channel.");

-- A command to send a message to all players on the same team.
evorp.command.add("guild", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Say a message as a radio broadcast.
	evorp.player.sayClan(player, text);
end, "Commands", "<text>", "Send a message through your clan radio.");

playerToMutiny = nil;
MutinyJob = nil;
MutinyStarter = nil;
-- A command to warrant a player.
evorp.command.add("mutiny", "b", 1, function(player, arguments)
	arguments[1] = string.upper(arguments[1]) -- Let's work with all capitals.
	local team = arguments[1];
	if  (!timer.Exists("MUTINY") and team == "JOIN") then
		evorp.player.notify(player, "There is no mutiny for you to join!", 1)
		return false;
	end
	if (timer.Exists( "MUTINY" )) then
		if (team == "JOIN") then
			if IsValid(playerToMutiny) then --Make sure mutiny player didn't disconnect.
					if (player._CanMutiny) then
						playerToMutiny:AddCount("MUTINY", player)
						evorp.player.notify(player, "You have joined the mutiny!", 0)
					else
						evorp.player.notify(player, "You may not participate in the current mutiny!", 1)
					end
			end
		else
			evorp.player.notify(player, "A mutiny is already in progress! You must wait for it to end!", 1)
		end
	else
		if (team == "HOSS") then
			team = TEAM_HOSS
		elseif (team == "COMMANDER") then
			team = TEAM_COMMANDER
		elseif (team == "REBEL") then
			team = TEAM_RLEADER
		elseif (team == "DON") then
			team = TEAM_MLEADER
		elseif (team == "PRESIDENT") then
			team = TEAM_PRESIDENT
		elseif (team == "RENEGADE") then
			team = TEAM_RENLEADER
		elseif (team == "ROGUE") then
			team = TEAM_TLEADER
		end
		if (team == arguments[1]) then
			evorp.player.notify(player, "Invalid arguments!", 1);
			return false;
		end
		local victim = nil;
		for k, v in ipairs( g_Player.GetAll() ) do -- Loop through all of the players.
			if (v:Team() == team) then
				victim = v;
			end;
		end 
		if not (IsValid(victim)) then
			evorp.player.notify(player, "There is no person in that post to mutiny!", 1);
			return false
		end
		playerToMutiny = victim;
		MutinyJob = team;
		MutinyStarter = player;
		local maxcount = 0;
		for k, v in ipairs( g_Player.GetAll() ) do -- Loop through all of the players.
			v._CanMutiny = false;
			if (MutinyJob == TEAM_HOSS) then
				if (v:Team() == TEAM_SS) then -- Only SS can mutiny the HOSS
					v._CanMutiny = true;
				end
			elseif (MutinyJob == TEAM_COMMANDER) then
				if (v:Team() == TEAM_OFFICER) then 
					v._CanMutiny = true;
				end
			elseif (MutinyJob == TEAM_RLEADER) then
				if (v:Team() == TEAM_REBEL) then 
					v._CanMutiny = true;
				end
			elseif (MutinyJob == TEAM_MLEADER) then
				if (v:Team() == TEAM_MAFIA) then 
					v._CanMutiny = true;
				end
			elseif (MutinyJob == TEAM_TLEADER) then
				if (v:Team() == TEAM_THIEF) then 
					v._CanMutiny = true;
				end
			elseif (MutinyJob == TEAM_RENLEADER) then
				if (v:Team() == TEAM_RENEGADE) then 
					v._CanMutiny = true;
				end
			elseif (MutinyJob == TEAM_PRESIDENT) then
				if (evorp.team.query(v:Team(), "radio", "") == "R_GOV" and !v:Team() == TEAM_PRESIDENT) then 
					v._CanMutiny = true;
				end
			end
		end 
		if not (player._CanMutiny) then
			evorp.player.notify(player, "You can't start this mutiny!", 1)
			return false;
		end

		for k, v in ipairs( g_Player.GetAll() ) do -- Loop through all of the players.
			if (v._CanMutiny) then
				evorp.player.notify(v, "A mutiny has been started by "..player.evorp._NameIC.."! You can join!", 0)
				maxcount = maxcount + 1;
			end
		end

		timer.Create( "MUTINY", 60, 1, function()
			if (IsValid(playerToMutiny) and playerToMutiny:Team() == MutinyJob) then
				local maxcount = 0;
				if (playerToMutiny:GetCount("MUTINY")/maxcount > .75) then
					evorp.player.demote(playerToMutiny)
					for k, v in ipairs( g_Player.GetAll() ) do -- Loop through all of the players.
						evorp.player.notify(player, "A mutiny against "..playerToMutiny:Nick().." had  succeeded!", 0);
					end
				else
					for k, v in ipairs( g_Player.GetAll() ) do -- Loop through all of the players.
						evorp.player.notify(player, "A mutiny against "..playerToMutiny:Nick().." had  failed!", 0);
					end
				end
			else
				if (IsValid(playerToMutiny)) then
					for k, v in ipairs( g_Player.GetAll() ) do -- Loop through all of the players.
						evorp.player.notify(player, "A mutiny against "..playerToMutiny:Nick().." had  succeeded!", 0);
					end
				end
			end

			playerToMutiny = nil;
			MutinyJob = nil;
			MutinyStarter = nil;

			for k, v in ipairs( g_Player.GetAll() ) do -- Loop through all of the players.
				v._CanMutiny = false;
			end
		end)
 		evorp.player.notify(player, "You have started a mutiny, you have a minute to gather your supporters!", 0);
	end
end, "Commands", "<HOSS|COMMANDER|REBEL|DON|PRESIDENT|RENEGADE|ROGUE|JOIN> ", "Start a mutiny on a specific post or join an existing mutiny. No turning back once you join!");