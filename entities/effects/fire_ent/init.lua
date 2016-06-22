///////////////////////////////
//  2009-2010 Pulsar Effect //
//    All rights reserved    //
///////////////////////////////
// This material may not be  //
//   reproduced, displayed,  //
//  modified or distributed  //
// without the express prior //
// written permission of the //
//   the copyright holder.   //
///////////////////////////////


local function collideCallback ( particle )
    particle:SetDieTime(10);
end


function EFFECT:Init( data )

    local Pos = data:GetOrigin() - Vector(0, 0, 5)
    local emitter = ParticleEmitter( Pos ) 

    local Trace = {};
    Trace.start = Pos;
    Trace.endpos = Pos + Vector(0, 0, 500)
    Trace.mask = MASK_VISIBLE;

    local TR = util.TraceLine(Trace);

    local p = emitter:Add( "sprites/flamelet"..tostring( math.random( 1, 5 ) ),Pos)
    if TR.Hit then
        p:SetVelocity(Vector(math.random(-30,30),math.random(-30,30), math.random(0, 70)))
    else
        p:SetVelocity(Vector(math.random(-30,-20),math.random(20,30), math.random(0, 70)))
    end

    p:SetDieTime(math.Rand(2, 3))
    p:SetStartAlpha(230)
    p:SetEndAlpha(0)
    p:SetStartSize(math.random(70, 80))
    p:SetEndSize(10)
    p:SetRoll( math.Rand( 0,10  ) )
    p:SetRollDelta(math.Rand( -0.2, 0.2 ))

    if TR.Hit and math.sin(CurTime() * 5) >= .5 then
        local p = emitter:Add("effects/extinguisher", Pos + Vector(math.random(-40,40),math.random(-40,40), math.random(50, 100)))
        p:SetVelocity(Vector(math.random(-20,20),math.random(-20,20), math.random(20, 40)))
        p:SetDieTime(20)
        p:SetStartAlpha(20)
        p:SetEndAlpha(0)
        p:SetStartSize(math.random(40, 50))
        p:SetEndSize(200)
        p:SetRoll( math.Rand( 0,10  ) )
        p:SetRollDelta(math.Rand( -0.2, 0.2 ));
    elseif TR.Hit and math.sin(CurTime() * 5) <= -.5 then
        local p = emitter:Add("effects/extinguisher", Pos + Vector(math.random(-40,40),math.random(-40,40), math.random(50, 100)))
        p:SetVelocity(Vector(math.random(-30,30),math.random(-30,30), math.random(0, 5)))
        p:SetDieTime(math.random(20, 30))
        p:SetStartAlpha(20)
        p:SetEndAlpha(0)
        p:SetStartSize(math.random(40, 50))
        p:SetEndSize(200)
        p:SetCollideCallback(collideCallback)
        p:SetCollide(true);
        p:SetBounce(15);
        p:SetRoll( math.Rand( 0,10  ) )
        p:SetRollDelta(math.Rand( -0.2, 0.2 ));
    end
end

function EFFECT:Think( )

    return false

end

function EFFECT:Render()


end
