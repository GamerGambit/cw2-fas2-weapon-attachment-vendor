hook.Add("InitPostEntity", "AttachmentVendorReady", function()
   timer.Simple(5, function()
      net.Start("attvend_ready");
      net.SendToServer();
   end);
end);