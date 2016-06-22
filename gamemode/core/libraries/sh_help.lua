--[[
Name: "sh_help.lua".
Product: "evorp (Roleplay)".
--]]

if (SERVER) then
	util.AddNetworkString("evorp.help.help") 
	util.AddNetworkString("evorp.help.category") 
end

evorp.help = {};
evorp.help.stored = {};
evorp.help.category = nil;

-- Add a new line of help to the specified category.
function evorp.help.add(category, help, tip, command)
	local new = true;
	
	-- Loop through the help to try and find the category.
	for k, v in pairs(evorp.help.stored) do
		if (v.category == category) then
			if (help) then
			table.insert( v.help, {command = command, text = help, tip = tip} );
			end;
				
			-- Set the new variable to false because we found an existing category.
			new = false;
		end;
	end;
	
	-- Check to see if we should create a new category. // this part looks like got issues but i dont think we use at moment, why is help in {} and key for help should be text and where is tip? / temar
	if (new) then
		if (help) then
			table.insert( evorp.help.stored, { category = category, help = {help} } );
		else
			table.insert( evorp.help.stored, { category = category, help = {} } );
		end;
	end;
	
	-- Check if we have any help to send.
	if (help) then
		if (CLIENT) then
			if (evorp.help.panel) then evorp.help.panel:Reload(); end;
		else
			net.Start("evorp.help.category") net.WriteString(category); net.Broadcast();
			net.Start("evorp.help.help")
				net.WriteString(help);
				
				-- Check to see if we supplied a tip.
				if (tip) then net.WriteString(tip); end;
			net.Broadcast();
		end;
	end;
end;

function evorp.help.get(command)
	local new = true;
	
	-- Loop through the help to try and find the category.
	for k, v in pairs(evorp.help.stored) do
		for c, v2 in pairs(v.help) do	
			if (type(v2) == "table" && v2.command == command) then
				return v2.text
			end;
		end;
	end;
	return false;
end;

function evorp.help.clearLaws()
	for k, v in pairs(evorp.help.stored) do
		if v.category == "Laws" then v.help = { }; end
	end;
	if (SERVER) then
		umsg.Start("ClearLaws", player) umsg.End();
	else
		if (evorp.help.panel) then
			evorp.help.panel:Reload()
		end
	end
end

-- Add the common help categories.
evorp.help.add("Laws");
evorp.help.add("Permanent Laws");
evorp.help.add("General");
evorp.help.add("Commands");
evorp.help.add("President Commands")
evorp.help.add("Admin Commands");
--evorp.help.add("Super Admin Commands");
if (SERVER) then
	evorp.help.add("Laws", "Speed limit inside the city is 20 MPH, outside the city is 60 MPH.");
	evorp.help.add("Laws", "Fine for breaking the speed limit is $100");
	evorp.help.add("Laws", "Improperly parked vehicles will be impounded to the Nexus Garage.");
	evorp.help.add("Laws", "The fee to retrieve a vehicle from the impound is $200.");
end

-- Check if we're running on the client.
if (CLIENT) then
	net.Receive("evorp.help.category", function(msg)
		evorp.help.category = net.ReadString();
	end);
	
	-- A usermessage to get a line of help from the server.
	net.Receive("evorp.help.help", function(msg)
		local help = net.ReadString();
		local tip = net.ReadString();
		
		-- Add the help to the specified category.
		evorp.help.add(evorp.help.category, help, tip);
	end);


	usermessage.Hook("ClearLaws", function(msg)
		evorp.help.clearLaws()
		if (evorp.help.panel) then
			evorp.help.panel:Reload()
		end
	end);
	
	-- Add some general help.
	evorp.help.add("General", "You can use the F4 menu to execute a lot of the commands using a graphical interface.");
	evorp.help.add("General", "Use '!commands' for a list of ALL the commands and their functions. This page also contains command documentation.");
	evorp.help.add("General", "Read the rules and roleplay guide on the forum. (EVORP.NET)");
	evorp.help.add("General", "If you need to contact an admin, use the /admin command.");
	evorp.help.add("General", "Ignorance is not an excuse. Failure to do the above stated will lead to a ban.");
	evorp.help.add("General", "You can bring your car back into your inventory by placing it on the parking spot closest to the BP.");
	evorp.help.add("General", "5 Minutes = 1 Day in-game.");
	evorp.help.add("General", "Speed of vehicles is measured in 'Evo Miles Per Hour' (EMPH).");
	evorp.help.add("General", "OOC = Out Of Character, IC = In Character");
	evorp.help.add("General", "When OOC leaks into IC, it's considered metagaming and will lead to a ban.");
	evorp.help.add("General", "Use // before your message to use global OOC chat.");
	evorp.help.add("General", "Use .// before your message to use local OOC chat.");
	evorp.help.add("General", "Visit EVORP.NET for help, tips, guides, et cetera.");
	evorp.help.add("General", "Hover over the spawn icon of an item to find out it's UniqueID.");
	evorp.help.add("General", "A heart icon next to name = Donator.");
	evorp.help.add("General", "Wrench Icon = Moderator, Star Icon = Administrator, Shield Icon = Super Administrator");
	evorp.help.add("General", "Person Icon = Casual Player.");
	evorp.help.add("General", "The Q menu will provide you with view options (SharyeYe, Customisable Thirdperson)");
	evorp.help.add("General", "The president can use /clearlaws and /law commands to set the laws in this F1 Menu");
	evorp.help.add("General", "You can trade pointshop items using !trade");
	evorp.help.add("Permanent Laws", "Drive on the right side of the road. (Context of 'right' is positional.)");
	evorp.help.add("Permanent Laws", "Abide the traffic lights and only cross at zebra crossings. You can be fined.");
	evorp.help.add("Permanent Laws", "Officers cannot step on private property without consent of the owner or without a warrant.");
	evorp.help.add("Permanent Laws", "Officers must give reasons for tasering, arresting, shooting at the time of action.");
	evorp.help.add("Permanent Laws", "Improperly parked vehicles will be stored in the Nexus Garage, and a fine of $100 must be paid.");
	evorp.help.add("Permanent Laws", "Officers are not allowed to shoot unless absolutely necessary.");
	evorp.help.add("Permanent Laws", "Dealership of weapons is legal!");
	evorp.help.add("Permanent Laws", "Openly carrying weapons is illegal unless you are an officer.");
	evorp.help.add("Permanent Laws", "Contraband is illegal.");
else
	function evorp.help.playerInitialized(player)
		timer.Simple(1, function()
			if ( IsValid(player) ) then
				for k, v in pairs(evorp.help.stored) do
					net.Start("evorp.help.category") net.WriteString(v.category); net.Send(player);
					
					-- Loop through the help in this category.
					for k2, v2 in pairs(v.help) do
						net.Start("evorp.help.help")
							net.WriteString(v2.text);
							
							-- Check to see if we have a tip.
							if (v2.tip) then net.WriteString(v2.tip); end;
						net.Send(player);
					end;
				end;
				
				-- Show the player the help menu.
				GAMEMODE:ShowHelp(player);
			end;
		end);
	end;
	
	-- Add the hook on a timer.
	timer.Simple(FrameTime() * 0.5, function()
		evorp.hook.add("PlayerInitialized", evorp.help.playerInitialized);
	end);
end;