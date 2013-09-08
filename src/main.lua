-- main.lua
-- Copyright (c) 2013 James Deery
-- Released under the MIT license <http://opensource.org/licenses/MIT>.
-- See COPYING for details.

local host = require 'host'
local hm = require 'hamilton'

local function Hamilton()
	local self = {
	}

	return self
end

local function HamiltonUI(root, app)
	root:fill_colour(0.2, 0.2, 0.2, 1.0)
		:bind_down(host.exit)

	Toolbar():add_to(root)
		:add_button(0.1, 0.8, 0.3, hm.play)
		:add_button(0.9, 0.7, 0.2, hm.pause)
		:layout(10, nil, nil, nil, nil, 10)

	return root
end

HamiltonUI(Widget.root(), Hamilton())

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

hm.set_loop(00000, 04000)
hm.set_looping(true)

function frame()
	local state = hm.get_band_state()
end
