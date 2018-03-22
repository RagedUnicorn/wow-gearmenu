--[[
  MIT License

  Copyright (c) 2018 Michael Wiesendanger

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]--

gm = {}
local me = gm

-- localization
gm.L = {}

me.tag = "Core"

--[[
  Saved addon variable
]]--
GearMenuOptions = {
  ["windowLocked"] = true,
  ["showKeyBindings"] = true,
  ["showCooldowns"] = true,
  ["disableTooltips"] = false,
  ["smallTooltips"] = false,
  ["disableDragAndDrop"] = false,
  --[[
    Itemquality to filter items by their quality. Everything that is below the settings value
    will not be considered a valid item to display when building the itemcontextmenu.
    By default all items are allowed

    0 Poor (gray)
    1 Common (white)
    2 Uncommon (green)
    3 Rare (blue)
    4 Epic (purple)
    5 Legendary (orange)
  ]]--
  ["filterItemQuality"] = 0,
  ["modules"] = {
    ["mainHand"] = 1,
    ["offHand"] = 2,
    ["waist"] = 3,
    ["feet"] = 4,
    ["head"] = 5,
    ["upperTrinket"] = 6,
    ["lowerTrinket"] = 7
  },
  --[[
    example
    {
      ["slotID"] = {13, 14},
      ["changeFromName"] = "Earthstrike",
      ["changeFromID"] = 21180,
      ["changeToName"] = "Drake Fang Talisman",
      ["changeToID"]  = 19406,
      ["changeDelay"] = 20 -- delay in sek
    }
  ]]--
  ["QuickChangeRules"] = {}
}

--[[
  Addon load
]]--
function me.OnLoad()
  me.logger.InitializeLogging()
  me.RegisterEvents()
  me.cmd.SetupSlashCmdList()
end

--[[
  Register addon events
]]--
function me.RegisterEvents()
  -- register to player login event also fires on /reload
  this:RegisterEvent("PLAYER_LOGIN")
  -- register to inventory changed - fires for each change in the inventory
  this:RegisterEvent("UNIT_INVENTORY_CHANGED")
  -- fires when the cooldown for an action bar item begins or ends
  this:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
  -- fires when the player leaves combat status
  this:RegisterEvent("PLAYER_REGEN_ENABLED")
  -- fires when a player resurrects after being in spirit form
  this:RegisterEvent("PLAYER_UNGHOST")
  -- fires when the player's spirit is released after death or when the player accepts a resurrection without releasing
  this:RegisterEvent("PLAYER_ALIVE")
  -- fired when the keybindings are changed
  this:RegisterEvent("UPDATE_BINDINGS")
end

--[[
  MainFrame OnEvent handler
]]--
function me.OnEvent()
  if event == "PLAYER_LOGIN" then
    me.logger.LogEvent(me.tag, "PLAYER_LOGIN")
    me.Initialize()
  elseif event == "UPDATE_BINDINGS" then
    me.gui.ShowKeyBindings()
  elseif event == "ACTIONBAR_UPDATE_COOLDOWN" then
    me.logger.LogEvent(me.tag, "ACTIONBAR_UPDATE_COOLDOWN")
    me.itemManager.UpdateCooldownForAllWornItems()
  elseif event == "UNIT_INVENTORY_CHANGED" and arg1 == "player" then
    me.logger.LogEvent(me.tag, "UNIT_INVENTORY_CHANGED")
    -- update all registered worn items
    me.itemManager.UpdateWornItems()
    if getglobal(GM_CONSTANTS.ELEMENT_GM_SLOT_FRAME):IsVisible() then
      -- rebuild possible changed menu
      me.gui.BuildMenu()
    end
    -- rebuild bagged items menu
  elseif (event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_UNGHOST"
    or event == "PLAYER_ALIVE") and not me.common.IsPlayerReallyDead() then
      if event == "PLAYER_REGEN_ENABLED" then
        me.logger.LogEvent(me.tag, "PLAYER_REGEN_ENABLED")
      elseif event == "PLAYER_UNGHOST" then
        me.logger.LogEvent(me.tag, "PLAYER_UNGHOST")
      elseif event == "PLAYER_ALIVE" then
        me.logger.LogEvent(me.tag, "PLAYER_ALIVE")
      end
      -- player is alive again or left combat - work through all combat queues
      me.combatQueue.ProcessQueue()
  end
end

--[[
  Init function
]]--
function me.Initialize()
  --setup random seed
  math.randomseed(GetTime())

  -- register item
  me.itemManager.RegisterItem(me.mainHand.moduleName)
  me.itemManager.RegisterItem(me.offHand.moduleName)
  me.itemManager.RegisterItem(me.waist.moduleName)
  me.itemManager.RegisterItem(me.feet.moduleName)
  me.itemManager.RegisterItem(me.head.moduleName)
  me.itemManager.RegisterItem(me.upperTrinket.moduleName)
  me.itemManager.RegisterItem(me.lowerTrinket.moduleName)

  -- update all registered worn items
  me.itemManager.UpdateWornItems()
  -- show keybindings for all registered items
  me.gui.ShowKeyBindings()
  -- create timers for all registered items
  me.itemManager.CreateTimersForItems()

  -- create all timers
  me.timer.CreateTimer("MenuMouseover", me.gui.SlotFrameMouseOver, .25, 1)
  me.timer.CreateTimer("TooltipUpdate", me.tooltip.TooltipUpdate, 1, 1)
  me.timer.CreateTimer("CooldownUpdate", me.cooldown.CooldownUpdate, 1, 1)
  me.timer.CreateTimer("ReflectItemUse", me.gui.ReflectItemUse, .75, .75)

  me.SetSlotPositions()
  me.opt.ReflectLockState(GearMenuOptions.windowLocked)

  me.timer.StartTimer("CooldownUpdate")

  -- show welcome message
  DEFAULT_CHAT_FRAME:AddMessage(
    string.format(GM_CONSTANTS.ADDON_NAME .. gm.L["help"], GM_CONSTANTS.ADDON_VERSION))
end


--[[
  Set SetSlotPositions on addon load
]]--
function me.SetSlotPositions()
  for key, value in pairs(GearMenuOptions.modules) do
    if value == 0 then
      me[key].SetDisabled(true)
    else
      me[key].SetDisabled(false)
    end

    me[key].SetPosition(value)
  end

  for i = 1, GM_CONSTANTS.ADDON_SLOTS do
    local active = me.itemManager.FindModuleForPosition(i)

    if active == nil then
      me.logger.LogDebug(me.tag, "Slot" .. i .. " is inactive")
      me.gui.HideSlot(i)
    end
  end

  -- reflect items that are worn
  me.itemManager.UpdateWornItems()
end
