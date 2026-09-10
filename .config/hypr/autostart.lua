-- Extra autostart processes.
-- o.launch_on_start("my-service")
-- Virtual display (HEADLESS-1) is created/removed by Sunshine's prep-cmd
-- for the Steam app (see ~/.config/sunshine/apps.json), not at boot.
o.exec_on_start("sunshine")
o.exec_on_start("hushmic --tray")

o.launch_on_start("foot")
o.launch_on_start("brave-origin")
o.launch_on_start("sable")
o.launch_on_start("steam")
