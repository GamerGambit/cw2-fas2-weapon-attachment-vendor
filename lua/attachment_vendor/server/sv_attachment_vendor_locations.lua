local ids = {};

hook.Add("InitPostEntity", "AttachmentVendorLocations", function()
   if (istable(ATTACHMENT_VENDOR.locations)) then
      for k, v in pairs(ATTACHMENT_VENDOR.locations) do
         assert(isvector(v.pos), "Location MUST have a \"pos\" vector.");
         assert(isangle(v.ang), "Location MUST have an \"ang\" angle.");
         
         local ent = ents.Create("attachment_vendor");
         ent:SetPos(v.pos);
         ent:SetAngles(v.ang);
         ent:Spawn();
         
         if (isstring(v.id)) then
            ent:Setid(v.id);
         end
         
         if (isbool(v.destructible)) then
            ent:Setdestructible(v.destructible);
         end
      end
   end
end);