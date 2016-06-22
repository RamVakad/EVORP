--[[
Name: "sv_init.lua".
Product: "EvoRP (Roleplay)".
--]]

local PLUGIN = {};

-- Create a variable to store the plugin for the shared file.
PLUGIN_SHARED = PLUGIN;

-- Include the shared file and add it to the client download list.
include("sh_init.lua");
AddCSLuaFile("sh_init.lua");

-- Say a message as a request.
function PLUGIN.sayRequest(ply, text)
	for k, v in pairs( g_Player.GetAll() ) do
		if (evorp.team.query(v:Team(), "radio", "") == "R_GOV") then
			if (v:GetPos():Distance( ply:GetPos() ) > evorp.configuration["Talk Radius"] / 2) then
				evorp.chatBox.add(v, ply, "request", text);
			end
		end;
	end;

	evorp.chatBox.addInRadius(ply, "request", text, ply:GetPos(), evorp.configuration["Talk Radius"] / 2)
end;

-- Say a message as a request.
function PLUGIN.sayFire(ply, text)
	for k, v in pairs( g_Player.GetAll() ) do
		if (evorp.team.query(v:Team(), "radio", "") == "R_FIRE") then
			evorp.chatBox.add(v, ply, "request", text);
		end;
	end;
end;

-- Say a message as a request.
function PLUGIN.sayMedic(ply, text)
	for k, v in pairs( g_Player.GetAll() ) do
		if (evorp.team.query(v:Team(), "radio", "") == "R_MEDIC") then
			evorp.chatBox.add(v, ply, "request", text);
		end;
	end;
end;

-- Say a message as a broadcast.
function PLUGIN.sayBroadcast(player, text)
	evorp.chatBox.add(nil, player, "broadcast", text);
end;

