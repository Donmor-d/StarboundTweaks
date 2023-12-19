function build(directory, config, parameters, level, seed)

  config.tooltipFields = config.tooltipFields or {}

  config.tooltipFields.damagePerShotLabel = config.augment.primaryAbility.baseDps

  if config.augment.primaryAbility.fireTime then
    local rateOfFire = math.floor((1/config.augment.primaryAbility.fireTime)*100)/100
    config.tooltipFields.rateOfFireLabel = rateOfFire.."/s"
  end
  
  config.tooltipFields.ammoPerShotLabel = config.augment.primaryAbility.ammoUsage
  
  
  config.tooltipFields.weaponTypeLabel = config.typeName

  if config.notes then
    config.tooltipFields.notesLabel = config.notes
  end

  return config, parameters
end