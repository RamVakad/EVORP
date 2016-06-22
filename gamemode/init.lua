--[[
Name: "init.lua".
Product: "EvoRP (Roleplay)".
--]]
require("tmysql4")
SetGlobalInt("evorp_cycle", 1)

-- Include the shared gamemode file.
include("sh_init.lua");

-- Add the Lua files that we need to send to the client.
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("sh_init.lua");
AddCSLuaFile("core/sh_configuration.lua");
AddCSLuaFile("core/sh_enumerations.lua");
AddCSLuaFile("core/scoreboard/admin_buttons.lua");
AddCSLuaFile("core/scoreboard/player_frame.lua");
AddCSLuaFile("core/scoreboard/player_infocard.lua");
AddCSLuaFile("core/scoreboard/player_row.lua");
AddCSLuaFile("core/scoreboard/scoreboard.lua");
AddCSLuaFile("core/scoreboard/vote_button.lua");

-- Enable realistic fall damage for this gamemode.
game.ConsoleCommand("mp_falldamage 1\n");
game.ConsoleCommand("sbox_godmode 0\n");

-- Check to see if local voice is enabled.
if (evorp.configuration["Local Voice"]) then
	game.ConsoleCommand("sv_voiceenable 1\n");
	game.ConsoleCommand("sv_alltalk 1\n");
	game.ConsoleCommand("sv_voicecodec vaudio_speex\n");
	--game.ConsoleCommand("sv_voicequality 5\n");
end;

-- Some useful ConVars that can be changed in game.
CreateConVar("evorp_ooc", 1);

-- Store the old hook.Call function.
hookCall = hook.Call;



-- Overwrite the hook.Call function.
function hook.Call(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z)
	if (a == "PlayerSay") then d = string.Replace(d, "$q", "\""); end;
	
	-- Call the original hook.Call function.
	return hookCall(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z);
end;

-- A table that will hold entities that were there when the map started.
GM.entities = {};
local DBConn = nil

function GetCManagerID() -- Community Manager ID (This guy will have some power on the server!!)
	return 'STEAM_0:1:52503352';
end

-- Called when the server initializes.
function GM:Initialize()
	local host = evorp.configuration["MySQL Host"];
	local username = evorp.configuration["MySQL Username"];
	local password = evorp.configuration["MySQL Password"];
	local database = evorp.configuration["MySQL Database"];
	
	-- Initialize a connection to the MySQL database.
	local db, err = tmysql.initialize(host, username, password, database, 3306, 5, 5);
	DBConn = db
	local scode = GetConVar("sv_logdownloadlist"):GetString();
	resource.AddFile("maps/"..string.lower(game.GetMap())..".bsp")
	print("SERVER CODE: "..scode)

	-- Call the base class function.
	return self.BaseClass:Initialize();
end;

function GetDBConnection()
	return DBConn or nil;
end

-- Called when a player switches their flashlight on or off.
function GM:PlayerSwitchFlashlight(player, on)
	if (player.evorp._Arrested or player._KnockedOut) then
		return false;
	else
		return true;
	end;
end;

function GM:ScalePlayerDamage(ply, hitgroup, dmginfo)
	if (hitgroup == HITGROUP_HEAD) then
		dmginfo:ScaleDamage(5)
	elseif (hitgroup == HITGROUP_CHEST) then
		dmginfo:ScaleDamage(1)
	else
		dmginfo:ScaleDamage(0.7)
	end
end

-- Called when a player attempts to use an entity.
function GM:PlayerUse(player, entity)
	if (player._KnockedOut) then
		return false;
	elseif (player.evorp._Arrested and entity:GetClass() != "prop_vehicle_jeep" and (evorp.entity.isDoor(entity) or entity:GetClass() == "prop_dynamic") ) then
		if ( !player._NextNotify or player._NextNotify < CurTime() ) then
			evorp.player.notify(player, "You cannot do that in this state!", 1);
			
			-- Set their next notify so that they don't get spammed with the message.
			player._NextNotify = CurTime() + 2;
		end;
		
		-- Return false because they are arrested.
		return false;
	elseif (evorp.entity.isDoor(entity) or entity:GetClass() == "prop_dynamic") then
		if (evorp.player.hasDoorAccess(player, entity)) then
			evorp.entity.openDoor(entity, 0);
		end;
	end;
	
	-- Call the base class function.
	return self.BaseClass:PlayerUse(player, entity);
end;

-- Called when a player's warrant has expired.
function GM:PlayerWarrantExpired(player, class) end;

-- Called when a player demotes another player.
function GM:PlayerDemote(player, target, team) end;

-- Called when a player knocks out another player.
function GM:PlayerKnockOut(player, target) end;

-- Called when a player wakes up another player.
function GM:PlayerWakeUp(player, target) end;

-- Called when a player arrests another player.
function GM:PlayerArrest(player, target) end;

-- Called when a player unarrests another player.
function GM:PlayerUnarrest(player, target) end;

-- Called when a player warrants another player.
function GM:PlayerWarrant(player, target, class) end;

-- Called when a player unwarrants another player.
function GM:PlayerUnwarrant(player, target) end;

-- Called when a player attempts to own a door.
function GM:PlayerCanOwnDoor(player, door) return true; end;

-- Called when a player attempts to view a door.
function GM:PlayerCanViewDoor(player, door) return true; end;

-- Called when a player attempts to holster a weapon.
function GM:PlayerCanHolster(player, weapon, silent) return true; end;

-- Called when a player attempts to drop a weapon.
function GM:PlayerCanDrop(player, weapon, silent, attacker) return true; end;

-- Called when a player attempts to use an item.
function GM:PlayerCanUseItem(player, item, silent) return true; end;

-- Called when a player attempts to warrant a player.
function GM:PlayerCanWarrant(player, target) return true; end;

-- Called when a player attempts to use a door.
function GM:PlayerCanUseDoor(player, door)
	if ( IsValid(door._Owner) ) then
		if (!door._Owner._Warranted and door._Owner != player) then
			return false;
		end;
	end;
	
	-- Return true because we can use this door.
	return true;
end;

-- Called when a player enters a vehicle.
function GM:PlayerEnteredVehicle(player, vehicle, role)
	if (vehicle:GetClass() == "prop_vehicle_jeep") then
		player.nextHyd = CurTime() + 5
		if not (evorp.player.hasDoorAccess(player, vehicle) or vehicle:GetNetworkedBool("HotWired") or vehicle:GetNetworkedBool("NeedsFix")) then
			vehicle:Fire("TurnOff", "" , 0)
			evorp.player.notify(player, "You're not in the access list, you might need to hotwire the car.", 0);
		else
			vehicle:Fire("TurnOn", "" , 0)
		end
		player:SetNetworkedInt("nextHyd", player.nextHyd )
		player:ConCommand("enteredvehicle")
	end
end;

function GM:CheckPassword(SteamID, IP, sv_logdownloadlist, ClientPassword, PlayerName)
	return true;
end

-- Called when a player attempts to join a team.
function GM:PlayerCanJoinTeam(player, team)
	team = evorp.team.get(team);
	
	-- Check if this is a valid team.
	if (team) then
		if (player._NextChangeTeam[team.index]) then
			if ( player._NextChangeTeam[team.index] > CurTime() ) then
				local seconds = math.floor( player._NextChangeTeam[team.index] - CurTime() );
				
				-- Notify them that they cannot change to this team yet.
				evorp.player.notify(player, "You must wait "..seconds.." second(s) to become a "..team.name.."!", 1);
				
				-- Return here because they can't become this team.
				return false;
			end;
		end;
	end;
	
	-- Check if the player is warranted.
	if (player._Warranted) then
		evorp.player.notify(player, "You cannot do that while you are warranted!", 1);
		
		-- Return here because they can't become this team.
		return false;
	end;
	
	-- Check if the player is knocked out.
	if (player._KnockedOut) then
		evorp.player.notify(player, "You can't change team in your current state!", 1);
		
		-- Return here because they can't become this team.
		return false;
	end;
	
	-- Return true because they can join this team.
	return true;
end;

-- Called when a player earns contraband money.
function GM:PlayerCanEarnContraband(player) return true; end;

-- Called when a player attempts to unwarrant a player.
function GM:PlayerCanUnwarrant(player, target)
	if ( player:IsAdmin() ) then
		return true;
	end
end;


-- Called when a player attempts to demote another player.
function GM:PlayerCanDemote(player, target)
	if ( !player:IsAdmin() ) then
		evorp.player.notify(player, "You do not have access to demote this player!", 1);
		
		-- Return false because they cannot demote this player.
		return false;
	else
		return true;
	end;
end;

-- Called when all of the map entities have been initialized.
function GM:InitPostEntity()
	--It's always sunny in EVORP :)
	if string.lower(game.GetMap()) == "rp_evocity_v33x" then
		engine.LightStyle(0, "t")
		print("Made things a little brighter today.")
	end
	
	for k, v in pairs( ents.GetAll() ) do self.entities[v] = v; end;
	
	-- Call the base class function.
	return self.BaseClass:InitPostEntity();
end;

