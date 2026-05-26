-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function () 
  hl.exec_cmd("hypridle")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
  hl.exec_cmd(quickshell)
end)
