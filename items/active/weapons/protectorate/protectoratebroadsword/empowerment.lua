Empowerment = WeaponAbility:new()

function Empowerment:init()
  self.cooldownTimer = self.cooldownTime

  self.active = false

  --needed for thing below
  self.soundlock = 0
  self.flashtime = 0.1
  self.flashtimer = 0
  
  self.maxPowerTime = 3.5
  self.powerTimer = self.maxPowerTime
end

function Empowerment:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

 --adds a sound and a brief glow when the cooldown timer is at 0
  if self.cooldownTimer == 0 then
    if self.soundlock == 0 then
      animator.playSound("recharge")
      animator.setGlobalTag("bladeDirectives", "fade=FFFFFFFF=0.15")
      self.soundlock = 1
      self.flashtimer = self.flashtime
    end

    if self.flashtimer > 0 then
      self.flashtimer = math.max(0, self.flashtimer - dt)
      if self.flashtimer == 0 then
        animator.setGlobalTag("bladeDirectives", "")
      end
    end
  end

  --limits how long you can use the ability
  if self.active and self.powerTimer > 0 and self.cooldownTimer == 0 then
    self.powerTimer = math.max(0, self.powerTimer - dt)
  end

  if self.active and self.powerTimer == 0 then
    self:setState(self.windup)
    self.powerTimer = self.maxPowerTime
  end



  if self.active and not status.overConsumeResource("energy", self.energyPerSecond * self.dt) then
    self.active = false
  end

  if fireMode == "alt"
      and not self.weapon.currentAbility
      and self.cooldownTimer == 0
      and not status.resourceLocked("energy") then

    if self.active then
      self:setState(self.windup)
      self.powerTimer = self.maxPowerTime --resets on projectile launch
    else
      self:setState(self.empower)
    end
  end
end

function Empowerment:empower()
  self.weapon:setStance(self.stances.empower)

  util.wait(self.stances.empower.durationBefore)

  animator.playSound("empower")
  self.active = true

  util.wait(self.stances.empower.durationAfter)
end

function Empowerment:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()

  util.wait(self.stances.windup.duration)

  self:setState(self.fire)
end

function Empowerment:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  local position = vec2.add(mcontroller.position(), {self.projectileOffset[1] * mcontroller.facingDirection(), self.projectileOffset[2]})
  local params = {
    powerMultiplier = activeItem.ownerPowerMultiplier(),
    power = self:damageAmount()
  }
  world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), self:aimVector(), false, params)

  animator.playSound("slash")
  
  self.active = false

  util.wait(self.stances.fire.duration)

  self.cooldownTimer = self.cooldownTime

  --also needed
  self.soundlock = 0
end

function Empowerment:uninit()

end

function Empowerment:aimVector()
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle)
  aimVector[1] = aimVector[1] * self.weapon.aimDirection
  return aimVector
end

function Empowerment:damageAmount()
  return self.baseDamage * config.getParameter("damageLevelMultiplier")
end
