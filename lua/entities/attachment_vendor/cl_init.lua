surface.CreateFont("HUDNumber5", {font = "Trebuchet MS", size = 45, weight = 900});

include ("shared.lua");

function ENT:Initialize()
   self.m_iLastSpark = CurTime();
   self.m_iNextSparkTime = 0;
end

function ENT:Draw()
   self:DrawModel();
   
   local pos = self:LocalToWorld(self:OBBCenter());
   local ang = self:GetAngles();
   
   ang:RotateAroundAxis(ang:Forward(), 90);
   ang:RotateAroundAxis(ang:Right(), -90);
   
   local owner = IsValid(self:Getowning_ent()) and self:Getowning_ent():Nick() .. "'s " or "";
   
   cam.Start3D2D(pos + ang:Right() * -47 + ang:Up() * 8.5, ang, 0.15);
      draw.SimpleTextOutlined(owner .. "Attachment Vendor", "HUDNumber5", 0, 0, color_white, draw.TEXT_ALIGN_CENTER, draw.TEXT_ALIGN_CENTER, 1, color_black);
   cam.End3D2D();
   
   ang:RotateAroundAxis(ang:Forward(), -90);
   ang:RotateAroundAxis(ang:Right(), -90);
   
   cam.Start3D2D(pos + ang:Up() * 13, ang, 0.22);
      draw.SimpleText(owner .. "Attachment Vendor", "HUDNumber5", 0, 0, color_white, draw.TEXT_ALIGN_CENTER, draw.TEXT_ALIGN_CENTER);
   cam.End3D2D();
   
   ang:RotateAroundAxis(ang:Forward(), 180);
   
   cam.Start3D2D(pos + ang:Up() * 13.5, ang, 0.22);
      draw.SimpleText(owner .. "Attachment Vendor", "HUDNumber5", 0, 0, color_white, draw.TEXT_ALIGN_CENTER, draw.TEXT_ALIGN_CENTER);
   cam.End3D2D();
end

function ENT:Think()
   if (self:Getdamaged() == false or CurTime() < self.m_iLastSpark + self.m_iNextSparkTime) then return; end
   
   local ed = EffectData();
   ed:SetOrigin(self:LocalToWorld(self:OBBCenter()));
   util.Effect("cball_bounce", ed);
   self:EmitSound("ambient.electrical_zap_" .. math.random(1, 3));
   
   self.m_iLastSpark = CurTime();
   self.m_iNextSparkTime = math.random(1, 5);
end
