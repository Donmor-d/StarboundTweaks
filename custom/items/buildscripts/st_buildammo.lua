function build(directory, config, parameters, level, seed)

  config.tooltipFields = config.tooltipFields or {}

  local augmentType = config.augment.type or "anyammo"

  -- if config.augment.primaryAbility then

  --   config.tooltipFields.damagePerShotLabel = config.augment.primaryAbility.baseDps or ""

  --   if config.augment.primaryAbility.fireTime then
  --     local rateOfFire = math.floor((1/config.augment.primaryAbility.fireTime)*100)/100
  --     config.tooltipFields.rateOfFireLabel = rateOfFire.."/s"
  --   end
  --   config.tooltipFields.ammoPerShotLabel = config.augment.primaryAbility.ammoUsage or ""

  -- end
  
  --config.tooltipFields.weaponTypeLabel = config.typeName
  if type(config.augment.type) == "table" then
    for key, type in ipairs(config.augment.type) do
      config.tooltipFields["weaponType" .. tostring(key) .. "Image"] = "/custom/interface/tooltips/ammo/" .. config.augment.category .. type .. ".png"
    end
  else
    config.tooltipFields.weaponType1Image = "/custom/interface/tooltips/ammo/" .. config.augment.category .. config.augment.type .. ".png"
  end

  if config.notes then
    config.tooltipFields.notesLabel = config.notes
  end

  return config, parameters
end