-- Called when a player attempts to say something in-character.
function GM:PlayerCanSayIC(player, text)
	if (!player:Alive() or player._KnockedOut and string.sub(text, 1, 6) != "/admin") then
		evorp.player.notify(player, "You cannot talk in this state!", 1);
		
		-- Return false because we can't say anything.
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to say something in OOC.
function GM:PlayerCanSayOOC(player, text)
	if (player:IsAdmin()) then return true end
	if not (player._NextOOC) then player._NextOOC = 0; end
	if not (CurTime() > player._NextOOC) then
		evorp.player.notify(player, "You may not use this command yet!", 1);
		return false;
	end
	if (evorp.player.hasAccess(player, "u")) then
		player._NextOOC = CurTime() + 10;
		return true;
	else
		evorp.player.notify(player, "You are banned from using OOC chat.", 1);
		
		-- Return false because we cannot talk out-of-character.
		return false;
	end;
end;

-- Called when a player attempts to say something in local OOC.
function GM:PlayerCanSayLOOC(player, text) return true; end;

-- Called when attempts to use a command.
function GM:PlayerCanUseCommand(player, command, arguments)
	if (command == "admin") then return true end
	if (command == "wakeup" and player:Alive() and !player.evorp._Arrested and player._Sleeping) then
		return true;
	else
		if (!player:Alive() or player._KnockedOut or player.evorp._Arrested) then
			evorp.player.notify(player, "You cannot do that in this state!", 1);
			
			-- Return false because we can't say anything.
			return false;
		else
			return true;
		end;
	end;
end;

-- Called when a player says something.
function GM:PlayerSay(player, text, public)
	
	-- Fix Valve's errors.
	text = string.Replace(text, " ' ", "'");
	text = string.Replace(text, " : ", ":");
	
	-- Check if we're speaking on OOC.
	if (string.sub(text, 1, 2) == "//") then
		if (string.Trim( string.sub(text, 3) ) != "") then
			if ( hook.Call("PlayerCanSayOOC", GAMEMODE, player, text) ) then
				EVPlayerLog(player, text, public);
				evorp.chatBox.add( nil, player, "ooc", string.Trim( string.sub(text, 3) ) );
			end;
		end;
	elseif (string.sub(text, 1, 3) == ".//") then
		if (string.Trim( string.sub(text, 4) ) != "") then
			if ( hook.Call("PlayerCanSayLOOC", GAMEMODE, player, text) ) then
				EVPlayerLog(player, text, public);
				evorp.chatBox.addInRadius(player, "looc", string.Trim( string.sub(text, 4) ), player:GetPos(), evorp.configuration["Talk Radius"]);
			end;
		end;
	else
		if ( string.sub(text, 1, 1) == evorp.configuration["Command Prefix"] ) then
			evorp.command.ConCommand(player, string.sub(text, 2));
		else
			if ( hook.Call("PlayerCanSayIC", GAMEMODE, player, text) ) then	
				EVPlayerLog(player, text, public);
				if (player.evorp._Arrested) then
					evorp.chatBox.addInRadius(player, "arrested", text, player:GetPos(), evorp.configuration["Talk Radius"]);
				else
					evorp.chatBox.addInRadius(player, "ic", text, player:GetPos(), evorp.configuration["Talk Radius"]);
				end;
			end;
		end;
		
	end;
	
	-- Return an empty string so the text doesn't show.
	return "";
end;

-- Called when a player attempts suicide.
function GM:CanPlayerSuicide(player) return false; end;

hook.Add( "CanProperty", "canprophook", function( ply, property, ent )
	ret = false;
	if (ply.evorp._Donator > os.time() or ply.evorp._AdminLevel > 2) and (property == "skin" or property == "bodygroups") and (ent:CPPIGetOwner() == ply) then
		ret = true;
	end
	if (ply.evorp._AdminLevel > 4) then ret = true end
	return ret;
end )

function GM:CanProperty( ply, property, ent ) end

-- Called when a player attempts to punt an entity with the gravity gun.
function GM:GravGunPunt(player, entity) return false; end;

-- Called when a player attempts to pick up an entity with the physics gun.
function GM:PhysgunPickup(player, entity)
	if (self.entities[entity]) then return false; end;
	
	-- Check if the player is an administrator.
	if ( player:IsAdmin() ) then
		if ( entity:IsPlayer() ) then
			if ( !entity:InVehicle() ) then
				entity:SetMoveType(MOVETYPE_NOCLIP);
			else
				return false;
			end;
		end;
		
		-- Return true because administrators can pickup any entity.
		return true;
	end;
	
	-- Check if this entity is a player's ragdoll.
	if ( IsValid(entity._Player) ) then return false; end;
	
	-- Check if the entity is a forbidden class.
	if ( string.find(entity:GetClass(), "npc_" or entity:IsRagdoll( ))
	or string.find(entity:GetClass(), "prop_dynamic") ) then
		return false;
	end;
	
	-- Call the base class function.
	return self.BaseClass:PhysgunPickup(player, entity);
end;

-- Called when a player attempts to drop an entity with the physics gun.
function GM:PhysgunDrop(player, entity)
	if ( entity:IsPlayer() ) then entity:SetMoveType(MOVETYPE_WALK); end;
end;

-- Called when a player attempts to spawn an NPC.
function GM:PlayerSpawnNPC(player, model)
	-- Check if the player is an administrator.
	if ( player:IsSuperAdmin() ) then
		return true;
	else
		return false;
	end;
end;

-- Called when a player attempts to spawn a prop.
function GM:PlayerSpawnProp(player, model)
	local hours = math.floor((player:GetNetworkedInt("evorp_PlayTime", 0) + (os.time() - player:GetNetworkedInt("evorp_JoinCurTime", 0))) / 3600)
	if (hours < 2) then
		evorp.player.notify(player, "You need atleast two hours of playtime to spawn props.", 0)
		return false; 
	end
	if ( !evorp.player.hasAccess(player, "e") ) then 
		evorp.player.notify(player, "You are banned from spawning props.", 1)
		return false; 
	end;
	
	-- Check if the player can spawn this prop.
	if (!player:Alive() or player.evorp._Arrested or player._KnockedOut) then
		evorp.player.notify(player, "You cannot do that in this state!", 1);
		
		-- Return false because we cannot spawn it.
		return false;
	end;
	
	-- Check if the player is an administrator.
	if ( player:IsSuperAdmin() ) then return true; end;
	
	local maxprops = 15;
	if (player.evorp._Donator > os.time()) then maxprops = 20 end;
	if (player:IsAdmin()) then maxprops = 20; end
	if (player:GetCount("props") >= maxprops) then evorp.player.notify(player, "You have hit the prop limit!", 1); return false; end;
	
	-- Escape the bad characters from the model.
	model = string.Replace(model, "\\", "/");
	model = string.Replace(model, "//", "/");
	
	-- Loop through our banned props to see if this one is banned.
	if ( evorp.configuration["Banned Props"][string.lower(model)] ) or string.find(string.lower(model), "models/xqm/coastertrack") or string.find(string.lower(model), "models/props_explosive")  then
		evorp.player.notify(player, "This prop is banned!", 1);
		-- Return false because we cannot spawn it.
		return false;
	end;
	
	-- Call the base class function.
	return self.BaseClass:PlayerSpawnProp(player, model);
end;

function GM:PlayerSpawnedRagdoll(ply, model, ent )
	if (IsValid(ent)) then
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end
end

-- Called when a player attempts to spawn a ragdoll.
function GM:PlayerSpawnRagdoll(player, model)
	return false;

	--[[
	if (!player:Alive() or player.evorp._Arrested or player._KnockedOut) then
		evorp.player.notify(player, "You cannot do that in this state!", 1);
		
		-- Return false because we cannot spawn it.
		return false;
	end;
	
	-- Check if the player is an administrator.
	if ( !player:IsSuperAdmin() ) then
		return false;
	else
		return true;
	end;]]
end;

-- Called when a player attempts to spawn an effect.
function GM:PlayerSpawnEffect(player, model)
	if (!player:Alive() or player.evorp._Arrested or player._KnockedOut) then
		evorp.player.notify(player, "You cannot do that in this state!", 1);
		
		-- Return false because we cannot spawn it.
		return false;
	end;
	
	-- Check if the player is an administrator.
	if ( !player:IsAdmin() ) then
		return false;
	else
		return true;
	end;
end;

function GM:PlayerSpawnedVehicle(player, vehicle)
	local model = vehicle:GetModel()
	if (model == "models/nova/airboat_seat.mdl" or model == "models/nova/jeep_seat.mdl" or model == "models/nova/chair_wood01.mdl" or model == "models/nova/chair_office02.mdl" or model == "models/nova/chair_plastic01.mdl") then
		--if not (player.evorp._Donator > os.time()) then
		player._SpawnedChair = vehicle;
		--end
	end
end

-- Called when a player attempts to spawn a vehicle.
function GM:PlayerSpawnVehicle(player, model)
	if (model == "models/nova/airboat_seat.mdl" or model == "models/nova/jeep_seat.mdl" or model == "models/nova/chair_wood01.mdl" or model == "models/nova/chair_office02.mdl" or model == "models/nova/chair_plastic01.mdl") then
		if ( !evorp.player.hasAccess(player, "e") ) then 
			evorp.player.notify(player, "You are banned from spawning.", 1)
			return false; 
		end;
		if IsValid(player._SpawnedChair) then
			evorp.player.notify(player, "You already have a spawned chair!", 1);
			return false; 
		else
			return true;
		end
	end
	if (player.evorp._AdminLevel > 4) then
		return true
	else
		return false
	end
