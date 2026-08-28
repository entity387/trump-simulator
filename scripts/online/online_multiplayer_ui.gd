extends Control

signal close_requested
signal launch_match(mode_name: String, role_name: String)

var manager: Variant = null

var panel: Panel
var title: Label
var status: Label
var body: VBoxContainer
var name_input: LineEdit
var lobby_players: RichTextLabel
var lobby_code: Label
var lobby_mode: Label
var role_button: Button
var ready_button: Button
var start_button: Button
var games_container: VBoxContainer
var games_scroll: ScrollContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 100
	manager = get_node_or_null("/root/OnlineMultiplayer")
	_build_shell()

	if manager == null:
		title.text = "LAN MULTIPLAYER"
		status.text = "MULTIPLAYER SERVICE DID NOT LOAD"
		_clear_body()
		_add_button("BACK", _close)
		return

	manager.status_changed.connect(_on_status_changed)
	manager.lobby_updated.connect(_on_lobby_updated)
	manager.match_started.connect(_on_match_started)
	manager.connection_state_changed.connect(_on_connection_state)
	if manager.has_signal("lan_games_updated"):
		manager.lan_games_updated.connect(_on_lan_games_updated)
	show_home()

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.055, 0.08, 0.92)
	style.border_color = Color(0.82, 0.88, 0.96, 0.20)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.shadow_color = Color(0, 0, 0, 0.55)
	style.shadow_size = 24
	return style

func _button(text_value: String) -> Button:
	var b := Button.new()
	b.text = text_value
	b.custom_minimum_size = Vector2(390, 42)
	b.add_theme_font_size_override("font_size", 15)
	return b

func _build_shell() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.38)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	panel = Panel.new()
	panel.position = Vector2(290, 45)
	panel.size = Vector2(700, 630)
	panel.add_theme_stylebox_override("panel", _panel_style())
	add_child(panel)

	title = Label.new()
	title.position = Vector2(30, 24)
	title.size = Vector2(640, 42)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	panel.add_child(title)

	status = Label.new()
	status.position = Vector2(50, 70)
	status.size = Vector2(600, 44)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_font_size_override("font_size", 12)
	status.modulate = Color("#b9c5d1")
	panel.add_child(status)

	body = VBoxContainer.new()
	body.position = Vector2(155, 122)
	body.size = Vector2(390, 455)
	body.add_theme_constant_override("separation", 9)
	panel.add_child(body)

func _clear_body() -> void:
	for child in body.get_children():
		child.queue_free()
	games_container = null
	games_scroll = null

func _add_button(text_value: String, callback: Callable) -> Button:
	var b := _button(text_value)
	b.pressed.connect(callback)
	body.add_child(b)
	return b

func _add_label(text_value: String, font_size: int = 14) -> Label:
	var l := Label.new()
	l.text = text_value
	l.custom_minimum_size = Vector2(390, 28)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", font_size)
	body.add_child(l)
	return l

func _name_field() -> LineEdit:
	var input := LineEdit.new()
	input.placeholder_text = "Display name"
	input.text = "Player"
	input.max_length = 18
	input.custom_minimum_size = Vector2(390, 40)
	body.add_child(input)
	return input

func show_home() -> void:
	_clear_body()
	title.text = "LAN MULTIPLAYER"
	status.text = "SCANNING YOUR LOCAL NETWORK..."
	name_input = _name_field()
	_add_button("HOST LAN GAME", show_host_select)
	_add_label("GAMES ON YOUR NETWORK", 13)

	games_scroll = ScrollContainer.new()
	games_scroll.custom_minimum_size = Vector2(390, 170)
	games_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(games_scroll)

	games_container = VBoxContainer.new()
	games_container.custom_minimum_size = Vector2(370, 165)
	games_container.add_theme_constant_override("separation", 6)
	games_scroll.add_child(games_container)

	_add_button("REFRESH LAN GAMES", _refresh_games)
	_add_button("BACK", _close)
	manager.start_lan_scan()
	_refresh_game_list(manager.discovered_games)

func show_host_select() -> void:
	manager.stop_lan_scan()
	_clear_body()
	title.text = "HOST LAN GAME"
	status.text = "OTHER DEVICES ON THIS NETWORK WILL FIND YOUR GAME AUTOMATICALLY"
	name_input = _name_field()
	_add_button("HOST CRISIS ROOM", _host.bind("crisis"))
	_add_button("HOST PRESIDENTIAL DEBATE", _host.bind("debate"))
	_add_button("BACK", show_home)

