function ageItem(baseItem, aging)
  --baseItem.parameters.timeToRot = 100
  if baseItem.parameters.timeToRot then
    baseItem.parameters.timeToRot = baseItem.parameters.timeToRot - aging

    baseItem.parameters.tooltipFields = baseItem.parameters.tooltipFields or {}
    baseItem.parameters.tooltipFields.rotTimeLabel = getRotTimeDescription(baseItem.parameters.timeToRot)
    baseItem.parameters.tooltipFields.rotTimerLabel = getRotTimerInClockFormat(baseItem.parameters.timeToRot)

    sb.logError(sb.print(baseItem))
    if baseItem.parameters.timeToRot <= 0 then
      return 
    end
  end

  return baseItem
  
  --[[    descobrir uma forma de atualizar o valor da comida de acordo com o tempo que falta para estragar
  return {
    name = baseItem.name,
    count = baseItem.count,
    parameters = { 
      --foodValue = -50,
      timeToRot = baseItem.parameters.timeToRot
    }
  }
  ]]
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