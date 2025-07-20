function GunFire:init()

  if self.critMultiplier == nil then
    self.critMultiplier = 3
  end

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

function GunFire:auto()
  self.weapon:setStance(self.stances.fire)
  self.roll = math.random(100)
  self:fireProjectile()
  self:muzzleFlash()

  if self.stances.fire.duration then
    util.wait(self.stances.fire.duration)
  end
  
  if status.resourceLocked("ammo") then
    self.cooldownTimer = self.fireTime * 2 / (self.stockFireRateMult or 1)  / (self.barrelFireRateMult or 1)
  else
    self.cooldownTimer = self.fireTime / (self.stockFireRateMult or 1)  / (self.barrelFireRateMult or 1)
  end

  self:setState(self.cooldown)
end

function GunFire:burst()
  self.weapon:setStance(self.stances.fire)

  local shots = self.burstCount
  while shots > 0 do
    self.roll = math.random(100)
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

  self.cooldownTimer = (self.fireTime - self.burstTime) * self.burstCount / (self.stockFireRateMult or 1)  / (self.barrelFireRateMult or 1)
end

function GunFire:muzzleFlash()
  animator.setPartTag("muzzleFlash", "variant", math.random(1, self.muzzleFlashVariants or 3))
  animator.setAnimationState("firing", "fire")
  animator.burstParticleEmitter("muzzleFlash")
  status.overConsumeResource("ammo", self.ammoUsage)
  
  if self.roll < self.critChance then
    animator.playSound("empoweredFire")
  else
    animator.playSound("fire")
  end

  animator.setLightActive("muzzleFlash", true)
end

function GunFire:fireProjectile(projectileType, projectileParams, inaccuracy, firePosition, projectileCount)
  
  local element = config.getParameter("elementalType", "physical")
  local projectileCategory = self.projectileCategory or "default"
  local params = sb.jsonMerge(self.projectileParameters, projectileParams or {})

  --crit = 3x damage
  if self.roll < self.critChance then
    params = sb.jsonMerge(self.empoweredProjectileParameters, projectileParams or {})
    params.power = self:damagePerShot() * self.critMultiplier * (self.stockDamageMult or 1) * (self.chamberDamageMult or 1) * (self.barrelDamageMult or 1) --could do better by getting the augment types and their multiplier but oh well
  else
    local params = sb.jsonMerge(self.projectileParameters, projectileParams or {})
    params.power = self:damagePerShot() * (self.stockDamageMult or 1) * (self.chamberDamageMult or 1) * (self.barrelDamageMult or 1) --could do better by getting the augment types and their multiplier but oh well
  end


  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.speed = util.randomInRange(params.speed)
  

  if not projectileType then
    if self.roll < self.critChance then 
        projectileType = self.elementalConfig[element].primaryAbility[projectileCategory].empoweredProjectileType
    else
        projectileType = self.elementalConfig[element].primaryAbility[projectileCategory].projectileType
    end
  end
  if type(projectileType) == "table" then
    projectileType = projectileType[math.random(#projectileType)]
  end

  local projectileId = 0
  for i = 1, (projectileCount or self.projectileCount) do
    if params.timeToLive then
      params.timeToLive = util.randomInRange(params.timeToLive)
    end

    projectileId = world.spawnProjectile(
        projectileType,
        firePosition or self:firePosition(),
        activeItem.ownerEntityId(),
        self:aimVector(inaccuracy or self.inaccuracy),
        false,
        params
      )
  end
  return projectileId
end

