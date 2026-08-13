# Official Windows installer setup

The project now includes the finished Inno Setup installer source and automated Windows build scripts.

## Installer behaviour
- Installs to Program Files under `Simulated Studios\Trump Simulator`
- Creates a Desktop shortcut automatically
- Creates a Start Menu shortcut
- Registers an uninstaller
- Uses the game's red launch button as the installer/shortcut icon
- Includes credits and Godot/legal notices
- Offers to launch the game after setup

## Build
Run `installer\BUILD_OFFICIAL_INSTALLER.bat` on the Windows development PC after installing Godot 4.7.1 export templates and Inno Setup 6.

The final file is `release\TrumpSimulatorSetup.exe`.
