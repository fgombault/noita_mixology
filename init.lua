local pretty_print = dofile("mods/mixology/files/scripts/pretty_print.lua")

-- this is a dictionary of material
-- key = material name
-- value = table of related reagents
MaterialReagents = {}

-- ░█▄█░█▀█░▀█▀░█▀▀░█▀▄░▀█▀░█▀█░█░░░█▀▀░░░█▀█░█▀█░█▀▄░█▀▀░▀█▀░█▀█░█▀▀░░
-- ░█░█░█▀█░░█░░█▀▀░█▀▄░░█░░█▀█░█░░░▀▀█░░░█▀▀░█▀█░█▀▄░▀▀█░░█░░█░█░█░█░░
-- ░▀░▀░▀░▀░░▀░░▀▀▀░▀░▀░▀▀▀░▀░▀░▀▀▀░▀▀▀░░░▀░░░▀░▀░▀░▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░░


function AddMaterialsFile(materials_file)
  local xml2lua = dofile("mods/mixology/lib/xml2lua/xml2lua.lua")
  local handler = dofile("mods/mixology/lib/xml2lua/xmlhandler/tree.lua")
  local parser = xml2lua.parser(handler)
  local materials = ModTextFileGetContent(materials_file)
  if (materials == nil or materials == "") then
    print("failed to load: " .. materials_file)
    return
  end

  parser:parse(materials)
  if (handler.root == nil or handler.root.Materials == nil) then
    print("Failed to load: " .. materials_file)
    return
  end

  for i, _ in pairs(handler.root.Materials) do
    if i == "Reaction" then
      for _, p2 in pairs(handler.root.Materials[i]) do
        if (p2._attr ~= nil) then
          if (MaterialReagents[p2._attr.input_cell1] == nil) then
            MaterialReagents[p2._attr.input_cell1] = {}
          end
          table.insert(MaterialReagents[p2._attr.input_cell1], p2._attr.input_cell2)
        end
      end
    end
  end
  print("Mixology - Materials file loaded: " .. materials_file)
end

function ModIDFromPath(path)
  local slashIndex = string.find(path, "/")
  if (slashIndex and slashIndex > 1) then
    return string.sub(path, 1, slashIndex - 1)
  end
end

function GetMaterialReagents()
  AddMaterialsFile("data/materials.xml")
  local modMaterialsFiles = {
    "alchemical_reactions_expansion/files/materials_append.xml",
    "grahamsperks/files/materials/materials_reactions.xml",
    "Hydroxide/files/reactions.xml",
    -- following is a broken xml file
    -- "more-stuff/data/new/materials_appends.xml",
  }
  for i = 1, #modMaterialsFiles do
    if ModIsEnabled(ModIDFromPath(modMaterialsFiles[i])) then
      AddMaterialsFile("mods/" .. modMaterialsFiles[i])
    end
  end
end

-- ░█▄█░█▀█░█▀▄░░░▀█▀░█▀█░▀█▀░▀█▀░▀█▀░█▀█░█░░░▀█▀░▀▀█░█▀█░▀█▀░▀█▀░█▀█░█▀█░░
-- ░█░█░█░█░█░█░░░░█░░█░█░░█░░░█░░░█░░█▀█░█░░░░█░░▄▀░░█▀█░░█░░░█░░█░█░█░█░░
-- ░▀░▀░▀▀▀░▀▀░░░░▀▀▀░▀░▀░▀▀▀░░▀░░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀▀▀░▀░▀░░

function OnMagicNumbersAndWorldSeedInitialized()
  print("Mixology initialization")

  GetMaterialReagents()
  local reagentsLua = pretty_print.table(MaterialReagents)
  -- print(reagentsLua)

  -- the file below then gets used by the potion initializer
  ModTextFileGetContent("mods/mixology/files/scripts/reagents.lua", reagentsLua)
end
