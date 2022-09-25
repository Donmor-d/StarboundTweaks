function init()
    self.entity = projectile.sourceEntity()
    self.shakeAmount = projectile.getParameter("shakeAmount", 1)
    self.time = projectile.getParameter("timeToLive")/2
    self.timer = self.time
end

function update(dt)
    mcontroller.setPosition({world.entityPosition(self.entity)[1], world.entityPosition(self.entity)[2] + (math.random(-1, 1) * self.shakeAmount)})
    self.timer = self.timer - dt

    if self.timer <= 0 then
        self.shakeAmount = self.shakeAmount/2
        self.time = self.time/2
        self.timer = self.time
    end
end

function uninit()

end