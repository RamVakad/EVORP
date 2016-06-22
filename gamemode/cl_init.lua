--[[
Name: "cl_init.lua".
Product: "EvoRP (Roleplay)".
--]]
surface.CreateFont("Museo", {font = "Museo Sans 500", size= 24, weight = 400, antialias = true } )
surface.CreateFont("Franchise", {font = "Franchise", size= 24, weight = 400, antialias = true } )
surface.CreateFont("EvoFontN1", {font = "Museo Sans 500", size = 20, weight = 600, antialias = true, shadow = false}); -- A slightly bigger font.
surface.CreateFont("EvoFont", {font = "Museo Sans 500", size = 17, weight = 600, antialias = true, shadow = false}); -- Chat and Char info font
surface.CreateFont("EvoFont2", {font = "Museo Sans 500", size = 16, weight = 400, antialias = true, shadow = false}); -- F1, readable font
surface.CreateFont("EvoFont3", {font = "Museo Sans 500", size = 12, weight = 400, antialias = true, shadow = false}); -- Bar Font

include("sh_init.lua");
include("core/scoreboard/scoreboard.lua");

-- Set some information for the gamemode.
GM.topTextGradient = {};
GM.variableQueue = {};

surface.CreateFont("LabelFont", {font = "Museo Sans 500", size = 60, weight = 575, antialias = false, shadow = true});

-- Add a usermessage to recieve a notification.
usermessage.Hook("evorp_Notification", function(msg)
	local message = msg:ReadString();
	local class = msg:ReadShort();
	
	-- The sound of the notification.
	local sound = "ambient/water/drip2.wav";
	
	-- Check the class of the message.
	if (class == 1) then
		sound = "buttons/button10.wav";
	elseif (class == 2) then
		sound = "buttons/button17.wav";
	elseif (class == 3) then
		sound = "buttons/bell1.wav";
	elseif (class == 4) then
		sound = "buttons/button15.wav";
	end
	
	-- Play the sound to the local player.
	surface.PlaySound(sound);
	
	-- Add the notification using Garry's system.
	GAMEMODE:AddNotify(message, class, 10);
end);

-- Override the weapon pickup function.
function GM:HUDWeaponPickedUp(...) end;

-- Override the item pickup function.
function GM:HUDItemPickedUp(...) end;

-- Override the ammo pickup function.
function GM:HUDAmmoPickedUp(...) end;

-- Called when an entity is created.
function GM:OnEntityCreated(entity)	
	if (LocalPlayer() == entity) then
		for k, v in pairs(self.variableQueue) do LocalPlayer()[k] = v; end;
	end;
	
	-- Call the base class function.
	return self.BaseClass:OnEntityCreated(entity);
end;

timer.Create( "timePlayed", 1, 0, function()
	if LocalPlayer():GetNetworkedInt("evorp_PlayTime") then
		LocalPlayer():SetNetworkedInt("evorp_PlayTime", LocalPlayer():GetNetworkedInt("evorp_PlayTime") + 1)
	end
end)

-- Called when a player presses a bind.
function GM:PlayerBindPress(player, bind, press)
	if ( !self.playerInitialized and string.find(bind, "+jump") ) then
		RunConsoleCommand("retry");
	end;
	
	-- Check if they're trying to use a binded EvoRP command.
	if ( string.find(bind, "evorp ") or string.find(bind, "say /") ) then
		--if ( !player:GetNetworkedBool("evorp_Binds") and !player:IsAdmin() ) then
		--	player:ChatPrint("Only Donators can use binded commands!");
			
			-- Return true because they cannot use the command.
		--	return true;
		--end;
	end;
	
	-- Call the base class function.
	return self.BaseClass:PlayerBindPress(player, bind, press);
end;

