--[[
   Handles the Ship AI (tutorial-ish?) being triggered from the ifo menu
--]]
local fmt = require "format"
local tut = require "common.tutorial"
local vn  = require "vn"

function create ()
   vn.clear()
   vn.scene()
   local sai = vn.newCharacter( tut.vn_shipai() )
   vn.transition( tut.shipai.transition )
   vn.label("mainmenu")
   sai(fmt.f(_([["Hello {playername}! Is there anything you want to change or brushen up on?"]]),{playername=player.name()}))
   vn.menu( function ()
      local opts = {
         {_("Get Advice"), "advice"},
         {_("Get Information"), "tutorials"},
         {_("Tutorial Options"), "opts"},
         {_("Close"), "close"},
      }
      return opts
   end )

   vn.label("advice")
   sai( function () return advice() end )

   vn.label("opts")
   vn.menu( function ()
      local opts = {
         {_("Reset all tutorials"), "reset"},
         {_("Close"), "mainmenu"},
      }
      if tut.isDisabled() then
         table.insert( opts, 1, {_("Enable tutorials"), "enable"} )
      else
         table.insert( opts, 1, {_("Disable tutorials"), "disable"} )
      end
      return opts
   end )

   vn.label("enable")
   vn.func( function () var.pop("tut_disable") end )
   sai(_([["In-game tutorials are now enabled! If you want to revisit old tutorials, make sure to reset them."]]))
   vn.jump("mainmenu")

   vn.label("disable")
   vn.func( function () var.push("tut_disable", true) end )
   sai(_([["In-game tutorials are now disabled."]]))
   vn.jump("mainmenu")

   vn.label("reset")
   sai(_([["This will reset and enable all in-game tutorials, are you sure you want to do this?"]]))
   vn.menu{
      {_("Reset tutorials"), "resetyes"},
      {_("Nevermind"), "opts"},
   }
   vn.label("resetyes")
   vn.func( function () tut.reset() end )
   sai(_([["All in-game tutorials have been set and enabled! They will naturally pop up as you do different things in the game."]]))
   vn.jump("mainmenu")

   vn.label("tutorials")
   sai(_([["What do you want to learn about?"]]))
   vn.menu{
      {_("Weapon Sets"), "tut_weaponsets"},
      {_("Electronic Warfare"), "tut_ewarfare"},
      {_("Stealth"), "tut_stealth"},
      {_("Nevermind"), "mainmenu"},
   }

   vn.label("tut_weaponsets")
   sai(_([["A large part of combat is decided ahead of time by the ship classes and their load out. However, good piloting can turn the tables easily. It is important to assign weapon sets to be easy to use. You can set weapon sets from the '#oWeapons#0' tab of the information window. You have 10 different weapon sets that can be configured separately for each ship."]]))
   sai(_([["There are three different types of weapon sets:
- #oWeapons - Switched#0: activating the hotkey will set your primary and secondary weapons
- #oWeapons - Instant#0: activating the hotkey will fire the weapons
- #oAbilities - Toggled#0: activating the hotkey will toggle the state of the outfits]]))
   sai(_([["By default, the weapon sets will be automatically managed by me, with forward bolts in set 1 (switched), turret weapons in set 2 (switched), and both turret and forward weapons in set 3 (switched). Seeker weapons are in set 4 (instant), and fighter bays in set 5 (instant). However, you can override this and set them however you prefer. Just remember to update them whenever you change your outfits."]]))
   vn.jump("tutorials")

   vn.label("tut_ewarfare")
   sai(_([["Ship sensors are based on detecting gravitational anomalies, and thus the mass of a ship plays a critical role in being detected. Smaller ships like yachts or interceptors are inherently much harder to detect than carriers or battleship."]]))
   sai(_([["Each ship has three important electronic warfare statistics:
- #oDetection#0 determines the distance at which a ship appears on the radar.
- #oEvasion#0 determines the distance at which a ship is fully detected, that is, ship type and faction are visible. It also plays a role in how missiles and weapons track the ship.
- #oStealth#0 determines the distance at which the ship is undetected when in stealth mode"]]))
   sai(_([["#oDetection#0 plays a crucial in how much attention you draw in a system, and detection bonuses can be very useful for avoiding lurking dangers. Furthermore, concealment bonuses will lower your detection, evasion, and stealth ranges, making outfits that give concealment bonuses very useful if you get your hands on them."]]))
   sai(_([["#oEvasion#0 is very important when it comes to combat as it determines how well weapons can track your ship. If your evasion is below your enemies weapon's #ominimal tracking#0, their weapons will not be able to accurately target your ship at all. However, if your evasion is above the #ooptimal tracking#0, you will be tracked perfectly. Same goes for your targets. This also has an effect on launcher lock-on time, with lower evasion increasing the time it takes for rockets to lock on to you."]]))
   sai(fmt.f(_([["#oStealth#0 is a whole different beast and is only useful when entering stealth mode with {stealthkey}. If you want to learn more about stealth, please ask me about it."]]),{stealthkey=tut.getKey("stealth")}))
   vn.jump("tutorials")

   vn.label("tut_stealth")
   sai(fmt.f(_([["You can activate stealth mode with {stealthkey} when far enough away from other ships, and only when you have no missiles locked on to you. When stealthed, your ship will be completely invisible to all ships. However, if a ship gets within the #ostealth#0 distance of your ship, it will slowly uncover you."]]),{stealthkey=tut.getKey("stealth")}))
   sai(_([["Besides making your ship invisible to other ships, #ostealth#0 slows down your ship by 50% to mask your gravitational presence. This also has the effect of letting you jump out from jumpoints further away. There are many outfits that can change and modify this behaviour to get more out of stealth."]]))
   sai(_([["When not in stealth, ships can target your ship to perform a scan. This can uncover unwanted information, such as illegal cargo or outfits. The time to scan depends on the mass of the ship. If you don't want to be scanned, you should use stealth as much as possible. Enemy ships may also use stealth. Similarly to how you get uncovered when ships enter your #ostealth#0 range, you can uncover neutral or hostile ships by entering their #ostealth#0 range, however, you will not be able to know where they are until you are on top of them."]]))
   sai(_([["Finally, escorts and fighters will automatically stealth when their leader goes into stealth, so you don't have to worry giving stealth orders to ships you may be commanding. Friendly ships will also not uncover your stealth, so it is good to make as many friends as possible."]]))
   vn.jump("tutorials")

   vn.label("close")
   vn.done( tut.shipai.transition )
   vn.run()
end

-- Tries to give the player useful contextual information
function advice ()
   local adv = {}
   local pp = player.pilot()
   local fuel, consumption = pp:fuel()
   if fuel < consumption then
      table.insert( adv, _([["When out of fuel, if there is an inhabitable planet you can land to refuel for free. However, if you want to save time or have no other option, it is possible to hail passing ships to get refueled, or even take fuel by force by boarding ships. Bribing hostile ships can also encourage them to give you fuel afterwards."]]) )
   end
   local hostiles = pp:getHostiles()
   if #hostiles > 0 then
      table.insert( adv, _([["When being overwhelmed by hostile enemies, you can sometimes get out of a pinch by bribing them so that they leave you alone. Not all pilots or factions are susceptible to bribing, however."]]) )
   end
   local hmean, hpeak = pp:weapsetHeat(true)
   if pp:temp() > 300 or hpeak > 0.2 then
      table.insert( adv, fmt.f(_([["When your ship or weapons get very hot, it is usually a good idea to perform an active cooldown when it is safe to do so. You can actively cooldown with {cooldownkey} or double-tapping {reversekey}. The amount it takes to cooldown depends on the size of the ship, but when done, not only will your ship be cool, it will also have replenished all ammunition and fighters."]]),{cooldownkey=tut.getKey("cooldown"), reversekey=tut.getKey("reverse")}))
   end
   local armour, shield = pp:health()
   local ppstats = pp:stats()
   if pp:armour() < 80 and ppstats.armour_regen <= 0 then
   end

   if #adv > 0 then
      return adv[ rnd.rnd(1,#adv) ]
   end

   return "Generic advice"
end
