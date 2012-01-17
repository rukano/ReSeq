--[[ ---------------------------------------------------------------------------
-- Pattern System inspired/derived from SuperCollider Patterns
-- Only implementing/adapting _some_ of the ListPattern Subclasses concepts
--]] ---------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- tools

local
function wrap (t, i)
   return t[ ((i-1) % #t) + 1]
end

local
function choose (t)
   return t[ math.random(#t) ]
end

local
function copy_table (t)
   local o = {}
   for i,v in ipairs(t) do o[i] = v end
   return o
end

--------------------------------------------------------------------------------
-- ListPatterns

local ListPattern = {}

-- sequential
function ListPattern.Pseq (list)
   local counter = 0
   local func = function ()
      counter = counter + 1
      return wrap(list, counter)
   end
   return func
end

-- sequential with iteration awareness (for subtables)
function ListPattern.Place (list)
   local counter = 0
   local iteration = 0
   local func = function ()
      counter = counter + 1
      iteration = math.floor((counter-1)/#list)
      local item = wrap(list, counter)
      if type(item) == "table" then
	 return wrap(item, iteration+1)
      else
	 return item
      end
   end
   return func
end

-- random elements
function ListPattern.Prand (list)
   return function () return choose(list) end
end

-- random sequence will be rndomized on every new cycle
function ListPattern.Pshuf (list)
   local items = copy_table(list)
   local func = function ()
      print(#list)
      if #items == 0 then items = copy_table(list) end
      local item = table.remove(items, math.random(#items))
      return item
   end
   return func
end

return ListPattern

-- TODO:
-- Pseq with fold
