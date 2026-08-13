extends Node

signal status_changed(message: String)
signal error_occurred(message: String)
signal lobby_updated(players: Dictionary, join_code: String, mode: String, host: bool)
signal connection_state_changed(state: String)
signal match_started(mode: String, local_role: String)
signal voice_state_changed(state: String)

const SOCKET_ID := "trump-simulator-v1"
const EOS_CONFIG_PATH := "res://config/eos_credentials.json"
const EOS_BRIDGE_SOURCE := "res://scripts/eos/eos_bridge.gd.txt"

var backend_url: String = ""
var display_name: String = "Player"
var game_mode: String = ""
var join_code: String = ""
var host_token: String = ""
var host_product_user_id: String = ""
var is_host := false
var connected := false
var eos_ready := false
var voice_ready := false
var players: Dictionary = {}
var local_role := ""
var local_ready := false

var _bridge: Node
var _http: HTTPRequest
var _heartbeat_timer: Timer

func _ready() -> void:
	backend_url = str(ProjectSettings.get_setting(
		"trump_simulator/multiplayer/join_code_api",
		"http://127.0.0.1:8787"
	)).trim_suffix("/")

	_http = HTTPRequest.new()
	_http.name = "JoinCodeHTTP"
	add_child(_http)

	_heartbeat_timer = Timer.new()
	_heartbeat_timer.wait_time = 45.0
	_heartbeat_timer.one_shot = false
	_heartbeat_timer.timeout.connect(_heartbeat_room)
	add_child(_heartbeat_timer)

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func eos_plugin_available() -> bool:
	return ClassDB.class_exists("EOSGMultiplayerPeer") or ResourceLoader.exists(
		"res://addons/epic-online-services-godot/plugin.cfg"
	)

func _load_eos_credentials() -> Dictionary:
	if not FileAccess.file_exists(EOS_CONFIG_PATH):
		return {}
	var raw := FileAccess.get_file_as_string(EOS_CONFIG_PATH)
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary

func _create_dynamic_eos_bridge() -> bool:
	if _bridge != null and is_instance_valid(_bridge):
		return true
	if not eos_plugin_available():
		_fail("EOSG is not installed. Install Epic Online Services Godot (EOSG) before using online multiplayer.")
		return false
	if not FileAccess.file_exists(EOS_BRIDGE_SOURCE):
		_fail("EOS bridge source is missing.")
		return false

	var source := FileAccess.get_file_as_string(EOS_BRIDGE_SOURCE)
	var bridge_script := GDScript.new()
	bridge_script.source_code = source
	var reload_result := bridge_script.reload()
	if reload_result != OK:
		_fail("EOS bridge could not compile. Check that EOSG is installed and enabled.")
		return false

	_bridge = Node.new()
	_bridge.name = "EOSBridge"
	_bridge.set_script(bridge_script)
	add_child(_bridge)
	return true

func ensure_eos_ready() -> bool:
	if eos_ready:
		return true
	if not _create_dynamic_eos_bridge():
		return false

	var credentials := _load_eos_credentials()
	var required := [
		"product_name", "product_version", "product_id", "sandbox_id",
		"deployment_id", "client_id", "client_secret"
	]
	for key in required:
		if str(credentials.get(key, "")).strip_edges().is_empty():
			_fail("EOS credentials are not configured. Copy eos_credentials.example.json to eos_credentials.json and fill in your Epic Developer Portal values.")
			return false

	status_changed.emit("CONNECTING TO EPIC ONLINE SERVICES...")
	connection_state_changed.emit("eos_connecting")
	var ok: bool = await _bridge.initialize_and_login_async(credentials)
	if not ok:
		_fail("Epic Online Services login failed. Check EOS credentials and EOSG setup.")
		return false

	eos_ready = true
	status_changed.emit("EPIC ONLINE SERVICES READY")
	connection_state_changed.emit("eos_ready")
	return true

func host_game(mode_name: String, player_name: String) -> void:
	if connected or is_host:
		await leave_session()

	display_name = _clean_name(player_name)
	game_mode = mode_name
	is_host = true
	status_changed.emit("STARTING HOST...")
	connection_state_changed.emit("hosting")

	if not await ensure_eos_ready():
		is_host = false
		return

	var result: int = _bridge.create_server_peer(SOCKET_ID)
	if result != OK:
		is_host = false
		_fail("Could not create EOS P2P host.")
		return

	multiplayer.multiplayer_peer = _bridge.get_peer()
	connected = true
	host_product_user_id = _bridge.get_local_product_user_id()
	local_role = _default_role_for_mode(mode_name)
	local_ready = false
	players = {
		1: {
			"name": display_name,
			"role": local_role,
			"ready": false,
			"host": true
		}
	}

	status_changed.emit("REGISTERING JOIN CODE...")
	var room: Dictionary = await _create_room()
	if room.is_empty():
		await leave_session()
		return

	join_code = str(room.get("code", ""))
	host_token = str(room.get("host_token", ""))
	_heartbeat_timer.start()
	status_changed.emit("LOBBY READY — SHARE CODE %s" % join_code)
	connection_state_changed.emit("lobby")
	_emit_lobby()

