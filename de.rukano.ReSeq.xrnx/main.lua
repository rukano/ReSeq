-- ______     _____            
-- | ___ \   /  ___|           
-- | |_/ /___\ `--.  ___  __ _ 
-- |    // _ \`--. \/ _ \/ _` |
-- | |\ \  __/\__/ /  __/ (_| |
-- \_| \_\___\____/ \___|\__, |
--                          | |
--                          |_|

_AUTO_RELOAD_DEBUG = true 

-- TODO: Fix Place
-- TODO: generate notes!

-- TODO: make a function definition window!
-- TODO: execute and globalize user defined functions (from here)!

local interpret = require "Interpreter"
local Patterns = require "Patterns"

local vb
local app
local gui
local song

local width = 600

local selected_track = 1
local selected_parameter = 1
local selected_pattern_type = "Pseq"
local selected_command = "note_value"

local possible_parameters = {"Note", "Instrument", "Volume", "Paning", "Delay"}
local possible_pattern_type_labels = {"Sequence", "Interlace", "Random", "Shuffle"}
local possible_pattern_types = {"Pseq", "Place", "Prand", "Pshuf"}

local last_selected_track = 1
local saved_code = {}

--------------------------------------------------------------------------------
-- tool registration
--------------------------------------------------------------------------------
renoise.tool():add_menu_entry {
   name = "Main Menu:Tools:ReSeq",
   invoke = function() 
      init_tool()
      show_window() 
   end
			      }

renoise.tool():add_keybinding {
   name = "Global:Tools:ReSeq",
   invoke = function(repeated)
      if (not repeated) then
	 init_tool()
	 show_window()
      end
   end
			      }

function init_tool ()
   print("ReSeq started. Have Fun") -- put init code here
end

function exit_tool ()
   print("ReSeq closing")
   -- TODO: save data in document/preferences for the next time
end

function save_state ()
   -- TODO: save state to file/preferences
end

function load_state ()
   -- TODO: load state from file/preferences
end
--------------------------------------------------------------------------------
-- tools

local
function table_series (n)
   local t = {}
   for i=1, n do
      t[i] = tostring(i)
   end
   return t
end

--------------------------------------------------------------------------------
-- GUI

function show_window ()
   song = renoise.song()
   app = renoise.app()
   vb = renoise.ViewBuilder()
   gui = {}

   build_gui()

   app:show_custom_prompt("ReSeq", gui.content, {})
end

function build_gui ()
   local num_tracks = #song.tracks

   gui.rows = {}
   ---------------------------------------------------------------------------
   gui.parameter_chooser = vb:popup {
      items = possible_parameters,
      width = width/6,
				     }

   gui.pattern_type_chooser = vb:popup {
      items = possible_pattern_type_labels,
      width = width/6,
				     }

   gui.track_chooser_label = vb:text {
      width = width/12,
      align = "center",
      text = "Track: "
				    }
   gui.track_chooser = vb:switch {
      value = selected_track,
      items = table_series(num_tracks),
      width = width/1.71,
			   }
   gui.text_field = vb:multiline_textfield{
      text = [[60]],
      width = width,
      height = 300,
      font = "mono",
					  }
   gui.exec_button = vb:button{
      text = "execute",
      width = width,
      height = 30,
      color = {100,255,100},
			      }

   gui.load_button = vb:button{
      text = "load",
      width = width/8,
      height = 20,
      color = {255,255,255},
			      }

   gui.save_button = vb:button{
      text = "save",
      width = width/8,
      height = 20,
      color = {255,255,255},
			      }

   ---------------------------------------------------------------------------
   gui.rows[1] = vb:row{ margin = 0, gui.parameter_chooser, gui.pattern_type_chooser, gui.track_chooser_label, gui.track_chooser }
   gui.rows[2] = gui.text_field
   gui.rows[3] = gui.exec_button
   gui.rows[4] = vb:row{ margin = 0, vb:space{width=width/8*6}, gui.load_button, gui.save_button }
   gui.content = vb:column{ margin = 0, unpack(gui.rows) }
   ---------------------------------------------------------------------------

   gui.parameter_chooser:add_notifier(choose_parameter)
   gui.track_chooser:add_notifier(choose_track)
   gui.pattern_type_chooser:add_notifier(choose_pattern_type)
   gui.exec_button:add_pressed_notifier(execute)

end

--------------------------------------------------------------------------------
-- execute
function execute ()
   local code = gui.text_field.text
   local num = 64
   local pattern = interpret(code, selected_command, selected_pattern_type, num)
   print(selected_pattern_type)
   for i=1, num do
      local next = pattern()
      print(next())
   end

   -- TODO: save code on execute
end

---------------------------------------------------------------------------
function choose_parameter ()
   local index = gui.parameter_chooser.value
   selected_parameter = possible_parameters[index]
   selected_command = selected_parameter:lower() .. "_value"
end

function choose_track ()
   selected_track = gui.track_chooser.value
   -- TODO: save strings of code per track
   -- TODO: later also save code per track per parameter?
end

function choose_pattern_type ()
   local index = gui.pattern_type_chooser.value
   selected_pattern_type = possible_pattern_types[index]
end


--[[
-- old execute code
-- local code = text_field.text
-- local lines = renoise.song().selected_pattern_track.lines
-- local values = {"note_value", "instrument_value", "volume_value", "panning_value", "delay_value"}
-- local cv = {}
-- for _,cmd in ipairs(values) do
--    cv[cmd] = {}
--    for i,line in ipairs(lines) do
-- 	 table.insert(cv[cmd], line.note_columns[1][cmd])
--    end
-- end

-- for code_line in code:gmatch("[^\r\n]+") do
--    local seq, typ = interpret_line(code_line, cv.note_value)
--    local cmd = typtocmd(typ)
--    for i,line in ipairs(lines) do
-- 	 line.note_columns[1][cmd] = seq[i]
--    end
-- end

--]]