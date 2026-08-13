# v0.9.1 — Phone-call dialogue isolation

Fixed a bug where random ambient Trump one-liners could fire while a scripted phone call was active.

New rule:
- Random Trump ambient lines are blocked as soon as the phone starts ringing.
- Scripted Trump lines inside the call still play normally.
- After an answered call, ambient chatter stays blocked for 3.5 seconds so the final recorded call clip is not talked over.
- After a missed call, ambient chatter waits 1.5 seconds before resuming.

This is intended for the individually recorded voice clips.