func join_game(code: String, player_name: String) -> void:
	if connected or is_host:
		await leave_session()

	display_name = _clean_name(player_name)
	join_code = _normalise_code(code)
	if join_code.is_empty():
		_fail("Enter a join code.")
		return

	status_changed.emit("LOOKING UP %s..." % join_code)
	connection_state_changed.emit("joining")

	var room: Dictionary = await _resolve_room(join_code)
	if room.is_empty():
		return

	game_mode = str(room.get("mode", ""))
	host_product_user_id = str(room.get("host_user_id", ""))
	if game_mode.is_empty() or host_product_user_id.is_empty():
		_fail("Join-code response was incomplete.")
		return

	if not await ensure_eos_ready():
		return

	var result: int = _bridge.create_client_peer(SOCKET_ID, host_product_user_id)
	if result != OK:
		_fail("Could not start EOS P2P client.")
		return

	is_host = false
	multiplayer.multiplayer_peer = _bridge.get_peer()
	status_changed.emit("CONNECTING TO HOST...")
	connection_state_changed.emit("connecting")

func leave_session() -> void:
	_heartbeat_timer.stop()
	if is_host and not join_code.is_empty() and not host_token.is_empty():
		await _delete_room()

	if _bridge != null and is_instance_valid(_bridge):
		_bridge.close_peer()

	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()
	connected = false
	is_host = false
	game_mode = ""
	join_code = ""
	host_token = ""
	host_product_user_id = ""
	local_role = ""
	local_ready = false
	status_changed.emit("OFFLINE")
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
	# Solo-start is kept enabled for development so Scarlett can test networking
	# and role cameras without needing four PCs. Turn this off before release.
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
	status_changed.emit("CONNECTED — JOINING LOBBY")
	connection_state_changed.emit("lobby")
	_register_player.rpc_id(1, display_name)

func _on_connection_failed() -> void:
	_fail("Could not connect to the host.")
	connected = false

func _on_server_disconnected() -> void:
	connected = false
	players.clear()
	status_changed.emit("HOST DISCONNECTED")
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

func _clean_name(value: String) -> String:
	var cleaned := value.strip_edges()
	if cleaned.is_empty():
		return "Player"
	if cleaned.length() > 18:
		cleaned = cleaned.substr(0, 18)
	return cleaned

func _normalise_code(value: String) -> String:
	var code := value.to_upper().strip_edges().replace(" ", "").replace("-", "")
	if code.length() == 8:
		return code.substr(0, 4) + "-" + code.substr(4, 4)
	if code.length() == 9 and code[4] == "-":
		return code
	return code

func _create_room() -> Dictionary:
	if backend_url.is_empty():
		_fail("Join-code service URL is not configured.")
		return {}
	var body := JSON.stringify({
		"host_user_id": host_product_user_id,
		"mode": game_mode,
		"max_players": 8 if game_mode == "debate" else 4
	})
	return await _http_json(
		backend_url + "/rooms",
		HTTPClient.METHOD_POST,
		body,
		PackedStringArray(["Content-Type: application/json"])
	)

func _resolve_room(code_value: String) -> Dictionary:
	if backend_url.is_empty():
		_fail("Join-code service URL is not configured.")
		return {}
	var encoded := code_value.uri_encode()
	var result := await _http_json(
		backend_url + "/rooms/" + encoded,
		HTTPClient.METHOD_GET,
		"",
		[]
	)
	if result.is_empty():
		_fail("Join code not found or expired.")
	return result

func _delete_room() -> void:
	if backend_url.is_empty() or join_code.is_empty() or host_token.is_empty():
		return
	await _http_json(
		backend_url + "/rooms/" + join_code.uri_encode(),
		HTTPClient.METHOD_DELETE,
		"",
		PackedStringArray(["Authorization: Bearer " + host_token])
	)

func _heartbeat_room() -> void:
	if not is_host or join_code.is_empty() or host_token.is_empty():
		return
	await _http_json(
		backend_url + "/rooms/" + join_code.uri_encode() + "/heartbeat",
		HTTPClient.METHOD_POST,
		"",
		PackedStringArray(["Authorization: Bearer " + host_token])
	)

func _http_json(url: String, method: HTTPClient.Method, body: String, headers: PackedStringArray) -> Dictionary:
	var err := _http.request(url, headers, method, body)
	if err != OK:
		_fail("Join-code service request could not start.")
		return {}

	var response: Array = await _http.request_completed
	var result_code: int = int(response[0])
	var status_code: int = int(response[1])
	var data: PackedByteArray = response[3]

	if result_code != HTTPRequest.RESULT_SUCCESS:
		_fail("Join-code service network error.")
		return {}

	var parsed: Variant = JSON.parse_string(data.get_string_from_utf8())
	if status_code < 200 or status_code >= 300:
		if typeof(parsed) == TYPE_DICTIONARY:
			var message := str((parsed as Dictionary).get("error", "Join-code service error."))
			_fail(message)
		else:
			_fail("Join-code service returned HTTP %d." % status_code)
		return {}

	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary

func _fail(message: String) -> void:
	status_changed.emit(message)
	error_occurred.emit(message)
	connection_state_changed.emit("error")

# --------------------------------------------------------------------
# Voice interface foundation
# --------------------------------------------------------------------
# EOS RTC voice is intentionally kept behind the EOS bridge. The UI can
# expose PTT/mute state now without pretending audio is already live.
func set_push_to_talk(active: bool) -> void:
	if _bridge != null and is_instance_valid(_bridge) and _bridge.has_method("set_push_to_talk"):
		_bridge.set_push_to_talk(active)

func set_remote_muted(product_user_id: String, muted: bool) -> void:
	if _bridge != null and is_instance_valid(_bridge) and _bridge.has_method("set_remote_muted"):
		_bridge.set_remote_muted(product_user_id, muted)
