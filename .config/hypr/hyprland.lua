-- Hyprland Lua config, migrated 1:1 from hyprland.conf (hyprlang is deprecated since 0.55).
-- API ground truth: /usr/share/hypr/stubs/hl.meta.lua + Hyprland 0.56.2 sources.
-- The .conf is kept alongside as a rollback: delete this file and restart Hyprland to fall back.

hl.config({
	debug = {
		disable_logs = false,
	},
})

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "eDP-1", mode = "2560x1600@240.02", position = "0x0", scale = 2 })
hl.monitor({ output = "DP-2", mode = "3840x2160@239.99", position = "1280x-340", scale = 2, vrr = 2, bitdepth = 10 })
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60.00", position = "3200x-640", scale = 2, transform = 3 })

hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1", default = true, persistent = true })
hl.workspace_rule({ workspace = "8", monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "9", monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-2", default = true, persistent = true })
hl.workspace_rule({ workspace = "7", monitor = "DP-2", persistent = true })
hl.workspace_rule({ workspace = "10", monitor = "DP-2", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "eDP-1", default = true, persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "eDP-1", persistent = true })
hl.workspace_rule({ workspace = "5", monitor = "eDP-1", persistent = true })
hl.workspace_rule({ workspace = "6", monitor = "eDP-1", persistent = true })

------------------------------
---- ENVIRONMENT VARIABLES ----
------------------------------

-- Kitty
hl.env("KITTY_ENABLE_WAYLAND", "1")

-- VA-API hardware video decode on the 4070 (nvidia-vaapi-driver);
-- MOZ_DRM_DEVICE points Firefox at the NVIDIA render node (renderD129 = 01:00.0),
-- RDD sandbox must be off for nvidia-vaapi-driver to reach the GPU
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("MOZ_DRM_DEVICE", "/dev/dri/renderD129")
hl.env("MOZ_DISABLE_RDD_SANDBOX", "1")

-- XDG Desktop Portal
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.env("MOZ_ENABLE_WAYLAND", "1") -- Enable Wayland support in Mozilla applications

-- XXX: Fix qutebrowser rendering on fractional scaling
hl.env("QT_SCALE_FACTOR_ROUNDING_POLICY", "RoundPreferFloor")

-- Other QT stuff
-- (From the Qt documentation) enables automatic scaling, based on the monitor's pixel density
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
-- Tell Qt applications to use the Wayland backend, and fall back to x11 if Wayland is unavailable
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
-- Tells Qt based applications to pick your theme from qt6ct, use with Kvantum.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Misc
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("GDK_SCALE", "2")
hl.env("XCURSOR_SIZE", "32")

-- NVIDIA
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- (LIBVA_DRIVER_NAME / NVD_BACKEND are set in the VA-API block above — don't redeclare here)
hl.env("AQ_DRM_DEVICES", "/dev/dri/dgpu:/dev/dri/igpu")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- https://gist.github.com/kRHYME7/1d2574e8f3a4b7ad4059535503ce1eaa
hl.env("__GLX_GSYNC_ALLOWED", "1")
hl.env("__GL_VRR_ALLOWED", "1")
hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")
hl.env("PROTON_ENABLE_NGX_UPDATER", "1")
hl.env("VDPAU_DRIVER", "nvidia")

-------------------
---- AUTOSTART ----
-------------------

-- Unlike hyprlang's exec-once, hl.exec_cmd() called from hyprland.start runs
-- outside the executor's "currently launching exec-once" guard, so every process
-- started here inherits a fresh HL_INITIAL_WORKSPACE_TOKEN pinned to whatever
-- workspace is focused at the first rendered frame (2, since DP-2 is the only
-- monitor up that early). Any window one of these opens within
-- misc:initial_workspace_token_timeout then gets yanked onto that workspace,
-- ignoring the rules below — that is what dragged a restored Firefox window onto
-- workspace 2. Dropping the token restores the hyprlang behaviour: placement at
-- startup is decided by the exec rules and windowrules alone. Interactive
-- launches (keybinds, the menu) are untouched and still track their workspace.
local function exec_once(cmd, rules)
	hl.exec_cmd("env -u HL_INITIAL_WORKSPACE_TOKEN " .. cmd, rules)
end

-- exec-once equivalents: hyprland.start fires once per compositor launch, not on reloads
hl.on("hyprland.start", function()
	-- OpenRC
	exec_once("openrc --user hyprland")

	-- Night light
	exec_once("wlsunset -l 40.440624 -L -79.995888")

	-- Notifications
	exec_once("mako")

	-- Idle management: screens off after 5 min (no locker) — see hypridle.conf
	exec_once("hypridle")

	-- Clipboard history (Super+V to pick from it)
	exec_once("wl-paste --type text --watch cliphist store")
	exec_once("wl-paste --type image --watch cliphist store")

	-- XDG Desktop Portal
	exec_once("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	exec_once("xrdb -merge ~/.Xresources") -- Xft.dpi 192 so XWayland apps (Steam) scale on HiDPI
	exec_once("~/.config/hypr/xdg-portal-hyprland")

	-- Wallpaper
	exec_once("hyprpaper")

	-- PipeWire audio server
	-- NOTE: Disabled in favor of openRC user service
	-- exec_once("gentoo-pipewire-launcher restart &")

	-- Polkit authentication agent
	exec_once("/usr/libexec/hyprpolkitagent")
	exec_once("sunshine") -- Moonlight streaming host (Apple TV) — pairs on demand, PIN-protected

	-- Terminals on workspaces 1-3 at startup, attached to continuum-restored tmux
	-- sessions (w1 "monitoring 2", w2 "cedana", w3 "monitoring") — see scripts/tmux_boot
	exec_once("~/code/scripts/tmux_boot")

	-- Chat/mail apps at startup — windowrules below pin them to their workspaces (5/6/8)
	exec_once("slack", { workspace = "5 silent" })
	-- LD_PRELOAD: discord_utils.node needs libXi, not loaded under wayland ozone
	exec_once("env LD_PRELOAD=/usr/lib64/libXi.so.6 discord", { workspace = "6 silent" })
	exec_once("thunderbird", { workspace = "8 silent" })

	-- Reset gaming/streaming modes
	exec_once("~/code/scripts/stream_mode off")
	exec_once("~/code/scripts/game_mode_auto")

	-- Firefox with auto session restore, windows spread across workspaces 4/10/9
	exec_once("~/code/scripts/firefox_restore")
end)

-- exec-shutdown equivalent
hl.on("hyprland.shutdown", function()
	hl.exec_cmd("openrc --user default")
end)

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "kitty"
-- Under the Lua config `hyprctl dispatch X` evaluates X as Lua, so piping tofi's
-- Exec line into `hyprctl dispatch exec --` is a syntax error. --drun-launch has
-- tofi spawn the app itself, which also keeps the initial-workspace tracking that
-- the hyprctl round-trip used to lose.
local menu = "tofi-drun --drun-launch=true"
local browser = "firefox"

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,

		touchpad = {
			natural_scroll = false,
			disable_while_typing = true,
		},

		sensitivity = -0.8, -- -1.0 to 1.0, 0 means no modification.
	},

	-- https://wiki.hypr.land/0.51.0/Configuring/XWayland/
	xwayland = {
		force_zero_scaling = true,
	},

	general = {
		gaps_in = 12,
		gaps_out = 24,
		border_size = 2,
		col = {
			active_border = { colors = { "rgba(ffffff22)" }, angle = 270 },
			inactive_border = "rgba(00000000)",
		},

		layout = "dwindle",

		-- Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on
		allow_tearing = false,
	},

	decoration = {
		rounding = 10,
		active_opacity = 1.0,
		inactive_opacity = 1.0,

		blur = {
			enabled = true,
			size = 6,
			passes = 3,
			vibrancy = 0.2,
			vibrancy_darkness = 0.2,
			popups = true,
		},

		shadow = {
			enabled = false,
			range = 10,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
	},

	animations = {
		enabled = true,
	},

	dwindle = {
		-- pseudotile was removed in Hyprland 0.56
		preserve_split = true, -- you probably want this
	},

	misc = {
		force_default_wallpaper = 0, -- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		focus_on_activate = true,
		-- mouse_move_enables_dpms = true, -- prevents accidental wake up
		key_press_enables_dpms = true,
	},
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "default", style = "slidefade" })
hl.animation({ leaf = "layers", enabled = true, speed = 2, bezier = "default" })

---------------------
---- LAYER RULES ----
---------------------

-- notifications layer
hl.layer_rule({
	name = "notifications",
	match = { namespace = "notifications" },

	blur = true,
	ignore_alpha = 0,
	no_screen_share = true,
	animation = "slide top",
})

-- launcher menu
hl.layer_rule({
	name = "launcher",
	match = { namespace = "launcher" },

	blur = true,
	ignore_alpha = 0,
	dim_around = true,
	animation = "popin 90%",
})

--------------------------
---- INPUT (PER-DEVICE) --
--------------------------

-- Gaming mouse: flat accel profile (raw 1:1, no acceleration curve) for cs2/dota.
-- Sensitivity kept at the global value as a starting point — with flat it scales
-- linearly, so bump it toward 0 if the cursor feels too slow.
hl.device({
	name = "cx-2.4g-wireless-receiver-mouse",
	accel_profile = "flat",
	sensitivity = -0.8,
})

----------------------
---- WINDOW RULES ----
----------------------

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize", -- You'll probably like this.
})

