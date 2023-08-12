IncludeCS("attachment_vendor/configs/sh_attachment_vendor_config.lua");
IncludeCS("attachment_vendor/shared/sh_attachment_vendor_ext.lua");

include("attachment_vendor/configs/sv_attachment_vendor_config.lua");
include("attachment_vendor/server/sv_attachment_vendor_db.lua");
include("attachment_vendor/server/sv_attachment_vendor_locations.lua");
include("attachment_vendor/server/sv_attachment_vendor_net.lua");
include("attachment_vendor/server/sv_attachment_vendor_override.lua");
include("attachment_vendor/server/sv_attachment_vendor_ready.lua");

AddCSLuaFile("attachment_vendor/client/cl_attachment_vendor_net.lua");
AddCSLuaFile("attachment_vendor/client/cl_attachment_vendor_override.lua");
AddCSLuaFile("attachment_vendor/client/cl_attachment_vendor_ready.lua");

hook.Add("InitPostEntity", "AttachmentVendor:CheckAttachments", function()
   // OBSOLETE
   local obsoleteAttachments = "";
   do
      for k, v in pairs(ATTACHMENT_VENDOR.prices) do
         if (isCW2Attachment(k) == false && isFAS2Attachment(k) == false && isCW2Mag(k) == false && isARCCWAttachment(k) == false) then
            obsoleteAttachments = obsoleteAttachments .. k .. "\n";
         end
      end
   end
   
   // MISSING ATTACHMENTS
   local missingAttachments = "";
   do
      local atts = {};
      for k, v in pairs(istable(CustomizableWeaponry) && CustomizableWeaponry.registeredAttachmentsSKey || {}) do
         table.insert(atts, k);
      end
      
      for k, v in pairs(istable(FAS2_Attachments) && FAS2_Attachments || {}) do
         //table.insert(atts, k);
      end

      for k, v in pairs(istable(ArcCW) && ArcCW.AttachmentTable || {}) do
         table.insert(atts, k);
      end
      
      for k, v in pairs(atts) do
         if (isnumber(ATTACHMENT_VENDOR.prices[v]) == false) then
            missingAttachments = missingAttachments .. v .. "\n";
         end
      end
   end
   
   local str = "";
   
   if (string.len(obsoleteAttachments) > 0) then
      str = "The following attachments are no longer supported:\n" .. string.Trim(obsoleteAttachments);
   end
   
   if (string.len(missingAttachments) > 0) then
      if (string.len(str) > 0) then
         str = str .. "\n\n";
      end
      
      str = str .. "The following attachments are missing prices:\n" .. string.Trim(missingAttachments);
   end
   
   file.Write("attachment-vendor.txt", str);
end);