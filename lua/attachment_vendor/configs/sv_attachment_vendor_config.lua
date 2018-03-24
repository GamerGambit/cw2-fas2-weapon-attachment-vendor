ATTACHMENT_VENDOR.persistent = {
   enabled = false,  // Should bought attachments be saved to a database?
   module = "sqlite",// What database module should be used? (CURRENTLY ONLY SQLITE WORKS)
   auth = {          // Authentication for a remote MYSQL server (CURRENTLY NOT USED)
      host = "localhost",
      port = 3306,
      user = "root",
      pass = ""
   }
};

ATTACHMENT_VENDOR.locations = {
   //{pos = Vector(), ang = Angle(), id = "mySpecialVendorID", destructible = false}
};
   
ATTACHMENT_VENDOR.malfunction = {      // When a vendor is damaged, it CAN malfunction but is not guaranteed.
   allow = false,     // Should the vendor malfunction?
   chance = 40,      // 40% that a malfunctioning vendor will actually malfunction.
   
   steal = true,     // Should a malfunctioning vendor randomly take money without giving attachments?
   stealChance = 25, // 25% chance that a malfunctioning vendor will steal.
   
   free = true,      // Should a malfunctioning vendor randomly give attachments for free?
   freeChance = 15,  // 15% chance that a malfunctioning vendor will give free attachments.
   
   extra = true,     // Should a malfunctioning vendor randomly give extra attachments for free?
   extraChance = 10, // 10% chance a that a malfunctioning vendor will give extra attachments for free.
   extraMax = 2      // Maximum number of extra attachments to give.
};

// Percentage of the price of the attachment that goes back to the owner of the attachment vendor
ATTACHMENT_VENDOR.ownerPricePercentage = function(ply, attname, price)
   return 100; // 100% of the price goes to the owner
end;