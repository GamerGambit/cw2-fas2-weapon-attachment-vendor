hook.Add("Initialize", "AttachmentVendorOverride", function()
   if (not ATTACHMENT_VENDOR.override.enable) then return; end
   
   -- CW2
   if (istable(CustomizableWeaponry)) then
      ATTACHMENT_VENDOR.override.CWGiveAttachments = CustomizableWeaponry.giveAttachments;
      CustomizableWeaponry.giveAttachments = function(ply, tbl, noNotify)
         ply:giveWeaponAttachments(tbl, not noNotify);
      end;
      
      ATTACHMENT_VENDOR.override.CWRemoveAttachment = CustomizableWeaponry.removeAttachment;
      function CustomizableWeaponry.removeAttachment(cw, ply, att, noNetwork)
         ply:removeWeaponAttachments(att, not noNetwork);
      end;
   end
   
   local PlayerMeta = FindMetaTable("Player");
   
   -- CW2Mag
   if (ATTACHMENT_VENDOR.cw2Mags.enable) then
      ATTACHMENT_VENDOR.override.CW2AddMagazine = PlayerMeta.cwAddMagazine;
      PlayerMeta.cwAddMagazine = function(self, mag, amt, noNetwork)
         self:giveWeaponAttachments(mag, amt, not noNetwork);
      end;
      
      ATTACHMENT_VENDOR.override.CW2RemoveMagazine = PlayerMeta.cwRemoveMagazine;
      PlayerMeta.cwRemoveMagazine = PlayerMeta.removeWeaponAttachments;
   end
   
   -- FAS2
   if (istable(FAS2_Attachments)) then
      ATTACHMENT_VENDOR.override.FASPickupAttachment = PlayerMeta.FAS2_PickUpAttachment;
      PlayerMeta.FAS2_PickUpAttachment = function(self, att, noNotify)
         self:giveWeaponAttachments(att, not noNotify);
      end;
      
      ATTACHMENT_VENDOR.override.FASRemoveAttachment = PlayerMeta.FAS2_RemoveAttachment;
      PlayerMeta.FAS2_RemoveAttachment = PlayerMeta.removeWeaponAttachments;
   end

   -- ArcCW
   if (istable(ArcCW)) then
      ATTACHMENT_VENDOR.override.ARCCWPlayerGiveAtt = ArcCW.PlayerGiveAtt;
      function ArcCW.PlayerGiveAtt(this, ply, att, amt)
         ply:giveWeaponAttachments(att, amt, false); -- `false` will force these attachments to be networked
      end
      
      ATTACHMENT_VENDOR.override.ARCCWPlayerTakeAtt = ArcCW.PlayerTakeAtt;
      function ArcCW.PlayerTakeAtt(this, ply, att, amt)
         ply:removeWeaponAttachments(att, amt);
      end
   end

   -- Luctus Medic revive
   if (istable(LUCTUS_MEDIC_HITGROUPS)) then -- Luctus Medical has individual globals for each config so check if an arbitrary global exists
      ATTACHMENT_VENDOR.override.LuctusMedicReturnWeapons = LuctusMedicReturnWeapons;
      function LuctusMedicReturnWeapons(ply)
         ATTACHMENT_VENDOR.override.LuctusMedicReturnWeapons(ply)

         -- No death attachments so do nothing
         if (not istable(ply.deathAttachments) or #ply.deathAttachments == 0) then return end

         -- give normal weapon attachments
         ply:giveWeaponAttachments(ply.deathAttachments, false, false); -- The first `false` makes it not notify the player that they received the attachments. The second will force these attachments to be networked

         -- give cw2.0 mags
         for mag, count in pairs(ply.deathCW2Mags) do
            ply:giveWeaponAttachments(mag, count, false) -- `false` will force these to be networked
         end

         ply.deathAttachments = nil
         ply.deathCW2Mags = nil
      end

      hook.Add("PlayerDeath","AttVend:LuctusMedicAttachments",function (ply)
         local attDict = {}; -- attachment name : true pairs to make sure we dont double up on attachments. `table.HasValue` might be nicer but this is significantly quicker
         ply.deathAttachments = {} -- attachment name values
         ply.deathCW2Mags = {} -- mag name : count pairs

         -- CW2.0
         for att,_ in pairs(ply.CWAttachments or {}) do
            if (not attDict[att]) then
               table.insert(ply.deathAttachments, att)
            end
         end

         -- CW2.0 Mag System
         for mag, count in pairs(ply.cwMagazines or {}) do
            ply.deathCW2Mags[mag] = ply.deathCW2Mags[mag] or 0;
            ply.deathCW2Mags[mag] = ply.deathCW2Mags[mag] + count
         end

         -- FAS2
         for _, att in pairs(ply.FAS2Attachments or {}) do
            if (not attDict[att]) then
               table.insert(ply.deathAttachments, att)
            end
         end

         -- ArcCW
         for att, _ in pairs(ply.ArcCW_AttInv or {}) do
            if (not attDict[att]) then
               table.insert(ply.deathAttachments, att)
            end
         end
      end)
   end
end);