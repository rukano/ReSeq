<pre>
______     _____            
| ___ \   /  ___|           
| |_/ /___\ `--.  ___  __ _ 
|    // _ \`--. \/ _ \/ _` |
| |\ \  __/\__/ /  __/ (_| |
\_| \_\___\____/ \___|\__, |
                         | |
                         |_|
</pre>


ReSeq
=====

A tool for algorithmic sequence generation and live coding in Renoise
---------------------------------------------------------------------

ReSeq tries to bring some live coding ideas to Renoise. By making a simplified pattern description and allowing custom formulas and mathematical expressions, it is possible to fill the current pattern track with algorithmically produced values.

DISCLAIMER
----------

ReSeq is under **HEAVY** developement. Everything can change and it's not very usable right now. Use at your own risk. I'm happy about recommendations, help, hints and suggestions you can give me. "You can't programm", "Nice tool, but not usable", "I rocked the club yesterday with your tool", anything is acceptable, I'm open for critique.

Current State
-------------

Unusable. Code won't be executed

Building the GUI. Kind of working now.

Pattern library not yet bound.

HELP
====

Commands
--------

* __Note__: sets the value of the note column
* __Instrument__: sets the value of the instrument column
* __Volume__: sets the value of the volume column
* __Paning__: sets the value of the paning column
* __Delay__: sets the value of the delay column

_(in the future maybe fx columns will be covered)_

Patterns
--------

* __Sequence__: the slots will be used sequentially (with looping)
* __Interlace__: <not yet working> the slots will be used sequentially and subtables will be handled sequentially too (for every iteration)
* __Random__: the slots will be used random, there are no checks for repetition, just random.
* __Shuffle__: the slots order is randomized for every new loop, this ensures all slot items will be used, and on each loop the order will be different
_(more to come?)_

Syntax
------

* Every new line represents a new slot
* You can write expressions/formulae on every line
* Some variables will be passed to each slot:
	* **i** = The current line (from 0 to number of lines - 1)
	* **v** = The value of the current line
	* **n** = The total number of lines
	* **_** = Pause/Empty value
	* __TODO:__ x = OFF command (only for notes)
* Some functions are already defined and can be used:
	* **r(min,max)** = random number between min and max
	* **r{a,b,c...}** = random items from the list
	* **sin()**, **cos()**, **tan()**, **etc** (the whole lua math library!)
* Other commands:
	* _cond_ **?** _true_ **:** _false_ (if statements as ternary operator) NOTE: be careful with ifs, use only one per slot, haven't figured out how to chain them.
	* _expr_ **!** _x_ repeats the expr x times in the sequence
	* __TODO__ **@x** "expr" sets the expression for a x index in the table.
	* __TODO__ *x* from here replace the pattern
* __TODO__ You can define your own functions in pure Lua and use them in your slots.


Examples
--------
* a note: `60`
* a function: `sin(i) * 3 + 60`
* a control statement: `i>60 ? 80 : 121`
* an operation on the current value: `v + 12`
* a repetition: `121!3`
* random numbers: `r(60,62)`
* random items: `r{60,80,100,121}`
* a pause: `_`
* interpolation from 40 to 60: `floor((i/n)*20)+40`