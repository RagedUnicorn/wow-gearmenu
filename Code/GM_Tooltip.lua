--[[
  GearMenu - A WoW 1.12.1 Addon to manage quick itemswitching
  Copyright (C) 2017 Michael Wiesendanger <michael.wiesendanger@gmail.com>

  This file is part of GearMenu.

  GearMenu is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  GearMenu is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with GearMenu.  If not, see <http://www.gnu.org/licenses/>.
]]--

local mod = gm
local me = {}
mod.tooltip = me

me.tag = "Tooltip"

--[[
  private
]]--
local tooltipBag = 0
local tooltipSlot = 0
local tooltipType = ""

local TOOLTIP_TYPE_BAG = "Bag"
local TOOLTIP_TYPE_ITEMSLOT = "ItemSlot"

--[[
  @param {number} id
  @param {table} BaggedItems
]]--
function me.BuildTooltipForBaggedItems(id, BaggedItems)
  tooltipBag = BaggedItems[id].bag
  tooltipSlot = BaggedItems[id].slot
  tooltipType = TOOLTIP_TYPE_BAG

  mod.timer.StartTimer("TooltipUpdate", 0)
end

--[[
  @param {number} id
]]--
function me.BuildTooltipForWornItem(id)
  tooltipSlot = id
  tooltipType = TOOLTIP_TYPE_ITEMSLOT

  mod.timer.StartTimer("TooltipUpdate", 0)
end

--[[
  @param {string} line1
  @param {string} line2
]]--
function me.BuildTooltipForOptions(line1, line2)
  GameTooltip_SetDefaultAnchor(GameTooltip, this)

  GameTooltip:AddLine(line1)
  GameTooltip:AddLine(line2, .8, .8, .8, 1)

  GameTooltip:Show()
end

--[[
  update the tooltip
]]--
function me.TooltipUpdate()
  if GearMenuOptions.disableTooltips then return end

  local cooldown = GetContainerItemCooldown(tooltipBag, tooltipSlot)
  GameTooltip:ClearLines()

  if tooltipType == TOOLTIP_TYPE_BAG then
    if GearMenuOptions.smallTooltips then
      local itemLink = GetContainerItemLink(tooltipBag, tooltipSlot)
      local _, _, color, id = string.find(itemLink, "^|c([|%a%d]+)|Hitem:(%d+)")
      local _, _, name = string.find(itemLink, "%[([%a%s%d',-:]+)%]")

      GameTooltip:AddLine("|c" .. color .. name .. "|h|r")
    else
      GameTooltip:SetBagItem(tooltipBag, tooltipSlot)
    end
  else
    if GearMenuOptions.smallTooltips then
      local itemLink = GetInventoryItemLink("player", tooltipSlot);

      -- if the player has nothing equiped in this slot abort
      if not itemLink then return end

      local _, _, color, id = string.find(itemLink, "^|c([|%a%d]+)|Hitem:(%d+)")
      local _, _, name = string.find(itemLink, "%[([%a%s%d',-:]+)%]")

      GameTooltip:AddLine("|c" .. color .. name .. "|h|r")
    else
      GameTooltip:SetInventoryItem("player", tooltipSlot)
    end
  end

  GameTooltip:Show()
end

--[[
  remove tooltip after region leave
]]--
function me.TooltipClear()
  mod.logger.LogDebug(me.tag, "Cleared Tooltip")
  mod.timer.StopTimer("TooltipUpdate")
  GameTooltip:Hide()
end