end;


-- A function to check whether we're running on a listen server.
function GM:IsListenServer()
	for k, v in pairs( g_Player.GetAll() ) do
		if ( v:IsListenServerHost() ) then return true; end;
	end;
	
	-- Check if we're running on single player.
	if ( game.SinglePlayer() ) then return true; end;
	
	-- Return false because there is no listen server host and it isn't single player.
	return false;
end;

-- Called when a player attempts to use a tool.
function GM:CanTool(player, trace, tool)
	if (IsValid(trace.Entity)) then 
		if tool == "remover" and !trace.Entity:GetOwner():IsWorld() and player.evorp._AdminLevel > 0 then return true end;
		if trace.Entity.nodupe then return false end
		local  constraints = constraint.GetAllConstrainedEntities(trace.Entity);
	
		-- Loop through the constained entities.
		for k, v in pairs(constraints) do
			if (IsValid(v) and v.nodupe) then return false; end;
		end
	end

	--if ( player:IsAdmin() ) then return true; end;
	
	-- Check if the trace entity is valid.
	if ( IsValid(trace.Entity) ) then
		if (tool == "nail") then
			local line = {};
			
			-- Set the information for the trace line.
			line.start = trace.HitPos;
			line.endpos = trace.HitPos + player:GetAimVector() * 16;
			line.filter = {player, trace.Entity};
			
			-- Perform the trace line.
			line = util.TraceLine(line);
			
			-- Check if the trace entity is valid.
			if ( IsValid(line.Entity) ) then
				if (self.entities[line.Entity]) then return false; end;
			end;
		end
		
		-- Check if we're using the remover tool and we're trying to remove constrained entities.
		if ( tool == "remover" and player:KeyDown(IN_ATTACK2) and !player:KeyDownLast(IN_ATTACK2) ) then
			local entities = constraint.GetAllConstrainedEntities(trace.Entity);
			
			-- Loop through the constained entities.
			for k, v in pairs(entities) do
				if (self.entities[v]) then return false; end;
			end
		end
		
		-- Check if this entity cannot be used by the tool.
		if (self.entities[trace.Entity]) then return false; end;
		
		-- Check if this entity is a player's ragdoll.
		if ( IsValid(trace.Entity._Player) ) then return false; end;
	end;
	
	-- Call the base class function.
	return self.BaseClass:CanTool(player, trace, tool);
end;

-- Called when a player attempts to noclip.
function GM:PlayerNoClip(player)
	if ( player:IsAdmin() or player:GetUserGroup() == "moderator") then
		return true;
	else
		return false;
	end;
end;

-- Called when the player has initialized.
function GM:PlayerInitialized(player) end;

local celebrateseventy = false;

timer.Create("Salary", evorp.configuration["Salary Interval"], 0, function()
	local timeStart = SysTime()
	local totalplayers = table.Count(g_Player.GetAll( ))
	--Remember to remove
	if (totalplayers == 70 and !celebrateseventy) then
		celebrateseventy = true;

		for k, player in pairs( g_Player.GetAll() ) do
			if (IsValid(player)) then
				if (player._Initialized) then
					evorp.player.giveMoney(player, 10000);
					
					-- Print a message to the player letting them know they received their salary.
					evorp.player.notify(player, "You received $10000!! WE HIT 70 PLAYERS!.", 0);
				end;
			end
		end;
	end


	local govplayers = g_Team.NumPlayers(TEAM_SS) + g_Team.NumPlayers(TEAM_HOSS) + g_Team.NumPlayers(TEAM_PRESIDENT) + g_Team.NumPlayers(TEAM_COMMANDER) + g_Team.NumPlayers(TEAM_OFFICER) + g_Team.NumPlayers(TEAM_SECRETARY) + g_Team.NumPlayers(TEAM_PARAMEDIC) + g_Team.NumPlayers(TEAM_FIREMAN)
	local taxsplit = math.floor(((totalplayers - govplayers) * 25) / govplayers);
	for k, player in pairs( g_Player.GetAll() ) do
		if (IsValid(player)) then
			if (player._Initialized and player:Alive() and !player.evorp._Arrested) then
				local payable = player._Salary;
				if (evorp.team.query(player:Team(), "radio", "") != "R_GOV") then
					payable = payable - 25;
				else
					payable = payable + taxsplit;
				end
				evorp.player.giveMoney(player, payable);
				
				-- Print a message to the player letting them know they received their salary.
				evorp.player.notify(player, "You received $"..payable.." as salary.", 0);
				evorp.player.saveData(player);
			end;
		end
	end;
	local text = "EVORP CYCLE #"..GetGlobalInt( "evorp_cycle" ).." COMPLETED IN "..SysTime()-timeStart.." WITH "..totalplayers.." players.";
	exsto.GetPlugin("logs"):SaveEvent(text, "evorp")
	--print(text)
	SetGlobalInt( "evorp_cycle", GetGlobalInt( "evorp_cycle" ) + 1 )
end);




-- Called when a player's data is loaded.
function GM:PlayerDataLoaded(player, success)
	player._Job = evorp.configuration["Default Job"];
	player._Ammo = {};
	player._Gender = "Male";
	player._Salary = 0;
	player._Ragdoll = {};
	player._Sleeping = false;
	player._Warranted = false;
	player._LightSpawn = false;
	player._ScaleDamage = false;
	player._Initialized = true;
	player._ChangeTeam = false;
	player._NextChangeTeam = {};
	player._NextSpawnGender = "";
	player._HideHealthEffects = false;
	player._CannotBeWarranted = 0;
	
	-- Some player variables based on configuration.
	player._SpawnTime = evorp.configuration["Spawn Time"];
	player._KnockOutTime = evorp.configuration["Knock Out Time"];
	player._ArrestTime = 360;

	-- Call a hook for the gamemode.
	hook.Call("PlayerInitialized", GAMEMODE, player);
	
	-- Respawn them now that they have initialized and then freeze them.
	player:Spawn();
	player:Freeze(true);
	
	-- Unfreeze them in a second from now.
	timer.Simple(1, function()
		if ( IsValid(player) ) then
			player:Freeze(false);
			
			-- We can now start updating the player's data.
			if (success) then
				player._UpdateData = true;
			end

			player:SetNetworkedInt("evorp_PlayTime", player.evorp._PlayTime);
			player:SetNetworkedInt("evorp_JoinCurTime", os.time());
			NettyPlayerConnect(player)
			-- Send a user message to remove the loading screen.
			umsg.Start("evorp.player.initialized", player); umsg.End();
		end;
	end);
	
	-- Check if the player is arrested.
	if (player.evorp._Arrested) then evorp.player.arrest(player, true, true); end;
end;

-- Called when a player initially spawns.
function GM:PlayerInitialSpawn(player)

	if ( IsValid(player) ) then

		evorp.player.loadData(player);
		

		player:SetNetworkedInt("LastRevive", -300)
		-- A table of valid door classes.
		local doorClasses = {
			"func_door",
			"func_door_rotating",
			"prop_door_rotating",
			"prop_dynamic",
			"prop_vehicle_jeep"
		};
		
		-- Loop through our table of valid door classes.
		for k, v in pairs(doorClasses) do
			for k2, v2 in pairs( ents.FindByClass(v) ) do
				if ( evorp.entity.isDoor(v2) ) then
					if (player:UniqueID() == v2._UniqueID) then
						v2._Owner = player;
						
						-- Set the networked owner so that the client can get it.
						v2:SetNetworkedEntity("evorp_Owner", player);
					end;
				end;
			end;
		end;
		
		-- A table to store every contraband entity.
		local contraband = {};
		
		-- Loop through each contraband class.
		for k, v in pairs( evorp.configuration["Contraband"] ) do
			table.Add( contraband, ents.FindByClass(k) );
		end;
		
		-- Loop through all of the contraband.
		for k, v in pairs(contraband) do
			if (player:UniqueID() == v._UniqueID) then v:SetPlayer(player); end;
		end;
		
		-- Kill them silently until we've loaded the data.
		--player:KillSilent();
	end;
end

-- Called every frame that a player is dead.
function GM:PlayerDeathThink(player)
	if (!player._Initialized) then return true; end;
	
	-- Check if the player is a bot.
	if (player:SteamID() == "BOT") then
		if (player.NextSpawnTime and CurTime() >= player.NextSpawnTime) then player:Spawn(); end;
	end;
	
	-- Return the base class function.
	return self.BaseClass:PlayerDeathThink(player);
end;

-- Called when a player's salary should be adjusted.
function GM:PlayerAdjustSalary(player) end;
--[[
function GM:ShouldCollide( ent1, ent2 )
	if (ent1.GST and IsValid(ent1) and IsValid(ent2)) then
		local ret = true;
		local class = string.lower(ent2:GetClass());
		if (class == "player" or string.find(class, "prop_vehicle")) then
			ret = false;
		end
		return ret;
	end
	return self.BaseClass:ShouldCollide(ent1, ent2)
end]]

