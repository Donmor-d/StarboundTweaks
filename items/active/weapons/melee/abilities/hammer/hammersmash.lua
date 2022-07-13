require "/scripts/util.lua"
require "/scripts/rect.lua"
require "/scripts/poly.lua"
require "/scripts/interp.lua"
require "/items/active/weapons/melee/meleeslash.lua"

-- Hammer primary attack
-- Extends default melee attack and overrides windup and fire
HammerSmash = MeleeSlash:new()
function HammerSmash:init()
  self.stances.windup.duration = self.fireTime - self.stances.preslash.duration - self.stances.fire.duration

  self.damageMultiplier = 0 -- temporary solution while the thing doesnt fucking work for some fucking reason its literally the same as with the axe one so why the fuck does it return nil while axe doesnt FUCK YOU FUCK YOU

  self.defKnockback = self.damageConfig.knockback
  
  self.falling = false
  MeleeSlash.init(self)
  self:setupInterpolation()
end

function HammerSmash:windup(windupProgress)
  self.weapon:setStance(self.stances.windup)

  local windupProgress = windupProgress or 0
  local bounceProgress = 0
  while self.fireMode == "primary" and (self.allowHold ~= false or windupProgress < 1) do
    if windupProgress < 1 then
      windupProgress = math.min(1, windupProgress + (self.dt / self.stances.windup.duration))
      self.weapon.relativeWeaponRotation, self.weapon.relativeArmRotation = self:windupAngle(windupProgress)
    else
      bounceProgress = math.min(1, bounceProgress + (self.dt / self.stances.windup.bounceTime))
      self.weapon.relativeWeaponRotation, self.weapon.relativeArmRotation = self:bounceWeaponAngle(bounceProgress)
    end
    
    if windupProgress > 0.8 and windupProgress < 1 then
        animator.setGlobalTag("bladeDirectives", "fade=FFFFFFFF=0.15")
    else 
        animator.setGlobalTag("bladeDirectives", "")
    end
    coroutine.yield()
  end

  self.damageMultiplier = windupProgress

  if windupProgress > 0.5 then
    if math.abs(world.gravity(mcontroller.position())) > 0 then
      if self.stances.preslash then
        self:setState(self.preslash)
      else
        self:setState(self.fire)
      end
    else
      self:setState(self.spin)
    end
  else
    self:setState(self.winddown, windupProgress)
  end
end

function HammerSmash:winddown(windupProgress)
  self.weapon:setStance(self.stances.windup)

  while windupProgress > 0 do
    if self.fireMode == "primary" then
      self:setState(self.windup, windupProgress)
      return true
    end

    windupProgress = math.max(0, windupProgress - (self.dt / self.stances.windup.duration))
    self.weapon.relativeWeaponRotation, self.weapon.relativeArmRotation = self:windupAngle(windupProgress)
    coroutine.yield()
  end
end

function HammerSmash:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  if self.damageMultiplier > 0.8 and self.damageMultiplier < 1 then
    self.damageMultiplier = 1.25 -- 125% of base damage
    animator.setGlobalTag("bladeDirectives", "")
    animator.playSound("chargedFire")
  end
  self.damageConfig.baseDamage = self.damageConfig.baseDamage * self.damageMultiplier
  self.damageConfig.knockback = self.damageConfig.knockback * self.damageMultiplier

  animator.setAnimationState("swoosh", "fire")
  animator.playSound("fire")
  animator.burstParticleEmitter(self.weapon.elementalType .. "swoosh")

  local smashMomentum = self.smashMomentum
  smashMomentum[1] = smashMomentum[1] * mcontroller.facingDirection()
  mcontroller.addMomentum(smashMomentum)

  local initialYPos = mcontroller.yPosition() --initial position when the player swings the weapon mid air

  local smashTimer = self.stances.fire.smashTimer
  local duration = self.stances.fire.duration
  while smashTimer > 0 or duration > 0 do
    smashTimer = math.max(0, smashTimer - self.dt)
    duration = math.max(0, duration - self.dt)

    local damageArea = partDamageArea("swoosh")
    if not damageArea and smashTimer > 0 then
      damageArea = partDamageArea("blade")
    end
    self.weapon:setDamage(self.damageConfig, damageArea, self.fireTime)

    if smashTimer > 0 then
      if not mcontroller.onGround() then
        self.falling = true
      end

      local groundImpact = world.polyCollision(poly.translate(poly.handPosition(animator.partPoly("blade", "groundImpactPoly")), mcontroller.position()))
      if mcontroller.onGround() or groundImpact or mcontroller.yVelocity() > 0 then --mcontroller.yVelocity() > 0 ends the if statement if the player double jumps
        smashTimer = 0
        
        if groundImpact then
          local fallMultiplier = math.abs(initialYPos - mcontroller.yPosition()) / 10 --increases distance travelled by shockwave the higher the height
          animator.burstParticleEmitter("groundImpact")
          animator.playSound("groundImpact")
          if self.falling then
            self.falling = false
            self:fireShockwave(self.damageMultiplier * fallMultiplier)
          end
        end
      end
    end
    coroutine.yield()
  end

  self.damageConfig.baseDamage = self.baseDps * self.fireTime
  self.damageConfig.knockback = self.defKnockback

  self.cooldownTimer = self:cooldownTime()
end

