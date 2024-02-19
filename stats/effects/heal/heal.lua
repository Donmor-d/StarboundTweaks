function init()
  animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
  animator.setParticleEmitterEmissionRate("healing", config.getParameter("emissionRate", 3))
  animator.setParticleEmitterActive("healing", true)

  script.setUpdateDelta(5)

  self.healingRate = config.getParameter("healAmount", 30) / effect.duration()

  local activeStatus = status.activeUniqueStatusEffectSummary()
  for i = 1, #activeStatus do
    if activeStatus[i][1] == "weakpoison" then
      self.healingRate = self.healingRate * 0.75
    end
  end
end

function update(dt)
  status.modifyResource("health", self.healingRate * dt)
end

function uninit()
  status.addEphemeralEffect("st_recovering")
end
