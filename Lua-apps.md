Since CSP 0.1.76, it’s possible to create apps using Lua.

# Hello World app

To create an app, make a new folder “MyFirstApp” (or anything else) in “assettocorsa/apps/lua” and add “manifest.ini” in there:

```ini
[ABOUT]
NAME = Hello World App
AUTHOR = …
VERSION = 1.0
DESCRIPTION = My first Lua app for Assetto Corsa

[WINDOW_...]
ID = main
NAME = Hello World
ICON = icon.png
FUNCTION_MAIN = windowMain
SIZE = 400, 200
```

After that, create “MyFirstApp.lua” in the same folder and add:

```lua
function script.windowMain(dt)
  ui.text('Hello world!')
end
```

# More about manifest format

Manifest can define multiple windows, each of windows gets its own icon on AC apps taskbar. By default first “WINDOW_…” section acts as main window, although you can explicitly set main window with a window flag (more on that later).

When window is visible, function mentioned in “FUNCTION_MAIN” will be called each frame to draw its contents. Note: for UI CSP uses [Dear ImGui](https://github.com/ocornut/imgui) library which has a different approach to building UI. Instead of creating buttons and text fields and such, arranging them in a certain way and keeping track of their state, it works in immediate mode. Write `ui.button('Label')` and it would create 
a button in the current cursor position and move that cursor. If button is clicked, function would return `true`. You can read more about its
paradigm [here](https://github.com/ocornut/imgui/wiki#about-the-imgui-paradigm).

Full window section format:

```ini
[WINDOW_...]
ID = WINDOW_ID          ; defaults to section name
NAME = Window Name      ; shown it title bar of a window and in taskbar
SIZE = width, height    ; default window size in pixels (can be scaled based on global UI scaling parameter)
MIN_SIZE = 40, 20       ; minimum window size
MAX_SIZE = ∞, ∞         ; maximum window size
PADDING = X, Y          ; if set, overwrites default window padding
FLAGS = …               ; window flags separated by comma:
                        ;   NO_BACKGROUND: makes background transparent
                        ;   NO_TITLE_BAR: hides title bar
                        ;   NO_COLLAPSE: hides collapse button
                        ;   NO_SCROLLBAR: hides scrollbar 
                        ;   NO_SCROLL_WITH_MOUSE: stops mouse wheel from scrolling
                        ;   FIXED_SIZE: prevents window from being resized
                        ;   SETTINGS: adds settings button next to collapse and close buttons in title bar, opening settings window
                        ;   AUTO_RESIZE: automatically resizes window to fit its content
                        ;   FADING: makes window fade when inactive, similar to chat app
                        ;   MAIN: makes window act like main window (if not set, first window gets that role)
FUNCTION_MAIN = fn      ; function to be called each frame to draw window content
FUNCTION_SETTINGS = fn  ; function to be called to draw content of corresponding settings window (only with “SETTINGS” flag)
FUNCTION_ON_SHOW = fn   ; function to be called once when window opens
FUNCTION_ON_HIDE = fn   ; function to be called once when window closes
ICON = icon.png         ; name of window icon (icon is searched in app folder)
FUNCTION_ICON = fn      ; optional function to be called instead to draw a window icon, for dynamic icons
```

# Additional app functions

### script.update(dt)

Called each frame after world matrix traversal ends for each app, even if none of its windows are active. Please make sure to not do anything too computationally expensive there (unless app needs it for some reason).

### Sim callbacks

Optional callbacks triggered at different points of AC loop, in case app would need to get actual data or do some work at a very specific point. Can be set in manifest like so:

```ini
[SIM_CALLBACKS]
UPDATE = fn        ; if set, function `script.fn()` will be called right after simulation entities stopped updating
FRAME_BEGIN = fn   ; if set, will be called right before scene has started rendering
```

### Render callbacks

Optional render callbacks are triggered in certain points of main scene rendering process. Could be used to draw some extra shapes in world space: for example, if you are working on an app for positioning additional audio events in the world, those callbacks can be used to render some outlines for those audio events, as well as a moving helper.

```ini
[RENDER_CALLBACKS]
OPAQUE = fn       ; called when opaque geometry (objects without transparent flag) has finished rendering
TRANSPARENT = fn  ; called when transparent objects are finished rendering
```

At least at the moment it’s not meant to draw additional geometry, debug only shapes. To load and render additional models, use `ac.SceneReference` functions to find parent node, load extra KN5 in there and manipulate it.

### UI callback

Optional UI callback is meant for creating fullscreen UIs coming together in a predesigned layout to achieve a certain visual style (for example, to recreate HUD of another racing game). Such HUDs can replace certain original elements: virtual mirrors, damage display and low fuel indicator (more coming a bit later). To stop original elements from working, use `ac.redirect…` functions. Function `ui.drawVirtualMirror()` can be used to draw virtual mirror.

```ini
[UI_CALLBACKS]
IN_GAME = fn  ; called before rendering ImGui apps to draw things on screen
```

Note: unlike window rendering functions, this one does not run from a window, so to draw things, you first would need to create a window using function like `ui.transparentWindow()` or `ui.toolWindow()`.

### Example app

For an example, [here is a Lua HelloWorld app](https://files.acstuff.ru/shared/0Zlg/lua-example-HelloWorld.zip) (it includes some extra media to test video-rendering functions).

Features:
- Example of a simple fullscreen UI;
- Example of a custom camera motion;
- Example of Real Mirrors editor;
- Example of OS integration: running new processes, use of file dialogs;
- Console integration: adds new command `eval`, prints out things to console.