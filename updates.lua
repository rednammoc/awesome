---------------------------------------------------
-- Licensed under the GNU General Public License v2
---------------------------------------------------

-- {{{ Grab environment
local setmetatable = setmetatable
-- }}}


-- updates: provides update-information
-- vicious.widgets.updates
local updates = {}


-- {{{ updates widget type
local function worker(format)
	local apt_check = "/usr/lib/update-notifier/apt-check 2>&1"

	-- Get update contents
	local f = io.popen(apt_check)
	local updates = f:read("*all")
	f:close()

	-- Capture update state
	local sec, def = string.match(updates, "([%d]+);([%d]+)")
	return {(sec + def), def, sec}
end
-- }}}

return setmetatable(updates, { __call = function(_, ...) return worker(...) end })
