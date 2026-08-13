# Build the real Trump Simulator installer with GitHub

This package contains a GitHub Actions workflow that builds the actual Windows installer on a Windows Server runner.

You do NOT need Godot or Inno Setup installed on your own computer for this method.

## What the workflow does

1. Starts a Windows Server 2025 GitHub Actions runner.
2. Downloads Godot 4.7.1.
3. Downloads and installs the Godot 4.7.1 export templates.
4. Opens/imports the project headlessly to catch script errors.
5. Exports `build/TrumpSimulator.exe`.
6. Uses Inno Setup on the Windows runner to compile `TrumpSimulatorSetup.exe`.
7. Generates `update.json` with the installer's SHA-256.
8. Uploads the finished installer as a GitHub Actions artifact.

## How to use it

1. Create a GitHub repository for Trump Simulator.
2. Upload the CONTENTS of this project folder to the repository.
   The `.github/workflows/build-installer.yml` file must exist in the repo.
3. Open the repository on GitHub.
4. Click **Actions**.
5. Select **Build Trump Simulator 1.0 Installer**.
6. Click **Run workflow**.
7. Wait for the build to finish.
8. Open the completed workflow run.
9. Under **Artifacts**, download:
   `TrumpSimulator-1.0-Windows-Installer`

Inside it will be:
- `TrumpSimulatorSetup.exe`
- `update.json`
- `TrumpSimulator_1.0_Windows.zip`

If the workflow fails, open the failed step. GitHub will show the exact Godot/Inno Setup error instead of closing a CMD window.

## Website release

Upload:
- `TrumpSimulatorSetup.exe` to `/downloads/TrumpSimulatorSetup.exe`
- `update.json` to `/update.json`

Upload `update.json` LAST so installed games do not see the new version before the installer is available.