func show_lobby() -> void:
	manager.stop_lan_scan()
	_clear_body()
	title.text = "LAN LOBBY"

	var connection_text := manager.join_code if not manager.join_code.is_empty() else "LAN"
	lobby_code = _add_label(("HOST: " if manager.is_host else "CONNECTED: ") + connection_text, 17)
	lobby_mode = _add_label(_pretty_mode(manager.game_mode), 16)

	lobby_players = RichTextLabel.new()
	lobby_players.bbcode_enabled = true
	lobby_players.fit_content = false
	lobby_players.custom_minimum_size = Vector2(390, 175)
	lobby_players.add_theme_font_size_override("normal_font_size", 13)
	body.add_child(lobby_players)

	role_button = _add_button("ROLE", Callable(manager, "request_next_role"))
	ready_button = _add_button("READY", Callable(manager, "toggle_ready"))

	if manager.is_host:
		start_button = _add_button("START MATCH", Callable(manager, "start_match"))
	else:
		start_button = null

	_add_button("LEAVE LOBBY", _leave_lobby)
	_refresh_lobby()

func _host(mode_name: String) -> void:
	status.text = "STARTING LAN HOST..."
	manager.host_game(mode_name, name_input.text)
	if manager.connected:
		show_lobby()

func _join_discovered(address: String, port: int, mode_name: String) -> void:
	var chosen_name := "Player"
	if name_input != null:
		chosen_name = name_input.text
	status.text = "CONNECTING TO LAN HOST..."
	manager.join_lan_game(address, port, mode_name, chosen_name)

func _refresh_games() -> void:
	manager.refresh_lan_scan()

func _on_lan_games_updated(games: Array) -> void:
	_refresh_game_list(games)

func _refresh_game_list(games: Array) -> void:
	if games_container == null or not is_instance_valid(games_container):
		return
	for child in games_container.get_children():
		child.queue_free()

	if games.is_empty():
		var empty := Label.new()
		empty.text = "Searching...\nNo LAN games found yet."
		empty.custom_minimum_size = Vector2(360, 80)
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty.modulate = Color("#96a7b6")
		games_container.add_child(empty)
		return

	for game_value in games:
		if not (game_value is Dictionary):
			continue
		var game := game_value as Dictionary
		var address := str(game.get("address", ""))
		var port := int(game.get("port", 27887))
		var mode := str(game.get("mode", "crisis"))
		var host_name := str(game.get("name", "LAN Host"))
		var player_count := int(game.get("players", 1))
		var max_players := int(game.get("max_players", 4))
		var b := _button("%s  •  %s  •  %d/%d" % [host_name, _pretty_mode(mode), player_count, max_players])
		b.custom_minimum_size = Vector2(365, 42)
		b.pressed.connect(_join_discovered.bind(address, port, mode))
		games_container.add_child(b)

func _leave_lobby() -> void:
	manager.leave_session()
	show_home()

func _close() -> void:
	if manager != null:
		manager.stop_lan_scan()
		if manager.connected or manager.is_host:
			manager.leave_session()
	close_requested.emit()

func _on_status_changed(message: String) -> void:
	status.text = message

func _on_connection_state(state: String) -> void:
	if state == "lobby" and manager.connected:
		show_lobby()
	elif state == "host_disconnected":
		show_home()
		status.text = "LAN HOST DISCONNECTED"

func _on_lobby_updated(_players: Dictionary, _code: String, _mode: String, _host: bool) -> void:
	if lobby_players != null and is_instance_valid(lobby_players):
		_refresh_lobby()

func _refresh_lobby() -> void:
	if lobby_players == null or not is_instance_valid(lobby_players):
		return

	if lobby_code != null:
		lobby_code.text = ("HOST: " if manager.is_host else "CONNECTED: ") + (manager.join_code if not manager.join_code.is_empty() else "LAN")
	if lobby_mode != null:
		lobby_mode.text = _pretty_mode(manager.game_mode)

	var lines: Array[String] = []
	var ids: Array = manager.players.keys()
	ids.sort()
	for peer_id in ids:
		var p: Dictionary = manager.players[peer_id]
		var host_mark: String = " [HOST]" if bool(p.get("host", false)) else ""
		var ready_mark: String = " ✓ READY" if bool(p.get("ready", false)) else ""
		lines.append("[b]%s[/b]%s\n%s%s" % [
			str(p.get("name", "Player")),
			host_mark,
			_pretty_role(str(p.get("role", ""))),
			ready_mark
		])
	lobby_players.text = "\n\n".join(lines)

	if role_button != null:
		role_button.text = "ROLE — " + _pretty_role(manager.local_role)
	if ready_button != null:
		ready_button.text = "READY — " + ("YES" if manager.local_ready else "NO")

func _on_match_started(mode_name: String, role_name: String) -> void:
	launch_match.emit(mode_name, role_name)

func _pretty_mode(mode_name: String) -> String:
	return "CRISIS ROOM" if mode_name == "crisis" else "PRESIDENTIAL DEBATE"

func _pretty_role(role_name: String) -> String:
	if role_name.begins_with("AUDIENCE"):
		return "AUDIENCE"
	return role_name.replace("_", " ")
