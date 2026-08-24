extends Control

# Simulated Studios native startup ident.
# Recreates the supplied HTML intro without opening a browser/web view.

const NEXT_SCENE := "res://main.tscn"
const INTRO_LENGTH := 3.9
const FADE_OUT_LENGTH := 0.50

const INK := Color("#0a0a0a")
const PAPER := Color("#f2f0e6")

var elapsed: float = 0.0
var fade_elapsed: float = 0.0
var leaving: bool = false
var base_group_position := Vector2.ZERO

var logo_group: Control
var logo_img: TextureRect
var logo_material: ShaderMaterial
var flash: ColorRect
var splat_one: Panel
var splat_two: Panel
var skip_label: Label
var grain_material: ShaderMaterial

func _ready() -> void:
	set_process(true)
	set_process_input(true)
	_build_intro()

func _build_intro() -> void:
	# Full black stage.
	var background := ColorRect.new()
	background.color = INK
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_full_rect(background)
	add_child(background)

	# Central fixed-size composition. Project stretch handles other resolutions.
	logo_group = Control.new()
	logo_group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo_group.anchor_left = 0.5
	logo_group.anchor_top = 0.5
	logo_group.anchor_right = 0.5
	logo_group.anchor_bottom = 0.5
	logo_group.offset_left = -300.0
	logo_group.offset_top = -175.0
	logo_group.offset_right = 300.0
	logo_group.offset_bottom = 175.0
	logo_group.z_index = 20
	add_child(logo_group)
	base_group_position = logo_group.position

	splat_one = _make_splat(Vector2(340.0, 280.0), Vector2(-20.0, 30.0))
	splat_two = _make_splat(Vector2(280.0, 320.0), Vector2(350.0, 70.0))
	logo_group.add_child(splat_one)
	logo_group.add_child(splat_two)

	logo_img = TextureRect.new()
	logo_img.texture = load("res://logo.png") as Texture2D
	logo_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo_img.position = Vector2(40.0, 71.0)
	logo_img.size = Vector2(520.0, 208.0)
	logo_img.pivot_offset = logo_img.size * 0.5
	logo_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo_img.modulate = Color(1.0, 1.0, 1.0, 0.0)
	logo_group.add_child(logo_img)

	# Small texture blur used only during the initial stamp-in.
	var logo_shader := Shader.new()
	logo_shader.code = """
shader_type canvas_item;
uniform float blur_amount : hint_range(0.0, 8.0) = 0.0;
void fragment() {
    vec2 px = TEXTURE_PIXEL_SIZE * blur_amount;
    vec4 c = texture(TEXTURE, UV) * 0.36;
    c += texture(TEXTURE, UV + vec2(px.x, 0.0)) * 0.16;
    c += texture(TEXTURE, UV - vec2(px.x, 0.0)) * 0.16;
    c += texture(TEXTURE, UV + vec2(0.0, px.y)) * 0.16;
    c += texture(TEXTURE, UV - vec2(0.0, px.y)) * 0.16;
    COLOR = c * COLOR;
}
"""
	logo_material = ShaderMaterial.new()
	logo_material.shader = logo_shader
	logo_material.set_shader_parameter("blur_amount", 8.0)
	logo_img.material = logo_material

	# White flash over the ident at the stamp impact.
	flash = ColorRect.new()
	flash.color = PAPER
	flash.modulate.a = 0.0
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.z_index = 40
	_full_rect(flash)
	add_child(flash)

	# Animated film grain above the composition.
	var grain: ColorRect = ColorRect.new()
	grain.color = Color.WHITE
	grain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grain.z_index = 50
	_full_rect(grain)
	add_child(grain)
	var grain_shader := Shader.new()
	grain_shader.code = """
shader_type canvas_item;
uniform float time_seed = 0.0;
uniform float strength : hint_range(0.0, 0.12) = 0.05;
float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32 + time_seed);
    return fract(p.x * p.y);
}
void fragment() {
    float n = hash21(floor(FRAGCOORD.xy * 0.55));
    COLOR = vec4(vec3(n), strength);
}
"""
	grain_material = ShaderMaterial.new()
	grain_material.shader = grain_shader
	grain_material.set_shader_parameter("strength", 0.05)
	grain.material = grain_material

	# Same continuation cue as the HTML version.
	skip_label = Label.new()
	skip_label.text = "●  CLICK OR PRESS ANY KEY TO CONTINUE"
	skip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skip_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	skip_label.add_theme_font_size_override("font_size", 12)
	skip_label.add_theme_color_override("font_color", PAPER)
	skip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	skip_label.anchor_left = 0.5
	skip_label.anchor_right = 0.5
	skip_label.anchor_top = 1.0
	skip_label.anchor_bottom = 1.0
	skip_label.offset_left = -230.0
	skip_label.offset_right = 230.0
	skip_label.offset_top = -62.0
	skip_label.offset_bottom = -26.0
	skip_label.modulate.a = 0.0
	skip_label.z_index = 60
	add_child(skip_label)

func _process(delta: float) -> void:
	if leaving:
		fade_elapsed += delta
		var fade_t: float = clampf(fade_elapsed / FADE_OUT_LENGTH, 0.0, 1.0)
		modulate.a = 1.0 - fade_t
		if fade_t >= 1.0:
			get_tree().change_scene_to_file(NEXT_SCENE)
		return

	elapsed += delta
	grain_material.set_shader_parameter("time_seed", elapsed * 37.0)
	_animate_logo(elapsed)
	_animate_flash(elapsed)
	_animate_splats(elapsed)
	_animate_shake(elapsed)
	_animate_skip(elapsed)

