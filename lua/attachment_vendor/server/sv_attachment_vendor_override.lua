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
end);