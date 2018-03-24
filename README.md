# CW2/FAS2 Weapon Attachment Vendor (DarkRP Support)
- - -
This is a weapon attachment vendor for Customizable Weaponry 2 and Firearms Source 2. This is a plug-n-play addon for all gamemodes and supports DarkRP 2.6+.

Attachment Vendor supports the following addons:
+ [Customizable Weaponry 2.0](http://steamcommunity.com/sharedfiles/filedetails/?id=349050451)
+ [Unofficial Extra Customizable Weaponry](http://steamcommunity.com/workshop/filedetails/?id=359830105)
+ [X - UECW EP 2 [CW 2.0]](http://steamcommunity.com/sharedfiles/filedetails/?id=432651013)
+ [Mag System - CW 2.0](http://steamcommunity.com/sharedfiles/filedetails/?id=486217238)
+ [[CW 2.0] Khris' SWeps Collection](http://steamcommunity.com/workshop/filedetails/?id=654085316)
+ [FA:S 2.0 Alpha SWEPs](http://steamcommunity.com/sharedfiles/filedetails/?id=180507408)

This addon *will* work **WITHOUT** any of these, however the vendor will be useless and will not show any weapons or attachments.

If you buy this addon and no weapons appear in the vendor, make sure that you have any weapon from the collections above on your player. This is an attachment vendor, not a weapon vendor.

## HOW TO INSTALL
- - -
1. Download the ZIP
2. Copy the `CW2-FAS2-Weapon-Attachment-Vendor-master` folder into garrysmod/addons.
3. Configure the Attachment Vendor: `lua/attachment_vendor/configs/[sv|sh]_config.lua`

## Batteries Included
- - -
This addon comes included with a list of all CW2 and FAS2 attachments with default prices.

## Malfunctioning
- - -
The vendor has the ability to malfunction when damaged. Possibilities include: Taking money but not giving the attachment (*steal*), giving the attachment for free (*free*), giving extra attachments for free (*extra*) and operating normally. All of this can be configured, including disabling malfunctioning altogether.

## Installation
- - -
Installing this addon is as simple as extracing the folder to addons. It will automatically appear in DarkRP for the Gun Dealer job by default.

## Configuration
- - -
There 2 are files you might want to look at if you want to configure this vendor for your server:
* **lua/attachment_vendor/configs/(sv/sh)_config.lua** is where the attachments and respective prices are stored, as well as malfunction configuration and a function to retrieve the price of an attachment.
* As of version *1.6.0*, the DarkRP specific config file has been removed and merged with the regular config files. The hooks have been replaced with functions.

Editing other files will probably break stuff and I probably wont help you.

## Troubleshooting
- - -
If you want to use the [CW2 Mag System](http://steamcommunity.com/sharedfiles/filedetails/?id=486217238), please make sure that your `ATTACHMENT_VENDOR.cw2Mags` config is **enabled**, otherwise you will get errors like `Invalid attachment (srMag)`.

## Persistent Vendor Entities
- - -
As of version *1.4.0*, Attachment Vendor now supports location configurations which can be added in the `locations` table in `lua/attachment_vendor/configs/sv_config.lua`. This lets you place vendor entities around the map that will stay there even after a server reset. These locations, however, are map-specific and locations may vary between maps. 2 added bonuses with locations is that vendor entities can be set to be indestructible (To stop those pesky players destroying them) and they can be given an id/name which can be used in any of the hooks and functions (See below) that take a vendor entity, simply call **ent:Getid()**.

## Developers
- - -
If you are a developer looking to integrate this into your server, there are several things that might be of interest to you.
Attachment Vendor has the ability to overwrite the CW2 and FAS2 functions responsible for giving and removing weapon attachments.

Why do you care? If your server has addons or you have hard coded FAS2 or CW2 into your server, you may not want to change this. Letting Attachment Vendor overwrite these function calls is completely optional (See the "override.enable" config). If you choose to let Attachment Vendor overwrite these functions, it will call hooks for you to determine whether or not a player is allowed to be given or attachments or have attachments removed, and if so, will call hooks when they are given and removed. If you are curious about Attachment Vendor but realize it isnt for you and you have overwrite enabled; all you have to do is delete the addon and your code will still work exactly as it did before.

### Hooks and Functions
Attachment Vendor comes with several hooks and functions for you to use to add extra functionality to your server.

#### Functions
`ply:giveWeaponAttachments(table or string)`  
**Description:** Call this function to add attachment(s) to the player. The table MUST be sequential with string values (The names of the attachments). The table can contain attachments from both FAS2 and CW2 (Just in case your server uses both).  
**Returns:**
    
    Bool - Whether or not the attachments were added to the player (See "playerCanHaveAttachments" hook).

`ply:hasWeaponAttachment(string)`  
**Description:** Call this function to check if a player has a specific attachment. The attachment can be from either FAS2 or CW2.  
**Return:**

    Bool - Whether or not the player has the attachment.


`ply:removeWeaponAttachments(table or string)`  
**Description:** Call this function to remove attachment(s) from the player. The table MUST be sequential with string values (The names of the attachments). The table can contain attachments from both FAS2 and CW2 (Just in case your server uses both).  
**Returns:**

    Nothing.

`playerCanAffordAttachment(ply, attachment, price)`  
**Description:** Called to check whether a player can afford an attachment.  
**Returns:**
    
    Bool - Whether the player can afford the attachment or not.

`playerPurchasedAttachment(ply, attachment, price)`  
**Description:** Called before the player is given the attachments. If you are subtracting money or points, it should be done in this hook.  
**Returns:**
    
    Nothing.

`playerCanUseVendor(ply, ent)`  
**Description:** Called when the player tries to use Vendor entity.  
**Returns:**
    
    Bool - Whether the player can use the Vendor or not.


#### Hooks
`playerCanHaveAttachments(ply, tbl)`  
**Description:** Called before adding attachments to a player (See `ply:giveWeaponAttachments` function).  
**Returns:**
    
    Bool - Success.
    Table - Attachments to give. (Optional)

`playerGivenAttachments(ply, tbl)`  
**Description:** Called after attachments have been given to a player. The table contains a sequential list of strings as attachment names given.  
**Returns:**

    Nothing.

`playerCanRemoveAttachments(ply, tbl)`  
**Description:** Called before remove attachments from a player (See `ply:removeWeaponAttachments` function).  
**Returns:**
    
    Bool - Success.
    Table - Attachments to remove. (Optional)

`playerRemovedAttachments(ply, tbl)`  
**Description:** Called after attachments have been removed from a player. The table contains a sequential list of strings as attachment names removed.  
**Returns:**
    
    Nothing.

`playerLoadedWeaponAttachments(ply, tbl)`  
**Description:** Called after the player initially spawns and the attachments are loaded. The table contains a sequential list of strings as attachment names loaded.
**Returns:**
    
    Nothing.

## Database Support
- - -
Attachment Vendor supports saving and loading attachments via database. Unfortunately, only SQLite is supported for now.
The config to enable database support is "persistent.enabled".

Attachments are loaded once on initial spawn and are given in the loadout. When the attachments are given, the hook `playerLoadedWeaponAttachments` is called.
 
## Support
- - -
Please do not add me on Steam, create a [Ticket](https://github.com/GamerGambit/CW2-FAS2-Weapon-Attachment-Vendor/issues/new) instead. If you cannot reproduce the error please tell me and please for the love of god include the steps you took that resulted in the error **AND POST THE ERROR MESSAGE**. Tickets that are *just* the error message and nothing else will be closed and ignored.