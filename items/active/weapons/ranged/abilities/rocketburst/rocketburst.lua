require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

RocketBurst = GunFire:new()

function RocketBurst:new(abilityConfig)
  local primary = config.getParameter("primaryAbility")
  return GunFire.new(self, sb.jsonMerge(primary, abilityConfig))
end

function RocketBurst:init()
  self.cooldownTimer = self.fireTime
end

function RocketBurst:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
  
  local primaryEnabler = config.getParameter("primaryAltAbility")    --necessário para o bagui abaixo funcionar

  if primaryEnabler == "allow" then
     if self.fireMode == "primary"
       and not self.weapon.currentAbility
       and self.cooldownTimer == 0 
       and not world.lineTileCollision(mcontroller.position(), self:firePosition())
       and not status.resourceLocked("energy")  then
      self:setState(self.burst)
    end
  else 
    if self.fireMode == "alt"
       and not self.weapon.currentAbility
       and self.cooldownTimer == 0 
       and not world.lineTileCollision(mcontroller.position(), self:firePosition())
       and not status.resourceLocked("energy")  then
      self:setState(self.burst)
    end
  end
  
  --[[     original abaixo, adicionei uma variável que checa se ele permite usar a abilidade com m1 ou não, a abilidade primária deve ter um firerate absurdo para que ele não sobrepoa a abilidade
  if self.fireMode == "alt"
    and not self.weapon.currentAbility
    and self.cooldownTimer == 0
    and not status.resourceLocked("energy")
    and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then
    
    self:setState(self.burst)
  end
  ]]--
  
end

function RocketBurst:fireProjectile(...)
  local projectileId = GunFire.fireProjectile(self, ...)
  world.callScriptedEntity(projectileId, "setApproach", self:aimVector(0))
end

function RocketBurst:muzzleFlash()
  animator.burstParticleEmitter("altMuzzleFlash", true)
  animator.playSound("altFire")
end