-- Called when a player should gain a frag.
function GM:PlayerCanGainFrag(player, victim) return true; end;

-- Called when a player's model should be set.
function GM:PlayerSetModel(player)
	local models = evorp.team.query(player:Team(), "models");
	
	-- Check if the models table exists.
	if (models) then
		models = models[ string.lower(player._Gender) ];
		
		-- Check if the models table exists for this gender.
		if (models) then
			local model = models[ math.random(1, #models) ];
			
			-- Set the player's model to the we got.
			player:SetModel(model);
		end;
	end;
end;

-- Called when a player spawns.
function GM:PlayerSpawn(player)
	if (player._Initialized) then
		if (player._NextSpawnGender != "") then
			player._Gender = player._NextSpawnGender; player._NextSpawnGender = "";
		end;
		
		-- Set it so that the player does not drop weapons.
		player:ShouldDropWeapon(false);
		
		-- Check if we're not doing a light spawn.
		if (!player._LightSpawn) then
			-- Set some of the player's variables.

			player._Ammo = {};
			player._Sleeping = false;
			player._ScaleDamage = false;
			player._HideHealthEffects = false;
			player._CannotBeWarranted = CurTime() + 30;
			player:SetNetworkedBool("cuffed", false);
			player:SetNetworkedBool("hostaged", false)
			player:SetNetworkedBool("FakeDeathing", false)
			timer.Destroy("RealDeath_"..player:UniqueID())
			-- Make the player become conscious again.
			evorp.player.knockOut(player, false, nil, true);
			
			-- Set the player's model and give them their loadout.
			self:PlayerSetModel(player);
			self:PlayerLoadout(player);
			player._AttachmentKit = false;

			if (player._ChangeTeam and player._EVORPVehicle and IsValid(player._EVORPVehicle) and player._EVORPVehicle._Class) then
				player._EVORPVehicle:Remove()
			end
		end;
		if IsValid(player.BackGun) then
    	 		player.BackGun:Remove()
   	 	end
		
		local oldhands = player:GetHands()
		if ( IsValid( oldhands ) ) then oldhands:Remove() end

		local hands = ents.Create( "gmod_hands" )
		if ( IsValid( hands ) ) then
			player:SetHands( hands )
			hands:SetOwner( player )

			-- Which hands should we use?
			local cl_playermodel = player:GetInfo( "cl_playermodel" )
			local info = player_manager.TranslatePlayerHands( cl_playermodel )
			if ( info ) then
				hands:SetModel( info.model )
				hands:SetSkin( info.skin )
				hands:SetBodyGroups( info.body )
			end

			-- Attach them to the viewmodel
			local vm = player:GetViewModel( 0 )
			hands:AttachToViewmodel( vm )

			vm:DeleteOnRemove( hands )
			player:DeleteOnRemove( hands )

			hands:Spawn()
		end
	
		-- Call a gamemode hook for when the player has finished spawning.
		hook.Call("PostPlayerSpawn", GAMEMODE, player, player._LightSpawn, player._ChangeTeam);
		
		-- Set some of the player's variables.
		player._LightSpawn = false;
		player._ChangeTeam = false;
	else
		player:KillSilent();
	end;
end;

function GM:ShouldKnockOut(player, attacker)
	if (attacker and IsValid(attacker) and attacker:GetClass() == "prop_physics" or attacker:GetClass() == "worldspawn") then
		return true
	end
end

-- Called when a player should take damage.
function NoPropDMG(player, attacker) 
	--if (IsValid(attacker) and attacker:GetClass() == "prop_physics")  or (attacker:GetClass() == "worldspawn") then
	--	return false
	--end
end
 
hook.Add( "PlayerShouldTakeDamage", "NoPropDMG", NoPropDMG)

function GM:ShouldAct( ply, actname, actid )
	if not (ply:GetActiveWeapon() and ply:GetActiveWeapon() == "evorp_hands") then
		evorp.player.notify(player, "You can only use act commands with your hands out.", 0)
		return false;
	elseif (ply:InVehicle()) then
		evorp.player.notify(player, "You can't use act commands while you're inside a vehile or while sitting in a chair.", 0)
		return false;
	else
		return true;
	end
end
hook.Add( "PlayerShouldAct", "CanAct", ShouldAct );

-- Called when a player is attacked by a trace.
function GM:PlayerTraceAttack(player, damageInfo, direction, trace)
	player._LastHitGroup = trace.HitGroup;
	
	-- Return false so that we don't override internals.
	return false;
end;

-- Called just before a player dies.
function GM:DoPlayerDeath(player, attacker, damageInfo)
	--[[
	for k, v in pairs( player:GetWeapons() ) do
		local class = v:GetClass();
		
		-- Check if this is a valid item.
		if (evorp.item.stored[class]) then
			if ( hook.Call("PlayerCanDrop", GAMEMODE, player, class, true, attacker) ) then
				evorp.item.make( class.."Broken", player:GetPos(), 1 );
			end;
		end;
	end;

	-- Loop through the player's weapons drop them.
	if (player._Ragdoll.weapons) then
		for k, v in pairs(player._Ragdoll.weapons) do
			if (player._Ragdoll.weapons[v] and evorp.item.stored[ v[1] ]) then
				if ( hook.Call("PlayerCanDrop", GAMEMODE, player, v[1], true, attacker) ) then
					evorp.item.make( v[1].."Broken", player:GetPos(), 1 );
				end;
				player._Ragdoll.weapons[v] = 72;
			end;
		end
	end
	]]
	-- Strip the player's weapons and ammo.
	player:StripWeapons();
	player.evorp._Weps = "";
	
	-- Add a death to the player's death count.
	player:AddDeaths(1);
	
	-- Check it the attacker is a valid entity and is a player.
	if ( IsValid(attacker) and attacker:IsPlayer() ) then
		if (player != attacker) then
			if ( hook.Call("PlayerCanGainFrag", GAMEMODE, attacker, player) ) then
				attacker:AddFrags(1);
			end;
		end;
	end;
end;

-- Called when a player dies.
function GM:PlayerDeath(player, inflictor, attacker, ragdoll)
	evorp.player.warrant(player, false);
	evorp.player.arrest(player, false, true);
	evorp.player.bleed(player, false);
	player:StripAmmo();
	if (ragdoll != false) then
		player._Ragdoll.weapons = {};
		player._Ragdoll.health = player:Health();
		player._Ragdoll.model = player:GetModel();
		player._Ragdoll.team = player:Team();
		
		-- Knockout the player to simulate their death.
		evorp.player.knockOut(player, true);
	end;
	player._LastDeathTime = os.time();
	player._LastDeathLocation = player:GetPos();
	player:ConCommand("DrawDeathMsg")
	evorp.chatBox.add( nil, player, "nlr", player.evorp._NameIC.." ("..player:Nick()..") died." );
	-- Set their next spawn time.
	player.NextSpawnTime = CurTime() + player._SpawnTime;
	
	-- Set it so that we can the next spawn time client side.
	evorp.player.setLocalPlayerVariable(player, CLASS_LONG, "_NextSpawnTime", player.NextSpawnTime);

	if (player:Team() == TEAM_PRESIDENT) then
		if not (IsValid(attacker) and attacker:IsPlayer() and evorp.team.query(attacker:Team(), "radio", "") == "R_GOV" and !attacker:Team() == TEAM_PRESIDENT) then
			evorp.team.make(player, "Unemployed");
		end
	end
end;

-- Called when a player's weapons should be given.
function GM:PlayerLoadout(player)	
	-- Give the player the camera, the hands and the physics cannon.
	player:Give("evorp_hands"); -- Random placement? Yes.
	player:Give("gmod_camera");
	if (evorp.player.hasAccess(player, "t")) then player:Give("gmod_tool"); else evorp.player.notify(player, "You are temporarily banned from using the tool gun, you will not receive it.", 1); end;
	if (evorp.player.hasAccess(player, "p")) then player:Give("weapon_physgun"); else evorp.player.notify(player, "You are temporarily banned from using the physics gun, you will not receive it.", 1); end;
	-- Call the player loadout hook.
	evorp.plugin.call("playerLoadout", player);
end

-- Called when the server shuts down or the map changes.
function GM:ShutDown()
	for k, v in pairs( g_Player.GetAll() ) do
		--Contrarefund?
		
		-- Save the player's data.
		evorp.player.saveData(v);
	end;
end;

-- Called when a player presses F1.
function GM:ShowHelp(player) end;

-- Called when a player presses F2.
function GM:ShowTeam(player)
	local door = player:GetEyeTrace().Entity;
	
	-- Check if the player is aiming at a door.
	if ( IsValid(door) and evorp.entity.isDoor(door) ) then
		if (door:GetPos():Distance( player:GetPos() ) <= 128) then
			if ( hook.Call("PlayerCanViewDoor", GAMEMODE, player, door) ) then
				umsg.Start("evorp_Door", player);
					umsg.Bool(door._Unsellable or false);
					
					-- Check if the owner is a valid entity.
					if ( IsValid(door._Owner) ) then
						umsg.Entity(door._Owner);
					else
						umsg.Entity(NULL);
					end;
					
					-- Send the door as an entity and unsellable as a bool.
					umsg.Entity(door);
					
					-- Check if the door has access.
					if (door._Access) then
						for k, v in pairs( g_Player.GetAll() ) do
							if (v != door._Owner) then
								local uniqueID = v:UniqueID();
								
								-- Check if they have access.
								if (door._Access[uniqueID]) then
									umsg.Short( v:EntIndex() );
									umsg.Short(1);
								else
									umsg.Short( v:EntIndex() );
									umsg.Short(0);
								end;
							end;
						end;
					end;
				umsg.End();
			end;
		end;
	end;
end;

-- Called when an entity takes damage.
function GM:EntityTakeDamage(entity, damageInfo)
	local inflictor = damageInfo:GetInflictor();
	local attacker = damageInfo:GetAttacker();
	local amount= damageInfo:GetDamage();

	if (attacker and attacker:IsPlayer() and IsValid( attacker:GetActiveWeapon() )) then
		if attacker:GetActiveWeapon():GetClass() == "weapon_crowbar" then
			damageInfo:ScaleDamage(0.35);
		elseif attacker:GetActiveWeapon():GetClass() == "evorp_hands" then
			damageInfo:ScaleDamage(1);
		end
	end

	if (entity:GetClass() == "prop_vehicle_jeep") then
		if not (IsValid(attacker) and attacker:IsPlayer() and IsValid( attacker:GetActiveWeapon() ) and (attacker:GetActiveWeapon():GetClass() == "weapon_crowbar")) then
			--VehicleHealth(entity, damageInfo)
			if IsValid(entity:GetDriver()) then
				entity:GetDriver():TakeDamage(amount, attacker, inflictor)
			end
		end
	end
	
	-- Check if the entity that got damaged is a player.
	if ( entity:IsPlayer() ) then
		if not (entity:GetNetworkedBool("FakeDeathing")) then
			if (attacker:IsVehicle()) then
				--AMB_KillVelocity(attacker)
				evorp.player.knockOut(entity, true, 10);
				if (attacker:IsVehicle() and IsValid(attacker:GetDriver())) then
					--notifyAllAdm(attacker:GetDriver():Nick().." knocked out "..entity:Name().." with a car.", 0)
					evorp.player.printConsoleAccess(attacker:GetDriver():Nick().." knocked out "..entity:Name().." with a car.", "a", "kills", attacker);
				else
					evorp.player.printConsoleAccess(entity:Nick().." got knocked out by "..attacker:GetClass().." ["..attacker:EntIndex().."]", "a", "kills", attacker);
				end
				return
			end
			if (entity._KnockedOut) then
				if ( IsValid(entity._Ragdoll.entity) ) then
					hook.Call("EntityTakeDamage", GAMEMODE, entity._Ragdoll.entity, damageInfo);
				end;
			else
				if ( entity:InVehicle() and damageInfo:IsExplosionDamage() ) then
					if (!damageInfo:GetDamage() or damageInfo:GetDamage() == 0) then
						damageInfo:SetDamage(100);
					end;
				end;
				-- Check if the player has a last hit group defined.
				--[[
				if (entity._LastHitGroup) then
					if (entity._LastHitGroup == HITGROUP_HEAD) then
						damageInfo:ScaleDamage( evorp.configuration["Scale Head Damage"] );
					elseif (entity._LastHitGroup == HITGROUP_CHEST or entity._LastHitGroup == HITGROUP_GENERIC) then
						damageInfo:ScaleDamage( evorp.configuration["Scale Chest Damage"] );
					elseif (entity._LastHitGroup == HITGROUP_LEFTARM or
					entity._LastHitGroup == HITGROUP_RIGHTARM or 
					entity._LastHitGroup == HITGROUP_LEFTLEG or
					entity._LastHitGroup == HITGROUP_RIGHTLEG or
					entity._LastHitGroup == HITGROUP_GEAR) then
						damageInfo:ScaleDamage( evorp.configuration["Scale Limb Damage"] );
					end;
					
					-- Set the last hit group to nil so that we don't use it again.
					entity._LastHitGroup = nil;
				end;
				
				-- Check if the player is supposed to scale damage.
				if (entity._ScaleDamage) then damageInfo:ScaleDamage(entity._ScaleDamage); end;
				]]
				-- Make the player bleed.
				evorp.player.bleed( entity, true, evorp.configuration["Bleed Time"] );
				local player = entity;
				if player:InVehicle() then player:SetHealth( math.max(player:Health() - damageInfo:GetDamage(), 0) ) damageInfo:SetDamage(0) end
				if (player:Health() - damageInfo:GetDamage() <= 0 and player:Alive()) then
					if not (hook.Call( "PlayerShouldTakeDamage", GAMEMODE, player, attacker )) then return end
					if (IsValid(attacker)) then 
						if ( attacker:IsPlayer() ) then
							if ( IsValid( attacker:GetActiveWeapon() ) ) then
								evorp.player.printConsoleAccess(attacker:Name().. " [".. attacker:SteamID() .. "] killed "..player:Name().. " [".. player:SteamID() .. "] with "..attacker:GetActiveWeapon():GetClass()..".", "a", "kills", attacker);
							else
								evorp.player.printConsoleAccess(attacker:Name().. " [".. attacker:SteamID() .. "] killed "..player:Name().. " [".. player:SteamID() .. "].", "a", "kills", attacker);
							end;
						else
							local str = attacker:GetClass();
							if (IsValid(attacker) and string.find(str, "prop_vehicle_jeep") and IsValid(attacker:GetDriver())) then
								evorp.player.printConsoleAccess(attacker:GetDriver():Nick().." killed "..player:Name().." with a car.", "a", "kills", attacker);
								notifyAllAdm(attacker:GetDriver():Nick().." killed "..player:Name().." with a car.", 1)
							end
							evorp.player.printConsoleAccess(str.." killed "..player:Name().. " [".. player:SteamID() .. "]"..".", "a", attacker);
						end;
					end
					if (CurTime() > player:GetNetworkedInt("LastRevive") + 150) then
						player:SetNetworkedBool("FakeDeathing", true)
						player:SetNetworkedInt("FakeDeathTimer", CurTime() + 120)
						evorp.player.knockOut(player, true);
						player._FakePlayer = player;
						player._FakeAttacker = attacker;
						player._FakeDmgInfo = damageInfo;
						player._FakeInflictor = inflictor;
						hook.Call("DoPlayerDeath", GAMEMODE, player, attacker, damageInfo);
						timer.Create( "RealDeath_"..player:UniqueID(), 120, 1, function()
							if not (IsValid (player)) then return end
							player:KillSilent();
							player:SetNetworkedBool("FakeDeathing", false)
							-- Call some gamemode hooks to fake the player's death.
							hook.Call("PlayerDeath", GAMEMODE, player, inflictor, attacker, true);
							player.NextSpawnTime = CurTime();
							evorp.player.setLocalPlayerVariable(player, CLASS_LONG, "_NextSpawnTime", player.NextSpawnTime);
						end)
						player:SetHealth(0);
					else
						player:KillSilent();
						hook.Call("DoPlayerDeath", GAMEMODE, player, attacker, damageInfo);
						hook.Call("PlayerDeath", GAMEMODE, player, inflictor, attacker, true);
					end
					return
				end
			end;
		end
	elseif ( entity:IsNPC() ) then
		if (attacker and attacker:IsPlayer() and IsValid( attacker:GetActiveWeapon() )
		and attacker:GetActiveWeapon():GetClass() == "weapon_crowbar") then
			damageInfo:ScaleDamage(0.25);
		end;
	end;
	
	-- Check if the entity is a knocked out player.
	if ( IsValid(entity._Player) ) then
		local player = entity._Player;
		if not (entity:GetNetworkedBool("FakeDeathing")) then
			-- Set the damage to the amount we're given.
			if (damageInfo) then
				damageInfo:SetDamage(amount);
			end
			-- Check if the attacker is not a player.
			if ( !attacker:IsPlayer() ) then
				if ( attacker == game.GetWorld() ) then
					if ( ( entity._NextWorldDamage and entity._NextWorldDamage > CurTime() )
					or damageInfo:GetDamage() <= 10 ) then return; end;
					
					-- Set the next world damage to be 1 second from now.
					entity._NextWorldDamage = CurTime() + 1;
				else
					if (damageInfo:GetDamage() <= 25) then return; end;
				end;
			else
				damageInfo:ScaleDamage( evorp.configuration["Scale Ragdoll Damage"] );
			end;
			
			-- Check if the player is supposed to scale damage.
			if (entity._Player._ScaleDamage) then damageInfo:ScaleDamage(entity._Player._ScaleDamage); end;
			
			-- Take the damage from the player's health.
			player:SetHealth( math.max(player:Health() - damageInfo:GetDamage(), 0) );
			
			-- Set the player's conscious health.
			player._Ragdoll.health = player:Health();
			
			-- Create new effect data so that we can create a blood impact at the damage position.
			local effectData = EffectData();
				effectData:SetOrigin( damageInfo:GetDamagePosition() );
			util.Effect("BloodImpact", effectData);
			
			-- Loop from 1 to 4 so that we can draw some blood decals around the ragdoll.
			for i = 1, 2 do
				local trace = {};
				
				-- Set some settings and information for the trace.
				trace.start = damageInfo:GetDamagePosition();
				trace.endpos = trace.start + (damageInfo:GetDamageForce() + (VectorRand() * 16) * 128);
				trace.filter = entity;
				
				-- Create the trace line from the set information.
				trace = util.TraceLine(trace);
				
				-- Draw a blood decal at the hit position.
				util.Decal("Blood", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal);
			end;
			
			-- Check to see if the player's health is less than 0 and that the player is alive.
			if ( player:Health() <= 0 and player:Alive() ) then
				if not (player:GetNetworkedBool("FakeDeathing")) then
					if not (hook.Call( "PlayerShouldTakeDamage", GAMEMODE, player, attacker )) then return end
					-- Check if the attacker is a player.
					if (IsValid(attacker)) then 
						if ( attacker:IsPlayer() ) then
							if ( IsValid( attacker:GetActiveWeapon() ) ) then
								evorp.player.printConsoleAccess(attacker:Name().. " [".. attacker:SteamID() .. "] killed "..player:Name().. " [".. player:SteamID() .. "] with "..attacker:GetActiveWeapon():GetClass()..".", "a", "kills", attacker);
							else
								evorp.player.printConsoleAccess(attacker:Name().. " [".. attacker:SteamID() .. "] killed "..player:Name().. " [".. player:SteamID() .. "].", "a", "kills", attacker);
							end;
						else
							local str = attacker:GetClass();
							if (IsValid(attacker) and string.find(str, "prop_vehicle_jeep") and IsValid(attacker:GetDriver())) then
								notifyAllAdm(attacker:GetDriver():Nick().." killed "..player:Name().." with a car.", 1)
							end
							evorp.player.printConsoleAccess(str.." killed "..player:Name().. " [".. player:SteamID() .. "]"..".", "a", "kills", attacker);
						end;
					end
					if (CurTime() > player:GetNetworkedInt("LastRevive") + 150) then
						player._FakePlayer = player;
						player._FakeAttacker = attacker;
						player._FakeDmgInfo = damageInfo;
						player._FakeInflictor = inflictor;
						player:SetNetworkedBool("FakeDeathing", true)
						player:SetNetworkedInt("FakeDeathTimer", CurTime() + 120)
						timer.Destroy("Become Conscious: "..player:UniqueID())
						hook.Call("DoPlayerDeath", GAMEMODE, player, attacker, damageInfo);
						timer.Create( "RealDeath_"..player:UniqueID(), 120, 1, function()
							if not (IsValid (player)) then return end
							player:KillSilent();
							player:SetNetworkedBool("FakeDeathing", false)
							-- Call some gamemode hooks to fake the player's death.
							hook.Call("PlayerDeath", GAMEMODE, player, inflictor, attacker, true);
							player.NextSpawnTime = CurTime();
							evorp.player.setLocalPlayerVariable(player, CLASS_LONG, "_NextSpawnTime", player.NextSpawnTime);
						end)
					else
						player:KillSilent();
						hook.Call("DoPlayerDeath", GAMEMODE, player, attacker, damageInfo);
						hook.Call("PlayerDeath", GAMEMODE, player, inflictor, attacker, true);
					end
				end
			end;
		end
	end;
end; 

-- Called when a player has disconnected.
function GM:PlayerDisconnected(player)
	if not (!player:Alive() or player:GetNetworkedBool("hostaged") or player:GetNetworkedBool("FakeDeathing") or player:GetNetworkedBool("cuffed") or player._KnockedOut) then
		evorp.player.holsterAll(player);
	end
	if (player._Ragdoll and player._Ragdoll.weapons) then
		player._Ragdoll.weapons = false;
	end

	evorp.player.knockOut(player, false, nil, true);
	
	-- Save the player's data.
	evorp.player.saveData(player);
	
	-- Call the base class function.
	self.BaseClass:PlayerDisconnected(player);
end;

-- Called when a player attempts to spawn a SWEP.
function GM:PlayerSpawnSWEP(player, class, weapon)
	if not ( player.evorp._AdminLevel > 4 ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player is given a SWEP.
function GM:PlayerGiveSWEP(player, class, weapon)
	if  not ( player.evorp._AdminLevel > 4 ) then
		return false;
	else
		player._SpawnWeapons[class] = true;
		return true;
	end;
end;

-- Called when attempts to spawn a SENT.
function GM:PlayerSpawnSENT(player, class)
	if not ( player.evorp._AdminLevel > 4) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player presses a key.
function GM:KeyPress(player, key)
	if (player.LastControl and player.LastControl + .5 > CurTime()) then
		return
	end
	player.LastControl = CurTime()
	if (key == IN_WALK and player:InVehicle()) then
		local dist1 = 0;
		local dist2 = 0;
		if string.lower(game.GetMap()) == "rp_evocity_v2d_sexy_v2" then
			dist1 = player:GetPos():Distance(Vector( -6498, -6615, 72 ))
			dist2 =player:GetPos():Distance(Vector( -6494, -6320, 72 ))
		end
		if string.lower(game.GetMap()) == "rp_evocity_v2d" then
			dist1 = player:GetPos():Distance(Vector( -6494, -6550, 72 ))
			dist2 =player:GetPos():Distance(Vector( -6494, -6255, 72 ))
		end
		if string.lower(game.GetMap()) == "rp_evocity_v33x" then
			dist1 = player:GetPos():Distance(Vector( -6485, -6555, 72 ))
			dist2 =player:GetPos():Distance(Vector( -6485, -6320, 72 ))
			if (player:GetPos():Distance(Vector( 10796, 13418, 58 )) < 325 or player:GetPos():Distance(Vector( 9991, 13419, 58 )) < 325) then
				dist1 = 1; dist2 = 1;
			end
		end
		if string.lower(game.GetMap()) == "rp_chaos_city_v33x_03" then
			dist1 = player:GetPos():Distance(Vector( 4131, 535, -1876 ))
			dist2 =player:GetPos():Distance(Vector( 4124, 288, -1876 ))
			if (player:GetPos():Distance(Vector( -7361, 5234, -1489 )) < 500 or player:GetPos():Distance(Vector( -8282, 5223, -1489 )) < 500) then
				dist1 = 1; dist2 = 1;
			end
		end
		if (dist1 > 250 and dist2 > 250) then
			return
		end
		local fee = 300
		if (player.evorp._Donator > os.time()) then fee = 150 end;
		if evorp.player.canAfford(player, fee) then
			evorp.player.giveMoney(player, -fee);
			player:GetVehicle()._Fuel = 100;
			player:GetVehicle():SetNetworkedInt("fuel", 100)
			evorp.player.notify(player, "Your vehicle has been refueled!", 0)
		else
			evorp.player.notify(player, "Not enough money!", 1)
		end
	end
	if (key == IN_USE) then
		local trace = player:GetEyeTrace();
		if ( IsValid(trace.Entity) and trace.Entity.iDoorSID ) then 
			if (evorp.player.hasDoorAccess(player, trace.Entity)  ) then
				if not (trace.Entity:GetNetworkedBool("dlocked")) then
					if (trace.Entity.iOpen) then
						trace.Entity:Fire("setanimation", "close", "0");
						trace.Entity.iOpen = false
					else
						trace.Entity:Fire("setanimation", "open", "0");
						trace.Entity.iOpen = true
					end
				else
					trace.Entity:EmitSound("doors/door_latch3.wav")
				end
			end
        		end
	end
	if (key == IN_JUMP and player._StuckInWorld) then
		UnstuckPlayer(player)
		--evorp.player.holsterAll(player);
		
		-- Spawn them lightly now that we holstered their weapons.
		--evorp.player.lightSpawn(player);
	end;
end;

-- Create a timer to automatically clean up decals.
timer.Create("Cleanup Decals", 60, 0, function()
	if ( evorp.configuration["Cleanup Decals"] ) then
		for k, v in pairs( g_Player.GetAll() ) do v:ConCommand("r_cleardecals\n"); end;
	end;
end);

-- Create a timer to give players money for their contraband.
timer.Create("Contraband", evorp.configuration["Contraband Interval"], 0, function()
	local players = {};
	local contraband = {};
	
	-- Loop through each contraband class.
	for k, v in pairs( evorp.configuration["Contraband"] ) do
		table.Add( contraband, ents.FindByClass(k) );
	end;
	
	-- Loop through all of the contraband.
	for k, v in pairs(contraband) do
		local player = v:GetPlayer();
		
		-- Check if the player is a valid entity,
		if ( IsValid(player) and player:Team() != TEAM_PRESIDENT and player:Team() != TEAM_HOSS and player:Team() != TEAM_SS and player:Team() != TEAM_COMMANDER and player:Team() != TEAM_OFFICER) then
			players[player] = players[player] or {refill = 0, money = 0};
			
			-- Decrease the energy of the contraband.
			v._Energy = math.Clamp(v._Energy - 1, 0, 5);
			
			-- Set the networked variable so that the client can use it.
			v:SetNetworkedInt("evorp_Energy", v._Energy);
			v:SetNetworkedInt("evorp_CMoney", (5-v._Energy) * evorp.configuration["Contraband"][ v:GetClass() ].money);
			
			-- Check the energy of the contraband.
			if (v._Energy == 0) then
				players[player].refill = players[player].refill + 1;
			else
				--players[player].money = players[player].money + evorp.configuration["Contraband"][ v:GetClass() ].money;
			end;
		end;
	end;
	
	-- Loop through our players list.
	for k, v in pairs(players) do
		if ( hook.Call("PlayerCanContraband", GAMEMODE, k) ) then
			if (v.refill > 0) then
				evorp.player.notify(k, v.refill.." of your contraband need refilling!", 1);
			elseif (v.money > 0) then
				--evorp.player.notify(k, "You earned $"..v.money.." from contraband.", 0);
				
				-- Give the player their money.
				--evorp.player.giveMoney(k, v.money);
			end;
		end;
	end;
	
end);

timer.Create("SpawnPropPhysRemover", 20, 0, function() 
	local mapname = string.lower(game.GetMap());
	if mapname == "rp_chaos_city_v33x_03" then
		for _, ent in pairs(ents.FindInSphere(Vector( 6765, -5554, -1868 ), 700)) do
			if (string.find( ent:GetClass( ), "prop_physics" )) then
				ent:Remove()
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( 6413, -5552, -1868 ), 700)) do
			if (string.find( ent:GetClass( ), "prop_physics" )) then
				ent:Remove()
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( 6038, -5548, -1868 ), 700)) do
			if (string.find( ent:GetClass( ), "prop_physics" )) then
				ent:Remove()
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( 5765, -5495, -1868 ), 700)) do
			if (string.find( ent:GetClass( ), "prop_physics" )) then
				ent:Remove()
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( 5325, -5289, 1868 ), 300)) do
			if (string.find( ent:GetClass( ), "prop_physics" )) then
				ent:Remove()
			end
		end
	end
	if mapname == "rp_evocity_v2d" or mapname == "rp_evocity_v33x" or mapname == "rp_evocity_v2d_sexy_v2" then
		for _, ent in pairs(ents.FindInSphere(Vector( -3427, -10392, 71 ), 700)) do
			if (string.find( ent:GetClass( ), "prop_physics" )) then
				ent:Remove()
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -4062, -10399, 71 ), 700)) do
			if (string.find( ent:GetClass( ), "prop_physics" )) then
				ent:Remove()
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -4645, -10404, 71 ), 700)) do
			if (string.find( ent:GetClass( ), "prop_physics" )) then
				ent:Remove()
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -5170, -10384, 71 ), 700)) do
			if (string.find( ent:GetClass( ), "prop_physics" )) then
				ent:Remove()
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -5531, -10094, 71 ), 300)) do
			if (string.find( ent:GetClass( ), "prop_physics" )) then
				ent:Remove()
			end
		end
	end
