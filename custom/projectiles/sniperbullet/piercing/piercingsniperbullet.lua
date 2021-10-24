function init()
    hitactions = config.getParameter("hitactions", {})
  end
  
function hit(entityId)
  for _,action in ipairs(hitactions) do
    projectile.processAction(action)
  end
end