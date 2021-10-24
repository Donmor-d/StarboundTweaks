function activate()
  local configData = root.assetJson("/interface/scripted/mechassembly/mechassemblygui.config")
  activeItem.interact("ScriptPane", configData)
end
