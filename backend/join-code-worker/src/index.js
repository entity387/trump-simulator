const JSON_HEADERS = {
  "content-type": "application/json; charset=utf-8",
  "cache-control": "no-store",
};

function json(data, status = 200) {
  return new Response(JSON.stringify(data), { status, headers: JSON_HEADERS });
}

function normaliseCode(value) {
  return String(value || "").toUpperCase().replace(/[^A-Z0-9]/g, "");
}

function displayCode(compact) {
  return compact.slice(0, 4) + "-" + compact.slice(4, 8);
}

function randomLetters(count) {
  const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ";
  const bytes = new Uint8Array(count);
  crypto.getRandomValues(bytes);
  return Array.from(bytes, b => alphabet[b % alphabet.length]).join("");
}

function randomDigits(count) {
  const bytes = new Uint8Array(count);
  crypto.getRandomValues(bytes);
  return Array.from(bytes, b => String(b % 10)).join("");
}

function randomToken() {
  const bytes = new Uint8Array(24);
  crypto.getRandomValues(bytes);
  return Array.from(bytes, b => b.toString(16).padStart(2, "0")).join("");
}

export class RoomRegistry {
  constructor(ctx, env) {
    this.ctx = ctx;
    this.env = env;
  }

  async fetch(request) {
    const url = new URL(request.url);
    const parts = url.pathname.split("/").filter(Boolean);

    if (request.method === "GET" && url.pathname === "/health") {
      return json({ ok: true, service: "trump-simulator-join-codes" });
    }

    if (request.method === "POST" && url.pathname === "/rooms") {
      return this.createRoom(request);
    }

    if (parts[0] === "rooms" && parts[1]) {
      const compact = normaliseCode(parts[1]);

      if (request.method === "GET" && parts.length === 2) {
        return this.getRoom(compact);
      }

      if (request.method === "DELETE" && parts.length === 2) {
        return this.deleteRoom(request, compact);
      }

      if (request.method === "POST" && parts[2] === "heartbeat") {
        return this.heartbeat(request, compact);
      }
    }

    return json({ error: "Not found" }, 404);
  }

  async createRoom(request) {
    let body;
    try {
      body = await request.json();
    } catch {
      return json({ error: "Invalid JSON" }, 400);
    }

    const hostUserId = String(body.host_user_id || "").trim();
    const mode = String(body.mode || "").trim();
    const maxPlayers = Number(body.max_players || 4);

    if (!hostUserId || !["crisis", "debate"].includes(mode)) {
      return json({ error: "Invalid room data" }, 400);
    }

    let compact = "";
    for (let i = 0; i < 16; i++) {
      compact = randomLetters(4) + randomDigits(4);
      const existing = await this.ctx.storage.get("room:" + compact);
      if (!existing) break;
      compact = "";
    }

    if (!compact) {
      return json({ error: "Could not allocate join code" }, 503);
    }

    const token = randomToken();
    const now = Date.now();
    const room = {
      code: displayCode(compact),
      host_user_id: hostUserId,
      mode,
      max_players: Math.max(2, Math.min(16, maxPlayers)),
      created_at: now,
      expires_at: now + 120_000,
      host_token: token,
    };

    await this.ctx.storage.put("room:" + compact, room);

    return json({
      code: room.code,
      host_token: token,
      expires_in: 120,
    }, 201);
  }

  async getRoom(compact) {
    if (compact.length !== 8) {
      return json({ error: "Invalid join code" }, 400);
    }

    const key = "room:" + compact;
    const room = await this.ctx.storage.get(key);
    if (!room) {
      return json({ error: "Join code not found" }, 404);
    }

    if (Number(room.expires_at || 0) < Date.now()) {
      await this.ctx.storage.delete(key);
      return json({ error: "Join code expired" }, 404);
    }

    return json({
      code: room.code,
      host_user_id: room.host_user_id,
      mode: room.mode,
      max_players: room.max_players,
      created_at: room.created_at,
    });
  }

  async deleteRoom(request, compact) {
    const room = await this.ctx.storage.get("room:" + compact);
    if (!room) return json({ ok: true });

    if (!this.authorised(request, room)) {
      return json({ error: "Not authorised" }, 403);
    }

    await this.ctx.storage.delete("room:" + compact);
    return json({ ok: true });
  }

  async heartbeat(request, compact) {
    const key = "room:" + compact;
    const room = await this.ctx.storage.get(key);
    if (!room) return json({ error: "Join code not found" }, 404);

    if (!this.authorised(request, room)) {
      return json({ error: "Not authorised" }, 403);
    }

    room.expires_at = Date.now() + 120_000;
    await this.ctx.storage.put(key, room);
    return json({ ok: true, expires_in: 120 });
  }

  authorised(request, room) {
    const header = request.headers.get("authorization") || "";
    return header === "Bearer " + room.host_token;
  }
}

export default {
  async fetch(request, env) {
    const id = env.ROOMS.idFromName("global-registry");
    return env.ROOMS.get(id).fetch(request);
  },
};
