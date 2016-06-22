
if SERVER then
   AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType			= "ar2"

if CLIENT then
   SWEP.PrintName = "Projectile EMP"
   SWEP.Slot = 3
   SWEP.SlotPos = 1

   SWEP.ViewModelFlip = false
   SWEP.ViewModelFOV = 54

   SWEP.Icon = "VGUI/ttt/icon_polter"
end

SWEP.Primary.Recoil	= 0.1
SWEP.Primary.Delay = 12.0
SWEP.Primary.Cone = 0.02
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Ammo = "Gravity"
SWEP.Primary.Automatic = false

-- Set the secondary fire settings.
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo  = "";

SWEP.UseHands			= true
SWEP.ViewModel	= "models/weapons/c_irifle.mdl"
SWEP.WorldModel	= "models/weapons/w_IRifle.mdl"

SWEP.Primary.Sound = Sound( "weapons/airboat/airboat_gun_energy1.wav" )

SWEP.NoSights = true

local maxrange = 800

local math = math

-- Returns if an entity is a valid physhammer punching target. Does not take
-- distance into account.
local function ValidTarget(ent)
   return (IsValid(ent) and ent:GetClass() == "prop_vehicle_jeep")
   -- NOTE: cannot check for motion disabled on client
end

local ghostmdl = Model("models/Items/combine_rifle_ammo01.mdl")
function SWEP:Initialize()
   if CLIENT then
      -- create ghosted indicator
      local ghost = ents.CreateClientProp(ghostmdl)
      if IsValid(ghost) then
         ghost:SetPos(self:GetPos())
         ghost:Spawn()

         -- PhysPropClientside whines here about not being able to parse the
         -- physmodel. This is not important as we won't use that anyway, and it
         -- happens in sandbox as well for the ghosted ents used there.

         ghost:SetSolid(SOLID_NONE)
         ghost:SetMoveType(MOVETYPE_NONE)
         ghost:SetNotSolid(true)
         ghost:SetRenderMode(RENDERMODE_TRANSCOLOR)
         ghost:AddEffects(EF_NOSHADOW)
         ghost:SetNoDraw(true)

         self.Ghost = ghost
      end
   end

   return self.BaseClass.Initialize(self)
end

function SWEP:PreDrop()

   -- OnDrop does not happen on client
   self.Weapon:CallOnClient("HideGhost", "")
end

function SWEP:HideGhost()
   if IsValid(self.Ghost) then
      self.Ghost:SetNoDraw(true)
   end
end
function SWEP:DrawHUD()
   draw.SimpleText("EMPs LEFT: "..self.Owner:GetAmmoCount("Gravity"), "EvoFont2", ScrW() - 100, ScrH() - 100, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
function SWEP:PrimaryAttack()
   self.Weapon:SetNextPrimaryFire(CurTime() + 0.1)
   if not self:CanPrimaryAttack() then return end

   if SERVER then
      local ply = self.Owner
      if not IsValid(ply) then return end

      local tr = util.TraceLine({start=ply:GetShootPos(), endpos=ply:GetShootPos() + ply:GetAimVector() * maxrange, filter={ply, self.Entity}, mask=MASK_SOLID})

      if tr.HitNonWorld and ValidTarget(tr.Entity) and tr.Entity:GetPhysicsObject():IsMoveable() then

         self:CreateHammer(tr.Entity, tr.HitPos)

         self.Owner:EmitSound(self.Primary.Sound)
         self:TakePrimaryAmmo(1)
         self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
      end
   end
end

function SWEP:SecondaryAttack()
end

function SWEP:CreateHammer(tgt, pos)
   local hammer = ents.Create("ttt_physhammer")
   if IsValid(hammer) then
      local ang = self.Owner:GetAimVector():Angle()
      ang:RotateAroundAxis(ang:Right(), 90)

      hammer:SetPos(pos)
      hammer:SetAngles(ang)

      hammer:Spawn()

      hammer:SetOwner(self.Owner)

      local stuck = hammer:StickTo(tgt)

      if not stuck then hammer:Remove() end
   end
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self.Ghost) then
      self.Ghost:Remove()
   end
