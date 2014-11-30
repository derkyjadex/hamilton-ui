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

	local function transform_note(widget)
		local note = widget.note
		local time_scale, note_scale = scale()
		local time_pan, note_pan = pan()

		local left = (note.time + time_pan) * time_scale
		local width = note.length * time_scale
		local bottom = (note.num + note_pan) * math.floor(note_scale)
		local height = note_scale + 1

		widget:layout(left, width, nil, bottom, height, nil)
			:invalidate()
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

	local function make_note_widget(note)
		local widget = Widget()
			:add_to(self)
			:fill_colour(note_colour(note))
			:border_width(1)
			:border_colour(0, 0, 0, 1)

		widget.note = note
		transform_note(widget)

		return widget
	end

	function self:refresh_notes()
		for _, note in ipairs(notes) do
			note:remove()
		end
		notes = {}

		for _, e in ipairs(hm.get_seq_items()) do
			if e.channel == channel and e.type == 'note' then
				local widget = make_note_widget(e)

				table.insert(notes, widget)
			end
		end

		return self
	end

	function self:layout(...)
		Widget.prototype.layout(self, ...)
		update_transform()
	end

	self:bind_down(function(_, x, y)
		local time_scale, note_scale = scale()
		local time_pan, note_pan = pan()

		local note = {
			channel = channel,
			type = 'note',
			time = (x / time_scale) - time_pan,
			num = math.floor((y / note_scale) - note_pan),
			length = 200,
			velocity = 0.7
		}

		local note_widget = make_note_widget(note)

		local orig_x, orig_y = self:grab_mouse()
		self:bind_motion(function(_, motion_x, motion_y)
			note.length = clamp(note.length + (motion_x / time_scale), 50, nil)
			note.velocity = clamp(note.velocity + (motion_y / 100), 0, 1)

			transform_note(note_widget)
			note_widget:fill_colour(note_colour(note))
		end)

		self:bind_up(function()
			self:release_mouse(orig_x, orig_y)
			self:bind_up(nil)
			self:bind_motion(nil)

			note_widget:remove()

			hm.add_note(note.channel, note.time, note.length, note.num, note.velocity)
			self:refresh_notes()

			hm.seq_commit()
		end)
	end)

	update_transform()
	self:refresh_notes()
end)
