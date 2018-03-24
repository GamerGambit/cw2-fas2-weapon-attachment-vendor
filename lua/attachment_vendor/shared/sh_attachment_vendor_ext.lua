hook.Add("loadCustomDarkRPItems", "DRP:AddAttachmentVendor", function()
   DarkRP.createEntity("Attachment Vendor", {
      ent = "attachment_vendor",
      model = "models/props/de_nuke/NuclearTestCabinet.mdl",
      price = 5000,
      max = 2,
      cmd = "buyattachmentvendor",
      allowed = ATTACHMENT_VENDOR.darkrpAllowedJobs();
   });
end);

hook.Add("PhysgunPickup", "AttVend:PhysgunPickup", function(ply, ent)
   if (ent:GetClass() == "attachment_vendor") then
      if (ply:IsAdmin()) then
         return true;
      elseif (IsValid(ent:Getowning_ent()) && ply == ent:Getowning_ent()) then
         return true;
      else
         return false;
      end
   end
end);

function isCW2(base)
   if (istable(base) || (isstring(base) == false && IsValid(base) && base:IsWeapon())) then
      return tobool(base.CW20Weapon);
   elseif (isstring(base)) then
      local wepTbl = weapons.Get(base);
      if (istable(wepTbl) == false) then return false; end
      return tobool(wepTbl.CW20Weapon);
   end
   
   return false;
end

function isFAS2(base)
   if (istable(base) || (isstring(base) == false && IsValid(base) && base:IsWeapon())) then
      return tobool(base.IsFAS2Weapon);
   elseif (isstring(base)) then
      local wepTbl = weapons.Get(base);
      if (istable(wepTbl) == false) then return false; end
      return tobool(wepTbl.IsFAS2Weapon);
   end
   
   return false;
end

function isCW2Attachment(att)
   if (istable(CustomizableWeaponry) == false) then return false; end
   return istable(CustomizableWeaponry.registeredAttachmentsSKey[att]);
end

function isCW2Mag(att)
   if (ATTACHMENT_VENDOR.cw2Mags.enable != true) then return false; end
   if (istable(CustomizableWeaponry) == false) then return false; end
   if (istable(CustomizableWeaponry.magSystem) == false) then return false; end
   return isstring(CustomizableWeaponry.magSystem.magTypes[att]);
end

function isFAS2Attachment(att)
   if (istable(FAS2_Attachments) == false) then return false; end
   return istable(FAS2_Attachments[att]);
end

function getAttachmentName(attname)
   if (isCW2Attachment(attname)) then
      return CustomizableWeaponry.registeredAttachmentsSKey[attname].displayName;
   elseif (isFAS2Attachment(attname)) then
      return FAS2_Attachments[attname].namefull;
   elseif (isCW2Mag(attname)) then
      return CustomizableWeaponry.magSystem.magTypes[attname];
   end
   
   ErrorNoHalt(string.format("[Attachment Vendor] Invalid attachment (%s).\n", tostring(attname)));
   return "";
end

local msg = "Attachment Vendor: A price of $%d is being used for invalid attachment \"%s\".";
function getAttachmentPrice(ply, attname, ent)
   local price = ATTACHMENT_VENDOR.prices[attname];
   
   if (isnumber(price) == false) then
      local str = Format(msg, ATTACHMENT_VENDOR.defaultAttachmentPrice, attname);
      if (SERVER) then
         print(str);
      else
         if (ATTACHMENT_VENDOR.notifyPlayersOfInvalidAttachments) then
            ply:ChatPrint(str);
         end
      end
      
      price = 100;
   end
   
   return ATTACHMENT_VENDOR.getAttachmentPrice(ply, price, ent);
end

function chance(percent)
   if (percent == false) then return false; end
   if (percent == true) then return true; end
   if (percent == 0) then return false; end
   if (percent == 100) then return true; end
   
   return math.Rand(0, 100) <= percent;
end

