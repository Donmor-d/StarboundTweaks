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
      return output:descriptor(), 0
    end
  end
end

function isCompatible(table, type) --checa se um dos elementos da table é o mesmo que o type assim uma bala pode ser usada por dois tipos de armas diferentes
  for _, value in pairs(table) do
    if value == type then
      return true
    end
  end
  return false
end

--[[
-- não usado, talvez para futuros planos para simplificar o processo
function primaryDefaultParameters(augmentType)
  local params = {
    assaultrifleammo = {
      scripts = {"/items/active/weapons/ranged/gunfire.lua"},
      class = "GunFire",  
      fireTime = 0.11,
      baseDps = 16,
      energyUsage = 0,
      ammoUsage = 1.5,
      inaccuracy = 0.02,

      reloadTime = 1.5,

      projectileType = "standardbullet",
      projectileParameters = {
        knockback = 5
      },
      projectileCount = 1,

      stances = {
        idle = {
          armRotation = 0,
          weaponRotation = 0,
          twoHanded = true,
  
          allowRotate = true,
          allowFlip = true
        },
        fire = {
          duration = 0,
          armRotation = 2,
          weaponRotation = 4,
          twoHanded = true,
          recoil = true,
  
          allowRotate = true,
          allowFlip = true
        },
        cooldown = {
          duration = 0.11,
          armRotation = 2,
          weaponRotation = 4,
          twoHanded = true,
          recoil= true,
  
          allowRotate = true,
          allowFlip = true
        }
      }
    },
    rocketlauncherammo = {
      scripts = {"/items/active/weapons/ranged/gunfire.lua"},
      class = "GunFire",  
      fireTime = 1.5,
      baseDps = 10,
      energyUsage = 0,
      ammoUsage = 7.5,
      inaccuracy = 0.0,

      projectileType = "rocketshell",
      projectileParameters = {},
      projectileCount = 1,

      stances = {
        idle = {
          armRotation = 0,
          weaponRotation = 0,
          twoHanded = true,
  
          allowRotate = true,
          allowFlip = true
        },
        fire = {
          duration = 0,
          armRotation = 0,
          weaponRotation = 0,
          weaponOffset = [-0.2, 0],
          twoHanded = true,
          recoil = true,
  
          allowRotate = true,
          allowFlip = true
        },
        cooldown = {
          duration = 1.5,
          armRotation = 0,
          weaponRotation = 0,
          weaponOffset = [-0.2, 0],
          twoHanded = true,
          recoil= true,
  
          allowRotate = true,
          allowFlip = true
        }
      }
    },
    grenadelauncherammo = {
      scripts = {"/items/active/weapons/ranged/gunfire.lua"},
      class = "GunFire",  
      fireTime = 1.0,
      baseDps = 6,
      energyUsage = 0,
      ammoUsage = 4.5,
      inaccuracy = 0.0,

      projectileType = "grenade",
      projectileParameters = {
        bounces = 0
      },
      projectileCount = 1,

      stances = {
        idle = {
          armRotation = 0,
          weaponRotation = 0,
          twoHanded = false,
  
          allowRotate = true,
          allowFlip = true
        },
        fire = {
          duration = 0,
          armRotation = 7.5,
          weaponRotation = 7.5,
          twoHanded = false,
          recoil = true,
  
          allowRotate = true,
          allowFlip = true
        },
        cooldown = {
          duration = 0.4,
          armRotation = 7.5,
          weaponRotation = 7.5,
          twoHanded = false,
          recoil= true,
  
          allowRotate = true,
          allowFlip = true
        }
      }
    },
    machinepistolammo = {
      scripts = {"/items/active/weapons/ranged/gunfire.lua"},
      class = "GunFire",  
      fireTime = 0.11,
      baseDps = 8.5,
      energyUsage = 0,
      ammoUsage = 1,
      inaccuracy = 0.04,

      reloadTime = 1,

      projectileType = "standardbullet",
      projectileParameters = {
        knockback = 5
      },
      projectileCount = 1,

      stances = {
        idle = {
          armRotation = 0,
          weaponRotation = 0,
          twoHanded = true,
  
          allowRotate = true,
          allowFlip = true
        },
        fire = {
          duration = 0,
          armRotation = 2,
          weaponRotation = 4,
          twoHanded = true,
          recoil = true,
  
          allowRotate = true,
          allowFlip = true
        },
        cooldown = {
          duration = 0.11,
          armRotation = 2,
          weaponRotation = 4,
          twoHanded = true,
          recoil= true,
  
          allowRotate = true,
          allowFlip = true
        }
      }
    },
    pistolammo = {
      scripts = {"/items/active/weapons/ranged/gunfire.lua"},
      class = "GunFire",  
      fireTime = 0.6,
      baseDps = 9,
      energyUsage = 0,
      ammoUsage = 3,
      inaccuracy = 0.025,

      reloadTime = 1,

      projectileType = "standardbullet",
      projectileParameters = {
        knockback = 5
      },
      projectileCount = 1,

      stances = {
        idle = {
          armRotation = 0,
          weaponRotation = 0,
          twoHanded = true,
  
          allowRotate = true,
          allowFlip = true
        },
        fire = {
          duration = 0,
          armRotation = 4,
          weaponRotation = 6,
          twoHanded = true,
          recoil = true,
  
          allowRotate = true,
          allowFlip = true
        },
        cooldown = {
          duration = 0.15,
          armRotation = 4,
          weaponRotation = 6,
          twoHanded = true,
          recoil= true,
  
          allowRotate = true,
          allowFlip = true
        }
      }
    },
    shotgunammo = {
      scripts = {"/items/active/weapons/ranged/gunfire.lua"},
      class = "GunFire",  
      fireTime = 1.2,
      baseDps = 20,
      energyUsage = 0,
      ammoUsage = 4.5,
      inaccuracy = 0.12,

      reloadTime = 1.5,

      projectileType = "st_normalpellet",
      projectileParameters = {
        damageKind : shotgunbullet,
        knockback : 30
      },
      projectileCount = 8,

      stances = {
        idle = {
          armRotation = 0,
          weaponRotation = 0,
          twoHanded = true,
  
          allowRotate = true,
          allowFlip = true
        },
        fire = {
          duration = 0,
          armRotation = 8,
          weaponRotation = 8,
          twoHanded = true,
          recoil = true,
  
          allowRotate = true,
          allowFlip = true
        },
        cooldown = {
          duration = 0.15,
          armRotation = 8,
          weaponRotation = 8,
          twoHanded = true,
          recoil= true,
  
          allowRotate = true,
          allowFlip = true
        }
      }
    },
    sniperrifleammo = {
      scripts = {"/items/active/weapons/ranged/gunfire.lua"},
      class = "GunFire",  
      fireTime = 1.0,
      baseDps = 10,
      energyUsage = 0,
      ammoUsage = 4.5,
      inaccuracy = 0.008,

      reloadTime = 1.5,

      projectileType = "st_sniperbullet",
      projectileParameters = {
        knockback : 20
      },
      projectileCount = 1,

      stances = {
        idle = {
          armRotation = 0,
          weaponRotation = 0,
          twoHanded = true,
  
          allowRotate = true,
          allowFlip = true
        },
        fire = {
          duration = 0,
          armRotation = 6,
          weaponRotation = 10,
          twoHanded = true,
          recoil = true,
  
          allowRotate = true,
          allowFlip = true
        },
        cooldown = {
          duration = 0.15,
          armRotation = 6,
          weaponRotation = 10,
          twoHanded = true,
          recoil= true,
  
          allowRotate = true,
          allowFlip = true
        }
      }
    }
  }
  return params[augmentType]
end
]]