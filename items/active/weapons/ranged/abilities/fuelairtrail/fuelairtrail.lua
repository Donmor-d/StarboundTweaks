require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

FuelAirTrail = WeaponAbility:new()

function FuelAirTrail:init()
  self.cooldownTimer = 0
end

function FuelAirTrail:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)

  if self.fireMode == "alt"
     and not self.weapon.currentAbility
     and self.cooldownTimer == 0 
     and not status.resourceLocked("ammo")
     and not world.lineTileCollision(mcontroller.position(), self:firePosition())
     and not world.liquidAt(self:firePosition()) then

    self:setState(self.fire)
  end
end

function FuelAirTrail:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  local pParams = copy(self.projectileParameters)
  pParams.power = pParams.power * root.evalFunction("weaponDamageLevelMultiplier", config.getParameter("level", 1))
  pParams.powerMultiplier = activeItem.ownerPowerMultiplier()

  self:spawnProjectile(self:firePosition(), pParams)

  animator.playSound("trailLoop", -1)

  -- lay trail
  while self.fireMode == "alt" and not status.resourceLocked("ammo") do
    if not world.entityExists(self.lastProjectileId) then break end

    if world.liquidAt(self:firePosition()) then return true end
    
    local lastPosition = world.entityPosition(self.lastProjectileId)
    local delta = world.distance(self:firePosition(), lastPosition)
    if vec2.mag(delta) >= self.projectileFrequency then
      local nextPosition = vec2.add(lastPosition, vec2.mul(vec2.norm(delta), self.projectileFrequency))

      if world.pointTileCollision(nextPosition) then break end

      self:spawnProjectile(nextPosition, pParams)
    end

    coroutine.yield()
  end

  -- ignite trail
  if self.lastProjectileId and world.entityExists(self.lastProjectileId) then
    world.callScriptedEntity(self.lastProjectileId, "ignite")
    self.lastProjectileId = nil
    animator.playSound("trailIgnite")
  end

  animator.stopAllSounds("trailLoop")

  self.cooldownTimer = self.cooldown
end

function FuelAirTrail:reset()
  animator.stopAllSounds("trailLoop")
end

function FuelAirTrail:uninit(unequipped)
  self:reset()
end

function FuelAirTrail:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(self.weapon.muzzleOffset))
end

function FuelAirTrail:aimVector(inaccuracy)
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle)
  aimVector[1] = aimVector[1] * self.weapon.aimDirection
  return aimVector
end

function FuelAirTrail:spawnProjectile(position, params)
  params.chainProjectile = self.lastProjectileId
  local projectileId = world.spawnProjectile(
      self.projectileType,
      position,
      activeItem.ownerEntityId(),
      self:aimVector(),
      false,
      params
    )
  if projectileId then
    status.overConsumeResource("ammo", self.ammoUsage)
    self.lastProjectileId = projectileId
  end

  return projectileId
end
