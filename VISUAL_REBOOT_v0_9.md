# Trump Simulator Desktop v0.9.0 — Visual Reboot

This build deliberately stops trying to make the gameplay view from runtime Godot primitive geometry.

## New presentation
The game now uses a fixed seated-behind-the-desk composition:
- desk surface fills the foreground
- player looks across an Oval Office-inspired room
- fireplace, side windows, curtains, flags, sofas, lamps and rug establish the room
- main launch monitor is built into the composition

## Interactive hero objects
These are separate clickable controls rather than baked into the background:
- red launch button
- desk phone
- urgent paperwork
- emergency phone
- alarm switch

This means the visuals can stay clean while the interactions remain reliable.

## Gameplay
The existing progression, saves, difficulty modes, calls, paperwork, crisis events, alarms, upgrades and game-over systems remain in the Godot project.

## Why this direction
The Web Edition looked cleaner because it had a fixed composition. v0.9.0 brings that same strength to Desktop while keeping the Desktop gameplay systems.
