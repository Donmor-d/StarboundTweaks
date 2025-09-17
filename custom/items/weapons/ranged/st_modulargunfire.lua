function GunFire:fireProjectile(projectileType, projectileParams, inaccuracy, firePosition, projectileCount)
  --self.fired = true
  local element = config.getParameter("elementalType", "physical")
  local projectileCategory = self.projectileCategory or "default"
  local params = sb.jsonMerge(self.elementalConfig[element].primaryAbility[projectileCategory].projectileParameters or {}, projectileParams or {})
  params.power = self:damagePerShot() * (self.buttDamageMult or 1) * (self.middleDamageMult or 1) * (self.barrelDamageMult or 1) --could do better by getting the augment types and their multiplier but oh well
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.speed = util.randomInRange(params.speed)

  if not projectileType then
      projectileType = self.elementalConfig[element].primaryAbility[projectileCategory].projectileType
  end
  if type(projectileType) == "table" then
      projectileType = projectileType[math.random(#projectileType)]
  end

  self.projectileId = 0
  for i = 1, (projectileCount or self.projectileCount) do
      if params.timeToLive then
      params.timeToLive = util.randomInRange(params.timeToLive)
      end
      self.projectileId = world.spawnProjectile(
          projectileType,
          firePosition or self:firePosition(),
          activeItem.ownerEntityId(),
          self:aimVector(inaccuracy or self.inaccuracy),
          false,
          params
      )
  end

  return self.projectileId
end

function GunFire:auto()
  self.weapon:setStance(self.stances.fire)

  self:fireProjectile()
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
    self:fireProjectile()
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

function GunFire:cooldown()
  self.weapon:setStance(self.stances.cooldown)
  self.weapon:updateAim()

  local progress = 0
  local cooldown = math.min(self.fireTime / (self.buttFireRateMult or 1)  / (self.barrelFireRateMult or 1), self.stances.cooldown.duration)
  util.wait(cooldown, function()
    local from = self.stances.cooldown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}

    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.armRotation, self.stances.idle.armRotation))

    progress = math.min(1.0, progress + (self.dt / cooldown))
  end)
end