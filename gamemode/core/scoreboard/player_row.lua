include( "player_infocard.lua" )

surface.CreateFont("ScoreboardPlayerName", {font = "Museo Sans 500", size = 17, weight = 600, antialias = true, shadow = false})
surface.CreateFont("ScoreboardPlayerNameBig", {font = "Museo Sans 500", size = 20, weight = 500, antialias = true, shadow = false})

local texGradient = surface.GetTextureID( "gui/center_gradient" )
local PANEL = {}

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self.Size = 36
	self:OpenInfo( false )
	
	self.infoCard	= vgui.Create( "ScorePlayerInfoCard", self )
	
	self.lblName 	= vgui.Create( "DLabel", self )
	self.lblTime 	= vgui.Create( "DLabel", self )
	self.lblPoints 	= vgui.Create( "DLabel", self )
	self.lblFrags 	= vgui.Create( "DLabel", self )
	self.lblDeaths 	= vgui.Create( "DLabel", self )
	self.lblPing 	= vgui.Create( "DLabel", self )
	
	// If you don't do this it'll block your clicks
	self.lblName:SetMouseInputEnabled( true )
	self.lblTime:SetMouseInputEnabled( false )
	self.lblPoints:SetMouseInputEnabled( false )
	self.lblFrags:SetMouseInputEnabled( false )
	self.lblDeaths:SetMouseInputEnabled( false )
	self.lblPing:SetMouseInputEnabled( false )
	
	self.imgAvatar = vgui.Create( "AvatarImage", self )
	
	self:SetCursor( "hand" )

end;

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint( w, h)

	if ( !IsValid( self.Player ) ) then return end;
	
	local color = team.GetColor( self.Player:Team() )

	if ( self.Open || self.Size != self.TargetSize ) then
	
		draw.RoundedBox( 4, 0, 16, self:GetWide(), self:GetTall() - 16, color )
		draw.RoundedBox( 4, 2, 16, self:GetWide()-4, self:GetTall() - 16 - 2, Color( 250, 250, 245, 255 ) )
		
		surface.SetTexture( texGradient )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( 2, 16, self:GetWide()-4, self:GetTall() - 16 - 2 ) 
	
	end;
	
	draw.RoundedBox( 4, 0, 0, self:GetWide(), 36, color )
	
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 50 )
	surface.DrawTexturedRect( 0, 0, self:GetWide(), 36 ) 
	
	// This should be an image panel!
	surface.SetMaterial( self.texRating )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( self:GetWide() - 16 - 8, 36 / 2 - 8, 16, 16 ) 	
	
	return true

end;

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:SetPlayer( ply )

	self.Player = ply
	
	self.infoCard:SetPlayer( ply )
	self.imgAvatar:SetPlayer( ply )
	
	self:UpdatePlayerData()

end;


/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()

	if ( !self.Player ) then return end;
	if ( !self.Player:IsValid() ) then return end;

	self.lblName:SetText( "["..self.Player:GetNetworkedString("evorp_Job").."] "..self.Player:Nick().." ("..self.Player:GetNetworkedString("evorp_NameIC")..")" )
	self.lblName:SizeToContents()
	if self.Player then self.lblTime:SetText( math.floor((self.Player:GetNetworkedInt("evorp_PlayTime", 0) + (os.time() - self.Player:GetNetworkedInt("evorp_JoinCurTime", 0))) / 3600)) end	
	if self.Player then 
		self.lblPoints:SetText(tonumber(self.Player:GetNetworkedInt("evorp_PointsRP", "0"))) 
	else 
		self.lblPoints:SetText("0")  
	end
	self.lblFrags:SetText( self.Player:Frags() )
	self.lblDeaths:SetText( self.Player:Deaths() )
	self.lblPing:SetText( self.Player:Ping() )
	 
 	if (self.Player:IsUserGroup("moderator")) then
		self.texRating = Material( "icon16/wrench.png" )
	elseif ( self.Player:IsUserGroup("trailmod") ) then
		self.texRating = Material( "icon16/accept.png" )
	elseif ( self.Player:IsSuperAdmin() ) then
		self.texRating = Material( "icon16/shield.png" )
	elseif(  self.Player:IsAdmin() )then
		self.texRating = Material( "icon16/star.png" )
	elseif ( self.Player:GetNetworkedBool("evorp_Donator") ) then
		self.texRating = Material( "icon16/heart.png" )
	else
		self.texRating = Material( "icon16/user.png" )
	end
	// Work out what icon to draw.
	--[[
	if ( self.Player:IsUserGroup( "developer" ) ) then
		
	elseif (self.Player:IsAdmin()) then
		
	elseif (!self.Player:IsSuperAdmin() and !self.Player:IsAdmin() and self.Player:GetNetworkedBool("evorp_Donator")) then
		
	else
		
	end;]]
