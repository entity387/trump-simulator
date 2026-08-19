TRUMP SIMULATOR GITHUB BUILDER — FIX 3

This version is for diagnosing a REAL Godot export failure.

The current error:
  Godot Windows export failed with exit code 1.

is only the final wrapper error. The actual Godot reason appears earlier in
the export output.

FIX 3 now:
- verifies windows_release_x86_64.exe exists before exporting
- exports with Godot --verbose
- captures both stdout and stderr
- automatically prints the last 200 lines when export fails
- uploads the complete godot-export.log as:
    TrumpSimulator-Build-Diagnostics
  even if the workflow fails

INSTALL:
1. Replace all contents of:
     .github/workflows/build-installer.yml
   with the new build-installer.yml.
2. Commit.
3. Run the Action again.
4. If it fails:
   - copy the block headed:
       GODOT EXPORT FAILED - IMPORTANT LOG OUTPUT
     OR
   - download TrumpSimulator-Build-Diagnostics and send godot-export.log.

That next log should contain the exact Godot error we need to fix.
