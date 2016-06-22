ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Growing Weed Plant"
ENT.Author = "N/A"
ENT.Spawnable = true;
ENT.AdminSpawnable = true;

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"price")
	self:NetworkVar("Entity",1,"owning_ent")
end

PLANT_CONFIG = {}
-- Configuration ~ Start

	-- Duration for Stages (in seconds)
	PLANT_CONFIG.Stage1 = 20
	PLANT_CONFIG.Stage2 = 20
	PLANT_CONFIG.Stage3 = 30
	PLANT_CONFIG.Stage4 = 30
	PLANT_CONFIG.Stage5 = 40
	PLANT_CONFIG.Stage6 = 40
	PLANT_CONFIG.Stage7 = 45
	-- Mode
	PLANT_CONFIG.Mode 	= 3
	/* MODE STAGES
	Mode 1: Regular with no text
	Mode 2: Owner Text
	Mode 3: Spinning Owner Text
	*/
	-- Outcome (1 = drugs, 2 = money)
	PLANT_CONFIG.Outcome = 1
	-- Money Amount ONLY USED IF Outcome is 2
	PLANT_CONFIG.MoneyAmount = 150
	-- Plant Name
	PLANT_CONFIG.PlantName = "Marijuana" -- Some people prefer to call it Cannabis. Edit it if you want to.

-- Configuration ~ End