-- main.lua
-- Copyright (c) 2013 James Deery
-- Released under the MIT license <http://opensource.org/licenses/MIT>.
-- See COPYING for details.

local function Hamilton()
	local self = {
	}

	return self
end

local function HamiltonUI(root, app)
	root:fill_colour(0.2, 0.2, 0.2, 1.0)
		:bind_down(commands.exit)

	return root
end

HamiltonUI(Widget.root(), Hamilton())
