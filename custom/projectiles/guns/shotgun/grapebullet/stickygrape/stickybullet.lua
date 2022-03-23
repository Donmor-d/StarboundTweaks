require "/scripts/util.lua"
require "/scripts/messageutil.lua"

function init()
    collideAction = config.getParameter("actionOnCollision", {})
end

function hit(entityId)
    if self.hit then return end
    if world.isMonster(entityId) then
        self.hit = true
    else
        collide()
    end
end

function collide()
    for _,action in ipairs(collideAction) do
        projectile.processAction(action)
    end
end