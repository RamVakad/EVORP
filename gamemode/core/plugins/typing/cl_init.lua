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
evorp.hook.add("PlayerHUDPaint", function(player)
	if ( LocalPlayer():Alive() and !LocalPlayer():GetNetworkedBool("evorp_KnockedOut") ) then
		local fadeDistance = evorp.configuration["Talk Radius"];
		
		-- Check if the player is alive.
		if ( player:Alive() ) then
			if ( player != LocalPlayer() ) then
				if (!player._KnockedOut and !player.Ghosted) then
					if (player:GetNetworkedBool("evorp_FMenu")) then
						local alpha = math.Clamp(255 - ( (255 / fadeDistance) * player:GetShootPos():Distance( LocalPlayer():GetShootPos() ) ), 0, 255);
						-- Define the x and y position.
						local x = player:GetShootPos():ToScreen().x;
						local y = player:GetShootPos():ToScreen().y - 64;
						
						-- Check if the position is visible.
						if (player:GetShootPos():ToScreen().visible) then
							y = y + (32 * (LocalPlayer():GetShootPos():Distance( player:GetShootPos() ) / fadeDistance)) * 0.5;
							
							-- Draw the information and get the new y position.
							draw.SimpleTextOutlined( "In Menu", "EvoFont", x, y + math.sin( CurTime() ) * 4, Color(255, 255, 255, alpha), 1, 0, 1, Color( 0, 0, 0,alpha ) )
							--y = GAMEMODE:DrawInformation("Typing", "EvoFont", x, y + math.sin( CurTime() ) * 8, Color(255, 255, 255, 255), alpha)
						end;
					elseif ( player:GetNetworkedBool("evorp_Typing") ) then
						--[[
						local textColor = Color( 232, 232, 232, 255 )
						local outlineCol = Color( 0, 0, 0, 255 )
						surface.SetFont( "ExGenericText14" )
						local w = math.max( surface.GetTextSize( player:Nick() ) + 20, surface.GetTextSize( player:GetNWString( "title" ) ) + 20 )
						local h = 20
						
						local drawPos = ( player:GetPos() + Vector( 0, 0, player:OBBMaxs().z + 7 ) ):ToScreen()
						drawPos.x = drawPos.x - w / 2
						drawPos.y = drawPos.y - 15
						
						local col = Color(255, 255, 255, 255)
						
						
						textColor.a = alpha
						outlineCol.a = alpha
						
						draw.SimpleTextOutlined( text, font, x, y, Color(color.r, color.g, color.b, alpha or color.a), 1, 0, 1, outlineCol )
						]]
						local alpha = math.Clamp(255 - ( (255 / fadeDistance) * player:GetShootPos():Distance( LocalPlayer():GetShootPos() ) ), 0, 255);
						-- Define the x and y position.
						local x = player:GetShootPos():ToScreen().x;
						local y = player:GetShootPos():ToScreen().y - 64;
						
						-- Check if the position is visible.
						if (player:GetShootPos():ToScreen().visible) then
							y = y + (32 * (LocalPlayer():GetShootPos():Distance( player:GetShootPos() ) / fadeDistance)) * 0.5;
							
							-- Draw the information and get the new y position.
							draw.SimpleTextOutlined( "Typing", "EvoFont", x, y + math.sin( CurTime() ) * 4, Color(255, 255, 255, alpha), 1, 0, 1, Color( 0, 0, 0,alpha ) )
							--y = GAMEMODE:DrawInformation("Typing", "EvoFont", x, y + math.sin( CurTime() ) * 8, Color(255, 255, 255, 255), alpha)
						end;
					end;
				end;
			end;
		end;
	end;
end);

-- Called when a player starts typing.
evorp.hook.add("OpenChatBox", function()
	RunConsoleCommand("evorp_typing_start");
	LocalPlayer():SetNetworkedBool("evorp_Typing", true);
end);

-- Called when a player finishes typing.
evorp.hook.add("CloseChatBox", function()
	RunConsoleCommand("evorp_typing_finish");
	LocalPlayer():SetNetworkedBool("evorp_Typing", false);
end);

-- Register the plugin.
evorp.plugin.register(PLUGIN);
