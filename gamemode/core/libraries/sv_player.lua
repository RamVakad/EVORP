--[[
Name: "sv_player.lua".
Product: "EvoRP (Roleplay)".
--]]

evorp.player = {};
evorp.player.nextSecond = 0;

-- Give access to a player.
function evorp.player.giveAccess(player, access)
	for i = 1, string.len(access) do
		local flag = string.sub(access, i, i);
		
		-- Check to see if we do not already have this flag.
		if ( !string.find(player._Access, flag) ) then
			player._Access = player._Access..flag;
		end;
	end;
end;

-- Take access from a player.
function evorp.player.takeAccess(player, access)
	for i = 1, string.len(access) do
		local flag = string.sub(access, i, i);
		
		-- Check to see if we have this flag.
		if ( string.find(player._Access, flag) ) then
			player._Access = string.gsub(player._Access, access, "");
		end;
	end;
end;

-- Check to see if a player has access.
function evorp.player.hasAccess(player, access)
	for i = 1, string.len(access) do
		local flag = string.sub(access, i, i);
		if not (player._Access) then return false; end;
		if ( !string.find(player._Access, flag) ) then return false; end;
	end;
	
	-- We haven't failed yet so we must have all the required access.
	return true;
end;

-- Take a door from a player.
function evorp.player.takeDoor(player, door)
	door._Owner = nil;
	door._UniqueID = nil;
	
	-- Unlock the door so that people can use it again and play the door latch sound.
	door:Fire("unlock", "", 0);
	door:EmitSound("doors/door_latch3.wav");
	
	-- Set the networked name so that the client can get it.
	door:SetNetworkedEntity("evorp_Owner", NULL);
	door:SetNetworkedString("evorp_Name", "");
	
	-- Give the player a refund for the door.
	evorp.player.giveMoney(player, evorp.configuration["Door Cost"] / 2);
end;

-- Say a message as a radio broadcast.
function evorp.player.sayRadio(ply, text)
	local recipients = {}
	
	for k, v in ipairs( player.GetAll() ) do -- Loop through all of the players.
		if (evorp.team.query(v:Team(), "radio", "") == evorp.team.query(ply:Team(), "radio", "")) then
			if (v:GetPos():Distance( ply:GetPos() ) > evorp.configuration["Talk Radius"] * 1) then
				table.insert(recipients, v)
			end
		end;
	end -- End the loop.
	
	-- Loop through every recipient.
	evorp.chatBox.addInRadius(ply, "oradio", text, ply:GetPos(), evorp.configuration["Talk Radius"] * 1)
	for k, v in pairs(recipients) do evorp.chatBox.add(v, ply, "radio", text); end;
end;

-- Say a message as a clan broadcast.
function evorp.player.sayClan(ply, text)
	local recipients = {}
	
	for k, v in ipairs( player.GetAll() ) do -- Loop through all of the players.
		if (v.evorp._Clan == ply.evorp._Clan) then
			table.insert(recipients, v)
		end;
	end -- End the loop.
	
	-- Loop through every recipient.
	for k, v in pairs(recipients) do evorp.chatBox.add(v, ply, "clan", text); end;
end;

-- Give a door to a player.
function evorp.player.giveDoor(player, door, name, unsellable)
	if (evorp.entity.isDoor(door) or door:GetClass() == "prop_dynamic") then
		door._Unsellable = unsellable;
		door._Owner = player;
		door._UniqueID = player:UniqueID();
		door._Access = {};
		
		-- Set the networked owner and name so that the client can get it.
		door:SetNetworkedEntity("evorp_Owner", player);
		door:SetNetworkedString("evorp_Name", name or "Sold");
		
		-- Unlock the door so that people can use it again and play the door latch sound.
		door:Fire("unlock", "", 0);
		door:EmitSound("doors/door_latch3.wav");
	end;
end;

-- Demote a player from their current team.
function evorp.player.demote(player)
	
	-- Call the plugin hook so that we can decide what to do with the player.
	evorp.plugin.call("playerDemoted", player);
end;

