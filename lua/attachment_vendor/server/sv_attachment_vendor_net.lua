util.AddNetworkString("attvend_notify");

NOTIFY_GENERIC = 0;
NOTIFY_ERROR = 1;
NOTIFY_UNDO = 2;
NOTIFY_HINT = 3;
NOTIFY_CLEANUP = 4;


function vendNotify(ply, t, l, m)
   net.Start("attvend_notify");
      net.WriteUInt(t, 8);
      net.WriteUInt(l, 8);
      net.WriteString(m);
   net.Send(ply);
end

local chanceTbl = {false, "free", "extra", "steal"};

net.Receive("attvend", function(l, p)
   local weptbl = weapons.Get(net.ReadString());
   local attname = net.ReadString();
   local ent = net.ReadEntity();
   
   if (IsValid(ent) == false or ent:GetClass() ~= "attachment_vendor") then return; end
   
   local atts = {attname};
   
   local malf = ent:Getdamaged() and ATTACHMENT_VENDOR.malfunction.allow and chance(ATTACHMENT_VENDOR.malfunction.chance);
   local func = malf and chanceTbl[math.random(#chanceTbl)];
   
   if (isstring(func) and chance(ATTACHMENT_VENDOR.malfunction[func .. "Chance"]) == false) then
      func = false;
   end
   
   -- if the vendor can give extra attachments, do it
   if (func == "extra") then
      vendNotify(p, NOTIFY_ERROR, 4, "The vendor has malfunctioned and given you some extra attachments.");
      
      for i = 1, ATTACHMENT_VENDOR.malfunction.extraMax do
         local att = getRandomAttachment(p, weptbl);
         table.insert(atts, att);
      end
   end
   
   local giveAtts = {};
   for k,v in pairs(atts) do
      if (isCW2Mag(v) == false and p:hasWeaponAttachment(v)) then continue; end
      
      table.insert(giveAtts, v);
   end
   
   if (#giveAtts == 0) then return; end
   local success, tbl = hook.Run("playerCanHaveAttachments", p, table.Copy(giveAtts));
   if (success == false) then return; end
   if (istable(tbl)) then
      giveAtts = tbl;
   end
   
   local price;

   if (attname == "buyAmmo") then
      assert(ATTACHMENT_VENDOR.ammo.sell, "Vendor config does not allow selling ammo.");
      price = ATTACHMENT_VENDOR.ammo.price;
   else
      price = getAttachmentPrice(p, attname, ent);
   end
   
   if (func == "free") then
      vendNotify(p, NOTIFY_ERROR, 4, "The vendor has malfunctioned and given you the attachment for free.");
      price = 0;
   end
   
   if (ATTACHMENT_VENDOR.playerCanAffordAttachment(p, attname, price) == false) then
      vendNotify(p, NOTIFY_ERROR, 4, "You cannot afford this attachment.");
      return;
   end
   
   ATTACHMENT_VENDOR.playerPurchasedAttachment(p, attname, price);
   
   if (func == "steal") then
      vendNotify(p, NOTIFY_ERROR, 4, "The vendor has malfunctioned and you have not received your attachment.");
      return;
   end
   
   local msg;
   if (attname == "buyAmmo") then
      msg = "ammo";
   else
      msg = "the " .. string.Trim(getAttachmentName(attname, weptbl));
   end
   
   if (price > 0) then
      vendNotify(p, NOTIFY_GENERIC, 4, "You have purchased " .. msg .. " for $" .. price);
   end
   
   if (attname == "buyAmmo") then
      p:GiveAmmo(weptbl.Primary.ClipSize, weptbl.Primary.Ammo);
      table.RemoveByValue(giveAtts, attname);
   end
   
   p:giveWeaponAttachments(giveAtts);
   
   if (IsValid(ent:Getowning_ent()) and p ~= ent:Getowning_ent() and price > 0) then
      local givePrice = ATTACHMENT_VENDOR.ownerPricePercentage(ent:Getowning_ent(), attname, price);
      local tax = price / givePrice;
      
      ent:Getowning_ent():addMoney(givePrice);
      vendNotify(ent:Getowning_ent(), NOTIFY_GENERIC, 4, "You have sold " .. msg .. " for $" .. price .. ((tax ~= 1) and " (" .. tax .. "% tax)" or ""));
   end
end);