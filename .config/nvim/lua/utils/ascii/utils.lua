local categories = require("ascii.art")
local library = require("utils.ascii.library")
local M = {}

-- Get a random key from a given table
-- @param items The table where to pick a random key
function M.get_random_key(items)
  local keys = {}

  for k, _ in pairs(items) do
    table.insert(keys, k)
  end

  return keys[math.random(1, #keys)]
end

-- Function to merge two Lua tables recursively.
-- table1: The first table to merge.
-- table2: The second table to merge.
-- Returns: The merged table containing items from both tables.
function M.merge(t1, t2)
  for k, v in pairs(t2) do
    if type(v) == "table" and type(t1[k]) == "table" then
      t1[k] = M.merge(t1[k], v)
    else
      t1[k] = v
    end
  end
  return t1
end

-- see for more advanced doctorfree/asciiart.nvim
function M.get_any_random()
  local arts = M.merge(categories, { custom = { customs = library } })
  local category = M.get_random_key(arts)
  local subcategories = arts[category]
  local subcategory = M.get_random_key(subcategories)
  local items = subcategories[subcategory]
  local key = M.get_random_key(items)

  return items[key]
end

-- Method to get a specific item by name
function M.get(name)
  local arts = M.merge(categories, { custom = { customs = library } })
  for category, subcategories in pairs(arts) do
    for subcategory, items in pairs(subcategories) do
      for key, item in pairs(items) do
        if key == name then
          return item
        end
      end
    end
  end
  return nil -- Return nil if the item with the provided name is not found
end

return M
