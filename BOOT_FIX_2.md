# Boot Fix 2

Fixes the parse failure in:

`res://scripts/online/online_multiplayer_ui.gd`

Changes:
- `manager` is now a dynamic `Variant` instead of a generic statically typed `Node`.
- Manager-owned button callbacks use explicit `Callable(manager, "...")`.
- `manager.players.keys()` now has an explicit `Array` type rather than `:=` inference.
- Lobby marker locals are explicitly typed as `String`.

This patch is applied on top of Boot Fix 1.
