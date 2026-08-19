# Trump Simulator 1.1.0 — Boot Fix 1

`main.gd` referenced two new call-dialogue state variables that were not declared:

- `active_call_line`
- `call_line_index`

Godot therefore rejected `res://scripts/main.gd` during parsing and the game could not start.

This build adds those declarations next to the existing phone-call runtime state. No campaign balance, level progression, visuals, saves, or multiplayer behavior were rolled back.
