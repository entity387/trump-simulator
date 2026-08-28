# Join-code backend

The `join-code-worker` folder is a tiny Cloudflare Worker + Durable Object service.

It stores only short-lived routing data:
- join code
- host EOS Product User ID
- game mode
- maximum players
- expiry time

It does **not** host the actual match or voice traffic. The host PC remains authoritative and EOS P2P carries gameplay traffic.
