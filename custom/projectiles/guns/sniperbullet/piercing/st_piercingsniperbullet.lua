function init()
    hitActions = config.getParameter("hitactions", {})
  end
  
function hit(entityId)
  for _,action in ipairs(hitActions) do
    projectile.processAction(action)
  end
end