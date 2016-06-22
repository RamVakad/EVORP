--[[
Name: "cl_door.lua".
Product: "EvoRP (Roleplay)".
--]]

evorp.door = {};

-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetTitle("Door/Vehicle Menu");
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);

	self.btnClose.DoClick = function()
		self:Close();
		self:Remove();
		
		-- Disable the screen clicker.
		gui.EnableScreenClicker(false);
	end;
	
	-- Capture the position of the local player.
	self.localPlayerPosition = LocalPlayer():GetPos();
	
	-- Create the label panels.
	self.label = vgui.Create("DLabel", self);
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetTextColor( Color(255, 255, 255, 255) );
	self.nameLabel:SetText("Name:");
	self.nameLabel:SizeToContents();
	
	-- Create the text entry panel.
	self.textEntry = vgui.Create("DTextEntry", self);
	
	-- Create the okay button.
	self.okay = vgui.Create("DButton", self);
	self.okay:SetText("OK");
	self.okay.DoClick = function()
		RunConsoleCommand( "evorp", "door", "name", self.textEntry:GetValue() );
	end;
	
	-- Create the player list view.
	self.playerList = vgui.Create("DListView", self);
	self.playerList:SetMultiSelect(false);
	self.playerList:AddColumn("Players");
	self.playerList:SetSize(128, 256);
	self.playerList.players = {};
	
	-- Create the access list view.
	self.accessList = vgui.Create("DListView", self);
	self.accessList:SetMultiSelect(false);
	self.accessList:AddColumn("Access");
	self.accessList:SetSize(128, 256);
	self.accessList.players = {};
	
	-- Create the purchase button.
	self.purchase = vgui.Create("DButton", self);
	self.purchase:SetText("Purchase");
	self.purchase.DoClick = function()
		self:Close();
		self:Remove();
		
		-- Get if we're the owner.
		local owner = ( self.playerList:IsVisible() and self.accessList:IsVisible() );
		
		-- Disable the screen clicker.
		gui.EnableScreenClicker(false);
		
		-- Check if we're the owner.
		if (owner) then
			RunConsoleCommand("evorp", "door", "sell");
		else
			if (self.textEntry:GetValue() == "") then
				RunConsoleCommand("evorp", "door", "purchase");
			else
				RunConsoleCommand( "evorp", "door", "purchase", self.textEntry:GetValue() );
			end;
		end;
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	local owner = ( self.playerList:IsVisible() and self.accessList:IsVisible() );
	
	-- Check if we are the owner.
	if (owner) then
		if (self.unsellable) then
			self:SetSize(8 + self.playerList:GetWide() + 8 + self.accessList:GetWide() + 8, 28 + self.playerList:GetTall() + 8 + self.textEntry:GetTall() + 8);
		else
			self:SetSize(8 + self.playerList:GetWide() + 8 + self.accessList:GetWide() + 8, 28 + self.playerList:GetTall() + 8 + self.textEntry:GetTall() + 8 + self.purchase:GetTall() + 8);
		end;
	else
		local width = math.max( 112, self.label:GetWide() );
		
		-- Check if it is not owned by another player.
		if (!self.owner) then
			self:SetSize(8 + width + 8, 28 + self.label:GetTall() + 8 + self.textEntry:GetTall() + 8 + self.purchase:GetTall() + 8);
		else
			self:SetSize(8 + width + 8, 28 + self.label:GetTall() + 8);
		end;
	end;
	
	-- Set the visibility of the label.
	self.label:SetVisible(!owner);
	self.okay:SetVisible(owner);
	
	-- Set the position of the menu.
	self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2);
	
	-- Set the position of the label and the purchase button.
	self.label:SetPos(8, 28);
	self.purchase:SetPos(8, 50);
	
	-- Set the position of the player list and the access list.
	self.playerList:SetPos(8, 28);
	self.accessList:SetPos(8 + self.playerList:GetWide() + 8, 28);
	
	-- Set the position of the label, text entry, and button panels.
	self.nameLabel:SetPos(8, 28 + self.playerList:GetTall() + 10);
	self.textEntry:SetPos(8 + self.nameLabel:GetWide() + 8, 28 + self.playerList:GetTall() + 8);
	self.textEntry:SetSize(self:GetWide() - self.nameLabel:GetWide() - 24, 18);
	
	-- Check if we are the owner.
	if (owner) then
		self.purchase:SetText("Sell ($"..(evorp.configuration["Door Cost"] / 2)..")");
		self.purchase:SetPos(self:GetWide() / 2 - self.purchase:GetWide() / 2, 28 + self.playerList:GetTall() + 8 + self.textEntry:GetTall() + 8);
		
		-- Set the size of the text entry.
		self.textEntry:SetSize(self:GetWide() - self.nameLabel:GetWide() - self.okay:GetWide() - 32, 18);
		
		-- Set the label and text entry panels to be visible.
		self.nameLabel:SetVisible(true);
		self.textEntry:SetVisible(true);
	else
		self.purchase:SetText("Purchase");
		
		-- Set the position of the label and text entry panels.
		self.nameLabel:SetPos(8, 28 + self.label:GetTall() + 8);
		self.textEntry:SetPos(8 + self.nameLabel:GetWide() + 8, 28 + self.label:GetTall() + 8);
		
		-- Set the position of the purchase button.
		self.purchase:SetPos(8, 28 + self.label:GetTall() + 8 + self.textEntry:GetTall() + 8);
		
		-- Check if we have an owner.
		if (self.owner) then
			self.label:SetTextColor( Color(255, 0, 0, 255) );
			self.label:SetText("The owner of this door is currently online, and you may not buy it.");
			self.label:SizeToContents();
			self.purchase:SetDisabled(true);
			
			-- Set the label and text entry panels to be invisible.
			self.nameLabel:SetVisible(false);
			self.textEntry:SetVisible(false);
		else
			self.label:SetTextColor( Color(50, 255, 50, 255) );
			self.label:SetText("Purchase this door for $"..evorp.configuration["Door Cost"]..".");
			self.label:SizeToContents();
			self.purchase:SetDisabled(false);
			
			-- Set the label and text entry panels to be visible.
			self.nameLabel:SetVisible(true);
			self.textEntry:SetVisible(true);
		end;
	end;
	
	-- Set the position of the okay button.
	self.okay:SetPos(8 + self.nameLabel:GetWide() + 8 + self.textEntry:GetWide() + 8, 28 + self.playerList:GetTall() + 8);
	self.okay:SetSize(self.okay:GetWide(), 18);
	
	-- Set the frame to size itself based on it's contents.
	self:SizeToContents();
	
	-- Check if the local player's position is different from our captured one.
	if ( LocalPlayer():GetPos() != self.localPlayerPosition or !LocalPlayer():Alive() ) then
		self:Close();
		self:Remove();
		
		-- Disable the screen clicker.
		gui.EnableScreenClicker(false);
	end;
	
	-- Perform the layout of the main frame.
	DFrame.PerformLayout(self);
