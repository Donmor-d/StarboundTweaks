require "/scripts/util.lua"

function craftingRecipe(items)
  if #items ~= 2 then return end

  local rarities = {"Common", "Uncommon", "Rare", "Legendary", "Essential"}

  local indexLead;
  local itemOutput;
  local itemsInput = {};

  local leadCount = 1;

  for i, item in pairs(items) do
    if item.name ~= "st_leadbar" then
      local originalItem = root.itemConfig(item.name)

      if originalItem.config.category == "ammoModifier" then 

        itemOutput = {
          name = item.name,
          count = 1,
          parameters = item.parameters
        }

        table.insert(itemsInput, item)
        itemsInput[1].count = 0

        local rarity = originalItem.config.rarity

        if rarity == "Common" then
          leadCount = 2
        elseif rarity == "Uncommon" then
          leadCount = 4
        elseif rarity == "Rare" then
          leadCount = 8
        elseif rarity == "Legendary" then
          leadCount = 16
        end
      else
        return 
      end
    else
      indexLead = i
    end
  end

  table.insert(itemsInput, items[indexLead])

  if itemsInput[2].count < leadCount then
    return
  end
  itemsInput[2].count = leadCount

  return {
      input = itemsInput,
      output = itemOutput,
      duration = 1.0
    }
end

function update(dt)
end
