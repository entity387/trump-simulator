TRUMP SIMULATOR GITHUB BUILDER — FIX 2

THIS FIX ADDRESSES:
  ERROR: Please provide a valid project path when exporting, aborting.

WHY IT HAPPENED:
The old workflow assumed project.godot was at the repository root.
If the project folder was uploaded inside another folder, GitHub's workspace
was not itself a valid Godot project directory.

WHAT FIX 2 DOES:
- searches the entire repository for project.godot
- requires exactly one Godot project
- saves the actual project folder as PROJECT_DIR
- verifies export_presets.cfg and installer files exist there
- imports from the actual project folder
- exports to an absolute build path inside the project
- compiles Inno Setup from the actual project folder
- copies final output to _finished_installer at repository root
- uploads the artifact from that fixed location

HOW TO INSTALL:
1. Open your GitHub repository.
2. Open:
     .github/workflows/build-installer.yml
3. Replace ALL of it with the build-installer.yml from this ZIP.
4. Commit changes.
5. Go to Actions.
6. Run:
     Build Trump Simulator 1.0 Installer

If the next run fails, send the complete output from the first red step.
The workflow now prints the exact detected project path before it builds.