func _animate_logo(t: float) -> void:
	var alpha: float = 0.0
	var scale_value: float = 1.6
	var blur_value: float = 8.0

	if t < 0.936:
		alpha = 0.0
		scale_value = 1.6
		blur_value = 8.0
	elif t < 1.040:
		var p: float = _smooth01((t - 0.936) / 0.104)
		alpha = p
		scale_value = lerpf(1.6, 0.92, p)
		blur_value = lerpf(8.0, 0.0, p)
	elif t < 1.196:
		var p: float = _smooth01((t - 1.040) / 0.156)
		alpha = 1.0
		scale_value = lerpf(0.92, 1.03, p)
		blur_value = 0.0
	elif t < 1.352:
		var p: float = _smooth01((t - 1.196) / 0.156)
		alpha = 1.0
		scale_value = lerpf(1.03, 1.0, p)
		blur_value = 0.0
	else:
		alpha = 1.0
		blur_value = 0.0
		if t >= 2.6:
			var pulse_phase: float = (t - 2.6) / 3.2 * TAU
			scale_value = 1.0 + 0.0075 - cos(pulse_phase) * 0.0075
		else:
			scale_value = 1.0

	logo_img.modulate.a = alpha
	logo_img.scale = Vector2.ONE * scale_value
	logo_material.set_shader_parameter("blur_amount", blur_value)

func _animate_flash(t: float) -> void:
	var alpha: float = 0.0
	if t >= 0.988 and t < 1.040:
		alpha = lerpf(0.0, 0.90, _smooth01((t - 0.988) / 0.052))
	elif t >= 1.040 and t < 1.196:
		alpha = lerpf(0.90, 0.0, _smooth01((t - 1.040) / 0.156))
	flash.modulate.a = alpha

func _animate_splats(t: float) -> void:
	var alpha: float = 0.0
	var scale_value: float = 0.4
	if t >= 0.988 and t < 1.196:
		var p: float = _smooth01((t - 0.988) / 0.208)
		alpha = lerpf(0.0, 0.06, p)
		scale_value = lerpf(0.4, 1.05, p)
	elif t >= 1.196:
		alpha = 0.06
		var settle: float = _smooth01(clampf((t - 1.196) / 1.404, 0.0, 1.0))
		scale_value = lerpf(1.05, 1.0, settle)

	var splats: Array[Panel] = [splat_one, splat_two]
	for splat in splats:
		splat.modulate.a = alpha
		splat.scale = Vector2.ONE * scale_value

func _animate_shake(t: float) -> void:
	var offset := Vector2.ZERO
	if t >= 1.014 and t < 1.053:
		offset = _segment_vec(t, 1.014, 1.053, Vector2(-6.0, 3.0), Vector2(5.0, -4.0))
	elif t >= 1.053 and t < 1.092:
		offset = _segment_vec(t, 1.053, 1.092, Vector2(5.0, -4.0), Vector2(-3.0, 2.0))
	elif t >= 1.092 and t < 1.131:
		offset = _segment_vec(t, 1.092, 1.131, Vector2(-3.0, 2.0), Vector2(2.0, -2.0))
	elif t >= 1.131 and t < 1.170:
		offset = _segment_vec(t, 1.131, 1.170, Vector2(2.0, -2.0), Vector2.ZERO)
	logo_group.position = base_group_position + offset

func _animate_skip(t: float) -> void:
	if t < 3.1:
		skip_label.modulate.a = 0.0
		return
	var fade_in: float = _smooth01(clampf((t - 3.1) / 0.8, 0.0, 1.0))
	var blink: float = 0.82 + sin((t - 3.1) * TAU / 1.4) * 0.18
	skip_label.modulate.a = 0.45 * fade_in * blink

func _input(event: InputEvent) -> void:
	if leaving:
		return
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo:
			_proceed()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed:
			_proceed()
			get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton:
		var joy_event := event as InputEventJoypadButton
		if joy_event.pressed:
			_proceed()
			get_viewport().set_input_as_handled()

func _proceed() -> void:
	if leaving:
		return
	leaving = true
	fade_elapsed = 0.0

func _make_splat(splat_size: Vector2, splat_position: Vector2) -> Panel:
	var panel := Panel.new()
	panel.position = splat_position
	panel.size = splat_size
	panel.pivot_offset = splat_size * 0.5
	panel.scale = Vector2.ONE * 0.4
	panel.modulate.a = 0.0
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = PAPER
	style.corner_radius_top_left = 999
	style.corner_radius_top_right = 999
	style.corner_radius_bottom_left = 999
	style.corner_radius_bottom_right = 999
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _full_rect(control: Control) -> void:
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 1.0
	control.anchor_bottom = 1.0
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0

func _smooth01(value: float) -> float:
	var x: float = clampf(value, 0.0, 1.0)
	return x * x * (3.0 - 2.0 * x)

func _segment_vec(t: float, start_time: float, end_time: float, from: Vector2, to: Vector2) -> Vector2:
	var p: float = _smooth01((t - start_time) / (end_time - start_time))
	return from.lerp(to, p)
