-- Copyright (c) 2014 James Deery
-- Released under the MIT license <http://opensource.org/licenses/MIT>.
-- See COPYING for details.

local hm = require 'hamilton'

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
