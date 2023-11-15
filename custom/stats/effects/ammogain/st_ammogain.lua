function init()

  script.setUpdateDelta(5)

  self.ammoRegain = config.getParameter("ammoGain", 50)
  
  animator.burstParticleEmitter("ammoup")
end

function update(dt)
  status.modifyResource("ammo", self.ammoRegain)
end

function uninit()
  
end
