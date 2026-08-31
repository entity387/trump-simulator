Trump Simulator release output

BUILD_OFFICIAL_INSTALLER.bat creates:
- TrumpSimulatorSetup.exe (standalone Inno Setup installer)
- TrumpSimulator-1.1.0-Windows-Installer.zip (website + auto-updater package)
- update.json (publish at simulatedstudios.com/updates/trump-simulator.json)

R2 bucket: trump-simulator
R2 public domain: download.simulatedstudios.com

The ZIP contains TrumpSimulatorSetup.exe and a copy of update.json.
The update manifest verifies the setup executable inside the ZIP by SHA-256.
