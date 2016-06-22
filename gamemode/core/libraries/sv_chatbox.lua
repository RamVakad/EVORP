--[[
Name: "sv_chat.lua".
Product: "EvoRP (Roleplay)".
--]]

evorp.chatBox = {};

-- Add a new line.
function evorp.chatBox.add(recipientFilter, player, filter, text)
	if (player) then
		umsg.Start("evorp.chatBox.playerMessage", recipientFilter);
			umsg.Entity(player);
			umsg.String(filter);
			umsg.String(text);
		umsg.End();
	else
		umsg.Start("evorp.chatBox.message", recipientFilter);
			umsg.String(filter);
			umsg.String(text);
		umsg.End();
	end;
end;

-- Add a new line to players within the radius of a position.
function evorp.chatBox.addInRadius(player, filter, text, position, radius)
	for k, v in pairs( g_Player.GetAll() ) do
		if (v:GetPos():Distance( position ) <= radius) then
			evorp.chatBox.add(v, player, filter, text);
		end;
	end;
end;
