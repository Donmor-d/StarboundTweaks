function init()
  local removeEffects = config.getParameter("removeEffects")

  --remove the other eerie effects on start
  for k, v in pairs(removeEffects) do
    status.removeEphemeralEffect(v)
  end

  local message = config.getParameter("message")
  world.sendEntityMessage(entity.id(), "queueRadioMessage", message)

  self.powerModifier = config.getParameter("powerModifier", 0)
  effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = self.powerModifier}})

  self.negativeMultiplier = ((2 - self.powerModifier)) / self.powerModifier

  self.lunacy = 0
  self.lock = false
  self.timer = 1
  self.canSpawn = config.getParameter("canSpawn")
  --self.monsterList = config.getParameter("spawnList") for use later
end

function update(dt)
  local currentLunacy = status.resource("lunacy")

  local playerPos = entity.position()
  local spawnPos = playerPos
  spawnPos[1] = spawnPos[1] + math.random(-10 , 10)

  if self.lunacy > currentLunacy then
    if not self.lock then 
      status.addPersistentEffect("eerieWithdrawal",{ stat = "powerMultiplier", effectiveMultiplier = self.negativeMultiplier});
      self.lock = true
    end
  else
    status.clearPersistentEffects("eerieWithdrawal")
    self.lock = false
  end

  self.lunacy = status.resource("lunacy")

  self.timer = math.max(self.timer - dt, 0)

  if self.timer <= 0 
  and not world.lineTileCollision(playerPos, spawnPos) 
  and self.canSpawn then
    
    world.spawnMonster("punchy", spawnPos)
    self.timer = 1
  end

end

function uninit()
  status.clearPersistentEffects("eerieWithdrawal")
end
