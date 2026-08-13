# v0.6.2 Godot 4.7 parse-error fix

This build fixes the strict-typing errors reported by Godot 4.7.1.

Fixed categories:
- Difficulty dictionary locals now explicitly typed as Dictionary
- Upgrade dictionary locals explicitly typed as Dictionary
- Curtain/side-table/flag/desk loop-derived floats explicitly typed
- Cooldown uses maxf() and an explicit float
- Upgrade UI booleans/buttons explicitly typed
- Save dictionaries/files explicitly typed
- Caller candidate return explicitly converted to String

The previous grey screen was not a rendering/GPU problem: main.gd failed to parse before gameplay startup.