-- Holsters all of a player's weapons.
function evorp.player.holsterAll(player)
	local notifyy = false;
	local weapons = player:GetWeapons()
	if player._KnockedOut then weapons = player._Ragdoll.weapons; end
	for k, v in pairs( weapons ) do
		local class = "";
		if (player._KnockedOut) then
			class = v[1]
		else
			class = v:GetClass();
		end
		-- Check if this is a valid item.
		if ( evorp.item.stored[class] ) then
			if ( hook.Call("PlayerCanHolster", GAMEMODE, player, class, true) ) then
				notifyy = true;
				evorp.inventory.update(player, class, 1);
				-- Strip the weapon from the player.
				if not player._KnockedOut then player:StripWeapon(class); end
			end;
		end;
	end;
	if IsValid(player.BackGun) then
 		player.BackGun:Remove()
 	end
	player._Ragdoll.weapons = {}
	evorp.player.holsterAttachment(player)
	-- Make the player select the hands weapon.
	player:SelectWeapon("evorp_hands");
	if (notify) then evorp.player.notify(player, "All weapons holstered.", 0); end
end;

function evorp.player.holsterAttachment(player)
	if (player._AttachmentKit and !player._KnockedOut and !player:GetNetworkedBool("cuffed") and !player:GetNetworkedBool("hostaged")) then
		player:RemoveAttachments();
		player:RemoveInternalParts();
		player._AttachmentKit = false;
		evorp.inventory.update(player, "attach", 1);
		evorp.player.notify(player, "Attachment kit holstered!", 1);
	end;
end


-- Set a player's local player variable for the client.
function evorp.player.setLocalPlayerVariable(player, class, key, value)
	if ( IsValid(player) ) then
		local variable = key.."_Last_"..class;
		
		-- Check if we can send this player variable again.
		if (player[variable] == nil or player[variable] != value) then
			umsg.Start("evorp._LocalPlayerVariable", player);
				umsg.Char(class);
				umsg.String(key);
				
				-- Check if we can get what class of variable it is.
				if (class == CLASS_STRING) then
					value = value or ""; umsg.String(value);
				elseif (class == CLASS_LONG) then
					value = value or 0; umsg.Long(value);
				elseif (class == CLASS_SHORT) then
					value = value or 0; umsg.Short(value);
				elseif (class == CLASS_BOOL) then
					value = value or false; umsg.Bool(value);
				elseif (class == CLASS_VECTOR) then
					value = value or Vector(0, 0, 0); umsg.Vector(value);
				elseif (class == CLASS_ENTITY) then
					value = value or NULL; umsg.Entity(value);
				elseif (class == CLASS_ANGLE) then
					value = value or Angle(0, 0, 0); umsg.Angle(value);
				elseif (class == CLASS_CHAR) then
					value = value or 0; umsg.Char(value);
				elseif (class == CLASS_FLOAT) then
					value = value or 0; umsg.Float(value);
				end;
			umsg.End();
			
			-- Set the last sent value with this key to this value.
			player[variable] = value;
		end;
	end;
end;

-- Check if a player has access to a door.
function evorp.player.hasDoorAccess(player, door)
	if door:GetNetworkedBool("evorp_Unownable") then
		local name = door:GetNetworkedString("evorp_Name");
		if (string.find(name, "Nexus") or string.find(name, "1") or string.find(name, "2") or string.find(name, "3") or string.find(name, "Special")) then
			if (player:Team() == TEAM_COMMANDER or player:Team() == TEAM_OFFICER or player:Team() == TEAM_PRESIDENT or player:Team() == TEAM_SS or player:Team() == TEAM_HOSS) then
				return true;
			end
		end
		if (string.find(name, "President")) then
			if (player:Team() == TEAM_PRESIDENT) then
				return true;
			end
		end
	end

	if (door._Owner == player) then
		return true;
	else
		local uniqueID = player:UniqueID();
		
		-- Check if the player has access to this door.
		if (door._Access and door._Access[uniqueID]) then
			return true;
		end;
	end;
	
	-- Return false because we don't have access to this door.
	return false;
end;

-- Print a message to player's with the specified access.
--eff'd up function. i hate my coding.
function evorp.player.printConsoleAccess(text, access, category, ply)
	if category then
		if not (type(category) == "string") then
			ply = category;
			category = false;
		end
	end
	if (ply and IsValid(ply) and ply:IsPlayer()) then
		EVPlayerLog(ply, text, false)
	end
	--print(text);
	--GetDBConnection():Query("INSERT INTO logs (_Data, _Time, _Server) VALUES ('"..tmysql.escape(text).."', '"..os.time().."', '"..GetConVar("sv_logdownloadlist"):GetString().."')");
	if not (category) then category = "evorp" end
	exsto.GetPlugin("logs"):SaveEvent(text, category)
	--for k, v in pairs( g_Player.GetAll() ) do
	--	if ( evorp.player.hasAccess(v, access) ) then v:PrintMessage(2, text); end;
	--end;
