///////////////////////////////
// © 2009-2010 Pulsar Effect //
//    All rights reserved    //
///////////////////////////////
// This material may not be  //
//   reproduced, displayed,  //
//  modified or distributed  //
// without the express prior //
// written permission of the //
//   the copyright holder.   //
///////////////////////////////



AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

local Distance = 60
local MaxFires = 15;
local NumberOfFires = 0;

function ENT:Initialize()
    self.Entity:SetModel("models/props_junk/wood_pallet001a.mdl");

    self.Entity:SetMoveType( MOVETYPE_NONE )
    self.Entity:SetSolid( SOLID_NONE )
    self.Entity:SetAngles(Angle(0, 0, 0));
    self.Entity:SetPos(self:GetPos() + Vector(0, 0, 10));
    
    self.LastSpread = CurTime();
    self.SpawnTime = CurTime();
    
    NumberOfFires = NumberOfFires + 1;
    
    self.LastDamage = CurTime();
    self.ExtinguisherLeft = math.random(70, 100);
    self.Spores = 0;
    self.HealthAdd = CurTime();
    
    self:DrawShadow(false);
    self.IsAlive = true;
    ParticleEffectAttach("fire_large_01", PATTACH_ABSORIGIN_FOLLOW, self, 0)
end

function ENT:SpreadFire()
    if NumberOfFires >= MaxFires then return false; end
    // Try 25 times to spread.  
    for i = 1, 25 do
        local RandomStart = self:GetPos() + Vector(math.Rand(-1, 1) * Distance, math.Rand(-1, 1) * Distance, 50);
        local UsStart = self:GetPos() + Vector(0, 0, 10);
        
        // trace to the random spot from us
        local Trace = {};
        Trace.start = UsStart;
        Trace.endpos = RandomStart;
        Trace.filter = self.Entity;
        Trace.mask = MASK_OPAQUE;
        
        local TR1 = util.TraceLine(Trace);
        
        // trace back to make sure theres nothing there
            
        local Trace2 = {};
        Trace2.start = RandomStart;
        Trace2.endpos = UsStart;
        Trace2.filter = self.Entity;
        Trace2.mask = MASK_OPAQUE;
            
        local TR2 = util.TraceLine(Trace2);
        
        if (TR1.Hit and TR2.Hit) or (!TR1.Hit and !TR2.Hit) then
            -- trace down to make sure it's not a sheer cliff, or the like
            
            local TrStart = RandomStart;
            local TrEnd = TrStart - Vector(0, 0, 100);
            
            local Trace = {};
            Trace.start = TrStart;
            Trace.endpos = TrEnd;
            Trace.filter = self.Entity;
                
            local TraceResults = util.TraceLine(Trace);
                
            if TraceResults.HitWorld then
                if util.IsInWorld(TraceResults.HitPos) then             
                   --[[ if  TraceResults.MatType == MAT_DIRT or 
                        TraceResults.MatType == MAT_WOOD or
                        TraceResults.MatType == MAT_COMPUTER or
                        TraceResults.MatType == MAT_FOLIAGE or
                        TraceResults.MatType == MAT_PLASTIC or
                        TraceResults.MatType == MAT_SAND or
                        TraceResults.MatType == MAT_SLOSH or
                        TraceResults.MatType == MAT_TILE or
                        TraceResults.MatType == MAT_VENT then]]

                        local NearbyEnts = ents.FindInSphere(TraceResults.HitPos, Distance * .5);
                                    
                        local NearShroom = false;
                        for k, v in pairs(NearbyEnts) do
                            if v:GetClass() == 'evorp_fire' then
                                NearShroom = true;
                            end
                        end
                                
                        if !NearShroom then
                            local Shroom = ents.Create('evorp_fire');
                            Shroom:SetPos(TraceResults.HitPos);
                            Shroom:Spawn();
                            self.Spores = self.Spores + 1;
                            return;
                        end
                    end
               -- end
            end
        end
    end
end

function ENT:KillFire ( ) 
    if self.IsAlive then
        NumberOfFires = NumberOfFires - 1;
        self.IsAlive = false;
    end
    self:Remove();
end

