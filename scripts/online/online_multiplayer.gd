extends Node

signal status_changed(message: String)
signal error_occurred(message: String)
signal lobby_updated(players: Dictionary, join_code: String, mode: String, host: bool)
signal connection_state_changed(state: String)
signal match_started(mode: String, local_role: String)
signal voice_state_changed(state: String)
signal lan_games_updated(games: Array)

const DEFAULT_GAME_PORT := 27887
const DEFAULT_DISCOVERY_PORT := 27888
const DISCOVERY_MAGIC := "TRUMP_SIMULATOR_LAN_V1"
const DISCOVERY_INTERVAL := 0.8
const DISCOVERY_TIMEOUT_MSEC := 3500

var display_name: String = "Player"
var game_mode: String = ""
var join_code: String = ""
var is_host := false
var connected := false
var players: Dictionary = {}
var local_role := ""
var local_ready := false
var local_test_host := false

var discovered_games: Array[Dictionary] = []
var _discovered_by_key: Dictionary = {}
var _host_discovery_socket: PacketPeerUDP
var _scan_socket: PacketPeerUDP
var _scan_active := false
var _scan_accum := 0.0
var _game_port := DEFAULT_GAME_PORT
var _discovery_port := DEFAULT_DISCOVERY_PORT

func _ready() -> void:
	_game_port = int(ProjectSettings.get_setting("trump_simulator/multiplayer/lan_port", DEFAULT_GAME_PORT))
	_discovery_port = int(ProjectSettings.get_setting("trump_simulator/multiplayer/discovery_port", DEFAULT_DISCOVERY_PORT))

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _process(delta: float) -> void:
	_poll_host_discovery()
	if _scan_active:
		_scan_accum += delta
		if _scan_accum >= DISCOVERY_INTERVAL:
			_scan_accum = 0.0
			_send_discovery_probe()
		_poll_scan_replies()
		_expire_discovered_games()

func host_mode_description() -> String:
	return "LAN ONLY — VISIBLE TO DEVICES ON THIS NETWORK"

func host_game(mode_name: String, player_name: String) -> void:
	if connected or is_host:
		leave_session()

	display_name = _clean_name(player_name)
	game_mode = mode_name
	is_host = true
	local_test_host = false
	stop_lan_scan()
	status_changed.emit("STARTING LAN HOST...")
	connection_state_changed.emit("hosting")

	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_server(_game_port, 8)
	if result != OK:
		is_host = false
		_fail("Could not start a LAN game on port %d." % _game_port)
		return

	multiplayer.multiplayer_peer = peer
	connected = true
	local_role = _default_role_for_mode(mode_name)
	local_ready = false
	join_code = "%s:%d" % [_best_local_address(), _game_port]
	players = {
		1: {
			"name": display_name,
			"role": local_role,
			"ready": false,
			"host": true
		}
	}

	_start_host_discovery()
	status_changed.emit("LAN LOBBY READY — OTHER DEVICES CAN FIND THIS GAME")
	connection_state_changed.emit("lobby")
	_emit_lobby()

func start_lan_scan() -> void:
	if is_host:
		return
	if _scan_socket != null:
		stop_lan_scan()

	_scan_socket = PacketPeerUDP.new()
	var bind_result := _scan_socket.bind(0, "0.0.0.0")
	if bind_result != OK:
		_scan_socket = null
		_fail("Could not start LAN discovery.")
		return

	_scan_socket.set_broadcast_enabled(true)
	_scan_active = true
	_scan_accum = 0.0
	_discovered_by_key.clear()
	discovered_games.clear()
	lan_games_updated.emit(discovered_games.duplicate(true))
	status_changed.emit("SCANNING YOUR LOCAL NETWORK...")
	_send_discovery_probe()

func refresh_lan_scan() -> void:
	if not _scan_active:
		start_lan_scan()
		return
	_discovered_by_key.clear()
	discovered_games.clear()
	lan_games_updated.emit(discovered_games.duplicate(true))
	status_changed.emit("SCANNING YOUR LOCAL NETWORK...")
	_send_discovery_probe()

func stop_lan_scan() -> void:
	_scan_active = false
	_scan_accum = 0.0
	if _scan_socket != null:
		_scan_socket.close()
	_scan_socket = null

