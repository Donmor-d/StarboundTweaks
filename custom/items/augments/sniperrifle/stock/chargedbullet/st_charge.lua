require "/scripts/util.lua"
require "/scripts/interp.lua"

-- Base gun fire ability
GunFire = WeaponAbility:new()

function GunFire:init()
  self.weapon:setStance(self.stances.idle)

  self.cooldownTimer = self.reloadTime

  activeItem.setCursor("/cursors/reticle0.cursor")

  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

function GunFire:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if animator.animationState("firing") ~= "fire" then
    animator.setLightActive("muzzleFlash", false)
  end

  if self.fireMode == "primary"
    and not self.weapon.currentAbility
    and self.cooldownTimer == 0
    and not status.resourceLocked("ammo")
    and not world.lineTileCollision(mcontroller.position(), self:firePosition()) then
    
    self:setState(self.charge)
  end
end


function GunFire:charge()

  --self.weapon:setStance(self.stances.charge)
  animator.playSound("charge")
  --[[
  animator.setAnimationState("charge", "charge")
  --]]

  activeItem.setCursor("/cursors/charge2.cursor")

  self.chargeTimer = self.chargeTime
  while self.chargeTimer > 0 and self.fireMode == "primary" do
    if status.resourceLocked("ammo") then
      self.chargeTimer = self.chargeTimer - (self.dt / 2)
    else
      self.chargeTimer = self.chargeTimer - self.dt
    end
    coroutine.yield()
  end

--animator.stopAllSounds("charge")

  self:setState(self.charged)

end

function GunFire:charged()

  if self.chargeTimer <= 0.5 then
    animator.playSound("charged")
  else 
	animator.stopAllSounds("charge")
  end
  --[[   to be added later, right now it only delays testing
  animator.playSound("chargedloop", -1)
  --]]


  while self.fireMode == "primary" do
    activeItem.setCursor("/cursors/chargeready.cursor")

    coroutine.yield()
  end
  if self.chargeTimer <= 0.5 then
  
	self:setState(self.fire)
  end
  activeItem.setCursor("/cursors/reticle0.cursor")
end

function GunFire:fire()
  self.weapon:setStance(self.stances.fire)

  self.damageMultiplier = self.chargeTimer

  animator.stopAllSounds("charge")

  self:fireProjectile()
  self:muzzleFlash()

  if self.stances.fire.duration then
    util.wait(self.stances.fire.duration)
  end

  self.cooldownTimer = 0.1
  self:setState(self.cooldown)
end

function GunFire:cooldown()
  self.weapon:setStance(self.stances.cooldown)
  self.weapon:updateAim()

  local progress = 0
  util.wait(self.stances.cooldown.duration, function()
    local from = self.stances.cooldown.weaponOffset or {0,0}
    local to = self.stances.idle.weaponOffset or {0,0}
    self.weapon.weaponOffset = {interp.linear(progress, from[1], to[1]), interp.linear(progress, from[2], to[2])}
    self.weapon.relativeWeaponRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.weaponRotation, self.stances.idle.weaponRotation))
    self.weapon.relativeArmRotation = util.toRadians(interp.linear(progress, self.stances.cooldown.armRotation, self.stances.idle.armRotation))

    progress = math.min(1.0, progress + (self.dt / self.stances.cooldown.duration))
  end)
end

function GunFire:muzzleFlash()
  animator.setPartTag("muzzleFlash", "variant", math.random(1, self.muzzleFlashVariants or 3))
  animator.setAnimationState("firing", "fire")
  animator.burstParticleEmitter("muzzleFlash")
  animator.playSound("fire")

  animator.setLightActive("muzzleFlash", true)
end

function GunFire:fireProjectile(projectileType, projectileParams, inaccuracy, firePosition, projectileCount)
  local element = config.getParameter("elementalType", "physical")
  local projectileCategory = self.projectileCategory or "default"
  local params = sb.jsonMerge(self.elementalConfig[element].primaryAbility[projectileCategory].projectileParameters,  projectileParams or {})
  params.power = self:damagePerShot() * (self.stockDamageMult or 1) * (self.chamberDamageMult or 1) * (self.barrelDamageMult or 1) --could do better by getting the augment types and their multiplier but oh well
  params.power = params.power * 0.1 / math.max(0.1, self.damageMultiplier)
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.speed = util.randomInRange(params.speed)
  status.overConsumeResource("ammo", self.ammoUsage)

  if not projectileType then
    if self.damageMultiplier > 0.1 then
      projectileType = self.elementalConfig[element].primaryAbility[projectileCategory].projectileTypeUncharged or self.elementalConfig[element].primaryAbility[projectileCategory].projectileType
    else
      projectileType = self.elementalConfig[element].primaryAbility[projectileCategory].projectileTypeCharged or self.elementalConfig[element].primaryAbility[projectileCategory].projectileType
    end
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

function GunFire:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function GunFire:aimVector(inaccuracy)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(inaccuracy, 0))
  aimVector[1] = aimVector[1] * mcontroller.facingDirection()
  return aimVector
end

function GunFire:damagePerShot()
  return self.maxDamage * (self.baseDamageMultiplier or 1.0) * config.getParameter("damageLevelMultiplier") / self.projectileCount
end

function GunFire:uninit()
end