function checkAndKick(player) 
	local ret = false;
	local name = tmysql.escape(player:Name());
	local steamID = tmysql.escape(player:SteamID());

	if not (evorp.player.hasAccess(player, "b")) then
		game.ConsoleCommand( "kickid "..steamID.." Check the ban page on EVORP.NET for more information.\n");
		ret = true;
	end
	--[[
	--Checks if they are banned first.
	GetDBConnection():Query("SELECT * FROM bans WHERE _UniqueID = '"..uniqueID.."' AND _Access = 'b'", function(result)
		if ( IsValid(player) ) then
			if (result and type(result) == "table" and #result > 0) then
				for index,value in ipairs(result) do
					local column = result[index];
					if (os.time() < tonumber(column._Until) or tonumber(column._Until) == 0) then
						
					end
				end;
			end;
		end
	end, 1);
	]]

	if (ret) then return end;

	if not (player.evorp._Online == "NO") then 
		--game.ConsoleCommand( "kickid "..steamID.." It seems that you are already connected to the server, please wait a minute and try again.\n");
		evorp.player.printConsoleAccess(name.." ["..steamID.."] has connected, but he is online on some other ERP server too. I did not kick him.", "a")
	else
		player.evorp._Online = GetConVar("sv_logdownloadlist"):GetString()
	end
end

-- Called when a player has initialized.
function PLUGIN.playerInitialized(player)
	checkAndKick(player);
	if not (IsValid(player)) then return end
	if (player.evorp._AdminLevel < 2) then 
		evorp.player.takeAccess(player, "a") 
	end
	if (player.evorp._AdminLevel < 5) then
		evorp.player.takeAccess(player, "s") 
	end

	if (player.evorp._AdminLevel <= 0) then
		player:SetUserGroup( "guest" )
		player:SetRank("guest")
	elseif  (player.evorp._AdminLevel == 1) then
		player:SetUserGroup( "trailmod" )
		player:SetRank("trailmod")
	elseif (player.evorp._AdminLevel == 2) then
		player:SetUserGroup( "moderator" )
		player:SetRank("moderator")
	elseif (player.evorp._AdminLevel == 3) then
		player:SetUserGroup( "admin" )
		player:SetRank("admin")
	elseif (player.evorp._AdminLevel == 4) then
		player:SetUserGroup( "superadmin" )
		player:SetRank("superadmin")
	elseif (player.evorp._AdminLevel == 5) then
		player:SetUserGroup( "srv_owner" )
		player:SetRank("srv_owner")
	end

	--if (string.find(player:Nick(), "Chuteuk")) then
	--	evorp.player.giveAccess(player, "a") 
	--	player:SetUserGroup( "superadmin" )
	--	player:SetRank("superadmin")
	--end
	if (player.evorp._Donator > os.time()) then
		local expire = math.max(player.evorp._Donator - os.time(), 0);
		
		-- Check if the expire time is greater than 0.
		if (expire > 0) then
			local days = math.floor( ( (expire / 60) / 60 ) / 24 );
			local hours = string.format("%02.f", math.floor(expire / 3600));
			local minutes = string.format("%02.f", math.floor(expire / 60 - (hours * 60)));
			local seconds = string.format("%02.f", math.floor(expire - hours * 3600 - minutes * 60));
			
			-- Check if we still have at least 1 day.
			if (days > 0) then
				evorp.player.printMessage(player, "Your VIP status expires in "..days.." day(s).");
			else
				evorp.player.printMessage(player, "Your VIP status expires in "..hours.." hour(s) "..minutes.." minute(s) and "..seconds.." second(s).");
			end;
			
			-- Set some Donator only player variables.
			player._SpawnTime = evorp.configuration["Spawn Time"] / 2;
			player._ArrestTime = player._ArrestTime/2;
			player._KnockOutTime = evorp.configuration["Knock Out Time"] / 2;
			player:SetNetworkedBool("evorp_Donator", true)
		end
	else
		-- Notify the player about how their Donator status has expired.
		if (player.evorp._Donator > 0) then
			player:SetNetworkedBool("evorp_Donated", true)
			evorp.player.notify(player, "Your VIP status has expired!", 1);
		end;
	end;
	
	-- Make the player a Citizen to begin with.
	evorp.team.make(player, TEAM_CITIZEN);
end;

evorp.hook.add("PlayerInitialized", PLUGIN.playerInitialized);

-- Called every frame.
function PLUGIN.think()
	if (PLUGIN.NextHeavyThink and CurTime() < PLUGIN.NextHeavyThink) then return end
	PLUGIN.NextHeavyThink = CurTime() + .1;
	if (PLUGIN.lockdown and g_Team.NumPlayers(TEAM_PRESIDENT) == 0) then
		PLUGIN.lockdown = false;
		evorp.player.notifyAll("Due to the lack of a president, the lockdown is no longer active.");
		
		-- Set a global integer so that the client can get whether there is a lockdown.
		SetGlobalInt("evorp_Lockdown", 0);
	end;
end;

-- Add the hook.
evorp.hook.add("Think", PLUGIN.think);

-- Called when a player should be given their weapons.
function PLUGIN.playerLoadout(player)
	player._SpawnWeapons = {};
	
	-- Check the player's team.
	--if (player:Team() == TEAM_RLEADER or player:Team() == TEAM_MLEADER) then
		--player._SpawnWeapons["evorp_lockpick"] = true;
	    	--player:Give("evorp_lockpick");
	--end

	if (player:Team() == TEAM_FIREMAN) then
		player:Give("evorp_firestop");
		--player:Give("evorp_axe");
	end

	if (player:Team() == TEAM_PARAMEDIC) then
		player._SpawnWeapons["test_medkit"] = true;
		player:Give("test_medkit");
	end
	
	if (player:Team() == TEAM_COMMANDER or player:Team() == TEAM_OFFICER or player:Team() == TEAM_HOSS or player:Team() == TEAM_SS) then
		if (player.evorp._Donator > os.time()) then
			player:GiveAmmo(24, "pistol");
			player:Give("bb_glock");
			player._SpawnWeapons["bb_glock"] = true;
		end
		player:Give("evorp_arrest");
		player:Give("evorp_cuff");
		player._SpawnWeapons["evorp_carstop"] = true;
		player:Give("evorp_carstop");
		player:GiveAmmo(12, "Gravity");
		player:Give("evorp_radar");
	end;
	
	if (player:Team() == TEAM_COMMANDER) then
		if (evorp.player.hasAccess(player, "w")) then
			if (player.evorp._Donator > os.time()) then
				player:GiveAmmo(90, "smg1");
				player:Give("bb_mp5");
				player._SpawnWeapons["bb_mp5"] = true;
			else
				player:GiveAmmo(24, "pistol");
				player:Give("bb_glock");
				player._SpawnWeapons["bb_glock"] = true;
			end
		else
			evorp.player.notify(player, "You didn't receive weapons as you are banned form using them. Go online for more information!", 1);
		end		
	end

	if (player:Team() == TEAM_HOSS or player:Team() == TEAM_SS) then
		if (evorp.player.hasAccess(player, "w")) then
			player:GiveAmmo(20, "pistol");
			player:Give("bb_deagle");
			player._SpawnWeapons["bb_deagle"] = true;
			if (player.evorp._Donator > os.time()) then
				player:Give("bb_m4a1");
				player._SpawnWeapons["bb_m4a1"] = true;
				player:GiveAmmo(90, "smg1");
			end
		end
	end;

	
	-- Select the hands weapon.
	player:SelectWeapon("evorp_hands");
end;

-- Called when a player attempts to holster a weapon.
function PLUGIN.playerCanHolster(player, weapon, silent)
	if not (player:HasWeapon(weapon)) then return false end;
	if ( player._SpawnWeapons[weapon] ) then
		if (!silent) then evorp.player.notify(player, "You cannot holster this weapon!", 1); end;
		
		-- Return false because they cannot holster this weapon.
		return false;
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerCanHolster", PLUGIN.playerCanHolster);

-- Called when a player attempts to use a door.
function PLUGIN.playerCanUseDoor(player, door)
	if ( !IsValid(door._Owner) ) then
		if (player:Team() != TEAM_COMMANDER and player:Team() != TEAM_OFFICER
		and player:Team() != TEAM_PRESIDENT) then
			return false;
		end;
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerCanUseDoor", PLUGIN.playerCanUseDoor);

-- Called when a player's salary should be adjusted.
function PLUGIN.playerAdjustSalary(player)
	if (player.evorp._Donator > os.time()) then player._Salary = player._Salary * 2; end;
end;

-- Add the hook.
evorp.hook.add("PlayerAdjustSalary", PLUGIN.playerAdjustSalary);

-- Called when a player uses contraband contraband.
function PLUGIN.PlayerCanContraband(player)
	if (player:Team() == "Paramedic" or player:Team() == "Fireman") then return true; end;
	if (evorp.team.query(target:Team(), "radio", "") == "R_GOV") then
		return false;
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerCanContraband", PLUGIN.PlayerCanEarnContraband);

-- Called when a player attempts to demote another player.
function PLUGIN.playerCanDemote(player, target)
	if (target:Team() == TEAM_CITIZEN) then
		evorp.player.notify(player, "You cannot demote a player from Citizen!", 1);
		
		-- Return false because they cannot demote this player.
		return false;
	end;

	if(player:IsAdmin()) then return true end
	
	-- Check to see if we are the President and if the target is part of the government.
	if (player:Team() == TEAM_PRESIDENT) then
		if (evorp.team.query(target:Team(), "radio", "") == "R_GOV") then
			return true;
		else
			evorp.player.notify(player, "You can only demote government officials!", 1);
		end;
	elseif  (player:Team() == TEAM_TLEADER and target:Team() == TEAM_THIEF) or (player:Team() == TEAM_RENLEADER and target:Team() == TEAM_RENEGADE) or (player:Team() == TEAM_HOSS and target:Team() == TEAM_SS) or (player:Team() == TEAM_COMMANDER and target:Team() == TEAM_OFFICER) or (player:Team() == TEAM_RLEADER and target:Team() == TEAM_REBEL) or (player:Team() == TEAM_MLEADER and target:Team() == TEAM_MAFIA) then
		return true;
	else
		evorp.player.notify(player, "Only leaders can use this command!", 1);
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerCanDemote", PLUGIN.playerCanDemote);

-- Called when a player attempts to drop a weapon.
function PLUGIN.playerCanDrop(player, weapon, silent, attacker)	
	-- Check if the player spawned with this weapon.
	if ( player._SpawnWeapons[weapon] ) then
		if (!silent) then evorp.player.notify(player, "You cannot drop this weapon!", 1); end;
		
		-- Return false because they cannot drop this weapon.
		return false;
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerCanDrop", PLUGIN.playerCanDrop);

-- Called when a player destroys contraband.
function PLUGIN.playerDestroyContraband(player, entity)
	local contraband = evorp.configuration["Contraband"][ entity:GetClass() ];
	
	-- Check if the contraband is valid.
	if (contraband) then
		evorp.player.giveMoney(player, contraband.money);
		
		-- Notify them about the money they earned.
		evorp.player.notify(player, "You earned $"..contraband.money.." for destroying contraband.", 0);
	end;
end;

-- Called when a player dies.
function PLUGIN.playerDeath(player, inflictor, killer)
	local govKiller = false;
	if (IsValid(killer) and killer:IsPlayer() and evorp.team.query(killer:Team(), "radio", "") == "R_GOV") then
		govKiller = true;
	end;
	if (!govKiller and IsValid(player) and player:Team() == TEAM_PRESIDENT and !player._ChangeTeam) then
		for k, v in pairs( g_Player.GetAll() ) do evorp.player.warrant(v, false); end;
		
		-- Make the president a Citizen again.
		evorp.team.make(player, TEAM_CITIZEN); 
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerDeath", PLUGIN.playerDeath);

-- Called when a player is demoted.
function PLUGIN.playerDemoted(player, team) 
	evorp.team.make(player, TEAM_CITIZEN);
end;

-- Called when a player spawns.
function PLUGIN.postPlayerSpawn(player, lightSpawn, changeTeam)
	if (player:Team() == TEAM_PRESIDENT) then
		if (!lightSpawn or changeTeam) then
			player:GodEnable();
			
			-- The duration that the player will be immune.
			local duration = 30;
			
			-- Check if the player has Donator status.
			if (player.evorp._Donator > os.time()) then duration = 60; end;
			
			-- Set the player's immunity time so that we can get it client side.
			evorp.player.setLocalPlayerVariable(player, CLASS_LONG, "_SpawnImmunityTime", CurTime() + duration);
			
			-- Create a timer to disable the player's god mode.
			timer.Create("Spawn Immunity: "..player:UniqueID(), duration, 1, function()
				if ( IsValid(player) ) then player:GodDisable(); end;
			end);
		end;
	else
		timer.Remove( "Spawn Immunity: "..player:UniqueID() );
		
		-- Reset the player's immunity time client side.
		evorp.player.setLocalPlayerVariable(player, CLASS_LONG, "_SpawnImmunityTime", 0);
	end;
	
	-- Check if the player is a Combine or the City Administrator.
	if (evorp.team.query(player:Team(), "radio", "") == "R_GOV" and (player:Team() != TEAM_PARAMEDIC and player:Team() != TEAM_FIREMAN and player:Team() != TEAM_SECRETARY)) then player._ScaleDamage = 0.5; end;
end;

-- Add the hook.
evorp.hook.add("PostPlayerSpawn", PLUGIN.postPlayerSpawn);

-- Called when a player attempts to warrant another player.
function PLUGIN.playerCanWarrant(player, target, class)
	if (player:Team() != TEAM_PRESIDENT and player:Team()  != TEAM_COMMANDER) then
		evorp.player.notify(player, "Only the president/commander can issue warrants!", 1);
		return false;
	end;
	
	return true;
end;

-- Add the hook.
evorp.hook.add("PlayerCanWarrant", PLUGIN.playerCanWarrant);

-- Called when a player's warrant has expired.
function PLUGIN.playerWarrantExpired(player, class)
	if (g_Team.NumPlayers(TEAM_PRESIDENT) > 0 and IsValid(g_Team.GetPlayers(TEAM_PRESIDENT)[1]) and IsValid(player)) then
		PLUGIN.sayBroadcast(g_Team.GetPlayers(TEAM_PRESIDENT)[1], "The "..class.." warrant for "..player:Name().." has expired.");
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerWarrantExpired", PLUGIN.playerWarrantExpired);

-- Called when a player warrants another player.
function PLUGIN.playerWarrant(player, target, class)
	if (player:Team() == TEAM_PRESIDENT) then
		if (class == "search") then
			PLUGIN.sayBroadcast(player, "I have warranted "..target:Name().." for a search.");
		elseif (class == "arrest") then
			PLUGIN.sayBroadcast(player, "I have warranted "..target:Name().." for an arrest.");
		end;
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerWarrant", PLUGIN.playerWarrant);

-- Called when a player unwarrants another player.
function PLUGIN.playerUnwarrant(player, target)
	if (player:Team() == TEAM_PRESIDENT) then
		PLUGIN.sayBroadcast(player, "I have unwarranted "..target:Name()..".");
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerUnwarrant", PLUGIN.playerUnwarrant);

-- Called when a player demotes another player.
function PLUGIN.playerDemote(player, target, team)
	if (player:Team() == TEAM_PRESIDENT) then
		PLUGIN.sayBroadcast(player, "I have demoted "..target:Name().." from "..g_Team.GetName(team)..".");
		
		-- Notify the target that they have been demoted.
		evorp.player.notify(target, "You have been demoted from "..g_Team.GetName(team)..".");
	else
		evorp.player.notifyAll(player:Name().." demoted "..target:Name().." from "..g_Team.GetName(team)..".");
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerDemote", PLUGIN.playerDemote);

-- Called when a player wakes up another player.
function PLUGIN.playerWakeUp(player, target)
	if evorp.team.query(player:Team(), "radio", "") == "R_GOV" and (player:Team() != TEAM_PARAMEDIC and player:Team() != TEAM_FIREMAN and player:Team() != TEAM_SECRETARY) then
		evorp.player.sayRadio(player, "I have woken up "..target:Name()..".");
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerWakeUp", PLUGIN.playerWakeUp);

-- Called when a player knocks out another player.
function PLUGIN.playerKnockOut(player, target)
end;

-- Add the hook.
evorp.hook.add("PlayerKnockOut", PLUGIN.playerKnockOut);

-- Called when a player arrests another player.
function PLUGIN.playerArrest(player, target)
end;

-- Add the hook.
evorp.hook.add("PlayerArrest", PLUGIN.playerArrest);

-- Called when a player unarrests another player.
function PLUGIN.playerUnarrest(player, target)
	if (evorp.team.query(player:Team(), "radio", "") == "R_GOV" and (player:Team() != TEAM_PARAMEDIC and player:Team() != TEAM_FIREMAN and player:Team() != TEAM_SECRETARY)) then
		evorp.player.sayRadio(player, "I have unarrested "..target:Name()..".");
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerUnarrest", PLUGIN.playerUnarrest);

-- Called when a player attempts to unwarrant another player.
function PLUGIN.playerCanUnwarrant(player, target)
	if (player:Team() == TEAM_PRESIDENT or player:Team() == TEAM_COMMANDER) then
		return true;
	end;
end;

-- Add the hook.
evorp.hook.add("PlayerCanUnwarrant", PLUGIN.playerCanUnwarrant);

-- A command to broadcast to all players.
evorp.command.add("broadcast", "b", 1, function(player, arguments)
	if (player:Team() == TEAM_PRESIDENT) then
		local text = table.concat(arguments, " ");
		
		-- Check if the there is enough text.
		if (text == "") then
			evorp.player.notify(player, "You did not specify enough text!", 1);
			
			-- Return because there wasn't enough text.
			return;
		end;
		
		-- Print a message to all players.
		evorp.chatBox.add(nil, player, "broadcast", text);
	else
		evorp.player.notify(player, "Only the president may broadcast!", 1);
	end;
end, "Commands", "<text>", "Broadcast a message to all players. (President only.)");

-- A command to request assistance from the Combine and City Administrator.
evorp.command.add("request", "b", 1, function(player, arguments)
		local text = table.concat(arguments, " ");
		
		if (evorp.team.query(player:Team(), "radio", "") == "R_GOV") then
			evorp.player.notify(player, "Please use /radio instead!", 1);
			return false;
		end;
		
		-- Check if the there is enough text.
		if (text == "") then
			evorp.player.notify(player, "You did not specify enough text!", 1);
			
			-- Return because there wasn't enough text.
			return false;
		end;
		
		PLUGIN.sayRequest(player, text)
		
		-- Let them know that their request was sent.
		evorp.player.printMessage(player, "Your request has been sent to the government.");
end, "Commands", "<text>", "Request government assistance.");

-- A command to set the Rebel objective.
evorp.command.add("objective", "b", 1, function(player, arguments)
	local objectiveType = "";
	
	if (player:Team() == TEAM_HOSS) then 
		objectiveType = "evorp_HObjective_" 
	elseif (player:Team() == TEAM_COMMANDER) then
		objectiveType = "evorp_CObjective_"
	elseif (player:Team() == TEAM_RLEADER) then
		objectiveType = "evorp_RObjective_" 
	elseif (player:Team() == TEAM_MLEADER) then 
		objectiveType = "evorp_MObjective_" 
	elseif (player:Team() == TEAM_RENLEADER) then 
		objectiveType = "evorp_RenObjective_" 
	elseif (player:Team() == TEAM_TLEADER) then 
		objectiveType = "evorp_TObjective_" 
	else 
		evorp.player.notify(player, "You cannot set the objective!", 1); 
		return false; 
	end;
	
	local text = table.concat(arguments, " ");
	
	-- Check if the there is enough text.
	if (text == "") then
		evorp.player.notify(player, "You did not specify enough text!", 1);
		
		-- Return because there wasn't enough text.
		return;
	end;
	
	-- Check if the there is too much text.
	if (string.len(text) > 125) then
		evorp.player.notify(player, "Objectives can be a maximum of 125 characters!", 1);
		
		-- Return because there was too much text.
		return;
	end;
	
	-- Create a table to store our objective and a variable to store the position of our text.
	local objective = {};
	local position = 1;
	
	-- Do a while loop to store our objective.
	while (string.sub(text, position, position + 30) != "") do
		table.insert( objective, string.sub(text, position, position + 30) );
		
		-- Increase the position.
		position = position + 31;
	end;
	
	-- Loop through our text.
	for k, v in pairs(objective) do SetGlobalString(objectiveType..k, v); end;
	
	-- Loop through any objectives we didnt set.
	for i = #objective + 1, 10 do SetGlobalString(objectiveType..i, ""); end;
	
	-- Loop through all of the team.
	for k, v in pairs( g_Team.GetPlayers(player:Team()) ) do
		evorp.player.notify(v, player:Name().." has set the objective.", 0);
	end;
end, "Commands", "<text>", "Set the objective.");

-- A command to initiate lockdown.
evorp.command.add("lockdown", "b", 0, function(player, arguments)
	if (player:Team() == TEAM_PRESIDENT) then
		if (!PLUGIN.lockdown) then
			PLUGIN.sayBroadcast(player, "A lockdown is in progress. Please return to your home.");
			
			-- Set the lockdown variable to true.
			PLUGIN.lockdown = true;
			
			-- Set a global integer so that the client can get whether there is a lockdown.
			SetGlobalInt("evorp_Lockdown", 1);
		else
			evorp.player.notify(player, "A lockdown is already in progress!", 1);
		end;
	else
		evorp.player.notify(player, "You are not the president!", 1);
	end;
end, "Commands", nil, "Initiate a lockdown.");

-- A command to cancel lockdown.
evorp.command.add("unlockdown", "b", 0, function(player, arguments)
	if (player:Team() == TEAM_PRESIDENT) then
		if (PLUGIN.lockdown) then
			PLUGIN.sayBroadcast(player, "The lockdown has been cancelled.");
			
			-- Set the lockdown variable to false.
			PLUGIN.lockdown = false;
			
			-- Set a global integer so that the client can get whether there is a lockdown.
			SetGlobalInt("evorp_Lockdown", 0);
		else
			evorp.player.notify(player, "A lockdown is already in progress!", 1);
		end;
	else
		evorp.player.notify(player, "You are not the president!", 1);
	end;
end, "Commands", nil, "Cancel a lockdown.");
--[[

evorp.command.add("tax", "b", 1, function(player, arguments)
	if (player:Team() == TEAM_PRESIDENT) then
		if (math.ceil(tonumber( arguments[1] )) > 30 or math.ceil(tonumber( arguments[1] )) < 1) then
			evorp.player.notify(player, "You cannot set the tax higher than $30 or lower than $1!", 1);
		else
			evorp._tax = SetGlobalInt("evorp_tax", math.ceil(tonumber( arguments[1] ))) ;
			PLUGIN.sayBroadcast(team.GetPlayers(TEAM_PRESIDENT)[1], "I've set the taxation amount to $"..GetGlobalInt("evorp_tax", 25)..".");
		end;
	else
		evorp.player.notify(player, "You are not the president!", 1);
	end;
end, "Commands", nil, "Sets the taxation amount (0 - 30)");
]]
-- A command to privately message a player.
evorp.command.add("law", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ", 1);
	
	-- Check if we got a valid target.
	if (player:Team() == TEAM_PRESIDENT or player:IsAdmin()) then
		
		-- Check if the there is enough text.
		if (text == "") then
			evorp.player.notify(player, "You did not specify enough text!", 1);
			
			-- Return because there wasn't enough text.
			return;
		end;
		evorp.help.add("Laws", text);
		evorp.player.notify(player, "Law added!", 0);
		PLUGIN.sayBroadcast(player, "I have added a new law, press F1 and read it.")
	else
		evorp.player.notify(player, "Only the president may use this command!", 1);
	end;
end, "President Commands", "<text>", "Add a law to the list of laws in the F1 Menu.");

-- A command to give Donator status to a player.
evorp.command.add("donatorcredits", "s", 2, function(player, arguments)
	local target = evorp.player.get( arguments[1] )
	
	-- Calculate the days that the player will be given Donator status for.
	local days = math.ceil(tonumber( arguments[2] ));
	
	-- Check if we got a valid target.
	if (target) then
		target.evorp._DonorCredits = target.evorp._DonorCredits + days;
		evorp.player.notify(player, "You gave "..target:Name().." "..days.." credits.", 0);
		evorp.player.notify(target, "You received "..days.." Donator Credits.", 0);
	else
		evorp.player.notify(player, arguments[1].." is not a valid player!", 1);
	end;
end, "Super Admin Commands", "<player> <amount>", "Give donator credits to a player.");

	local text = "Objective can be set using /objective";
	
	-- Create a table to store our objective and a variable to store the position of our text.
	local objective = {};
	local position = 1;
	
	-- Do a while loop to store our objective.
	while (string.sub(text, position, position + 30) != "") do
		table.insert( objective, string.sub(text, position, position + 30) );
		
		-- Increase the position.
		position = position + 31;
	end;
	
	-- Loop through our text.
	for k, v in pairs(objective) do 
		SetGlobalString("evorp_HObjective_"..k, v);
		SetGlobalString("evorp_CObjective_"..k, v);
		SetGlobalString("evorp_RObjective_"..k, v);
		SetGlobalString("evorp_MObjective_"..k, v);
		SetGlobalString("evorp_RenObjective_"..k, v);
		SetGlobalString("evorp_TObjective_"..k, v);
	end;
	
	-- Loop through any objectives we didnt set.
	for i = #objective + 1, 10 do 
		SetGlobalString("evorp_HObjective_"..i, ""); 
		SetGlobalString("evorp_CObjective_"..i, ""); 
		SetGlobalString("evorp_RObjective_"..i, ""); 
		SetGlobalString("evorp_MObjective_"..i, ""); 
		SetGlobalString("evorp_RenObjective_"..i, "");
		SetGlobalString("evorp_TObjective_"..i, "");
	end;

-- Register the plugin.
evorp.plugin.register(PLUGIN)