function ENT:HitByExtinguisher ( ByWho, IsHose )
    if IsHose then
        self.ExtinguisherLeft = self.ExtinguisherLeft - 10;
    else
        self.ExtinguisherLeft = self.ExtinguisherLeft - 1;
    end
    
    if self.ExtinguisherLeft <= 0 then
        if ByWho and ByWho:IsValid() and ByWho:IsPlayer() then        
            if IsHose then
                evorp.player.giveMoney(ByWho, 5);
                evorp.player.notify(ByWho, "You received $5.", 0);
            else
                evorp.player.giveMoney(ByWho, 10);
                evorp.player.notify(ByWho, "You received $10.", 0);
            end
        end
        self:KillFire();
    end
end

function ENT:Think ( )
    if (CurTime() - self.SpawnTime > (300*8) ) then self:KillFire(); end
    if self.Spores >= 25 then self:KillFire(); return false; end
    if self:WaterLevel() > 0 then self:KillFire(); return false; end

    local IsStorming = GAMEMODE.CloudCondition == CLOUDS_STORMY || GAMEMODE.CloudCondition == CLOUDS_STORMY_SEVERE
    local IsRaining = IsStorming || GAMEMODE.CloudCondition == CLOUDS_STORMY_LIGHT

    local Trace = {};
    Trace.start = self:GetPos();
    Trace.endpos = self:GetPos() + Vector(0, 0, 500)
    Trace.mask = MASK_VISIBLE;
    Trace.filter = self;
    
    local TR = util.TraceLine(Trace);
    local IsOutdoors = TR.HitPos == Trace.endpos;
        
    if IsStorming and IsOutdoors then
        self:HitByExtinguisher();
    else
        if self.HealthAdd + 10 < CurTime() and (!IsRaining or !IsOutdoors) then 
            self.HealthAdd = CurTime(); 
            self.ExtinguisherLeft = math.Clamp(self.ExtinguisherLeft + 1, 0, 120); 
        end

        if (self.LastSpread + 10 < CurTime() and (!IsRaining or !IsOutdoors)) or (self.LastSpread + 60 < CurTime() and (IsRaining and IsOutdoors)) then
            self.Spores = self.Spores + 1;
            self:SpreadFire();
            
            self.LastSpread = CurTime();
        end
    end
    
    if self.LastDamage + .1 < CurTime() then
        local CloseEnts = ents.FindInSphere(self:GetPos(), 70);
        
        
        self.LastDamage = CurTime();
        
        for k , v in pairs(CloseEnts) do
            if (v:GetClass() == 'prop_physics' or v:GetClass() == 'ent_item' or v:GetClass() == 'ent_prop_item' or v:GetClass() == "prop_clock" or v:GetClass() == "ent_pot") and !v:GetTable().UnBurnable then
                v:GetTable().FireDamage = v:GetTable().FireDamage or 60;
                v:GetTable().FireDamage = v:GetTable().FireDamage - 1;
                
                if v:GetTable().FireDamage == 0 then
                    if v:GetModel() == 'models/props_junk/propanecanister001a.mdl' then
                        WorldSound(Sound('ambient/explosions/explode_' .. math.random(1, 7) .. '.wav'), v:GetPos(), 150, 255);
                        
                        for i = 1, 10 do
                            self:SpreadFire();
                        end
                    end
                    
                    if (v.costItem && v:GetTable().Owner) then
                        v:GetTable().Owner.theirNumItems = v:GetTable().Owner.theirNumItems - 1;
                    end
                    
                    v:Remove();
                else
                    if !v:IsOnFire() then
                        v:Ignite(60, 100);

                    end
                    
                    local C = (v:GetTable().FireDamage / 60) * 255;
                    v:SetColor(C, C, C, 255);
                end
            elseif v:IsPlayer() and v:Alive() and v:GetPos():Distance(self:GetPos()) < 70 then
                if v:Team() != TEAM_FIREMAN then
                    v:TakeDamage(2, v, self);
                    
                    if v:GetPos():Distance(self:GetPos()) < 50 and v:Team() != TEAM_FIREMAN then
                        v:TakeDamage(15, v, self);
                    end
                else
                    v:GetTable().LastFireDamage = v:GetTable().LastFireDamage or 0;
                    
                    if v:GetTable().LastFireDamage + 1 < CurTime() then
                        v:TakeDamage(1, v, self);
                        v:GetTable().LastFireDamage = CurTime();
                    end
                end
            end
        end
    end
end

function ENT:Use( activator, caller )

end
