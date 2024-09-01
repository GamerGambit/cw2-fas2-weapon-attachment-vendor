ATTACHMENT_VENDOR.db = {};

local persistent = ATTACHMENT_VENDOR.persistent;

function ATTACHMENT_VENDOR.db:init()
   if (persistent.enabled == false) then return; end
   assert(persistent.module == "sqlite", "Attachment Vendor module is unsupported.");
   
   if (persistent.module == "sqlite") then
      sql.Begin();
         sql.Query("CREATE TABLE IF NOT EXISTS attachment_vendor (`SteamID` char(20) NOT NULL, `AttachmentName` TEXT NOT NULL );");
      sql.Commit();
   else ---@TODO mysql
      -- NOP
   end
end

function ATTACHMENT_VENDOR.db:playerLoadAttachments(ply)
   if (persistent.enabled == false) then return; end
   
   local tbl = {};
   
   if (persistent.module == "sqlite") then
      sql.Begin();
         local res = sql.Query("SELECT AttachmentName FROM attachment_vendor WHERE SteamID = " .. sql.SQLStr(ply:SteamID()) .. ";");
         if (istable(res)) then
            for k,v in pairs(res) do
               table.insert(tbl, v.AttachmentName);
            end
         end
      sql.Commit();
      
      ply.attvend_pers = tbl;
   else ---@TODO mysql
      -- NOP
   end
   
   hook.Run("playerLoadedWeaponAttachments", ply, table.Copy(tbl));
end

function ATTACHMENT_VENDOR.db:playerAddAttachment(ply, atts)
   if (persistent.enabled == false) then return; end
   
   if (persistent.module == "sqlite") then
      sql.Begin();
         for k,v in pairs(atts) do
            if ((isCW2Mag(v) and ATTACHMENT_VENDOR.cw2Mags.ignoreAdd) or (isCW2Mag(v) == false and self:playerHasAttachment(ply, v))) then continue; end
            sql.Query("INSERT INTO attachment_vendor VALUES(" .. sql.SQLStr(ply:SteamID()) .. ", " .. sql.SQLStr(v) .. ");");
         end
      sql.Commit();
   else ---@TODO mysql
      -- NOP
   end
end

function ATTACHMENT_VENDOR.db:playerRemoveAttachments(ply, atts)
   if (persistent.enabled == false) then return; end
   
   if (persistent.module == "sqlite") then
      sql.Begin();
         for k,v in pairs(atts) do
            if (self:playerHasAttachment(ply, v) == false) then continue; end
            table.RemoveByValue(ply.attvend_pers, v);
            sql.Query("DELETE FROM attachment_vendor WHERE SteamID = " .. sql.SQLStr(ply:SteamID()) .. " AND AttachmentName = " .. sql.SQLStr(v) .. ";");
         end
      sql.Commit();
   else ---@TODO mysql
      -- NOP
   end
end

function ATTACHMENT_VENDOR.db:playerHasAttachment(ply, att)
   if (persistent.enabled == false) then return; end
   
   if (persistent.module == "sqlite") then
      sql.Begin();
         local res = sql.QueryValue("SELECT COUNT(*) FROM attachment_vendor WHERE SteamID = " .. sql.SQLStr(ply:SteamID()) .. " AND AttachmentName = " .. sql.SQLStr(att) .. ";");
      sql.Commit();
      
      return tonumber(res) ~= 0;
   else ---@TODO mysql
      -- NOP
   end
end

hook.Add("InitPostEntity", "AttachmentVendorInitDB", function()
   timer.Simple(0, function()
      ATTACHMENT_VENDOR.db:init();
   end);
end);

hook.Add("PlayerInitialSpawn", "AttachmentVendorLoadAttachments", function(ply)
   ATTACHMENT_VENDOR.db:playerLoadAttachments(ply);
end);

hook.Add("PlayerLoadout", "AttachmentVendorLoadout", function(ply)
   if (not ATTACHMENT_VENDOR.persistent.enabled) then return; end
   if (not ply.attvend_ready) then return; end
   
   timer.Simple(0, function()
      ATTACHMENT_VENDOR.cw2Mags.ignoreAdd = true;
      ply:giveWeaponAttachments(ply.attvend_pers);
      ATTACHMENT_VENDOR.cw2Mags.ignoreAdd = false;
   end);
end);