func join_lan_game(address: String, port: int, mode_name: String, player_name: String) -> void:
	if connected or is_host:
		leave_session()

	display_name = _clean_name(player_name)
	game_mode = mode_name
	is_host = false
	local_test_host = false
	join_code = "%s:%d" % [address, port]
	stop_lan_scan()
	status_changed.emit("CONNECTING TO %s..." % address)
	connection_state_changed.emit("connecting")

	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_client(address, port)
	if result != OK:
		_fail("Could not start the LAN connection.")
		return

	multiplayer.multiplayer_peer = peer

func leave_session() -> void:
	stop_lan_scan()
	_stop_host_discovery()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()
	connected = false
	is_host = false
	game_mode = ""
	join_code = ""
	local_role = ""
	local_ready = false
	local_test_host = false
	status_changed.emit("LAN MULTIPLAYER OFFLINE")
	connection_state_changed.emit("offline")
	_emit_lobby()

func request_next_role() -> void:
	if not connected:
		return
	var next_role := _next_available_role(local_role)
	if is_host:
		_set_player_role_internal(1, next_role)
	else:
		_request_role.rpc_id(1, next_role)

func toggle_ready() -> void:
	if not connected:
		return
	var new_ready := not local_ready
	if is_host:
		_set_player_ready_internal(1, new_ready)
	else:
		_request_ready.rpc_id(1, new_ready)

func start_match() -> void:
	if not is_host or not connected:
		return
	if not _can_host_start():
		status_changed.emit("WAITING FOR PLAYERS / READY STATES")
		return
	_broadcast_match_start()

func _can_host_start() -> bool:
	var allow_solo := bool(ProjectSettings.get_setting(
		"trump_simulator/multiplayer/allow_solo_test",
		true
	))
	if allow_solo:
		return true

	var minimum := 4 if game_mode == "crisis" else 3
	if players.size() < minimum:
		return false
	for peer_id in players:
		var p: Dictionary = players[peer_id]
		if not bool(p.get("ready", false)):
			return false
		if str(p.get("role", "")).is_empty():
			return false
	return true

func _broadcast_match_start() -> void:
	for peer_id in players:
		var p: Dictionary = players[peer_id]
		if str(p.get("role", "")).is_empty():
			_set_player_role_internal(int(peer_id), _first_available_role())
	_start_match_rpc.rpc(game_mode, players)

@rpc("authority", "call_local", "reliable")
func _start_match_rpc(mode_name: String, snapshot: Dictionary) -> void:
	players = snapshot.duplicate(true)
	var my_id := multiplayer.get_unique_id()
	var mine: Dictionary = players.get(my_id, {})
	local_role = str(mine.get("role", _default_role_for_mode(mode_name)))
	status_changed.emit("MATCH STARTING")
	connection_state_changed.emit("in_match")
	match_started.emit(mode_name, local_role)

@rpc("any_peer", "reliable")
func _register_player(player_name: String) -> void:
	if not is_host:
		return
	var peer_id := multiplayer.get_remote_sender_id()
	if peer_id <= 1:
		return
	players[peer_id] = {
		"name": _clean_name(player_name),
		"role": _first_available_role(),
		"ready": false,
		"host": false
	}
	_broadcast_lobby()

@rpc("any_peer", "reliable")
func _request_role(role_name: String) -> void:
	if not is_host:
		return
	var peer_id := multiplayer.get_remote_sender_id()
	_set_player_role_internal(peer_id, role_name)

@rpc("any_peer", "reliable")
func _request_ready(ready_value: bool) -> void:
	if not is_host:
		return
	var peer_id := multiplayer.get_remote_sender_id()
	_set_player_ready_internal(peer_id, ready_value)

func _set_player_role_internal(peer_id: int, role_name: String) -> void:
	if not players.has(peer_id):
		return
	var resolved := role_name
	if not _role_is_available(resolved, peer_id):
		resolved = _first_available_role(peer_id)
	var p: Dictionary = players[peer_id]
	p["role"] = resolved
	p["ready"] = false
	players[peer_id] = p
	if peer_id == multiplayer.get_unique_id():
		local_role = resolved
		local_ready = false
	_broadcast_lobby()