-- NOTE: Steam (normal and Big Picture) always opens on workspace 7 (DP-2)
hl.window_rule({
	name = "steam-ws7",
	match = { class = "^(steam)$" },

	workspace = "7",
})
hl.window_rule({
	name = "steam-bpm-fullscreen",
	match = { title = "^(Steam Big Picture Mode)$" },

	fullscreen = true,
})
-- Games launched by Steam: Proton/Windows titles always get class
-- steam_app_<appid>. Native Linux games set their own class (dota2, cs2, ...) —
-- if one escapes these rules, add its class alongside steam_app below and keep
-- game_mode_auto's GAME_CLASS in sync.
hl.window_rule({
	name = "games-ws7",
	match = { class = [[^(steam_app_\d+|dota2|cs2)$]] },

	workspace = "7",
})
hl.window_rule({
	name = "games-fullscreen",
	match = { class = [[^(steam_app_\d+|dota2|cs2)$]] },

	fullscreen = true,
})

-- Firefox: 0.56 rounds Firefox's subsurfaces too, so solid UI bars render as
-- segmented rounded strips — exclude it from rounding until that's fixed upstream
hl.window_rule({
	name = "firefox-no-rounding",
	match = { class = "^(firefox)$" },

	rounding = 0,
})

-- NOTE: Pin apps to workspaces: Slack -> 5, Discord -> 6, Thunderbird -> 8
hl.window_rule({ name = "slack-ws5", match = { class = "^([Ss]lack)$" }, workspace = "5" })
hl.window_rule({ name = "discord-ws6", match = { class = "^([Dd]iscord)$" }, workspace = "6" })
hl.window_rule({ name = "thunderbird-ws8", match = { class = "^([Tt]hunderbird(-esr)?)$" }, workspace = "8" })

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Full screen toggle
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

