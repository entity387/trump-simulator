extends Node3D

signal exit_requested
signal role_changed(role_name: String)

# This scene is intentionally built from real 3D meshes.
# It is the visual/map foundation for networked multiplayer.
# Networking and voice chat are wired separately later.

var arena_camera: Camera3D
var arena_root: Node3D
var character_root: Node3D
var active_mode: String = ""
var active_role: String = ""
var local_character: Node3D
var yaw: float = 0.0
var pitch: float = 0.0
var mouse_look_enabled: bool = true

var debate_characters: Dictionary = {}
var crisis_characters: Dictionary = {}
var audience_characters: Array[Node3D] = []

const TRUMP_SKIN := Color("#e9ad78")
const BIDEN_SKIN := Color("#e6c5aa")
const SUIT_NAVY := Color("#101b31")
const SUIT_CHARCOAL := Color("#242831")
const SHIRT := Color("#f5f5f2")
const TRUMP_HAIR := Color("#d9bd6a")
const BIDEN_HAIR := Color("#e8e6df")
const MOD_HAIR := Color("#3a2d28")
const RED_TIE := Color("#b5222d")
const BLUE_TIE := Color("#315b9a")
const GOLD := Color("#c8aa62")
const SCREEN := Color("#0d2431")

func _ready() -> void:
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_ESCAPE:
			exit_requested.emit()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and mouse_look_enabled and arena_camera != null:
		var motion := event as InputEventMouseMotion
		yaw -= motion.relative.x * 0.0024
		pitch = clampf(pitch - motion.relative.y * 0.0021, -1.15, 1.15)
		arena_camera.rotation = Vector3(pitch, yaw, 0.0)

func build_mode(mode_name: String, role_name: String) -> void:
	active_mode = mode_name
	active_role = role_name
	_clear_arena()

	arena_root = Node3D.new()
	arena_root.name = "MultiplayerArena"
	add_child(arena_root)

	character_root = Node3D.new()
	character_root.name = "Characters"
	arena_root.add_child(character_root)

	_build_lighting()

	if mode_name == "debate":
		_build_debate_room()
		_set_debate_role(role_name)
	else:
		_build_crisis_room()
		_set_crisis_role(role_name)

func switch_role(role_name: String) -> void:
	active_role = role_name
	if active_mode == "debate":
		_set_debate_role(role_name)
	else:
		_set_crisis_role(role_name)

func _clear_arena() -> void:
	debate_characters.clear()
	crisis_characters.clear()
	audience_characters.clear()
	local_character = null
	if arena_root != null and is_instance_valid(arena_root):
		arena_root.queue_free()
	arena_root = null
	arena_camera = null

func _build_lighting() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#10151d")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#d9e1ea")
	env.ambient_light_energy = 0.72
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_env.environment = env
	arena_root.add_child(world_env)

	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	key.light_energy = 1.25
	key.shadow_enabled = true
	arena_root.add_child(key)

	var fill := OmniLight3D.new()
	fill.position = Vector3(0.0, 4.5, 2.0)
	fill.omni_range = 18.0
	fill.light_energy = 5.0
	fill.light_color = Color("#e7edf5")
	arena_root.add_child(fill)

func _material(color: Color, metallic: float = 0.0, roughness: float = 0.68) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	return material

