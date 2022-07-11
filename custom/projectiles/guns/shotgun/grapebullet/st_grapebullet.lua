require "/scripts/util.lua"
require "/scripts/messageutil.lua"

function init()
    self.spawnItem = config.getParameter("grapeSpawn")
end

function update()

end

function hit(entityId)
    if self.hit then return end
    if world.isMonster(entityId, true) then
        self.hit = true
        spawnItem()
    end
end

function spawnItem()
    local x = math.random(1, 10)
    if x == 1 then
        world.spawnItem(self.spawnItem, mcontroller.position(), 1)
    end
end