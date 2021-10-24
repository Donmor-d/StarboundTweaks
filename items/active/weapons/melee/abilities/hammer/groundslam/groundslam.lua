require "/scripts/util.lua"
require "/scripts/interp.lua"
require "/items/active/weapons/weapon.lua"

GroundSlam = WeaponAbility:new()

function GroundSlam:init()
  self:reset()
  self.cooldownTimer = self.cooldownTime

  --needed for thing below
  self.soundlock = 0
  self.flashtime = 0.1
  self.flashtimer = 0
end

function GroundSlam:update(dt, fireMode, shiftHeld)
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

  if self.weapon.currentAbility == nil
    and self.cooldownTimer == 0
    and self.fireMode == "alt"
    and not mcontroller.onGround()
    and status.overConsumeResource("energy", self.energyUsage) then

    self:setState(self.windup)
  end
end

function GroundSlam:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()

  status.setPersistentEffects("weaponMovementAbility", {{stat = "activeMovementAbilities", amount = 1}})

  util.wait(self.stances.windup.duration)

  if not mcontroller.onGround() then
    self:setState(self.slam)
  end
end

function GroundSlam:slam()
  local preSlamPosition = self:slamPosition()
  self.weapon:setStance(self.stances.slam)
  self.weapon:updateAim()
  local postSlamPosition = self:slamPosition()

  animator.playSound("groundSlamFall")
  
  status.setPersistentEffects("groundSlam", {
      {stat = "fallDamageMultiplier", effectiveMultiplier = 0},
      {stat = "invulnerable", amount = 1}
    })

  local lastSlamPosition = self:slamPosition()
  local slamTime = self:inGravity() and self.maxSlamTime or self.spaceSlamTime
  util.wait(slamTime, function(dt)
    if self:inGravity() then
      mcontroller.setYVelocity(self.slamSpeed)
      local newSlamPosition = self:slamPosition()
      if world.lineTileCollision(lastSlamPosition, newSlamPosition) then
        local params = copy(self.projectileParameters)
        params.powerMultiplier = activeItem.ownerPowerMultiplier()
        params.power = params.power * config.getParameter("damageLevelMultiplier")

        world.spawnProjectile(self.projectileType, lastSlamPosition, activeItem.ownerEntityId(), {0,0}, false, params)
        return true
      end
      lastSlamPosition = newSlamPosition
    end

    if mcontroller.onGround() then
      return true end

    local damageArea = partDamageArea("blade")
    self.weapon:setDamage(self.damageConfig, damageArea)
  end)

  self.cooldownTimer = self.cooldownTime

  --also needed
  self.soundlock = 0

  util.wait(self.winddownTime)
end

function GroundSlam:slamPosition()
  return vec2.add(activeItem.handPosition(animator.partPoint("blade", "groundSlamPoint")), mcontroller.position())
end

function GroundSlam:reset()
  status.clearPersistentEffects("weaponMovementAbility")
  status.clearPersistentEffects("groundSlam")
  animator.setGlobalTag("directives", "")
end

function GroundSlam:uninit()
  self:reset()
end

function GroundSlam:inGravity()
  return math.abs(world.gravity(mcontroller.position())) > 0
end
