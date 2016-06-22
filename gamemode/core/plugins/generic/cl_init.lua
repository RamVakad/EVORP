--[[
Name: "cl_init.lua".
Product: "EvoRP (Roleplay)".
--]]

local PLUGIN = {};

-- Create a variable to store the plugin for the shared file.
PLUGIN_SHARED = PLUGIN;

-- Include the shared file.
include("sh_init.lua");

-- Called when a player's HUD should be painted.
--[[HUGE Warrant notif
evorp.hook.add("PlayerHUDPaint", function(player)
	if ( LocalPlayer():Alive() and !LocalPlayer():GetNetworkedBool("evorp_KnockedOut") ) then
		
		if (evorp.team.query(player:Team(), "radio", "") == "R_GOV") then
			if ( player:Alive() ) then
				if (player:GetNetworkedString("evorp_Warranted") != "") then
					local alpha = math.Clamp( 255 - ( (255 / 4096) * ( LocalPlayer():GetShootPos():Distance( player:GetShootPos() ) ) ), 0, 255 );
					
					-- Set the text that will display and the color of the text.
					local text = player:Name();
					local color = Color(255, 255, 255, 255);
					
					-- Check the class of the warrant.
					if (player:GetNetworkedString("evorp_Warranted") == "search") then
						text = text.." (Search Warrant)"; color = Color(75, 150, 255, 255);
					elseif (player:GetNetworkedString("evorp_Warranted") == "arrest") then
						text = text.." (Arrest Warrant)"; color = Color(255, 50, 50, 255);
					end;
					
					-- Define the x and y position.
					local x = player:GetShootPos():ToScreen().x;
					local y = player:GetShootPos():ToScreen().y - 64;
					
					-- Check if the player is knocked out.
					if ( player:GetNetworkedBool("evorp_KnockedOut") ) then
						if ( IsValid( player:GetNetworkedEntity("evorp_Ragdoll") ) ) then
							x = player:GetNetworkedEntity("evorp_Ragdoll"):GetPos():ToScreen().x;
							y = player:GetNetworkedEntity("evorp_Ragdoll"):GetPos():ToScreen().y - 64;
						end;
					end;
					
					-- Balance out the y position.
					y = y + (32 * (LocalPlayer():GetShootPos():Distance( player:GetShootPos() ) / 4096)) * 0.5;
					
					-- Draw the information and get the new y position.
					y = GAMEMODE:DrawInformation(text, "EvoFont", x, y + math.sin( CurTime() ) * 8, color, alpha);
				end;
			end;
		end;
		
	end;
end);
]]
-- Called when the top text should be drawn.
evorp.hook.add("DrawTopText", function(text)
	if (GetGlobalInt("evorp_Lockdown") == 1) then
		text.y = GAMEMODE:DrawInformation("A lockdown is in progress. Please return to your home.", "EvoFont", text.x, text.y, Color(255, 50, 50, 255), 255, true, function(x, y, width, height)
			return x - width - 8, y;
		end);
	end;
	
	-- Check if the player is the City Administrator.
	if (LocalPlayer():Team() == TEAM_PRESIDENT) then
		local _SpawnImmunityTime = LocalPlayer()._SpawnImmunityTime or 0;
		
		-- Check if the spawn immunity time is greater than the current time.
		if ( _SpawnImmunityTime > CurTime() ) then
			local seconds = math.floor( _SpawnImmunityTime - CurTime() );
			
			-- Check if the amount of seconds is greater than 0.
			if (seconds > 0) then
				text.y = GAMEMODE:DrawInformation("You have spawn immunity for "..seconds.." second(s).", "EvoFont", text.x, text.y, Color(150, 255, 75, 255), 255, true, function(x, y, width, height)
					return x - width - 8, y;
				end);
			end;
		end;
	end;
	
	-- Check if the player is warranted.
	if (LocalPlayer():GetNetworkedString("evorp_Warranted") != "") then
		local _WarrantExpireTime = LocalPlayer()._WarrantExpireTime;
		
		-- Text which is extended to the notice.
		local extension = ".";
		
		-- Check if the warrant expire time exists.
		if (_WarrantExpireTime) then
			local seconds = math.floor( _WarrantExpireTime - CurTime() );
			
			-- Check if the amount of seconds is greater than 0.
			if (seconds > 0) then
				if (seconds > 60) then
					extension = " which expires in "..math.ceil(seconds / 60).." minute(s).";
				else
					extension = " which expires in "..seconds.." second(s).";
				end;
			end;
		end;
		
		-- Check the class of the warrant.
		if (LocalPlayer():GetNetworkedString("evorp_Warranted") == "search") then
			text.y = GAMEMODE:DrawInformation("You have a search warrant"..extension, "EvoFont", text.x, text.y, Color(150, 255, 75, 255), 255, true, function(x, y, width, height)
				return x - width - 8, y;
			end);
		elseif (LocalPlayer():GetNetworkedString("evorp_Warranted") == "arrest") then
			text.y = GAMEMODE:DrawInformation("You have an arrest warrant"..extension, "EvoFont", text.x, text.y, Color(150, 255, 75, 255), 255, true, function(x, y, width, height)
				return x - width - 8, y;
			end);
		end;
	end;

	if (LocalPlayer():GetNetworkedBool("hostaged")) then 
		text.y = GAMEMODE:DrawInformation("You are currently tied up.", "EvoFont", text.x, text.y, Color(150, 255, 75, 255), 255, true, function(x, y, width, height)
				return x - width - 8, y;
			end);
	end;
	
	-- Check if the player is handcuffed.
	if (LocalPlayer():GetNetworkedInt("LastRevive") + 60 > CurTime()) then
		text.y = GAMEMODE:DrawInformation("You are weak from your near-death experience.", "EvoFont", text.x, text.y, Color(255, 150, 75, 255), 255, true, function(x, y, width, height)
			return x - width - 8, y;
		end);
	end
	if (LocalPlayer():GetNetworkedBool("cuffed")) then 
		text.y = GAMEMODE:DrawInformation("You are currently handcuffed.", "EvoFont", text.x, text.y, Color(150, 255, 75, 255), 255, true, function(x, y, width, height)
			return x - width - 8, y;
		end);
	end;
	
	-- Check if the player is arrested.
	if ( LocalPlayer():GetNetworkedBool("evorp_Arrested") ) then
		local _UnarrestTime = LocalPlayer()._UnarrestTime or 0;
		
		-- Check if the unarrest time is greater than the current time.
		if ( _UnarrestTime > CurTime() ) then
			local seconds = math.floor( _UnarrestTime - CurTime() );
			
			-- Check if the amount of seconds is greater than 0.
			if (seconds > 0) then
				if (seconds > 60) then
					text.y = GAMEMODE:DrawInformation("You will be unarrested in "..math.ceil(seconds / 60).." minute(s).", "EvoFont", text.x, text.y, Color(75, 150, 255, 255), 255, true, function(x, y, width, height)
						return x - width - 8, y;
					end);
				else
					text.y = GAMEMODE:DrawInformation("You will be unarrested in "..seconds.." second(s).", "EvoFont", text.x, text.y, Color(75, 150, 255, 255), 255, true, function(x, y, width, height)
						return x - width - 8, y;
					end);
				end;
			end;
		end;
	end;
	
	-- Check if the player is wearing kevlar.
	if (LocalPlayer()._ScaleDamage == 0.5) then
		text.y = GAMEMODE:DrawInformation("You are wearing kevlar which reduces damage by 50%.", "EvoFont", text.x, text.y, Color(255, 75, 150, 255), 255, true, function(x, y, width, height)
			return x - width - 8, y;
		end);
	end;
end);
	
