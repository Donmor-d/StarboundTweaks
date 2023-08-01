function init()
  animator.setParticleEmitterOffsetRegion("icetrail", mcontroller.boundBox())
  animator.setParticleEmitterActive("icetrail", true)
  effect.setParentDirectives("fade=00BBFF=0.15")
  
  effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = 0.75}}) --reduces damage done by victim

  script.setUpdateDelta(5)
  effect.addStatModifierGroup({
    {stat = "jumpModifier", amount = -0.15}
  })
  self.defaultSpeedMult = 1
  self.speedMult = self.defaultSpeedMult

  self.block = true
end

function update(dt)
  if effect.duration() > 4.9 and not self.block then  --Cada reaplicacao reseta a duração, então a cada vez que a duração fica 5s (que é a defaultDuration), 4.9 pois o ele é detectado entre 4.9 e 5
    self.defaultSpeedMult = self.defaultSpeedMult - self.defaultSpeedMult/4
    self.block = true
  else
    self.block = false
  end

  local sourceID = effect.sourceEntity()
  local activeStatus = status.activeUniqueStatusEffectSummary()

  for i = 1, #activeStatus do
    if activeStatus[i][1] == "weakpoison" then
      status.addEphemeralEffect("st_commoncold", nil, sourceID)
    end
  end

  if effect.duration() and world.liquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1}) then --if touching water, eventually slows more
    local liquidID =world.liquidAt({mcontroller.xPosition(), mcontroller.yPosition() - 1})[1] 
      if liquidID == 1  or liquidID == 6 or liquidID == 12 then
        self.speedMult = math.max(self.speedMult - dt/2, 0.1)
      end
  else  
    self.speedMult = math.min(self.speedMult + dt/2, self.defaultSpeedMult)
  end

  mcontroller.controlModifiers({
      groundMovementModifier = 0.3 * self.speedMult,
      speedModifier = 0.75 * self.speedMult,
      airJumpModifier = 0.85 * self.speedMult
    })
end

function uninit()

end
