function init()
  effect.setParentDirectives(config.getParameter("directives", ""))
  world.sendEntityMessage(entity.id(), "queueRadioMessage", "biomeradiation", 5.0)
  self.healthPercentage = config.getParameter("healthPercentage", 0.1)
  
  script.setUpdateDelta(5)

  self.tickDamagePercentage = 0.025
  self.tickTime = 1.0
  self.tickTimer = self.tickTime
end

function update(dt)
  status.setResourcePercentage("health", math.min(status.resourcePercentage("health"), self.healthPercentage))
  
   self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1,
        damageSourceKind = "poison",
        sourceEntityId = entity.id()
      })
  end

  effect.setParentDirectives(string.format("fade=00AA00=%.1f", self.tickTimer * 0.4))
end

function uninit()

end