-- Called when the HUD should be painted.
evorp.hook.add("HUDPaint", function()
	if (IsValid( LocalPlayer():GetActiveWeapon() ) and LocalPlayer():GetActiveWeapon():GetClass() != "gmod_tool" and LocalPlayer():GetActiveWeapon():GetClass() != "gmod_camera") then
		if (LocalPlayer():Team() == TEAM_REBEL or LocalPlayer():Team() == TEAM_RLEADER) then
			for k, v in pairs( team.GetPlayers(TEAM_RLEADER) ) do
				local text = "";
				
				-- Loop through 1 to 10.
				for i = 1, 10 do
					local line = GetGlobalString("evorp_RObjective_"..i);
					
					-- Check if the line exists.
					if (line != "") then
						line = string.Replace(line, " ' ", "'");
						line = string.Replace(line, " : ", ":");
						
						-- Add the line to our text.
						text = text..line;
					end;
				end;
				
				-- Create a table to store the wrapped text and then get the wrapped text.
				local wrapped = {};
				
				-- Wrap the text into our table.
				evorp.chatBox.wrapText(text, "EvoFont", 256, nil, wrapped);
				
				-- Check if we have at least 1 line in our text.
				if (wrapped[1] != "") then
					local width, height = surface.GetTextSize("EvoFont", wrapped[1]);
					
					-- Adjust the maximum width to our objective display.
					width = GAMEMODE:AdjustMaximumWidth("EvoFont", "Rebel Objective", width, 16);
					
					-- Loop through our text.
					for k, v in pairs(wrapped) do
						width = GAMEMODE:AdjustMaximumWidth("EvoFont", v, width, 16);
					end;
					
					-- Draw a box in the the top left corner.
					draw.RoundedBox( 2, 8, 8, width, 22 * (table.Count(wrapped) + 1) + 12, Color(0, 0, 0, 200) );
					
					-- Set the x and y position of the text.
					local x, y = 16, 16;
					
					-- Draw some text to show we're gonna display their objective.
					y = GAMEMODE:DrawInformation("Rebel Objective", "EvoFont", x, y, Color(175, 175, 175, 255), 255, true);
					
					-- Loop through our text.
					for k, v in pairs(wrapped) do
						y = GAMEMODE:DrawInformation(v, "EvoFont", x, y, Color(255, 255, 255, 255), 255, true);
					end;
				end;
				
				-- Break because we only have one Rebel Leader.
				break;
			end;
		end;
		
		if (LocalPlayer():Team() == TEAM_MAFIA or LocalPlayer():Team() == TEAM_MLEADER) then
			for k, v in pairs( team.GetPlayers(TEAM_MLEADER) ) do
				local text = "";
				
				-- Loop through 1 to 10.
				for i = 1, 10 do
					local line = GetGlobalString("evorp_MObjective_"..i);
					
					-- Check if the line exists.
					if (line != "") then
						line = string.Replace(line, " ' ", "'");
						line = string.Replace(line, " : ", ":");
						
						-- Add the line to our text.
						text = text..line;
					end;
				end;
				
				-- Create a table to store the wrapped text and then get the wrapped text.
				local wrapped = {};
				
				-- Wrap the text into our table.
				evorp.chatBox.wrapText(text, "EvoFont", 256, nil, wrapped);
				
				-- Check if we have at least 1 line in our text.
				if (wrapped[1] != "") then
					local width, height = surface.GetTextSize("EvoFont", wrapped[1]);
					
					-- Adjust the maximum width to our objective display.
					width = GAMEMODE:AdjustMaximumWidth("EvoFont", "Mafia Objective", width, 16);
					
					-- Loop through our text.
					for k, v in pairs(wrapped) do
						width = GAMEMODE:AdjustMaximumWidth("EvoFont", v, width, 16);
					end;
					
					-- Draw a box in the the top left corner.
					draw.RoundedBox( 2, 8, 8, width, 22 * (table.Count(wrapped) + 1) + 12, Color(0, 0, 0, 200) );
					
					-- Set the x and y position of the text.
					local x, y = 16, 16;
					
					-- Draw some text to show we're gonna display their objective.
					y = GAMEMODE:DrawInformation("Mafia Objective", "EvoFont", x, y, Color(175, 175, 175, 255), 255, true);
					
					-- Loop through our text.
					for k, v in pairs(wrapped) do
						y = GAMEMODE:DrawInformation(v, "EvoFont", x, y, Color(255, 255, 255, 255), 255, true);
					end;
				end;
				
				-- Break because we only have one Mafia Leader.
				break;
			end;
		end;
		
		
		if (LocalPlayer():Team() == TEAM_COMMANDER or LocalPlayer():Team() == TEAM_OFFICER) then
			for k, v in pairs( team.GetPlayers(TEAM_COMMANDER) ) do
				local text = "";
				
				-- Loop through 1 to 10.
				for i = 1, 10 do
					local line = GetGlobalString("evorp_CObjective_"..i);
					
					-- Check if the line exists.
					if (line != "") then
						line = string.Replace(line, " ' ", "'");
						line = string.Replace(line, " : ", ":");
						
						-- Add the line to our text.
						text = text..line;
					end;
				end;
				
				-- Create a table to store the wrapped text and then get the wrapped text.
				local wrapped = {};
				
				-- Wrap the text into our table.
				evorp.chatBox.wrapText(text, "EvoFont", 256, nil, wrapped);
				
				-- Check if we have at least 1 line in our text.
				if (wrapped[1] != "") then
					local width, height = surface.GetTextSize("EvoFont", wrapped[1]);
					
					-- Adjust the maximum width to our objective display.
					width = GAMEMODE:AdjustMaximumWidth("EvoFont", "Police Objective", width, 16);
					
					-- Loop through our text.
					for k, v in pairs(wrapped) do
						width = GAMEMODE:AdjustMaximumWidth("EvoFont", v, width, 16);
					end;
					
					-- Draw a box in the the top left corner.
					draw.RoundedBox( 2, 8, 8, width, 22 * (table.Count(wrapped) + 1) + 12, Color(0, 0, 0, 200) );
					
					-- Set the x and y position of the text.
					local x, y = 16, 16;
					
					-- Draw some text to show we're gonna display their objective.
					y = GAMEMODE:DrawInformation("Police Objective", "EvoFont", x, y, Color(175, 175, 175, 255), 255, true);
					
					-- Loop through our text.
					for k, v in pairs(wrapped) do
						y = GAMEMODE:DrawInformation(v, "EvoFont", x, y, Color(255, 255, 255, 255), 255, true);
					end;
				end;
				
				-- Break because we only have one Mafia Leader.
				break;
			end;
		end;

		if (LocalPlayer():Team() == TEAM_HOSS or LocalPlayer():Team() == TEAM_SS) then
			for k, v in pairs( team.GetPlayers(TEAM_HOSS) ) do
				local text = "";
				
				-- Loop through 1 to 10.
				for i = 1, 10 do
					local line = GetGlobalString("evorp_HObjective_"..i);
					
					-- Check if the line exists.
					if (line != "") then
						line = string.Replace(line, " ' ", "'");
						line = string.Replace(line, " : ", ":");
						
						-- Add the line to our text.
						text = text..line;
					end;
				end;
				
				-- Create a table to store the wrapped text and then get the wrapped text.
				local wrapped = {};
				
				-- Wrap the text into our table.
				evorp.chatBox.wrapText(text, "EvoFont", 256, nil, wrapped);
				
				-- Check if we have at least 1 line in our text.
				if (wrapped[1] != "") then
					local width, height = surface.GetTextSize("EvoFont", wrapped[1]);
					
					-- Adjust the maximum width to our objective display.
					width = GAMEMODE:AdjustMaximumWidth("EvoFont", "Secret Service Objective", width, 16);
					
					-- Loop through our text.
					for k, v in pairs(wrapped) do
						width = GAMEMODE:AdjustMaximumWidth("EvoFont", v, width, 16);
					end;
					
					-- Draw a box in the the top left corner.
					draw.RoundedBox( 2, 8, 8, width, 22 * (table.Count(wrapped) + 1) + 12, Color(0, 0, 0, 200) );
					
					-- Set the x and y position of the text.
					local x, y = 16, 16;
					
					-- Draw some text to show we're gonna display their objective.
					y = GAMEMODE:DrawInformation("Secret Service Objective", "EvoFont", x, y, Color(175, 175, 175, 255), 255, true);
					
					-- Loop through our text.
					for k, v in pairs(wrapped) do
						y = GAMEMODE:DrawInformation(v, "EvoFont", x, y, Color(255, 255, 255, 255), 255, true);
					end;
				end;
				
				-- Break because we only have one Mafia Leader.
				break;
			end;
		end;

		if (LocalPlayer():Team() == TEAM_RENLEADER or LocalPlayer():Team() == TEAM_RENEGADE) then
			for k, v in pairs( team.GetPlayers(TEAM_RENLEADER ) ) do
				local text = "";
				
				-- Loop through 1 to 10.
				for i = 1, 10 do
					local line = GetGlobalString("evorp_RenObjective_"..i);
					
					-- Check if the line exists.
					if (line != "") then
						line = string.Replace(line, " ' ", "'");
						line = string.Replace(line, " : ", ":");
						
						-- Add the line to our text.
						text = text..line;
					end;
				end;
				
				-- Create a table to store the wrapped text and then get the wrapped text.
				local wrapped = {};
				
				-- Wrap the text into our table.
				evorp.chatBox.wrapText(text, "EvoFont", 256, nil, wrapped);
				
				-- Check if we have at least 1 line in our text.
				if (wrapped[1] != "") then
					local width, height = surface.GetTextSize("EvoFont", wrapped[1]);
					
					-- Adjust the maximum width to our objective display.
					width = GAMEMODE:AdjustMaximumWidth("EvoFont", "Renegade Objective", width, 16);
					
					-- Loop through our text.
					for k, v in pairs(wrapped) do
						width = GAMEMODE:AdjustMaximumWidth("EvoFont", v, width, 16);
					end;
					
					-- Draw a box in the the top left corner.
					draw.RoundedBox( 2, 8, 8, width, 22 * (table.Count(wrapped) + 1) + 12, Color(0, 0, 0, 200) );
					
					-- Set the x and y position of the text.
					local x, y = 16, 16;
					
					-- Draw some text to show we're gonna display their objective.
					y = GAMEMODE:DrawInformation("Renegade Objective", "EvoFont", x, y, Color(175, 175, 175, 255), 255, true);
					
					-- Loop through our text.
					for k, v in pairs(wrapped) do
						y = GAMEMODE:DrawInformation(v, "EvoFont", x, y, Color(255, 255, 255, 255), 255, true);
					end;
				end;
				
				-- Break because we only have one Mafia Leader.
				break;
			end;
		end;

		if (LocalPlayer():Team() == TEAM_TLEADER or LocalPlayer():Team() == TEAM_THIEF) then
			for k, v in pairs( team.GetPlayers(TEAM_TLEADER ) ) do
				local text = "";
				
				-- Loop through 1 to 10.
				for i = 1, 10 do
					local line = GetGlobalString("evorp_TObjective_"..i);
					
					-- Check if the line exists.
					if (line != "") then
						line = string.Replace(line, " ' ", "'");
						line = string.Replace(line, " : ", ":");
						
						-- Add the line to our text.
						text = text..line;
					end;
				end;
				
				-- Create a table to store the wrapped text and then get the wrapped text.
				local wrapped = {};
				
				-- Wrap the text into our table.
				evorp.chatBox.wrapText(text, "EvoFont", 256, nil, wrapped);
				
				-- Check if we have at least 1 line in our text.
				if (wrapped[1] != "") then
					local width, height = surface.GetTextSize("EvoFont", wrapped[1]);
					
					-- Adjust the maximum width to our objective display.
					width = GAMEMODE:AdjustMaximumWidth("EvoFont", "Rogue Objective", width, 16);
					
					-- Loop through our text.
					for k, v in pairs(wrapped) do
						width = GAMEMODE:AdjustMaximumWidth("EvoFont", v, width, 16);
					end;
					
					-- Draw a box in the the top left corner.
					draw.RoundedBox( 2, 8, 8, width, 22 * (table.Count(wrapped) + 1) + 12, Color(0, 0, 0, 200) );
					
					-- Set the x and y position of the text.
					local x, y = 16, 16;
					
					-- Draw some text to show we're gonna display their objective.
					y = GAMEMODE:DrawInformation("Rogue Objective", "EvoFont", x, y, Color(175, 175, 175, 255), 255, true);
					
					-- Loop through our text.
					for k, v in pairs(wrapped) do
						y = GAMEMODE:DrawInformation(v, "EvoFont", x, y, Color(255, 255, 255, 255), 255, true);
					end;
				end;
				
				-- Break because we only have one Mafia Leader.
				break;
			end;
		end;

	end;
end)

-- Register the plugin.
evorp.plugin.register(PLUGIN);