-- Notification
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("makoctl dismiss"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("makoctl dismiss -a"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("makoctl restore"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("~/code/scripts/mako_open"))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("makoctl invoke delete-moz && makoctl dismiss"))

-- Screen off (the sleep lets the key release land before the screens go dark;
-- `hyprctl dispatch` takes Lua now, so the old "dpms off" string no longer parses)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd([[sleep 0.5 && hyprctl dispatch 'hl.dsp.dpms("off")']]))

-- Toggle HDR mode on the Alienware (for YouTube HDR etc.)
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd("~/code/scripts/hdr_mode"))

-- Cycle (cyclenext + bringactivetotop on one key)
hl.bind(mainMod .. " + semicolon", function()
	hl.dispatch(hl.dsp.window.cycle_next())
	hl.dispatch(hl.dsp.window.bring_to_top())
end)
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ last = true }))

-- Screenshot a region
hl.bind("F4", hl.dsp.exec_cmd("hyprshot --clipboard-only -m region"))
hl.bind("SHIFT + F4", hl.dsp.exec_cmd("hyprshot --clipboard-only -m output -m active"))
hl.bind("CTRL + SHIFT + F4", hl.dsp.exec_cmd("hyprshot -m region -o ~/downloads"))

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mainMod .. " + minus", hl.dsp.window.float())
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | tofi | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + P", hl.dsp.window.pin())

-- Move focus with mainMod + hjkl
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Pulseaudio volume control
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"))
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd(
		[[pactl set-sink-mute @DEFAULT_SINK@ toggle && sudo sh -c 'if [ "$(cat /sys/class/leds/platform::mute/brightness)" -eq 0 ]; then echo 100 > /sys/class/leds/platform::mute/brightness; else echo 0 > /sys/class/leds/platform::mute/brightness; fi']]
	)
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd(
		[[pactl set-source-mute @DEFAULT_SOURCE@ toggle && sudo sh -c 'if [ "$(cat /sys/class/leds/platform::micmute/brightness)" -eq 0 ]; then echo 100 > /sys/class/leds/platform::micmute/brightness; else echo 0 > /sys/class/leds/platform::micmute/brightness; fi']]
	)
)

-- Media controls
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"))

-- FIXME: monitor brightness and keyboard backlight controls
