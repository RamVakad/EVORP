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


include('shared.lua')

function ENT:Draw()
end

function PlayerCanSee(ent)    
    local tr = {};  
    tr.start = LocalPlayer():GetShootPos();
    tr.endpos = ent:GetPos() + Vector(0, 0, 5)
    tr.filter = {LocalPlayer(), ent};
    tr.mask = MASK_SHOT;    
    local trace = util.TraceLine(tr) ;
    if (trace.Fraction == 1) then 
        return true;
    else 
        return false; 
    end     
end


function ENT:Think ( )  
    --if !PlayerCanSee(self) then return false; end
    if self.LastEffect + 1 < CurTime() then
        self.LastEffect = CurTime();
        
        local effect = EffectData();
            effect:SetOrigin(self:GetPos());
        util.Effect("fire_ent", effect);
    end
    
    if self.LastPlayTime + self.InBetween < CurTime() then
        self.SoundEffect:Stop();
        self.SoundEffect:Play();
        self.LastPlayTime = CurTime();
    end
end

function ENT:Initialize ( ) 
    self.LastEffect = CurTime();
    
    self.SoundID = math.random(1, 2);
    
    if self.SoundID == 1 then
        self.SoundEffect = CreateSound(self, Sound('ambient/fire/fire_med_loop1.wav'));
        self.InBetween = 6.5;
    elseif self.SoundID == 2 then
        self.SoundEffect = CreateSound(self, Sound('ambient/fire/firebig.wav'));
        self.InBetween = 5;
    else
        self.SoundEffect = CreateSound(self, Sound('ambient/fire/fire_big_loop1.wav'));
        self.InBetween = 5;
    end
    
    self.LastPlayTime = 0;
end

function ENT:OnRemove ( )
    self.SoundEffect:Stop();
end
