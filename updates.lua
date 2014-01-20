---------------------------------------------------
-- Licensed under the GNU General Public License v2
---------------------------------------------------

-- {{{ Grab environment
local setmetatable = setmetatable
local config = awful.util.getdir("config")
-- }}}

-- updates: provides update-information
-- vicious.widgets.updates
local updates = {}

-- {{{ updates widget type
local function worker(format)
	-- Get update contents
	local f = io.popen(config .. "/bin/system/update-checker.sh")
	local updates = f:read("*all")
	f:close()

	-- Capture update state (security-update, standard-updates)
	local sec, std = string.match(updates, "([%d]+);([%d]+)")
	return {(sec + std), std, sec}
end
-- }}}

return setmetatable(updates, { __call = function(_, ...) return worker(...) end })
