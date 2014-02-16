-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
beautiful = require("beautiful")
-- Notification library
require("naughty")
-- shifty - dynamic tagging library
--require("shifty")
-- Calendar
require("calendar2")
-- Widgets
vicious = require("vicious")

-- {{{ Variable definitions

-- Keys
local altkey	= "Mod1"	-- ALT-KEY
local modkey	= "Mod4"	-- WIN-KEY
local clkey		= "Mod3"	-- CAPS-LOCK-KEY

-- Folders
local home		= os.getenv("HOME")
local config 	= awful.util.getdir("config")
local exec 		= awful.util.spawn
local sexec		= awful.util.spawn_with_shell

-- Basic Applications
local filemanager 		= "spacefm"
local terminal 			= "x-terminal-emulator "
local editor 			= os.getenv("EDITOR") or "editor"
local browser 			= "firefox"
local email				= "thunderbird"

-- Utils
local multidrop 		= home .. "/Bin/app/dropbox/dropbox"
local login_screen 		= config .. "/bin/screen/login_screen.py"

-- Commands
local terminal_cmd		= terminal
local editor_cmd 		= terminal .. " -e " .. editor
local browser_cmd		= browser
local email_cmd			= email
local filemanager_cmd	= filemanager
local updatemanager_cmd	= "update-manager"

local shutdown_cmd		= function () awful.util.spawn("/usr/lib/indicator-session/gtk-logout-helper --shutdown") 	end
local restart_cmd		= function () awful.util.spawn("/usr/lib/indicator-session/gtk-logout-helper --restart") 	end
local lockscreen_cmd	= function () os.execute("xtrlock") 			end
local suspend_cmd		= function () os.execute("sudo pm-suspend") 	end
local hibernate_cmd		= function () os.execute("sudo pm-hibernate") 	end

-- }}}

-- {{{ Define colours. icons, and wallpapers
beautiful.init(config .. "/theme.lua")
-- }}}

-- {{{ Helper
function toggle_screenlock () 
	local namespace = " org.gnome.desktop.lockdown "
	local attribute = " disable-lock-screen "

	-- Get screen-lock state
	local f = io.popen("gsettings get " .. namespace .. attribute)
	local lock = f:read("*all")
	f:close()

	-- Toggle state
	local is_active = string.match(lock, "(%a+)")
	local state = (is_active == "true" and "false" or "true")
	os.execute("gsettings set " .. namespace .. attribute .. state)
end
-- }}}

-- {{{ Error handling

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Layout and Tags

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.max,
    awful.layout.suit.tile,
    awful.layout.suit.floating,
}

-- Define a tag table which hold all screen tags.
tags = {}
-- Each screen has its own tag table.
tags[1] = awful.tag({ "web", "mail" }, 1, layouts[1])
tags[2] = awful.tag({ "main", "dev", "gfx"}, 2, layouts[1])
tags[3] = awful.tag({ "sys", "im", "org", "doc", "note", "media" }, 3, layouts[1])

-- }}}

-- {{{ Wibox

-- Create a textclock widget
timewidget = widget({ type = "textbox" })
vicious.register(timewidget, vicious.widgets.date, '<span color="#ffffff" weight="bold"> %F %R </span>')
calendar2.addCalendarToWidget(timewidget)

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create volume-widget
volwidget = widget({ type = "textbox" })
vicious.register(volwidget, vicious.widgets.volume, '<span color="#ffffff" weight="bold"> Volume:</span><span color="#ffffff"> $1% </span>', 2, "Master")

-- Create screenlock-widget
screenlockwidget = widget({type = "textbox" })
screenlockwidget:buttons( awful.button({ }, 0, function() 	toggle_screenlock()	end))
vicious.register(screenlockwidget, vicious.widgets.screenlock, '<span color="#ffffff" weight="bold"> Lock:</span><span color="#ffffff"> $1 </span>')

-- Create updates-widget
updateswidget = widget({type = "textbox"})
updateswidget:buttons( awful.button({ }, 0, function() 	awful.util.spawn(updatemanager_cmd)	end))
vicious.register(updateswidget, vicious.widgets.updates, '<span color="#ffffff" weight="bold"> Updates:</span><span color="#ffffff"> $1 </span>')

-- Create memory-widget
memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem, '<span color="#ffffff" weight="bold"> Memory:</span><span color="#ffffff"> $1% </span>', 13)

-- Create logo
mylogo = widget({type = "textbox" })
mylogo.text = "<span color=\"#ffffff\"> (◣_◢) </span>"

-- Create spacer
myspacer = widget({type = "textbox" })
myspacer.text = " "

-- Create quit-menu (label, table, icon)
mypowermenu = awful.menu( {
    items = {
        { "Lock Screen",    lockscreen_cmd  },
        { "Hibernate",      hibernate_cmd   },
       -- { "Suspend",        suspend_cmd     },
        { "Restart",         restart_cmd      },
        { "Shutdown",       shutdown_cmd    }}
    })
mypowerlauncher = awful.widget.launcher({ image = image(beautiful.power_icon), menu = mypowermenu })

-- Create a wibox for each screen and add it
mywibox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
			mylogo,
            mytaglist[s],
            layout = awful.widget.layout.horizontal.leftright
        },
		mypowerlauncher,
		myspacer, 
        timewidget,
		myspacer, 
		s == 2 and memwidget or nil,
		s == 2 and updateswidget or nil,
		s == 2 and volwidget or nil,
		s == 2 and screenlockwidget or nil,
        s == 3 and mysystray or nil,
		myspacer, 
        mylayoutbox[s],
		myspacer, 
        mytasklist[s],
		myspacer, 
        layout = awful.widget.layout.horizontal.rightleft
    }
