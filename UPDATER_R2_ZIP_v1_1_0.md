# R2 ZIP updater patch

- Manifest check: https://simulatedstudios.com/updates/trump-simulator.json
- R2 custom domain: https://download.simulatedstudios.com
- R2 bucket: trump-simulator
- Release package: TrumpSimulator-1.1.0-Windows-Installer.zip
- Updater extracts and SHA-256 verifies TrumpSimulatorSetup.exe from the ZIP.
- Before launching an automatic update, savegame.json and settings.json are copied to pre-update backup files in Godot user://.
- The installer does not delete Godot user:// data, so reinstall/update preserves campaign progress.
- Startup intro files were intentionally not modified.
