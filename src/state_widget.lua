-- Copyright (c) 2014 James Deery
-- Released under the MIT license <http://opensource.org/licenses/MIT>.
-- See COPYING for details.

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
			local bars = math.floor(position / 2000)
			position = position % 2000
			local beats = math.floor(position / 500)
			position = position % 500

			return string.format('%02d-%d.%03d', bars, beats, position)
		end)

	function self:layout(left, width, right, bottom, height, top)
		return Widget.prototype.layout(self, left, 200, nil, bottom, 30, nil)
	end
end)
