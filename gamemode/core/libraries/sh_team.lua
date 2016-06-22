--[[
Name: "sh_team.lua".
Product: "evorp (Roleplay)".
--]]

evorp.team = {};
evorp.team.index = 1;
evorp.team.stored = {};

-- Add a new team.
function evorp.team.add(name, color, males, females, description, salary, limit, canmake, accessNeeded, radio)
	local data = {
		name = name,
		index = evorp.team.index,
		color = color,
		models = {},
		salary = salary,
		limit = limit,
		description = description,
		canmake = canmake,
		accessNeeded = accessNeeded,
		radio = radio
	};
	
	-- Check if the male and female models are a table and if not make them one.
	if (males and type(males) != "table") then males = {males}; end;
	if (males and type(females) != "table") then females = {females}; end;
	
	-- Make the limit maximum players if there is none set.
	data.limit = data.limit or game.MaxPlayers();
	data.description = data.description or "N/A.";
	data.accessNeeded = data.accessNeeded or "b";
	data.models.male = males or evorp.configuration["Default Model"];
	data.models.female = females or evorp.configuration["Default Model"];
	data.canmake = data.canmake or {"Class Vehicles", "Vehicles", "Misc.", "Contraband"};
	data.radio = data.radio or "R_OPEN";
	
	-- Set the team up (this is called on the server and the client).
	team.SetUp(evorp.team.index, name, color);
	
	-- Insert the data for our new team into our table.
	evorp.team.stored[name] = data;
	
	-- Increase the team index so we don't duplicate any team.
	evorp.team.index = evorp.team.index + 1;
	
	-- Return the index of the team.
	return data.index;
end;

-- Get a team from a name of index.
function evorp.team.get(name)
	local team;
	
	-- Check if we have a number (it's probably an index).
	if ( tonumber(name) ) then
		for k, v in pairs(evorp.team.stored) do
			if ( v.index == tonumber(name) ) then team = v; break; end;
		end;
	else
		for k, v in pairs(evorp.team.stored) do
			if ( string.find( string.lower(v.name), string.lower(name) ) ) then
				if (team) then
					if ( string.len(v.name) < string.len(team.name) ) then
						team = v;
					end;
				else
					team = v;
				end;
			end;
		end;
	end;
	
	-- Return the team that we found.
	return team;
end;

-- Query a variable from a team.
function evorp.team.query(name, key, default)
	local team = evorp.team.get(name);
	
	-- Check to see if it's a valid team.
	if (team) then
		return team[key] or default;
	else
		return default;
	end;
end;

-- Check to see if we're running on the server.
if (SERVER) then
	-- Make a player a member of a team.
	function evorp.team.make(player, name)
		local team = evorp.team.get(name);
		
		-- Check to see if the team exists.
		if (team) then
			local hours = math.floor((player:GetNetworkedInt("evorp_PlayTime", 0) + (os.time() - player:GetNetworkedInt("evorp_JoinCurTime", 0))) / 3600)
			-- Check to see if the team exists.
			if team.index == (TEAM_COMMANDER) or team.index == (TEAM_OFFICER) or team.index == (TEAM_SS) or team.index == (TEAM_HOSS) then
				if (hours < 5) then
					return false, "You have to play at least 5 hours to play that class!";
				end
			elseif team.index == (TEAM_PRESIDENT) then
				if (hours < 10) then
					return false, "You have to play at least 10 hours to be a president!";
				end  
			end  
			if team.index == (TEAM_SS) or team.index == (TEAM_HOSS) then
				if not (player.evorp._Donator > 0 or player:IsAdmin()) then
					return false, "You never had VIP status!";
				end
			end
			local query = evorp.team.query(name, "accessNeeded")
			if (evorp.player.hasAccess(player, query) or player:IsAdmin()) then
				if (player:InVehicle()) then
					player:ExitVehicle();
				end;
				player._NextChangeTeam[ player:Team() ] = CurTime() + 300;
				
				-- Set their new team and change their job.
				player:SetTeam(team.index);
				player._Job = team.name;
				evorp.player.holsterAll(player)
				-- Silently kill the player.
				player._ChangeTeam = true; player:KillSilent();
				
				-- Return true because it was successful.
				return true;
			else
				return false, "You are banned from roleplaying as that class. Go online for more information.";
			end;
		else
			return false, "This is not a valid team!";
		end;
	end;
end;
