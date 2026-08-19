TRUMP SIMULATOR GITHUB BUILDER — FIX 4

EXACT ERROR FIXED
-----------------
Godot reported:

    ERROR: Invalid export preset name: Windows.

and then detected:

    "Windows Desktop"

The project/export preset is correct.

The problem was PowerShell Start-Process -ArgumentList. It joined the arguments
into a command line and the preset name "Windows Desktop" was split at its space,
so Godot received "Windows" as the preset.

FIX 4
-----
The workflow now uses:

    System.Diagnostics.ProcessStartInfo.ArgumentList

for Godot and Inno Setup. Every argument is added individually, so:

    Windows Desktop

is passed to Godot as one exact argument.

It also makes paths containing spaces safe.

HOW TO USE
----------
1. Open your GitHub repository.
2. Open:
      .github/workflows/build-installer.yml
3. Replace ALL contents with the Fix 4 build-installer.yml.
4. Commit.
5. Go to Actions.
6. Run:
      Build Trump Simulator 1.0 Installer

If the export succeeds, the workflow should continue to Inno Setup and finally
produce the TrumpSimulator-1.0-Windows-Installer artifact.

If another step fails, send the first red step/log again.
