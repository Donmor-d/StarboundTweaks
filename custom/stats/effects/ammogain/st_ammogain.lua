function init()

  script.setUpdateDelta(5)

  self.ammoRegain = config.getParameter("ammoGain", 50)
 
end

function update(dt)
  status.modifyResource("ammo", self.ammoRegain)
end

function uninit()
  
end