end;

-- Register the panel.
vgui.Register("evorp_Door", PANEL, "DFrame");

-- Hook the usermessage to toggle the menu from the server.
usermessage.Hook("evorp_Door", function(msg)
	local unsellable = msg:ReadBool();
	local owner = msg:ReadEntity();
	local door = msg:ReadEntity();
	
	-- Enable the screen clicker.
	gui.EnableScreenClicker(true);
	
	-- Check if the door panel already exists.
	if (evorp.door.panel) then evorp.door.panel:Remove(); evorp.door.panel = nil; end;
	
	-- The list of players for the panel.
	local players = {};
	
	-- Loop through each player.
	for k, v in pairs( g_Player.GetAll() ) do
		local entID = msg:ReadShort();
		local access = msg:ReadShort();
		
		-- Check if we can get this player by his ID.
		local player = g_Player.GetByID(entID)
		
		-- Check if the player is a valid entity.
		if ( IsValid(player) ) then
			table.insert( players, { player = player, entID = entID, access = access, owner = (player == owner) } );
		end;
	end;
	
	-- Create a new door panel.
	evorp.door.panel = vgui.Create("evorp_Door");
	evorp.door.panel.owner = nil;
	evorp.door.panel.unsellable = unsellable;
	evorp.door.panel:MakePopup();
	
	-- Check if the owner is a valid entity.
	if ( IsValid(owner) ) then
		evorp.door.panel.owner = owner:Name();
		evorp.door.panel.textEntry:SetValue( door:GetNetworkedString("evorp_Name") );
	end;
	
	-- Check if the local player is the owner of the door.
	if (LocalPlayer() == owner) then
		for k, v in pairs(players) do
			if (v.access == 0) then
				local id = evorp.door.panel.playerList:AddLine( v.player:Name() ):GetID();
				
				-- Add it to our list of players.
				evorp.door.panel.playerList.players[id] = {name = v.player:Name(), entID = v.entID};
			elseif (v.access == 1) then
				local id = evorp.door.panel.accessList:AddLine( v.player:Name() ):GetID();
				
				-- Add it to our list of players.
				evorp.door.panel.accessList.players[id] = {name = v.player:Name(), entID = v.entID};
			end;
		end;
		
		-- Set the function to do a double click for the player list.
		evorp.door.panel.playerList.DoDoubleClick = function(self, id, line)
			local index = evorp.door.panel.accessList:AddLine(self.players[id].name):GetID();
			
			-- Add it to our list of players.
			evorp.door.panel.accessList.players[index] = self.players[id];
			
			-- Remove the line from the players list.
			self:RemoveLine(id)
			
			-- Run a console command to tell the server we've changed access.
			RunConsoleCommand("evorp", "door", "access", self.players[id].entID);
		end;
		
		-- Set the function to do a double click for the access list.
		evorp.door.panel.accessList.DoDoubleClick = function(self, id, line)
			local index = evorp.door.panel.playerList:AddLine(self.players[id].name):GetID();
			
			-- Add it to our list of players.
			evorp.door.panel.playerList.players[index] = self.players[id];
			
			-- Remove the line from the access list.
			self:RemoveLine(id)
			
			-- Run a console command to tell the server we've changed access.
			RunConsoleCommand( "evorp", "door", "access", tostring(self.players[id].entID) );
		end;
	else
		evorp.door.panel.playerList:SetVisible(false);
		evorp.door.panel.accessList:SetVisible(false);
	end;
end);