function GunFire:init()
  self:reset()

  self.rocketIds = {}

  self.weapon:setStance(self.stances.idle)

  if self.ammoUsage == nil then
    self.ammoUsage = self.energyUsage/10 or 0
  end

  self.cooldownTimer = self.reloadTime --increased delay until you can fire

  if self.cooldownTimer == nil then
    self.cooldownTimer = 1
  end

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

function GunFire:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.rocketIds = util.filter(self.rocketIds, world.entityExists)
  local rocketTargetPosition = activeItem.ownerAimPosition()
  local rocketTargetDirection = nil

  for _,rocketId in pairs(self.rocketIds) do
    world.callScriptedEntity(rocketId, "setTarget", rocketTargetPosition)
    world.callScriptedEntity(rocketId, "setTargetDirection", rocketTargetDirection)
  end

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if animator.animationState("firing") ~= "fire" then
    animator.setLightActive("muzzleFlash", false)
  end

  if self.fireMode == "primary" 
  and self.cooldownTimer == 0
  and status.resourceLocked("ammo") then
    
    animator.playSound("noAmmo")
    self.cooldownTimer = self.fireTime
  end  

  if self.fireMode == "primary"
  and not self.weapon.currentAbility
  and self.cooldownTimer == 0     
  and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then

    if self.fireType == "auto" then
      self:setState(self.auto)
    elseif self.fireType == "burst" then
      self:setState(self.burst)
    end
  end
end

function GunFire:auto()
  self.weapon:setStance(self.stances.fire)

  table.insert(self.rocketIds, self:fireProjectile())
  self:muzzleFlash()

  if self.stances.fire.duration then
    util.wait(self.stances.fire.duration)
  end

  if status.resourceLocked("ammo") then
    self.cooldownTimer = self.fireTime * 2 / (self.buttFireRateMult or 1)  / (self.barrelFireRateMult or 1)
  else
    self.cooldownTimer = self.fireTime / (self.buttFireRateMult or 1)  / (self.barrelFireRateMult or 1)
  end
  self:setState(self.cooldown)
  
end

function GunFire:burst()
  self.weapon:setStance(self.stances.fire)

  local shots = self.burstCount
  while shots > 0 do
    table.insert(self.rocketIds, self:fireProjectile())
    self:muzzleFlash()
    shots = shots - 1

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(1 - shots / self.burstCount, 0, self.stances.fire.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(1 - shots / self.burstCount, 0, self.stances.fire.armRotation))

    if status.resourceLocked("ammo") then
      util.wait(self.burstTime*2)
    else
      util.wait(self.burstTime)
    end
  end

  self.cooldownTimer = (self.fireTime - self.burstTime) * self.burstCount / (self.buttFireRateMult or 1)  / (self.barrelFireRateMult or 1)
end

function GunFire:reset()
end