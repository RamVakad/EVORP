include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	if self:GetModel() == "models/nater/weedplant_pot_growing7.mdl" then
		self:SetColor( Color( 0, 255, 0, 255) )
	else
		self:SetColor( Color( 255, 255, 255, 255) )
	end
	
	if PLANT_CONFIG.Mode == nil then return end
	if PLANT_CONFIG.Mode > 1 then
		local Pos = self:GetPos()
		local Ang = self:GetAngles()
		surface.SetFont("HUDNumber5")
		local TextWidth = surface.GetTextSize(PLANT_CONFIG.PlantName or "Weed Plant")
		local TextWidth2 = surface.GetTextSize(self:GetNetworkedString("evorp_grower"))

		Ang:RotateAroundAxis(Ang:Forward(), 90)
		local TextAng = Ang
		if PLANT_CONFIG.Mode == 3 then
			TextAng:RotateAroundAxis(TextAng:Right(), CurTime()*-20)
		end
		cam.Start3D2D(Pos + Ang:Right() * -30, TextAng, 0.2)
			draw.WordBox(1, -TextWidth*0.5 + 5, -60, PLANT_CONFIG.PlantName or "Weed Plant", "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255))
			draw.WordBox(1, -TextWidth2*0.5 + 5, -14, self:GetNetworkedString("evorp_grower"), "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255))
		cam.End3D2D()
	end
end