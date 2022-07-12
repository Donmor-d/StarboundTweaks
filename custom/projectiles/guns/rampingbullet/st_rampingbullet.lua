function init()
    self.multiplier = config.getParameter("multiplier", 1)
    self.timer = config.getParameter("rampTime", 1)
    self.projectilePower = projectile.power()
end

function update(dt)

    self.timer = math.max(0, self.timer - dt)
    
    if self.timer == 0 then
        projectile.setPower(self.projectilePower * self.multiplier)
        self.projectilePower = projectile.power()
        sb.logInfo(self.projectilePower)
        self.timer = config.getParameter("rampTime", 1)
    end

end