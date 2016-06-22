SWEP.Author = "Int64"
SWEP.Contact = ""
SWEP.Purpose = "Fine those speeding players!"
SWEP.Instructions = "Primary to check speed."
 
SWEP.Spawnable = true;
SWEP.AdminSpawnable = false;
 
SWEP.ViewModel = "models/weapons/v_pistol.mdl";
SWEP.WorldModel = "models/weapons/w_pistol.mdl";
 
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
 
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

local ShootSound =  Sound("weapons/ar2/ar2_reload_rotate.wav")
local ModeSound = Sound("weapons/ar2/ar2_empty.wav")


function SWEP:Initialize() 
	 self:SetWeaponHoldType("normal")
	util.PrecacheSound(ShootSound)
	util.PrecacheSound(ModeSound)
	Mode = 1 
	speed = 0
	CanFire = true;
end 

function SWEP:Reload()
	// Change mode to KMH (1) or MPH (2)
	if Mode == 1 then
		Mode = 2
		self.Weapon:EmitSound( ModeSound )
	else
		Mode = 1
		self.Weapon:EmitSound( ModeSound )
	end
end
 
function SWEP:PrimaryAttack()
	if (!CanFire) then return end;

	local tr = self:GetOwner():GetEyeTrace()
	if ( tr.HitWorld ) then return end
	if not tr.Entity:IsValid() then return end
	local vel = tr.Entity:GetVelocity():Length()
	local mph = math.abs(math.floor(vel/ 23.33));
	local kph =  math.abs(math.floor(vel/ 14.49));
	local eph = math.abs(math.floor(vel/ 25.33));
	CanFire = false;

	if Mode == 1 then
		self.Owner:PrintMessage(HUD_PRINTCENTER, mph.." MPH")
	else
		self.Owner:PrintMessage(HUD_PRINTCENTER, kph.." KMPH")
	end
	timer.Simple( 1, function() CanFire = true; end)
end

function SWEP:SecondaryAttack()
end