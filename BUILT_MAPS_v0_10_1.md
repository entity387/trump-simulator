# v0.10.1 — Built Campaign Maps

Maps 2–10 are no longer full-screen baked screenshots. Each location is constructed at runtime from Godot Control/Panel/ColorRect/Polygon2D/Line2D nodes, with the gameplay objects layered separately.

The real interactive launch button, phone, paperwork, emergency phone, alarm switch, monitor text and upgrades control remain separate nodes and move into map-specific positions.

The Oval Office keeps the existing visual-reboot room plate because that was the approved first-level direction. Later maps deliberately match its clean separated-object approach rather than painting fake controls into a background.

The old `assets/maps/*.png` campaign screenshots have been removed from this build so they cannot accidentally be used as levels.
