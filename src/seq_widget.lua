-- Copyright (c) 2014 James Deery
-- Released under the MIT license <http://opensource.org/licenses/MIT>.
-- See COPYING for details.

local hm = require 'hamilton'

SeqWidget = Widget:derive(function(self, channel)
	Widget.init(self)

	self:fill_colour(0, 0, 0, 0)
		:grid_colour(0.4, 0.4, 0.4)

	local notes = {}
	local grid_time = 125
	local scale = function() return 0.2, 10 end
	local pan = function() return 0, -50 end

	local function transform_note(note)
		local time_scale, note_scale = scale()
		local time_pan, note_pan = pan()

		for _, note in ipairs(notes) do
			local left = (note.time + time_pan) * time_scale
			local width = note.length * time_scale
			local bottom = (note.num + note_pan) * math.floor(note_scale)
			local height = note_scale + 1

			note:layout(left, width, nil, bottom, height, nil)
				:invalidate()
		end
	end

	local function update_transform()
		local time_scale, note_scale = scale()
		local time_pan, note_pan = pan()

		self:grid_size(time_scale * grid_time, math.floor(note_scale))
			:grid_offset(time_pan * time_scale, note_pan * note_scale)
			:invalidate()

		for _, note in ipairs(notes) do
			transform_note(note)
		end
	end

	local function note_colour(note)
		local min = {0.6, 1, 0.42, 1}
		local max = {1, 0.16, 0.15, 1}

		return table.unpack(
			mix(min, max, note.velocity))
	end

	function self:refresh_notes()
		for _, note in ipairs(notes) do
			note:remove()
		end
		notes = {}

		for _, e in ipairs(hm.get_seq_items()) do
			if e.channel == channel and e.type == 'note' then
				local note = Widget()
					:add_to(self)
					:fill_colour(note_colour(e))
					:border_width(1)
					:border_colour(0, 0, 0, 1)

				note.time = e.time
				note.length = e.length
				note.num = e.num
				note.velocity = e.velocity

				transform_note(note)

				table.insert(notes, note)
			end
		end

		return self
	end

    function self:layout(left, width, right, bottom, height, top, offset_x, offset_y)
       Widget.prototype.layout(self, left, width, right, bottom, height, top, offset_x, offset_y)
       update_transform()
    end

	update_transform()
	self:refresh_notes()
end)
