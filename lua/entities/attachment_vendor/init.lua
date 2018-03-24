include("shared.lua");
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

util.AddNetworkString("attvend");

function ENT:Initialize()
   self:SetModel("models/props/de_nuke/NuclearTestCabinet.mdl");
   self:PhysicsInit(SOLID_VPHYSICS);
   self:SetMoveType(MOVETYPE_VPHYSICS);
   self:SetSolid(SOLID_VPHYSICS);
   self:SetUseType(SIMPLE_USE);
   self:GetPhysicsObject():EnableMotion(false);
   
   self.m_iHealth = 100;
   self:Setdestructible(true);
   self:Setdamaged(false);
   self:Setid("");
end

function ENT:Use(activator, caller)
   if (ATTACHMENT_VENDOR.playerCanUseVendor(activator, self)) then
      net.Start("attvend");
         net.WriteEntity(self);
      net.Send(activator);
   end
end

function ENT:OnTakeDamage(dmginfo)
   if (self:Getdestructible() == false) then return; end
   
   self.m_iHealth = self.m_iHealth - dmginfo:GetDamage() * 0.25;
   
   if (self.m_iHealth <= 0) then
      self:Remove();
      return;
   end
   
   self:Setdamaged(ATTACHMENT_VENDOR.malfunction.allow);
end

function ENT:OnRemove()
   local pos = self:GetPos();
   local effectdata = EffectData();
   effectdata:SetStart(pos);
   effectdata:SetOrigin(pos);
   effectdata:SetScale(1);
   util.Effect("Explosion", effectdata);
   
   if (IsValid(self:Getowning_ent())) then
      vendNotify(self:Getowning_ent(), NOTIFY_ERROR, 4, "Your Attachment Vendor has been destroyed!");
   end
end