func _box(
	parent: Node,
	node_name: String,
	size: Vector3,
	position_value: Vector3,
	color: Color,
	rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var item := MeshInstance3D.new()
	item.name = node_name
	item.mesh = mesh
	item.position = position_value
	item.rotation_degrees = rotation_value
	item.material_override = _material(color)
	parent.add_child(item)
	return item

func _cylinder(
	parent: Node,
	node_name: String,
	radius: float,
	height: float,
	position_value: Vector3,
	color: Color,
	rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	var item := MeshInstance3D.new()
	item.name = node_name
	item.mesh = mesh
	item.position = position_value
	item.rotation_degrees = rotation_value
	item.material_override = _material(color)
	parent.add_child(item)
	return item

func _sphere(
	parent: Node,
	node_name: String,
	radius: float,
	position_value: Vector3,
	color: Color,
	scale_value: Vector3 = Vector3.ONE
) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	var item := MeshInstance3D.new()
	item.name = node_name
	item.mesh = mesh
	item.position = position_value
	item.scale = scale_value
	item.material_override = _material(color)
	parent.add_child(item)
	return item

func _label3d(
	parent: Node,
	text_value: String,
	position_value: Vector3,
	font_size_value: int = 64,
	pixel_size_value: float = 0.0038,
	modulate_value: Color = Color("#f2f6fb")
) -> Label3D:
	var label := Label3D.new()
	label.text = text_value
	label.position = position_value
	label.font_size = font_size_value
	label.pixel_size = pixel_size_value
	label.modulate = modulate_value
	label.outline_size = 8
	label.outline_modulate = Color(0, 0, 0, 0.9)
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	parent.add_child(label)
	return label

func _chair(parent: Node, pos: Vector3, yaw_deg: float, color: Color = Color("#222831")) -> Node3D:
	var chair := Node3D.new()
	chair.position = pos
	chair.rotation_degrees.y = yaw_deg
	parent.add_child(chair)
	_box(chair, "Seat", Vector3(0.70, 0.12, 0.68), Vector3(0, 0.53, 0), color)
	_box(chair, "Back", Vector3(0.70, 0.88, 0.12), Vector3(0, 1.00, 0.29), color)
	_box(chair, "LegL", Vector3(0.10, 0.55, 0.10), Vector3(-0.27, 0.27, 0.22), Color("#15181c"))
	_box(chair, "LegR", Vector3(0.10, 0.55, 0.10), Vector3(0.27, 0.27, 0.22), Color("#15181c"))
	return chair

func _podium(parent: Node, pos: Vector3, name_text: String) -> Node3D:
	var podium := Node3D.new()
	podium.position = pos
	parent.add_child(podium)
	_box(podium, "Base", Vector3(1.45, 0.18, 0.95), Vector3(0, 0.09, 0), Color("#20242c"))
	_box(podium, "Body", Vector3(1.15, 1.18, 0.72), Vector3(0, 0.68, 0), Color("#2f353e"))
	_box(podium, "Top", Vector3(1.45, 0.14, 0.88), Vector3(0, 1.30, 0), Color("#15181d"))
	var label := _label3d(podium, name_text, Vector3(0, 0.78, 0.37), 56, 0.0032, Color("#f5f2e8"))
	label.rotation_degrees = Vector3(0, 180, 0)
	return podium

func _desk(parent: Node, pos: Vector3, size: Vector3, color: Color) -> Node3D:
	var desk := Node3D.new()
	desk.position = pos
	parent.add_child(desk)
	_box(desk, "Top", Vector3(size.x, 0.16, size.z), Vector3(0, 0.88, 0), color)
	_box(desk, "Front", Vector3(size.x, 0.84, 0.12), Vector3(0, 0.44, -size.z * 0.43), color.darkened(0.12))
	_box(desk, "LegL", Vector3(0.16, 0.86, size.z * 0.75), Vector3(-size.x * 0.42, 0.43, 0), color.darkened(0.18))
	_box(desk, "LegR", Vector3(0.16, 0.86, size.z * 0.75), Vector3(size.x * 0.42, 0.43, 0), color.darkened(0.18))
	return desk

func _screen(parent: Node, pos: Vector3, rotation_y: float, text_value: String, width: float = 1.65) -> Node3D:
	var screen := Node3D.new()
	screen.position = pos
	screen.rotation_degrees.y = rotation_y
	parent.add_child(screen)
	_box(screen, "Monitor", Vector3(width, 0.95, 0.10), Vector3.ZERO, Color("#11161d"))
	_box(screen, "Display", Vector3(width - 0.12, 0.82, 0.015), Vector3(0, 0, -0.058), SCREEN)
	var label := _label3d(screen, text_value, Vector3(0, 0, -0.072), 48, 0.0026, Color("#86e0d3"))
	label.rotation_degrees = Vector3(0, 180, 0)
	return screen

func _console_button(parent: Node, pos: Vector3, color: Color, label_text: String) -> Node3D:
	var root := Node3D.new()
	root.position = pos
	parent.add_child(root)
	_cylinder(root, "ButtonBase", 0.22, 0.11, Vector3.ZERO, Color("#171a1f"))
	_cylinder(root, "Button", 0.17, 0.12, Vector3(0, 0.10, 0), color)
	var label := _label3d(root, label_text, Vector3(0, 0.06, 0.33), 38, 0.0024, Color("#f3f4f6"))
	label.rotation_degrees = Vector3(-90, 180, 0)
	return root

func _make_character(
	character_kind: String,
	pos: Vector3,
	yaw_deg: float,
	seated: bool,
	variant_index: int = 0
) -> Node3D:
	var person := Node3D.new()
	person.name = character_kind + "_" + str(variant_index)
	person.position = pos
	person.rotation_degrees.y = yaw_deg
	character_root.add_child(person)

	var skin := TRUMP_SKIN
	var suit := SUIT_NAVY
	var hair := TRUMP_HAIR
	var tie := RED_TIE
	var body_width := 0.58
	var head_y := 1.66
	var torso_y := 1.16
	var leg_y := 0.52

	if character_kind == "BIDEN":
		skin = BIDEN_SKIN
		suit = Color("#18243a")
		hair = BIDEN_HAIR
		tie = BLUE_TIE
		body_width = 0.52
	elif character_kind == "MODERATOR":
		skin = Color("#c89372")
		suit = SUIT_CHARCOAL
		hair = MOD_HAIR
		tie = Color("#59636f")
		body_width = 0.50
	elif character_kind == "AUDIENCE":
		var skin_palette: Array[Color] = [
			Color("#edc19e"), Color("#c98d68"), Color("#8e5f46"),
			Color("#e1ad83"), Color("#a86e50"), Color("#6f4937")
		]
		var suit_palette: Array[Color] = [
			Color("#334457"), Color("#4a3945"), Color("#394a3e"),
			Color("#4a4840"), Color("#28343f"), Color("#51404a")
		]
		var hair_palette: Array[Color] = [
			Color("#201c1a"), Color("#4b3528"), Color("#8a6648"),
			Color("#d3c3a4"), Color("#392a24")
		]
		skin = skin_palette[variant_index % skin_palette.size()]
		suit = suit_palette[variant_index % suit_palette.size()]
		hair = hair_palette[variant_index % hair_palette.size()]
		tie = suit.lightened(0.18)
		body_width = 0.47

	if seated:
		head_y = 1.46
		torso_y = 0.98
		leg_y = 0.38

	# Shoes / legs
	_box(person, "ShoeL", Vector3(0.20, 0.12, 0.34), Vector3(-0.18, 0.08, -0.04), Color("#101114"))
	_box(person, "ShoeR", Vector3(0.20, 0.12, 0.34), Vector3(0.18, 0.08, -0.04), Color("#101114"))
	_box(person, "LegL", Vector3(0.22, 0.76 if not seated else 0.50, 0.27), Vector3(-0.17, leg_y, 0), suit)
	_box(person, "LegR", Vector3(0.22, 0.76 if not seated else 0.50, 0.27), Vector3(0.17, leg_y, 0), suit)

	# Torso / shirt / jacket
	_box(person, "Torso", Vector3(body_width, 0.70, 0.32), Vector3(0, torso_y, 0), suit)
	_box(person, "Shirt", Vector3(0.18, 0.48, 0.02), Vector3(0, torso_y + 0.02, -0.171), SHIRT)
	_box(person, "Tie", Vector3(0.075, 0.40, 0.025), Vector3(0, torso_y - 0.02, -0.187), tie)

	# Arms
	_box(person, "ArmL", Vector3(0.16, 0.64, 0.18), Vector3(-body_width * 0.60, torso_y, 0), suit, Vector3(0, 0, -4))
	_box(person, "ArmR", Vector3(0.16, 0.64, 0.18), Vector3(body_width * 0.60, torso_y, 0), suit, Vector3(0, 0, 4))
	_sphere(person, "HandL", 0.11, Vector3(-body_width * 0.60, torso_y - 0.35, -0.02), skin)
	_sphere(person, "HandR", 0.11, Vector3(body_width * 0.60, torso_y - 0.35, -0.02), skin)

	# Head / ears
	_sphere(person, "Head", 0.25, Vector3(0, head_y, 0), skin, Vector3(0.95, 1.08, 0.92))
	_sphere(person, "EarL", 0.065, Vector3(-0.245, head_y, 0), skin)
	_sphere(person, "EarR", 0.065, Vector3(0.245, head_y, 0), skin)

	# Hair silhouette
	if character_kind == "TRUMP":
		_sphere(person, "HairTop", 0.24, Vector3(0, head_y + 0.20, 0.015), hair, Vector3(1.03, 0.34, 0.95))
		_box(person, "CombOver", Vector3(0.40, 0.075, 0.22), Vector3(0.04, head_y + 0.235, -0.03), hair, Vector3(0, 0, -8))
	elif character_kind == "BIDEN":
		_sphere(person, "HairTop", 0.235, Vector3(0, head_y + 0.18, 0.03), hair, Vector3(1.0, 0.25, 0.92))
		_box(person, "HairSideL", Vector3(0.08, 0.22, 0.16), Vector3(-0.20, head_y + 0.08, 0.01), hair)
		_box(person, "HairSideR", Vector3(0.08, 0.22, 0.16), Vector3(0.20, head_y + 0.08, 0.01), hair)
	else:
		_sphere(person, "HairTop", 0.235, Vector3(0, head_y + 0.18, 0.02), hair, Vector3(1.0, 0.30, 0.94))

	# Simple eyes facing local -Z.
	_sphere(person, "EyeL", 0.025, Vector3(-0.085, head_y + 0.02, -0.225), Color("#111318"))
	_sphere(person, "EyeR", 0.025, Vector3(0.085, head_y + 0.02, -0.225), Color("#111318"))

	return person

func _set_character_local(person: Node3D) -> void:
	if local_character != null and is_instance_valid(local_character):
		local_character.visible = true
	local_character = person
	if local_character != null:
		# The local player's own head/body would block first-person view.
		# Other clients / preview roles still see the real 3D model.
		local_character.visible = false

func _create_camera(pos: Vector3, target: Vector3) -> void:
	if arena_camera != null and is_instance_valid(arena_camera):
		arena_camera.queue_free()
	arena_camera = Camera3D.new()
	arena_camera.name = "RoleCamera"
	arena_camera.position = pos
	arena_camera.fov = 76.0
	arena_camera.near = 0.05
	arena_camera.current = true
	arena_root.add_child(arena_camera)
	arena_camera.look_at(target, Vector3.UP)
	yaw = arena_camera.rotation.y
	pitch = arena_camera.rotation.x

# ============================================================
# PRESIDENTIAL DEBATE
# ============================================================

func _build_debate_room() -> void:
	# Room shell
	_box(arena_root, "Floor", Vector3(20, 0.20, 18), Vector3(0, -0.10, 4.5), Color("#24272e"))
	_box(arena_root, "Stage", Vector3(13.8, 0.28, 5.0), Vector3(0, 0.14, 0.3), Color("#3a3330"))
	_box(arena_root, "BackWall", Vector3(18.0, 6.5, 0.25), Vector3(0, 3.25, -2.35), Color("#182334"))
	_box(arena_root, "LeftWall", Vector3(0.25, 6.5, 18), Vector3(-9.0, 3.25, 4.5), Color("#1c2027"))
	_box(arena_root, "RightWall", Vector3(0.25, 6.5, 18), Vector3(9.0, 3.25, 4.5), Color("#1c2027"))
	_box(arena_root, "Ceiling", Vector3(18, 0.20, 18), Vector3(0, 6.5, 4.5), Color("#161a20"))

	# Neutral debate branding / stage features.
	_box(arena_root, "BackdropPanel", Vector3(9.0, 3.7, 0.18), Vector3(0, 3.05, -2.18), Color("#243750"))
	_label3d(arena_root, "PRESIDENTIAL DEBATE", Vector3(0, 4.00, -2.05), 92, 0.0050, Color("#f0eadb"))
	_label3d(arena_root, "SIMULATED STUDIOS", Vector3(0, 3.25, -2.04), 42, 0.0032, GOLD)

	# Podiums and playable candidates.
	_podium(arena_root, Vector3(-2.8, 0, 0.65), "TRUMP")
	_podium(arena_root, Vector3(2.8, 0, 0.65), "BIDEN")
	var trump := _make_character("TRUMP", Vector3(-2.8, 0, -0.05), 180.0, false, 0)
	var biden := _make_character("BIDEN", Vector3(2.8, 0, -0.05), 180.0, false, 0)
	debate_characters["TRUMP"] = trump
	debate_characters["BIDEN"] = biden

	# Podium interrupt controls.
	_console_button(arena_root, Vector3(-2.45, 1.43, 0.67), Color("#bd2930"), "INTERRUPT")
	_console_button(arena_root, Vector3(3.15, 1.43, 0.67), Color("#315b9a"), "INTERRUPT")

	# Moderator desk and real 3D moderator.
	var moderator_desk := _desk(arena_root, Vector3(0, 0, 3.05), Vector3(3.6, 0, 1.15), Color("#353b45"))
	_screen(moderator_desk, Vector3(0, 1.48, -0.12), 0.0, "02:00\nQUESTION 1", 1.75)
	_console_button(moderator_desk, Vector3(-0.75, 1.05, -0.15), Color("#b52b31"), "MUTE T")
	_console_button(moderator_desk, Vector3(0.0, 1.05, -0.15), Color("#c7a85e"), "NEXT")
	_console_button(moderator_desk, Vector3(0.75, 1.05, -0.15), Color("#315b9a"), "MUTE B")
	_chair(arena_root, Vector3(0, 0, 3.95), 0.0, Color("#222831"))
	var moderator := _make_character("MODERATOR", Vector3(0, 0, 3.85), 0.0, true, 0)
	debate_characters["MODERATOR"] = moderator

	# Audience seating and 3D NPCs.
	var idx: int = 0
	for row in range(3):
		for col in range(6):
			var seat_x: float = -5.75 + float(col) * 2.30
			var seat_z: float = 6.4 + float(row) * 2.25
			var seat_pos := Vector3(seat_x, 0, seat_z)
			_chair(arena_root, seat_pos, 0.0, Color("#242a32"))
			var audience := _make_character("AUDIENCE", seat_pos + Vector3(0, 0, 0.02), 0.0, true, idx)
			audience_characters.append(audience)
			idx += 1

	# Decorative aisle rails and cameras/lights.
	_box(arena_root, "AudienceRailL", Vector3(0.10, 0.85, 8.0), Vector3(-7.4, 0.43, 8.1), Color("#353b43"))
	_box(arena_root, "AudienceRailR", Vector3(0.10, 0.85, 8.0), Vector3(7.4, 0.43, 8.1), Color("#353b43"))

	var stage_light_a := SpotLight3D.new()
	stage_light_a.position = Vector3(-3.5, 5.6, 2.0)
	stage_light_a.rotation_degrees = Vector3(-55, 0, 0)
	stage_light_a.spot_range = 10.0
	stage_light_a.light_energy = 7.0
	stage_light_a.shadow_enabled = true
	arena_root.add_child(stage_light_a)

	var stage_light_b := SpotLight3D.new()
	stage_light_b.position = Vector3(3.5, 5.6, 2.0)
	stage_light_b.rotation_degrees = Vector3(-55, 0, 0)
	stage_light_b.spot_range = 10.0
	stage_light_b.light_energy = 7.0
	stage_light_b.shadow_enabled = true
	arena_root.add_child(stage_light_b)

func _set_debate_role(role_name: String) -> void:
	for key in debate_characters.keys():
		var person := debate_characters[key] as Node3D
		if person != null:
			person.visible = true
	for person in audience_characters:
		if person != null:
			person.visible = true

	if role_name == "TRUMP":
		_set_character_local(debate_characters["TRUMP"] as Node3D)
		_create_camera(Vector3(-2.8, 1.66, -0.12), Vector3(0, 1.25, 4.5))
	elif role_name == "BIDEN":
		_set_character_local(debate_characters["BIDEN"] as Node3D)
		_create_camera(Vector3(2.8, 1.66, -0.12), Vector3(0, 1.25, 4.5))
	elif role_name == "MODERATOR":
		_set_character_local(debate_characters["MODERATOR"] as Node3D)
		_create_camera(Vector3(0, 1.48, 3.82), Vector3(0, 1.28, 0.45))
	else:
		var seat_index: int = 7
		if role_name.begins_with("AUDIENCE_"):
			seat_index = clampi(int(role_name.trim_prefix("AUDIENCE_")), 0, audience_characters.size() - 1)
		_set_character_local(audience_characters[seat_index])
		var row: int = int(seat_index / 6)
		var col: int = seat_index % 6
		var seat_x: float = -5.75 + float(col) * 2.30
		var seat_z: float = 6.4 + float(row) * 2.25
		_create_camera(Vector3(seat_x, 1.46, seat_z), Vector3(0, 1.35, 0.5))
	role_changed.emit(role_name)

# ============================================================
# CRISIS ROOM — EVERY PLAYABLE CHARACTER IS TRUMP
# ============================================================

func _build_crisis_room() -> void:
	_box(arena_root, "Floor", Vector3(18, 0.20, 16), Vector3(0, -0.10, 0), Color("#20262c"))
	_box(arena_root, "BackWall", Vector3(18, 5.5, 0.25), Vector3(0, 2.75, -8.0), Color("#1b252c"))
	_box(arena_root, "FrontWall", Vector3(18, 5.5, 0.25), Vector3(0, 2.75, 8.0), Color("#1b252c"))
	_box(arena_root, "LeftWall", Vector3(0.25, 5.5, 16), Vector3(-9.0, 2.75, 0), Color("#1b252c"))
	_box(arena_root, "RightWall", Vector3(0.25, 5.5, 16), Vector3(9.0, 2.75, 0), Color("#1b252c"))
	_box(arena_root, "Ceiling", Vector3(18, 0.20, 16), Vector3(0, 5.5, 0), Color("#151a1f"))

	_label3d(arena_root, "CRISIS COORDINATION ROOM", Vector3(0, 4.2, -7.82), 82, 0.0048, Color("#e8edf2"))
	_label3d(arena_root, "FOUR TRUMPS. FOUR JOBS. ONE PROBLEM.", Vector3(0, 3.55, -7.81), 38, 0.0030, GOLD)

	# Central coordination table.
	_desk(arena_root, Vector3(0, 0, 0), Vector3(7.0, 0, 4.4), Color("#343b42"))
	_box(arena_root, "TableInset", Vector3(5.8, 0.05, 3.2), Vector3(0, 1.00, 0), Color("#172a31"))

	# Role stations.
	_build_crisis_station("INTEL", Vector3(0, 0, -4.1), 180.0, "MISSION ORDER\nZONE C\nLAUNCH: 3", false)
	_build_crisis_station("LAUNCH", Vector3(0, 0, 4.1), 0.0, "LAUNCH CONSOLE\nTARGET: ---\nREADY", true)
	_build_crisis_station("RADAR", Vector3(5.0, 0, 0), -90.0, "RADAR\nN  •  •\n   ▲\nW     E", false)
	_build_crisis_station("COMMS", Vector3(-5.0, 0, 0), 90.0, "COMMS / POWER\nLINE 2 RINGING\nGRID: 82%", false)

	# Four real 3D Trump models.
	var intel_trump := _make_character("TRUMP", Vector3(0, 0, -4.75), 180.0, true, 0)
	var launch_trump := _make_character("TRUMP", Vector3(0, 0, 4.75), 0.0, true, 1)
	var radar_trump := _make_character("TRUMP", Vector3(5.65, 0, 0), -90.0, true, 2)
	var comms_trump := _make_character("TRUMP", Vector3(-5.65, 0, 0), 90.0, true, 3)
	crisis_characters["INTEL"] = intel_trump
	crisis_characters["LAUNCH"] = launch_trump
	crisis_characters["RADAR"] = radar_trump
	crisis_characters["COMMS"] = comms_trump

	# Role placards so every Trump is still distinguishable.
	_add_role_placard(Vector3(0, 1.25, -3.15), 180.0, "INTEL TRUMP")
	_add_role_placard(Vector3(0, 1.25, 3.15), 0.0, "LAUNCH TRUMP")
	_add_role_placard(Vector3(4.05, 1.25, 0), -90.0, "RADAR TRUMP")
	_add_role_placard(Vector3(-4.05, 1.25, 0), 90.0, "COMMS TRUMP")

func _build_crisis_station(
	role_name: String,
	pos: Vector3,
	yaw_deg: float,
	screen_text: String,
	has_launch_controls: bool
) -> void:
	var station := Node3D.new()
	station.name = role_name + "_Station"
	station.position = pos
	station.rotation_degrees.y = yaw_deg
	arena_root.add_child(station)

	_chair(station, Vector3(0, 0, 0.65), 0.0, Color("#242b33"))
	var console := _desk(station, Vector3(0, 0, -0.10), Vector3(2.75, 0, 1.25), Color("#303840"))
	_screen(console, Vector3(0, 1.55, -0.35), 0.0, screen_text, 2.10)

	if has_launch_controls:
		_console_button(console, Vector3(-0.52, 1.08, -0.15), Color("#c52832"), "LAUNCH")
		_console_button(console, Vector3(0.52, 1.08, -0.15), Color("#d6b54f"), "INTERCEPT")
	else:
		_console_button(console, Vector3(-0.42, 1.08, -0.15), Color("#4f7b86"), "ACTION")
		_console_button(console, Vector3(0.42, 1.08, -0.15), Color("#b9954c"), "CONFIRM")

func _add_role_placard(pos: Vector3, yaw_deg: float, text_value: String) -> void:
	var placard := Node3D.new()
	placard.position = pos
	placard.rotation_degrees.y = yaw_deg
	arena_root.add_child(placard)
	_box(placard, "Plate", Vector3(1.4, 0.34, 0.06), Vector3.ZERO, Color("#171a1f"))
	var label := _label3d(placard, text_value, Vector3(0, 0, -0.04), 40, 0.0024, Color("#f0d681"))
	label.rotation_degrees = Vector3(0, 180, 0)

func _set_crisis_role(role_name: String) -> void:
	for key in crisis_characters.keys():
		var person := crisis_characters[key] as Node3D
		if person != null:
			person.visible = true

	if not crisis_characters.has(role_name):
		role_name = "INTEL"

	_set_character_local(crisis_characters[role_name] as Node3D)

	if role_name == "INTEL":
		_create_camera(Vector3(0, 1.46, -4.70), Vector3(0, 1.15, -0.35))
	elif role_name == "LAUNCH":
		_create_camera(Vector3(0, 1.46, 4.70), Vector3(0, 1.15, 0.35))
	elif role_name == "RADAR":
		_create_camera(Vector3(5.60, 1.46, 0), Vector3(0.35, 1.15, 0))
	else:
		_create_camera(Vector3(-5.60, 1.46, 0), Vector3(-0.35, 1.15, 0))

	role_changed.emit(role_name)
