Patterns = require "Patterns"
local command

--------------------------------------------------------------------------------
-- TOOLS

if renoise == nil then		-- for testing in lua w/o renoise
   rprint = function (t)
      for k,v in pairs(t) do
	 print(k, type(v) .. " =>", v)
      end
   end
end

-- string tools
local strsplit = function (str, delimiter) 
   local t = {}
   for v in string.gmatch(str, "[^" .. delimiter .. "]+") do
      table.insert(t, v)
   end
   return t
end

local no_spaces = function  (str)
   return str:gsub(" ", "")
end

local dostring = function (str)
   local func = loadstring("return " .. str)
   return func()
end

-- table tools
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
-- CONSTANTS

EMPTY_VALUES = {
   note_value = "121",
   instrument_value = "255",
   volume_value = "255",
   paning_value = "255",
   delay_value = "0",
}

PI = math.pi

--------------------------------------------------------------------------------
-- functions
sin = math.sin; sinh = math.sinh;
cos = math.cos; cosh = math.cosh;
tan = math.tan; tanh = math.tan;
floor = math.floor; ceil = math.ceil;
rand = math.random; seed = math.randomseed; abs = math.abs;
acos = math.acos; asin = math.asin; atan = math.atan; atan2 = math.atan2;
deg = math.deg; rad = math.rad; exp = math.exp;
fmod = math.fmod; frexp = math.frexp;fmod = math.fmod;
log = math.log; log10 = math.log10;
max = math.max; min = math.min;
pow = math.pow; sqrt = math.sqrt;


local function choose (t)
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
-- parsing/expansion functions

function make_expression (str)
   local expr = str
   local with_if = has_if(expr)

   -- expand ternary operation
   if with_if then expr = make_if(expr) end

   -- handle pauses
   if expr:find("_") then expr = EMPTY_VALUES[command] end

   if has_repetition(expr) then
      expr = make_repetition_table(expr)
      if with_if then
	 expr[1] = make_function(expr[1], true)
      else
	 expr[1] = make_function(expr[1], false)	 
      end
   else
      expr = make_function(expr, with_if)
   end
   return expr
end


function make_function (str, with_if)
   local func = ""
   if with_if then
      func = "function (i,v,n) %s end"
   else
      func = "function (i,v,n) return %s end"
   end
   func = func:format(str)
   return dostring(func)
end

function has_repetition (str)
   if str:find("!") then return true else return false end
end

function has_if (str)
   if str:find("?") then return true else return false end
end

function make_repetition_table (str)
   local t = {}
   local expr, num = unpack(strsplit(str, "!"))
   return {expr, tonumber(num)}
end

function make_if (str)
   local cond, body = unpack(strsplit(str, "?"))
   local if_true, if_false = unpack(strsplit(body, ":"))
   local expr = "if " .. cond
      .. " then return " .. if_true
      .. " else return " .. if_false
      .. " end"
   return expr
end

function set_direct (str)
   return str
end

function process_code (str)
   local t = {}
   local slots = strsplit(str, "\n")
   for i,s in ipairs(slots) do
      table.insert(t, make_expression(s))
   end
   inject_repetitions(t)
   return t
end

function inject_repetitions (o)
   local t = {}
   for i,v in ipairs(o) do
      if type(v) == "table" then
	 for i=1, v[2] do
	    table.insert(t, v[1])
	 end
      else
	 table.insert(t, v)
      end
   end
   return t
end

function interpret_code (str, cmd, pattern, num)
   command = cmd or "note_value"
   local pattern = pattern or "Pseq"
   local num = num or 64

   local slots = process_code(str)
   slots = inject_repetitions(slots)
   
   local seq = Patterns[pattern](slots)
   return seq
end

return interpret_code