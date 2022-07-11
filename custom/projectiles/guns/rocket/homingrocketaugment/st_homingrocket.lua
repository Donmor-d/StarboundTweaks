require "/scripts/vec2.lua"

function init()
  self.targetSpeed = vec2.mag(mcontroller.velocity())
  self.controlForce = config.getParameter("baseHomingControlForce") * self.targetSpeed

  self.timeToHome = 0.5
  homingActions = config.getParameter("homingActions", {})
  self.lock = false
end

function update(dt)

    self.timeToHome = math.max(self.timeToHome - dt, 0)

    if self.timeToHome <= 0 then

        local targets = world.entityQuery(mcontroller.position(), 30, {
            withoutEntityId = projectile.sourceEntity(),
            includedTypes = {"creature"},
            order = "nearest"
        })

        

        for _, target in ipairs(targets) do
            

            if entity.isValidTarget(target) and entity.entityInSight(target)then
                if not self.lock then
                    for _,action in ipairs(homingActions) do
                        projectile.processAction(action)
                    end
                    self.lock = true
                end
                local targetPos = world.entityPosition(target)
                local myPos = mcontroller.position()
                local dist = world.distance(targetPos, myPos)

                mcontroller.approachVelocity(vec2.mul(vec2.norm(dist), self.targetSpeed), self.controlForce)
                return
            end
        end
    end
end