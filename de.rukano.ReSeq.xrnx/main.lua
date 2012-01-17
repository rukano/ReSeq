_AUTO_RELOAD_DEBUG = true 

require "ReSeq"

--------------------------------------------------------------------------------
-- tool registration
--------------------------------------------------------------------------------

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:ReSeq",
  invoke = function() 
    show_window() 
  end
}

renoise.tool():add_keybinding {
  name = "Global:Tools:ReSeq",
  invoke = function(repeated)
    if (not repeated) then
       show_window()
    end
  end
}

--------------------------------------------------------------------------------
-- gui
--------------------------------------------------------------------------------

function typtocmd (typ)
   local cmd = ""
   if typ == "note" then
      cmd = "note_value"
   elseif typ == "inst" then
      cmd = "instrument_value"
   elseif typ == "vol" then
      cmd = "volume_value"
   elseif typ == "pan" then
      cmd = "panning_value"
   elseif typ == "dly" then
      cmd = "delay_value"
   end
   return cmd
end

function show_window ()
  local app = renoise.app()

  local vb = renoise.ViewBuilder()
  local dialog_title = "Mini interpreter"
  local text_field = vb:multiline_textfield{
   text=[[note: seq -> v]],
   width=600,
   height=300,
   font="mono"
  }
  local exec_button = vb:button{
    text="execute",
    width=600,
    height=20,
    color={100,255,100}
  }
  local dialog_content = vb:column{
   margin=0,
   text_field,
   exec_button
  }

  exec_button:add_pressed_notifier(function()
    local code = text_field.text
    local lines = renoise.song().selected_pattern_track.lines
    ------------------------------------------------------------
    local values = {"note_value", "instrument_value", "volume_value", "panning_value", "delay_value"}
    local cv = {}
    for _,cmd in ipairs(values) do
       cv[cmd] = {}
       for i,line in ipairs(lines) do
	  table.insert(cv[cmd], line.note_columns[1][cmd])
       end
    end

    for code_line in code:gmatch("[^\r\n]+") do
       local seq, typ = interpret_line(code_line, cv.note_value)
       local cmd = typtocmd(typ)
       for i,line in ipairs(lines) do
	  line.note_columns[1][cmd] = seq[i]
       end
    end
   ------------------------------------------------------------
  end)
  app:show_custom_prompt(dialog_title, dialog_content, {})
end
