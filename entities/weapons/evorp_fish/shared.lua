if (SERVER) then
	AddCSLuaFile("shared.lua")
end

if (CLIENT) then
	SWEP.PrintName = "Fishing Rod"
	SWEP.Slot = 2
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

-- Variables that are used on both client and server

SWEP.Author = "Int64"
SWEP.Instructions = "Go to the lake and click on the water."
SWEP.Contact = ""
SWEP.Purpose = "Fishing"

SWEP.ViewModel = Model("models/als/rod/v_rod.mdl")
SWEP.WorldModel = Model("models/als/rod/w_rod.mdl")

SWEP.Spawnable = true;
SWEP.AdminSpawnable = true

SWEP.Primary.ClipSize = 6
SWEP.Primary.ClipMax = 6      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = "HelicopterGun"

-- Set the secondary fire settings.
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo	= "";

SWEP.LockPickTime = 15

/*---------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()
	self:SetWeaponHoldType("pistol")
end

function SWEP:GetFishingPosition()
	if(CLEINT) then return end

end

function SWEP:SecondaryAttack() end

/*---------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + .4)
	if not (self.Owner:GetAmmoCount("HelicopterGun") > 0) then 
		if (SERVER) then
			evorp.player.notify(self.Owner, "You don't have any bait!", 0)
		end
		return
	end
	if self.IsLockPicking then return end

	local watertrace = util.TraceLine{ start = self.Owner:GetPos(), endpos = self.Owner:GetPos()+self.Owner:EyeAngles():Up()*-500, filter = self.Owner, mask = MASK_WATER }
	local fishpos = 0;
	if string.lower(game.GetMap()) == "rp_evocity_v2d" then
		fishpos = Vector(7483, 13508, 45)
	end
	if string.lower(game.GetMap()) == "rp_evocity_v2d_sexy_v2" then
		fishpos = Vector(1067, 495, 0)
	end
	if string.lower(game.GetMap()) == "rp_evocity_v33x" then
		fishpos = Vector(-9433, 13035, 40)
	end
	if string.lower(game.GetMap()) == "rp_chaos_city_v33x_03" then
		fishpos = Vector(-11285, -11413, -2245)
	end
	if watertrace.MatType == 83 and watertrace.HitPos:Distance(self.Owner:GetPos()) < 500 then
		self.origLook = self.Owner:GetEyeTrace().HitPos
		self.IsLockPicking = true
		self.StartPick = CurTime()
		local time = math.random(self.LockPickTime) + 6
		self.EndPick = CurTime() + time
		
		if SERVER then
			timer.Create("LockPickSounds", 1, time, function()
				if not (self and IsValid(self)) then return end
				if (self.IsLockPicking) then
					self:EmitSound("fishingrod/reel.wav")
				end
			end)
		end
		if CLIENT then
			self.Dots = self.Dots or ""
			timer.Create("LockPickDots", 0.5, 0, function()
				local wep = self
				local len = string.len(wep.Dots or "")
				local dots = {[0]=".", [1]="..", [2]="...", [3]=""}
				wep.Dots = dots[len]
			end)
		end
	end
end

function SWEP:Holster()
	self.IsLockPicking = false
	if SERVER then timer.Stop("LockPickSounds") end
	if CLIENT then timer.Stop("LockPickDots") end
	return true
end

function SWEP:Succeed()
	
	local trace = self.Owner:GetEyeTrace()
	if SERVER then timer.Stop("LockPickSounds") end
	if CLIENT then timer.Stop("LockPickDots") return end
	local fail = false
	if (SERVER) then
		self:EmitSound("ambient/water/drip2.wav", 30, 100)
		if (!fail and math.random(100) < 10) then
			evorp.player.notify(self.Owner, "Your fishing rod broke!", 0)
			self.Owner:SelectWeapon("evorp_hands")
			self.Owner:StripWeapon("evorp_fish")
			fail = true
		end
		self.IsLockPicking = false
		local chance =  math.random(100);
		print(chance)
		if (!fail and math.random(100) > 60) then
			evorp.player.notify(self.Owner, "A fish caught your bait, aim up to reel it in!", 0)
			timer.Create("FishCatch", 2.5, 1, function()
				if (self and self.Owner and IsValid(self.Owner)) then
					local pos = self.Owner:GetEyeTrace().HitPos
					if (self.origLook:Distance(pos) > 256) then
						if (evorp.inventory.canFit(self.Owner, evorp.item.stored["fish"].size)) then
							if (math.random(100) < 25) then
								evorp.inventory.update(self.Owner, "goldfish", 1, false)
								evorp.player.notify(self.Owner, "You caught a gold fish!", 0)
							else
								evorp.inventory.update(self.Owner, "fish", 1, false)
								evorp.player.notify(self.Owner, "Your fish is in your inventory!", 0)
							end
						else
							evorp.player.notify(self.Owner, "Not enough inventory space to store fish!", 1)
						end
					else
						evorp.player.notify(self.Owner, "You didn't reel in the fish and it has escaped with your bait!", 0)
					end
				end
			end)
		else
			evorp.player.notify(self.Owner, "Catch failed, try again!", 0)
		end
	self:TakePrimaryAmmo(1)
	end
	if SERVER then timer.Stop("LockPickSounds") end
	if CLIENT then timer.Stop("LockPickDots") end
end

function SWEP:Fail()
	self.IsLockPicking = false
	self:SetWeaponHoldType("normal")
	if SERVER then
		timer.Stop("LockPickSounds")	
	end
	if CLIENT then timer.Stop("LockPickDots") end
end

function SWEP:Think()
	if self.IsLockPicking then
		local trace = self.Owner:GetEyeTrace()
		if  self.origLook:Distance(self.Owner:GetEyeTrace().HitPos) > 200 then
			self:Fail()
		end
		if self.EndPick <= CurTime() then
			self:Succeed()
		end
	end
end

function SWEP:DrawHUD()
  	draw.SimpleText("Baits Left: "..self.Owner:GetAmmoCount("HelicopterGun"), "EvoFont2", ScrW() - 100, ScrH() - 100, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	if self.IsLockPicking then
		self.Dots = self.Dots or ""
		local w = ScrW()
		local h = ScrH()
		local x,y,width,height = w/2-w/10, h/ 2, w/5, h/15
		draw.RoundedBox(8, x, y, width, height, Color(10,10,10,120))
		
		local time = self.EndPick - self.StartPick
		local curtime = CurTime() - self.StartPick
		local status = curtime/time
		local BarWidth = status * (width - 16) + 8
		--draw.RoundedBox(8, x+8, y+8, BarWidth, height - 16, Color(255-(status*255), 0+(status*255), 0, 255))
		
		draw.SimpleText("Fishing"..self.Dots, "EvoFont", w/2, h/2 + height/2, Color(255,255,255,255), 1, 1)
	end
end