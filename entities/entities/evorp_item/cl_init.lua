--[[
Name: "cl_init.lua".
Product: "EvoRP (Roleplay)".
--]]

include("sh_init.lua")

-- This is called when the entity should draw.
function ENT:Draw() self.Entity:DrawModel(); end;
