--[[CarTimerIsOn = false;

surface.CreateFont( "carinfo", {font="Museo Sans 500", size=16, weight=60,shadow=false} )

hook.Add("HUDPaint", "carstuff", function()
    local veh = LocalPlayer():GetVehicle() or {}
    local rech = 0
    local speed = 0
    
    if IsValid( veh ) and veh:GetClass() == "prop_vehicle_jeep" then
        local vehicleVel = veh:GetVelocity():Length()
        local vehicleConv = -1
        local terminal = 0
           
        terminal = math.Clamp(vehicleVel/2000, 0, 1)
        vehicleConv = math.Round(vehicleVel / 10)
        
        speed = math.Clamp(vehicleConv, 0, 320) //  Maximal Display KM/H = 320km/h
        
        local w, h = 500, 35
        local w2, h2 = 492/320*speed, 27
        local roundrech = 4/30*math.Clamp(speed, 0.1, 30)
        
        --draw.RoundedBox( 4, (ScrW()/2) - (w/2), ScrH() - ( 25 + h ), w, h, Color( 0, 0, 0, 240 ) )
        --draw.RoundedBox( roundrech, (ScrW()/2) - (w2/2), ScrH() - ( 25 + h2 + 4 ), w2, h2, Color( 200, 0, 0, 240 ) )
        local speed = math.abs(math.floor(veh:GetVelocity():Length()/ 25.33))
        if not (CarTimerIsOn) then
             CarTimerIsOn = true;
            timer.Simple( .25, function()
                    if (IsValid(veh)) then
                        local newspeed = math.abs(math.floor(veh:GetVelocity():Length()/ 25.33))
                        if (speed - newspeed > 20) then
                            net.Start("veh_col")
                            net.WriteInt((speed - newspeed)/3, 32) --4 Bytes
                            net.SendToServer();
                        end
                    end
                    CarTimerIsOn = false;
                end)
         end
        local speedtext = "SPEED: "..speed .. " EMPH"
        local font = "carinfo"
        surface.SetFont( font )
        local len = surface.GetTextSize( speedtext )
        local text = "";
        if (veh:GetNetworkedBool("NeedsFix")) then
            text = "This vehicle needs to be repaired.";
        end
        if (veh:GetNetworkedBool("HotWired")) then
                text = "This vehicle is hotwired and needs a repair."
        end
        if (text != "") then
             draw.SimpleTextOutlined( text, font, ((ScrW()/2) - len/2), ScrH() - 52, Color( 255, 255, 255, 200 ), false, false, 1, Color( 0, 0, 0, 200 ) )
        end
        if (CurTime() >= LocalPlayer():GetNetworkedInt("nextHyd")) and (LocalPlayer():GetNetworkedBool("evorp_Donator") or LocalPlayer():IsAdmin()) then
                 draw.SimpleTextOutlined( "NOS Available", font, ((ScrW()/2) - len/2) + 120, ScrH() - 36, Color( 255, 255, 255, 200 ), false, false, 1, Color( 0, 0, 0, 200 ) )
        end
        --draw.SimpleTextOutlined( speedtext, font, (ScrW()/2) - len/2, ScrH() - 18, Color( 255, 255, 255, 200 ), false, false, 1, Color( 0, 0, 0, 200 ) )
        draw.SimpleTextOutlined( "FUEL: "..veh:GetNetworkedInt("fuel").."%", font, (ScrW()/2) - len/2, ScrH() - 36, Color( 255, 255, 255, 200 ), false, false, 1, Color( 0, 0, 0, 200 ) )
        local lockunlock = "Unlocked"
        if (veh:GetNetworkedBool("locked")) then lockunlock = "Locked" end
        draw.SimpleTextOutlined( lockunlock, font, ((ScrW()/2) - len/2) + 120, ScrH() - 18, Color( 255, 255, 255, 200 ), false, false, 1, Color( 0, 0, 0, 200 ) )
    end
end)
]]--