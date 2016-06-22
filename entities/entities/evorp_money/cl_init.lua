--[[
Name: "cl_init.lua".
Product: "EvoRP (Roleplay)".
--]]

include("sh_init.lua")

-- This is called when the entity should draw.
function ENT:Draw() 
	self.Entity:DrawModel(); 

	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	surface.SetFont("EvoFont2")
	local TextWidth = surface.GetTextSize("$"..tostring(self:GetNetworkedInt("evorp_Amount")))

	cam.Start3D2D(Pos + Ang:Up() * 0.9, Ang, 0.1)
		draw.WordBox(2, -TextWidth*0.5, -10, "$"..tostring(self:GetNetworkedInt("evorp_Amount")), "ChatFont", Color(0, 140, 0, 100), Color(255,255,255,255))
	cam.End3D2D()

	Ang:RotateAroundAxis(Ang:Right(), 180)

	cam.Start3D2D(Pos, Ang, 0.1)
		draw.WordBox(2, -TextWidth*0.5, -10, "$"..tostring(self:GetNetworkedInt("evorp_Amount")), "ChatFont", Color(0, 140, 0, 100), Color(255,255,255,255))
	cam.End3D2D()
end;
