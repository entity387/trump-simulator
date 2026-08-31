# Expanded Developer Tools — v1.1.0

The secret developer access sequence and PIN are unchanged.

Once successfully unlocked, developer tools remain unlocked for the current app session. Closing the panel minimizes it to a small `DEV TOOLS • F12` launcher instead of locking it again. F12 also toggles the full panel. The unlock state resets only when the application exits.

## Tabs

### Status
- Live runtime report: FPS/frame time, world state, level/stage/difficulty, bombs/power, meters, active events, save protection and LAN state.
- Optional compact debug overlay that remains visible after the panel is minimized.
- God mode (blocks game-over conditions).
- Random-event director toggle.
- Simulation freeze toggle.
- Runtime meter normalization and near-fail test state.
- In-memory runtime snapshot capture/restore.
- 0.5x / 1x / 2x time scale.

### Maps
- Instant loader for all campaign maps.
- Reload current map.
- Full map-preview sheet.
- Manual menu-background advance.

### Game State
- Direct stage override for all six stages.
- Add or clear bomb currency.
- Jump current level to 90% / 99% progress or reset it.
- Trigger current-level completion.
- Unlock/clear every upgrade.
- Live difficulty override for all difficulties.

### Events
- Force random or specific callers (Kim, Putin, Xi, Lil Timmy).
- Answer/end active calls.
- Force paperwork, crisis, alarm, current map gimmick and button overheat.
- Clear all active events.
- Trigger/recover the game-over UI for testing.

### Save / Debug
- Normal save/settings presence and exact user-data path.
- Create developer backup copies of save + settings.
- Restore developer backup copies.
- Validate save JSON.
- Reload the normal save into a protected developer session.
- Copy a complete debug report to clipboard.
- Write a debug report to `user://trump_simulator_debug_report.txt`.
- Print the scene tree to Godot output.
- Open the user-data folder.
- Force UI/stage visibility refresh.

### Multiplayer
- Live LAN connection/host/mode/role/player/discovery diagnostics.
- Refresh LAN discovery.
- Leave current LAN session.
- Open the normal LAN browser.
- Quick local-practice launch for Crisis Room and Presidential Debate.

## Save safety

Any developer action that changes campaign runtime state sets `dev_session_active`, which blocks the normal `_save_game()` path. Gameplay modifiers that remain enabled when starting or continuing a campaign also automatically enable save protection.

Explicit backup/restore buttons are the only developer tools that intentionally write to the normal save/settings files.