end

function SWEP:Holster()
   if CLIENT and IsValid(self.Ghost) then
      self.Ghost:SetNoDraw(true)
   end

   return self.BaseClass.Holster(self)
end


local function around( val )
   return math.Round( val * (10 ^ 3) ) / (10 ^ 3);
end

if CLIENT then
   local surface = surface

   function SWEP:UpdateGhost(pos, c, a)
      if IsValid(self.Ghost) then
         if self.Ghost:GetPos() != pos then
            self.Ghost:SetPos(pos)
            local ang = LocalPlayer():GetAimVector():Angle()
            ang:RotateAroundAxis(ang:Right(), 90)

            self.Ghost:SetAngles(ang)

            self.Ghost:SetColor(Color(255, 255, 255, a))

            self.Ghost:SetNoDraw(false)
         end
      end
   end

   local linex = 0
   local liney = 0
   local laser = Material("trails/laser")
   function SWEP:ViewModelDrawn()
      local client = LocalPlayer()
      local vm = client:GetViewModel()
      if not IsValid(vm) then return end

      local plytr = client:GetEyeTrace(MASK_SHOT)

      local muzzle_angpos = vm:GetAttachment(1)
      local spos = (muzzle_angpos.Pos or 0) + muzzle_angpos.Ang:Forward() * 10
      local epos = client:GetShootPos() + client:GetAimVector() * maxrange

      -- Painting beam
      local tr = util.TraceLine({start=spos, endpos=epos, filter=client, mask=MASK_ALL})

      local c = COLOR_RED
      local a = 150
      local d = (plytr.StartPos - plytr.HitPos):Length()
      if plytr.HitNonWorld then
         if ValidTarget(plytr.Entity) then
            if d < maxrange then
               c = COLOR_GREEN
               a = 255
            else
               c = COLOR_YELLOW
            end
         end
      end

      self:UpdateGhost(plytr.HitPos, c, a)

      render.SetMaterial(laser)
      render.DrawBeam(spos, tr.HitPos, 5, 0, 0, c)

      -- Charge indicator
      local vm_ang = muzzle_angpos.Ang
      local cpos = muzzle_angpos.Pos + (vm_ang:Up() * -8) + (vm_ang:Forward() * -5.5) + (vm_ang:Right() * 0)
      local cang = vm:GetAngles()
      cang:RotateAroundAxis(cang:Forward(), 90)
      cang:RotateAroundAxis(cang:Right(), 90)
      cang:RotateAroundAxis(cang:Up(), 90)

      cam.Start3D2D(cpos, cang, 0.05)

      surface.SetDrawColor(255, 55, 55, 50)
      surface.DrawOutlinedRect(0, 0, 50, 15)

      local sz = 48
      local next = self.Weapon:GetNextPrimaryFire()
      local ready = (next - CurTime()) <= 0
      local frac = 1.0
      if not ready then
         frac = 1 - ((next - CurTime()) / self.Primary.Delay)
         sz = sz * math.max(0, frac)
      end

      surface.SetDrawColor(255, 10, 10, 170)
      surface.DrawRect(1, 1, sz, 13)

      surface.SetTextColor(255,255,255,15)
      surface.SetFont("Default")
      surface.SetTextPos(2,0)
      surface.DrawText(string.format("%.3f", around(frac)))

      surface.SetDrawColor(0,0,0, 80)
      surface.DrawRect(linex, 1, 3, 13)

      surface.DrawLine(1, liney, 48, liney)

      linex = linex + 3 > 48 and 0 or linex + 1
      liney = liney > 13 and 0 or liney + 1

      cam.End3D2D()

   end
end
