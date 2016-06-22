if SERVER then
   AddCSLuaFile("shared.lua")
end


ENT.Type = "anim"
ENT.Model = Model("models/Items/combine_rifle_ammo01.mdl")

ENT.Stuck = false
ENT.Weaponised = false

ENT.PunchMax = 6
ENT.PunchRemaining = 6


function ENT:Initialize()
   self.Entity:SetModel(self.Model)

   self.Entity:SetSolid(SOLID_NONE)

   if SERVER then
      self:SetGravity(0.4)
      self:SetFriction(1.0)
      self:SetElasticity(0.45)

      self.Entity:NextThink(CurTime() + 1)
   end

   self:SetColor(Color(55, 50, 250, 255))

   self.Stuck = false
   self.PunchMax = 6
   self.PunchRemaining = self.PunchMax
end

function ENT:StickTo(ent)
   if (not IsValid(ent)) or ent:IsPlayer() or ent:GetMoveType() != MOVETYPE_VPHYSICS then return false end

   local phys = ent:GetPhysicsObject()
   if (not IsValid(phys)) or (not phys:IsMoveable()) then return false end

--   local norm = self:GetAngles():Up()

   self:SetParent(ent)

   ent:SetPhysicsAttacker(self:GetOwner())
   ent:SetNWBool("punched", true)
   self.PunchEntity = ent

   self:StartEffects()

   self.Stuck = true

   return true
end

function ENT:OnRemove()
   if IsValid(self.BallSprite) then
      self.BallSprite:Remove()
   end

   if IsValid(self.PunchEntity) then
      self.PunchEntity:SetPhysicsAttacker(self.PunchEntity)
      self.PunchEntity:SetNWBool("punched", false)
   end
end

function ENT:StartEffects()
   -- MAKE IT PRETTY

   local sprite = ents.Create("env_sprite")
   if IsValid(sprite) then
--      local angpos = self:GetAttachment(ball)
      -- sometimes attachments don't work (Lua-side) on dedicated servers,
      -- so have to fudge it
      local ang = self:GetAngles()
      local pos = self:GetPos() + self:GetAngles():Up() * 6
      sprite:SetPos(pos)
      sprite:SetAngles(ang)
      sprite:SetParent(self.Entity)

      sprite:SetKeyValue("model", "sprites/combineball_glow_blue_1.vmt")
      sprite:SetKeyValue("spawnflags", "1")
      sprite:SetKeyValue("scale", "0.25")
      sprite:SetKeyValue("rendermode", "5")
      sprite:SetKeyValue("renderfx", "7")

      sprite:Spawn()
      sprite:Activate()

      self.BallSprite = sprite

   end

   local effect = EffectData()
   effect:SetStart(self:GetPos())
   effect:SetOrigin(self:GetPos())
   effect:SetNormal(self:GetAngles():Up())
   util.Effect("ManhackSparks", effect, true, true)

   if SERVER then
      local ball = self:LookupAttachment("attach_ball")
      util.SpriteTrail(self.Entity, ball, Color(250, 250, 250), false, 30, 0, 1, 0.07, "trails/physbeam.vmt")
   end
end

if SERVER then
   local diesound = Sound("weapons/physcannon/energy_disintegrate4.wav")
   local punchsound = Sound("weapons/ar2/ar2_altfire.wav")

   function ENT:Think()
      if not self.Stuck then return end

      if self.PunchRemaining <= 0 then
         self:Remove()
      else
         self.PunchRemaining = self.PunchRemaining - 1

         if IsValid(self.PunchEntity) and self.PunchEntity:IsVehicle() then
            timer.Create("EMP"..math.random(0,1000), .1, 80, function()
               if not (IsValid(self.PunchEntity)) then return end
                 local edata = EffectData()
                 edata:SetEntity(self.PunchEntity)
                 edata:SetScale(20)
                 edata:SetMagnitude(20)
                 util.Effect("TeslaHitBoxes", edata)
                 self.PunchEntity:EmitSound("Weapon_StunStick.Activate")

            end)
                  self.PunchEntity:Fire("TurnOff", "" , 0)
                  self.PunchEntity._Off = true
         end
      end

      local delay = math.max(0.1, self.PunchRemaining / self.PunchMax) * 10
      self.Entity:NextThink(CurTime() + delay)
      return true
   end
   
end