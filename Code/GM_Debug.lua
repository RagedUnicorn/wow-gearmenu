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

local mod = gm
local me = {}
mod.debug = me

me.tag = "Debug"

function __GM__DEBUG__PRINTCOMBATQUEUE()
  local items = mod.itemManager.GetAllRegisteredItems()

  for key, moduleName in pairs(items) do
    local itemID = mod.combatQueue.GetCombatQueueStore()[mod[items[moduleName]].id]

    if itemID ~= nil then
      mod.logger.LogDebug(me.tag, "Item with id '" .. itemID .. "' registered for slot '" .. moduleName .."'")
    else
      mod.logger.LogDebug(me.tag, "No item registered for slot: " .. moduleName)
    end
  end
end

function __GM__DEBUG__PRINTQUICKCHANGERULELIST()
  local ruleList = GearMenuOptions.QuickChangeRules
  local ruleNumber = 1

  for key, rule in pairs(ruleList) do
    mod.logger.LogDebug(me.tag, "Rule no." .. ruleNumber)

    for i = 1, table.getn(rule.slotID) do
      mod.logger.LogDebug(me.tag, "slotID: " .. rule.slotID[i])
    end

    mod.logger.LogDebug(me.tag, "changeFromName: " .. rule.changeFromName)
    mod.logger.LogDebug(me.tag, "changeFromID: " .. rule.changeFromID)
    mod.logger.LogDebug(me.tag, "changeToName: " .. rule.changeToName)
    mod.logger.LogDebug(me.tag, "changeToID: " .. rule.changeToID)
    mod.logger.LogDebug(me.tag, "delay: " .. rule.changeDelay)
    ruleNumber = ruleNumber + 1
  end
end
