require "/scripts/augments/item.lua"

function apply(input)
  local augmentConfig = config.getParameter("augment")
  local output = Item.new(input)

  local weaponType = output:instanceValue("acceptsAugmentType", "")

  if augmentConfig then
    if weaponType == augmentConfig.type or augmentConfig.type == "anyammo" or isCompatible(augmentConfig.type, weaponType) then --checks if compatible, 
      local currentAugments = output:instanceValue("currentAugments", {stock, chamber, barrel})
      if currentAugments then
        if currentAugments[augmentConfig.category] and currentAugments[augmentConfig.category].name == augmentConfig.name then
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
      if augmentConfig.altAbilityType then
        if elementType == "physical" and augmentConfig.elementalAbility then --checa se a abilidade é elemental e não coloca se a arma é physical (algumas habilidades só funcionam se a arma tiver um elemento) / checks if the ability is elemental and doesnt apply if the weapon is physical(certain abilities only work when the weapon has an element)
          return nil
        end
        output:setInstanceValue("altAbilityType", augmentConfig.altAbilityType)
      else
        local equippedAugments = output:instanceValue("currentAugments", {stock, chamber, barrel})
        equippedAugments[augmentConfig.category] = augmentConfig
        output:setInstanceValue("currentAugments", equippedAugments)
        if augmentConfig.elementalType then
          output:setInstanceValue("elementalType", augmentConfig.elementalType)
        end

        --rebuild gun with current augments every time a new one is equipped

        local defaultPrimaryAbility = root.assetJson("/custom/items/weapons/ranged/modular/st_defaultParameters.config:".. output:instanceValue("category", "assaultRifle"))

        for k, augment in pairs(equippedAugments) do

          if augment.primaryAbility then
            for key, value in pairs(augment.primaryAbility) do
              defaultPrimaryAbility[key] = value
            end 
          end 

          output:setInstanceValue("primaryAbility", defaultPrimaryAbility) 

          if augment.inventoryIcon then
            local inventoryIcon = output:instanceValue("inventoryIcon") 

            local animationParts = output:instanceValue("animationParts") 
            if augment.category == "stock" then
              local index = string.find(inventoryIcon[1].image, "/[^/]*$")

              local filePath = string.sub(inventoryIcon[1].image, 1, index)

              inventoryIcon[1].image = filePath .. augment.inventoryIcon
              animationParts.butt = filePath .. augment.inventoryIcon
              if augment.fullbright then
                animationParts.buttfullbright = filePath .. augment.fullbright
              end
            elseif augment.category == "chamber" then
              local index = string.find(inventoryIcon[2].image, "/[^/]*$")

              local filePath = string.sub(inventoryIcon[2].image, 1, index)

              inventoryIcon[2].image = filePath .. augment.inventoryIcon
              animationParts.middle = filePath .. augment.inventoryIcon
              if augment.fullbright then
                animationParts.middlefullbright = filePath .. augment.fullbright
              end
            elseif augment.category == "barrel" then
              local index = string.find(inventoryIcon[3].image, "/[^/]*$")

              local filePath = string.sub(inventoryIcon[3].image, 1, index)

              inventoryIcon[3].image = filePath .. augment.inventoryIcon
              animationParts.barrel = filePath .. augment.inventoryIcon
              if augment.fullbright then
                animationParts.barrelfullbright = filePath .. augment.fullbright
              end
            end

            output:setInstanceValue("inventoryIcon", inventoryIcon)
            output:setInstanceValue("animationParts", animationParts)
          end
          
          if augment.animationCustom then
            output:setInstanceValue("animationCustom", augment.animationCustom)
          end

          if augment.animationCustom then
            local newAnimationCustom = {}
            for key, value in pairs(augment.animationCustom) do
              newAnimationCustom[key] = value
            end 
            output:setInstanceValue("animationCustom", newAnimationCustom)
          end  

        end
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