-- Check if the local player is using the camera.
function GM:IsUsingCamera()
	if (IsValid( LocalPlayer():GetActiveWeapon() )
	and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera") then
		return true;
	else
		return false;
	end;
end;

-- Hook into when the server sends us a variable for the local player.
usermessage.Hook("evorp._LocalPlayerVariable", function(message)
	local class = message:ReadChar();
	local key = message:ReadString();
	
	-- Create the variable which we'll store our received variable in.
	local variable = nil;
	
	-- Check if we can get what class of variable it is.
	if (class == CLASS_STRING) then
		variable = message:ReadString();
	elseif (class == CLASS_LONG) then
		variable = message:ReadLong();
	elseif (class == CLASS_SHORT) then
		variable = message:ReadShort();
	elseif (class == CLASS_BOOL) then
		variable = message:ReadBool();
	elseif (class == CLASS_VECTOR) then
		variable = message:ReadVector();
	elseif (class == CLASS_ENTITY) then
		variable = message:ReadEntity();
	elseif (class == CLASS_ANGLE) then
		variable = message:ReadAngle();
	elseif (class == CLASS_CHAR) then
		variable = message:ReadChar();
	elseif (class == CLASS_FLOAT) then
		variable = message:ReadFloat();
	end;
	
	-- Check if the local player is a valid entity.
	if ( IsValid( LocalPlayer() ) ) then
		LocalPlayer()[key] = variable;
		
		-- Set the variable queue variable to nil so that we don't overwrite it later on.
		GAMEMODE.variableQueue[key] = nil;
	else
		GAMEMODE.variableQueue[key] = variable;
	end;
end);

function GM:PostDrawViewModel( vm, ply, weapon )
  	 if weapon.UseHands or (not weapon:IsScripted()) then
		local hands = LocalPlayer():GetHands()
		if IsValid(hands) then hands:DrawModel() end
 	end
end

-- A function to override whether a HUD element should draw.
function GM:HUDShouldDraw(name)
	if (!self.playerInitialized) then
		if (name != "CHudGMod") then return false; end;
	else
		if (name == "CHudHealth" or name == "CHudBattery" or name == "CHudSuitPower"
		or name == "CHudAmmo" or name == "CHudSecondaryAmmo") then
			return false;
		end;
		
		-- Return true if it's none of the others.
		return true;
	end;
	
	-- Call the base class function.
	return self.BaseClass:HUDShouldDraw(name);
end

-- A function to adjust the width of something by making it slightly more than the width of a text.
function GM:AdjustMaximumWidth(font, text, width, addition, extra)
	surface.SetFont(font);
	
	-- Get the width of the text.
	local textWidth = surface.GetTextSize( tostring( string.Replace(text, "&", "U") ) ) + (extra or 0);
	
	-- Check if the width of the text is greater than our current width.
	if (textWidth > width) then width = textWidth + (addition or 0); end;
	
	-- Return the new width.
	return width;
end;

-- A function to draw a bar with a maximum and a variable.
function GM:DrawBar(font, x, y, width, height, color, text, maximum, variable, bar)
	if(LocalPlayer()._NLRTimer) then
		if(LocalPlayer()._NLRTimer) then
			draw.WordBox( 8, ScrW() - 140, 16, "NLR Timer: "..(300 - LocalPlayer()._TimeSinceDeath), "EvoFont", Color(255,100,100,200), Color(255,255,255,255));
		end
	end

	draw.RoundedBox( 2, x, y, width, height, Color(0, 0, 0, 200) );
	draw.RoundedBox( 0, x + 2, y + 2, width - 4, height - 4, Color(25, 25, 25, 150) );
	draw.RoundedBox( 0, x + 2, y + 2, math.Clamp( ( (width - 4) / maximum ) * variable, 0, width - 4 ), height - 4, color );
	
	-- Set the font of the text to this one.
	surface.SetFont("EvoFont3");
	
	-- Adjust the x and y positions so that they don't screw up.
	x = math.floor( x + (width / 2) );
	y = math.floor(y + 1);
	
	-- Draw text on the bar.
	draw.DrawText(text, "EvoFont3", x + 1, y + 1, Color(0, 0, 0, 255), 1);
	draw.DrawText(text, "EvoFont3", x, y, Color(255, 255, 255, 255), 1);
	
	-- Check if a bar table was specified.
	if (bar) then bar.y = bar.y - (height + 4); end;
end;

-- Get the bouncing position of the screen's center.
function GM:GetScreenCenterBounce(bounce)
	return ScrW() / 2, (ScrH() / 2) + 32 + ( math.sin( CurTime() ) * (bounce or 8) );
end;

-- Called when the target ID should be drawn.
function GM:HUDDrawTargetID()
	if ( LocalPlayer():Alive() and !LocalPlayer():GetNetworkedBool("evorp_KnockedOut") ) then
		local trace = LocalPlayer():GetEyeTrace();
		
		-- Set the distance that text will be completely faded to the same as the talk radius.
		local fadeDistance = evorp.configuration["Talk Radius"];
		
		-- Check if we hit a valid entity.
		if ( IsValid(trace.Entity) ) then
			local class = trace.Entity:GetClass();
			
			-- Check if the entity is a player.
			if ( trace.Entity:IsPlayer() or IsValid( trace.Entity:GetNetworkedEntity("evorp_Player") ) ) then
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
				
				-- Get the x and y position.
				local x, y = self:GetScreenCenterBounce();
				
				local player = trace.Entity;
				if IsValid( trace.Entity:GetNetworkedEntity("evorp_Player") ) then player = trace.Entity:GetNetworkedEntity("evorp_Player") end

				if (player == LocalPlayer()) then return end
				-- Check if the player is alive.
				if ( player:Alive() and !player:GetNetworkedBool("FakeDeathing") ) then
					local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( player:GetPos() ) ) ), 0, 255);
					
					-- Get the x and y position.
					local x, y = self:GetScreenCenterBounce();
					
					-- Draw the player's name.
					--y = self:DrawInformation(player:Name(), "EvoFont", x, y, team.GetColor( player:Team() ), alpha);
					
					
					--if ((LocalPlayer():Team() == TEAM_HOSS or LocalPlayer():Team() == TEAM_SS or LocalPlayer():Team() == TEAM_OFFICER or LocalPlayer():Team() == TEAM_COMMANDER or LocalPlayer():Team()) and trace.Entity:GetNetworkedString("evorp_Warranted") == "search") then
					if (trace.Entity:GetNetworkedString("evorp_Warranted") == "search") then
						y = self:DrawInformation("This person has a search warrant!", "EvoFont", x, y, Color(214, 34, 34, 255), alpha);
					end;
				
					if ((LocalPlayer():Team() == TEAM_OFFICER or LocalPlayer():Team() == TEAM_COMMANDER) and trace.Entity:GetNetworkedString("evorp_Warranted") == "arrest") then
						y = self:DrawInformation("This person is wanted by the police!", "EvoFont", x, y, Color(214, 34, 34, 255), alpha);
					end;
					
					
					-- Check if the player is knockedout.
					if (player:GetNetworkedBool("evorp_KnockedOut")) then 
						y = self:DrawInformation("Unconscious", "EvoFont", x, y, Color(214, 34, 34, 255), alpha);
					end;
					
					-- Check if the player is hostaged.
					if (player:GetNetworkedBool("hostaged")) then 
						y = self:DrawInformation("Tied Up: USE + Left Click to untie.", "EvoFont", x, y, Color(255, 0, 0, 255), alpha);
					end;
					
					-- Check if the player is handcuffed.
					if (player:GetNetworkedBool("cuffed")) then 
						y = self:DrawInformation("Handcuffed: Lockpick to unhandcuff.", "EvoFont", x, y, Color(255, 0, 0, 255), alpha);
					end;
										
					-- NameIC.
					if (player:GetNetworkedString("evorp_NameIC") != "") then
						y = self:DrawInformation("Name: "..player:GetNetworkedString("evorp_NameIC"), "EvoFont", x, y, Color(255, 255, 255, 255), alpha);
					end;
					
					-- Description.
					if (player:GetNetworkedString("evorp_Description") != "") then
						y = self:DrawInformation("Description: "..player:GetNetworkedString("evorp_Description"), "EvoFont", x, y, Color(255, 255, 255, 255), alpha);
					end;

					-- Description.
					if (player:GetNetworkedString("evorp_Clan") != "") then
						y = self:DrawInformation("Guild: "..player:GetNetworkedString("evorp_Clan"), "EvoFont", x, y, Color(255, 255, 255, 255), alpha);
					end;
					
					if (player:GetNetworkedString("evorp_Job") != "") then
						y = self:DrawInformation("Job: "..player:GetNetworkedString("evorp_Job"), "EvoFont", x, y, Color(255, 255, 255, 255), alpha);
					end;
				elseif (player:GetNetworkedBool("FakeDeathing")) then
					y = self:DrawInformation(player:Name(), "EvoFont", x, y, team.GetColor( player:Team() ), alpha);
					if (player:GetNetworkedString("evorp_NameIC") != "") then
						y = self:DrawInformation("Name: "..player:GetNetworkedString("evorp_NameIC"), "EvoFont", x, y, Color(255, 255, 255, 255), alpha);
					end;
					y = self:DrawInformation("This person might still live if a paramedic reaches here in time!", "EvoFont", x, y, Color(214, 34, 34, 255), alpha);
				end
			elseif (trace.Entity:GetNetworkedBool("iDoor")) then
				local name = trace.Entity:GetNetworkedString("evorp_Name");
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
					
				-- Get the x and y position.
				local x, y = self:GetScreenCenterBounce();
				y = GAMEMODE:DrawInformation("Dynamic Door (STool)", "EvoFont", x, y, Color(150, 200, 20, 255), alpha);
				y = GAMEMODE:DrawInformation(name, "EvoFont", x, y, Color(255, 194, 14, 255), alpha);
			elseif (string.find( class, "prop_vehicle_jeep" )) then
				if (LocalPlayer():InVehicle()) then return end
				-- Calculate the alpha from the distance.
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
					
				-- Get the x and y position.
				local x, y = self:GetScreenCenterBounce();
					
				-- Draw the information and get the new y position.
				y = GAMEMODE:DrawInformation(trace.Entity:GetNetworkedString("evorp_Name"), "EvoFont", x, y, Color(125, 255, 50, 255), alpha);

				local eph = math.abs(math.floor(trace.Entity:GetVelocity():Length()/ 25.33));

				if ( trace.Entity:GetNetworkedBool("locked") ) then
					y = GAMEMODE:DrawInformation("Locked", "EvoFont", x, y, Color(255, 194, 14, 255), alpha);
				else
					y = GAMEMODE:DrawInformation("Unlocked", "EvoFont", x, y, Color(255, 194, 14, 255), alpha);
				end

				if (trace.Entity:GetNetworkedBool("evStolen")) then
					y = GAMEMODE:DrawInformation("This car has been reported stolen!", "EvoFont", x, y, Color(214, 34, 34, 255), alpha);
				end
			elseif (class == "evorp_item") then
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
				
				-- Get the x and y position.
				local x, y = self:GetScreenCenterBounce();
				
				-- Draw the information and get the new y position.

				y = GAMEMODE:DrawInformation(trace.Entity:GetNetworkedString("evorp_Name"), "EvoFont", x, y, Color(125, 255, 50, 255), alpha);
				y = GAMEMODE:DrawInformation("Size: "..trace.Entity:GetNetworkedInt("evorp_Size"), "EvoFont", x, y, Color(255, 255, 255, 255), alpha);
				y = GAMEMODE:DrawInformation("Amount: "..trace.Entity:GetNetworkedInt("evorp_iAmount"), "EvoFont", x, y, Color(255, 255, 255, 255), alpha);
			elseif (class == "evorp_saleitem") then
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
				-- Get the x and y position.
				local x, y = self:GetScreenCenterBounce();
				if (trace.Entity:GetNetworkedEntity("saleitem_Player") == LocalPlayer()) then
					if (trace.Entity:GetNetworkedInt("evorp_Price") > 0) then
						y = GAMEMODE:DrawInformation("You are selling this item for $"..trace.Entity:GetNetworkedInt("evorp_Price")..".", "EvoFont", x, y, Color(255, 0, 0, 255), alpha);
					else

						y = GAMEMODE:DrawInformation("Aim at the item and use /setprice <price> to start selling at desired price.", "EvoFont", x, y, Color(255, 0, 0, 255), alpha);
					end
					y = GAMEMODE:DrawInformation("Double Tap 'E' to remove sale.", "EvoFont", x, y, Color(150, 200, 20, 255), alpha);
				else
					y = GAMEMODE:DrawInformation("FOR SALE: "..trace.Entity:GetNetworkedString("evorp_Name"), "EvoFont", x, y, Color(255, 0, 0, 255), alpha);
					if (trace.Entity:GetNetworkedInt("evorp_Price") == 0) then
						y = GAMEMODE:DrawInformation("Unpriced", "EvoFont", x, y, Color(255, 255, 255, 255), alpha);
					else
						y = GAMEMODE:DrawInformation("Price: $"..trace.Entity:GetNetworkedInt("evorp_Price"), "EvoFont", x, y, Color(255, 255, 255, 255), alpha);
						y = GAMEMODE:DrawInformation("Double Tap 'E' to buy.", "EvoFont", x, y, Color(150, 200, 20, 255), alpha);
					end
				end
			elseif (class == "activated_ammokit") then
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
				
				-- Get the x and y position.
				local x, y = self:GetScreenCenterBounce();
				
				-- Draw the information and get the new y position.
				y = GAMEMODE:DrawInformation("Ammunition Kit", "EvoFont", x, y, Color(125, 255, 50, 255), alpha);
				y = GAMEMODE:DrawInformation("Charge: "..trace.Entity:GetNetworkedInt("charge"), "EvoFont", x, y, Color(255, 255, 255, 255), alpha);
			elseif (class == "activated_medkit") then
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
				-- Get the x and y position.
				local x, y = self:GetScreenCenterBounce();
				
				-- Draw the information and get the new y position.
				y = GAMEMODE:DrawInformation("Health Kit", "EvoFont", x, y, Color(125, 255, 50, 255), alpha);
				y = GAMEMODE:DrawInformation("Charge: "..trace.Entity:GetNetworkedInt("charge"), "EvoFont", x, y, Color(255, 255, 255, 255), alpha);
			elseif ( evorp.configuration["Contraband"][class] ) then
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
				
				-- Get the x position, y position and contraband table.
				local x, y = self:GetScreenCenterBounce();
				local contraband = evorp.configuration["Contraband"][class];
				
				-- Draw the information and get the new y position.
				y = GAMEMODE:DrawInformation(contraband.name, "EvoFont", x, y, Color(125, 255, 50, 255), alpha);
				y = GAMEMODE:DrawInformation("Energy: "..trace.Entity:GetNetworkedInt("evorp_Energy").."/"..contraband.energy, "EvoFont", x, y, Color(255, 255, 255, 255), alpha);
				y = GAMEMODE:DrawInformation("Money: $"..trace.Entity:GetNetworkedInt("evorp_CMoney"), "EvoFont", x, y, Color(255, 255, 255, 255), alpha);
			elseif ( string.lower( class ) == "evorp_money" ) then
				local amount = trace.Entity:GetNetworkedInt("evorp_Amount");
				
				-- Calculate the alpha from the distance.
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
				
				-- Get the x and y position.
				local x, y = self:GetScreenCenterBounce();
				
				-- Draw the information and get the new y position.
				y = GAMEMODE:DrawInformation("Money", "EvoFont", x, y, Color(125, 255, 50, 255), alpha);
				y = GAMEMODE:DrawInformation("$"..amount, "EvoFont", x, y, Color(255, 255, 255, 255), alpha);
			elseif ( class == "evorp_breach" ) then
				local health = trace.Entity:GetNetworkedInt("evorp_Health");
				
				-- Calculate the alpha from the distance.
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
				
				-- Get the x and y position.
				local x, y = self:GetScreenCenterBounce();
				
				-- Draw the information and get the new y position.
				y = GAMEMODE:DrawInformation("Breach", "EvoFont", x, y, Color(214, 34, 34, 255), alpha);
				y = GAMEMODE:DrawInformation("Health: "..health.."/100", "EvoFont", x, y, Color(255, 255, 255, 255), alpha);
			elseif ( class == "evorp_note" ) then
				local text = "";
				
				-- Loop through 1 to 10.
				for i = 1, 10 do
					local line = trace.Entity:GetNetworkedString("evorp_Text_"..i);
					
					-- Check if this line exists.
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
				
				-- Calculate the alpha from the distance.
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
				
				-- Get the x and y position.
				local x, y = self:GetScreenCenterBounce();
				
				-- Draw the information and get the new y position.
				y = GAMEMODE:DrawInformation("Note", "EvoFont", x, y, Color(125, 255, 50, 255), alpha);
				
				-- Loop through our text.
				for k, v in pairs(wrapped) do
					y = GAMEMODE:DrawInformation(v, "EvoFont", x, y, Color(255, 255, 255, 255), alpha);
				end;
			end;
		end;
	end;
