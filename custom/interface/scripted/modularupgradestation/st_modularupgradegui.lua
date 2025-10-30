require "/scripts/util.lua"
require "/scripts/interp.lua"

function init()
  self.itemList = "itemScrollArea.itemList"

  self.material = "tungstenbar"

  self.maxLevel = config.getParameter("maxLevel")
  self.upgradeableWeaponItems = {}
  self.selectedItem = nil
  populateItemList()
end

function update(dt)
  populateItemList()
end

function getMaterial(itemConfig)

  local materials = {
    "tungstenbar",
    "titaniumbar",
    "durasteelbar",
    "refinedaegisalt",
    "solariumstar"
  }

  if itemConfig == nil then return materials[1] end

  if itemConfig.parameters.level then return materials[itemConfig.parameters.level] end

  if itemConfig.config then return materials[itemConfig.config.level] end

  return materials[1]
end

function populateItemList(forceRepop)
  local upgradeableWeaponItems = player.itemsWithTag("st_modularWeapon")
  for i = 1, #upgradeableWeaponItems do
    upgradeableWeaponItems[i].count = 1
  end

  local playerFrames = player.hasCountOfItem("st_modularframe")

  if forceRepop or not compare(upgradeableWeaponItems, self.upgradeableWeaponItems) then
    self.upgradeableWeaponItems = upgradeableWeaponItems
    widget.clearListItems(self.itemList)
    widget.setButtonEnabled("btnUpgrade", false)

    local showEmptyLabel = true

    for i, item in pairs(self.upgradeableWeaponItems) do
      local config = root.itemConfig(item)

      if (config.parameters.level or config.config.level or 1) < self.maxLevel then
        showEmptyLabel = false

        local listItem = string.format("%s.%s", self.itemList, widget.addListItem(self.itemList))
        local name = config.config.shortdescription

        widget.setText(string.format("%s.itemName", listItem), name)
        widget.setItemSlotItem(string.format("%s.itemIcon", listItem), item)

        --modular frame price
        local price = 2
        widget.setData(listItem,
          {
            index = i,
            price = price
          })

        widget.setVisible(string.format("%s.unavailableoverlay", listItem), price > playerFrames)
      end
    end

    self.selectedItem = nil
    showWeapon(nil)

    widget.setVisible("emptyLabel", showEmptyLabel)
  end
end

function showWeapon(item, price)
  local playerFrames = player.hasCountOfItem("st_modularframe")

  local originalItem

  local playerMetalBars = 0
  if item then
    local originalItem = root.itemConfig(item.name)
    local material = getMaterial(item.parameters.level and item or originalItem)
    playerMetalBars = player.hasCountOfItem(material)
    widget.setImage("materialImage", "/items/generic/crafting/" .. material .. ".png")
  else 
    widget.setImage("materialImage", "/custom/interface/scripted/modularupgradestation/default.png")
  end
  
  local enableButton = false

  local hasFrames = false
  local hasMaterials = false

  if item then
    hasFrames = playerFrames >= price
    hasMaterials = playerMetalBars >= 10
    
    enableButton = hasFrames and hasMaterials

    local directive = enableButton and "^green;" or "^red;"
    widget.setText("frameCost", string.format("%s%s / %s", hasFrames and "^green;" or "^red;", playerFrames, price))
    widget.setText("materialCost", string.format("%s%s / %s", hasMaterials and "^green;" or "^red;", playerMetalBars, 10))
  else
    widget.setText("frameCost", string.format("%s / 2", playerFrames))
    widget.setText("materialCost", string.format("%s / 10", playerMetalBars))
  end

  widget.setButtonEnabled("btnUpgrade", enableButton)
end

function itemSelected()
  local listItem = widget.getListSelected(self.itemList)
  self.selectedItem = listItem

  if listItem then
    local itemData = widget.getData(string.format("%s.%s", self.itemList, listItem))
    local weaponItem = self.upgradeableWeaponItems[itemData.index]
    showWeapon(weaponItem, itemData.price)
  end
end

function doUpgrade()
  if self.selectedItem then
    local selectedData = widget.getData(string.format("%s.%s", self.itemList, self.selectedItem))
    local upgradeItem = self.upgradeableWeaponItems[selectedData.index]

    local originalItem = root.itemConfig(upgradeItem.name)

    if upgradeItem then
      local consumedItem = player.consumeItem(upgradeItem, false, true)
      if consumedItem then
        local consumedFrames = player.consumeItem("st_modularframe", selectedData.price)
        local consumedMaterials = player.consumeItem(getMaterial(consumedItem.parameters.level and consumedItem or originalItem), 10)
        local upgradedItem = copy(consumedItem)
        if consumedFrames and consumedMaterials then
          upgradedItem.parameters.level = upgradedItem.parameters.level and upgradedItem.parameters.level + 1 or originalItem.config.level + 1
          local itemConfig = root.itemConfig(upgradedItem)
          if itemConfig.config.upgradeParameters then
            upgradedItem.parameters = util.mergeTable(upgradedItem.parameters, itemConfig.config.upgradeParameters)
          end
        end
        player.giveItem(upgradedItem)
      end
    end
    populateItemList(true)
  end
end