end;

-- Check if a player can afford an amount of money.
function evorp.player.canAfford(player, amount)
	return player.evorp._Money >= amount;
end;

-- Give a player an amount of money.
function evorp.player.giveMoney(player, amount)
	player.evorp._Money = player.evorp._Money + amount;
end;

-- Get a player by a part of their name.
function evorp.player.get(name)
	local ret = false;
	for k, v in pairs( g_Player.GetAll() ) do
		if ( string.find( string.lower( v:Name() ), string.lower(name) ) or string.find( v:Name(), name ) ) then
			if (ret) then
				if (string.len(v:Name()) < string.len(ret:Name())) then
					ret = v;
				end
			else
				ret = v;
			end
		end;
	end;
	
	-- Return false because we didn't find any players.
	return ret;
end;

-- Notifies every player using Garry's hint messages.
function evorp.player.notifyAll(message, class)
	for k, v in pairs( g_Player.GetAll() ) do evorp.player.notify(v, message, class); end;
end;

-- Notifies a player using Garry's hint messages.
function evorp.player.notify(player, message, class)
	if not (IsValid(player)) then return end
	if (!class) then
		evorp.chatBox.add(player, nil, "notify", message);
	else
		umsg.Start("evorp_Notification", player);
			umsg.String(message);
			umsg.Short(class);
		umsg.End();
		
		-- Print a message to their console.
		player:PrintMessage(2, message);
	end;
end;

-- Prints a message to every player's chat area and console.
function evorp.player.printMessageAll(message)
	for k, v in pairs( g_Player.GetAll() ) do
		evorp.player.printMessage(v, message)
	end;
end;

-- Prints a message to a player's chat area and console.
function evorp.player.printMessage(player, message) player:PrintMessage(3, message) end;

-- Prints a message to players within a radius of a specified position.
function evorp.player.printMessageInRadius(message, position, radius)
	for k, v in pairs( g_Player.GetAll() ) do
		if (position:Distance( v:GetPos() ) <= radius) then
			evorp.player.printMessage(v, message);
		end;
	end;
end;

-- Warrant or unwarrant a player.
function evorp.player.warrant(player, class)
	if (boolean) then
		evorp.plugin.call("playerWarranted", player, class);
	else
		evorp.plugin.call("playerUnwarranted", player, class);
	end;
	
	-- Update their warranted status.
	player._Warranted = class;
	
	-- Check the class of the warrant.
	if (class and type(class) == "string") then
		timer.Remove( "Warrant Expire: "..player:UniqueID() ); -- Just in case it exists!
		player:SetNetworkedString("evorp_Warranted", class);
		
		-- Get the warrant expire time.
		local expireTime = 600;
		
		-- Check the class of the warrant.
		--if (class == "arrest") then expireTime = 300; end;
		
		-- Check if the expire time is greater than 0.
		if (expireTime > 0) then
			evorp.player.setLocalPlayerVariable(player, CLASS_LONG, "_WarrantExpireTime", CurTime() + expireTime);
			
			-- Create the warrant expire timer.
			timer.Create("Warrant Expire: "..player:UniqueID(), expireTime, 1, function()
				if ( IsValid(player) ) then
					evorp.player.warrant(player, false);
					hook.Call("PlayerWarrantExpired", player, class);
				end;
			end);
		end;
	else
		player:SetNetworkedString("evorp_Warranted", "");
	end;
end;

-- Make a player bleed or stop them from bleeding.
function evorp.player.bleed(player, boolean, seconds)
	if (!boolean) then
		timer.Remove( "Bleed: "..player:UniqueID() );
	else
		timer.Create("Bleed: "..player:UniqueID(), 0.25, (seconds or 0) * 4, function()
			if ( IsValid(player) ) then
				local trace = {};
				
				-- Set some settings and information for the trace.
				trace.start = player:GetPos() + Vector(0, 0, 256);
				trace.endpos = trace.start + Vector(0, 0, -1024);
				trace.filter = player;
				
				-- Create the trace line from the set information.
				trace = util.TraceLine(trace);
				
				-- Draw a blood decal at the hit position.
				util.Decal("Blood", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal);
			end;
		end);
	end;
end;

