
SWEP.ViewModelFOV	= 75
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_molotov.mdl"
SWEP.WorldModel		= "models/weapons/w_grenade.mdl"

SWEP.ReloadSound	= ""

SWEP.Slot = 4
SWEP.SlotPos = 1

SWEP.DrawWorldModel = false
SWEP.DrawViewModel 	= true
SWEP.DrawShadow		= true

SWEP.HoldType		= "grenade"

SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "grenade"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false	
SWEP.Secondary.Ammo			= "none"

function SWEP:Initialize()
	self.Weapon:SetWeaponHoldType(self.HoldType)
	util.PrecacheSound("WeaponFrag.Throw")
	util.PrecacheModel("models/props_junk/garbage_glassbottle003a.mdl")
	util.PrecacheModel(self.ViewModel)
	util.PrecacheSound("physics/glass/glass_largesheet_break1.wav")
	util.PrecacheSound("physics/glass/glass_largesheet_break2.wav")
	util.PrecacheSound("physics/glass/glass_largesheet_break3.wav")
end

function SWEP:Deploy()

end

function SWEP:PrimaryAttack()
	--if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + 0.5)
	self:SetWeaponHoldType(self.HoldType)
	self.Owner:EmitSound("WeaponFrag.Throw", 100, 100)
	self:SendWeaponAnim(ACT_VM_THROW)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	if (CLIENT) then return end

		local ent = ents.Create("ent_molotov_c")
		ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 16))
		ent:SetAngles(self.Owner:GetAngles())
		ent:Spawn()
		
		local entobject = ent:GetPhysicsObject()
		entobject:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() * math.random(1500,2000))
	self.Owner:SelectWeapon("evorp_hands")
	self.Owner:StripWeapon("evorp_molotov")
	--self:TakePrimaryAmmo(1)
end

function SWEP:SecondaryAttack()

end

function SWEP:Reload()
	self.Weapon:DefaultReload(ACT_VM_DRAW)
end

function SWEP:Think()

end
