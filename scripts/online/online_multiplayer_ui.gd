extends Control

signal close_requested
signal launch_match(mode_name: String, role_name: String)

var manager: Variant = null

var panel: Panel
var title: Label
var status: Label
var body: VBoxContainer

var name_input: LineEdit
var code_input: LineEdit
var lobby_players: RichTextLabel
var lobby_code: Label
var lobby_mode: Label
var role_button: Button
var ready_button: Button
var start_button: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 100
	manager = get_node_or_null("/root/OnlineMultiplayer")
	_build_shell()

	if manager == null:
		title.text = "MULTIPLAYER"
		status.text = "MULTIPLAYER SERVICE DID NOT LOAD"
		_clear_body()
		_add_label("Return to the multiplayer menu and rebuild with the online scripts included.", 13)
		_add_button("BACK", _close)
		return

	manager.status_changed.connect(_on_status_changed)
	manager.lobby_updated.connect(_on_lobby_updated)
	manager.match_started.connect(_on_match_started)
	manager.connection_state_changed.connect(_on_connection_state)
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
	b.custom_minimum_size = Vector2(360, 44)
	b.add_theme_font_size_override("font_size", 16)
	return b

func _build_shell() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.38)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	panel = Panel.new()
	panel.position = Vector2(315, 70)
	panel.size = Vector2(650, 590)
	panel.add_theme_stylebox_override("panel", _panel_style())
	add_child(panel)

	title = Label.new()
	title.position = Vector2(30, 28)
	title.size = Vector2(590, 42)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	panel.add_child(title)

	status = Label.new()
	status.position = Vector2(45, 76)
	status.size = Vector2(560, 44)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_font_size_override("font_size", 12)
	status.modulate = Color("#b9c5d1")
	panel.add_child(status)

	body = VBoxContainer.new()
	body.position = Vector2(145, 140)
	body.size = Vector2(360, 390)
	body.add_theme_constant_override("separation", 12)
	panel.add_child(body)

func _clear_body() -> void:
	for child in body.get_children():
		child.queue_free()

func _add_button(text_value: String, callback: Callable) -> Button:
	var b := _button(text_value)
	b.pressed.connect(callback)
	body.add_child(b)
	return b

func _add_label(text_value: String, font_size: int = 14) -> Label:
	var l := Label.new()
	l.text = text_value
	l.custom_minimum_size = Vector2(360, 30)
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
	input.custom_minimum_size = Vector2(360, 42)
	body.add_child(input)
	return input

func show_home() -> void:
	_clear_body()
	title.text = "MULTIPLAYER"
	status.text = "HOST A GAME OR JOIN WITH A CODE"
	_add_button("HOST GAME", show_host_select)
	_add_button("JOIN GAME", show_join)
	_add_button("BACK", _close)

func show_host_select() -> void:
	_clear_body()
	title.text = "HOST GAME"
	if manager != null and manager.has_method("host_mode_description"):
		status.text = str(manager.call("host_mode_description"))
	else:
		status.text = "CHOOSE A GAME TO HOST"
	name_input = _name_field()
	_add_button("HOST CRISIS ROOM", _host.bind("crisis"))
	_add_button("HOST PRESIDENTIAL DEBATE", _host.bind("debate"))
	_add_button("BACK", show_home)

func show_join() -> void:
	_clear_body()
	title.text = "JOIN GAME"
	status.text = "ENTER THE HOST'S JOIN CODE"
	name_input = _name_field()
	code_input = LineEdit.new()
	code_input.placeholder_text = "ABCD-1234"
	code_input.max_length = 9
	code_input.custom_minimum_size = Vector2(360, 46)
	code_input.add_theme_font_size_override("font_size", 20)
	code_input.text_changed.connect(_format_join_code)
	body.add_child(code_input)
	_add_button("JOIN", _join)
	_add_button("BACK", show_home)

func show_lobby() -> void:
	_clear_body()
	title.text = "MULTIPLAYER LOBBY"

	var shown_code: String = manager.join_code if not manager.join_code.is_empty() else "CONNECTING..."
	if bool(manager.get("local_test_host")):
		shown_code = "LOCAL LOBBY"
	lobby_code = _add_label("JOIN CODE: " + shown_code, 22)
	lobby_mode = _add_label(_pretty_mode(manager.game_mode), 16)

	lobby_players = RichTextLabel.new()
	lobby_players.bbcode_enabled = true
	lobby_players.fit_content = false
	lobby_players.custom_minimum_size = Vector2(360, 150)
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
	status.text = "STARTING HOST..."
	await manager.host_game(mode_name, name_input.text)
	if manager.connected:
		show_lobby()
	else:
		# Keep the host screen visible and show the manager's failure text.
		if manager.has_method("host_mode_description") and status.text == "STARTING HOST...":
			status.text = str(manager.call("host_mode_description"))

func _join() -> void:
	status.text = "CONNECTING..."
	await manager.join_game(code_input.text, name_input.text)
	# show_lobby is triggered once Godot reports connected_to_server.

func _leave_lobby() -> void:
	await manager.leave_session()
	show_home()

func _close() -> void:
	if manager != null and (manager.connected or manager.is_host):
		await manager.leave_session()
	close_requested.emit()

func _format_join_code(value: String) -> void:
	var compact := value.to_upper().replace("-", "").replace(" ", "")
	var formatted := compact
	if compact.length() > 4:
		formatted = compact.substr(0, 4) + "-" + compact.substr(4, mini(4, compact.length() - 4))
	if code_input.text != formatted:
		code_input.set_block_signals(true)
		code_input.text = formatted
		code_input.caret_column = formatted.length()
		code_input.set_block_signals(false)

func _on_status_changed(message: String) -> void:
	status.text = message

func _on_connection_state(state: String) -> void:
	if state == "lobby" and manager.connected:
		show_lobby()
	elif state == "host_disconnected":
		show_home()
		status.text = "HOST DISCONNECTED"

func _on_lobby_updated(_players: Dictionary, _code: String, _mode: String, _host: bool) -> void:
	if lobby_players != null and is_instance_valid(lobby_players):
		_refresh_lobby()

func _refresh_lobby() -> void:
	if lobby_players == null or not is_instance_valid(lobby_players):
		return

	if lobby_code != null:
		lobby_code.text = "JOIN CODE: " + (manager.join_code if not manager.join_code.is_empty() else "CONNECTING...")
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
	if role_name == "AUDIENCE":
		return "AUDIENCE"
	return role_name.replace("_", " ")
