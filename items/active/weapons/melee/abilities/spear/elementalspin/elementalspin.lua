require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

ElementalSpin = WeaponAbility:new()

function ElementalSpin:init()
  self:reset()
  self.cooldownTimer = self.cooldownTime

  --needed for thing below
  self.soundlock = 0
  self.flashtime = 0.1
  self.flashtimer = 0
end

function ElementalSpin:update(dt, fireMode, shiftHeld)
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

  if self.weapon.currentAbility == nil and self.cooldownTimer == 0 and fireMode == "alt" and not status.resourceLocked("energy") then
    self:setState(self.windup)
  end
end

function ElementalSpin:windup()
  self.weapon:setStance(self.stances.windup)
  self.weapon:updateAim()

  animator.setAnimationState("spinSwoosh", "spin")
  animator.setParticleEmitterActive(self.weapon.elementalType.."Spin", true)
  self.weapon.aimAngle = 0
  activeItem.setOutsideOfHand(true)

  animator.playSound(self.weapon.elementalType.."Spin", -1)

  local duration = self.stances.windup.duration
  while self.fireMode == "alt" or duration > 0 do
    duration = math.max(0, duration - self.dt)
    self.weapon.relativeWeaponRotation = self.weapon.relativeWeaponRotation + util.toRadians(self.spinRate * self.dt)

    if status.overConsumeResource("energy", self.energyUsage * self.dt) then
      local damageArea = partDamageArea("spinSwoosh")
      self.weapon:setDamage(self.damageConfig, damageArea)
    elseif duration == 0 then
      break
    end

    coroutine.yield()
  end

  animator.stopAllSounds(self.weapon.elementalType.."Spin")

  if status.overConsumeResource("energy", self.projectileEnergyCost) then
    self:setState(self.fire)
  end

  self.cooldownTimer = self.cooldownTime

  --also needed
  self.soundlock = 0
end

function ElementalSpin:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  animator.setParticleEmitterActive(self.weapon.elementalType.."Spin", false)
  animator.setAnimationState("spinSwoosh", "idle")
  animator.playSound(self.weapon.elementalType.."SpinFire")

  local position = vec2.add(mcontroller.position(), activeItem.handPosition())
  local params = copy(self.projectileParameters)
  params.powerMultiplier = activeItem.ownerPowerMultiplier()
  params.power = params.power * config.getParameter("damageLevelMultiplier")
  world.spawnProjectile(self.projectileType, position, activeItem.ownerEntityId(), self:aimVector(), false, params)

  util.wait(self.stances.fire.duration)
end

function ElementalSpin:aimVector()
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle)
  aimVector[1] = aimVector[1] * self.weapon.aimDirection
  return aimVector
end


function ElementalSpin:reset()
  animator.setAnimationState("spinSwoosh", "idle")
  animator.setParticleEmitterActive(self.weapon.elementalType.."Spin", false)
  activeItem.setOutsideOfHand(false)
  animator.stopAllSounds(self.weapon.elementalType.."Spin")
end

function ElementalSpin:uninit()
  self:reset()
end
