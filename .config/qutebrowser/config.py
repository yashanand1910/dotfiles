config.load_autoconfig()

c.auto_save.session = True
c.session.lazy_restore = True

c.url.searchengines = {'DEFAULT': 'https://google.com/search?hl=en&q={}'}
c.url.default_page = 'https://google.com'
c.url.start_pages = ['https://google.com']
c.downloads.location.directory = '~/downloads'

c.statusbar.show = 'in-mode'
c.scrolling.bar = 'when-searching'
c.window.hide_decoration = True
c.tabs.show = 'multiple'
c.editor.command = ['kitty', '-e', 'nvim', '{}']

# c.content.user_stylesheets = ["~/.config/qutebrowser/solarized-dark.css"]
c.colors.webpage.preferred_color_scheme = 'dark'
c.colors.webpage.darkmode.enabled = False

c.input.insert_mode.auto_enter = True
c.input.insert_mode.auto_load = False

c.zoom.default = 100
c.fonts.default_family = 'JetBrains Mono'
c.qt.highdpi = True
# c.qt.force_software_rendering = 'chromium'
# c.backend = 'webkit'
# c.fonts.default_size = '12pt'
# c.fonts.hints = '12pt'
c.colors.tabs.even.bg = 'rgb(0, 0, 0)'
c.colors.tabs.odd.bg = 'rgb(0, 0, 0)'
c.colors.tabs.even.fg = 'rgb(100, 100, 100)'
c.colors.tabs.odd.fg = 'rgb(100, 100, 100)'
c.colors.tabs.pinned.odd.bg = 'rgb(0, 0, 0)'
c.colors.tabs.pinned.even.bg = 'rgb(0, 0, 0)'
c.colors.tabs.pinned.odd.fg = 'rgb(100, 100, 100)'
c.colors.tabs.pinned.even.fg = 'rgb(100, 100, 100)'
c.colors.tabs.pinned.selected.odd.fg = 'rgb(255, 255, 255)'
c.colors.tabs.pinned.selected.even.fg = 'rgb(255, 255, 255)'
c.colors.tabs.pinned.selected.odd.bg = 'rgb(0, 0, 0)'
c.colors.tabs.pinned.selected.even.bg = 'rgb(0, 0, 0)'
c.colors.tabs.selected.odd.fg = 'rgb(255, 255, 255)'
c.colors.tabs.selected.even.fg = 'rgb(255, 255, 255)'
c.colors.tabs.selected.odd.bg = 'rgb(0, 0, 0)'
c.colors.tabs.selected.even.bg = 'rgb(0, 0, 0)'

c.content.javascript.clipboard = 'access'
c.content.blocking.enabled = True
c.content.desktop_capture = True

# Unbindings

# config.unbind('<Ctrl-D>', mode='normal')
# config.unbind('<Ctrl-U>', mode='normal')

# Keybinds

c.bindings.default['normal']['H'] = 'tab-prev'
c.bindings.default['normal']['L'] = 'tab-next'
c.bindings.default['normal']['<Ctrl-o>'] = 'back'
c.bindings.default['normal']['<Ctrl-i>'] = 'forward'
c.bindings.default['normal']['<Ctrl-e>'] = 'scroll down'
c.bindings.default['normal']['<Ctrl-y>'] = 'scroll up'
c.bindings.default['normal']['1'] = 'tab-focus 1'
c.bindings.default['normal']['2'] = 'tab-focus 2'
c.bindings.default['normal']['3'] = 'tab-focus 3'
c.bindings.default['normal']['4'] = 'tab-focus 4'
c.bindings.default['normal']['5'] = 'tab-focus 5'
c.bindings.default['normal']['6'] = 'tab-focus 6'
c.bindings.default['normal']['7'] = 'tab-focus 7'
c.bindings.default['normal']['8'] = 'tab-focus 8'
c.bindings.default['normal']['9'] = 'tab-focus 9'

c.bindings.default['command']['<Ctrl-N>'] = 'completion-item-focus next'
c.bindings.default['command']['<Ctrl-P>'] = 'completion-item-focus prev'

c.bindings.default['command']['<Ctrl-C>'] = 'mode-leave'
c.bindings.default['caret']['<Ctrl-C>'] = 'mode-leave'
c.bindings.default['insert']['<Ctrl-C>'] = 'mode-leave'
c.bindings.default['hint']['<Ctrl-C>'] = 'mode-leave'

c.bindings.key_mappings['<Ctrl-M>'] = '<Return>'

# with config.pattern('docs.google.com') as p:
#     p.input.mode_override = 'passthrough'

# with config.pattern('notion.so') as p:
#     p.input.mode_override = 'passthrough'

# with config.pattern('excalidraw.com') as p:
#     p.input.mode_override = 'passthrough'

# c.content.headers.user_agent = 'Mozilla/5.0 ({os_info}) AppleWebKit/{webkit_version} (KHTML, like Gecko) {upstream_browser_key}/118.1.5615.213 Safari/{webkit_version} slack.com'
