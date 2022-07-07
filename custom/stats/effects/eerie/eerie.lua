function init()
  local removeEffects = config.getParameter("removeEffects")

  for k, v in pairs(removeEffects) do
    status.removeEphemeralEffect(v)
  end



  local message = config.getParameter("message")
  world.sendEntityMessage(entity.id(), "queueRadioMessage", message)

  self.powerModifier = config.getParameter("powerModifier", 0)
  effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = self.powerModifier}})

  self.negativeMultiplier = ((2 - self.powerModifier)) / self.powerModifier

  self.lunacy = 0
  lock = false
end

function update(dt)
  local currentLunacy = status.resource("lunacy")

  if self.lunacy > currentLunacy then
    if not lock then 
      status.addPersistentEffect("eerieWithdrawal",{ stat = "powerMultiplier", effectiveMultiplier = self.negativeMultiplier});
      lock = true
    end
  else
    status.clearPersistentEffects("eerieWithdrawal")
    lock = false
  end

  self.lunacy = status.resource("lunacy")
end

function uninit()
  status.clearPersistentEffects("eerieWithdrawal")
end
