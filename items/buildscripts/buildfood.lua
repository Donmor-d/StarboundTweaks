function build(directory, config, parameters, level, seed)
  if not parameters.timeToRot then
    local rottingMultiplier = parameters.rottingMultiplier or config.rottingMultiplier or 1.0
    parameters.timeToRot = root.assetJson("/items/rotting.config:baseTimeToRot") * rottingMultiplier
  end

  config.tooltipFields =  {}
  config.tooltipFields.rotTimeLabel = getRotTimeDescription(parameters.timeToRot)
  config.tooltipFields.rotTimerLabel = getRotTimerInClockFormat(parameters.timeToRot)
 

  if config.effects then
    local effectNumber = math.min(#config.effects[1], 10)
    for i = 1, effectNumber do
      --sb.logInfo(config.effects[1][i].effect)

      config.tooltipFields["foodBuff"..tostring(i).."Image"] = "/custom/interface/statusinterface/"..config.effects[1][i].effect..".png" or ""
    end
  end

  
  --_G["config.tooltipFields.foodBuffImage"..tostring(i)] = "/interface/elements/"..parameters.effects[i].effect..".png"
  return config, parameters
end

function getRotTimeDescription(rotTime)
  local descList = root.assetJson("/items/rotting.config:rotTimeDescriptions")
  for i, desc in ipairs(descList) do
    if rotTime <= desc[1] then return desc[2] end
  end
  return descList[#descList]
end

function getRotTimerInClockFormat(rotTimer)
  local hours = rotTimer/3600
  local minutes = (hours % 1) * 60
  local seconds = (minutes % 1) * 60

  hours = math.floor(hours)
  minutes = math.floor(minutes)

  if seconds == 60 then
    seconds = 0
  end

  return string.format("%02.f:%02.f:%02.f", hours, minutes, seconds)
end