end;

-- Called when screen space effects should be rendered.
function GM:RenderScreenspaceEffects()
	local modify = {};
	local color = 0.8;
	
	-- Check if the player is low on health.
	if (LocalPlayer():Health() < 50 and !LocalPlayer()._HideHealthEffects) then
		if ( LocalPlayer():Alive() ) then
			color = math.Clamp(color - ( ( 50 - LocalPlayer():Health() ) * 0.025 ), 0, color);
		else
			color = 0;
		end;
		
		-- Draw the motion blur.
		DrawMotionBlur(math.Clamp(1 - ( ( 50 - LocalPlayer():Health() ) * 0.025 ), 0.1, 1), 1, 0);
	end;
	
	-- Set some color modify settings.
	modify["$pp_colour_addr"] = 0;
	modify["$pp_colour_addg"] = 0;
	modify["$pp_colour_addb"] = 0;
	modify["$pp_colour_brightness"] = 0;
	modify["$pp_colour_contrast"] = 1;
	modify["$pp_colour_colour"] = color;
	modify["$pp_colour_mulr"] = 0;
	modify["$pp_colour_mulg"] = 0;
	modify["$pp_colour_mulb"] = 0;
	
	-- Draw the modified color.
	DrawColorModify(modify);
end;

-- Called when the scoreboard should be drawn.
function GM:HUDDrawScoreBoard()
	--self.BaseClass:HUDDrawScoreBoard(player);
	
	-- Check if the player hasn't initialized yet.
	if (!self.playerInitialized) then
		draw.RoundedBox( 2, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255) );
		
		-- Set the font of the text to Chat Font.
		surface.SetFont("EvoFont");
		
		-- Get the size of the loading text.
		local width, height = surface.GetTextSize("Loading!");
		
		-- Get the x and y position.
		local x, y = self:GetScreenCenterBounce();
		
		-- Draw a rounded box for the loading text to go on.
		draw.RoundedBox( 2, (ScrW() / 2) - (width / 2) - 8, (ScrH() / 2) - 8, width + 16, 30, Color(25, 25, 25, 255) );
		
		-- Draw the loading text in the middle of the screen.
		draw.DrawText("Loading!", "EvoFont", ScrW() / 2, ScrH() / 2, Color(255, 255, 255, 255), 1, 1);
		
		-- Let them know how to rejoin if they are stuck.
		draw.DrawText("Press 'Jump' to rejoin if you are stuck on this screen!", "EvoFont", ScrW() / 2, ScrH() / 2 + 32, Color(255, 50, 25, 255), 1, 1);
	end;
