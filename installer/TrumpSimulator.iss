; Trump Simulator Official Windows Installer
; Simulated Studios
; Build after exporting build\TrumpSimulator.exe.
; Compile with Inno Setup 6.

#define MyAppName "Trump Simulator"
#define MyAppVersion "1.1.0"
#define MyAppPublisher "Simulated Studios"
#define MyAppExeName "TrumpSimulator.exe"
#define MyAppSetupName "TrumpSimulatorSetup"

[Setup]
AppId={{8F2F3B11-79AB-4A8D-B361-8E4D2A040400}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppName} Installer
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}
VersionInfoVersion={#MyAppVersion}
DefaultDirName={autopf}\Simulated Studios\Trump Simulator
UsePreviousAppDir=yes
DefaultGroupName=Trump Simulator
DisableProgramGroupPage=yes
PrivilegesRequired=admin
OutputDir=..\release
OutputBaseFilename={#MyAppSetupName}
SetupIconFile=TrumpSimulator.ico
UninstallDisplayIcon={app}\TrumpSimulator.ico
UninstallDisplayName={#MyAppName}
CreateUninstallRegKey=yes
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
SetupLogging=yes
CloseApplications=yes
RestartApplications=no
AllowNoIcons=no

[Files]
Source: "..\build\TrumpSimulator.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "TrumpSimulator.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\CREDITS.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\legal\GODOT_LICENSE.txt"; DestDir: "{app}\legal"; Flags: ignoreversion
Source: "..\legal\THIRD_PARTY_NOTICES.txt"; DestDir: "{app}\legal"; Flags: ignoreversion

[Icons]
; Start Menu
Name: "{group}\Trump Simulator"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; IconFilename: "{app}\TrumpSimulator.ico"
Name: "{group}\Uninstall Trump Simulator"; Filename: "{uninstallexe}"

; Desktop shortcut is installed automatically.
Name: "{autodesktop}\Trump Simulator"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; IconFilename: "{app}\TrumpSimulator.ico"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch Trump Simulator"; Flags: nowait postinstall skipifsilent

; User saves are stored by Godot under user:// (Windows AppData).
; Never add an AppData/user-data deletion rule here; updates/reinstalls must preserve progress.

[UninstallDelete]
Type: filesandordirs; Name: "{app}\legal"
