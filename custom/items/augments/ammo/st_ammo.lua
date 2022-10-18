require "/scripts/augments/item.lua"

function apply(input)
  local augmentConfig = config.getParameter("augment")
  local output = Item.new(input)

  local weaponType = output:instanceValue("acceptsAugmentType", "")

  if augmentConfig then
    if weaponType == augmentConfig.type or isCompatible(augmentConfig.type, weaponType) then --checks if compatible, 
      local currentAugment = output:instanceValue("currentAugment")
      if currentAugment then
        if currentAugment.name == augmentConfig.name then
          return nil
        end
      end
      
      local currentAbility = output:instanceValue("altAbilityType")
      if currentAbility and augmentConfig.altAbilityType then
        if currentAbility == augmentConfig.altAbilityType then
          return nil
        end
      end
      
      
      local elementType = output:instanceValue("elementalType")
      if augmentConfig.altAbilityType then
        if elementType == "physical" and augmentConfig.elementalAbility then --checa se a abilidade é elemental e não coloca se a arma é physical (algumas habilidades só funcionam se a arma tiver um elemento) / checks if the ability is elemental and doesnt apply if the weapon is physical(certain abilities only work when the weapon has an element)
          return nil
        end
        output:setInstanceValue("altAbilityType", augmentConfig.altAbilityType)
      else
        output:setInstanceValue("currentAugment", augmentConfig)
        output:setInstanceValue("elementalType", augmentConfig.elementalType)
        output:setInstanceValue("primaryAbility", augmentConfig.primaryAbility) 
        
        output:setInstanceValue("animationParts", augmentConfig.animationParts) --muda a textura da arma (olhar "massaultrifle.activeitem" e t1marelectricbullet.augment / changes weapon texture
        output:setInstanceValue("inventoryIcon", augmentConfig.inventoryIcon)
  
        output:setInstanceValue("animationCustom", augmentConfig.animationCustom)
      end
      return output:descriptor(), 1
    end
  end
end

function isCompatible(table, type) --checa se um dos elementos da table é o mesmo que o type / checks if one of the elements from a table is the same as the type
  for _, value in pairs(table) do
    if value == type then
      return true
    end
  end
  return false
end