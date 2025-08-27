require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/versioningutils.lua"
require "/items/buildscripts/abilities.lua"

function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue)
    if parameters[keyName] ~= nil then
      return parameters[keyName]
    elseif config[keyName] ~= nil then
      return config[keyName]
    else
      return defaultValue
    end
  end

  if level and not configParameter("fixedLevel", true) then
    parameters.level = level
  end

  setupAbility(config, parameters, "primary")
  setupAbility(config, parameters, "alt")

  -- elemental type and config (for alt ability)
  local elementalType = configParameter("elementalType", "physical")
  replacePatternInData(config, nil, "<elementalType>", elementalType)
  if config.altAbility and config.altAbility.elementalConfig then
    util.mergeTable(config.altAbility, config.altAbility.elementalConfig[elementalType])
  end

  -- calculate damage level multiplier
  config.damageLevelMultiplier = root.evalFunction("weaponDamageLevelMultiplier", configParameter("level", 1))

  -- palette swaps
  config.paletteSwaps = ""
  if config.palette then
    local palette = root.assetJson(util.absolutePath(directory, config.palette))
    local selectedSwaps = palette.swaps[configParameter("colorIndex", 1)]
    for k, v in pairs(selectedSwaps) do
      config.paletteSwaps = string.format("%s?replace=%s=%s", config.paletteSwaps, k, v)
    end
  end
  if type(config.inventoryIcon) == "string" then
    config.inventoryIcon = config.inventoryIcon .. config.paletteSwaps
  else
    for i, drawable in ipairs(config.inventoryIcon) do
      if drawable.image then drawable.image = drawable.image .. config.paletteSwaps end
    end
  end

  -- gun offsets
  if config.baseOffset then
    construct(config, "animationCustom", "animatedParts", "parts", "middle", "properties")
    construct(config, "animationCustom", "animatedParts", "parts", "butt", "properties")
    construct(config, "animationCustom", "animatedParts", "parts", "barrel", "properties")
    config.animationCustom.animatedParts.parts.butt.properties.offset = config.baseOffset
    config.animationCustom.animatedParts.parts.middle.properties.offset = config.baseOffset
    config.animationCustom.animatedParts.parts.barrel.properties.offset = config.baseOffset
    
    
    construct(config, "animationCustom", "animatedParts", "parts", "middleFullbright", "properties")
    construct(config, "animationCustom", "animatedParts", "parts", "buttFullbright", "properties")
    construct(config, "animationCustom", "animatedParts", "parts", "barrelFullbright", "properties")
    if config.animationCustom.animatedParts.parts.buttFullbright then
      config.animationCustom.animatedParts.parts.buttFullbright.properties.offset = config.baseOffset
    end
    if config.animationCustom.animatedParts.parts.middleFullbright then
      config.animationCustom.animatedParts.parts.middleFullbright.properties.offset = config.baseOffset
    end
    if config.animationCustom.animatedParts.parts.barrelFullbright then
      config.animationCustom.animatedParts.parts.barrelFullbright.properties.offset = config.baseOffset
    end

    if config.muzzleOffset then
      config.muzzleOffset = vec2.add(config.muzzleOffset, config.baseOffset)
    end
  end

  -- populate tooltip fields
  if config.tooltipKind ~= "base" then
    config.tooltipFields = {}
    config.tooltipFields.levelLabel = util.round(configParameter("level", 1), 1)
    config.tooltipFields.dpsLabel = util.round((config.primaryAbility.baseDps or 0) * config.damageLevelMultiplier, 1)
    config.tooltipFields.speedLabel = util.round(1 / (config.primaryAbility.fireTime or 1.0), 1)
    config.tooltipFields.damagePerShotLabel = util.round((config.primaryAbility.baseDps or 0) * (config.primaryAbility.fireTime or 1.0) * config.damageLevelMultiplier, 1)
    config.tooltipFields.energyPerShotLabel = util.round((config.primaryAbility.energyUsage or 0) * (config.primaryAbility.fireTime or 1.0), 1)
	--ammo
    config.tooltipFields.ammoPerShotLabel = config.primaryAbility.ammoUsage or 0
    if elementalType ~= "physical" then
      config.tooltipFields.damageKindImage = "/interface/elements/"..elementalType..".png"
    end
    if config.primaryAbility then
      config.tooltipFields.primaryAbilityTitleLabel = "Primary:"
      config.tooltipFields.primaryAbilityLabel = config.primaryAbility.name or "unknown"
    end
    if config.altAbility then
      config.tooltipFields.altAbilityTitleLabel = "Special:"
      config.tooltipFields.altAbilityLabel = config.altAbility.name or "unknown"
    end

    if config.acceptsAugmentType then
      config.tooltipFields.weaponTypeImage = "/custom/interface/tooltips/ammo/" .. config.acceptsAugmentType .. ".png"
    end

    if parameters.currentAugments then
      if parameters.currentAugments.stock then
        config.tooltipFields.stockIconImage = parameters.currentAugments.stock.displayIcon
      end
      if parameters.currentAugments.chamber then
        config.tooltipFields.chamberIconImage = parameters.currentAugments.chamber.displayIcon
      end
      if parameters.currentAugments.barrel then
        config.tooltipFields.barrelIconImage = parameters.currentAugments.barrel.displayIcon
      end
    end

  end

  -- set price
  -- TODO: should this be handled elsewhere?
  config.price = (config.price or 0) * root.evalFunction("itemLevelPriceMultiplier", configParameter("level", 1))

  return config, parameters
end