-- Knock out a player or bring them back to consciousness.
function evorp.player.knockOut(player, boolean, seconds, reset)
	if (boolean and player._KnockedOut) then
		return;
	elseif (!boolean and !player._KnockedOut and !reset) then
		return;
	else
		if(player:InVehicle()) then player:ExitVehicle() end
		if (boolean) then
			player._KnockedOut = true;
			local ragdoll = ents.Create("prop_ragdoll");
			
			-- Get the velocity and model of the player.
			local velocity = player:GetVelocity();
			local model = player:GetModel();
			
			-- Check if the model is valid without the player in it.
			if ( util.IsValidModel( string.Replace(model, "/player/", "/humans/") ) ) then
				model = string.Replace(model, "/player/", "/humans/");
			end;
			--[[if (player:IsCTPEnabled()) then
				player.KnckOutCTP = true;
				player:ConCommand("ctp")
			end
			]]
			-- Set the position, angles and model of the ragdoll and then spawn it.
			ragdoll:SetPos( player:GetPos() );
			ragdoll:SetAngles( player:GetAngles() );
			ragdoll:SetModel(model);
			ragdoll:Spawn();
			ragdoll:SetCollisionGroup(COLLISION_GROUP_WORLD)
			AMB_KillVelocity(ragdoll)
  			--timer.Simple(.1, function() AMB_SetSubPhysMotionEnabled(ragdoll, true) end)
			-- Loop through each of the ragdoll's physics objects.
			--[[
			for i = 1, ragdoll:GetPhysicsObjectCount() do
				local physicsObject = ragdoll:GetPhysicsObjectNum(i);
				
				-- Check if the physics object is a valid entity.
				if ( IsValid(physicsObject) ) then
					local position, angle = player:GetBonePosition( ragdoll:TranslatePhysBoneToBone(i) );
					
					-- Set the position and angle of the physics object, then add velocity to it.
					physicsObject:SetPos(position);
					physicsObject:SetAngles(angle);
					physicsObject:AddVelocity(velocity);
				end;
			end;
			]]
			-- Copy any settings that we can and set the networked entity to the player.
			ragdoll:SetSkin( player:GetSkin() );
			ragdoll:SetColor( player:GetColor() );
			ragdoll:SetMaterial( player:GetMaterial() );
			ragdoll:SetNetworkedEntity("evorp_Player", player);
			
			-- Set the ragdoll's player.
			ragdoll._Player = player;
			
			-- Check if the player is on fire.
			if ( player:IsOnFire() ) then ragdoll:Ignite(8, 0); end;
			
			-- Set some variables for this player's ragdoll.
			player._Ragdoll.weapons = {};
			player._Ragdoll.entity = ragdoll;
			player._Ragdoll.health = player:Health();
			player._Ragdoll.model = player:GetModel();
			player._Ragdoll.team = player:Team();
			
			-- Check if the player is alive.
			if ( player:Alive() ) then
				if ( IsValid( player:GetActiveWeapon() ) ) then
					player._Ragdoll.weapon = player:GetActiveWeapon():GetClass();
				end;
				
				-- Loop through the player's weapons and save them.
				for k, v in pairs( player:GetWeapons() ) do
					local class = v:GetClass();
					
					-- Check if this weapon is a valid item.
					if (evorp.item.stored[class]) then
						if ( hook.Call("PlayerCanHolster", GAMEMODE, player, class, true) ) then
							table.insert( player._Ragdoll.weapons, {class, true} );
						else
							table.insert( player._Ragdoll.weapons, {class, false} );
						end;
					else
						table.insert( player._Ragdoll.weapons, {class, false} );
					end;
				end;
				
				-- Check if we specified how long we're knocked out for.
				if (seconds) then
					timer.Create("Become Conscious: "..player:UniqueID(), seconds, 1, function()
						if ( IsValid(player) and player:Alive() ) then
							evorp.player.knockOut(player, false);
						end;
					end);
					
					-- Set it so that we can get this client side.
					evorp.player.setLocalPlayerVariable(player, CLASS_LONG, "_BecomeConsciousTime", CurTime() + seconds);
				end;

				timer.Create("RagdollRemove"..player:UniqueID(), 180, 1, function()
						if (player._Ragdoll and player._Ragdoll.entity and IsValid(player._Ragdoll.entity) ) then
							player._Ragdoll.entity:Remove();
						end;
					end);

			end;
			
			-- Check if the player is in a vehicle.
			if ( player:InVehicle() and IsValid( player:GetVehicle() ) ) then
				constraint.NoCollide(ragdoll, player:GetVehicle(), true, true);
			end;
			
			-- Strip the player's weapons and make them spectate the ragdoll.
			player:StripWeapons();
			player:Flashlight(false);
			player:Spectate(OBS_MODE_CHASE);
			player:SpectateEntity(ragdoll);
			player:CrosshairDisable();
			
			-- Stop the player from bleeding.
			evorp.player.bleed(player, false);
			
			-- Set the player to be knocked out.
			
			
			-- Set a networked boolean to let the client know we're knocked out.
			player:SetNetworkedBool("evorp_KnockedOut", true);
			player:SetNetworkedEntity("evorp_Ragdoll", ragdoll);
			
			-- Call a function on every plugin so they can know about this.
			evorp.plugin.call("playerKnockedOut", player);
		else
			if (player:Team() != player._Ragdoll.team and !reset) then
				player._Ragdoll.team = player:Team();
				
				-- Spawn the player fully.
				player:Spawn();
				--[[
				if (player.KnckOutCTP) then
					player.KnckOutCTP = false;
					player:ConCommand("ctp")
				end
				]]
			else
				player:UnSpectate();
				player:CrosshairEnable();
				
				-- Check if we're not doing a reset.
				if (!reset) then evorp.player.lightSpawn(player); end
				-- Loop through the player's weapons and give them back.
				if (player._Ragdoll.weapons) then
					for k, v in pairs(player._Ragdoll.weapons) do
						if (player._Ragdoll.weapons[v] != 72) then
							if ( reset and v[2] ) then
								if ( !evorp.inventory.update(player, v[1], 1) ) then player:Give( v[1] ); end;
							else
								player:Give( v[1] );
							end;
						end
					end;
				end
				
				-- Check if we're not doing a reset.
				if (!reset) then
					if ( IsValid(player._Ragdoll.entity) ) then
						player:SetPos( player._Ragdoll.entity:GetPos() );
						player:SetSkin( player._Ragdoll.entity:GetSkin() );
						player:SetColor( player._Ragdoll.entity:GetColor() );
						player:SetMaterial( player._Ragdoll.entity:GetMaterial() );
					end;
					
					-- Restore some information from the ragdoll.
					player:SetModel(player._Ragdoll.model);
					player:SetHealth(player._Ragdoll.health);
					
					-- Check if the player had a weapon when they got knocked out.
					if (player._Ragdoll.weapon) then player:SelectWeapon(player._Ragdoll.weapon); end;
				end;
				
				if ( IsValid(player._Ragdoll.entity) ) then player._Ragdoll.entity:Remove(); end;
				-- Restore the ragdoll table and set the knocked out variable to nil.
				player._Ragdoll = {};
				player._KnockedOut = nil;
				
				-- Set a networked boolean to let the client know we're unknocked out.
				player:SetNetworkedBool("evorp_KnockedOut", false);
				player:SetNetworkedEntity("evorp_Ragdoll", NULL);
				
				-- Remove the timer to become conscious.
				
				timer.Remove( "RagdollRemove"..player:UniqueID() );
				timer.Remove( "Become Conscious: "..player:UniqueID() );
				player:SelectWeapon("evorp_hands")
				
				-- Call a function on every plugin so they can know about this.
				evorp.plugin.call("playerUnknockedOut", player);
			end;
		end;
	end;
