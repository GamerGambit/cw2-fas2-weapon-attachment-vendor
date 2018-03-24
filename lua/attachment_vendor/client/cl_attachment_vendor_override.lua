if (ATTACHMENT_VENDOR.override.enable != true) then return; end

// Seriously.. The dev(s) of CW2 left this out
usermessage.Hook("CW20_REMOVEATTACHMENT", function(d)
   LocalPlayer().CWAttachments[d:ReadString()] = nil;
end);