func _set_player_ready_internal(peer_id: int, ready_value: bool) -> void:
	if not players.has(peer_id):
		return
	var p: Dictionary = players[peer_id]
	if str(p.get("role", "")).is_empty():
		return
	p["ready"] = ready_value
	players[peer_id] = p
	if peer_id == multiplayer.get_unique_id():
		local_ready = ready_value
	_broadcast_lobby()

func _broadcast_lobby() -> void:
	_apply_lobby_snapshot.rpc(players, join_code, game_mode)

@rpc("authority", "call_local", "reliable")
func _apply_lobby_snapshot(snapshot: Dictionary, code_value: String, mode_name: String) -> void:
	players = snapshot.duplicate(true)
	join_code = code_value
	game_mode = mode_name
	var mine: Dictionary = players.get(multiplayer.get_unique_id(), {})
	local_role = str(mine.get("role", ""))
	local_ready = bool(mine.get("ready", false))
	_emit_lobby()

func _send_lobby_to(peer_id: int) -> void:
	_apply_lobby_snapshot.rpc_id(peer_id, players, join_code, game_mode)

func _on_peer_connected(peer_id: int) -> void:
	if is_host:
		call_deferred("_send_lobby_to", peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	if is_host and players.has(peer_id):
		players.erase(peer_id)
		_broadcast_lobby()

func _on_connected_to_server() -> void:
	connected = true
	status_changed.emit("CONNECTED TO LAN HOST")
	connection_state_changed.emit("lobby")
	_register_player.rpc_id(1, display_name)

func _on_connection_failed() -> void:
	connected = false
	_fail("Could not connect to the LAN host.")

func _on_server_disconnected() -> void:
	connected = false
	players.clear()
	status_changed.emit("LAN HOST DISCONNECTED")
	connection_state_changed.emit("host_disconnected")
	_emit_lobby()

func _emit_lobby() -> void:
	lobby_updated.emit(players.duplicate(true), join_code, game_mode, is_host)

func _roles_for_mode() -> Array[String]:
	if game_mode == "crisis":
		return ["INTEL", "LAUNCH", "RADAR", "COMMS"]
	return ["TRUMP", "BIDEN", "MODERATOR", "AUDIENCE"]

func _default_role_for_mode(mode_name: String) -> String:
	return "INTEL" if mode_name == "crisis" else "TRUMP"

func _next_available_role(current: String) -> String:
	var roles := _roles_for_mode()
	if roles.is_empty():
		return ""
	var index := roles.find(current)
	for offset in range(1, roles.size() + 1):
		var candidate := roles[(maxi(index, -1) + offset) % roles.size()]
		if _role_is_available(candidate, multiplayer.get_unique_id()):
			return candidate
	return current

func _first_available_role(ignore_peer: int = -1) -> String:
	for candidate in _roles_for_mode():
		if _role_is_available(candidate, ignore_peer):
			return candidate
	return "AUDIENCE" if game_mode == "debate" else ""

func _role_is_available(role_name: String, ignore_peer: int = -1) -> bool:
	if role_name == "AUDIENCE" and game_mode == "debate":
		return true
	for peer_id in players:
		if int(peer_id) == ignore_peer:
			continue
		var p: Dictionary = players[peer_id]
		if str(p.get("role", "")) == role_name:
			return false
	return role_name in _roles_for_mode()

func _start_host_discovery() -> void:
	_stop_host_discovery()
	_host_discovery_socket = PacketPeerUDP.new()
	var result := _host_discovery_socket.bind(_discovery_port, "0.0.0.0")
	if result != OK:
		_host_discovery_socket = null
		status_changed.emit("LAN LOBBY READY — AUTOMATIC DISCOVERY UNAVAILABLE")

func _stop_host_discovery() -> void:
	if _host_discovery_socket != null:
		_host_discovery_socket.close()
	_host_discovery_socket = null

func _poll_host_discovery() -> void:
	if not is_host or not connected or _host_discovery_socket == null:
		return
	while _host_discovery_socket.get_available_packet_count() > 0:
		var packet := _host_discovery_socket.get_packet()
		var sender_ip := _host_discovery_socket.get_packet_ip()
		var sender_port := _host_discovery_socket.get_packet_port()
		var parsed: Variant = JSON.parse_string(packet.get_string_from_utf8())
		if typeof(parsed) != TYPE_DICTIONARY:
			continue
		var request := parsed as Dictionary
		if str(request.get("magic", "")) != DISCOVERY_MAGIC or str(request.get("type", "")) != "discover":
			continue
		var response := {
			"magic": DISCOVERY_MAGIC,
			"type": "host",
			"name": display_name,
			"mode": game_mode,
			"port": _game_port,
			"players": players.size(),
			"max_players": 4 if game_mode == "crisis" else 8,
			"version": "1.1.0",
		}
		_host_discovery_socket.set_dest_address(sender_ip, sender_port)
		_host_discovery_socket.put_packet(JSON.stringify(response).to_utf8_buffer())

func _send_discovery_probe() -> void:
	if not _scan_active or _scan_socket == null:
		return
	var request := {
		"magic": DISCOVERY_MAGIC,
		"type": "discover",
		"version": "1.1.0",
	}
	_scan_socket.set_broadcast_enabled(true)
	_scan_socket.set_dest_address("255.255.255.255", _discovery_port)
	_scan_socket.put_packet(JSON.stringify(request).to_utf8_buffer())

func _poll_scan_replies() -> void:
	if _scan_socket == null:
		return
	var changed := false
	while _scan_socket.get_available_packet_count() > 0:
		var packet := _scan_socket.get_packet()
		var sender_ip := _scan_socket.get_packet_ip()
		var parsed: Variant = JSON.parse_string(packet.get_string_from_utf8())
		if typeof(parsed) != TYPE_DICTIONARY:
			continue
		var response := parsed as Dictionary
		if str(response.get("magic", "")) != DISCOVERY_MAGIC or str(response.get("type", "")) != "host":
			continue
		var port := int(response.get("port", _game_port))
		var key := "%s:%d" % [sender_ip, port]
		_discovered_by_key[key] = {
			"address": sender_ip,
			"port": port,
			"name": str(response.get("name", "LAN Host")),
			"mode": str(response.get("mode", "crisis")),
			"players": int(response.get("players", 1)),
			"max_players": int(response.get("max_players", 4)),
			"last_seen": Time.get_ticks_msec(),
		}
		changed = true
	if changed:
		_publish_discovered_games()

func _expire_discovered_games() -> void:
	var now := Time.get_ticks_msec()
	var expired: Array[String] = []
	for key in _discovered_by_key:
		var item: Dictionary = _discovered_by_key[key]
		if now - int(item.get("last_seen", now)) > DISCOVERY_TIMEOUT_MSEC:
			expired.append(str(key))
	if expired.is_empty():
		return
	for key in expired:
		_discovered_by_key.erase(key)
	_publish_discovered_games()

func _publish_discovered_games() -> void:
	discovered_games.clear()
	var keys: Array = _discovered_by_key.keys()
	keys.sort()
	for key in keys:
		discovered_games.append((_discovered_by_key[key] as Dictionary).duplicate(true))
	lan_games_updated.emit(discovered_games.duplicate(true))
	if discovered_games.is_empty():
		status_changed.emit("SCANNING YOUR LOCAL NETWORK...")
	else:
		status_changed.emit("%d LAN GAME%s FOUND" % [discovered_games.size(), "" if discovered_games.size() == 1 else "S"])

func _best_local_address() -> String:
	for address in IP.get_local_addresses():
		var value := str(address)
		if ":" in value:
			continue
		if value.begins_with("127.") or value.begins_with("169.254."):
			continue
		return value
	return "LAN"

func _clean_name(value: String) -> String:
	var cleaned := value.strip_edges()
	if cleaned.is_empty():
		return "Player"
	if cleaned.length() > 18:
		cleaned = cleaned.substr(0, 18)
	return cleaned

func _fail(message: String) -> void:
	status_changed.emit(message)
	error_occurred.emit(message)
	connection_state_changed.emit("error")

func set_push_to_talk(_active: bool) -> void:
	pass

func set_remote_muted(_product_user_id: String, _muted: bool) -> void:
	pass
