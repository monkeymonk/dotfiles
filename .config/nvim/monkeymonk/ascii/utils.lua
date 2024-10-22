local asciiArt = require("monkeymonk.ascii.library")
local M = {}

-- Function to retrieve art by name
function M.getArtByName(name)
  return asciiArt[name] or nil
end

-- Function to retrieve a random art
function M.getRandomArt()
  local art_names = {}

  -- Collect all valid art names
  for k in pairs(asciiArt) do
    if type(asciiArt[k]) == "table" then
      table.insert(art_names, k)
    end
  end

  local randomIndex = math.random(#art_names)
  local randomArtName = art_names[randomIndex]
  return asciiArt[randomArtName]
end

return M