function HammerSmash:fireShockwave(charge)
  local impact, impactHeight = self:impactPosition()

  local volume = math.min(charge, 1)

  if impact then
    self.weapon.weaponOffset = {0, impactHeight + self.impactWeaponOffset}

    local charge = math.floor(charge * self.maxDistance)
    local directions = {1}
    if self.bothDirections then directions[2] = -1 end
    local positions = self:shockwaveProjectilePositions(impact, charge, directions)
    if #positions > 0 then
      animator.playSound(self.weapon.elementalType.."impact")
      animator.setSoundVolume(self.weapon.elementalType.."impact", volume)
      local params = copy(self.projectileParameters)
      params.powerMultiplier = activeItem.ownerPowerMultiplier()
      params.power = params.power * config.getParameter("damageLevelMultiplier")
      params.actionOnReap = {
        {
          action = "projectile",
          inheritDamageFactor = 0.5,
          type = self.weapon.elementalType.."shockwave"
        }
      }
      for i,position in pairs(positions) do
        local xDistance = world.distance(position, impact)[1]
        local dir = util.toDirection(xDistance)
        params.timeToLive = (math.floor(math.abs(xDistance))) * 0.025
        world.spawnProjectile("shockwavespawner", position, activeItem.ownerEntityId(), {dir,0}, false, params)
      end
    end
  end
end

function HammerSmash:impactPosition()
  local dir = mcontroller.facingDirection()
  local startLine = vec2.add(mcontroller.position(), vec2.mul(self.impactLine[1], {dir, 1}))
  local endLine = vec2.add(mcontroller.position(), vec2.mul(self.impactLine[2], {dir, 1}))

  local blocks = world.collisionBlocksAlongLine(startLine, endLine, {"Null", "Block"})
  if #blocks > 0 then
    return vec2.add(blocks[1], {0.5, 0.5}), endLine[2] - blocks[1][2] + 1
  end
end

function HammerSmash:shockwaveProjectilePositions(impactPosition, maxDistance, directions)
  local positions = {}

  for _,direction in pairs(directions) do
    direction = direction * mcontroller.facingDirection()
    local position = copy(impactPosition)
    for i = 0, maxDistance do
      local continue = false
      for _,yDir in ipairs({0, -1, 1}) do
        local wavePosition = {position[1] + direction * i, position[2] + 0.5 + yDir + self.shockwaveHeight}
        local groundPosition = {position[1] + direction * i, position[2] + yDir}
        local bounds = rect.translate(self.shockWaveBounds, wavePosition)

        if world.pointTileCollision(groundPosition, {"Null", "Block", "Dynamic", "Slippery"}) and not world.rectTileCollision(bounds, {"Null", "Block", "Dynamic", "Slippery"}) then
          table.insert(positions, wavePosition)
          position[2] = position[2] + yDir
          continue = true
          break
        end
      end
      if not continue then break end
    end
  end

  return positions
end

function HammerSmash:spin()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  if self.damageMultiplier > 0.8 and self.damageMultiplier < 1 then
    self.damageMultiplier = 1.25 -- 125% of base damage
    animator.setGlobalTag("bladeDirectives", "")
    animator.playSound("chargedFire")
  end
  self.damageConfig.baseDamage = self.damageConfig.baseDamage * self.damageMultiplier

  animator.setAnimationState("swoosh", "fire")
  animator.playSound("fire")
  animator.burstParticleEmitter(self.weapon.elementalType .. "swoosh")

  local direction = -mcontroller.facingDirection()

  local spinTimer = self.stances.spin.spinTimer
  while spinTimer > 0 do
    spinTimer = spinTimer - self.dt

    local ratio = 1 - ((spinTimer / self.stances.spin.spinTimer) ^ 2)
    local angle = ratio * self.stances.spin.spinAngle * direction
    mcontroller.setRotation(angle)

    local damageArea = partDamageArea("swoosh")
    if damageArea then
      self.weapon:setDamage(self.damageConfig, poly.rotate(damageArea, angle), self.fireTime)
    end


    coroutine.yield()
  end

  self.damageConfig.baseDamage = self.baseDps * self.fireTime

  mcontroller.setRotation(0)
  self.cooldownTimer = self:cooldownTime()
end

function HammerSmash:uninit()
  MeleeSlash.uninit(self)
  if self.weapon.currentState == self.spin then
    mcontroller.setRotation(0)
  end
end

function HammerSmash:setupInterpolation()
  for i, v in ipairs(self.stances.windup.bounceWeaponAngle) do
    v[2] = interp[v[2]]
  end
  for i, v in ipairs(self.stances.windup.bounceArmAngle) do
    v[2] = interp[v[2]]
  end
  for i, v in ipairs(self.stances.windup.weaponAngle) do
    v[2] = interp[v[2]]
  end
  for i, v in ipairs(self.stances.windup.armAngle) do
    v[2] = interp[v[2]]
  end
end

function HammerSmash:bounceWeaponAngle(ratio)
  local weaponAngle = interp.ranges(ratio, self.stances.windup.bounceWeaponAngle)
  local armAngle = interp.ranges(ratio, self.stances.windup.bounceArmAngle)

  return util.toRadians(weaponAngle), util.toRadians(armAngle)
end

function HammerSmash:windupAngle(ratio)
  local weaponRotation = interp.ranges(ratio, self.stances.windup.weaponAngle)
  local armRotation = interp.ranges(ratio, self.stances.windup.armAngle)

  return util.toRadians(weaponRotation), util.toRadians(armRotation)
end