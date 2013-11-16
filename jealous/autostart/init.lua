
module("jealous.autostart")
function autostart()
	os.execute("~/Bin/app/dropbox/dropbox --S &")
	os.execute("tomboy &")
	naughty.notify{text="Autostart complete!\n" .. os.date("%d.%m.%Y %T\n\n"), timeout = 10}
end
