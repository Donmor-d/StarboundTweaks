function init()
  animator.setParticleEmitterOffsetRegion("icetrail", mcontroller.boundBox())
  animator.setParticleEmitterActive("icetrail", true)
  effect.setParentDirectives("fade=00BBFF=0.15")
  
  effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = 0.75}}) --reduces damage done by victim

  script.setUpdateDelta(5)
  effect.addStatModifierGroup({
    {stat = "jumpModifier", amount = -0.15}
  })
  self.speedMult = 1
end

function update(dt)
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
    self.speedMult = math.min(self.speedMult + dt/2, 1)
  end

  mcontroller.controlModifiers({
      groundMovementModifier = 0.3 * self.speedMult,
      speedModifier = 0.75 * self.speedMult,
      airJumpModifier = 0.85 * self.speedMult
    })
end

function uninit()

end
