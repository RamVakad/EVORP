if CLIENT then return end

local plymeta = FindMetaTable( "Player" )
if not plymeta then Error("FAILED TO FIND PLAYER TABLE") return end

local oldStripWeapon = plymeta.StripWeapon
function plymeta:StripWeapon(class)
   oldStripWeapon(self, class)
   local weps = { }
   for wep in self.evorp._Weps:gmatch("[^%s]+") do table.insert(weps, wep) end
   for k, v in pairs( weps ) do
        if v == class then
          table.remove(weps, k)
        end
    end
    self.evorp._Weps = table.concat(weps, " ")
    GetDBConnection():Query("UPDATE players SET _Weps = '"..tmysql.escape(self.evorp._Weps).."' WHERE _SteamID = '"..tmysql.escape(self:SteamID()).."'")
end

local oldGive = plymeta.Give
function plymeta:Give(class)
   oldGive(self, class)
   local weps = { }
   for wep in self.evorp._Weps:gmatch("[^%s]+") do table.insert(weps, wep) end
   for k, v in pairs( weps ) do
        if v == class then
        	table.remove(weps, k)
        end
    end
    table.insert(weps, class)
    self.evorp._Weps = table.concat(weps, " ")
end