end)

timer.Create("Vehicles", 2, 0, function()
	for _, v in ipairs( g_Player.GetAll() ) do
		--print(v:GetPos())
		if (IsValid(v) and v:InVehicle()) then
			local vehicle = v:GetVehicle()
			if (vehicle._Fuel) then
				local eph = math.abs(math.floor(vehicle:GetVelocity():Length()/ 25.33));
				if eph < 5 then eph = 0 end --Meh..Didn't even test if it was going to bug, but this doesn't hurt.
				vehicle._Fuel = math.Clamp(vehicle._Fuel - (math.Clamp(eph * (0.01), .1, 100)), 0, 100);
				vehicle:SetNetworkedInt("fuel", vehicle._Fuel)
				if vehicle._Fuel < 1 then
					vehicle:Fire("TurnOff", "" , 0)
					vehicle._Off = true
				else
					if (vehicle._Off and !vehicle:GetNetworkedBool("punched")) then vehicle:Fire("TurnOn", "" , 0); v._Off = false; end
				end
			end
		end
	end
	if string.lower(game.GetMap()) == "rp_chaos_city_v33x_03" then
		for _, ent in pairs(ents.FindInSphere(Vector( 3207, -99, -1876 ), 400)) do
			if (string.find( ent:GetClass( ), "prop_vehicle_jeep" )) then
				if (IsValid(ent:GetDriver())) then
					if (ent:GetNetworkedBool("NeedsFix")) then
						evorp.player.notify(ent:GetDriver(), "You need to repair this vehicle before parking it!", 0)
						return;
					end
					ent:GetDriver():ExitVehicle();
					evorp.player.notify(ent:GetDriver(), "Your vehicle has been parked!", 0)
				end
				ent:Remove()
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( 4131, 749, -1868 ), 100)) do
			if (string.find( ent:GetClass( ), "prop_vehicle_jeep") and ent:GetDriver() and IsValid(ent:GetDriver())) then
				if not (ent.VehicleTable.nopaint) then
					 local rand = evorp.configuration["Default Colors"][ math.random( #evorp.configuration["Default Colors"] ) ] 
					 ent:SetColor(rand);
			        		 --ent:SetSkin(math.random(11, 15))
					 ent:EmitSound("carStools/spray.wav",80,70)
				end
			end
		end
	end
	if string.lower(game.GetMap()) == "rp_evocity_v33x" then
		for _, ent in pairs(ents.FindInSphere(Vector( -7572, -7226, 64 ), 350)) do
			if (string.find( ent:GetClass( ), "prop_vehicle_jeep" )) then
				if (IsValid(ent:GetDriver())) then
					if (ent:GetNetworkedBool("NeedsFix")) then
						evorp.player.notify(ent:GetDriver(), "You need to repair this vehicle before parking it!", 0)
						return;
					end
					ent:GetDriver():ExitVehicle();
					evorp.player.notify(ent:GetDriver(), "Your vehicle has been parked!", 0)
				end
				ent:Remove()
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -6489, -5959, 72 ), 100)) do
			if (string.find( ent:GetClass( ), "prop_vehicle_jeep") and ent:GetDriver() and IsValid(ent:GetDriver())) then
				if not (ent.VehicleTable.nopaint) then
					 local rand = evorp.configuration["Default Colors"][ math.random( #evorp.configuration["Default Colors"] ) ] 
					 ent:SetColor(rand);
			        		 --ent:SetSkin(math.random(11, 15))
					 ent:EmitSound("carStools/spray.wav",80,70)
				end
			end
		end
	end
	if string.lower(game.GetMap()) == "rp_evocity_v2d" then
		for _, ent in pairs(ents.FindInSphere(Vector( -7209, -7056, 64 ), 40)) do
			if (string.find( ent:GetClass( ), "prop_vehicle_jeep" )) then
				if (IsValid(ent:GetDriver())) then
					if (ent:GetNetworkedBool("NeedsFix")) then
						evorp.player.notify(ent:GetDriver(), "You need to repair this vehicle before parking it!", 0)
						return;
					end
					ent:GetDriver():ExitVehicle();
					evorp.player.notify(ent:GetDriver(), "Your vehicle has been parked!", 0)
				end
				ent:Remove()
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -6493, -5960, 72 ), 100)) do
			if (string.find( ent:GetClass( ), "prop_vehicle_jeep") and ent:GetDriver() and IsValid(ent:GetDriver())) then
				if not (ent.VehicleTable.nopaint) then
					 local rand = evorp.configuration["Default Colors"][ math.random( #evorp.configuration["Default Colors"] ) ] 
					 ent:SetColor(rand);
			        		 --ent:SetSkin(math.random(11, 15))
					 ent:EmitSound("carStools/spray.wav",80,70)
				end
			end
		end
	end
	if string.lower(game.GetMap()) == "rp_evocity_v2d_sexy_v2" then
		for _, ent in pairs(ents.FindInSphere(Vector( -7230, -6735, 64 ), 40)) do
			if (string.find( ent:GetClass( ), "prop_vehicle_jeep" )) then
				if (IsValid(ent:GetDriver())) then
					if (ent:GetNetworkedBool("NeedsFix")) then
						evorp.player.notify(ent:GetDriver(), "You need to repair this vehicle before parking it!", 0)
						return;
					end
					ent:GetDriver():ExitVehicle();
					evorp.player.notify(ent:GetDriver(), "Your vehicle has been parked!", 0)
				end
				ent:Remove()
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -6491, -5960, 72 ), 100)) do
			if (string.find( ent:GetClass( ), "prop_vehicle_jeep") and ent:GetDriver() and IsValid(ent:GetDriver())) then
				if not (ent.VehicleTable.nopaint) then
					 local rand = evorp.configuration["Default Colors"][ math.random( #evorp.configuration["Default Colors"] ) ] 
					 ent:SetColor(rand);
			        		 --ent:SetSkin(math.random(11, 15))
					 ent:EmitSound("carStools/spray.wav",80,70)
				end
			end
		end
	end
end);

timer.Create("WalkAdvice", 1, 0, function() 
	if string.lower(game.GetMap()) == "rp_chaos_city_v33x_03" then
		for _, ent in pairs(ents.FindInSphere(Vector( 3207, -99, -1876 ), 450)) do
			if (ent:IsPlayer()) then
				ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here to park it.")
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( 4131, 535, -1876 ), 200)) do
			if (ent:IsPlayer()) then
				if (ent:InVehicle()) then
					if not (ent.evorp._Donator > os.time()) then
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $300.")
					else
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $150.")
					end
				else
					ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here to refuel it.")
				end		
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( 4124, 288, -1876 ), 200)) do
			if (ent:IsPlayer()) then
				if (ent:InVehicle()) then
					if not (ent.evorp._Donator > os.time()) then
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $300.")
					else
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $150.")
					end
				else
					ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here to refuel it.")
				end		
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -7361, 5234, -1489 ), 500)) do
			if (ent:IsPlayer()) then
				if (ent:InVehicle()) then
					if not (ent.evorp._Donator > os.time()) then
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $300.")
					else
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $150.")
					end
				else
					ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here to refuel it.")
				end		
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -8282, 5223, -1489 ), 500)) do
			if (ent:IsPlayer()) then
				if (ent:InVehicle()) then
					if not (ent.evorp._Donator > os.time()) then
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $300.")
					else
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $150.")
					end
				else
					ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here to refuel it.")
				end		
			end
		end
		
		for _, ent in pairs(ents.FindInSphere(Vector( 4131, 749, -1868 ), 200)) do
			if (ent:IsPlayer() and !ent:InVehicle()) then
				ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here for a paint job.")
			end
		end
	end
	if string.lower(game.GetMap()) == "rp_evocity_v33x" then
		for _, ent in pairs(ents.FindInSphere(Vector( -7571, -7201, 64 ), 350)) do
			if (ent:IsPlayer()) then
				ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here to park it.")
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -6503, -6614, 72 ), 200)) do
			if (ent:IsPlayer()) then
				if (ent:InVehicle()) then
					if not (ent.evorp._Donator > os.time()) then
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $300.")
					else
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $150.")
					end
				else
					ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here to refuel it.")
				end		
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -6494, -6315, 72 ), 200)) do
			if (ent:IsPlayer()) then
				if (ent:InVehicle()) then
					if not (ent.evorp._Donator > os.time()) then
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $300.")
					else
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $150.")
					end
				else
					ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here to refuel it.")
				end		
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( 10796, 13418, 58 ), 200)) do
			if (ent:IsPlayer()) then
				if (ent:InVehicle()) then
					if not (ent.evorp._Donator > os.time()) then
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $300.")
					else
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $150.")
					end
				else
					ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here to refuel it.")
				end		
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( 9991, 13419, 58 ), 200)) do
			if (ent:IsPlayer()) then
				if (ent:InVehicle()) then
					if not (ent.evorp._Donator > os.time()) then
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $300.")
					else
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $150.")
					end
				else
					ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here to refuel it.")
				end		
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -6484, -6024, 72 ), 200)) do
			if (ent:IsPlayer() and !ent:InVehicle()) then
				ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here for a paint job.")
			end
		end
	end
	if string.lower(game.GetMap()) == "rp_evocity_v2d" then
		for _, ent in pairs(ents.FindInSphere(Vector( -7209, -7056, 64 ), 150)) do
			if (ent:IsPlayer()) then
				ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here to park it.")
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -6494, -6550, 72 ), 200)) do
			if (ent:IsPlayer()) then
				if (ent:InVehicle()) then
					if not (ent.evorp._Donator > os.time()) then
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $300.")
					else
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $150.")
					end
				else
					ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here to refuel it.")
				end		
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -6494, -6255, 72 ), 200)) do
			if (ent:IsPlayer()) then
				if (ent:InVehicle()) then
					if not (ent.evorp._Donator > os.time()) then
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $300.")
					else
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $150.")
					end
				else
					ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here to refuel it.")
				end		
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -6493, -5960, 72 ), 100)) do
			if (ent:IsPlayer() and !ent:InVehicle()) then
				ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here for a paint job.")
			end
		end
	end
	if string.lower(game.GetMap()) == "rp_evocity_v2d_sexy_v2" then
		for _, ent in pairs(ents.FindInSphere(Vector( -7230, -6735, 64  ), 150)) do
			if (ent:IsPlayer()) then
				ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here to park it.")
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -6498, -6615, 72 ), 200)) do
			if (ent:IsPlayer()) then
				if (ent:InVehicle()) then
					if not (ent.evorp._Donator > os.time()) then
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $300.")
					else
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $150.")
					end
				else
					ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here to refuel it.")
				end		
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -6494, -6320, 72 ), 200)) do
			if (ent:IsPlayer()) then
				if (ent:InVehicle()) then
					if not (ent.evorp._Donator > os.time()) then
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $300.")
					else
						ent:PrintMessage(HUD_PRINTCENTER, "Tap 'ALT' to refill car for $150.")
					end
				else
					ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here to refuel it.")
				end		
			end
		end
		for _, ent in pairs(ents.FindInSphere(Vector( -6491, -5960, 72 ), 100)) do
			if (ent:IsPlayer() and !ent:InVehicle()) then
				ent:PrintMessage(HUD_PRINTCENTER, "Bring your car here for a paint job.")
			end
		end
	end
