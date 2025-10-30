require "/scripts/augments/item.lua"

function apply(input)
  local augmentConfig = config.getParameter("augment")
  local output = Item.new(input)

  local weaponType = output:instanceValue("acceptsAugmentType", "")

  if augmentConfig then
    if weaponType == augmentConfig.type or augmentConfig.type == "anyammo" or augmentConfig.type == "default" or isCompatible(augmentConfig.type, weaponType) then --checks if compatible, 
      local currentAugments = output:instanceValue("currentAugments", {butt, middle, barrel})
      if currentAugments then
        if currentAugments[augmentConfig.category] then
          if currentAugments[augmentConfig.category].name == augmentConfig.name then
            return nil
          end
        elseif augmentConfig.type == "default" then
          return nil
        end
      end
      
      local currentAbility = output:instanceValue("altAbilityType")
      if currentAbility and augmentConfig.altAbilityType then
        if currentAbility == augmentConfig.altAbilityType then
          return nil
        end
      end
      
      local elementType = output:instanceValue("elementalType") or "physical"

      --adds secondary abilities, not used for now
      if augmentConfig.altAbilityType then
        -- checks if alt ability type requires an element
        if elementType == "physical" and augmentConfig.elementalAbility then
          return nil
        end
        output:setInstanceValue("altAbilityType", augmentConfig.altAbilityType)
      else
        local equippedAugments = output:instanceValue("currentAugments", {butt, middle, barrel})
        equippedAugments[augmentConfig.category] = augmentConfig

        --rebuild gun with current augments every time a new one is equipped
        --NOTES:
        --  - this means any value added by the butt can be overriden by the middle and then both will be overriden by the barrel
        --  - to avoid this simply dont add values that are used by the other augment types (eg. if a butt augment changes fireTime, dont change that in any middle or barrel augment)

        local defaultPrimaryAbility = root.assetJson("/custom/items/weapons/ranged/modular/st_defaultParameters.config:".. output:instanceValue("category", "assaultRifle"))

        for k, augment in pairs(equippedAugments) do

          if augment.primaryAbility then
            for key, value in pairs(augment.primaryAbility) do
              defaultPrimaryAbility[key] = value
            end 
          end 

          output:setInstanceValue("primaryAbility", defaultPrimaryAbility) 
          
          -- local inventoryIcon = output:instanceValue("inventoryIcon") 
          -- local animationParts = output:instanceValue("animationParts")

          local newInventoryIcon = augment.inventoryIcon or "normal.png"
          
          if augment.category then
            -- Mudar para pegar de um arquivo config
            local categories = {
              butt = {index = 1}, 
              middle = {index = 2}, 
              barrel = {index = 3}
            }

            local category = augment.category

            if category == "middle" then
              if augmentConfig.type == "default" then
                output:setInstanceValue("elementalType", "physical")
              elseif augmentConfig.elementalType then
                output:setInstanceValue("elementalType", augmentConfig.elementalType)
              end
            end

            -- local index = string.find(inventoryIcon[categories[category].index].image, "/[^/]*$")

            -- local filePath = string.sub(inventoryIcon[categories[category].index].image, 1, index)

            -- inventoryIcon[categories[category].index].image = filePath .. newInventoryIcon
            -- animationParts[category] = filePath .. newInventoryIcon
            if augment.fullbright then
              -- animationParts[category .. "Fullbright"] = filePath .. augment.fullbright
            end
          end

          -- output:setInstanceValue("inventoryIcon", inventoryIcon)
          -- output:setInstanceValue("animationParts", animationParts)

          -- if augment.animationCustom then
          --   local newAnimationCustom = {}
          --   for key, value in pairs(augment.animationCustom) do
          --     newAnimationCustom[key] = value
          --   end 
          --   output:setInstanceValue("animationCustom", newAnimationCustom)
          -- end
        end

        if augmentConfig.type == "default" then
          equippedAugments[augmentConfig.category] = nil
        end
        output:setInstanceValue("currentAugments", equippedAugments)
      end
      return output:descriptor(), 1
    end
  end
end

function isCompatible(table, weaponType) --checa se um dos elementos da table é o mesmo que o type assim uma bala pode ser usada por dois tipos de armas diferentes
  if type(table) ~= "table" then return false end

  for _, value in pairs(table) do
    if value == weaponType then
      return true
    end
  end
  return false
end