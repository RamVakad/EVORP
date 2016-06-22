--[[
Name: "sv_commands.lua".
Product: "EvoRP (Roleplay)".
--]]

util.AddNetworkString( "extCmd" )

evorp.command = {};
evorp.command.stored = {};

-- Add a new command.
function evorp.command.add(command, access, arguments, callback, category, help, tip, noExsto)
	evorp.command.stored[command] = {access = access, arguments = arguments, callback = callback, tip = tip, help = help, noExsto = noExsto};
	
	-- Check to see if a category was specified.
	if (category and category != "Super Admin Commands") then
		if (!help or help == "") then
			evorp.help.add(category, evorp.configuration["Command Prefix"]..command.." <none>.", tip);
		else
			evorp.help.add(category, evorp.configuration["Command Prefix"]..command.." "..help..". "..tip, tip);
		end;
	end;
end;


function evorp.command.ConCommand(player, text) --Only EVORP Command thingy.
	local arguments = string.Explode(" ", text);
	local command = arguments[1];
	local quote = false;
	local revised = {};
	-- Loop through the arguments that we specified.
	table.insert(revised, command)
	for k, v in ipairs(arguments) do
		if not (k == 1) then 
			if (quote) then
				if (string.sub(v, -1) == "\"") then
					quote = quote.." "..string.sub(v, 1, string.len(v) - 1)
					table.insert(revised, quote)
					quote = false;
				else
					quote = quote.." "..v
				end
			else
				if (string.sub(v, 1, 1) == "\"") then
					quote = string.sub(v, 2);
				else
					table.insert(revised, v)
				end
			end
		end;
	end;
	
	evorp.command.consoleCommand(player, command, revised)
	--player:ConCommand("evorp "..command.." "..table.concat(arguments, " ", 2).."\n"); --This is a two way trip.
end

net.Receive( "extCmd", function( len, pl )
	if ( IsValid( pl ) and pl:IsPlayer() ) then
		--local cmd = net.ReadString()	
		local args = net.ReadTable()
		evorp.command.consoleCommand(pl, args[1], args)
	end
end )


-- This is called when a player runs a command from the console.
function evorp.command.consoleCommand(player, command, arguments)
	if (player._Initialized) then
		if (arguments and arguments[1]) then
			command = string.lower(table.remove(arguments, 1));
			
			-- Check to see if the command exists.
			if (evorp.command.stored[command]) then
				
				-- Loop through the arguments and fix Valve's errors.
				for k, v in pairs(arguments) do
					arguments[k] = string.Replace(arguments[k], " ' ", "'");
					arguments[k] = string.Replace(arguments[k], " : ", ":");
				end;
				
				-- Check if the player can use this command.
				if ( hook.Call("PlayerCanUseCommand", GAMEMODE, player, command, arguments) ) then
					if (#arguments >= evorp.command.stored[command].arguments) then
						if ( evorp.player.hasAccess(player, evorp.command.stored[command].access) ) then
							local success, fault = pcall(evorp.command.stored[command].callback, player, arguments);
							
							-- Check if we have specified any arguments.
							
							
							-- Check to see if we did not succeed.
							if not (command == "inventory") then
								if (!success) then
									if (table.concat(arguments, " ") != "") then
										evorp.player.printConsoleAccess("FAIL:["..fault.."] "..player:Name().. " [".. player:SteamID() .. "]".." used 'evorp "..command.." "..table.concat(arguments, " ").."'.", "a", player);
									else
										evorp.player.printConsoleAccess("FAIL:["..fault.."] "..player:Name().. " [".. player:SteamID() .. "]".." used 'evorp "..command.."'.", "a", player);
									end;
								else
									if (table.concat(arguments, " ") != "") then
										evorp.player.printConsoleAccess(player:Name().. " [".. player:SteamID() .. "]".." used 'evorp "..command.." "..table.concat(arguments, " ").."'.", "a", player);
									else
										evorp.player.printConsoleAccess(player:Name().. " [".. player:SteamID() .. "]".." used 'evorp "..command.."'.", "a", player);
									end;
								end;
							end
						else
							evorp.player.notify(player, "You do not have access to this command.", 1);
						end;
					else
						evorp.player.notify(player, "This command requires atleast "..evorp.command.stored[command].arguments.." arguments!", 1);
					end;
				end;
			else
				evorp.player.notify(player, "This is not a valid command!", 1);
			end;
		else
			evorp.player.notify(player, "This is not a valid command!", 1);
		end;
	else
		evorp.player.notify(player, "You haven't initialized yet!", 1);
	end;
end;

-- Add a new console command.
concommand.Add("evorp", evorp.command.consoleCommand);
