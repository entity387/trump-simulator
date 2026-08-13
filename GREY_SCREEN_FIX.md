# v0.6.1 Grey-Screen Diagnostic Build

This build changes startup order so the menu is created BEFORE the 3D office.

On startup you should see a dark menu and one of these messages:

1/8 LIGHTING + CAMERA
2/8 OFFICE GEOMETRY + MATERIALS
3/8 DESK + PROPS
4/8 LAUNCH BUTTON
5/8 PHONES + PAPERWORK
6/8 IN-WORLD COMMAND SCREENS
7/8 GAMEPLAY LINKS
8/8 READY

If loading stops on one of those messages, that tells us the exact subsystem that failed.

## Re-export
Open this v0.6.1 project in Godot 4.7.1 and export Windows Desktop again.

IMPORTANT: overwrite the OLD executable. Do not keep running the v0.6 executable.

The export preset also enables the console wrapper for debugging. If Godot produces
a console-wrapper executable alongside the main executable, running it can reveal
engine/script errors directly.

## Expected successful result
The title menu should appear immediately.
The status should end at:

3D OFFICE READY — SELECT NEW GAME

Then NEW GAME should enter the office.
