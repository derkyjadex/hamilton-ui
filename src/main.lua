-- main.lua
-- Copyright (c) 2013-2014 James Deery
-- Released under the MIT license <http://opensource.org/licenses/MIT>.
-- See COPYING for details.

local host = require 'host'
local hm = require 'hamilton'
local commands = require 'commands'

local Icons = {
	play = Model({
		  8.00,   0.00, 0,
		 -6.00,   8.00, 0,
		 -6.00,  -8.00, 0,
	}),
	pause = Model({
		 -2.00,   8.00, 0,
		 -8.00,   8.00, 0,
		 -8.00,  -8.00, 0,
		 -2.00,  -8.00, 0
		}, {
		  8.00,   8.00, 0,
		  2.00,   8.00, 0,
		  2.00,  -8.00, 0,
		  8.00,  -8.00, 0
	}),
	exit = Model({
		  0.00,   3.00, 0,
		 -8.00,  11.00, 0,
		-11.00,   8.00, 0,
		 -3.00,   0.00, 0,
		-11.00,  -8.00, 0,
		 -8.00, -11.00, 0,
		  0.00,  -3.00, 0,
		  8.00, -11.00, 0,
		 11.00,  -8.00, 0,
		  3.00,   0.00, 0,
		 11.00,   8.00, 0,
		  8.00,  11.00, 0
	})
}

function BandState()
	local self = {
		playing = Property(false),
		position = Property(0),
		looping = Property(false),
		loop = Property(0, 0)
	}

	local playing = Binding(self.playing, function(value)
		if value then
			hm.play()
		else
			hm.pause()
		end
	end)

	local position = Binding(self.position, function(value)
		hm.seek(value)
	end)

	local looping = Binding(self.looping, function(value)
		hm.set_looping(value)
	end)

	local loop = Binding(self.loop, function(loop_start, loop_end)
		hm.set_loop(loop_start, loop_end)
	end)

	local last_state = {}
	function self.update()
		local state = hm.get_band_state()

		if state.playing ~= last_state.playing then
			playing(state.playing)
		end

		if state.position ~= last_state.position then
			position(state.position)
		end

		if state.looping ~= last_state.looping then
			looping(state.looping)
		end

		if state.loop_start ~= last_state.loop_start or
			state.loop_end ~= last_state.loop_end then
			loop(state.loop_start, state.loop_end)
		end

		last_state = state
	end

	return self
end

PlayHead = Widget:derive(function(self, band_state)
	Widget.init(self)

	function self:add_to(parent)
		Widget.prototype.add_to(self, parent)

		local parent_bounds = {parent:bounds()}
		self:bounds(-3, parent_bounds[2], 3, parent_bounds[4])

		self:bind_property('location', band_state.position, function(position)
			local parent_bounds = {parent:bounds()}
			local loop_start, loop_end = band_state:loop()

			local progress = position / (loop_end - loop_start)
			local x = progress * (parent_bounds[3] - parent_bounds[1])

			return x, parent_bounds[2]
		end)

		local function seek(x)
			local parent_bounds = {parent:bounds()}
			local loop_start, loop_end = band_state:loop()

			x = clamp(x, parent_bounds[1], parent_bounds[3])

			local progress = x / (parent_bounds[3] - parent_bounds[1])
			local position = progress * (loop_end - loop_start)

			band_state:position(position)
		end

		local drag_x, drag_y

		parent:bind_down(function(_, x, y)
			drag_x, drag_y = x, y
			seek(x)
			parent:grab_mouse()
		end)

		parent:bind_motion(function(_, x, y)
			if x ~= 0 then
				drag_x = drag_x + x
				seek(drag_x)
			end
		end)

		parent:bind_up(function(_, x, y)
			parent:release_mouse(drag_x, drag_y)
		end)

		parent:bind_key(function(_, key)
			if key == 32 then
				band_state:playing(not band_state:playing())
			elseif key == 27 then
				host.exit()
			end
		end)

		return self
	end
end)

StateWidget = Widget:derive(function(self, band_state)
	Widget.init(self)

	self:model_location(15, 15)
		:text_size(28)
		:text_location(28, 1.5)
		:fill_colour(0, 0, 0, 0)
		:bind_property('model', band_state.playing, function(playing)
			return playing and Icons.play or Icons.pause
		end)
		:bind_property('text', band_state.position, function(position)
			return string.format('%04d', position)
		end)

	function self:layout(left, width, right, bottom, height, top)
		return Widget.prototype.layout(self, left, 80, nil, bottom, 30, nil)
	end
end)

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
