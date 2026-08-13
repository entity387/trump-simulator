# Trump Simulator Desktop v0.8.0 — Graphics Lock Candidate

This build is the first version intended to move beyond the procedural whitebox look.

## Imported hero assets
- Resolute-style desk model
- compact launch-button base and domed cap
- detailed desk phone
- pleated curtain set
- layered fireplace
- smoother monitor shell
- desk lamp

All hero models are included as `.glb` assets in:
`assets/models/graphics_lock/`

## Material pass
The main procedural textures have been regenerated at 1024×1024:
- walnut
- green leather
- red fabric
- warm plaster
- cream marble
- paper
- presidential-style rug

## Interaction fix
The red button no longer depends on automatic CollisionObject3D click signals.
A left mouse click now casts a ray directly from the active 3D camera and dispatches the clicked desk object.

The full-screen HUD is also set to `MOUSE_FILTER_IGNORE` so it cannot sit invisibly over the office and steal button clicks.

## Art status
Treat this as the GRAPHICS LOCK CANDIDATE.
The intention is to get the main desktop look approved now, then avoid repeatedly rebuilding the room later.