local PlayerMeta = FindMetaTable("Player");
if (SERVER) then
   function getRandomAttachment(ply, wep)
      if (isCW2(wep) == false && isFAS2(wep) == false) then return nil; end
      
      local atts = {};
      for k, v in pairs(wep.Attachments) do
         for _, a in pairs(v.atts) do
            if (ply:hasWeaponAttachment(a, wep)) then continue; end
            table.insert(atts, a);
         end
      end
      
      if (isCW2Mag(wep.magType)) then
         table.insert(atts, wep.magType);
      end
      
      return table.Random(atts);
   end

   function PlayerMeta:giveWeaponAttachments(atts, notifyOrAmount, dontNetwork)
      if (isstring(atts)) then
         if (isCW2Mag(atts)) then
            local newAtts = {};
            for i = 1, notifyOrAmount do
               table.insert(newAtts, atts);
            end
            atts = newAtts;
         else
            atts = {atts};
         end
      end
      
      assert(istable(atts), "Attachments expected to be table or string.");
      
      local success, tbl = hook.Run("playerCanHaveAttachments", self, table.Copy(atts));
      if (success == false) then return false; end
      if (istable(tbl)) then
         atts = tbl;
      end
      
      for k,v in pairs(atts) do
         if (isCW2Mag(v) == false && self:hasWeaponAttachment(v)) then continue; end
         
         if (isCW2Attachment(v)) then
            if (ATTACHMENT_VENDOR.override.enable) then
               ATTACHMENT_VENDOR.override.CWGiveAttachments(self, {v}, !notifyOrAmount);
            else
               CustomizableWeaponry.giveAttachments(self, {v}, !notifyOrAmount);
            end
         elseif (isCW2Mag(v)) then
            if (ATTACHMENT_VENDOR.override.enable) then
               ATTACHMENT_VENDOR.override.CW2AddMagazine(self, v, 1, dontNetwork);
            else
               self:cwAddMagazine(v, 1, dontNetwork);
            end
         elseif (isFAS2Attachment(v)) then
            if (ATTACHMENT_VENDOR.override.enable) then
               ATTACHMENT_VENDOR.override.FASPickupAttachment(self, v, !notifyOrAmount);
            else
               self:FAS2_PickUpAttachment(v, !notifyOrAmount);
            end
         else
            assert(false, string.format("Invalid attachment (%s)", tostring(v)));
         end
      end
      
      ATTACHMENT_VENDOR.db:playerAddAttachment(self, atts);
      hook.Run("playerGivenAttachments", self, atts);
      return true;
   end

   function PlayerMeta:removeWeaponAttachments(atts, networkOrAmount)
      if (isstring(atts)) then
         if (isCW2Mag(atts)) then
            local newAtts = {};
            for i = 1, networkOrAmount do
               table.insert(newAtts, atts);
            end
            atts = newAtts;
         else
            atts = {atts};
         end
      end
      
      assert(istable(atts), "Attachments expected to be table or string.");
      
      local success, tbl = hook.Run("playerCanRemoveAttachments", self, table.Copy(atts));
      if (success == false) then return; end
      if (istable(tbl)) then
         atts = tbl;
      end
      
      for k,v in pairs(atts) do
         if (self:hasWeaponAttachment(v) == false) then continue; end
         
         if (isCW2Attachment(v)) then
            if (ATTACHMENT_VENDOR.override.enable) then
               ATTACHMENT_VENDOR.override.CWRemoveAttachment(CustomizableWeaponry, self, v, networkOrAmount);
            else
               CustomizableWeaponry:removeAttachment(self, v, networkOrAmount);
            end
         elseif (isCW2Mag(v)) then
            if (ATTACHMENT_VENDOR.override.enable) then
               ATTACHMENT_VENDOR.override.CW2RemoveMagazine(self, v, 1);
            else
               self:cwRemoveMagazine(self, v, 1);
            end
         elseif (isFAS2Attachment(v)) then
            if (ATTACHMENT_VENDOR.override.enable) then
               ATTACHMENT_VENDOR.override.FASRemoveAttachment(self, v);
            else
               self:FAS2_RemoveAttachment(v);
            end
         else
            assert(false, string.format("Invalid attachment (%s)", tostring(v)));
         end
      end
      
      ATTACHMENT_VENDOR.db:playerRemoveAttachments(self, atts);
      hook.Run("playerRemovedAttachments", self, atts);
   end
end

function PlayerMeta:hasWeaponAttachment(att)
   if (isCW2Attachment(att)) then
      return self.CWAttachments[att];
   elseif (isCW2Mag(att)) then
      return isnumber(self.cwMagazines[att]) && self.cwMagazines[att] > 0;
   elseif (isFAS2Attachment(att)) then
      if (SERVER) then
         return table.HasValue(self.FAS2Attachments, att);
      else
         return table.HasValue(FAS2AttOnMe, att);
      end
   end
   
   return false;
end

function GetStaticInfo()
   //return {{ user_id | 76561198025069739 }};
end