end;

-- Lightly spawn a player.
function evorp.player.lightSpawn(player)
	player._LightSpawn = true;
	
	-- Spawn the player lightly.
	player:Spawn();
end;

-- Arrest or unarrest a player.
function evorp.player.arrest(player, boolean, reset)
	if (boolean and player.evorp._Arrested and !reset) then
		return;
	elseif (!boolean and !player.evorp._Arrested and !reset) then
		return;
	else
		if (boolean) then
			evorp.plugin.call("playerArrested", player);
		else
			evorp.plugin.call("playerUnarrested", player);
		end;
		
		-- Update their arrested status.
		player.evorp._Arrested = boolean;
		
		-- Set a networked boolean to let the client know whether we're arrested or not.
		player:SetNetworkedBool("evorp_Arrested", boolean);
		
		-- Check to see if we are arresting them.
		if (boolean) then
			timer.Create("Unarrest: "..player:UniqueID(), player._ArrestTime, 1, function()
				if (IsValid(player)) then
					evorp.player.arrest(player, false);
					
					-- Notify the player that they have been unarrested.
					evorp.player.notify(player, "You have been unarrested.", 0);
				end
			end);
			
			-- Set it so that we can get this client side.
			evorp.player.setLocalPlayerVariable(player, CLASS_LONG, "_UnarrestTime", CurTime() + player._ArrestTime);
			
			player:Flashlight(false);
			--evorp.player.holsterAll(player);
			player:StripWeapons();
			--player:StripAmmo();
			
			-- Unwarrant the player.
			evorp.player.warrant(player, false);
		else
			timer.Remove( "Unarrest: "..player:UniqueID() );
			
			-- Check if we're not resetting it so that we can spawn the player.
			if (!reset) then player:Spawn(); end;
		end;
	end;
