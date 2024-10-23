local M = {}

-- Function to retrieve art by name
function M.getArtByName(name, library)
  return library[name] or nil
end

-- Function to retrieve a random art
function M.getRandomArt(library)
  local art_names = {}

  -- Collect all valid art names
  for k in pairs(library) do
    if type(library[k]) == "table" then
      table.insert(art_names, k)
    end
  end

  local randomIndex = math.random(#art_names)
  local randomArtName = art_names[randomIndex]
  return library[randomArtName]
end

return M
