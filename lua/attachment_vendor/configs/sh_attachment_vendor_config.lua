ATTACHMENT_VENDOR = {
   override = {
      enable = true  // If this is set to true, Attachment Vendor will override functions in FAS2 and CW2
                     // that deal with adding and removing weapon attachments.
                     // In addition, these new functions will provide hooks for you to decide if an attachment
                     // should be added or removed and what happens when and attachment is added or removed.
   },
   
   ammo = {
      sell = true,      // Should the vendor sell ammo for weapons?
      price = 50        // Price of buying ammo  (1 clip worth)
   },
   
   darkrpAllowedJobs = function() return {TEAM_GUN}; end, // List of DarkRP TEAM_ classes that spawn the vendor from F4/Entities
   
   defaultAttachmentPrice = 100,             // Default price for attachments that arent in the prices table below
   
   getAttachmentPrice = function(ply, price, vendor)
      if (ply == vendor:Getowning_ent()) then
         return price * 0.75; // Owner pays 75% of the attachment price
      else
         return price;
      end
   end,
   
   playerCanAffordAttachment = function(ply, att, price)
      if (isfunction(ply.canAfford)) then
         return ply:canAfford(price);
      else
         return true;
      end
   end,

   playerPurchasedAttachment = function(ply, att, price)
      if (isfunction(ply.addMoney)) then
         ply:addMoney(-price);
      end
   end,

   playerCanUseVendor = function(ply, ent)
      return true;
   end,
   
   cw2Mags = {
      enable = true,    // Use the CW2 Magazing addon (http://steamcommunity.com/sharedfiles/filedetails/?id=486217238)
   },
   
   
   prices = {
      // CW2
      bg_ak74_rpkbarrel = 650,
      bg_ak74_ubarrel = 350,
      bg_ak74foldablestock = 400,
      bg_ak74heavystock = 350,
      bg_ak74rpkmag = 500,
      bg_ar1560rndmag = 1000,
      bg_ar15heavystock = 400,
      bg_ar15sturdystock = 200,
      bg_bipod = 900,
      bg_deagle_compensator = 450,
      bg_deagle_extendedbarrel = 400,
      bg_foldsight = 50,
      bg_longbarrel = 800,
      bg_longbarrelmr96 = 800,
      bg_longris = 650,
      bg_magpulhandguard = 500,
      bg_mp530rndmag = 750,
      bg_mp5_kbarrel = 650,
      bg_mp5_sdbarrel = 450,
      bg_nostock = 400,
      bg_regularbarrel = 500,
      bg_retractablestock = 200,
      bg_ris = 150,
      bg_sg1scope = 900,
      md_acog = 600,
      md_acog_fixed = 700,
      md_aimpoint = 350,
      md_anpeq15 = 300,
      md_ballistic = 1000,
      md_bipod = 900,
      md_csgo_556 = 600,
      md_csgo_acog = 700,
      md_csgo_scope_ssg = 900,
      md_csgo_silencer_ballistic = 400,
      md_csgo_silencer_pistol = 400,
      md_csgo_silencer_rifle = 500,
      md_csgo_taclight = 100,
      md_docter = 100,
      md_elcan = 500,
      md_eotech = 100,
      md_foregrip = 400,
      md_kobra = 100,
      md_m203 = 10000,
      md_microt1 = 100,
      md_pbs1 = 500,
      md_pso1 = 750,
      md_reflex = 100,
      md_rmr = 100,
      md_saker = 300,
      md_schmidt_shortdot = 1000,
      md_trijicon = 800,
      md_tundra9mm = 200,
      md_uecw_60rnd = 1000,
      md_uecw_akmag = 500,
      md_uecw_cmag = 2500,
      md_uecw_csgo_556 = 600,
      md_uecw_emag = 300,
      md_uecw_foldsight = 50,
      md_uecw_usgimag = 100,
      uecw_skin_silencer = 200,
      am_magnum = 400,
      am_matchgrade = 400,
      md_cmore = 100,
      md_cobram2 = 100,
      md_insight_x2 = 100,
      md_nightforce_nxs = 100,
      md_sight_rail = 100,
      md_sight_rail_larue = 100,
      md_sight_railmount = 100,
      md_uecw_csgo_acog = 100,
      md_uecw_csgo_scope_ssg = 100,
      am_flechetterounds = 100,
      am_slugrounds = 100,
      bg_makarov_pb6p9 = 100,
      bg_sr3m = 100,
      bg_makarov_extmag = 100,
      bg_mac11_unfolded_stock = 100,
      bg_asval_20rnd = 100,
      bg_mac11_extended_barrel = 100,
      bg_vss_foldable_stock = 100,
      am_sp7 = 100,
      bg_makarov_pm_suppressor = 100,
      bg_asval = 100,
      bg_asval_30rnd = 100,
      bg_makarov_pb_suppressor = 100,
      
      // CW2 MAG
      pistolMag = 50,
      smgMag = 60,
      arMag = 75,
      brMag = 70,
      srMag = 70,
      
      // Khris SWEPs Collection
      bg_r8rail = 100,
      md_mark2em = 100,
      bg_makpmm12rnd = 100,
      am_7n31 = 100,
      bg_makpmm = 100,
      am_slugroundsneo = 100,
      md_khr_ins2ws_acog = 100,
      md_mnbrandnew2 = 100,
      am_slugrounds2k = 100,
      bg_makpmext = 100,
      md_avt40 = 100,
      md_bfstock = 100,
      md_extmag22 = 100,
      md_gemtechmm = 100,
      md_ins2_suppressor_ins = 100,
      md_cz52barrel = 100,
      bg_makpmmext = 100,
      bg_dsmag = 100,
      am_416barrett = 100,
      bg_sksbayonetfold = 100,
      bg_mncustombody = 100,
      bg_long38 = 100,
      bg_38 = 100,
      bg_short38 = 100,
      bg_3006extmag = 100,
      bg_mnobrezbody = 100,
      bg_mncarbinebody = 100,
      md_mnbrandnew1 = 100,
      md_shortdot = 100,
      bg_medium38 = 100,
      bg_rugerext = 100,
      md_cblongerbarrel = 100,
      md_tritiumispmm = 100,
      bg_sksbayonetunfold = 100,
      bg_6inchsw29 = 100,
      bg_delislescope = 100,
      bg_mdemag = 100,
      md_cblongbarrel = 100,
      bg_bentbolt = 100,
      md_fas2_eotech = 100,
      am_45lc = 100,
      md_mnolddark = 100,
      bg_skspuscope = 100,
      md_tritiumis = 100,
      bg_makpbsup = 100,
      am_flechette410 = 100,
      bg_judgelong = 100,
      bg_cbstock = 100,
      am_4borehp = 100,
      kry_docter_sight = 100,
      am_duprojectile = 100,
      md_pr3 = 100,
      md_pr2 = 100,
      md_makeshift = 100,
      odec3d_cmore_kry = 100,
      odec3d_barska_sight = 100,
      bg_4inchsw29 = 100,
      md_rugersup = 100,
      bg_cz52ext = 100,
      bg_ots_extmag = 100,
      md_lightbolt = 100,
      bg_hcarfoldsight = 100,
      md_cz52chrome = 100,
      md_tritiumispb = 100,
      bg_makpb6 = 100,
      bg_cz52compact = 100,
      md_nxs = 100,
      bg_judgelonger = 100,
      md_cz52silver = 100,
      md_prextmag = 100,
      md_fas2_aimpoint = 100,
      md_griplaser = 100,
      md_item62em = 100,
      md_microt1kh = 100,
      md_muzl = 100,
      
      // FAS2
      c79 = 100,
      sks20mag = 100,
      compm4 = 100,
      mp5k30mag = 100,
      harrisbipod = 100,
      leupold = 100,
      eotech = 100,
      slugrounds = 100,
      uziwoodenstock = 100,
      tritiumsights = 100,
      foregrip = 100,
      acog = 100,
      sks30mag = 100,
      pso1 = 100,
      sg55x30mag = 100,
      suppressor = 100,
      m2120mag = 100
   }
}