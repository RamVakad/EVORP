if (SERVER) then
	AddCSLuaFile("shared.lua")
end

if (CLIENT) then
	SWEP.PrintName = "Lock Pick"
	SWEP.Slot = 2
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

-- Variables that are used on both client and server

SWEP.Author = "Int64"
SWEP.Instructions = "Left click to pick a lock."
SWEP.Contact = ""
SWEP.Purpose = "Unlocking doors, handcuffs, etc."

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/v_crowbar.mdl")
SWEP.WorldModel = Model("models/weapons/w_crowbar.mdl")

SWEP.Spawnable = true;
SWEP.AdminSpawnable = true

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""
SWEP.LockPickTime = 15

/*---------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
end

/*---------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + .4)
	if self.IsLockPicking then return end

	local trace = self.Owner:GetEyeTrace()
	local e = trace.Entity
	if ( IsValid(trace.Entity) ) then
		if (evorp.entity.isDoor(trace.Entity) or trace.Entity:GetClass() == "prop_dynamic" or string.find( trace.Entity:GetClass( ), "prop_vehicle_jeep" )) or (trace.Entity:IsPlayer() and trace.Entity:GetNetworkedBool("cuffed")) then
			if (trace.Entity:IsPlayer() and trace.Entity:GetNetworkedBool("cuffed")) then
				if (SERVER) then
					evorp.player.notify(trace.Entity, "Your handcuffs are being lockpicked by "..self.Owner:Nick()..". Do not move.", 0)
				end
			end
			self.IsLockPicking = true
			self.StartPick = CurTime()
			local time = self.LockPickTime
			if (string.find( trace.Entity:GetClass( ), "prop_vehicle_jeep" ) ) then time = 30 end;
			self.EndPick = CurTime() + time
			self:SetWeaponHoldType("pistol")
			if SERVER then

				timer.Create("LockPickSounds", 1, self.LockPickTime, function()
					local wep = self
					local snd = {1,3,4}
					if (IsValid(wep)) then
						wep:EmitSound("weapons/357/357_reload".. tostring(snd[math.random(1, #snd)]) ..".wav", 30, 100)
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
end

function SWEP:Holster()
	self.IsLockPicking = false
	if SERVER then timer.Stop("LockPickSounds") end
	if CLIENT then timer.Stop("LockPickDots") end
	return true
end

function SWEP:Succeed()
	self.IsLockPicking = false
	local trace = self.Owner:GetEyeTrace()
	local team = evorp.team.get( self.Owner:Team() ).name;
	local percentage = 25;
	if (IsValid(trace.Entity) and string.find( trace.Entity:GetClass( ), "prop_vehicle_jeep" )) then percentage = 40 end
	if SERVER then timer.Stop("LockPickSounds") end
	if CLIENT then timer.Stop("LockPickDots") return end
	if (math.random(100) < percentage) then
			evorp.player.notify(self.Owner, "Your lockpick broke!", 0)
			self.Owner:SelectWeapon("evorp_hands")
			self.Owner:StripWeapon("evorp_lockpick")
			return
	end
	if(IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:GetNetworkedBool("cuffed")) then
		gamemode.Call("PlayerLoadout", trace.Entity)
		if ( evorp.player.hasAccess(trace.Entity, "t") ) then 
			trace.Entity:Give("gmod_tool");
		end;
		if ( evorp.player.hasAccess(trace.Entity, "p") ) then 
			trace.Entity:Give("weapon_physgun");
		end;
		trace.Entity:SetNetworkedBool("cuffed", false)
		self.Owner:PrintMessage( HUD_PRINTCENTER, "You have released "..trace.Entity:Nick().."." )
		trace.Entity:PrintMessage( HUD_PRINTCENTER, "You have been released by "..self.Owner:Nick().."." )
		if (SERVER) then
			if (tr.Entity.evorp._Arrested) then
				evorp.player.arrest(tr.Entity, false, true);
				gamemode.Call("PlayerLoadout", tr.Entity)
			end
		end
	elseif (IsValid(trace.Entity) and string.find( trace.Entity:GetClass( ), "prop_vehicle_jeep" )) then
		trace.Entity:EmitSound("caralarm.mp3", 100, 100) 
		timer.Create( "CarAlarmLoop", 9.7, 1, function()
			trace.Entity:EmitSound("caralarm.mp3", 100, 100) 
		end)
		self:DoLock(false)
		if (SERVER and IsValid(trace.Entity._Owner)) then
			evorp.player.printConsoleAccess(self.Owner:Nick().." ["..self.Owner:SteamID().."] lockpicked "..trace.Entity._Owner:Nick().."'s' ["..trace.Entity._Owner:SteamID().."] car as a "..team..".", "a", "kills", self.Owner)
		end
	elseif IsValid(trace.Entity) and trace.Entity.Fire then

		if (evorp.entity.isDoor(trace.Entity) and IsValid(trace.Entity._Owner)) then
			if (SERVER) then
				if (trace.Entity.iDoorSID) then
					evorp.player.printConsoleAccess(self.Owner:Nick().." ["..self.Owner:SteamID().."] lockpicked the (STool) door of "..trace.Entity.iDoorNick.." ["..trace.Entity.iDoorSID.."] as a "..team..".", "a", "kills", self.Owner)
				else
					evorp.player.printConsoleAccess(self.Owner:Nick().." ["..self.Owner:SteamID().."] lockpicked the door of "..trace.Entity._Owner:Nick().." ["..trace.Entity._Owner:SteamID().."] as a "..team..".", "a", "kills", self.Owner)
				end

				local team = self.Owner:Team()
				if (team == TEAM_OFFICER or team == TEAM_COMMANDER) then
					local warrant = trace.Entity._Owner:GetNetworkedString("evorp_Warranted");
					if warrant != "search" then
						evorp.player.notify(self.Owner, "You need a warrant first!", 0)
						evorp.player.printConsoleAccess("[Alert] He had no search warrant! Returning false.", "a", "kills", self.Owner)
						return false
					end
				end
			end
		end
		trace.Entity:Fire("unlock", "", .5)
		trace.Entity:Fire("open", "", .6)
		trace.Entity:Fire("setanimation","open","0")
		trace.Entity.iOpen = true;
		trace.Entity:Fire("lock", "", .5)
	end
	self:SetWeaponHoldType("normal")
	if SERVER then timer.Stop("LockPickSounds") end
	if CLIENT then timer.Stop("LockPickDots") end
end

function SWEP:DoLock( lockUnLock )

	local tr = self:DoTrace()
	
	if tr.Hit then
		if not(string.find( tr.Entity:GetClass( ), "prop_vehicle_jeep" )) then return false end

		local SCARIA = tr.Entity
		
		if (SERVER) then
			if lockUnLock == true then
				SCARIA:SetNetworkedBool("locked", true)
			else
				SCARIA:SetNetworkedBool("locked", false)
			end
		end
	end
end

function SWEP:DoTrace()
	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = trace.start + (self.Owner:GetAimVector() * 10000)
	trace.filter = { self.Owner, self.Weapon }
	local tr = util.TraceLine( trace )
	return tr
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
		if not IsValid(trace.Entity) then 
			self:Fail()
		end
		if trace.HitPos:Distance(self.Owner:GetShootPos()) > 100 or (not evorp.entity.isDoor(trace.Entity) and not trace.Entity:GetClass() == "prop_vehicle_jeep") then
			self:Fail()
		end
		if self.EndPick <= CurTime() then
			self:Succeed()
		end
	end
end

function SWEP:DrawHUD()
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
		draw.RoundedBox(8, x+8, y+8, BarWidth, height - 16, Color(255-(status*255), 0+(status*255), 0, 255))
		
		draw.SimpleText("Picking lock"..self.Dots, "EvoFont", w/2, h/2 + height/2, Color(255,255,255,255), 1, 1)
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end
