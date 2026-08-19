# Trump Simulator 1.0.3 — Host + Progression Fix

## Host button
The installed builds currently do not bundle EOSG credentials, and the default join-code backend is local development (`127.0.0.1`). That meant the online host path could not finish.

v1.0.3 adds a safe fallback:
- If full EOS online hosting is configured: use EOS and the join-code backend.
- Otherwise: create a local ENet test host on port 27887.
- The local lobby can select roles, ready up, and start a solo test match.
- The UI explicitly labels this as LOCAL TEST so it is not confused with Internet hosting.

This does not pretend that the local fallback provides public Internet join codes. The intended Internet implementation still requires EOSG + Epic credentials + the deployed join-code service.

## Campaign bomb goals
New per-level launch requirements:
1. Oval Office — 10,000
2. Putin's Office — 20,000
3. UNICEF Office — 35,000
4. UN Meeting Room — 55,000
5. Air Force One — 80,000
6. Rally Backstage — 120,000
7. G20 Summit — 175,000
8. Emergency Bunker — 250,000
9. Golf Club Office — 350,000
10. Presidential Nightmare — 500,000

The final upgrade costs 12,000 bombs, so Presidential Nightmare now requires about 41.7× that number.
