ENT.Base = "base_anim";
ENT.Type = "anim";
ENT.PrintName = "Attachment Vendor"
ENT.Category = "Entities"
ENT.Author = "Gambit"
ENT.Spawnable = true;

function ENT:SetupDataTables()
   self:NetworkVar("Entity", 0, "owning_ent");
   self:NetworkVar("Bool", 0, "damaged");
   self:NetworkVar("Bool", 1, "destructible");
   self:NetworkVar("String", 0, "id");
end
