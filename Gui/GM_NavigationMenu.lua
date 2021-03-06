--[[
  MIT License

  Copyright (c) 2019 Michael Wiesendanger

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
mod.navigationMenu = me

me.tag = "NavigationMenu"

local navigationEntries = {
  [1] = {
    ["name"] = "Slots",
    ["text"] = gm.L["navigation_slots"],
    ["position"] = 1,
    ["active"] = true,
    ["init"] = function()
      for i = 1, 10 do
        getglobal(GM_CONSTANTS.ELEMENT_SLOT_TITLE .. i):SetText(gm.L["titleslot" .. i])
      end
    end
  },
  [2] = {
    ["name"] = "General",
    ["text"] = gm.L["navigation_general"],
    ["position"] = 2,
    ["active"] = false,
    ["init"] = function()
      getglobal(GM_CONSTANTS.ELEMENT_FILTER_ITEM_QUALITY_TITLE):SetText(gm.L["filter_item_quality"])
    end
  },
  [3] = {
    ["name"] = "QuickChange",
    ["text"] = gm.L["navigation_quickchange"],
    ["position"] = 3,
    ["active"] = false,
    ["init"] = function()
      getglobal(GM_CONSTANTS.ELEMENT_QUICK_CHANGE_DELAY_LABEL):SetText(gm.L["delay_label"])
      getglobal(GM_CONSTANTS.ELEMENT_QUICK_CHANGE_UNIT_DELAY_LABEL):SetText(gm.L["delay_unit_label"])
      getglobal(GM_CONSTANTS.ELEMENT_RULE_LIST_LABEL):SetText(gm.L["rule_list_label"])
      getglobal(GM_CONSTANTS.ELEMENT_CHANGE_FROM_LABEL):SetText(gm.L["change_from_label"])
      getglobal(GM_CONSTANTS.ELEMENT_CHANGE_TO_LABEL):SetText(gm.L["change_to_label"])
    end
  },
  [4] = {
    ["name"] = "About",
    ["text"] = gm.L["navigation_about"],
    ["position"] = 4,
    ["active"] = false,
    ["init"] = function()
      --load texts
      getglobal(GM_CONSTANTS.ELEMENT_ABOUT_AUTHOR_LABEL):SetText(gm.L["author"])
      getglobal(GM_CONSTANTS.ELEMENT_ABOUT_EMAIL_LABEL):SetText(gm.L["email"])
      getglobal(GM_CONSTANTS.ELEMENT_ABOUT_ISSUES_LABEL):SetText(gm.L["issues"])
      getglobal(GM_CONSTANTS.ELEMENT_ABOUT_VERSION_LABEL):SetText(gm.L["version"])
    end
  }
}

--[[
  Set first navigation point and content frame active in optionsframe
]]--
function me.LeftNavigationMenuOnShow()
  -- reset tab buttons and content frame
  for i = 1, table.getn(navigationEntries) do
    navigationEntries[i].active = false

    -- reset navigation highlight
    getglobal(GM_CONSTANTS.ELEMENT_NAVIGATION_BUTTON .. i .. "Texture"):Hide()
    getglobal(GM_CONSTANTS.ELEMENT_NAVIGATION_BUTTON .. i .. "Text"):SetTextColor(0.94, 0.76, 0, 1)
    -- hide content frame
    getglobal(GM_CONSTANTS.ELEMENT_CONTENT .. navigationEntries[i].name):Hide()
  end

  for _, framechild in ipairs({this:GetChildren()}) do
    -- set first navigation button active and selected
    getglobal(framechild:GetName() .."Texture"):Show()
    getglobal(framechild:GetName() .."Text"):SetTextColor(1, 1, 1, 1)

    break -- break on first element
  end

  -- set first content window active
  getglobal(GM_CONSTANTS.ELEMENT_CONTENT .. navigationEntries[1].name):Show()
  navigationEntries[1].init()
end

function me.NavigationMenuButtonOnClick()
  local name = this:GetName()
  local position = mod.common.ExtractPositionFromName(name)

  if not navigationEntries[position].active then
    for i = 1, table.getn(navigationEntries) do
      if i == position then
        navigationEntries[i].active = true
        -- set navigation button active
        getglobal(name .. "Texture"):Show()
        getglobal(name .. "Text"):SetTextColor(1, 1, 1, 1)
        -- set content frame active
        getglobal(GM_CONSTANTS.ELEMENT_CONTENT .. navigationEntries[i].name):Show()
        navigationEntries[i].init()
      else
        navigationEntries[i].active = false

        -- reset navigation highlight
        getglobal(GM_CONSTANTS.ELEMENT_NAVIGATION_BUTTON .. i .. "Texture"):Hide()
        getglobal(GM_CONSTANTS.ELEMENT_NAVIGATION_BUTTON .. i .. "Text"):SetTextColor(0.94, 0.76, 0, 1)
        -- hide content frame
        getglobal(GM_CONSTANTS.ELEMENT_CONTENT .. navigationEntries[i].name):Hide()
      end
    end
  else
    return -- abort no work left
  end
end

function me.NavigationMenuButtonOnLoad()
  local name = this:GetName()
  local position = mod.common.ExtractPositionFromName(name)

  getglobal(name .."Text"):SetText(navigationEntries[position].text)
end
