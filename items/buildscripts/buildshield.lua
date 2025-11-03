require "/scripts/util.lua"
require "/scripts/staticrandom.lua"

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

  if level and not configParameter("fixedLevel", false) then
    parameters.level = level
  end

  -- initialize randomization
  if seed then
    parameters.seed = seed
  else
    seed = configParameter("seed")
    if not seed then
      math.randomseed(util.seedTime())
      seed = math.random(1, 4294967295)
      parameters.seed = seed
    end
  end

  --randomised valores
  parameters.baseShieldHealth = randomIntInRange(configParameter("baseShieldHealth"), seed, "baseShieldHealth")
  parameters.cooldownTime = math.floor(randomInRange(configParameter("cooldownTime"), seed, "cooldownTime") * 10) / 10

  -- select the generation profile to use
  local builderConfig = {}
  if config.builderConfig then
    builderConfig = randomFromList(config.builderConfig, parameters.seed, "builderConfig")
  end

  -- build palette swap directives
  local paletteSwaps = ""
  if builderConfig.palette then
    local palette = root.assetJson(util.absolutePath(directory, builderConfig.palette))
    local selectedSwaps = randomFromList(palette.swaps, parameters.seed, "paletteSwaps")
    for k, v in pairs(selectedSwaps) do
      paletteSwaps = string.format("%s?replace=%s=%s", paletteSwaps, k, v)
    end
  end

  -- name
  if not parameters.shortdescription and builderConfig.nameGenerator then
    parameters.shortdescription = root.generateName(util.absolutePath(directory, builderConfig.nameGenerator))
  end

  -- merge extra animationCustom
  if builderConfig.animationCustom then
    config.animationCustom = util.mergeTable(config.animationCustom or {}, builderConfig.animationCustom)
  end

  -- animation parts
  if builderConfig.animationParts then
    if parameters.animationParts == nil then parameters.animationParts = {} end
    for k, v in pairs(builderConfig.animationParts) do
      if parameters.animationParts[k] == nil then
        if type(v) == "table" then
          parameters.animationParts[k] = util.absolutePath(directory, string.gsub(v.path, "<variant>", randomIntInRange({1, v.variants}, parameters.seed, "animationPart"..k)))
        else
          parameters.animationParts[k] = v
        end

        -- use near idle frame of shield for inventory icon for now
        if k == "shield" and not parameters.inventoryIcon then
          parameters.inventoryIcon = parameters.animationParts[k]..":nearidle"
        end
      end
    end
  end

  -- set price
  config.price = configParameter("price", 0) * root.evalFunction("itemLevelPriceMultiplier", configParameter("level", 1))

  -- tooltip fields
  config.tooltipFields = {}
  config.tooltipFields.healthLabel = util.round(parameters.baseShieldHealth * root.evalFunction("shieldLevelMultiplier", configParameter("level", 1)), 0)
  config.tooltipFields.cooldownLabel = parameters.cooldownTime
  if configParameter("parryEffect", "") == "" and #config.parryEffects <= 0 then
    config.tooltipFields.parryEffectLabel = "none" 
  else 
    config.tooltipFields.parryEffectLabel = configParameter("parryEffect", "") 
  end

  config.parryEffects = configParameter("parryEffects", {}) 

  if #config.parryEffects > 0 and not config.parryEffects[1].effect then
    config.parryEffects = config.parryEffects[math.random(#config.parryEffects)]
  end

  if config.parryEffects then
    local effectNumber = math.min(#config.parryEffects, 3)
    for i = 1, effectNumber do
      config.tooltipFields["parryBuff"..tostring(i).."Image"] = "/custom/interface/statusinterface/"..config.parryEffects[i].effect..".png" or ""
    end
  end
  return config, parameters
end
