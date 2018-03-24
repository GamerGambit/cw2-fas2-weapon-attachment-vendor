util.AddNetworkString("attvend_ready");

net.Receive("attvend_ready", function(l, p)
   p.attvend_ready = true;
   gamemode.Call("PlayerLoadout", p);
end);