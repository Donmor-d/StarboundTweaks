require "/scripts/status.lua"

function init()
  self.currentProtection = status.stat("protection")
  self.damageReduction = config.getParameter("damageReduction")

  effect.addStatModifierGroup({
    {stat = "protection", amount = (100 - self.currentProtection) * self.damageReduction},
  })
end

function update(dt)
end

function uninit()

end