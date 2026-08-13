TRUMP SIMULATOR 1.0 — OFFICIAL WINDOWS INSTALLER
Simulated Studios

START HERE
----------
Double-click:

    BUILD_OFFICIAL_INSTALLER.bat

The improved builder now:
- looks for Godot in PATH
- checks common Godot install locations
- checks Desktop and Downloads for portable Godot executables
- lets you drag/paste the Godot .exe path if it still cannot find it
- checks for Inno Setup separately
- saves all detailed errors to release\BUILD_LOG.txt

SUCCESS OUTPUT
--------------
release\TrumpSimulatorSetup.exe
release\update.json
release\BUILD_LOG.txt

IF IT FAILS
-----------
Open release\BUILD_LOG.txt and send the last 20-30 lines to ChatGPT.

If you want a quick environment check first, run:

    DIAGNOSE_BUILD.bat