end;

-- Load a player's data.
function evorp.player.loadData(player)
	local name = tmysql.escape(player:Name());
	local steamID = tmysql.escape(player:SteamID());
	local uniqueID = tmysql.escape(player:UniqueID());
	
	-- Create the main EvoRP table with some default variables.
	player.evorp = {};
	player.evorp._Name = name;
	player.evorp._Clan = evorp.configuration["Default Clan"];
	player.evorp._SteamID = steamID;
	player.evorp._UniqueID = uniqueID;
	player.evorp._Money = evorp.configuration["Default Money"];
	player.evorp._Donator = 0;
	player.evorp._Arrested = false;
	player.evorp._Inventory = {
		chinese = 15,
		pocket = 10
	};
	player.evorp._PlayTime = 0;
	player.evorp._NameIC = evorp.configuration["First Names"][ math.random(1, #evorp.configuration["First Names"]) ] .. evorp.configuration["Last Names"][ math.random(1, #evorp.configuration["Last Names"]) ];
	player.evorp._Description = evorp.configuration["Default Description"];
	player.evorp._FirstPlayed = os.time();
	player.evorp._LastPlayed = 0;
	player.evorp._PointsRP = 0;
	player.evorp._AdminLevel = 0;
	player.evorp._DonorCredits = 0;
	player.evorp._Online = 'NO';
	player.evorp._Weps = '';
	player._Access = evorp.configuration["Access"];
	
	--Weapons/Old Weapons/Ammo/SCars wipe. 8-9-2013
	--[[
	GetDBConnection():Query("SELECT * FROM players", function(results)
			if (results and type(results) == "table" and #results > 0) then
				for k, v in pairs(results) do
					local result = v;
					
					local inventory = evorp.player.convertInventoryString(result._Inventory);
					
					-- Loop through the inventory and give each item to the player.
					
					local value = "";
	
					-- Loop through the table.
					for k2, v2 in pairs(inventory) do
						if not (string.find(k2, "cstm_") or string.find(k2, "weapon_") or string.find(k2, "ammo") or string.find(k2, "c_")) then
							value = value..k2..": "..tostring(v2).."; ";
						end
					end
					value = string.sub(value, 1, -3)

					GetDBConnection():Query("UPDATE players SET _Inventory = \""..value.."\" WHERE _UniqueID = "..result._UniqueID)
					print("Updated UniqueID, Player: "..result._UniqueID..", "..result._Name)	
				end
			end;
	end, 1);
	]]
	-- Perform a threaded query.
	player._Bans = {}
	GetDBConnection():Query("SELECT * FROM bans WHERE _UniqueID = '"..uniqueID.."'", function(result)
		if ( IsValid(player) ) then
			if (result and type(result) == "table" and #result > 0) then
				for index,value in ipairs(result) do
					local column = result[index];
					if (os.time() < tonumber(column._Until) or tonumber(column._Until) == 0) then
						evorp.player.takeAccess(player, column._Access)
						table.insert(player._Bans, column)
					end
				end;
			end;
		end
	end, 1);

	GetDBConnection():Query("SELECT * FROM players WHERE _UniqueID = "..uniqueID, function(result)
		if ( IsValid(player) ) then
			if (result and type(result) == "table" and #result > 0) then
				result = result[1];
				
				-- Load the player's data from the result table.
				player.evorp._Clan = result._Clan;
				player.evorp._Money = tonumber(result._Money);
				player.evorp._Donator = tonumber(result._Donator);
				player.evorp._Arrested = (result._Arrested == "true");
				player.evorp._PlayTime = tonumber(result._PlayTime);
				player.evorp._Inventory = { };
				player.evorp._NameIC = result._NameIC;
				player.evorp._Description = result._Description;
				player.evorp._FirstPlayed = result._FirstPlayed;
				player.evorp._LastPlayed = os.time();
				player.evorp._PointsRP = tonumber(result._PointsRP);
				player.evorp._AdminLevel = tonumber(result._AdminLevel);
				player.evorp._DonorCredits = tonumber(result._DonorCredits);
				player.evorp._Online = result._Online;
				player.evorp._Weps = result._Weps;

				local inventory = evorp.player.convertInventoryString(result._Inventory);
			
				-- Loop through the inventory and give each item to the player.
				for k, v in pairs(inventory) do evorp.inventory.update(player, k, v, true); end;
				
				-- Call the gamemode hook to say that we loaded our data.
				hook.Call("PlayerDataLoaded", GAMEMODE, player, true);
			else
				hook.Call("PlayerDataLoaded", GAMEMODE, player, false);
				evorp.player.saveData(player, true);
				player._UpdateData = true;
			end;
		end;
	end, 1);

	-- Create a timer to check if the player has initialized.
	timer.Create("Player Data Loaded: "..player:UniqueID(), 2, 1, function()
		if not (IsValid(player)) then return end
		if (!player._Initialized) then evorp.player.loadData(player); else player:KillSilent(); end;
	end);
end;

-- Get the player's inventory as a string.
function evorp.player.getInventoryString(player)
	local value = "";
	
	-- Loop through the table.
	for k2, v2 in pairs(player.evorp._Inventory) do
		value = value..k2..": "..tostring(v2).."; ";
	end;
	
	-- Return the new value.
	return string.sub(value, 1, -3);
end;

-- Get the player's inventory as a string.
function evorp.player.getInventoryString(player)
	local value = "";
	
	-- Loop through the table.
	for k2, v2 in pairs(player.evorp._Inventory) do
		value = value..k2..": "..tostring(v2).."; ";
	end;
	
	-- Return the new value.
	return string.sub(value, 1, -3);
end;

-- Convert an inventory string to a table.
function evorp.player.convertInventoryString(data)
	local exploded = string.Explode("; ", data);
	local inventory = {};
	
	-- Loop through our exploded values.
	for k, v in pairs(exploded) do
		local item;
		local amount;
		
		-- Substitute the item and amount into their variables.
		string.gsub(v, "(.+): ", function(a) item = a end)
		string.gsub(v, ": (.+)", function(a) amount = a end)
		
		-- Check to see if we have both an item and an amount.
		if (item and amount) then
			item = string.Trim(item);

			if (item == "cstm_rif_ak47a") then item = "bb_ak47" end
			if (item == "cstm_sniper_awp") then item = "bb_awp" end
			if (item == "cstm_pistol_deagle") then item = "bb_deagle" end
			if (item == "cstm_pistol_fiveseven") then item = "bb_fiveseven" end
			if (item == "cstm_sniper_g3") then item = "bb_g3sg1" end
			if (item == "cstm_rif_galil") then item = "bb_galil" end
			if (item == "cstm_pistol_glock18") then item = "bb_glock" end
			if (item == "cstm_shotgun_xm1014") then item = "bb_xm1014" end
			if (item == "cstm_rif_m249") then item = "bb_m249" end
			if (item == "cstm_shotgun_m3") then item = "bb_m3" end
			if (item == "cstm_smg_mp5") then item = "bb_mp5" end
			if (item == "cstm_pistol_p228") then item = "bb_p228" end
			if (item == "cstm_sniper_scout") then item = "bb_scout" end
			if (item == "cstm_smg_ump45") then item = "bb_ump45" end
			-- Check to see if this is a valid item.
			if (evorp.item.stored[item]) then inventory[item] = tonumber(amount); end;
		end;
	end;
	
	-- Return the new inventory.
	return inventory;
end;

-- Get a player's data as MySQL key values.
function evorp.player.getDataKeyValues(player)
	local keys = "";
	local values = "";
	local amount = 1;
	
	-- Loop through the player's data.
	for k, v in pairs(player.evorp) do
		local final = (table.Count(player.evorp) == amount)
		
		-- Check to see if it's the final key.
		if (final) then keys = keys..k; else keys = keys..k..", "; end;
		
		-- We create a temporary variable here to store the value.
		local value = tostring(v);
		
		-- Check to see if the type of the value is a table. (Inventory)
		if (type(v) == "table") then
				value = evorp.player.getInventoryString(player);
		end;
		
		value = tmysql.escape(value) --Important!!
		
		-- Check to see if it's the final key.
		if (final) then
			values = values.."\""..value.."\"";
		else
			values = values.."\""..value.."\", ";
		end;
		
		-- Update the amount that we've done.
		amount = amount + 1;
	end;
	
	-- Return the keys and values that we collected.
	return keys, values;
end;

-- Get an update query of a player's data.
function evorp.player.getDataUpdateQuery(player)
	local uniqueID = player:UniqueID();
	local query = "";
	
	-- Loop through our data.
	for k, v in pairs(player.evorp) do
		if (type(v) == "table") then
				v = evorp.player.getInventoryString(player);
		end;
		
		v = tmysql.escape(tostring(v)) --Important!!
		
		-- Check our query to see if it's an empty string.
		if (query == "") then
			query = "UPDATE players SET "..k.." = \""..v.."\"";
		else
			query = query..", "..k.." = \""..v.."\"";
		end;
	end;
	
	-- Return our collected query.
	return query.." WHERE _UniqueID = "..uniqueID;
end;

-- Save a player's data.
function evorp.player.saveData(player, create)
	if (player._Initialized) then
		if (create) then
			local keys, values = evorp.player.getDataKeyValues(player);
			
			-- Perform a threaded query.
			GetDBConnection():Query("INSERT INTO players ("..keys..") VALUES ("..values..")");
		else
			local query = evorp.player.getDataUpdateQuery(player);
			
			-- Perform a threaded query.
			--print(query)
			GetDBConnection():Query(query);
		end;
		player:PS_Save();
	end;
end;

-- Set a player's salary based on third party adjustments.
function evorp.player.setSalary(player)
	player._Salary = evorp.team.query(player:Team(), "salary") or 50;	
	-- Call a gamemode hook to adjust the player's salary.
	hook.Call("PlayerAdjustSalary", GAMEMODE, player)
end;

local trup, trdown = Vector(0,0,10), Vector(0,0,-2147483648);
-- Create a timer to update each player's data.
timer.Create("evorp.player.update", 0.1, 0, function()
	for k, v in pairs( g_Player.GetAll() ) do
		if (v and IsValid(v) and v._Initialized) then
			if (v._UpdateData) then
				if (CurTime() >= evorp.player.nextSecond) then
					if (v:Alive() and !v._KnockedOut and v:GetMoveType() == MOVETYPE_WALK  and !(v:IsInWorld() or util.QuickTrace(v:GetPos() + trup, trdown, v).HitSky)) then
						v._StuckInWorld = true;
					else
						v._StuckInWorld = false;
					end;
					-- Check if the player has at least 50 health.
					if (v:Health() >= 50) then v._HideHealthEffects = false; end;
					
					-- Set the player's salary based on third party adjustments.
					evorp.player.setSalary(v);
					
					-- Set it so that we can get some of the player's information client side.
					v:SetNetworkedString("evorp_Job", v._Job);
					v:SetNetworkedString("evorp_Clan", v.evorp._Clan);
					v:SetNetworkedBool("evorp_Donator", v.evorp._Donator > 0);
					--v:SetNetworkedInt("evorp_PlayTime", v.evorp._PlayTime);
					v:SetNetworkedString("evorp_NameIC", v.evorp._NameIC);
					v:SetNetworkedString("evorp_Description", v.evorp._Description);
					v:SetNetworkedInt("evorp_PointsRP", v.evorp._PointsRP);
					v:SetNetworkedInt("evorp_DCredits", v.evorp._DonorCredits);

					-- Set it so that we can get some of the player's information client side.
					evorp.player.setLocalPlayerVariable(v, CLASS_STRING, "_NextSpawnGender", v._NextSpawnGender);
					evorp.player.setLocalPlayerVariable(v, CLASS_STRING, "_Gender", v._Gender);
					evorp.player.setLocalPlayerVariable(v, CLASS_FLOAT, "_ScaleDamage", v._ScaleDamage);
					evorp.player.setLocalPlayerVariable(v, CLASS_BOOL, "_HideHealthEffects", v._HideHealthEffects);
					evorp.player.setLocalPlayerVariable(v, CLASS_BOOL, "_StuckInWorld", v._StuckInWorld);
					evorp.player.setLocalPlayerVariable(v, CLASS_LONG, "_Money", v.evorp._Money);
					evorp.player.setLocalPlayerVariable(v, CLASS_LONG, "_Salary", v._Salary);
					
					-- Call a gamemode hook to let third parties know this player has played for another second.
					hook.Call("PlayerSecond", GAMEMODE, v);
				end;
				-- Call a gamemode hook to let third parties know this player has played for a tenth of a second.
				hook.Call("PlayerTenthSecond", GAMEMODE, v);
			end;
		end;
	end;
	
	-- Check if the current time is greater than the next second.
	if (CurTime() >= evorp.player.nextSecond) then evorp.player.nextSecond = CurTime() + 1; end;
end);