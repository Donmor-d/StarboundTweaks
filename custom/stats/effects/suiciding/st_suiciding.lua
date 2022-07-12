function init()
  
  script.setUpdateDelta(5)

  self.tickDamagePercentage = 0.25
  self.tickTime = 1
  self.tickTimer = self.tickTime
end

function update(dt)
  status.removeEphemeralEffect("medkitheal")
  status.removeEphemeralEffect("nanowrapheal")

  local sourceID = effect.sourceEntity()
  local activeStatus = status.activeUniqueStatusEffectSummary()

  self.tickTimer = self.tickTimer - dt
  status.overConsumeResource("health", self.tickDamagePercentage * dt)

  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    status.overConsumeResource("health", status.resourceMax("health") * 0.25)
  end
end

function uninit()
end