end;



/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()

	self.lblName:SetFont( "ScoreboardPlayerNameBig" )
	self.lblTime:SetFont( "ScoreboardPlayerName" )
	self.lblPoints:SetFont( "ScoreboardPlayerName" )
	self.lblFrags:SetFont( "ScoreboardPlayerName" )
	self.lblDeaths:SetFont( "ScoreboardPlayerName" )
	self.lblPing:SetFont( "ScoreboardPlayerName" )
	
	self.lblName:SetFGColor( color_white )
	self.lblTime:SetFGColor( color_white )
	self.lblPoints:SetFGColor( color_white )
	self.lblFrags:SetFGColor( color_white )
	self.lblDeaths:SetFGColor( color_white )
	self.lblPing:SetFGColor( color_white )

end;

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:OpenInfo( bool )

	if ( bool ) then
		self.TargetSize = 150
	else
		self.TargetSize = 36
	end;
	
	self.Open = bool

end;

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Think()

	if ( self.Size != self.TargetSize ) then
	
		self.Size = math.Approach( self.Size, self.TargetSize, (math.abs( self.Size - self.TargetSize ) + 1) * 10 * FrameTime() )
		self:PerformLayout()
		SCOREBOARD:InvalidateLayout()
	//	self:GetParent():InvalidateLayout()
	
	end;
	
	if ( !self.PlayerUpdate || self.PlayerUpdate < CurTime() ) then
	
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()
		
	end;

end;

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self.imgAvatar:SetPos( 2, 2 )
	self.imgAvatar:SetSize( 32, 32 )

	self:SetSize( self:GetWide(), self.Size )
	
	self.lblName:SizeToContents()
	self.lblName:SetPos( 24, 2 )
	self.lblName:MoveRightOf( self.imgAvatar, 8 )
	
	local COLUMN_SIZE = 50
	
	self.lblPing:SetPos( self:GetWide() - COLUMN_SIZE * 1, 0 )
	self.lblDeaths:SetPos( self:GetWide() - COLUMN_SIZE * 2, 0 )
	self.lblFrags:SetPos( self:GetWide() - COLUMN_SIZE * 3, 0 )
	self.lblPoints:SetPos( self:GetWide() - COLUMN_SIZE * 4, 0 )
	self.lblTime:SetPos( self:GetWide() - COLUMN_SIZE * 5, 0 )
	
	if ( self.Open || self.Size != self.TargetSize ) then
	
		self.infoCard:SetVisible( true )
		self.infoCard:SetPos( 4, self.imgAvatar:GetTall() + 10 )
		self.infoCard:SetSize( self:GetWide() - 8, self:GetTall() - self.lblName:GetTall() - 10 )
	
	else
	
		self.infoCard:SetVisible( false )
	
	end;
	
	

end;

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:HigherOrLower( row )
	if (IsValid(self.Player) and IsValid(row.Player)) then
		return self.Player:Team() < row.Player:Team()
	end
	return false
end;


vgui.Register( "ScorePlayerRow", PANEL, "Button" )