# Trump Simulator 1.0 — Automatic Update System

## Player experience

When Trump Simulator reaches the home menu it quietly requests:

`https://simulatedstudios.com/updates/trump-simulator.json`

If the website is unreachable, times out, returns invalid JSON, or does not
advertise a newer version, nothing appears and the game continues normally.

If a newer version exists, the player sees an **UPDATE AVAILABLE** popup with
the new version and release notes.

Choosing **UPDATE NOW**:

1. Downloads the official `TrumpSimulatorSetup.exe` into the Windows temporary directory.
2. Computes the downloaded file's SHA-256 hash.
3. Refuses to run it if the hash does not exactly match `update.json`.
4. Starts the Inno Setup installer with silent update parameters.
5. Closes Trump Simulator so Setup can replace the installed files.
6. Existing saves remain separate from the Program Files installation.

## Publishing an update

For a future version such as 1.0.1:

1. Update the version in the game, project settings, and Inno Setup script.
2. Edit `installer/UPDATE_NOTES.txt`.
3. Run `installer/BUILD_OFFICIAL_INSTALLER.bat`.
4. Upload `release/TrumpSimulatorSetup.exe` first.
5. Upload `release/update.json` last.

The build script calculates the installer SHA-256 and writes it into the
manifest automatically.

## Security

- Update manifest and installer URLs must use HTTPS.
- The downloaded installer is SHA-256 verified before execution.
- The updater does not accept a missing or malformed hash.
- The fixed Inno Setup AppId is retained so future installers upgrade the same installation.

For a larger public release, Windows Authenticode code-signing is also strongly
recommended to improve publisher identity/SmartScreen reputation.
