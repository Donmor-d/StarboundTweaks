require "/scripts/util.lua"
require "/scripts/messageutil.lua"

function update()

end

function hit(entityId)
    if self.hit then return end
    if world.isMonster(entityId) then
        self.hit = true
        spawnItem()
    end

end

function spawnItem()
    local x = math.random(1, 10)
    if x == 1 then
        world.spawnItem("suspiciousgrape", mcontroller.position(), 1)
    end
end