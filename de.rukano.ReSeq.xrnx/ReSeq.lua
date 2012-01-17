--------------------------------------------------------------------------------
-- TOOLS

-- DEBUG:
local rprint = function (t)
   for k,v in pairs(t) do
      print(k, type(v) .. " =>", v)
   end
end

-- STRING OPERAtiONS
local strsplit = function (str, delimiter) 
   local t = {}
   for v in string.gmatch(str, "[^" .. delimiter .. "]+") do
      table.insert(t, v)
   end
   return t
end

local nospace = function  (str)
   return str:gsub(" ", "")
end

local dostring = function (str)
   local func = loadstring("return " .. str)
   return func()
end

local subtable = function (t, from, to)
   local from = from or 1
   local to = to or #t
   local sub = {}
   for i,v in ipairs(t) do
      if i >= from and i <= to then
	 table.insert(sub, v)
      end
   end
   return sub
end

--------------------------------------------------------------------------------
-- MATH
sin = math.sin
cos = math.cos
tan = math.tan
tanh = math.tan
floor = math.floor
ceil = math.ceil
PI = math.pi
rand = math.random

function choose (t)
   return t[rand(#t)]
end

function r (a,b)
   if type(a) == "table" then
      return choose(a)
   elseif b then
      return rand(a, b)
   else
      return rand(a)
   end
end

--------------------------------------------------------------------------------
-- CONSTANTS

empty_values = {
   note = 121,
   inst = 255,
   vol = 255,
   pan = 255,
   del = 0,
}

--------------------------------------------------------------------------------
-- PATTERNS
-- TODO: Complement and use the Pseq/Prand library
-- Also make a loop for evaluating the patterns
-- instead of generating the values in the 'pattern' itself

PATTERNS = {}

function PATTERNS.seq (values, v)
   local n = #v
   local seq = {}
   for i=1, n do
      local val = values[((i-1) % #values)+1]
      seq[i] = evaluate(val, i, v[i], n)
   end
   return seq
end

function PATTERNS.rnd (values, v)
   local n = #v
   local seq = {}
   for i=1, n do
      local val = choose(values)
      seq[i] = evaluate(val, i, v[i], n)
   end
   return seq
end

--------------------------------------------------------------------------------
-- CODE EXECUTION
function evaluate (value, i, v, n)
   local num = value
   if type(value) == "function" then
      num = value(i, v, n)
   end
   return floor(num)
end

function evaluate_arg (arg, cmd, i, n) -- i=line, n=current
   local a = ""
   if arg == "_" or arg == "~" then
      a = empty_values[cmd]
   elseif (arg == "x" or arg == "X") and cmd == "note" then
      a = 120
   elseif tonumber(arg) then
      a = tonumber(arg)
   else
      a = make_expr(arg)
   end
   return a
end

function parse_line (code)
   local code = nospace(code)
   local header, body = unpack(strsplit(code, "->"))
   local cmd, pattern = unpack(strsplit(header, ":"))
   local steps = strsplit(body, "|")
   
   local slots = {}

   for i,v in ipairs(steps) do
      table.insert(slots, evaluate_arg(v, cmd, i))
   end

   return cmd, pattern, slots
end

function make_expr (arg)
   local expr = "return function (i, v, n) return " .. arg .. " end"
   expr = loadstring(expr)()
   return expr
end

function interpret_line (code, cv)
   local cmd, pattern, slots = parse_line(code)
   local seq = PATTERNS[pattern](slots, cv)
   return seq, cmd
end
