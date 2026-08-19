# Trump Simulator 1.0.2 — Multiplayer Interaction Fix

## Crisis Room
- Cameras moved back roughly 0.8–0.9 m from the character head positions.
- Camera height increased to 1.74 m.
- FOV increased to 82°.
- Cameras now aim toward the local station display/controls rather than the far side of the room.

## Presidential Debate
- Candidate INTERRUPT buttons have real interaction hitboxes.
- Moderator MUTE T / NEXT / MUTE B controls have real interaction hitboxes.
- Control labels face the camera using billboard labels.
- Podium names and other fixed text no longer use the reversed 180° rotation.
- Multiplayer screens now place the display and text on the player's side.

## Interaction
Multiplayer previews use a captured-mouse first-person control scheme:
- Move mouse: look
- Centre `+`: interaction crosshair
- Left click: use the control under the crosshair
- Esc: return

The control press is animated and a status message appears on screen.

## Note
The controls are now mechanically clickable in the local preview/map layer. Network replication and game-rule consequences remain part of the host-authoritative online gameplay layer.
