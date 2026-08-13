# Trump Simulator v0.10.1 — Campaign Maps

Normal campaign progression is **linear**. Players do not choose a map from a level-select screen. Trump is the player character at every location, and each transition explicitly says that Trump is travelling/arriving there.

1. **Oval Office** — 2,500 level launches. Introduces threats, calls and paperwork.
2. **Putin's Office** — 3,200. More calls and security-briefing interruptions.
3. **UNICEF Office** — 3,600. Staff requests and paperwork become more aggressive.
4. **UN Meeting Room** — 4,200. High communication pressure and delegate chaos.
5. **Air Force One** — 4,800. Turbulence periodically shakes the desk.
6. **Campaign Rally Backstage** — 5,500. Crowd/staff surges increase chaos.
7. **G20 World Leaders Summit** — 6,500. Frequent leader requests and calls.
8. **Emergency Bunker** — 7,500. Heavy threat pressure and security-system surges.
9. **Golf Club Office** — 8,200. Calls and distractions remain relentless.
10. **Presidential Nightmare** — 10,000. Stage 6 from the start; all major systems can overlap.

## Save flow
- Autosave approximately every 15 seconds during active gameplay.
- Save also occurs on stage changes and level completion.
- Save stores current map, local map progress, difficulty, launch currency/power, approval and purchased upgrades.
- Level completion immediately saves the **next** location before showing the transition screen. If the player quits there, Continue starts at the next map.
- Game-over Retry restores the most recent checkpoint/save rather than restarting the entire campaign.

## Secret developer map loader
Available only from the unobstructed home menu:

`Up Up Down Down Left Right Left Right B A Enter`

Then enter `1787`. The developer panel contains instant-load buttons for all 10 maps. Dev sessions do not overwrite the normal campaign save.

## Art note
The map backgrounds in `assets/maps/` are the actual playable map art packaged in this build. `MAP_PREVIEWS/index.html` provides an external click-through gallery for inspection without playing.


## v0.10.1 implementation note
Maps 2–10 are now constructed from runtime Godot nodes rather than full-screen baked map screenshots. Gameplay objects remain separate interactive nodes.
