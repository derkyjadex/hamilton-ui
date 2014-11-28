-- main.lua
-- Copyright (c) 2013-2014 James Deery
-- Released under the MIT license <http://opensource.org/licenses/MIT>.
-- See COPYING for details.

local host = require 'host'
local hm = require 'hamilton'
local commands = require 'commands'

local function Hamilton()
	local self = {
		band_state = BandState()
	}

	local on_frame
	on_frame = function()
		self.band_state:update()
		commands.enqueue(on_frame)
	end

	commands.enqueue(on_frame)

	return self
end

local function HamiltonUI(root, app)
	root:fill_colour(0.2, 0.2, 0.2, 1.0)
		:grid_size(100, 1000)
		:grid_offset(0, -1)
		:grid_colour(0.5, 0.5, 0.5)

	StateWidget(app.band_state)
		:add_to(root)
		:layout(0, nil, nil, 0, nil, nil)

	PlayHead(app.band_state)
		:add_to(root)

	Toolbar():add_to(root)
		:add_button(0.1, 0.8, 0.3, Icons.play, hm.play)
		:add_button(0.9, 0.7, 0.2, Icons.pause, hm.pause)
		:add_spacer()
		:add_button(0.9, 0.3, 0.1, Icons.exit, host.exit)
		:layout(10, nil, nil, nil, nil, 10)

	return root
end

local app = Hamilton()
HamiltonUI(Widget.root(), app)

local synths = hm.get_synths()
hm.set_synth(1, synths[1])
hm.set_synth(2, synths[1])

hm.add_note(1, 00000, 2000, 60, 0.5)
hm.add_note(1, 00020, 1880, 64, 0.5)
hm.add_note(1, 00040, 1760, 67, 0.5)

hm.add_note(1, 01800, 2200, 67, 0.5)
hm.add_note(1, 01900, 2100, 64, 0.5)
hm.add_note(1, 02000, 2000, 60, 0.5)

hm.add_set_patch(2, 0, 32)
hm.add_note(2, 00000, 200, 65, 0.7)
hm.add_note(2, 00500, 200, 58, 0.7)
hm.add_note(2, 01000, 200, 58, 0.7)
hm.add_note(2, 01500, 200, 58, 0.7)

hm.add_note(2, 02000, 200, 62, 0.7)
hm.add_note(2, 02500, 200, 58, 0.7)
hm.add_note(2, 03000, 200, 58, 0.7)
hm.add_note(2, 03500, 200, 58, 0.7)

hm.seq_commit()

app.band_state:loop(00000, 04000)
app.band_state:looping(true)
