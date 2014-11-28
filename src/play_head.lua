-- Copyright (c) 2014 James Deery
-- Released under the MIT license <http://opensource.org/licenses/MIT>.
-- See COPYING for details.

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

		local drag_x, drag_y

		local function seek()
			local parent_bounds = {parent:bounds()}
			local loop_start, loop_end = band_state:loop()

			drag_x = clamp(drag_x, parent_bounds[1], parent_bounds[3])

			local progress = drag_x / (parent_bounds[3] - parent_bounds[1])
			local position = progress * (loop_end - loop_start)

			band_state:position(position)
		end

		parent:bind_down(function(_, x, y)
			drag_x, drag_y = x, y
			seek()
			parent:grab_mouse()
		end)

		parent:bind_motion(function(_, x, y)
			if x ~= 0 then
				drag_x = drag_x + x
				seek()
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
