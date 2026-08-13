# Trump Simulator v0.12.0 — Online Multiplayer Setup

This build adds the online multiplayer **foundation** for the Crisis Room and Presidential Debate.

## What is implemented

- `HOST GAME` / `JOIN GAME` flow in the main Multiplayer menu.
- Human-readable join codes such as `ABCD-1234`.
- Host-authoritative lobby state.
- Player list, roles, ready state, and host-only start.
- Crisis Room roles: Intel, Launch, Radar, Comms — every role is still Trump.
- Debate roles: Trump, Biden, Moderator, Audience.
- EOS P2P transport adapter built around `EOSGMultiplayerPeer`.
- Automatic host-disconnect handling.
- Cloudflare Durable Object join-code service source.
- Join-code heartbeat/expiry so abandoned rooms disappear.
- Solo-start development switch so maps can still be tested without four PCs.
- Stable API hooks for EOS RTC voice / push-to-talk.

## What still requires external setup

The source package deliberately does **not** include your Epic product credentials or the third-party EOSG binary plugin.

### 1. Install EOSG

In Godot's Asset Library, install **Epic Online Services Godot (EOSG)** and enable it under Project Settings -> Plugins.

The integration is written for the EOSG P2P peer API (`EOSGMultiplayerPeer`).

### 2. Create the EOS credential file

Copy:

`config/eos_credentials.example.json`

to:

`config/eos_credentials.json`

Then fill in your Product ID, Sandbox ID, Deployment ID, Client ID and Client Secret from the Epic Developer Portal.

### 3. Deploy the join-code service

Open:

`backend/join-code-worker`

and run:

`DEPLOY_JOIN_CODE_SERVICE.bat`

After Cloudflare deploys it, copy the Worker URL into `project.godot`:

`trump_simulator/multiplayer/join_code_api="https://YOUR-WORKER.workers.dev"`

### 4. Turn off solo test before release

Change:

`multiplayer/allow_solo_test=true`

to:

`multiplayer/allow_solo_test=false`

This makes Crisis Room require the real player/ready flow instead of allowing the host to test alone.

## Voice chat

The lobby/network manager already exposes push-to-talk and mute hooks. The actual EOS RTC audio room is the next wiring step because it requires the live EOS product configuration and microphone testing on real Windows clients.

The intended final behaviour remains:

- Crisis Room: one team voice channel for all four Trumps.
- Debate: Trump/Biden/Moderator stage voice plus audience voice rules.
- Push-to-talk default.
- Per-player mute/volume controls.
