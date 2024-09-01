surface.CreateFont("AttachmentVendorTitle", {
   font = "Trebuchet MS",
   size = 24,
   weight = 700,
   antialias = true,
   additive = false
});

net.Receive("attvend_notify", function(l)
   local t = net.ReadUInt(8);
   local l = net.ReadUInt(8);
   local s = net.ReadString();
   
   notification.AddLegacy(s, t, l);
   surface.PlaySound("buttons/button15.wav");
   print(s);
end);

local blur = Material("pp/blurscreen");
net.Receive("attvend", function(l)
   local ent = net.ReadEntity();
   
   local frame = vgui.Create("DFrame");
   frame:SetTitle("Attachment Vendor");
   frame:SetSize(512, 512);
   frame:Center();
   frame:MakePopup(true);
   frame.lblTitle:SetFont("AttachmentVendorTitle");
   frame.Paint = function(this, w, h)
         local x, y = this:LocalToScreen(0, 0);
         
         surface.SetDrawColor(color_white);
         surface.SetMaterial(blur);

         for i = 1, 3 do
            blur:SetFloat("$blur", (i / 3) * 6);
            blur:Recompute();

            render.UpdateScreenEffectTexture();
            surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH());
         end
         
         surface.SetDrawColor(color_black);
         surface.DrawOutlinedRect(0, 0, w, h);
   end;
   
   local hdiv = vgui.Create("DHorizontalDivider", frame);
   hdiv:Dock(FILL);
   hdiv:SetLeftWidth(200);
   hdiv:SetDividerWidth(4);
   
   local attinfopnl = vgui.Create("DPanel");
   
   local attnameprice = vgui.Create("DLabel", attinfopnl);
   attnameprice:SetText("Select a weapon attachment");
   attnameprice:Dock(TOP);
   attnameprice:SetContentAlignment(5);
   attnameprice:SetTextColor(color_black);

   local attimg = vgui.Create("DImage", attinfopnl);
   attimg:Dock(FILL);
   attimg:Hide();
   
   local attmodel = vgui.Create("DAdjustableModelPanel", attinfopnl);
   attmodel:Dock(FILL);
   attmodel.LayoutEntity = function(this) end;
   local oldAdjMdlPnlFPC = attmodel.FirstPersonControls;
   attmodel.FirstPersonControls = function(this)
      if (IsValid(this.Entity) == false) then return; end
      oldAdjMdlPnlFPC(this);
   end;
   attmodel:Hide();
   
   local buy = vgui.Create("DButton", attinfopnl);
   buy:Dock(BOTTOM);
   buy:DockMargin(5, 5, 5, 5);
   buy:Hide();
   
   attinfopnl.Setup = function(this, attname, modelOrMaterial, class)
      local isAmmo = attname == "buyAmmo";
      local price;
      local name;

      if (isAmmo) then
         price = ATTACHMENT_VENDOR.ammo.price;
         name = "Ammo";
      else
         price = getAttachmentPrice(LocalPlayer(), attname, ent);
         name = getAttachmentName(attname);
      end
      
      local pricestr = tostring(price);
      attnameprice:SetText(name .. " - $" .. pricestr);

      if (type(modelOrMaterial) == "IMaterial") then
         attimg:SetMaterial(modelOrMaterial);
         attimg:Show();
         attmodel:Hide();
      elseif (type(modelOrMaterial) == "string") then
         attmodel:SetModel(modelOrMaterial);
         
         local tab = PositionSpawnIcon(attmodel:GetEntity(), attmodel:GetEntity():GetPos());
         attmodel:SetCamPos(tab.origin);
         attmodel:SetFOV(tab.fov);
         attmodel:SetLookAng(tab.angles);
         attmodel:Show();
         attimg:Hide();
      end
      
      buy:SetText("Buy for $" .. pricestr);
      buy.DoClick = function(this)
         net.Start("attvend");
            net.WriteString(class);
            net.WriteString(attname);
            net.WriteEntity(ent);
         net.SendToServer();
      end;
      buy.Think = function(this)
         if (isAmmo == false and isCW2Mag(attname) == false and LocalPlayer():hasWeaponAttachment(attname, base)) then
            this:SetText("[Already Owned]");
            this:SetDisabled(true);
            return;
         end
         
         if (not ATTACHMENT_VENDOR.playerCanAffordAttachment(LocalPlayer(), attname, price)) then
            this:SetDisabled(true);
         else
            this:SetDisabled(false);
         end
      end;
      buy:Show();
   end;
   
   local weplist = vgui.Create("DTree");
   
   for _, weptbl in pairs(LocalPlayer():GetWeapons()) do
      if (isCW2(weptbl) == false and isFAS2(weptbl) == false and isARCCW(weptbl) == false) then continue; end
      
      local wepnode = weplist:AddNode(string.Trim(weptbl:GetPrintName()));
      
      local ammohead = nil;
      for _, attinfo in pairs(istable(weptbl.Attachments) and weptbl.Attachments or {}) do
         local header = getAttachmentHeader(weptbl, attinfo);
         local attachments = getSuitableAttachments(weptbl, attinfo);

         -- For some reason ArcCW will show all slots even if the current weapon doesnt have attachments for the slot
         -- This will prune those empty slots and only show the slots that have attachments
         if (table.Count(attachments) == 0) then continue; end

         local headnode = wepnode:AddNode(header);
         
         if (string.lower(header) == "ammo") then
            ammohead = headnode;
         end
         
         for _, attname in pairs(attachments) do
            local name = getAttachmentName(attname);
            if (not isstring(name) or string.len(name) == 0) then continue end
            local attnode = headnode:AddNode(name);
            attnode.DoClick = function(this)
               local mdl;
               if (header == "Ammo") then
                  mdl = "models/items/357ammo.mdl";
               else
                  mdl = getAttachmentViewModel(weptbl, attname);
               end
               
               attinfopnl:Setup(attname, mdl or getAttachmentImage(attname), weptbl.ClassName);
            end;
            attnode.Think = function(this)
               if (LocalPlayer():hasWeaponAttachment(attname)) then
                  this:SetIcon("icon16/accept.png");
               else
                  this:SetIcon("icon16/add.png");
               end
            end;
         end
      end
      
      if (ATTACHMENT_VENDOR.cw2Mags.enable and isCW2Mag(weptbl.magType)) then
         if (ValidPanel(ammohead) == false) then
            ammohead = wepnode:AddNode("Ammo");
         end
         
         ---@TODO remove code duplication
         local magnode = ammohead:AddNode(string.Trim(getAttachmentName(weptbl.magType)));
         magnode:SetIcon("icon16/add.png");
         magnode.DoClick = function(this)
            attinfopnl:Setup(weptbl.magType, "models/items/357ammo.mdl", weptbl.ClassName);
         end;
      end
      
      if (ATTACHMENT_VENDOR.ammo.sell) then
         if (ValidPanel(ammohead) == false) then
            ammohead = wepnode:AddNode("Ammo");
         end
         
         local ammonode = ammohead:AddNode("Buy Ammo");
         ammonode:SetIcon("icon16/add.png");
         ammonode.DoClick = function(this)
            attinfopnl:Setup("buyAmmo", "models/items/357ammo.mdl", weptbl.ClassName);
         end;
      end
   end
   
   hdiv:SetLeft(weplist);
   hdiv:SetRight(attinfopnl);
end);