end

wibobox = {}
mypromptbox = {}

function wibotoggle()
	wibobox[mouse.screen].visible = not wibobox[mouse.screen].visible
	if not wibobox[mouse.screen].visible then keygrabber.stop() end
	return wibobox[mouse.screen].visible
end

function wiborun(prompt_text, callback, cache)
	if not wibotoggle() then return end
	awful.prompt.run({ prompt = prompt_text },
		  mypromptbox[mouse.screen].widget,
		  callback,		-- execute callback when pressing enter
		  wibotoggle,	-- toggle when success
		  cache, 		
		  nil, 			
		  wibotoggle	-- toggle when abort
	)
end

wibotogglebtn = widget({ type = "imagebox" })
wibotogglebtn.image = image(beautiful.close_icon) 
wibotogglebtn:buttons(awful.util.table.join(
	awful.button({ }, 1, function () wibotoggle() end)	-- left mouse button click
))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })

    -- Create bottom wibox for each screen
    wibobox[s] = awful.wibox({position = "bottom", screen = s})
    wibobox[s].widgets = {
		{
			myspacer,
        	mypromptbox[s], 
        	layout = awful.widget.layout.horizontal.leftright
		},
        wibotogglebtn,
        layout = awful.widget.layout.horizontal.rightleft
    }
    wibobox[s].visible = false
    wibobox[s].screen = s
end

-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    -- awful.button({ }, 3, function ()  end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
	-- Tag manipulation
    awful.key({ modkey,           }, "Left", 	awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",	awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape",	awful.tag.history.restore),
--  awful.key({ modkey			  }, "a", 		shifty.add), 					-- create a new tag
-- 	awful.key({ modkey			  }, "r", 		shifty.rename), 				-- rename a tag
--  awful.key({ modkey,           }, "w", 		shifty.del), 					-- remove a tag

	-- Client manipulation
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal_cmd) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
	awful.key({ modkey }, "F2",  function ()  
		wiborun("Run:", 
			function (...)
			  local result = awful.util.spawn(...)
			  if type(result) == "string" then
				 mypromptbox.widget.text = result
			  end
			end,
			awful.util.getdir("cache") .. "/history")
    end),
    awful.key({ modkey }, "F3", function ()
		wiborun("Web:",
            function (command)
                sexec("firefox 'http://www.google.com/?q="..command.."'")
                awful.tag.viewonly(tags[scount][3])
            end)
    end),

	-- Volume keys
  	awful.key({ }, "XF86AudioLowerVolume", 
		  function () awful.util.spawn("amixer -q sset Master 2dB-") 	end),
	awful.key({ }, "XF86AudioRaiseVolume", 
		  function () awful.util.spawn("amixer -q sset Master 2dB+") 	end),

	-- System keys
	awful.key({ modkey }, "F10", function () toggle_screenlock() 		end),
	awful.key({ modkey }, "F11", function () mypowermenu:show(true)     end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- }}}

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
	-- Firefox
     { rule = { role = "browser" },					properties = { tag = tags[1][1] } },
     { rule = { class = "Dialog" },					properties = { floating = true, above = true  } },
	-- Bind applications to tags.
     { rule = { class = "Thunderbird" },			properties = { tag = tags[1][2] } },
     { rule = { class = "Skype" },					properties = { tag = tags[3][2] } },
     { rule = { class = "Calibre" },				properties = { tag = tags[3][3] } },
     { rule = { class = "Zotero" },					properties = { tag = tags[3][3] } },
     { rule = { class = "Evince" },					properties = { tag = tags[3][4] } },
     { rule = { class = "Tomboy" },					properties = { tag = tags[3][5] } },
     { rule = { class = "Clementine" },				properties = { tag = tags[3][6] } },
     { rule = { class = "Amarok" },					properties = { tag = tags[3][6] } },
	 { rule = { class = "Update-Manager" },			properties = { above = false, tag = tags[3][1] } },
	 -- Bind login-screen to tags
	 { rule = { class = "Login_screen_left.py" },	properties = { tag = tags[1][1] } },
	 { rule = { class = "Login_screen_center.py" },	properties = { tag = tags[2][1] } },
	 { rule = { class = "Login_screen_right.py" },	properties = { tag = tags[3][1] } }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Autostart
awful.util.spawn(home .. "/Bin/app/dropbox/dropbox --S")
awful.util.spawn("tomboy  --panel-applet")
awful.util.spawn(config .. "/bin/screen/login_screen_left.py")
awful.util.spawn(config .. "/bin/screen/login_screen_center.py")
awful.util.spawn(config .. "/bin/screen/login_screen_right.py")
-- }}}

