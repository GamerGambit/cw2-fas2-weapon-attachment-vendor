if (not ATTACHMENT_VENDOR.override.enable) then return; end

-- This was missing from CW2
usermessage.Hook("CW20_REMOVEATTACHMENT", function(d)
   LocalPlayer().CWAttachments[d:ReadString()] = nil;
end);