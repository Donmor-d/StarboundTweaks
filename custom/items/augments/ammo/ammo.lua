require "/scripts/augments/item.lua"

function apply(input)
  local augmentConfig = config.getParameter("augment")
  local output = Item.new(input)
  if augmentConfig then
    if output:instanceValue("acceptsAugmentType", "") == augmentConfig.type then
      local currentAugment = output:instanceValue("currentAugment")
      if currentAugment then
        if currentAugment.name == augmentConfig.name then
          return nil
        end
      end
      output:setInstanceValue("currentAugment", augmentConfig)
      output:setInstanceValue("elementalType", augmentConfig.elementalType) -- muda o elemento da arma para o da bala
      output:setInstanceValue("primaryAbility", augmentConfig.primaryAbility) -- muda as propriedades da abilidade primária (m1)
	  output:setInstanceValue("animationParts", augmentConfig.animationParts) --muda a textura da arma (olhar "massaultrifle.activeitem" e t1marelectricbullet.augment
	  output:setInstanceValue("altAbilityType", augmentConfig.altAbilityType)
      return output:descriptor(), 1
    end
  end
end