end);

hook.Add("KeyPress", "InVehicleLock", function(ply, key)
	if (ply:GetNetworkedBool("FakeDeathing") and key == 1) then
		if not (CurTime() > ply:GetNetworkedInt("FakeDeathTimer")  - 120 + ply._SpawnTime) then return end
		local player = ply
		ply:SetNetworkedBool("FakeDeathing", false)
		timer.Destroy( "RealDeath_"..player:UniqueID())
		player:KillSilent();
		-- Call some gamemode hooks to fake the player's death.
		--hook.Call("DoPlayerDeath", GAMEMODE, player._FakePlayer, player._FakeAttacker, player._FakeDmgInfo);
		hook.Call("PlayerDeath", GAMEMODE, player._FakePlayer, player._FakeInflictor , player._FakeAttacker, true);
		player.NextSpawnTime = CurTime();
		evorp.player.setLocalPlayerVariable(player, CLASS_LONG, "_NextSpawnTime", player.NextSpawnTime);
	end
	if !ply:InVehicle() || key != 1 then return end -- 1 is IN_ATTACK
    	--local trace = ply:GetEyeTrace();
	if !( IsValid(ply:GetVehicle()) ) then 
			return;
        	end
	if !(string.find( ply:GetVehicle():GetClass(), "prop_vehicle_jeep" )) then
		return
	end
  	local car = ply:GetVehicle();
	if (car:GetNetworkedBool("locked")) then
		car:SetNetworkedBool("locked", false)
		car:EmitSound("doors/door_latch3.wav")
	else
		car:SetNetworkedBool("locked", true)
		car:EmitSound("doors/door_latch3.wav")
	end
end)

