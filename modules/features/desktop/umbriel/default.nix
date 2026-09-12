{ ... }:
{
  flake.nixosModules.umbriel =
    { inputs, pkgs, ... }:
    {
      imports = [ inputs.umbriel.nixosModules.default ];

      programs.umbriel.enable = true;

      environment.systemPackages = with pkgs; [
        jq
        xwayland-satellite
      ];

      home-manager.sharedModules = [
        (
          { inputs, ... }:
          {
            imports = [ inputs.umbriel.homeModules.default ];

            programs.umbriel = {
              enable = true;
              package = null;

              settings = {
                include.optional.files = [ "~/.config/umbriel/noctalia.toml" ];

                general = {
                  autostart = [ "noctalia" ];
                  mod_key = "Super";
                  xwayland = true;
                  show_cheatsheet = false;
                  focus_on_activate = false;
                };

                environment = {
                  ELECTRON_OZONE_PLATFORM_HINT = "auto";
                  SDL_VIDEODRIVER = "wayland";
                };

                input = {
                  keyboard = {
                    layout = "us";
                    variant = "intl";
                    repeat_rate = 40;
                    repeat_delay = 250;
                    numlock_toggle = true;
                  };

                  touchpad = {
                    natural_scroll = true;
                    click_method = "clickfinger";
                    scroll_factor = 0.4;
                    accel_profile = "flat";
                    sensitivity = 0.35;
                  };

                  mouse = {
                    accel_profile = "flat";
                    sensitivity = 0.35;
                  };
                };

                appearance = {
                  prefer_no_csd = true;
                  border_width = 2;
                  corner_radius = 10;

                  blur = {
                    enabled = true;
                    optimized = true;
                    passes = 3;
                    radius = 3;
                    noise = 0.02;
                    brightness = 0.9;
                    contrast = 0.9;
                    saturation = 1.1;
                  };

                  shadow.enabled = true;
                };

                window_rule = [
                  {
                    blur = true;
                    blur_optimized = true;
                  }
                  {
                    match.app_id = "^dev.noctalia.Noctalia$";
                    default_floating = true;
                    default_size = [
                      1020
                      900
                    ];
                  }
                ];

                layer_rule = [
                  {
                    match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$";
                    blur = true;
                    blur_ignore_alpha = 0.5;
                    blur_optimized = false;
                  }
                ];

                keybinds = {
                  "Mod+Return" = "spawn:noctalia msg panel-toggle launcher";
                  "Mod+Escape" = "spawn:noctalia msg panel-toggle session";

                  "Mod+Shift+T" = "spawn:foot -e tmux";
                  "Mod+Shift+Alt+T" = "spawn:foot";
                  "Mod+Shift+F" = "spawn:nautilus";
                  "Mod+Shift+B" = "spawn:brave-origin";
                  "Mod+Shift+Alt+B" = "spawn:brave-origin --private";
                  "Mod+Shift+S" = "spawn:steam";
                  "Mod+Shift+D" = "spawn:sable";
                  "Mod+Shift+M" = "spawn:brave-origin --app=https://music.youtube.com/";
                  "Mod+Shift+G" = "spawn:brave-origin --app=https://web.whatsapp.com/";
                  "Mod+Alt+H" = "spawn:toggle-tv";

                  "Mod+M" = "window-toggle-fullscreen";
                  "Mod+N" = "window-toggle-floating";
                  "Mod+Shift+W" = "window-close";
                  "Mod+Backspace" = "window-toggle-maximize";

                  "Mod+Left" = "window-focus-left";
                  "Mod+Down" = "window-focus-down";
                  "Mod+Up" = "window-focus-up";
                  "Mod+Right" = "window-focus-right";

                  "Mod+H" = "window-focus-left";
                  "Mod+J" = "window-focus-down";
                  "Mod+K" = "window-focus-up";
                  "Mod+L" = "window-focus-right";

                  "Mod+Shift+Left" = "column-move-left";
                  "Mod+Shift+Down" = "window-move-down";
                  "Mod+Shift+Up" = "window-move-up";
                  "Mod+Shift+Right" = "column-move-right";

                  "Mod+Ctrl+H" = "window-move-or-output-left";
                  "Mod+Ctrl+J" = "window-move-or-output-down";
                  "Mod+Ctrl+K" = "window-move-or-output-up";
                  "Mod+Ctrl+L" = "window-move-or-output-right";
                  "Mod+Ctrl+M" = "window-toggle-maximize";
                  "Mod+O" = "overview-toggle";
                  "Mod+P" = "spawn:noctalia msg screenshot-annotate";
                  "Mod+Shift+P" = "spawn:omarchy capture screenrecording";
                  "Mod+Alt+C" = "spawn:sh -c 'pkill hyprpicker || hyprpicker -a'";

                  "Mod+1" = "workspace-switch:1";
                  "Mod+2" = "workspace-switch:2";
                  "Mod+3" = "workspace-switch:3";
                  "Mod+4" = "workspace-switch:4";
                  "Mod+5" = "workspace-switch:5";
                  "Mod+6" = "workspace-switch:6";
                  "Mod+Shift+1" = "window-move-to-workspace:1";
                  "Mod+Shift+2" = "window-move-to-workspace:2";
                  "Mod+Shift+3" = "window-move-to-workspace:3";
                  "Mod+Shift+4" = "window-move-to-workspace:4";
                  "Mod+Shift+5" = "window-move-to-workspace:5";
                  "Mod+Shift+6" = "window-move-to-workspace:6";

                  "Mod+Q" = "workspace-switch:1";
                  "Mod+W" = "workspace-switch:2";
                  "Mod+E" = "workspace-switch:3";
                  "Mod+R" = "workspace-switch:4";
                  "Mod+T" = "workspace-switch:5";
                  "Mod+Y" = "workspace-switch:6";

                  "Mod+S" = "spawn:noctalia msg panel-toggle control-center";
                  "Mod+Comma" = "spawn:noctalia msg settings-toggle";
                  "Alt+Tab" = "spawn:noctalia msg window-switcher";
                  "Mod+Shift+A" = "spawn:noctalia msg screenshot-annotate";
                  "Mod+Ctrl+A" = "spawn:noctalia msg annotate";

                  "XF86AudioRaiseVolume" = "spawn:noctalia msg volume-up";
                  "XF86AudioLowerVolume" = "spawn:noctalia msg volume-down";
                  "XF86AudioMute" = "spawn:noctalia msg volume-mute";
                  "XF86MonBrightnessUp" = "spawn:noctalia msg brightness-up";
                  "XF86MonBrightnessDown" = "spawn:noctalia msg brightness-down";
                };
              };
            };
          }
        )
      ];
    };
}
