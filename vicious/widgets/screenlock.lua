---------------------------------------------------
-- Licensed under the GNU General Public License v2
---------------------------------------------------

-- {{{ Grab environment
local setmetatable = setmetatable
-- }}}


-- screenlock: show screen idle-activation state
-- vicious.widgets.screenlock
local screenlock = {}


-- {{{ screenlock widget type
local function worker(format)
    local namespace = " org.gnome.desktop.lockdown "
	local attribute = " disable-lock-screen "
	local f = io.popen("gsettings get " .. namespace .. attribute)
	local lock = f:read("*all")
	f:close()

	local is_active = string.match(lock, "(%a+)")

	return {is_active}
end
-- }}}

return setmetatable(screenlock, { __call = function(_, ...) return worker(...) end })