timer.Create("UpdateOnline", 20, 0, function() 
	local steamids = "('EX1', 'EX2'" -- Logic fail, this is the fix.
	for _, v in ipairs( g_Player.GetAll() ) do
		steamids = steamids..", '"..v:SteamID().."'"
	end
	steamids = steamids..")"
	GetDBConnection():Query("UPDATE players SET _Online = 'NO' WHERE _SteamID NOT IN "..steamids.." AND _Online = '"..GetConVar("sv_logdownloadlist"):GetString().."'")
end)

timer.Create("NLR Reminder", 10, 0, function() 
	for _, v in ipairs( g_Player.GetAll() ) do
		if (!v:Alive()) then return end
		if (v._LastDeathLocation and v._LastDeathTime) then
			if (os.time() - v._LastDeathTime  < 330 and os.time() - v._LastDeathTime  > 60) then
					for _, ent in pairs(ents.FindInSphere(v._LastDeathLocation, 650)) do
					if (ent:IsPlayer() and ent:UniqueID() == v:UniqueID()) then
						evorp.player.printConsoleAccess(v:Nick().." is breaking NLR.", 1, "a", "kills", v);
						--notifyAllAdm(v:Nick().." is breaking NLR.", 1)
					end
				end
			end
		end
	end
end)

timer.Create("DonationCheck", 60, 0, function() 
	GetDBConnection():Query("SELECT * FROM donations WHERE _Credited = '0'", function(result)
		if (result and type(result) == "table" and #result > 0) then
			for index,value in ipairs(result) do
				local column = result[index];
				local steamID = column._SteamID
				local credits = tonumber(column._Credits)

				for _, player in ipairs( g_Player.GetAll() ) do
					if (player._Initialized and string.lower(player:SteamID()) == string.lower(steamID)) then
						player.evorp._DonorCredits = player.evorp._DonorCredits + credits;
						GetDBConnection():Query("UPDATE donations SET _Credited = '1' WHERE _Key = "..column._Key)
						evorp.player.saveData(player)
						evorp.player.notify(player, "You have been credited for you donation!", 0)
					end
				end
			end
		end;
	end, 1);
end)

timer.Create("BansCheck", 120, 0, function() 
	for _, player in ipairs( g_Player.GetAll() ) do
		if (player._Initialized and player._Bans) then
			for k, column in ipairs(player._Bans) do
				if not (os.time() < tonumber(column._Until) or tonumber(column._Until) == 0) then
					if not (evorp.player.hasAccess(player, column._Access)) then
						evorp.player.giveAccess(player, column._Access)
						evorp.player.notify(player, "A ban on you has been lifted!", 0)
					end
				end
			end
		end
	end
end)

function notifyAllAdm(txt, type)
	for __, vv in ipairs( g_Player.GetAll() ) do
		if(vv:IsAdmin()) then
			evorp.player.notify(vv , txt, type)
		end
	end
end