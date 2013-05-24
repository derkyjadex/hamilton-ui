-- main.lua
-- Copyright (c) 2013 James Deery
-- Released under the MIT license <http://opensource.org/licenses/MIT>.
-- See COPYING for details.

local host = require 'host'

local function CC(channel, control)
	local self = Observable(0)
	self.changed:add(function(x)
		commands.send_cc(channel, control, x)
	end)

	return self
end

local function Hamilton()
	local self = {
		controls = {
			CC(0,  0),
			CC(0,  1),
			CC(0,  2),
			CC(0,  3),
			CC(0,  4),
			CC(0,  5),
			CC(0,  6),
			CC(0,  7),
			CC(0,  8),
			CC(0,  9),
			CC(0, 10),
			CC(0, 11),
			CC(0, 12),
			CC(0, 13),
			CC(0, 14),
			CC(0, 15)
		}
	}

	return self
end

local function HamiltonUI(root, app)
	root:fill_colour(0.2, 0.2, 0.2, 1.0)
		:bind_down(host.exit)

	for i, cc in ipairs(app.controls) do
		SliderWidget():add_to(root)
			:layout(40 * i - 20, nil, nil, 10, nil, 10)
			:bind_value(cc)
	end

	return root
end

HamiltonUI(Widget.root(), Hamilton())

local synths = {commands.get_synths()}
commands.set_synth(0, synths[1])