end;

-- Draw Information.
function GM:DrawInformation(text, font, x, y, color, alpha, left, callback, shadow)
	surface.SetFont(font);
	
	-- Get the width and height of the text.
	local width, height = surface.GetTextSize(text);
	
	-- Check if we shouldn't left align it, if we have a callback, and if we should draw a shadow.
	if (!left) then x = x - (width / 2); end;
	if (callback) then x, y = callback(x, y, width, height); end;
	if (shadow) then draw.DrawText(text, font, x + 1, y + 1, Color(0, 0, 0, alpha or color.a)); end;
	
	-- Draw the text on the player.
	draw.DrawText(text, font, x, y, Color(color.r, color.g, color.b, alpha or color.a));
	
	-- Return the new y position.
	return y + height + 8;
end;

-- Draw the player's information.
function GM:DrawPlayerInformation()
	local width = 0;
	local height = 0;
	
	-- Create a table to store the text.
	local text = {};
	local information = {};

	-- Insert the player's information into the text table.
	table.insert( text, {"Steam ID: "..LocalPlayer():SteamID(), "icon16/application_form.png"} );
	table.insert( text, {"Name: "..LocalPlayer():GetNetworkedString("evorp_NameIC", ""), "icon16/user.png"} );
	table.insert( text, {"Description: "..LocalPlayer():GetNetworkedString("evorp_Description"), "icon16/table_edit.png"} );
	table.insert( text, {"Guild: "..LocalPlayer():GetNetworkedString("evorp_Clan"), "icon16/group.png"} );
	table.insert( text, {"Gender: "..(LocalPlayer()._Gender or "Male"), "icon16/heart.png"} );
	table.insert( text, {"Job: "..LocalPlayer():GetNetworkedString("evorp_Job"), "icon16/brick.png"} );
	if (evorp.team.query(LocalPlayer():Team(), "radio", "") != "R_GOV") then
		table.insert( text, {"Salary: $"..(LocalPlayer()._Salary or 0).." - (TAX: $25)", "icon16/money_dollar.png"} );
	else
		table.insert( text, {"Salary: $"..(LocalPlayer()._Salary or 0).." + Tax Split", "icon16/money_dollar.png"} );
	end
	table.insert( text, {"Money: $"..(LocalPlayer()._Money or 0), "icon16/coins.png"} );
	table.insert( text, {"Donator Credits: "..(LocalPlayer():GetNetworkedInt("evorp_DCredits")), "icon16/star.png"} );
	--table.insert( text, {"Experience Points: "..(LocalPlayer():GetNetworkedInt("evorp_PointsRP")), "icon16/anchor.png"} );
	
	
	local s = LocalPlayer():GetNetworkedInt("evorp_PlayTime"); --How many total seconds do we have 
	local totalm = math.floor( s / 60 ); --How many total minutes do we have
	local h = math.floor( totalm / 60 ); --How many total hours do we have
	local m = totalm - h * 60; --Minutes left
	s = s - totalm * 60; --Seconds left
	
	table.insert( text, {""..h.." hours, "..m.." minutes, "..s.." seconds", "icon16/time.png"} );
	
	-- Loop through each of the text and adjust the width.
	for k, v in pairs(text) do
		if (string.Explode( ":", v[1] )[2] != " ") then
			if ( v[2] ) then
				width = self:AdjustMaximumWidth("EvoFont", v[1], width, nil, 24);
			else
				width = self:AdjustMaximumWidth("EvoFont", v[1], width);
			end;
			
			-- Insert this text into the information table.
			table.insert(information, v);
		end;
	end;
	
	-- Add 16 to the width and set the height of the box.
	width = width + 16;
	height = (18 * #information) + 14;
	
	-- The position of the information box.
	local x = 8;
	local y = ScrH() - height - 8;
	
	-- Draw a rounded box to put the information text onto.
	draw.RoundedBox( 2, x, y, width, height, Color(0, 0, 0, 200) );
	
	-- Increase the x and y position by 8.
	x = x + 8;
	y = y + 8;
	
	-- Draw the information on the box.
	for k, v in pairs(information) do
		if ( v[2] ) then
			self:DrawInformation(v[1], "EvoFont", x + 24, y, Color(255, 255, 255, 255), 255, true);
			
			-- Draw the icon that respresents the text.
			surface.SetMaterial( Material( v[2] ) );
			surface.SetDrawColor(255, 255, 255, 255);
			surface.DrawTexturedRect(x, y - 1, 16, 16);
		else
			self:DrawInformation(v[1], "EvoFont", x, y, Color(255, 255, 255, 255), 255, true);
		end;
		
		
		-- Increase the y position.
		y = y + 18;
	end;
	
	-- Return the width and height of the box.
	return width, height;
end;

-- Draw the health bar.
function GM:DrawHealthBar(bar)
	local health = math.Clamp(LocalPlayer():Health(), 0, 100);
	
	-- Draw the health and ammo bars.
	self:DrawBar("Default", bar.x, bar.y, bar.width, bar.height, Color(255, 50, 50, 200), "Health: "..health, 100, health, bar);
end;

function GM:DrawAmmoBar(bar)
	local weapon = LocalPlayer():GetActiveWeapon();
	
	-- Check if the weapon is valid.
	if not self.ammoCount then self.ammoCount = {} end
	if ( IsValid(weapon) ) then
		if ( !self.ammoCount[ weapon:GetClass() ] ) then
			self.ammoCount[ weapon:GetClass() ] = weapon:Clip1();
		end;
		
		-- Check if the weapon's first clip is bigger than the amount we have stored for clip one.
		if ( weapon:Clip1() > self.ammoCount[ weapon:GetClass() ] ) then
			self.ammoCount[ weapon:GetClass() ] = weapon:Clip1();
		end;
		
		-- Get the amount of ammo the weapon has in it's first clip.
		local clipOne = weapon:Clip1();
		local clipMaximum = self.ammoCount[ weapon:GetClass() ];
		local clipAmount = LocalPlayer():GetAmmoCount( weapon:GetPrimaryAmmoType() );
		
		-- Check if the maximum clip if above 0.
		if (clipMaximum > 0) then
			self:DrawBar("Default", bar.x, bar.y, bar.width, bar.height, Color(100, 100, 255, 200), "Ammo: "..clipOne.." ["..clipAmount.."]", clipMaximum, clipOne, bar);
		end;
	end;
end;

-- Called when the bottom bars should be drawn.
function GM:DrawBottomBars(bar) end;

-- Called when the top text should be drawn.
function GM:DrawTopText(text) end;

-- Called every time the HUD should be painted.
function GM:HUDPaint()
	if not (self.playerInitialized) then return end
	if ( !self:IsUsingCamera() ) then

		--local x = "Location: ";
		--if(LocalPlayer()._LastLocation) then x = x..LocalPlayer()._LastLocation end

		--self:DrawInformation(x , "EvoFont", ScrW(), ScrH(), Color(255, 50, 25, 255), 255, true, function(x, y, width, height)
		--	return x - width - 22, y - height - 22;
		--end);

		self:DrawInformation(evorp.configuration["Website URL"], "EvoFont", ScrW(), ScrH(), Color(255, 255, 255, 255), 255, true, function(x, y, width, height)
			return x - width - 8, y - height - 8;
		end);
		
		-- Get the size of the information box.
		local width, height = self:DrawPlayerInformation();
		
		-- A table to store the bar and text information.
		local bar = {x = width + 16, y = ScrH() - 24, width = 144, height = 16};
		local text = {x = ScrW(), y = 8};
		
		-- Draw the player's health and ammo bars.
		self:DrawHealthBar(bar);
		self:DrawAmmoBar(bar);
		
		-- Call a hook to let plugins know that we're now drawing bars and text.
		hook.Call("DrawBottomBars", GAMEMODE, bar);
		hook.Call("DrawTopText", GAMEMODE, text);
		
		if (LocalPlayer():InVehicle() and LocalPlayer():GetVehicle():GetClass() == "prop_vehicle_jeep") then
			local fuel = LocalPlayer():GetVehicle():GetNetworkedInt("fuel");
			self:DrawBar("Default", bar.x, bar.y, bar.width, bar.height, Color(109, 130, 247, 200), "Fuel: "..fuel, 100, fuel, bar);
		end

		-- Set the position of the chat box.
		evorp.chatBox.position = {x = 8, y = ScrH() - (height + 40)};
		
		-- Get the player's next spawn time.
		local _NextSpawnTime = LocalPlayer()._NextSpawnTime or 0;

		if (LocalPlayer():GetNetworkedBool("FakeDeathing"))then
			local secondsleft = math.floor(LocalPlayer():GetNetworkedInt("FakeDeathTimer") - CurTime())
			local sptime = evorp.configuration["Spawn Time"];
			if (LocalPlayer():GetNetworkedBool("evorp_Donator")) then sptime = evorp.configuration["Spawn Time"] / 2; end
			local sleft =math.floor((LocalPlayer():GetNetworkedInt("FakeDeathTimer") - 120 + sptime) - CurTime());
			local text = "A paramedic can revive you in the next "..secondsleft.." seconds or you can wait "..sleft.." seconds and click to give up on life."
			if (sleft < 1) then text = "A paramedic can revive you in the next "..secondsleft.." seconds or you can click to give up on life." end
			self:DrawInformation(text, "EvoFont", ScrW() / 2, (ScrH() / 2) + 16, Color(255, 255, 255, 255), 255);
		else
		
			-- Check if the next spawn time is greater than the current time.
			if ( !LocalPlayer():Alive() and _NextSpawnTime > CurTime()) then
				local seconds = math.floor( _NextSpawnTime - CurTime() );
				
				-- Check if the amount of seconds is greater than 0.
				if (seconds > 0) then
					self:DrawInformation("You must wait "..seconds.." second(s) to spawn.", "EvoFont", ScrW() / 2, (ScrH() / 2) + 16, Color(255, 255, 255, 255), 255);
				end;
			elseif ( LocalPlayer():GetNetworkedBool("evorp_KnockedOut") ) then
				local _BecomeConsciousTime = LocalPlayer()._BecomeConsciousTime or 0;
				
				-- Check if the unknock out time is greater than the current time.
				if ( _BecomeConsciousTime > CurTime() ) then
					local seconds = math.floor( _BecomeConsciousTime - CurTime() );
					
					-- Check if the amount of seconds is greater than 0.
					if (seconds > 0) then
						self:DrawInformation("You will become conscious in "..seconds.." second(s).", "EvoFont", ScrW() / 2, (ScrH() / 2) + 16, Color(255, 255, 255, 255), 255);
					end;
				end;
			end;
		end
		-- Get whether the player is stuck in the world.
		local stuckInWorld = LocalPlayer()._StuckInWorld;
		
		-- Check whether the player is stuck in the world.
		if (stuckInWorld) then
			draw.DrawText("You are stuck! Press 'Jump' to get unstuck.", "EvoFont", ScrW() / 2, (ScrH() / 2) - 16, Color(255, 50, 25, 255), 1, 1);
		end;
		
		-- Loop through every player.
		for k, v in pairs( g_Player.GetAll() ) do hook.Call("PlayerHUDPaint", GAMEMODE, v); end;
		
		-- Call the base class function.
		self.BaseClass:HUDPaint();
	end;
end;

-- Called to check if a player can use voice.
function GM:PlayerCanVoice(player)
	if ( player:Alive()	and player:GetPos():Distance( LocalPlayer():GetPos() ) <= evorp.configuration["Talk Radius"]) then
		return true;
	else
		return false;
	end;
end;

-- Called every frame.
function GM:Think()
	if ( evorp.configuration["Local Voice"] ) then
		for k, v in pairs( player.GetAll() ) do
			if ( hook.Call("PlayerCanVoice", GAMEMODE, v) ) then
				if ( v:IsMuted() ) then v:SetMuted(); end;
			else
				if ( !v:IsMuted() ) then v:SetMuted(); end;
			end;
		end;
	end;
	Control()
	-- Call the base class function.
	return self.BaseClass:Think();
end;

-- Called when a player begins typing.
function GM:StartChat(team) return true; end;

-- Called when a player says something or a message is received from the server.
function GM:ChatText(index, name, text, filter)
	if ( filter == "none" or filter == "joinleave" or (filter == "chat" and name == "Console") ) then
		evorp.chatBox.chatText(index, name, text, filter);
	end;
	
	-- Return true because we handle this our own way.
	return true;
end;

-- Hook into when the player has initialized.
usermessage.Hook("evorp.player.initialized", function() GAMEMODE.playerInitialized = true; end);

function DrawDeathMessage() 
	-- Frame
	local LDFrame = vgui.Create( "DFrame" )  
	LDFrame:SetPos( ScrW() / 2 - 250,ScrH() / 2 )  
	LDFrame:SetSize( 518, 200 )  
	LDFrame:SetTitle( "New Life Rule - NLR" )  
	LDFrame:SetVisible( true )  
	LDFrame:SetDraggable( true )  
	LDFrame:ShowCloseButton( false ) 
	LDFrame:SetBackgroundBlur( true )  
	LDFrame:MakePopup() 
	  
	local PaintPanel = vgui.Create( "DPanel", LDFrame )  
	
	-- Black box
	PaintPanel:SetPos( 5, 25 )  
	PaintPanel:SetSize( 508, 170 )  
	PaintPanel.Paint = function()      
	surface.SetDrawColor( 50, 50, 50, 255 )      
	surface.DrawRect( 0, 0, PaintPanel:GetWide(), PaintPanel:GetTall() ) 
	end 

	-- Text
	local Dlabel = vgui.Create("DLabel", PaintPanel); 
		Dlabel:SetText("Your old life ended. You now only remember your friends, job and home. You do not\nremember where you died or how you died...\n\nThese rules now apply:\n1. Do not return to the place you died for the next 5 minutes.\n2. Do not kill the player that killed you on the basis of revenge.\n"); 
		Dlabel:SetSize(490, 120); 
		Dlabel:SetPos(10, 10); 
		
	-- Buttons
	timer.Simple(5, function()
	local OKButton = vgui.Create("DButton", PaintPanel); 
		OKButton:SetText("Agree"); 
		OKButton:SetSize(100, 30); 
		OKButton:SetPos(10, 130); 
		OKButton.DoClick = function() 
		LDFrame:Close() 
		LocalPlayer()._TimeSinceDeath = 0;
		LocalPlayer()._NLRTimer = true;
		timer.Start("NLR");
		end
	local NOButton = vgui.Create("DButton", PaintPanel); 
		NOButton:SetText("Disagree"); 
		NOButton:SetSize(100, 30); 
		NOButton:SetPos(140, 130); 
		NOButton.DoClick = function() 
		RunConsoleCommand("disconnect")
		end
	end)
end 

concommand.Add("DrawDeathMsg", DrawDeathMessage)

timer.Create( "NLR", 1, 0, function()
	if not (LocalPlayer()._NLRTimer) then
		timer.Stop("NLR");
	else
		LocalPlayer()._TimeSinceDeath = LocalPlayer()._TimeSinceDeath + 1;
		if(LocalPlayer()._TimeSinceDeath > 299) then
			LocalPlayer()._NLRTimer = false;
		end
	end
end)

function OnContextMenuOpen()
	return true;
end
hook.Add( "ContextMenuOpen", "OnContextMenuOpen", OnContextMenuOpen )

function Control()
	if not (LocalPlayer()._NextControl) then LocalPlayer()._NextControl = 0; end
	if not (LocalPlayer()._NextControl <= CurTime()) then return end
	if (input.IsKeyDown(KEY_F4) and !evorp.chatBox.derma.panel:IsVisible()) then
		LocalPlayer()._NextControl = CurTime() + .2;
		RunConsoleCommand("ExQuickToggle");
	end
	if (input.IsKeyDown(KEY_LCONTROL)) and (input.IsKeyDown(KEY_TAB)) then

		LocalPlayer()._NextControl = CurTime() + .2;
		TP:RegQuickMenu();
		--[[
		if (ctp:IsEnabled()) then
			ctp:Disable();
		else
			if (LocalPlayer():InVehicle()) then
				ctp:LoadCVarPreset("Vehicle")
			else
				ctp:LoadCVarPreset("Third Person")
			end

			ctp:Enable();
		end]]
	end
	if (LocalPlayer():InVehicle() and !evorp.chatBox.derma.panel:IsVisible()) then
		if (input.IsKeyDown(KEY_C)) and (input.IsKeyDown(KEY_LCONTROL))  then
			LocalPlayer()._NextControl = CurTime() + .2;
			RunConsoleCommand("ToggleCruise")
		elseif (input.IsKeyDown(KEY_H)) and (input.IsKeyDown(KEY_LCONTROL))  then
			LocalPlayer()._NextControl = CurTime() + .2;
			RunConsoleCommand("HonkSiren")
		elseif (input.IsKeyDown(KEY_H)) then
			LocalPlayer()._NextControl = CurTime() + .2;
			RunConsoleCommand("HonkHorn")
		elseif (input.IsKeyDown(KEY_LSHIFT)) then
			LocalPlayer()._NextControl = CurTime() + .2;
			RunConsoleCommand("hydr")
		end
	end
end
	
--[[
timer.Create("LocationUpdater", 1, 0, function() 
	if not (IsValid(LocalPlayer())) then return end
	if not (LocalPlayer()._LastLocation) then LocalPlayer()._LastLocation = "UNKNOWN" end
	if string.lower(game.GetMap()) == "rp_evocity_v33x" then
		if (LocalPlayer():GetPos():Distance(Vector( -7006, -8928, 72 )) < 128) then
			LocalPlayer()._LastLocation = "Nexus";
		elseif (LocalPlayer():GetPos():Distance(Vector( -7351, -9582, 460 )) < 128) then
			LocalPlayer()._LastLocation = "Nexus First Floor";
		elseif (LocalPlayer():GetPos():Distance(Vector( -7349, -9574, 1735 )) < 128) then
			LocalPlayer()._LastLocation = "Nexus Second Floor";
		elseif (LocalPlayer():GetPos():Distance(Vector( -7337, -9592, 3791 )) < 128) then
			LocalPlayer()._LastLocation = "Nexus Third Floor";
		elseif (LocalPlayer():GetPos():Distance(Vector( -7558, -6300, 72 )) < 128) then
			LocalPlayer()._LastLocation = "AM/PM";
		end
	end
end);
]]

ScoreBoard = nil

timer.Simple( 1.5, function()
	
	function GAMEMODE:CreateScoreboard()
	
		if ( ScoreBoard ) then
		
			ScoreBoard:Remove()
			ScoreBoard = nil
			
		end
		
		ScoreBoard = vgui.Create( "ScoreBoard" )
		
		return true

	end
	
	function GAMEMODE:ScoreboardShow()
	
		if not ScoreBoard then
			self:CreateScoreboard()
		end

		GAMEMODE.ShowScoreboard = true
		gui.EnableScreenClicker( true )

		ScoreBoard:SetVisible( true )
		ScoreBoard:UpdateScoreboard( true )
		
		return true

	end
	
	function GAMEMODE:ScoreboardHide()
	
		GAMEMODE.ShowScoreboard = false
		gui.EnableScreenClicker( false )

		ScoreBoard:SetVisible( false )
		
		return true
		
	end
	
end )

local tblFonts = { }

tblFonts["HUDNumber5"] = {
	font = "Museo Sans 500",
	size = 45,
	weight = 900,
}
 
tblFonts["DefaultBold"] = {
    font = "Tahoma",
    size = 13,
    weight = 1000,
}


for k,v in SortedPairs( tblFonts ) do
	surface.CreateFont( k, tblFonts[k] );
end

TP = {}

TP.config = TP.config or {}
TP.config.distance = TP.config.distance or 0
TP.config.sensitive = TP.config.sensitive or .025
TP.config.changedir = TP.config.changedir or false
TP.config.changedir = TP.config.classic or false
TP.config.maxdistance = 100


local mc = math.Clamp	
local playerMeta = FindMetaTable("Player")
local GetVelocity = FindMetaTable("Entity").GetVelocity
local Length2D = FindMetaTable("Vector").Length2D

local function ffr()
	return mc(FrameTime(), 1/60,1)
end

local nobob = {
	"weapon_physgun",
	"gmod_tool",
}

function playerMeta:CanOverrideView()
	return ( 
		self:IsValid() && // If player is available.
		self:Alive() && // If player is alive.
		!self:GetNetworkedBool("evorp_KnockedOut") && // If player is not ragdolled/falloverd
		TP.config.distance > 0 // If player enabled the thirdperson.
	)
end

function TP:DistPerc()
	return mc(self.config.distance / self.config.maxdistance, 0, 1)
end


function TP:RegQuickMenu()
	if (TP.config.distance != 100) then
		TP.config.distance = 100;
	else
		TP.config.distance = 0;
	end
	--[[
		local DPanel = vgui.Create( "DFrame" )
		DPanel:SetPos( 10, 30 ) -- Set the position of the panel
		DPanel:SetSize( 200, 200 ) -- Set the size of the panel
		DPanel:SetVisible( true )
		DPanel:SetDraggable( true )
		DPanel:ShowCloseButton( true )
		TP:CreateQuickMenu(DPanel)
		gui.EnableScreenClicker(true)
		]]
end

hook.Add("HUDShouldDraw", "HideOldChatBox", function( name )
	if name == "CHudChat" then return false end
end)


function GM:ShouldDrawLocalPlayer()
	if ( LocalPlayer():Alive()) then
		if ( LocalPlayer():GetNetworkedBool("evorp_KnockedOut") ) then
			return true
		end

		if TP.config.distance > 0 then
			return true
		end
	end
	return false
end

local class
local camang = Angle(0, 0, 0)
local addpos = Vector(0, 0, 0)
local finaladdpos = addpos
local finalang = camang
local camx, camy = 0, 0

local lastaim = Angle(0, 0, 0)
if LocalPlayer() and LocalPlayer():IsValid() and LocalPlayer().character then
	lastaim = LocalPlayer():EyeAngles()
	camang = LocalPlayer():EyeAngles()
end

local movetrig = false


function GM:CreateMove( cmd )
	local ply = LocalPlayer()
	local vel = math.floor( Length2D(GetVelocity(ply)) )

	if ply:CanOverrideView() and !TP.config.classic then
		if (vel < 5) then
			cmd:SetViewAngles(lastaim)
			movetrig = true
		else
			if movetrig then
				cmd:SetViewAngles(camang)
				movetrig = false
			end
			lastaim = ply:EyeAngles()
		end
	end
end

function GM:InputMouseApply( cmd, x, y, ang ) // :C
	local ply = LocalPlayer()
	local vel = math.floor(Length2D(GetVelocity(ply)))

	camx = x * -TP.config.sensitive
	camy = y * TP.config.sensitive

	if (vel < 5 and !TP.config.classic) then
		camang = camang + Angle(camy, camx, 0)
		camang.p = mc(camang.p, -90, 90)
		addpos = camang:Up()*math.abs(camang.p*.1)
	end
end

local nodesync = false
function GM:CalcView( ply, pos, ang, fov )
	local rt = RealTime()
	local ft = FrameTime()
	local vel = math.floor( Length2D(GetVelocity(ply)) )
	local runspeed = ply:GetRunSpeed()
	local walkspeed = ply:GetWalkSpeed()
	local wep = ply:GetActiveWeapon()
	if wep and wep:IsValid() then
		class = ply:GetActiveWeapon():GetClass()
	else
		class = ""
	end
	local v = {}
	if 
		ply:CanOverrideView()
	then

		if !(vel < 5) or TP.config.classic then
			camang = ang
			addpos = ang:Up()*mc(TP:DistPerc()*TP.config.distance*.3, 10, TP.config.maxdistance)
			--[[
			if ply:WepRaised() then
				local difac = 1
				if TP.config.changedir then
					difac = -1
				end

				addpos = addpos + difac * ang:Right()*mc(TP:DistPerc()*TP.config.distance*.8, 20, TP.config.maxdistance)
			end
			]]
		end

		local data = {}
			data.start = pos
			data.endpos = data.start - finalang:Forward() * TP.config.distance + finaladdpos
			data.filter = ply
		local trace = util.TraceLine(data)

		// The reson of Clamping Frametime to 1/60(60 fps): Because Lerp getting slow as fuck when youre having too good fps.
		// Also Lerp gets freak out when player is getting really low fps. 
		// Upgrade your fucking computer then.
		if FrameTime() < 1/10 then
			finalang = LerpAngle(ffr()*15, finalang, camang)
			finaladdpos = LerpVector(ffr()*15, finaladdpos, addpos)
		else
			finalang = camang
			finaladdpos = addpos
		end

		v.angles = finalang
		v.angles.r = 0
		v.origin = trace.HitPos + trace.HitNormal * 10
		v.fov = fov
		
		return self.BaseClass:CalcView(ply, v.origin, v.angles, v.fov)
		
	end
	
end