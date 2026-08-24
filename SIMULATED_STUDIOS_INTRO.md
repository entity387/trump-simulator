# Simulated Studios native startup intro

This build starts at `intro.tscn` before loading the Trump Simulator game scene.

Sequence:
- black screen with animated grain
- Simulated Studios logo stamp/flash/shake at roughly 1 second
- subtle logo settle/pulse
- "CLICK OR PRESS ANY KEY TO CONTINUE" cue
- 0.5 second fade into `main.tscn`

The intro is isolated from gameplay. Trump Simulator's normal scene is not instantiated until the intro is dismissed, so campaign/menu systems cannot appear behind the ident.

Required branding asset:
- `res://logo.png`

To reuse this in another Godot Simulated Studios game, copy `intro.tscn`, `scripts/studio_intro.gd`, and `logo.png`, then change `NEXT_SCENE` in `studio_intro.gd` to that game's normal main scene and make `intro.tscn` the project's `run/main_scene`.
