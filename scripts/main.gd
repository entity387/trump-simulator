extends Node3D

# ============================================================
# TRUMP SIMULATOR — DESKTOP EDITION
# v1.1.0 — final completion and presentation pass
#
# The launch button remains the core gameplay action.
# Everything else exists to interrupt, distract, or pressure
# the player while they try to keep launching.
# ============================================================

const VERSION := "1.1.0"
const SAVE_PATH := "user://savegame.json"
const SETTINGS_PATH := "user://settings.json"

const MENU_BACKGROUND_HOLD_SECONDS := 7.0
const MENU_BACKGROUND_FADE_OUT_SECONDS := 0.42
const MENU_BACKGROUND_FADE_IN_SECONDS := 0.55

# Secret developer access. This sequence is only accepted on the unobstructed home menu.
const DEV_SEQUENCE := [
	KEY_UP, KEY_UP, KEY_DOWN, KEY_DOWN,
	KEY_LEFT, KEY_RIGHT, KEY_LEFT, KEY_RIGHT,
	KEY_B, KEY_A, KEY_ENTER,
]
const DEV_PIN := "1787"

const STAGES := [
	{"min": 0, "name": "THE BUTTON"},
	{"min": 10000, "name": "ENEMIES WAKE UP"},
	{"min": 50000, "name": "THE PHONE"},
	{"min": 200000, "name": "MULTITASKING"},
	{"min": 650000, "name": "CRISIS MANAGEMENT"},
	{"min": 1400000, "name": "ABSOLUTE CHAOS"},
]

const DIFFICULTIES := [
	{"name": "Intern", "enemy": 0.55, "events": 0.55, "heat": 0.65, "chaos": 0.65, "description": "A calmer first campaign. Longer breathing room, slower pressure and fewer overlapping problems.", "summary": "EVENTS: LOW   REACTION TIME: LONG   PENALTIES: LIGHT"},
	{"name": "President", "enemy": 1.0, "events": 1.0, "heat": 1.0, "chaos": 1.0, "description": "The intended Trump Simulator campaign experience. Balanced chaos and the recommended first playthrough.", "summary": "EVENTS: NORMAL   REACTION TIME: NORMAL   PENALTIES: NORMAL"},
	{"name": "Commander in Chief", "enemy": 1.35, "events": 1.35, "heat": 1.25, "chaos": 1.25, "description": "Problems arrive faster and overlap more often. You will need to keep clicking while reacting quickly.", "summary": "EVENTS: HIGH   REACTION TIME: SHORTER   PENALTIES: HIGH"},
	{"name": "DEFCON 1", "enemy": 1.7, "events": 1.75, "heat": 1.5, "chaos": 1.55, "description": "Very little downtime. Calls, paperwork, threats and crises regularly stack on top of each other.", "summary": "EVENTS: VERY HIGH   REACTION TIME: SHORT   PENALTIES: SEVERE"},
	{"name": "Presidential Nightmare", "enemy": 2.25, "events": 2.35, "heat": 1.85, "chaos": 2.0, "description": "Several systems demand attention almost constantly. Built for players who already know every mechanic.", "summary": "EVENTS: EXTREME   REACTION TIME: TINY   OVERLAP: EXTREME"},
	{"name": "IMPOSSIBLE", "enemy": 3.2, "events": 3.5, "heat": 2.4, "chaos": 3.0, "description": "Intentionally ridiculous and unfair. The campaign throws almost everything at you with minimal breathing room.", "summary": "EVENTS: MAXIMUM   REACTION TIME: BRUTAL   GOOD LUCK: NO"},
]

# Campaign levels are linear. There is no normal level-select screen.
const CAMPAIGN_LEVELS := [
	{"id":"oval_office", "name":"OVAL OFFICE", "visual":"oval_office", "goal":10000, "stage_floor":1, "stage_ceiling":4, "enemy":0.85, "events":0.80, "heat":0.85, "chaos":0.75, "gimmick_interval":0.0, "button":[550,533], "phone":[175,490], "paper":[880,495], "emergency":[1000,500], "alarm":[405,515], "monitor":[505,321], "intro":"TRUMP STARTS AT THE OVAL OFFICE.", "intro_message":"Welcome to the Oval Office.", "gimmick":"Learn the button, threats, calls and paperwork."},
	{"id":"putins_office", "name":"PUTIN'S OFFICE", "visual":"putins_office", "goal":30000, "stage_floor":2, "stage_ceiling":4, "enemy":1.00, "events":1.10, "heat":0.95, "chaos":0.90, "gimmick_interval":18.0, "button":[550,533], "phone":[855,535], "paper":[90,545], "emergency":[1020,520], "alarm":[405,535], "monitor":[70,315], "intro":"TRUMP ARRIVES IN MOSCOW. SOMEHOW.", "intro_message":"He said not to touch anything.", "gimmick":"Russian intel and extra calls keep interrupting the desk."},
	{"id":"unicef_office", "name":"UNICEF OFFICE", "visual":"unicef_office", "goal":75000, "stage_floor":2, "stage_ceiling":5, "enemy":0.95, "events":1.18, "heat":0.95, "chaos":1.00, "gimmick_interval":16.0, "button":[550,533], "phone":[865,535], "paper":[95,545], "emergency":[1015,520], "alarm":[405,535], "monitor":[90,310], "intro":"TRUMP VISITS THE UNICEF OFFICE. THE BUTTON CAME TOO.", "intro_message":"Please try to look helpful.", "gimmick":"Staff requests and paperwork arrive constantly."},
	{"id":"un_meeting", "name":"UN MEETING ROOM", "visual":"un_meeting", "goal":150000, "stage_floor":3, "stage_ceiling":5, "enemy":1.05, "events":1.25, "heat":1.00, "chaos":1.12, "gimmick_interval":14.0, "button":[550,536], "phone":[880,538], "paper":[90,545], "emergency":[1020,520], "alarm":[405,535], "monitor":[505,300], "intro":"TRUMP TAKES HIS SEAT AT THE UN MEETING.", "intro_message":"Diplomacy is strongly encouraged.", "gimmick":"Delegates keep talking while the office systems keep demanding attention."},
	{"id":"air_force_one", "name":"AIR FORCE ONE", "visual":"air_force_one", "goal":275000, "stage_floor":3, "stage_ceiling":5, "enemy":1.10, "events":1.18, "heat":1.08, "chaos":1.10, "gimmick_interval":12.0, "button":[550,533], "phone":[865,535], "paper":[90,545], "emergency":[1015,520], "alarm":[405,535], "monitor":[75,320], "intro":"TRUMP BOARDS AIR FORCE ONE.", "intro_message":"Please remain seated. Especially you.", "gimmick":"Turbulence periodically shakes the entire desk."},
	{"id":"rally_backstage", "name":"CAMPAIGN RALLY BACKSTAGE", "visual":"rally_backstage", "goal":450000, "stage_floor":3, "stage_ceiling":6, "enemy":1.12, "events":1.28, "heat":1.08, "chaos":1.22, "gimmick_interval":13.0, "button":[550,533], "phone":[95,535], "paper":[885,545], "emergency":[1020,520], "alarm":[405,535], "monitor":[875,300], "intro":"TRUMP HEADS BACKSTAGE AT THE RALLY.", "intro_message":"They're chanting your name. Probably.", "gimmick":"Crowd surges and staff interruptions push chaos upward."},
	{"id":"g20_summit", "name":"G20 WORLD LEADERS SUMMIT", "visual":"g20_summit", "goal":700000, "stage_floor":4, "stage_ceiling":6, "enemy":1.18, "events":1.35, "heat":1.12, "chaos":1.25, "gimmick_interval":12.0, "button":[550,536], "phone":[880,538], "paper":[90,545], "emergency":[1020,520], "alarm":[405,535], "monitor":[505,300], "intro":"TRUMP TAKES THE UNITED STATES SEAT AT THE G20.", "intro_message":"Try to remember everyone's name.", "gimmick":"World-leader requests arrive faster than anyone can answer them."},
	{"id":"emergency_bunker", "name":"EMERGENCY BUNKER", "visual":"emergency_bunker", "goal":1000000, "stage_floor":5, "stage_ceiling":6, "enemy":1.35, "events":1.32, "heat":1.18, "chaos":1.32, "gimmick_interval":10.0, "button":[550,533], "phone":[865,535], "paper":[90,545], "emergency":[1015,520], "alarm":[405,535], "monitor":[70,300], "intro":"TRUMP IS MOVED TO THE EMERGENCY BUNKER.", "intro_message":"If you're here, something has already gone wrong.", "gimmick":"Security alerts and system surges leave almost no downtime."},
	{"id":"golf_club", "name":"GOLF CLUB OFFICE", "visual":"golf_club", "goal":1400000, "stage_floor":4, "stage_ceiling":6, "enemy":1.15, "events":1.38, "heat":1.05, "chaos":1.18, "gimmick_interval":11.0, "button":[550,533], "phone":[875,535], "paper":[90,545], "emergency":[1020,520], "alarm":[405,535], "monitor":[75,315], "intro":"TRUMP ATTEMPTS TO WORK FROM THE GOLF CLUB.", "intro_message":"Finally. A completely normal workplace.", "gimmick":"Calls, staff and tee-time distractions refuse to stop."},
	{"id":"presidential_nightmare", "name":"PRESIDENTIAL NIGHTMARE", "visual":"presidential_nightmare", "goal":2000000, "stage_floor":6, "stage_ceiling":6, "enemy":1.55, "events":1.55, "heat":1.28, "chaos":1.55, "gimmick_interval":8.0, "button":[550,533], "phone":[875,535], "paper":[90,545], "emergency":[1020,520], "alarm":[405,535], "monitor":[505,290], "intro":"TRUMP ENTERS THE PRESIDENTIAL NIGHTMARE.", "intro_message":"Good luck, Mr President.", "gimmick":"Every system from the campaign can collide at once."},
]

const UPGRADES := [
	{"id": "reinforced_button", "name": "Reinforced Button", "cost": 100, "power": 1},
	{"id": "gold_actuator", "name": "Gold-Plated Actuator", "cost": 350, "power": 3},
	{"id": "executive_authority", "name": "Executive Launch Authority", "cost": 1200, "power": 8},
	{"id": "desk_reinforcement", "name": "Desk Reinforcement", "cost": 4000, "power": 20},
	{"id": "presidential_hydraulics", "name": "Presidential Hydraulics", "cost": 12000, "power": 50},
]

const AMBIENT_LINES := [
	"That's a tremendous button.",
	"Nobody has ever pressed a button like that.",
	"We're doing very, very well.",
	"Why is this thing making that noise?",
	"That's a beautiful number.",
	"We're going to need more buttons.",
	"Where's my phone?",
	"Oh. It's right there.",
]

const CALLERS := ["KIM", "PUTIN", "XI", "LIL TIMMY"]

const CALL_SCRIPTS := {
	"KIM": [
		"Hello, Donald. I have also found a button.",
		"Mine is red too. Very nice.",
		"I pressed it once. Everyone started yelling.",
		"Are we competing? I think we are competing.",
		"This is becoming a competition.",
	],
	"PUTIN": [
		"I have prepared a very short presentation.",
		"It is only forty-seven slides.",
		"I think you should stop funding Ukraine.",
		"You could spend the money on something much more useful.",
		"Like a very large desk.",
		"Or perhaps another button. You like buttons, yes?",
	],
	"XI": [
		"你好，唐纳德。",
		"我不知道你为什么一直按那个按钮。",
		"但是看起来很忙。",
		"你应该休息一下。",
		"冰淇淋。非常好。",
		"好了，我还有事情要做。再见。",
	],
	"LIL TIMMY": [
		"Hey!",
		"What are you doing?",
		"Why is there a giant red button on your desk?",
		"It says launch bombs.",
		"That's weird.",
		"Anyway, today at school we learned about fractions.",
		"I don't really understand fractions.",
		"Okay bye.",
	],
}

# ----------------------------
# Persistent game state
# ----------------------------
var bombs := 0
var lifetime_bombs := 0
var power := 1
var stage := 1
var difficulty_index := 1
var subtitles_enabled := true
var fullscreen_enabled := false
var purchased_upgrades: Array[String] = []
var current_level_index: int = 0
var level_launches: int = 0
var campaign_complete := false

# ----------------------------
# Runtime game state
# ----------------------------
var enemy_pressure := 0.0
var heat := 0.0
var approval := 50.0
var chaos := 0.0

var game_started := false
var paused := false
var game_over := false
var overheated := false
var button_busy := false

var call_active := false
var call_answered := false
var active_caller := ""
var active_call_line := ""
var call_line_index: int = 0
var call_locks_button := false
var call_seconds_left := 0
var ambient_resume_after_msec: int = 0

var paperwork_active := false
var paper_seconds_left := 0

var crisis_active := false
var crisis_seconds_left := 0

var alarm_active := false
var alarm_seconds_left := 0

var last_launch_time := 0.0
var last_stage_seen := 1
var autosave_accum := 0.0
var level_transition_active := false
var level_intro_active := false
var level_intro_token: int = 0
var level_gimmick_accum := 0.0

# Developer-session state never writes over the player's normal campaign save.
var dev_sequence_index: int = 0
var dev_session_active := false
var dev_access_unlocked := false
var dev_minimized := false
var dev_god_mode := false
var dev_random_events_enabled := true
var dev_freeze_simulation := false
var dev_debug_overlay_enabled := false
var dev_runtime_snapshot: Dictionary = {}
var dev_last_tool_status := "READY"
var dev_restore_mouse_capture := false

var rng := RandomNumberGenerator.new()

# ----------------------------
# 3D nodes
# ----------------------------
var main_camera: Camera3D
var launch_button: StaticBody3D
var launch_button_mesh: Node3D
var button_start_y := 0.0

var phone_body: StaticBody3D
var phone_start_rot := Vector3.ZERO

var emergency_phone: StaticBody3D
var emergency_phone_start_rot := Vector3.ZERO

var paper_body: StaticBody3D
var paper_mesh: MeshInstance3D
var paper_home := Vector3.ZERO

var crisis_folder: StaticBody3D
var crisis_folder_mesh: MeshInstance3D
var crisis_home := Vector3.ZERO

var alarm_switch: StaticBody3D
var alarm_switch_mesh: MeshInstance3D

# ----------------------------
# Diegetic 3D UI nodes
# ----------------------------
var command_monitor_label: Label3D
var threat_monitor_label: Label3D
var approval_monitor_label: Label3D
var chaos_monitor_label: Label3D
var heat_display_label: Label3D
var phone_display_label: Label3D
var paper_display_label: Label3D
var crisis_display_label: Label3D
var alarm_display_label: Label3D
var upgrade_terminal_label: Label3D
var upgrade_terminal: StaticBody3D
var upgrade_panel_open := false
var world_ready := false
var world_load_step := "BOOT"

# ----------------------------
# UI nodes
# ----------------------------
var layer: CanvasLayer
var hud_root: Control
var menu_backdrop: ColorRect
var transition_fade: ColorRect
var screen_transition_active := false
var menu_scene_fade: ColorRect
var menu_background_arena: Node3D
var menu_background_entries: Array[Dictionary] = []
var menu_background_index := 0
var menu_background_elapsed := 0.0
var menu_background_transition_active := false
var menu_background_cycle_active := false
var main_menu: Panel
var pause_menu: Panel
var settings_menu: Panel
var credits_menu: Panel
var credits_title_label: Label
var credits_body: RichTextLabel
var credits_license_button: Button
var credits_showing_licenses := false

var multiplayer_menu: Panel
var multiplayer_role_menu: Panel
var multiplayer_role_title: Label
var multiplayer_role_note: Label
var multiplayer_hud: Panel
var multiplayer_hud_title: Label
var multiplayer_hud_role: Label
var multiplayer_arena: Node3D
var multiplayer_selected_mode: String = ""
var online_multiplayer_ui: Control
var lan_match_session := false

var update_panel: Panel
var update_title_label: Label
var update_version_label: Label
var update_notes_label: RichTextLabel
var update_status_label: Label
var update_now_button: Button
var update_later_button: Button
var pending_update_info: Dictionary = {}

var game_over_panel: Panel
var difficulty_select_panel: Panel
var difficulty_description_label: Label
var difficulty_summary_label: Label
var difficulty_choice_buttons: Array[Button] = []
var level_complete_panel: Panel
var level_complete_title: Label
var level_complete_body: Label
var level_complete_button: Button
var level_intro_root: Control
var level_intro_bg: ColorRect
var level_intro_title: Label
var level_intro_message: Label
var mirror_overlay: Control
var mirror_image: TextureRect

var dev_code_panel: Panel
var dev_code_input: LineEdit
var dev_code_status: Label
var dev_panel: Panel
var dev_map_preview: Panel
var dev_map_preview_texture: TextureRect
var dev_minimized_button: Button
var dev_tabs: TabContainer
var dev_overview_label: RichTextLabel
var dev_tool_status_label: Label
var dev_debug_overlay: Panel
var dev_debug_overlay_label: Label
var dev_multiplayer_status_label: Label
var dev_save_status_label: Label
var dev_god_button: Button
var dev_events_button: Button
var dev_freeze_button: Button
var dev_overlay_button: Button

var bomb_label: Label
var power_label: Label
var stage_label: Label
var difficulty_hud_label: Label
var status_label: Label
var subtitle_label: Label
var caller_label: Label
var caller_timer_label: Label

var enemy_bar: ProgressBar
var heat_bar: ProgressBar
var approval_bar: ProgressBar
var chaos_bar: ProgressBar

var continue_button: Button
var difficulty_button: Button
var subtitle_toggle_button: Button
var fullscreen_toggle_button: Button
var startup_label: Label
var fallback_bg: ColorRect
var loading_root: Control
var loading_panel: Panel
var loading_bar: ProgressBar
var loading_status_label: Label
var loading_percent_label: Label
var loading_tip_label: Label

var upgrade_panel: Panel
var upgrade_buttons: Array[Button] = []

# ----------------------------
# Visual reboot presentation
# ----------------------------
var visual_root: Control
var visual_background: TextureRect
var visual_map_decor_root: Control
var visual_button: TextureButton
var visual_phone: TextureButton
var visual_paper: TextureButton
var visual_emergency_phone: TextureButton
var visual_alarm_switch: TextureButton
var visual_upgrade_button: Button

var visual_main_monitor: Label
var visual_phone_status: Label
var visual_threat_card: Panel
var visual_threat_label: Label
var visual_approval_card: Panel
var visual_approval_label: Label
var visual_chaos_card: Panel
var visual_chaos_label: Label
var visual_heat_label: Label
var visual_level_card: Panel
var visual_level_label: Label

var visual_button_normal_tex: Texture2D
var visual_button_pressed_tex: Texture2D
var visual_button_hot_tex: Texture2D
var visual_phone_normal_tex: Texture2D
var visual_phone_ring_tex: Texture2D
var visual_paper_normal_tex: Texture2D
var visual_paper_hover_tex: Texture2D

var visual_paper_home := Vector2(880.0, 495.0)
var visual_phone_home := Vector2(175.0, 490.0)
var visual_emergency_home := Vector2(1000.0, 500.0)
var visual_root_home := Vector2.ZERO

# ----------------------------
# Timers
# ----------------------------
var event_timer: Timer
var call_ring_timer: Timer
var call_duration_timer: Timer
var call_line_timer: Timer
var paper_timer: Timer
var crisis_timer: Timer
var alarm_timer: Timer

func _ready() -> void:
	rng.randomize()
	get_viewport().physics_object_picking = true
	last_launch_time = Time.get_ticks_msec() / 1000.0
	print("[Trump Simulator] v", VERSION, " startup")
	_load_settings()
	_apply_window_mode()

	# Build screen-space UI first so a 3D startup failure can never leave
	# the player staring at an unexplained blank/grey engine window.
	_build_ui()
	_build_timers()
	if not UpdateManager.update_available.is_connected(_on_update_available):
		UpdateManager.update_available.connect(_on_update_available)
	if not UpdateManager.update_status.is_connected(_on_update_status):
		UpdateManager.update_status.connect(_on_update_status)
	_update_menu_buttons()
	_set_startup_step("STARTING VISUAL REBOOT...")
	call_deferred("_build_world_sequence")

func _build_world_sequence() -> void:
	# Fixed seated visual composition. Keep startup deterministic and simple.
	_update_loading_screen(0, "Starting the Desktop Edition...", "TIP: Click the red button — it is always the priority.")
	_set_startup_step("0/8  STARTING THE DESKTOP EDITION")
	await get_tree().create_timer(0.07).timeout

	_update_loading_screen(1, "Opening the Oval Office...", "TIP: You are seated behind the desk in this presentation.")
	_set_startup_step("1/8  OPENING THE OVAL OFFICE")
	await get_tree().create_timer(0.07).timeout

	_update_loading_screen(2, "Preparing the desk...", "TIP: The phone and paperwork are physical clickable desk objects.")
	_set_startup_step("2/8  PREPARING THE DESK")
	await get_tree().create_timer(0.07).timeout

	_update_loading_screen(3, "Connecting launch control...", "TIP: There is no Space-bar launch in the Desktop Edition.")
	_set_startup_step("3/8  CONNECTING LAUNCH CONTROL")
	await get_tree().create_timer(0.07).timeout

	_update_loading_screen(4, "Connecting the desk phone...", "TIP: Calls become active later in the run.")
	_set_startup_step("4/8  CONNECTING THE DESK PHONE")
	await get_tree().create_timer(0.07).timeout

	_update_loading_screen(5, "Preparing paperwork systems...", "TIP: Urgent paperwork slides onto the desk when it needs attention.")
	_set_startup_step("5/8  PREPARING PAPERWORK SYSTEMS")
	await get_tree().create_timer(0.07).timeout

	_update_loading_screen(6, "Starting status displays...", "TIP: New pressure systems appear as the stages progress.")
	_set_startup_step("6/8  STARTING STATUS DISPLAYS")
	await get_tree().create_timer(0.07).timeout

	_update_loading_screen(7, "Connecting gameplay systems...", "TIP: Upgrades do not pause the office.")
	_set_startup_step("7/8  CONNECTING GAMEPLAY SYSTEMS")
	await get_tree().create_timer(0.07).timeout

	_update_loading_screen(8, "Campaign maps ready.", "TIP: The campaign begins in the Oval Office and progresses automatically.")
	_set_startup_step("8/8  CAMPAIGN READY")
	world_ready = true
	if visual_root != null:
		visual_root.visible = true
	_refresh_stage_unlocks()
	_update_ui()

	await get_tree().create_timer(0.20).timeout
	_set_startup_step("VISUAL REBOOT READY — SELECT NEW GAME")
	await _finish_loading_screen()
	print("[Trump Simulator] visual reboot ready")

func _set_startup_step(step_text: String) -> void:
	world_load_step = step_text
	print("[Trump Simulator] ", step_text)
	if startup_label != null:
		startup_label.text = step_text

func _process(delta: float) -> void:
	_process_menu_background_cycle(delta)
	_refresh_menu_backdrop()
	_refresh_dev_runtime_ui()
	_refresh_dev_launcher_visibility()
	if not world_ready or not game_started or paused or game_over or level_intro_active:
		return

	autosave_accum += delta
	if autosave_accum >= 15.0:
		autosave_accum = 0.0
		_save_game()

	if dev_freeze_simulation:
		_update_ui()
		return

	var diff: Dictionary = DIFFICULTIES[difficulty_index]
	var level_data: Dictionary = _current_level_data()
	var map_enemy: float = float(level_data.get("enemy", 1.0))
	var map_chaos: float = float(level_data.get("chaos", 1.0))

	level_gimmick_accum += delta
	var gimmick_interval: float = float(level_data.get("gimmick_interval", 0.0))
	if gimmick_interval > 0.0 and level_gimmick_accum >= gimmick_interval:
		level_gimmick_accum = 0.0
		_trigger_level_gimmick()

	# Core pressure: once enemies wake up, not pressing the button becomes costly.
	if stage >= 2:
		var now := Time.get_ticks_msec() / 1000.0
		var idle := now - last_launch_time
		var base_rise := 0.16
		if idle > 1.1:
			base_rise = 1.0
		enemy_pressure += base_rise * float(stage) * float(diff["enemy"]) * map_enemy * delta

		if enemy_pressure >= 100.0:
			enemy_pressure = 68.0
			approval -= 8.0
			chaos += 11.0
			bombs = max(0, bombs - max(10, int(float(bombs) * 0.04)))
			_show_status("INCOMING ATTACK — GET BACK TO THE BUTTON!", 2.2)
			_camera_shake(0.18, 0.55)

	# Button heat only becomes a concern after multitasking begins.
	if stage >= 4 and not overheated:
		heat = max(0.0, heat - 11.0 * delta)

	# Late stages add passive chaos.
	if stage >= 5:
		chaos += 0.18 * float(stage) * float(diff["chaos"]) * map_chaos * delta
	else:
		chaos = max(0.0, chaos - 0.8 * delta)

	enemy_pressure = clamp(enemy_pressure, 0.0, 100.0)
	heat = clamp(heat, 0.0, 100.0)
	approval = clamp(approval, 0.0, 100.0)
	chaos = clamp(chaos, 0.0, 100.0)

	if approval <= 0.0:
		_trigger_game_over("APPROVAL COLLAPSED")
	elif chaos >= 100.0:
		_trigger_game_over("THE OFFICE DESCENDED INTO TOTAL CHAOS")

	_update_ui()

func _input(event: InputEvent) -> void:
	# Use _input instead of _unhandled_input so menu focus navigation cannot swallow
	# the secret arrow-key sequence before we see it.
	if not world_ready:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event: InputEventKey = event as InputEventKey
		if dev_access_unlocked and key_event.keycode == KEY_F12:
			if (dev_panel != null and dev_panel.visible) or (dev_map_preview != null and dev_map_preview.visible):
				_minimize_dev_panel()
			else:
				_open_dev_panel()
			get_viewport().set_input_as_handled()
			return
		if _dev_sequence_allowed():
			var was_last_key: bool = (
				dev_sequence_index == DEV_SEQUENCE.size() - 1
				and int(key_event.keycode) == int(DEV_SEQUENCE[dev_sequence_index])
			)
			_process_dev_sequence_key(int(key_event.keycode))
			if was_last_key:
				# Prevent the final ENTER from activating whichever home-menu button
				# currently has keyboard focus.
				get_viewport().set_input_as_handled()
		else:
			dev_sequence_index = 0

func _unhandled_input(event: InputEvent) -> void:
	if not world_ready:
		return
	if level_intro_active:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode == KEY_U:
			_toggle_upgrade_terminal()
		elif key_event.keycode == KEY_ESCAPE:
			if mirror_overlay != null and mirror_overlay.visible:
				_close_mirror()
			elif level_complete_panel != null and level_complete_panel.visible:
				return
			elif difficulty_select_panel != null and difficulty_select_panel.visible:
				_close_new_game_difficulty()
			elif dev_map_preview != null and dev_map_preview.visible:
				_close_dev_map_preview()
			elif dev_panel != null and dev_panel.visible:
				_close_dev_panel()
			elif dev_code_panel != null and dev_code_panel.visible:
				_close_dev_code_prompt()
			elif upgrade_panel_open:
				_close_upgrade_terminal()
			else:
				_toggle_pause()

func _dev_sequence_allowed() -> bool:
	if dev_access_unlocked:
		return false
	if main_menu == null or not main_menu.visible:
		return false
	if settings_menu != null and settings_menu.visible:
		return false
	if credits_menu != null and credits_menu.visible:
		return false
	if dev_code_panel != null and dev_code_panel.visible:
		return false
	if dev_panel != null and dev_panel.visible:
		return false
	if dev_map_preview != null and dev_map_preview.visible:
		return false
	if difficulty_select_panel != null and difficulty_select_panel.visible:
		return false
	if level_complete_panel != null and level_complete_panel.visible:
		return false
	return not game_started

func _process_dev_sequence_key(keycode: int) -> void:
	if DEV_SEQUENCE.is_empty():
		return

	var expected_key: int = int(DEV_SEQUENCE[dev_sequence_index])
	if keycode == expected_key:
		dev_sequence_index += 1
		if dev_sequence_index >= DEV_SEQUENCE.size():
			dev_sequence_index = 0
			_open_dev_code_prompt()
	else:
		# Allow a fresh sequence to begin immediately if the wrong key is itself UP.
		dev_sequence_index = 1 if keycode == DEV_SEQUENCE[0] else 0

func _open_dev_code_prompt() -> void:
	if dev_code_panel == null or dev_code_input == null:
		return
	dev_code_input.text = ""
	dev_code_status.text = "ENTER ACCESS CODE"
	dev_code_panel.visible = true
	dev_code_input.grab_focus()

func _submit_dev_code(_submitted_text: String = "") -> void:
	if dev_code_input == null:
		return
	if dev_code_input.text.strip_edges() == DEV_PIN:
		dev_code_input.text = ""
		dev_code_panel.visible = false
		dev_access_unlocked = true
		dev_minimized = false
		_open_dev_panel()
	else:
		dev_code_input.text = ""
		dev_code_status.text = "ACCESS DENIED"
		dev_code_input.grab_focus()

func _close_dev_code_prompt() -> void:
	if dev_code_panel != null:
		dev_code_panel.visible = false
	if dev_code_input != null:
		dev_code_input.text = ""
	dev_sequence_index = 0

func _open_dev_panel() -> void:
	if not dev_access_unlocked:
		if not _home_menu_context():
			return
	if dev_panel != null:
		dev_panel.visible = true
	dev_restore_mouse_capture = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if dev_restore_mouse_capture:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	dev_minimized = false
	dev_sequence_index = 0
	_refresh_dev_launcher_visibility()
	_refresh_dev_runtime_ui()
	_refresh_menu_backdrop()

func _close_dev_panel() -> void:
	_minimize_dev_panel()

func _minimize_dev_panel() -> void:
	if dev_panel != null:
		dev_panel.visible = false
	if dev_map_preview != null:
		dev_map_preview.visible = false
	dev_minimized = dev_access_unlocked
	dev_sequence_index = 0
	if dev_restore_mouse_capture and multiplayer_arena != null and is_instance_valid(multiplayer_arena):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	dev_restore_mouse_capture = false
	_refresh_dev_launcher_visibility()
	_refresh_menu_backdrop()

func _home_menu_context() -> bool:
	return main_menu != null and main_menu.visible and not game_started

func _open_dev_map_preview() -> void:
	if not dev_access_unlocked and not _home_menu_context():
		return
	if dev_panel != null:
		dev_panel.visible = false
	if dev_map_preview != null:
		dev_map_preview.visible = true
	dev_minimized = false
	_refresh_dev_launcher_visibility()

func _close_dev_map_preview() -> void:
	if dev_map_preview != null:
		dev_map_preview.visible = false
	if dev_access_unlocked and dev_panel != null:
		dev_panel.visible = true
	dev_minimized = false
	_refresh_dev_launcher_visibility()

func _dev_start_stage(target_stage: int) -> void:
	if not world_ready:
		_dev_set_tool_status("WORLD IS STILL LOADING")
		return
	var safe_stage: int = clampi(target_stage, 1, STAGES.size())
	_dev_mark_modified("STAGE OVERRIDE")
	if not game_started:
		_start_new_game()
	stage = safe_stage
	last_stage_seen = safe_stage
	enemy_pressure = 0.0
	heat = 0.0
	approval = 75.0
	chaos = 0.0
	overheated = false
	_set_button_hot(false)
	_reset_runtime_events()
	_refresh_stage_unlocks()
	_show_status("STAGE %d — %s" % [safe_stage, str(STAGES[safe_stage - 1]["name"])], 2.0)
	_update_ui()
	_minimize_dev_panel()

func _dev_start_level(target_level: int) -> void:
	if not world_ready:
		_dev_set_tool_status("WORLD IS STILL LOADING")
		return
	var safe_level: int = clampi(target_level, 0, CAMPAIGN_LEVELS.size() - 1)
	_dev_mark_modified("MAP OVERRIDE")
	if multiplayer_arena != null and is_instance_valid(multiplayer_arena):
		multiplayer_arena.queue_free()
		multiplayer_arena = null
		if multiplayer_hud != null:
			multiplayer_hud.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if not game_started:
		_start_new_game()
	else:
		paused = false
		game_over = false
		get_tree().paused = false
		if game_over_panel != null:
			game_over_panel.visible = false
		_reset_runtime_events()
	current_level_index = safe_level
	level_launches = 0
	campaign_complete = false
	level_transition_active = false
	_apply_current_level(true, true)
	_show_status("MAP %d/%d — %s" % [safe_level + 1, CAMPAIGN_LEVELS.size(), str(_current_level_data()["name"])], 3.0)
	_update_ui()
	_minimize_dev_panel()

func _current_level_data() -> Dictionary:
	return CAMPAIGN_LEVELS[clampi(current_level_index, 0, CAMPAIGN_LEVELS.size() - 1)]

func _v2_from_level(data: Dictionary, key: String, fallback: Vector2) -> Vector2:
	var raw = data.get(key, [])
	if raw is Array and raw.size() >= 2:
		return Vector2(float(raw[0]), float(raw[1]))
	return fallback

func _apply_current_level(reset_transient: bool = true, show_intro: bool = true) -> void:
	var data: Dictionary = _current_level_data()
	_build_current_map_environment()
	if visual_button != null:
		visual_button.position = _v2_from_level(data, "button", Vector2(550, 533))
		visual_button.pivot_offset = visual_button.size * 0.5
		if visual_heat_label != null:
			visual_heat_label.position = visual_button.position + Vector2(15, -95)
	if visual_phone != null:
		visual_phone_home = _v2_from_level(data, "phone", visual_phone_home)
		visual_phone.position = visual_phone_home
		if visual_phone_status != null:
			visual_phone_status.position = visual_phone_home + Vector2(17, 117)
	if visual_paper != null:
		visual_paper_home = _v2_from_level(data, "paper", Vector2(880, 495))
		visual_paper.position = visual_paper_home
	if visual_emergency_phone != null:
		visual_emergency_home = _v2_from_level(data, "emergency", Vector2(1000, 500))
		visual_emergency_phone.position = visual_emergency_home
	if visual_alarm_switch != null:
		visual_alarm_switch.position = _v2_from_level(data, "alarm", Vector2(405, 515))
	if visual_main_monitor != null:
		visual_main_monitor.position = _v2_from_level(data, "monitor", Vector2(505, 321))
	level_gimmick_accum = 0.0
	if reset_transient:
		enemy_pressure = 0.0
		heat = 0.0
		chaos = 0.0
		approval = maxf(approval, 60.0)
		_reset_runtime_events()
	_recalculate_campaign_stage(false)
	_refresh_stage_unlocks()
	_update_ui()
	if show_intro:
		_show_level_intro()

func _show_level_intro() -> void:
	if level_intro_root == null:
		return

	level_intro_token += 1
	var token: int = level_intro_token
	var data: Dictionary = _current_level_data()
	var is_final: bool = current_level_index == CAMPAIGN_LEVELS.size() - 1

	level_intro_active = true
	level_intro_root.visible = true
	level_intro_root.modulate.a = 0.0
	level_intro_bg.color = Color("#16080a") if is_final else Color("#05080d")
	level_intro_title.text = str(data["name"])
	level_intro_title.modulate = Color("#d94a50") if is_final else Color("#f2d27c")
	level_intro_message.text = str(data.get("intro_message", data.get("intro", "")))
	level_intro_message.modulate = Color("#f2f2f2")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var fade_in := create_tween()
	fade_in.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_in.tween_property(level_intro_root, "modulate:a", 1.0, 0.24)

	await get_tree().create_timer(3.25 if is_final else 2.45, true, false, true).timeout
	if token != level_intro_token:
		return

	var fade_out := create_tween()
	fade_out.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_out.tween_property(level_intro_root, "modulate:a", 0.0, 0.34)
	await fade_out.finished
	if token != level_intro_token:
		return

	level_intro_root.visible = false
	level_intro_active = false
	last_launch_time = Time.get_ticks_msec() / 1000.0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _recalculate_campaign_stage(announce: bool = true) -> void:
	var data: Dictionary = _current_level_data()
	var floor_stage: int = clampi(int(data.get("stage_floor", 1)), 1, STAGES.size())
	var ceiling_stage: int = clampi(int(data.get("stage_ceiling", floor_stage)), floor_stage, STAGES.size())
	var goal: int = maxi(1, int(data.get("goal", 1)))
	var ratio: float = clampf(float(level_launches) / float(goal), 0.0, 1.0)
	var stage_count: int = ceiling_stage - floor_stage + 1
	var calculated: int = floor_stage + int(floor(ratio * float(stage_count)))
	calculated = clampi(calculated, floor_stage, ceiling_stage)
	var old_stage: int = stage
	stage = calculated
	if announce and stage != old_stage:
		last_stage_seen = stage
		_show_status("STAGE %d — %s" % [stage, str(STAGES[stage - 1]["name"])], 2.5)
		_refresh_stage_unlocks()
		_save_game()

func _complete_current_level() -> void:
	if level_transition_active or campaign_complete:
		return
	var finished_index: int = current_level_index
	var finished: Dictionary = _current_level_data()
	level_transition_active = true
	_reset_runtime_events()
	if finished_index >= CAMPAIGN_LEVELS.size() - 1:
		campaign_complete = true
		_save_game()
		paused = true
		get_tree().paused = true
		_show_level_complete_panel(str(finished["name"]), true, "")
		return
	current_level_index += 1
	level_launches = 0
	var next_level: Dictionary = _current_level_data()
	_recalculate_campaign_stage(false)
	_save_game()
	paused = true
	get_tree().paused = true
	_show_level_complete_panel(str(finished["name"]), false, str(next_level["name"]))

func _show_level_complete_panel(finished_name: String, final_level: bool, next_name: String) -> void:
	if level_complete_panel == null:
		return
	level_complete_title.text = "CAMPAIGN COMPLETE" if final_level else "LEVEL COMPLETE"
	if final_level:
		level_complete_body.text = "%s COMPLETE\n\n2,000,000 launches reached.\nAgainst all available evidence, the campaign is over.\n\nDifficulty: %s\nLifetime launches: %d" % [finished_name, str(DIFFICULTIES[difficulty_index]["name"]), lifetime_bombs]
		level_complete_button.text = "RETURN TO MAIN MENU"
	else:
		level_complete_body.text = "%s COMPLETE\n\nTrump is travelling to the next location.\nNEXT: %s\nDifficulty: %s" % [finished_name, next_name, str(DIFFICULTIES[difficulty_index]["name"])]
		level_complete_button.text = "CONTINUE CAMPAIGN"
	level_complete_panel.visible = true
	_refresh_menu_backdrop()

func _continue_after_level_complete() -> void:
	if level_complete_panel != null:
		level_complete_panel.visible = false
	if campaign_complete:
		level_transition_active = false
		paused = false
		get_tree().paused = false
		_return_to_main_menu()
		return
	paused = false
	get_tree().paused = false
	level_transition_active = false
	_apply_current_level(true, true)
	_save_game()
	_refresh_menu_backdrop()

func _trigger_level_gimmick() -> void:
	if not game_started or paused or game_over or level_transition_active or level_intro_active:
		return
	match current_level_index:
		1:
			chaos += 2.0
			_show_status("PUTIN'S OFFICE — ANOTHER SECURITY BRIEFING ARRIVES.", 2.0)
		2:
			if stage >= 4 and not paperwork_active:
				_start_paperwork()
			_show_status("UNICEF OFFICE — STAFF NEED ANOTHER SIGNATURE.", 2.0)
		3:
			chaos += 4.0
			_show_status("UN MEETING — EVERY DELEGATE IS TALKING AT ONCE.", 2.0)
		4:
			chaos += 2.0
			_camera_shake(0.22, 0.75)
			_show_status("AIR FORCE ONE — TURBULENCE.", 1.6)
		5:
			chaos += 4.0
			_camera_shake(0.16, 0.45)
			_show_status("RALLY BACKSTAGE — THE CROWD SURGES.", 1.8)
		6:
			if stage >= 3 and not call_active:
				_start_call()
			_show_status("G20 — ANOTHER LEADER WANTS YOUR ATTENTION.", 1.8)
		7:
			enemy_pressure += 7.0
			chaos += 3.0
			_camera_shake(0.20, 0.55)
			_show_status("BUNKER — SECURITY SYSTEM SURGE.", 1.8)
		8:
			if stage >= 3 and not call_active:
				_start_call()
			_show_status("GOLF CLUB — SOMEONE IS CALLING DURING TEE TIME.", 1.8)
		9:
			chaos += 6.0
			enemy_pressure += 5.0
			_camera_shake(0.26, 0.8)
			if stage >= 5 and not crisis_active:
				_start_crisis()
			_show_status("PRESIDENTIAL NIGHTMARE — EVERYTHING IS HAPPENING.", 1.8)
		_:
			pass

func _opaque_panel_style(bg: Color = Color("#0b1118")) -> StyleBoxFlat:
	# Kept function name for compatibility with earlier code, but the style is now
	# a readable translucent "frosted" panel rather than a heavy opaque slab.
	var style := StyleBoxFlat.new()
	var tint := bg
	tint.a = 0.82
	style.bg_color = tint
	style.border_color = Color(0.88, 0.92, 0.98, 0.20)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.shadow_color = Color(0, 0, 0, 0.48)
	style.shadow_size = 24
	style.content_margin_left = 10
	style.content_margin_top = 10
	style.content_margin_right = 10
	style.content_margin_bottom = 10
	return style

func _make_panel_opaque(panel: Panel, bg: Color = Color("#0b1118")) -> void:
	if panel != null:
		panel.add_theme_stylebox_override("panel", _opaque_panel_style(bg))

func _menu_button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(0, 0, 0, 0.32)
	style.shadow_size = 8
	return style

func _style_menu_button(button: Button) -> void:
	if button == null:
		return
	button.flat = false
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", Color("#eef5ff"))
	button.add_theme_color_override("font_hover_color", Color("#ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("#fff7e3"))
	button.add_theme_color_override("font_focus_color", Color("#ffffff"))
	button.add_theme_color_override("font_disabled_color", Color(0.72, 0.76, 0.82, 0.78))
	button.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_stylebox_override("normal", _menu_button_style(Color(0.08, 0.11, 0.16, 0.84), Color(0.85, 0.90, 0.98, 0.14)))
	button.add_theme_stylebox_override("hover", _menu_button_style(Color(0.12, 0.18, 0.26, 0.92), Color("#dcb86b")))
	button.add_theme_stylebox_override("pressed", _menu_button_style(Color(0.16, 0.24, 0.35, 0.96), Color("#f0cb78")))
	button.add_theme_stylebox_override("focus", _menu_button_style(Color(0.10, 0.16, 0.22, 0.90), Color("#f0cb78")))
	button.add_theme_stylebox_override("disabled", _menu_button_style(Color(0.08, 0.10, 0.13, 0.58), Color(0.78, 0.82, 0.88, 0.08)))

func _refresh_menu_backdrop() -> void:
	if menu_backdrop == null:
		return
	var should_show := false
	should_show = should_show or (main_menu != null and main_menu.visible)
	should_show = should_show or (pause_menu != null and pause_menu.visible)
	should_show = should_show or (settings_menu != null and settings_menu.visible)
	should_show = should_show or (credits_menu != null and credits_menu.visible)
	should_show = should_show or (game_over_panel != null and game_over_panel.visible)
	should_show = should_show or (difficulty_select_panel != null and difficulty_select_panel.visible)
	should_show = should_show or (level_complete_panel != null and level_complete_panel.visible)
	should_show = should_show or (dev_code_panel != null and dev_code_panel.visible)
	should_show = should_show or (dev_panel != null and dev_panel.visible)
	should_show = should_show or (dev_map_preview != null and dev_map_preview.visible)
	should_show = should_show or (multiplayer_menu != null and multiplayer_menu.visible)
	should_show = should_show or (multiplayer_role_menu != null and multiplayer_role_menu.visible)
	should_show = should_show or (online_multiplayer_ui != null and is_instance_valid(online_multiplayer_ui) and online_multiplayer_ui.visible)
	should_show = should_show or (update_panel != null and update_panel.visible)
	menu_backdrop.visible = should_show

func _saved_menu_level_index() -> int:
	var saved_level := 0
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file != null:
			var parsed = JSON.parse_string(file.get_as_text())
			if typeof(parsed) == TYPE_DICTIONARY:
				saved_level = clampi(int(parsed.get("current_level_index", 0)), 0, CAMPAIGN_LEVELS.size() - 1)
	return saved_level

func _show_saved_level_as_menu_background() -> void:
	# Compatibility wrapper: the rotating home background starts on the player's saved map.
	_start_menu_background_cycle(_saved_menu_level_index())

func _build_menu_scene_fade() -> void:
	menu_scene_fade = ColorRect.new()
	menu_scene_fade.name = "MenuSceneFade"
	menu_scene_fade.color = Color.BLACK
	menu_scene_fade.position = Vector2.ZERO
	menu_scene_fade.size = Vector2(1280, 720)
	menu_scene_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_scene_fade.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_scene_fade.modulate.a = 0.0
	menu_scene_fade.visible = false
	layer.add_child(menu_scene_fade)

func _build_menu_background_entries(start_campaign_index: int) -> void:
	menu_background_entries.clear()
	if CAMPAIGN_LEVELS.is_empty():
		return
	var start_index := clampi(start_campaign_index, 0, CAMPAIGN_LEVELS.size() - 1)
	for offset in range(CAMPAIGN_LEVELS.size()):
		var campaign_index := (start_index + offset) % CAMPAIGN_LEVELS.size()
		menu_background_entries.append({
			"type": "campaign",
			"index": campaign_index,
			"name": str(CAMPAIGN_LEVELS[campaign_index].get("name", "CAMPAIGN")),
		})
	menu_background_entries.append({"type":"multiplayer", "mode":"crisis", "role":"INTEL", "name":"CRISIS ROOM"})
	menu_background_entries.append({"type":"multiplayer", "mode":"debate", "role":"TRUMP", "name":"PRESIDENTIAL DEBATE"})

func _start_menu_background_cycle(start_campaign_index: int = -1) -> void:
	if not world_ready:
		return
	var first_index := _saved_menu_level_index() if start_campaign_index < 0 else start_campaign_index
	_build_menu_background_entries(first_index)
	menu_background_index = 0
	menu_background_elapsed = 0.0
	menu_background_cycle_active = not menu_background_entries.is_empty()
	menu_background_transition_active = false
	if menu_scene_fade != null:
		menu_scene_fade.visible = false
		menu_scene_fade.modulate.a = 0.0
	if menu_background_cycle_active:
		_apply_menu_background_entry(menu_background_entries[0])

func _stop_menu_background_cycle(clear_background_arena: bool = true) -> void:
	menu_background_cycle_active = false
	menu_background_elapsed = 0.0
	menu_background_transition_active = false
	if menu_scene_fade != null:
		menu_scene_fade.visible = false
		menu_scene_fade.modulate.a = 0.0
	if clear_background_arena:
		_clear_menu_background_arena()

func _menu_background_should_cycle() -> bool:
	if not world_ready or game_started or screen_transition_active:
		return false
	if multiplayer_arena != null and is_instance_valid(multiplayer_arena):
		return false
	return (
		(main_menu != null and main_menu.visible)
		or (settings_menu != null and settings_menu.visible)
		or (credits_menu != null and credits_menu.visible)
		or (difficulty_select_panel != null and difficulty_select_panel.visible)
		or (dev_code_panel != null and dev_code_panel.visible)
		or (dev_panel != null and dev_panel.visible)
		or (dev_map_preview != null and dev_map_preview.visible)
		or (multiplayer_menu != null and multiplayer_menu.visible)
		or (multiplayer_role_menu != null and multiplayer_role_menu.visible)
		or (online_multiplayer_ui != null and is_instance_valid(online_multiplayer_ui) and online_multiplayer_ui.visible)
		or (update_panel != null and update_panel.visible)
	)

func _process_menu_background_cycle(delta: float) -> void:
	if not menu_background_cycle_active or not _menu_background_should_cycle():
		return
	if menu_background_transition_active:
		return
	menu_background_elapsed += delta
	if menu_background_elapsed < MENU_BACKGROUND_HOLD_SECONDS:
		return
	menu_background_elapsed = 0.0
	_cycle_to_next_menu_background()

func _cycle_to_next_menu_background() -> void:
	if menu_background_transition_active or menu_background_entries.size() < 2:
		return
	menu_background_transition_active = true
	if menu_scene_fade != null:
		menu_scene_fade.visible = true
		menu_scene_fade.modulate.a = 0.0
		var fade_out := create_tween()
		fade_out.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		fade_out.set_trans(Tween.TRANS_QUAD)
		fade_out.set_ease(Tween.EASE_IN_OUT)
		fade_out.tween_property(menu_scene_fade, "modulate:a", 1.0, MENU_BACKGROUND_FADE_OUT_SECONDS)
		await fade_out.finished
	if not menu_background_cycle_active:
		menu_background_transition_active = false
		return
	menu_background_index = (menu_background_index + 1) % menu_background_entries.size()
	_apply_menu_background_entry(menu_background_entries[menu_background_index])
	await get_tree().create_timer(0.06, true, false, true).timeout
	if menu_scene_fade != null:
		var fade_in := create_tween()
		fade_in.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		fade_in.set_trans(Tween.TRANS_QUAD)
		fade_in.set_ease(Tween.EASE_IN_OUT)
		fade_in.tween_property(menu_scene_fade, "modulate:a", 0.0, MENU_BACKGROUND_FADE_IN_SECONDS)
		await fade_in.finished
		menu_scene_fade.visible = false
	menu_background_transition_active = false

func _apply_menu_background_entry(entry: Dictionary) -> void:
	var entry_type := str(entry.get("type", "campaign"))
	if entry_type == "multiplayer":
		_show_multiplayer_menu_background(str(entry.get("mode", "crisis")), str(entry.get("role", "INTEL")))
		return
	_clear_menu_background_arena()
	if fallback_bg != null:
		fallback_bg.visible = false
	if visual_root != null:
		visual_root.visible = true
	var logical_level := current_level_index
	current_level_index = clampi(int(entry.get("index", 0)), 0, CAMPAIGN_LEVELS.size() - 1)
	_apply_current_level(false, false)
	current_level_index = logical_level

func _show_multiplayer_menu_background(mode_name: String, role_name: String) -> void:
	_clear_menu_background_arena()
	if visual_root != null:
		visual_root.visible = false
	if fallback_bg != null:
		fallback_bg.visible = false
	var arena_script := load("res://scripts/multiplayer_arena.gd") as Script
	if arena_script == null:
		return
	menu_background_arena = Node3D.new()
	menu_background_arena.name = "MenuBackgroundMultiplayerArena"
	menu_background_arena.set_script(arena_script)
	add_child(menu_background_arena)
	menu_background_arena.set_process_unhandled_input(false)
	menu_background_arena.set_process_input(false)
	menu_background_arena.set("mouse_look_enabled", false)
	menu_background_arena.call("build_mode", mode_name, role_name)
	_hide_menu_background_canvas_layers(menu_background_arena)

func _hide_menu_background_canvas_layers(node: Node) -> void:
	for child in node.get_children():
		if child is CanvasLayer:
			(child as CanvasLayer).visible = false
		_hide_menu_background_canvas_layers(child)

func _clear_menu_background_arena() -> void:
	if menu_background_arena != null and is_instance_valid(menu_background_arena):
		menu_background_arena.queue_free()
	menu_background_arena = null

func _build_transition_fade() -> void:
	transition_fade = ColorRect.new()
	transition_fade.name = "ScreenTransitionFade"
	transition_fade.color = Color.BLACK
	transition_fade.position = Vector2.ZERO
	transition_fade.size = Vector2(1280, 720)
	transition_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	transition_fade.process_mode = Node.PROCESS_MODE_ALWAYS
	transition_fade.modulate.a = 0.0
	transition_fade.visible = false
	layer.add_child(transition_fade)

func _fade_to_black(duration: float = 0.30) -> void:
	if transition_fade == null:
		return
	transition_fade.visible = true
	transition_fade.modulate.a = 0.0
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(transition_fade, "modulate:a", 1.0, duration)
	await tween.finished

func _fade_from_black(duration: float = 0.38) -> void:
	if transition_fade == null:
		return
	transition_fade.visible = true
	transition_fade.modulate.a = 1.0
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(transition_fade, "modulate:a", 0.0, duration)
	await tween.finished
	transition_fade.visible = false

# ============================================================
# BUILD HELPERS
# ============================================================

func _material(
	color: Color,
	metallic := 0.0,
	roughness := 0.55,
	emission := Color(0, 0, 0),
	texture_path := "",
	uv_scale := Vector3.ONE
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	if texture_path != "":
		var texture: Texture2D = load(texture_path)
		if texture != null:
			material.albedo_texture = texture
			material.uv1_scale = uv_scale
	if emission != Color(0, 0, 0):
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = 1.5
	return material

func _instance_glb(
	path: String,
	name_value: String,
	pos: Vector3 = Vector3.ZERO,
	scale_value: Vector3 = Vector3.ONE,
	rotation_value: Vector3 = Vector3.ZERO,
	parent: Node = self
) -> Node3D:
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		push_error("Could not load model: " + path)
		return Node3D.new()

	var instance: Node = packed.instantiate()
	if not (instance is Node3D):
		push_error("Model root is not Node3D: " + path)
		return Node3D.new()

	var node: Node3D = instance as Node3D
	node.name = name_value
	node.position = pos
	node.scale = scale_value
	node.rotation_degrees = rotation_value
	parent.add_child(node)
	return node

func _set_model_material(root: Node, material: Material) -> void:
	if root is MeshInstance3D:
		(root as MeshInstance3D).material_override = material
	for child: Node in root.get_children():
		_set_model_material(child, material)

func _glass_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.72, 0.88, 0.96, 0.18)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 0.08
	material.metallic = 0.04
	return material

func _box(
	name: String,
	size: Vector3,
	pos: Vector3,
	color: Color,
	parent: Node = self,
	metallic := 0.0,
	roughness := 0.55,
	texture_path := "",
	uv_scale := Vector3.ONE
) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.position = pos
	node.material_override = _material(color, metallic, roughness, Color(0,0,0), texture_path, uv_scale)
	parent.add_child(node)
	return node

func _cylinder(
	name: String,
	radius: float,
	height: float,
	pos: Vector3,
	color: Color,
	parent: Node = self,
	metallic := 0.0,
	roughness := 0.45,
	texture_path := "",
	uv_scale := Vector3.ONE
) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 64
	node.mesh = mesh
	node.position = pos
	node.material_override = _material(color, metallic, roughness, Color(0,0,0), texture_path, uv_scale)
	parent.add_child(node)
	return node

func _sphere(
	name: String,
	radius: float,
	pos: Vector3,
	color: Color,
	parent: Node = self,
	metallic := 0.0,
	roughness := 0.45
) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 32
	mesh.rings = 16
	node.mesh = mesh
	node.position = pos
	node.material_override = _material(color, metallic, roughness)
	parent.add_child(node)
	return node

func _static_box_body(
	name: String,
	size: Vector3,
	pos: Vector3,
	color: Color
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = name
	body.position = pos
	body.input_ray_pickable = true
	add_child(body)

	_box(name + "Mesh", size, Vector3.ZERO, color, body)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size * Vector3(1.08, 2.0, 1.08)
	collision.shape = shape
	body.add_child(collision)
	return body

# ============================================================
# ENVIRONMENT / OFFICE
# ============================================================

func _build_environment() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#0c1520")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#cfc2a6")
	env.ambient_light_energy = 0.34
	world_env.environment = env
	add_child(world_env)

	# Softer daylight so the room stops blowing out.
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-34, -26, 0)
	sun.light_color = Color("#eef7ff")
	sun.light_energy = 0.72
	sun.shadow_enabled = true
	add_child(sun)

	# Warm practical lights should support the desk rather than overexpose the room.
	for p in [Vector3(-3.1, 3.25, 0.15), Vector3(3.1, 3.25, 0.15)]:
		var lamp := OmniLight3D.new()
		lamp.position = p
		lamp.light_color = Color("#ffd39a")
		lamp.light_energy = 2.15
		lamp.omni_range = 5.4
		lamp.shadow_enabled = true
		add_child(lamp)

	var fire_light := OmniLight3D.new()
	fire_light.position = Vector3(0, 1.15, -3.65)
	fire_light.light_color = Color("#ff8b49")
	fire_light.light_energy = 1.2
	fire_light.omni_range = 3.1
	add_child(fire_light)

	# Seated player camera: the player should feel like they're sitting behind the desk.
	main_camera = Camera3D.new()
	main_camera.name = "MainCamera"
	main_camera.position = Vector3(0.0, 3.18, 4.62)
	main_camera.fov = 60.0
	main_camera.near = 0.05
	main_camera.far = 100.0
	add_child(main_camera)
	main_camera.look_at(Vector3(0.05, 2.70, 0.55), Vector3.UP)
	main_camera.current = true

func _build_office() -> void:
	var plaster_tex := "res://assets/textures/plaster_warm.png"
	var wood_tex := "res://assets/textures/wood_walnut.png"
	var curtain_tex := "res://assets/textures/curtain_red.png"
	var marble_tex := "res://assets/textures/marble_cream.png"
	var rug_tex := "res://assets/textures/rug_presidential.png"

	# Real room shell with thickness. Unseen rear geometry is intentionally omitted.
	_box("Floor", Vector3(14, 0.22, 12), Vector3(0, -0.11, 0), Color("#75502f"), self, 0.0, 0.58, wood_tex, Vector3(5,5,5))
	_box("BackWall", Vector3(14, 7.1, 0.32), Vector3(0, 3.45, -5.02), Color("#ded6c8"), self, 0.0, 0.88, plaster_tex, Vector3(5,3,1))
	_box("LeftWall", Vector3(0.32, 7.1, 10.4), Vector3(-7.02, 3.45, 0), Color("#d8cfbf"), self, 0.0, 0.88, plaster_tex, Vector3(1,3,4))
	_box("RightWall", Vector3(0.32, 7.1, 10.4), Vector3(7.02, 3.45, 0), Color("#d8cfbf"), self, 0.0, 0.88, plaster_tex, Vector3(1,3,4))
	_box("CeilingLip", Vector3(14, 0.18, 5.2), Vector3(0, 6.96, -2.3), Color("#f0eadf"), self, 0.0, 0.9, plaster_tex, Vector3(4,2,2))

	# Crown moulding and baseboards give the room real scale and edge depth.
	_box("BackCrown", Vector3(13.8, 0.22, 0.30), Vector3(0, 6.63, -4.78), Color("#f4efe6"))
	_box("BackBaseboard", Vector3(13.8, 0.30, 0.24), Vector3(0, 0.18, -4.78), Color("#f0eadf"))
	_box("LeftCrown", Vector3(0.30, 0.22, 9.8), Vector3(-6.78, 6.63, 0), Color("#f4efe6"))
	_box("RightCrown", Vector3(0.30, 0.22, 9.8), Vector3(6.78, 6.63, 0), Color("#f4efe6"))
	_box("LeftBaseboard", Vector3(0.26, 0.30, 9.7), Vector3(-6.78, 0.18, 0), Color("#efe8dc"))
	_box("RightBaseboard", Vector3(0.26, 0.30, 9.7), Vector3(6.78, 0.18, 0), Color("#efe8dc"))

	# Raised wall panels. Each panel has an outer frame and a recessed inner field.
	for x in [-5.4, -3.25, 3.25, 5.4]:
		_box("PanelField", Vector3(1.62, 3.05, 0.06), Vector3(x, 4.02, -4.81), Color("#d5ccbc"), self, 0.0, 0.94, plaster_tex, Vector3(1,2,1))
		_box("PanelTop", Vector3(1.82, 0.09, 0.12), Vector3(x, 5.60, -4.70), Color("#f3ede4"))
		_box("PanelBottom", Vector3(1.82, 0.09, 0.12), Vector3(x, 2.44, -4.70), Color("#f3ede4"))
		_box("PanelLeft", Vector3(0.09, 3.25, 0.12), Vector3(x - 0.91, 4.02, -4.70), Color("#f3ede4"))
		_box("PanelRight", Vector3(0.09, 3.25, 0.12), Vector3(x + 0.91, 4.02, -4.70), Color("#f3ede4"))

	# Window recess with a real sill and jamb depth.
	_box("WindowRecessTop", Vector3(5.0, 0.30, 0.48), Vector3(0, 5.92, -4.57), Color("#eee7dc"))
	_box("WindowRecessBottom", Vector3(5.0, 0.34, 0.58), Vector3(0, 2.50, -4.52), Color("#eee7dc"))
	_box("WindowRecessLeft", Vector3(0.32, 3.15, 0.50), Vector3(-2.48, 4.20, -4.55), Color("#eee7dc"))
	_box("WindowRecessRight", Vector3(0.32, 3.15, 0.50), Vector3(2.48, 4.20, -4.55), Color("#eee7dc"))
	_box("WindowMullionV", Vector3(0.11, 3.08, 0.18), Vector3(0, 4.2, -4.28), Color("#f6f1e8"))
	_box("WindowMullionH", Vector3(4.58, 0.11, 0.18), Vector3(0, 4.2, -4.28), Color("#f6f1e8"))
	_box("WindowInnerFrameTop", Vector3(4.75, 0.18, 0.20), Vector3(0, 5.76, -4.29), Color("#f6f1e8"))
	_box("WindowInnerFrameBottom", Vector3(4.75, 0.18, 0.20), Vector3(0, 2.65, -4.29), Color("#f6f1e8"))

	var glass := _box("WindowGlass", Vector3(4.52, 2.98, 0.025), Vector3(0, 4.20, -4.39), Color.WHITE)
	glass.material_override = _glass_material()

	_build_exterior_view()

	# Final-art curtain set: imported pleated cloth instead of stacked slabs.
	_instance_glb("res://assets/models/graphics_lock/curtain_set.glb", "CurtainSet")

	# Final-art fireplace asset.
	_instance_glb("res://assets/models/graphics_lock/fireplace.glb", "Fireplace")

	# Presidential-style rug with actual thickness and texture.
	var rug := MeshInstance3D.new()
	var rug_mesh := CylinderMesh.new()
	rug_mesh.top_radius = 4.72
	rug_mesh.bottom_radius = 4.72
	rug_mesh.height = 0.055
	rug_mesh.radial_segments = 96
	rug.mesh = rug_mesh
	rug.position = Vector3(0, 0.035, 0.45)
	rug.scale = Vector3(1.0, 1.0, 0.58)
	rug.material_override = _material(Color("#c6ab67"), 0.0, 0.92, Color(0,0,0), rug_tex, Vector3(1,1,1))
	add_child(rug)

	# Side tables, lamps and framed wall art fill the visible frame with real geometry.
	for side in [-1.0, 1.0]:
		var sx: float = 4.75 * float(side)
		_box("SideTableTop", Vector3(1.55, 0.18, 1.05), Vector3(sx, 1.32, -1.90), Color("#70401f"), self, 0.0, 0.40, wood_tex)
		for ox in [-0.52, 0.52]:
			_box("SideTableLeg", Vector3(0.16, 1.20, 0.16), Vector3(sx + ox, 0.68, -1.90), Color("#583019"), self, 0.0, 0.45, wood_tex)
		_cylinder("LampStem", 0.075, 1.35, Vector3(sx, 2.05, -1.90), Color("#b68f42"), self, 0.72, 0.20)
		_cylinder("LampBase", 0.30, 0.09, Vector3(sx, 1.41, -1.90), Color("#b68f42"), self, 0.72, 0.20)
		var shade := _cylinder("LampShade", 0.43, 0.65, Vector3(sx, 2.72, -1.90), Color("#efe0bd"), self, 0.0, 0.82)
		shade.scale = Vector3(1.15, 1.0, 1.15)

	# Framed art/portraits. These are modeled frames, not UI images.
	for info in [
		Vector3(-5.25, 4.23, -4.52),
		Vector3(5.25, 4.23, -4.52)
	]:
		_box("PortraitFrame", Vector3(1.35, 1.72, 0.16), info, Color("#9b742f"), self, 0.62, 0.24)
		_box("PortraitMat", Vector3(1.13, 1.50, 0.06), info + Vector3(0,0,0.10), Color("#d9cfb9"), self, 0.0, 0.90)
		_box("PortraitImage", Vector3(0.92, 1.28, 0.035), info + Vector3(0,0,0.145), Color("#536170"), self, 0.0, 0.88)

	# Flag poles and folded flag masses at the sides of the background.
	for side in [-1.0, 1.0]:
		var px: float = 4.0 * float(side)
		_cylinder("FlagPole", 0.045, 4.1, Vector3(px, 3.50, -3.82), Color("#aa8641"), self, 0.70, 0.22)
		for i in range(5):
			_box(
				"FlagFold",
				Vector3(0.17, 2.65, 0.18),
				Vector3(px + side * (0.12 + float(i)*0.10), 3.90, -3.76 + (0.05 if i%2==0 else -0.03)),
				Color("#264d83") if side < 0 else Color("#a5232d"),
				self, 0.0, 0.88
			)

func _build_exterior_view() -> void:
	# The exterior uses several real depth planes behind the glass rather than one flat card.
	_box("ExteriorSkyBack", Vector3(5.35, 3.80, 0.08), Vector3(0, 4.20, -7.50), Color("#a9d8f2"))
	_box("ExteriorFarLawn", Vector3(5.50, 0.62, 0.12), Vector3(0, 2.78, -6.72), Color("#88ad70"))
	_box("ExteriorMidLawn", Vector3(5.50, 0.54, 0.12), Vector3(0, 2.40, -6.05), Color("#6f965a"))
	_box("ExteriorNearLawn", Vector3(5.50, 0.72, 0.14), Vector3(0, 2.02, -5.45), Color("#557a47"))

	# Distant skyline with actual separation in Z for parallax/depth.
	for item in [
		Vector4(-1.72, 3.58, 0.34, 0.75),
		Vector4(-1.25, 3.48, 0.38, 0.58),
		Vector4(-0.72, 3.62, 0.30, 0.86),
		Vector4(0.65, 3.52, 0.36, 0.70),
		Vector4(1.13, 3.45, 0.28, 0.55),
		Vector4(1.67, 3.60, 0.42, 0.82)
	]:
		_box("ExteriorBuilding", Vector3(item.z, item.w, 0.14), Vector3(item.x, item.y, -7.05), Color("#8b9daa"), self, 0.0, 0.92)

	_box("ExteriorMonument", Vector3(0.14, 1.22, 0.14), Vector3(-0.20, 3.62, -6.86), Color("#a4b0ba"), self, 0.0, 0.90)

	# Curved-looking walk built from overlapping stone sections.
	for i in range(7):
		_box("ExteriorPath", Vector3(0.58 + i*0.05, 0.05, 0.30), Vector3(0, 2.20 + i*0.07, -5.45 - i*0.18), Color("#d6d5cf"))

	_cylinder("ExteriorFountainBasin", 0.30, 0.10, Vector3(0, 2.63, -5.90), Color("#d6d2c9"), self, 0.0, 0.52)
	_cylinder("ExteriorFountainWater", 0.24, 0.035, Vector3(0, 2.70, -5.90), Color("#8bcfea"), self, 0.0, 0.12)

	for x in [-1.82, -1.36, -0.92, 0.92, 1.36, 1.82]:
		_box("ExteriorHedge", Vector3(0.48, 0.26, 0.38), Vector3(x, 2.55, -5.58), Color("#466f3c"), self, 0.0, 0.98)

	for p in [
		Vector3(-2.05, 2.28, -5.72),
		Vector3(-1.52, 2.35, -6.12),
		Vector3(1.52, 2.35, -6.12),
		Vector3(2.05, 2.28, -5.72)
	]:
		_build_tree(p)

	# Three cloud groups at the back layer.
	for c in [Vector3(-1.55,5.15,-7.34),Vector3(0.25,4.90,-7.34),Vector3(1.62,5.18,-7.34)]:
		for off in [Vector3.ZERO,Vector3(-0.22,-0.04,0),Vector3(0.22,-0.03,0)]:
			var cloud := _sphere("Cloud", 0.20, c+off, Color("#f5fbff"), self, 0.0, 1.0)
			cloud.scale = Vector3(1.5,0.68,0.65)

func _build_tree(pos: Vector3) -> void:
	_cylinder("TreeTrunk", 0.09, 0.95, pos + Vector3(0, 0.48, 0), Color("#68472b"), self, 0.0, 0.92)
	for offset in [
		Vector3(0, 1.12, 0),
		Vector3(-0.24, 1.02, 0.03),
		Vector3(0.24, 1.02, -0.03),
		Vector3(-0.10, 1.30, 0.02),
		Vector3(0.12, 1.30, 0.0)
	]:
		var leaf := _sphere("TreeCanopy", 0.28, pos + offset, Color("#4d7c43"), self, 0.0, 0.96)
		leaf.scale = Vector3(1.1,1.15,0.9)

func _build_desk() -> void:
	# Graphics-lock desk asset. The scene is authored at world scale so its proportions
	# stay consistent with the seated camera and gameplay objects.
	_instance_glb(
		"res://assets/models/graphics_lock/resolute_desk.glb",
		"ResoluteDesk"
	)

	# Hero desk props.
	_instance_glb(
		"res://assets/models/graphics_lock/desk_lamp.glb",
		"DeskLamp",
		Vector3(-2.65, 2.47, 1.32)
	)

	# Coffee cup/saucer kept lightweight; these are secondary props.
	_cylinder("CoffeeSaucer", 0.28, 0.028, Vector3(2.58, 2.46, 0.42), Color("#e7e1d8"), self, 0.0, 0.28)
	_cylinder("CoffeeCup", 0.20, 0.38, Vector3(2.58, 2.65, 0.42), Color("#dedbd3"), self, 0.0, 0.30)

# ============================================================
# DIEGETIC 3D UI / COMMAND SCREENS
# ============================================================

func _screen_material(color: Color) -> StandardMaterial3D:
	return _material(color, 0.05, 0.28, color.darkened(0.45))

func _build_screen(
	name_value: String,
	pos: Vector3,
	size: Vector2,
	screen_color: Color,
	frame_color: Color = Color("#151b20"),
	rotation_deg: Vector3 = Vector3.ZERO,
	with_stand: bool = false
) -> Label3D:
	var root := Node3D.new()
	root.name = name_value
	root.position = pos
	root.rotation_degrees = rotation_deg
	add_child(root)

	_instance_glb(
		"res://assets/models/graphics_lock/monitor_shell.glb",
		name_value + "Frame",
		Vector3.ZERO,
		Vector3(size.x + 0.16, size.y + 0.16, 1.0),
		Vector3.ZERO,
		root
	)

	var screen := _box(
		name_value + "Glass",
		Vector3(size.x, size.y, 0.055),
		Vector3(0, 0, 0.105),
		screen_color,
		root,
		0.12,
		0.16
	)
	screen.material_override = _screen_material(screen_color)

	if with_stand:
		_box(
			name_value + "StandStem",
			Vector3(0.12, 0.48, 0.12),
			Vector3(0, -(size.y * 0.5 + 0.28), -0.04),
			Color("#252a2e"),
			root,
			0.55,
			0.28
		)
		_box(
			name_value + "StandFoot",
			Vector3(max(0.72, size.x * 0.55), 0.08, 0.42),
			Vector3(0, -(size.y * 0.5 + 0.54), 0.04),
			Color("#202529"),
			root,
			0.55,
			0.28
		)

	var label := Label3D.new()
	label.name = name_value + "Text"
	label.position = Vector3(0, 0, 0.145)
	label.text = "STANDBY"
	label.font_size = 34
	label.pixel_size = 0.0075
	label.outline_size = 7
	label.outline_modulate = Color("#001018")
	label.modulate = Color("#baf6ff")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.width = int(size.x / label.pixel_size * 0.86)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(label)
	return label

func _build_clickable_terminal(
	name_value: String,
	pos: Vector3,
	size: Vector2,
	screen_color: Color,
	rotation_deg: Vector3 = Vector3.ZERO
) -> Dictionary:
	var body := StaticBody3D.new()
	body.name = name_value
	body.position = pos
	body.rotation_degrees = rotation_deg
	body.input_ray_pickable = true
	add_child(body)

	_box(
		name_value + "Frame",
		Vector3(size.x + 0.18, size.y + 0.18, 0.18),
		Vector3.ZERO,
		Color("#171c21"),
		body,
		0.5,
		0.25
	)
	var glass := _box(
		name_value + "Glass",
		Vector3(size.x, size.y, 0.06),
		Vector3(0, 0, 0.12),
		screen_color,
		body,
		0.12,
		0.16
	)
	glass.material_override = _screen_material(screen_color)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(size.x + 0.24, size.y + 0.24, 0.32)
	collision.shape = shape
	body.add_child(collision)

	var label := Label3D.new()
	label.position = Vector3(0, 0, 0.16)
	label.font_size = 32
	label.pixel_size = 0.0075
	label.outline_size = 7
	label.outline_modulate = Color("#001018")
	label.modulate = Color("#d7ffd4")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.width = int(size.x / label.pixel_size * 0.86)
	body.add_child(label)

	return {"body": body, "label": label}

func _build_diegetic_ui() -> void:
	# Keep the desk cleaner. Early game should feel like a desk, not a wall of monitors.
	command_monitor_label = _build_screen(
		"CommandMonitor",
		Vector3(0.12, 3.28, -0.78),
		Vector2(1.90, 0.90),
		Color("#081820"),
		Color("#181d22"),
		Vector3(-6, 0, 0),
		true
	)

	threat_monitor_label = _build_screen(
		"ThreatMonitor",
		Vector3(1.92, 3.04, -0.46),
		Vector2(1.10, 0.60),
		Color("#1b1306"),
		Color("#28211a"),
		Vector3(-6, -10, 0),
		true
	)
	threat_monitor_label.font_size = 28
	threat_monitor_label.pixel_size = 0.0070

	approval_monitor_label = _build_screen(
		"ApprovalNewsScreen",
		Vector3(-3.95, 4.36, -4.46),
		Vector2(1.55, 0.78),
		Color("#071524"),
		Color("#252b31")
	)
	approval_monitor_label.font_size = 24
	approval_monitor_label.pixel_size = 0.0068

	chaos_monitor_label = _build_screen(
		"OfficeStatusScreen",
		Vector3(3.95, 4.36, -4.46),
		Vector2(1.55, 0.78),
		Color("#151006"),
		Color("#252b31")
	)
	chaos_monitor_label.font_size = 24
	chaos_monitor_label.pixel_size = 0.0068

	heat_display_label = _build_screen(
		"ButtonHeatDisplay",
		Vector3(0.12, 2.58, 1.26),
		Vector2(0.98, 0.24),
		Color("#191008"),
		Color("#1b1d20"),
		Vector3(-10, 0, 0)
	)
	heat_display_label.font_size = 18
	heat_display_label.pixel_size = 0.0058

	phone_display_label = _build_screen(
		"PhoneDisplay",
		Vector3(-1.98, 2.96, 0.32),
		Vector2(1.05, 0.42),
		Color("#071615"),
		Color("#171b1d"),
		Vector3(-12, 10, 0),
		true
	)
	phone_display_label.font_size = 20
	phone_display_label.pixel_size = 0.0060

	paper_display_label = _build_screen(
		"PaperDeadlineDisplay",
		Vector3(2.02, 2.73, 1.28),
		Vector2(1.02, 0.24),
		Color("#151205"),
		Color("#1a1c1e"),
		Vector3(-10, -8, 0)
	)
	paper_display_label.font_size = 17
	paper_display_label.pixel_size = 0.0058

	crisis_display_label = _build_screen(
		"CrisisDisplay",
		Vector3(3.00, 3.02, -0.30),
		Vector2(1.06, 0.54),
		Color("#220808"),
		Color("#2b1717"),
		Vector3(-6, -10, 0),
		true
	)
	crisis_display_label.font_size = 20
	crisis_display_label.pixel_size = 0.0060

	alarm_display_label = _build_screen(
		"AlarmDisplay",
		Vector3(-3.00, 3.00, -0.30),
		Vector2(1.06, 0.54),
		Color("#211604"),
		Color("#2b2618"),
		Vector3(-6, 10, 0),
		true
	)
	alarm_display_label.font_size = 20
	alarm_display_label.pixel_size = 0.0060

	var terminal := _build_clickable_terminal(
		"UpgradeTerminal",
		Vector3(-5.05, 3.20, -4.44),
		Vector2(1.45, 0.84),
		Color("#081b11")
	)
	upgrade_terminal = terminal["body"] as StaticBody3D
	upgrade_terminal_label = terminal["label"] as Label3D

func _on_upgrade_terminal_input(
	_camera: Node,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	if _is_left_click(event):
		_toggle_upgrade_terminal()

func _toggle_upgrade_terminal() -> void:
	if not game_started or paused or game_over or upgrade_panel == null:
		return
	upgrade_panel_open = not upgrade_panel_open
	upgrade_panel.visible = upgrade_panel_open
	if upgrade_panel_open:
		_show_status("UPGRADE TERMINAL OPEN — THE OFFICE KEEPS RUNNING.", 1.4)

func _close_upgrade_terminal() -> void:
	upgrade_panel_open = false
	if upgrade_panel != null:
		upgrade_panel.visible = false

func _set_screen_severity(label: Label3D, value: float) -> void:
	if label == null:
		return
	if value >= 85.0:
		label.modulate = Color("#ff7b6e")
	elif value >= 60.0:
		label.modulate = Color("#ffd36e")
	else:
		label.modulate = Color("#baf6ff")



func _set_label_root_visible(label: Label3D, visible_value: bool) -> void:
	if label == null:
		return
	var root := label.get_parent()
	if root is Node3D:
		(root as Node3D).visible = visible_value

# ============================================================
# INTERACTIVE OBJECTS
# ============================================================

func _build_launch_button() -> void:
	# Small final-art button base.
	_instance_glb(
		"res://assets/models/graphics_lock/button_base.glb",
		"ButtonBaseModel",
		Vector3(0.10, 2.50, 0.74)
	)

	# The clickable cap has an intentionally larger invisible hit target than its visual size.
	launch_button = StaticBody3D.new()
	launch_button.name = "LaunchButton"
	launch_button.position = Vector3(0.10, 2.66, 0.74)
	launch_button.input_ray_pickable = true
	add_child(launch_button)

	launch_button_mesh = _instance_glb(
		"res://assets/models/graphics_lock/button_cap.glb",
		"ButtonCapModel",
		Vector3.ZERO,
		Vector3.ONE,
		Vector3.ZERO,
		launch_button
	)

	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 0.46
	shape.height = 0.38
	collision.shape = shape
	launch_button.add_child(collision)

	button_start_y = launch_button.position.y

func _build_phone() -> void:
	phone_body = StaticBody3D.new()
	phone_body.name = "Phone"
	phone_body.position = Vector3(-1.95, 2.48, 0.92)
	phone_body.input_ray_pickable = true
	add_child(phone_body)

	_instance_glb(
		"res://assets/models/graphics_lock/desk_phone.glb",
		"DeskPhoneModel",
		Vector3.ZERO,
		Vector3.ONE,
		Vector3.ZERO,
		phone_body
	)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.45, 0.80, 1.05)
	collision.shape = shape
	collision.position = Vector3(0, 0.32, 0)
	phone_body.add_child(collision)
	phone_start_rot = phone_body.rotation

func _build_emergency_phone() -> void:
	emergency_phone = StaticBody3D.new()
	emergency_phone.name = "EmergencyPhone"
	emergency_phone.position = Vector3(2.95, 2.56, 0.84)
	emergency_phone.input_ray_pickable = true
	add_child(emergency_phone)

	_box("EmergencyBase", Vector3(1.2, 0.38, 0.78), Vector3.ZERO, Color("#581b18"), emergency_phone, 0.12, 0.34)
	_box("EmergencyReceiver", Vector3(1.25, 0.27, 0.28), Vector3(0, 0.30, -0.03), Color("#8d2823"), emergency_phone, 0.18, 0.26)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.30, 0.68, 0.92)
	collision.shape = shape
	emergency_phone.add_child(collision)
	emergency_phone_start_rot = emergency_phone.rotation
	emergency_phone.visible = false

func _build_paperwork() -> void:
	paper_body = StaticBody3D.new()
	paper_body.name = "Paperwork"
	paper_body.position = Vector3(1.95, 2.49, 1.02)
	paper_body.input_ray_pickable = true
	add_child(paper_body)

	for i in range(4):
		var sheet := _box(
			"Paper%d" % i,
			Vector3(1.65, 0.018, 1.05),
			Vector3(i * 0.03, i * 0.018, -i * 0.025),
			Color("#f0e9d8"),
			paper_body,
			0.0,
			0.92
		)
		sheet.rotation_degrees.y = -8.0 + i * 3.0
		if i == 3:
			paper_mesh = sheet

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.95, 0.32, 1.25)
	collision.shape = shape
	paper_body.add_child(collision)

	paper_body.mouse_entered.connect(_on_paper_mouse_entered)
	paper_body.mouse_exited.connect(_on_paper_mouse_exited)
	paper_home = paper_body.position
	paper_body.visible = false

func _build_crisis_folder() -> void:
	crisis_folder = StaticBody3D.new()
	crisis_folder.name = "CrisisFolder"
	crisis_folder.position = Vector3(2.42, 2.53, 0.18)
	crisis_folder.input_ray_pickable = true
	add_child(crisis_folder)

	crisis_folder_mesh = _box(
		"CrisisFolderMesh",
		Vector3(1.55, 0.09, 1.0),
		Vector3.ZERO,
		Color("#8f1f1d"),
		crisis_folder,
		0.0,
		0.65
	)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.9, 0.45, 1.35)
	collision.shape = shape
	crisis_folder.add_child(collision)
	crisis_home = crisis_folder.position
	crisis_folder.visible = false

func _build_alarm_switch() -> void:
	alarm_switch = StaticBody3D.new()
	alarm_switch.name = "AlarmSwitch"
	alarm_switch.position = Vector3(-2.72, 2.63, 0.24)
	alarm_switch.input_ray_pickable = true
	add_child(alarm_switch)

	alarm_switch_mesh = _box(
		"AlarmSwitchMesh",
		Vector3(0.65, 0.32, 0.55),
		Vector3.ZERO,
		Color("#c58d22"),
		alarm_switch,
		0.55,
		0.26
	)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.9, 0.7, 0.8)
	collision.shape = shape
	alarm_switch.add_child(collision)
	alarm_switch.visible = false

# ----------------------------
# Mouse interaction handlers
# ----------------------------

func _on_launch_button_input(
	_camera: Node,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	if _is_left_click(event):
		_launch_bombs()

func _on_phone_input(
	_camera: Node,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	if _is_left_click(event):
		_answer_phone()

func _on_emergency_phone_input(
	_camera: Node,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	if _is_left_click(event):
		_handle_crisis()

func _on_paper_input(
	_camera: Node,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	if _is_left_click(event):
		_sign_paperwork()

func _on_crisis_folder_input(
	_camera: Node,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	if _is_left_click(event):
		_handle_crisis()

func _on_alarm_switch_input(
	_camera: Node,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	if _is_left_click(event):
		_reset_alarm()

func _is_left_click(event: InputEvent) -> bool:
	return (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	)

func _on_paper_mouse_entered() -> void:
	if paperwork_active and paper_mesh != null:
		paper_mesh.material_override = _material(Color("#fff4c2"), 0.0, 0.75, Color("#5a4210"))

func _on_paper_mouse_exited() -> void:
	if paper_mesh != null:
		paper_mesh.material_override = _material(Color("#f0e9d8"), 0.0, 0.92)

# ============================================================
# CORE GAMEPLAY
# ============================================================

func _ambient_trump_allowed() -> bool:
	# Random ambient lines must never overlap a phone call or its final line.
	return (
		not call_active
		and Time.get_ticks_msec() >= ambient_resume_after_msec
	)

func _launch_bombs() -> void:
	if not game_started or paused or game_over or level_intro_active or level_transition_active:
		return
	if button_busy or overheated:
		return
	if call_active and call_answered and call_locks_button:
		_show_status("TIMMY IS STILL TALKING.", 0.8)
		return

	bombs += power
	lifetime_bombs += power
	level_launches += power
	last_launch_time = Time.get_ticks_msec() / 1000.0

	if stage >= 2:
		enemy_pressure -= min(11.0, 3.0 + float(power) / 80.0)

	if stage >= 4:
		var diff: Dictionary = DIFFICULTIES[difficulty_index]
		var level_data: Dictionary = _current_level_data()
		heat += (2.1 + float(stage) * 0.36) * float(diff["heat"]) * float(level_data.get("heat", 1.0))
		chaos += 0.25

	if heat >= 100.0 and not overheated:
		_start_overheat()

	if _ambient_trump_allowed() and rng.randf() < 0.04:
		_say("TRUMP: " + AMBIENT_LINES[rng.randi_range(0, AMBIENT_LINES.size() - 1)])

	_update_stage()
	_press_button_animation()
	_update_ui()

func _start_overheat() -> void:
	overheated = true
	heat = 100.0
	approval -= 3.0
	_set_button_hot(true)
	_show_status("BUTTON OVERHEATED", 1.5)
	var cooldown: float = maxf(2.5, 6.0 - float(stage) * 0.4)
	get_tree().create_timer(cooldown).timeout.connect(_finish_cooldown)

func _finish_cooldown() -> void:
	overheated = false
	heat = 48.0
	_set_button_hot(false)
	_show_status("BUTTON READY", 1.2)

func _update_stage() -> void:
	_recalculate_campaign_stage(true)
	var goal: int = int(_current_level_data().get("goal", 1))
	if level_launches >= goal:
		_complete_current_level()

func _refresh_stage_unlocks() -> void:
	if upgrade_panel != null:
		upgrade_panel.visible = game_started and not game_over and upgrade_panel_open

	# Visual reboot: keep the desk clean and only surface systems when they matter.
	if visual_phone != null:
		visual_phone.visible = true
		visual_phone.disabled = stage < 3 and not call_active
	if visual_threat_card != null:
		visual_threat_card.visible = stage >= 2
	if visual_paper != null and not paperwork_active:
		visual_paper.visible = false
	if visual_emergency_phone != null and not crisis_active:
		visual_emergency_phone.visible = false
	if visual_alarm_switch != null and not alarm_active:
		visual_alarm_switch.visible = false

# ============================================================
# CALLS
# ============================================================

func _start_call() -> void:
	if not game_started or paused or game_over:
		return
	if stage < 3 or call_active:
		return

	call_active = true
	ambient_resume_after_msec = Time.get_ticks_msec() + 60_000
	call_answered = false
	call_locks_button = false
	call_seconds_left = 8
	active_caller = _choose_caller()
	caller_label.text = "INCOMING CALL: " + active_caller
	caller_timer_label.text = "Answer the desk phone"
	_start_phone_ring()
	call_ring_timer.start(8.0)
	_show_status("PHONE RINGING", 1.2)

func _choose_caller() -> String:
	var candidates: Array = CALLERS.duplicate()
	if active_caller != "" and candidates.size() > 1:
		candidates.erase(active_caller)
	return str(candidates[rng.randi_range(0, candidates.size() - 1)])

func _answer_phone() -> void:
	if not game_started or paused or game_over:
		return
	if not call_active or call_answered:
		_show_status("Nobody is calling.", 0.9)
		return

	call_answered = true
	call_ring_timer.stop()
	_stop_phone_ring()
	call_seconds_left = _caller_duration(active_caller)
	call_locks_button = active_caller == "LIL TIMMY"
	call_duration_timer.start(float(call_seconds_left))
	caller_label.text = "ON CALL: " + active_caller
	active_call_line = ""
	call_line_index = 0
	_play_call_opening(active_caller)
	if call_line_timer != null:
		call_line_timer.start()

func _caller_duration(caller: String) -> int:
	match caller:
		"LIL TIMMY":
			return 38
		"KIM":
			return 34
		"PUTIN":
			return 42
		"XI":
			return 34
		_:
			return 34

func _set_call_dialogue(message: String) -> void:
	active_call_line = message
	caller_timer_label.text = active_call_line
	_say("%s: %s" % [active_caller, active_call_line])

func _advance_call_dialogue() -> void:
	if not call_active or not call_answered:
		if call_line_timer != null:
			call_line_timer.stop()
		return

	var script_value: Variant = CALL_SCRIPTS.get(active_caller, [])
	if not (script_value is Array):
		return
	var lines: Array = script_value as Array
	if call_line_index >= lines.size():
		if call_line_timer != null:
			call_line_timer.stop()
		return

	_set_call_dialogue(str(lines[call_line_index]))
	call_line_index += 1

func _play_call_opening(caller: String) -> void:
	match caller:
		"KIM":
			enemy_pressure += 8.0
		"PUTIN":
			chaos += 3.0
		"LIL TIMMY":
			_show_status("TIMMY HAS THE BUTTON LOCKED", 1.6)
	_advance_call_dialogue()

func _finish_answered_call() -> void:
	if not call_active:
		return

	if call_line_timer != null:
		call_line_timer.stop()

	match active_caller:
		"KIM":
			enemy_pressure += 6.0
		"PUTIN":
			chaos += 1.0

	call_active = false
	ambient_resume_after_msec = Time.get_ticks_msec() + 3500
	call_answered = false
	call_locks_button = false
	active_call_line = ""
	call_line_index = 0
	caller_label.text = ""
	caller_timer_label.text = ""
	_show_status("CALL ENDED", 1.0)

func _miss_call() -> void:
	if not call_active or call_answered:
		return
	call_active = false
	active_call_line = ""
	call_line_index = 0
	if call_line_timer != null:
		call_line_timer.stop()
	ambient_resume_after_msec = Time.get_ticks_msec() + 1500
	approval -= 4.0
	chaos += 3.0
	_stop_phone_ring()
	caller_label.text = ""
	caller_timer_label.text = ""
	_show_status("MISSED CALL", 1.2)

# ============================================================
# PAPERWORK
# ============================================================

func _start_paperwork() -> void:
	if not game_started or paused or game_over:
		return
	if stage < 4 or paperwork_active:
		return

	paperwork_active = true
	paper_seconds_left = 10

	if visual_paper != null:
		visual_paper.visible = true
		visual_paper.texture_normal = visual_paper_normal_tex
		visual_paper.position = visual_paper_home + Vector2(330.0, 0.0)
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(visual_paper, "position", visual_paper_home, 0.35)

	paper_timer.start(10.0)
	_show_status("URGENT PAPERWORK — CLICK THE DOCUMENT", 1.8)
	_update_ui()

func _sign_paperwork() -> void:
	if not game_started or paused or game_over or not paperwork_active:
		return

	paperwork_active = false
	paper_timer.stop()
	approval += 3.0
	chaos = max(0.0, chaos - 2.0)
	_show_status("DOCUMENT SIGNED — APPROVAL +3", 1.4)

	if visual_paper != null:
		var tween := create_tween()
		tween.tween_property(visual_paper, "position", visual_paper_home + Vector2(330.0, 0.0), 0.24)
		tween.finished.connect(_hide_paper_after_sign)

	_update_ui()

func _hide_paper_after_sign() -> void:
	if visual_paper != null:
		visual_paper.visible = false
		visual_paper.position = visual_paper_home

func _miss_paperwork() -> void:
	if not paperwork_active:
		return
	paperwork_active = false
	if visual_paper != null:
		visual_paper.visible = false
		visual_paper.position = visual_paper_home
	approval -= 7.0
	chaos += 8.0
	_show_status("PAPERWORK IGNORED", 1.3)
	_update_ui()

# ============================================================
# STAGE 5 — CRISIS MANAGEMENT
# ============================================================

func _start_crisis() -> void:
	if not game_started or paused or game_over:
		return
	if stage < 5 or crisis_active:
		return

	crisis_active = true
	crisis_seconds_left = 9
	if visual_emergency_phone != null:
		visual_emergency_phone.visible = true
		visual_emergency_phone.position = visual_emergency_home + Vector2(190.0, 0.0)
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(visual_emergency_phone, "position", visual_emergency_home, 0.28)
	_start_emergency_phone_ring()
	crisis_timer.start(9.0)
	_show_status("CRISIS ALERT — CLICK THE RED EMERGENCY PHONE!", 2.0)
	_update_ui()

func _handle_crisis() -> void:
	if not game_started or paused or game_over or not crisis_active:
		return

	crisis_active = false
	crisis_timer.stop()
	if visual_emergency_phone != null:
		visual_emergency_phone.visible = false
		visual_emergency_phone.position = visual_emergency_home
	_stop_emergency_phone_ring()
	approval += 2.0
	chaos = max(0.0, chaos - 10.0)
	enemy_pressure = max(0.0, enemy_pressure - 10.0)
	_show_status("CRISIS CONTAINED", 1.5)
	_update_ui()

func _miss_crisis() -> void:
	if not crisis_active:
		return
	crisis_active = false
	if visual_emergency_phone != null:
		visual_emergency_phone.visible = false
		visual_emergency_phone.position = visual_emergency_home
	_stop_emergency_phone_ring()
	approval -= 9.0
	chaos += 18.0
	enemy_pressure += 15.0
	_camera_shake(0.14, 0.45)
	_show_status("CRISIS ESCALATED", 1.7)
	_update_ui()

# ============================================================
# STAGE 6 — ABSOLUTE CHAOS
# ============================================================

func _start_alarm() -> void:
	if not game_started or paused or game_over:
		return
	if stage < 6 or alarm_active:
		return

	alarm_active = true
	alarm_seconds_left = 7
	if visual_alarm_switch != null:
		visual_alarm_switch.visible = true
		visual_alarm_switch.modulate = Color("#ffd773")
	alarm_timer.start(7.0)
	_show_status("OFFICE ALARM — CLICK THE AMBER SWITCH!", 1.8)
	_camera_shake(0.06, 0.25)
	_update_ui()

func _reset_alarm() -> void:
	if not game_started or paused or game_over or not alarm_active:
		return

	alarm_active = false
	alarm_timer.stop()
	if visual_alarm_switch != null:
		visual_alarm_switch.visible = false
		visual_alarm_switch.modulate = Color.WHITE
	chaos = max(0.0, chaos - 12.0)
	_show_status("ALARM RESET", 1.2)
	_update_ui()

func _miss_alarm() -> void:
	if not alarm_active:
		return
	alarm_active = false
	if visual_alarm_switch != null:
		visual_alarm_switch.visible = false
		visual_alarm_switch.modulate = Color.WHITE
	chaos += 22.0
	approval -= 5.0
	_show_status("ALARM IGNORED — CHAOS SPIKE", 1.5)
	_update_ui()

# ============================================================
# UPGRADES
# ============================================================

func _buy_upgrade(index: int) -> void:
	if not game_started or paused or game_over:
		return
	if index < 0 or index >= UPGRADES.size():
		return

	var upgrade: Dictionary = UPGRADES[index]
	var upgrade_id: String = str(upgrade["id"])
	if purchased_upgrades.has(upgrade_id):
		return

	var cost: int = int(upgrade["cost"])
	if bombs < cost:
		_show_status("NOT ENOUGH BOMBS", 0.9)
		return

	bombs -= cost
	power += int(upgrade["power"])
	purchased_upgrades.append(upgrade_id)
	_show_status("%s PURCHASED" % str(upgrade["name"]), 1.2)
	_save_game()
	_update_ui()

# ============================================================
# DIFFICULTY / MENU / SETTINGS
# ============================================================

func _start_new_game() -> void:
	if not world_ready:
		_set_startup_step("PLEASE WAIT — THE OFFICE IS STILL LOADING")
		return
	if dev_access_unlocked and _dev_modifiers_active():
		dev_session_active = true
	_stop_menu_background_cycle(true)
	bombs = 0
	lifetime_bombs = 0
	level_launches = 0
	current_level_index = 0
	campaign_complete = false
	power = 1
	stage = 1
	enemy_pressure = 0.0
	heat = 0.0
	approval = 50.0
	chaos = 0.0
	purchased_upgrades.clear()
	_reset_runtime_events()
	upgrade_panel_open = false
	game_started = true
	paused = false
	game_over = false
	level_transition_active = false
	level_gimmick_accum = 0.0
	last_launch_time = Time.get_ticks_msec() / 1000.0
	main_menu.visible = false
	pause_menu.visible = false
	game_over_panel.visible = false
	if fallback_bg != null:
		fallback_bg.visible = false
	if visual_root != null:
		visual_root.visible = true
	hud_root.visible = true
	_refresh_menu_backdrop()
	_apply_current_level(true, true)
	_save_game()
	_update_ui()

func _continue_game() -> void:
	if not world_ready:
		_set_startup_step("PLEASE WAIT — THE OFFICE IS STILL LOADING")
		return
	if screen_transition_active:
		return
	screen_transition_active = true
	await _fade_to_black()
	_stop_menu_background_cycle(true)
	if not _load_game():
		screen_transition_active = false
		await _fade_from_black()
		_start_new_game()
		return
	if dev_access_unlocked and _dev_modifiers_active():
		dev_session_active = true
	if campaign_complete:
		game_started = false
		main_menu.visible = true
		if startup_label != null:
			startup_label.text = "CAMPAIGN COMPLETE — START A NEW GAME TO PLAY AGAIN"
		_show_saved_level_as_menu_background()
		_update_menu_buttons()
		await _fade_from_black()
		screen_transition_active = false
		return
	game_started = true
	paused = false
	game_over = false
	upgrade_panel_open = false
	main_menu.visible = false
	pause_menu.visible = false
	game_over_panel.visible = false
	if fallback_bg != null:
		fallback_bg.visible = false
	if visual_root != null:
		visual_root.visible = true
	hud_root.visible = true
	_refresh_menu_backdrop()
	last_launch_time = Time.get_ticks_msec() / 1000.0
	_apply_current_level(true, false)
	_show_status("WELCOME BACK — LEVEL %d/%d • %s" % [current_level_index + 1, CAMPAIGN_LEVELS.size(), str(_current_level_data()["name"])], 2.2)
	_update_ui()
	await _fade_from_black()
	screen_transition_active = false

func _return_to_main_menu() -> void:
	if screen_transition_active:
		return
	screen_transition_active = true
	# Fade the active level out before revealing the menu over that same location.
	await _fade_to_black()
	if game_started and not game_over:
		_save_game()
	_reset_runtime_events()
	_close_upgrade_terminal()
	game_started = false
	dev_session_active = false
	paused = false
	get_tree().paused = false
	if fallback_bg != null and not world_ready:
		fallback_bg.visible = true
	main_menu.visible = true
	pause_menu.visible = false
	settings_menu.visible = false
	credits_menu.visible = false
	game_over_panel.visible = false
	if difficulty_select_panel != null:
		difficulty_select_panel.visible = false
	if level_complete_panel != null:
		level_complete_panel.visible = false
	if dev_code_panel != null:
		dev_code_panel.visible = false
	if dev_panel != null:
		dev_panel.visible = false
	if dev_map_preview != null:
		dev_map_preview.visible = false
	dev_minimized = dev_access_unlocked
	_refresh_dev_launcher_visibility()
	if mirror_overlay != null:
		mirror_overlay.visible = false
	if level_intro_root != null:
		level_intro_root.visible = false
	level_intro_active = false
	level_intro_token += 1
	if multiplayer_menu != null:
		multiplayer_menu.visible = false
	if multiplayer_role_menu != null:
		multiplayer_role_menu.visible = false
	if multiplayer_hud != null:
		multiplayer_hud.visible = false
	if multiplayer_arena != null and is_instance_valid(multiplayer_arena):
		multiplayer_arena.queue_free()
	multiplayer_arena = null
	if online_multiplayer_ui != null:
		online_multiplayer_ui.visible = false
	if update_panel != null and update_panel.visible and pending_update_info.is_empty():
		update_panel.visible = false
	if OnlineMultiplayer.connected or OnlineMultiplayer.is_host:
		OnlineMultiplayer.leave_session()
	lan_match_session = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	dev_sequence_index = 0
	hud_root.visible = false
	if visual_root != null and world_ready:
		visual_root.visible = true
	# Resume the rotating map showcase, starting on the campaign location the player just left.
	_start_menu_background_cycle(current_level_index)
	_refresh_menu_backdrop()
	_update_menu_buttons()
	await _fade_from_black()
	screen_transition_active = false

func _toggle_pause() -> void:
	if not game_started or game_over:
		return
	paused = not paused
	get_tree().paused = paused
	pause_menu.visible = paused
	_refresh_menu_backdrop()

func _resume_game() -> void:
	paused = false
	get_tree().paused = false
	pause_menu.visible = false
	_refresh_menu_backdrop()

func _cycle_difficulty() -> void:
	difficulty_index = (difficulty_index + 1) % DIFFICULTIES.size()
	difficulty_button.text = "DIFFICULTY — " + str(DIFFICULTIES[difficulty_index]["name"])
	_save_settings()
	_update_ui()

func _toggle_subtitles() -> void:
	subtitles_enabled = not subtitles_enabled
	subtitle_toggle_button.text = "SUBTITLES — " + ("ON" if subtitles_enabled else "OFF")
	if not subtitles_enabled:
		subtitle_label.text = ""
	_save_settings()

func _apply_window_mode() -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen_enabled
		else DisplayServer.WINDOW_MODE_WINDOWED
	)

func _toggle_fullscreen() -> void:
	fullscreen_enabled = not fullscreen_enabled
	_apply_window_mode()
	if fullscreen_toggle_button != null:
		fullscreen_toggle_button.text = "FULLSCREEN — " + ("ON" if fullscreen_enabled else "OFF")
	_save_settings()

func _open_settings() -> void:
	settings_menu.visible = true
	_refresh_menu_backdrop()

func _close_settings() -> void:
	settings_menu.visible = false
	_refresh_menu_backdrop()

func _credits_main_text() -> String:
	return """[center][font_size=26][b]TRUMP SIMULATOR[/b][/font_size]
[i]A Simulated Studios Game[/i][/center]

[b]Created by[/b]
Scarlett Doughty

[b]Game Design[/b]
Scarlett Doughty
Peyton Bailey

[b]Original Concept & Game Ideas[/b]
Peyton Bailey

[b]Programming & Development[/b]
Scarlett Doughty
Simulated Studios

[b]Writing & Dialogue[/b]
Scarlett Doughty
Peyton Bailey

[b]Multiplayer Concepts & Design[/b]
Peyton Bailey
Scarlett Doughty

[b]Environment & Level Design[/b]
Simulated Studios

[b]UI Design[/b]
Simulated Studios

[font_size=18][b]VOICE CAST[/b][/font_size]

[b]Trump[/b] — Scarlett Doughty
[b]Putin[/b] — Scarlett Doughty
[b]Kim Jong Un[/b] — Scarlett Doughty
[b]Xi Jinping[/b] — Peyton Bailey
[b]Lil Timmy[/b] — Peyton Bailey
[b]Biden[/b] — Leon Havey

[b]Sound Design & Effects[/b]
All sound effects and recorded dialogue are original content produced for Trump Simulator.

[b]Music[/b]
No music is used in Trump Simulator.

[b]Artwork & Assets[/b]
All game artwork and assets are original project content created for Trump Simulator.

[b]Special Thanks[/b]
Playtesters
Everyone who helped test the game and gave feedback.

[b]Technology[/b]
Made with Godot Engine.

[center][i]Thanks for playing Trump Simulator.[/i]
— Simulated Studios[/center]
"""

func _credits_license_text() -> String:
	return """[center][font_size=24][b]OPEN SOURCE LICENCES[/b][/font_size][/center]

[b]Godot Engine[/b]
Trump Simulator is made with the Godot Engine.

Godot is free and open-source software distributed under the MIT License.

The complete Godot MIT license text is included with this project at:

[code]legal/GODOT_LICENSE.txt[/code]

[b]Third-party game assets[/b]
None currently used.

All game artwork, visual assets, sound effects, and recorded dialogue are original project content.

[b]Music[/b]
No music is used in Trump Simulator.
"""

func _show_main_credits() -> void:
	credits_showing_licenses = false
	if credits_title_label != null:
		credits_title_label.text = "CREDITS"
	if credits_body != null:
		credits_body.text = _credits_main_text()
	if credits_license_button != null:
		credits_license_button.text = "OPEN SOURCE LICENCES"

func _toggle_credits_licenses() -> void:
	credits_showing_licenses = not credits_showing_licenses
	if credits_showing_licenses:
		if credits_title_label != null:
			credits_title_label.text = "OPEN SOURCE"
		if credits_body != null:
			credits_body.text = _credits_license_text()
		if credits_license_button != null:
			credits_license_button.text = "BACK TO CREDITS"
	else:
		_show_main_credits()

func _open_credits() -> void:
	_show_main_credits()
	credits_menu.visible = true
	_refresh_menu_backdrop()

func _close_credits() -> void:
	credits_menu.visible = false
	credits_showing_licenses = false
	_refresh_menu_backdrop()

func _quit_game() -> void:
	Engine.time_scale = 1.0
	get_tree().quit()

# ============================================================
# SAVE / LOAD
# ============================================================

func _save_game() -> void:
	if not game_started or dev_session_active:
		return

	var data: Dictionary = {
		"version": VERSION,
		"bombs": bombs,
		"lifetime_bombs": lifetime_bombs,
		"power": power,
		"stage": stage,
		"difficulty_index": difficulty_index,
		"approval": approval,
		"purchased_upgrades": purchased_upgrades,
		"current_level_index": current_level_index,
		"level_launches": level_launches,
		"campaign_complete": campaign_complete,
	}

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))

func _load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false

	bombs = int(parsed.get("bombs", 0))
	lifetime_bombs = int(parsed.get("lifetime_bombs", 0))
	power = int(parsed.get("power", 1))
	stage = int(parsed.get("stage", 1))
	difficulty_index = clampi(int(parsed.get("difficulty_index", 1)), 0, DIFFICULTIES.size() - 1)
	approval = float(parsed.get("approval", 50.0))
	current_level_index = clampi(int(parsed.get("current_level_index", 0)), 0, CAMPAIGN_LEVELS.size() - 1)
	level_launches = maxi(0, int(parsed.get("level_launches", 0)))
	campaign_complete = bool(parsed.get("campaign_complete", false))
	purchased_upgrades.clear()
	for item in parsed.get("purchased_upgrades", []):
		purchased_upgrades.append(str(item))

	enemy_pressure = 0.0
	heat = 0.0
	chaos = 0.0
	level_transition_active = false
	level_gimmick_accum = 0.0
	_reset_runtime_events()
	_recalculate_campaign_stage(false)
	return true

func _save_settings() -> void:
	var data: Dictionary = {
		"subtitles": subtitles_enabled,
		"fullscreen": fullscreen_enabled,
		"difficulty_index": difficulty_index,
	}
	var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))

func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return

	var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	subtitles_enabled = true
	fullscreen_enabled = bool(parsed.get("fullscreen", false))
	difficulty_index = clampi(int(parsed.get("difficulty_index", 1)), 0, DIFFICULTIES.size() - 1)

# ============================================================
# GAME OVER
# ============================================================

func _trigger_game_over(reason: String) -> void:
	if game_over:
		return
	if dev_god_mode:
		approval = maxf(approval, 10.0)
		chaos = minf(chaos, 90.0)
		_show_status("DEV GOD MODE PREVENTED GAME OVER", 1.4)
		_update_ui()
		return

	game_over = true
	_close_upgrade_terminal()
	paused = false
	get_tree().paused = false
	_reset_runtime_events()

	var title := game_over_panel.get_node("GameOverTitle") as Label
	var reason_label := game_over_panel.get_node("GameOverReason") as Label
	title.text = "THE OFFICE HAS FALLEN"
	reason_label.text = reason
	game_over_panel.visible = true
	_refresh_menu_backdrop()

func _restart_after_game_over() -> void:
	if not _load_game():
		_start_new_game()
		return
	game_started = true
	paused = false
	game_over = false
	upgrade_panel_open = false
	level_transition_active = false
	get_tree().paused = false
	game_over_panel.visible = false
	if fallback_bg != null:
		fallback_bg.visible = false
	if visual_root != null:
		visual_root.visible = true
	hud_root.visible = true
	last_launch_time = Time.get_ticks_msec() / 1000.0
	_apply_current_level(true, false)
	_refresh_menu_backdrop()
	_show_status("CHECKPOINT RESTORED — %s" % str(_current_level_data()["name"]), 2.0)
	_update_ui()

# ============================================================
# TIMERS / RANDOM EVENT DIRECTOR
# ============================================================

func _build_timers() -> void:
	event_timer = Timer.new()
	event_timer.wait_time = 5.0
	event_timer.timeout.connect(_on_event_tick)
	add_child(event_timer)
	event_timer.start()

	call_ring_timer = Timer.new()
	call_ring_timer.one_shot = true
	call_ring_timer.timeout.connect(_miss_call)
	add_child(call_ring_timer)

	call_duration_timer = Timer.new()
	call_duration_timer.one_shot = true
	call_duration_timer.timeout.connect(_finish_answered_call)
	add_child(call_duration_timer)

	call_line_timer = Timer.new()
	call_line_timer.one_shot = false
	call_line_timer.wait_time = 5.5
	call_line_timer.timeout.connect(_advance_call_dialogue)
	add_child(call_line_timer)

	paper_timer = Timer.new()
	paper_timer.one_shot = true
	paper_timer.timeout.connect(_miss_paperwork)
	add_child(paper_timer)

	crisis_timer = Timer.new()
	crisis_timer.one_shot = true
	crisis_timer.timeout.connect(_miss_crisis)
	add_child(crisis_timer)

	alarm_timer = Timer.new()
	alarm_timer.one_shot = true
	alarm_timer.timeout.connect(_miss_alarm)
	add_child(alarm_timer)

func _on_event_tick() -> void:
	if not dev_random_events_enabled:
		return
	if not game_started or paused or game_over or level_intro_active or level_transition_active:
		return

	var diff: Dictionary = DIFFICULTIES[difficulty_index]
	var level_data: Dictionary = _current_level_data()
	var rate: float = float(diff["events"]) * float(level_data.get("events", 1.0))

	if stage >= 3 and not call_active:
		if rng.randf() < min(0.80, 0.26 * rate):
			_start_call()

	if stage >= 4 and not paperwork_active:
		if rng.randf() < min(0.80, 0.22 * rate):
			_start_paperwork()

	if stage >= 5 and not crisis_active:
		if rng.randf() < min(0.75, 0.18 * rate):
			_start_crisis()

	if stage >= 6 and not alarm_active:
		if rng.randf() < min(0.75, 0.18 * rate):
			_start_alarm()

func _reset_runtime_events() -> void:
	call_active = false
	call_answered = false
	call_locks_button = false
	active_caller = ""
	active_call_line = ""
	call_line_index = 0
	ambient_resume_after_msec = 0
	paperwork_active = false
	crisis_active = false
	alarm_active = false

	if call_ring_timer != null:
		call_ring_timer.stop()
	if call_duration_timer != null:
		call_duration_timer.stop()
	if call_line_timer != null:
		call_line_timer.stop()
	if paper_timer != null:
		paper_timer.stop()
	if crisis_timer != null:
		crisis_timer.stop()
	if alarm_timer != null:
		alarm_timer.stop()

	_stop_phone_ring()
	_stop_emergency_phone_ring()

	if visual_paper != null:
		visual_paper.visible = false
		visual_paper.position = visual_paper_home
	if visual_emergency_phone != null:
		visual_emergency_phone.visible = false
		visual_emergency_phone.position = visual_emergency_home
	if visual_alarm_switch != null:
		visual_alarm_switch.visible = false

	if caller_label != null:
		caller_label.text = ""
	if caller_timer_label != null:
		caller_timer_label.text = ""

	_close_upgrade_terminal()

# ============================================================
# ANIMATION
# ============================================================

func _press_button_animation() -> void:
	button_busy = true
	if visual_button == null:
		button_busy = false
		return

	var start_scale := Vector2.ONE
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(visual_button, "scale", Vector2(0.94, 0.94), 0.035)
	tween.tween_property(visual_button, "scale", start_scale, 0.065)
	tween.finished.connect(_button_animation_finished)
	_camera_shake(0.006, 0.07)

func _button_animation_finished() -> void:
	button_busy = false

func _set_button_hot(hot: bool) -> void:
	if visual_button == null:
		return
	visual_button.texture_normal = visual_button_hot_tex if hot else visual_button_normal_tex

func _start_phone_ring() -> void:
	if visual_phone == null:
		return
	visual_phone.texture_normal = visual_phone_ring_tex
	visual_phone.texture_hover = visual_phone_ring_tex
	if visual_phone.has_meta("ring_tween"):
		var old_tween: Tween = visual_phone.get_meta("ring_tween") as Tween
		if old_tween != null and is_instance_valid(old_tween):
			old_tween.kill()

	var tween := create_tween().set_loops()
	tween.tween_property(visual_phone, "rotation", deg_to_rad(-2.0), 0.08)
	tween.tween_property(visual_phone, "rotation", deg_to_rad(2.0), 0.08)
	visual_phone.set_meta("ring_tween", tween)

func _stop_phone_ring() -> void:
	if visual_phone == null:
		return
	if visual_phone.has_meta("ring_tween"):
		var tween_value: Tween = visual_phone.get_meta("ring_tween") as Tween
		if tween_value != null and is_instance_valid(tween_value):
			tween_value.kill()
	visual_phone.rotation = 0.0
	visual_phone.texture_normal = visual_phone_normal_tex
	visual_phone.texture_hover = visual_phone_normal_tex

func _start_emergency_phone_ring() -> void:
	if visual_emergency_phone == null:
		return
	if visual_emergency_phone.has_meta("ring_tween"):
		var old_tween: Tween = visual_emergency_phone.get_meta("ring_tween") as Tween
		if old_tween != null and is_instance_valid(old_tween):
			old_tween.kill()
	var tween := create_tween().set_loops()
	tween.tween_property(visual_emergency_phone, "rotation", deg_to_rad(-2.5), 0.07)
	tween.tween_property(visual_emergency_phone, "rotation", deg_to_rad(2.5), 0.07)
	visual_emergency_phone.set_meta("ring_tween", tween)

func _stop_emergency_phone_ring() -> void:
	if visual_emergency_phone == null:
		return
	if visual_emergency_phone.has_meta("ring_tween"):
		var tween_value: Tween = visual_emergency_phone.get_meta("ring_tween") as Tween
		if tween_value != null and is_instance_valid(tween_value):
			tween_value.kill()
	visual_emergency_phone.rotation = 0.0

func _camera_shake(amount: float, duration: float) -> void:
	if visual_root == null:
		return

	var start := visual_root_home
	var pixel_amount: float = amount * 95.0
	var tween := create_tween()
	for i in range(6):
		var offset := Vector2(
			rng.randf_range(-pixel_amount, pixel_amount),
			rng.randf_range(-pixel_amount, pixel_amount)
		)
		tween.tween_property(visual_root, "position", start + offset, duration / 6.0)
	tween.tween_property(visual_root, "position", start, 0.04)

# ============================================================
# UI BUILD
# ============================================================

func _visual_panel_style(
	background: Color,
	border: Color,
	border_width: int = 2,
	corner_radius: int = 10
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(corner_radius)
	style.shadow_color = Color(0, 0, 0, 0.35)
	style.shadow_size = 8
	return style

func _visual_label(
	text_value: String,
	position_value: Vector2,
	size_value: Vector2,
	font_size_value: int,
	parent: Control,
	text_color: Color = Color("#ecf6ff")
) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = position_value
	label.size = size_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size_value)
	label.add_theme_color_override("font_color", text_color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _map_rect(parent: Node, pos: Vector2, size_value: Vector2, color_value: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.position = pos
	rect.size = size_value
	rect.color = color_value
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect

func _map_panel(parent: Node, pos: Vector2, size_value: Vector2, background: Color, border: Color = Color(0, 0, 0, 0), border_width: int = 0, radius: int = 0) -> Panel:
	var panel := Panel.new()
	panel.position = pos
	panel.size = size_value
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel

func _map_text(parent: Node, text_value: String, pos: Vector2, size_value: Vector2, font_size_value: int, color_value: Color, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = pos
	label.size = size_value
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size_value)
	label.add_theme_color_override("font_color", color_value)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.70))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _map_polygon(parent: Node, points: Array, color_value: Color) -> Polygon2D:
	var poly := Polygon2D.new()
	var packed := PackedVector2Array()
	for point in points:
		if point is Vector2:
			packed.append(point)
	poly.polygon = packed
	poly.color = color_value
	parent.add_child(poly)
	return poly

func _map_line(parent: Node, points: Array, color_value: Color, width_value: float = 2.0) -> Line2D:
	var line := Line2D.new()
	for point in points:
		if point is Vector2:
			line.add_point(point)
	line.default_color = color_value
	line.width = width_value
	line.antialiased = true
	parent.add_child(line)
	return line

func _map_flag(parent: Node, pos: Vector2, size_value: Vector2, colors: Array, vertical: bool = true) -> void:
	var pole_x: float = pos.x - 10.0
	_map_rect(parent, Vector2(pole_x, pos.y - 12.0), Vector2(5, size_value.y + 60.0), Color("#7c5b31"))
	_map_panel(parent, Vector2(pole_x - 7.0, pos.y + size_value.y + 46.0), Vector2(19, 8), Color("#b7904c"), Color("#60431f"), 1, 2)
	if colors.is_empty():
		return
	if vertical:
		var stripe_width: float = size_value.x / float(colors.size())
		for i in range(colors.size()):
			_map_rect(parent, pos + Vector2(stripe_width * i, 0), Vector2(stripe_width + 1.0, size_value.y), colors[i])
	else:
		var stripe_height: float = size_value.y / float(colors.size())
		for i in range(colors.size()):
			_map_rect(parent, pos + Vector2(0, stripe_height * i), Vector2(size_value.x, stripe_height + 1.0), colors[i])

func _map_window(parent: Node, pos: Vector2, size_value: Vector2, sky: Color, ground: Color, rounded: int = 8) -> void:
	_map_panel(parent, pos, size_value, Color("#e8e0d0"), Color("#786d5f"), 5, rounded)
	_map_rect(parent, pos + Vector2(9, 9), Vector2(size_value.x - 18, size_value.y * 0.60), sky)
	_map_rect(parent, pos + Vector2(9, 9 + size_value.y * 0.60), Vector2(size_value.x - 18, size_value.y * 0.31), ground)
	_map_rect(parent, pos + Vector2(size_value.x * 0.5 - 2, 9), Vector2(4, size_value.y - 18), Color(0.83, 0.82, 0.77, 0.9))

func _map_chair(parent: Node, pos: Vector2, size_value: Vector2, color_value: Color) -> void:
	_map_panel(parent, pos, size_value, color_value, Color(0.08, 0.07, 0.06, 0.8), 3, 18)
	_map_panel(parent, pos + Vector2(18, 22), Vector2(size_value.x - 36, size_value.y * 0.52), color_value.lightened(0.08), Color(0.12, 0.10, 0.08, 0.8), 2, 14)
	_map_rect(parent, pos + Vector2(12, size_value.y - 14), Vector2(size_value.x - 24, 22), color_value.darkened(0.10))

func _map_desk(parent: Node, top_y: float, wood: Color, edge: Color, mat: Color) -> void:
	_map_polygon(parent, [Vector2(65, top_y), Vector2(1215, top_y), Vector2(1280, 720), Vector2(0, 720)], wood)
	_map_rect(parent, Vector2(55, top_y), Vector2(1170, 22), edge)
	_map_panel(parent, Vector2(375, top_y + 42), Vector2(530, 150), mat, mat.lightened(0.18), 3, 4)
	# Three shadow/placement zones indicate where interactive objects belong without painting fake controls.
	_map_panel(parent, Vector2(525, top_y + 65), Vector2(230, 104), Color(0, 0, 0, 0.16), Color(0, 0, 0, 0), 0, 35)
	_map_panel(parent, Vector2(82, top_y + 75), Vector2(235, 100), Color(0, 0, 0, 0.10), Color(0, 0, 0, 0), 0, 28)
	_map_panel(parent, Vector2(842, top_y + 75), Vector2(270, 100), Color(0, 0, 0, 0.10), Color(0, 0, 0, 0), 0, 28)

func _map_monitor_shell(parent: Node, pos: Vector2, size_value: Vector2 = Vector2(290, 120), accent: Color = Color("#334a5c")) -> void:
	_map_panel(parent, pos - Vector2(12, 10), size_value + Vector2(24, 20), Color("#242a31"), Color("#11161c"), 4, 10)
	_map_panel(parent, pos, size_value, Color("#10202b"), accent, 3, 6)
	_map_rect(parent, pos + Vector2(size_value.x * 0.44, size_value.y), Vector2(size_value.x * 0.12, 25), Color("#303238"))

func _map_picture(parent: Node, pos: Vector2, size_value: Vector2, frame: Color, art: Color, label_text: String = "") -> void:
	_map_panel(parent, pos, size_value, frame, frame.darkened(0.35), 3, 3)
	_map_rect(parent, pos + Vector2(8, 8), size_value - Vector2(16, 16), art)
	if label_text != "":
		_map_text(parent, label_text, pos + Vector2(8, size_value.y * 0.52), Vector2(size_value.x - 16, 28), 10, Color(1,1,1,0.85))

func _map_lamp(parent: Node, pos: Vector2, shade: Color = Color("#efe4bb")) -> void:
	_map_polygon(parent, [pos + Vector2(-28,0), pos + Vector2(28,0), pos + Vector2(18,42), pos + Vector2(-18,42)], shade)
	_map_rect(parent, pos + Vector2(-3,42), Vector2(6,70), Color("#8a682f"))
	_map_panel(parent, pos + Vector2(-28,108), Vector2(56,10), Color("#b38a38"), Color("#765b25"), 1, 4)

func _clear_map_environment() -> void:
	if visual_map_decor_root == null:
		return
	for child in visual_map_decor_root.get_children():
		child.queue_free()

func _build_current_map_environment() -> void:
	if visual_map_decor_root == null or visual_background == null:
		return
	_clear_map_environment()
	var visual_id: String = str(_current_level_data().get("visual", "oval_office"))
	visual_background.visible = visual_id == "oval_office"
	visual_map_decor_root.visible = visual_id != "oval_office"
	match visual_id:
		"putins_office": _build_map_putins_office()
		"unicef_office": _build_map_unicef_office()
		"un_meeting": _build_map_un_meeting()
		"air_force_one": _build_map_air_force_one()
		"rally_backstage": _build_map_rally_backstage()
		"g20_summit": _build_map_g20_summit()
		"emergency_bunker": _build_map_emergency_bunker()
		"golf_club": _build_map_golf_club()
		"presidential_nightmare": _build_map_presidential_nightmare()
		_: pass

func _build_map_putins_office() -> void:
	var p: Node = visual_map_decor_root
	_map_rect(p, Vector2.ZERO, Vector2(1280,720), Color("#3b2118"))
	_map_rect(p, Vector2(0,0), Vector2(1280,95), Color("#23140f"))
	for x in [70, 290, 510, 730, 950, 1170]:
		_map_rect(p, Vector2(float(x), 95), Vector2(8,390), Color("#5b3425"))
		_map_rect(p, Vector2(float(x)+12, 100), Vector2(3,380), Color("#2d1812"))
	_map_picture(p, Vector2(535,75), Vector2(210,125), Color("#a17b35"), Color("#5c625b"), "KREMLIN OFFICE")
	_map_flag(p, Vector2(335,115), Vector2(105,230), [Color("#ffffff"),Color("#2453a6"),Color("#b62d2d")], false)
	_map_flag(p, Vector2(850,115), Vector2(105,230), [Color("#ffffff"),Color("#2453a6"),Color("#b62d2d")], false)
	_map_chair(p, Vector2(500,205), Vector2(280,250), Color("#1d1a18"))
	_map_picture(p, Vector2(1110,110), Vector2(95,125), Color("#8f6a32"), Color("#42474a"), "HOST")
	_map_lamp(p, Vector2(120,295), Color("#d8c693"))
	_map_lamp(p, Vector2(1130,295), Color("#d8c693"))
	_map_monitor_shell(p, Vector2(70,315), Vector2(290,120), Color("#425e70"))
	_map_desk(p, 485.0, Color("#4f2b1d"), Color("#25140f"), Color("#211b19"))
	_map_text(p, "MOSCOW • SECURE OFFICE", Vector2(455,445), Vector2(370,30), 12, Color("#c9a96b"))

func _build_map_unicef_office() -> void:
	var p: Node = visual_map_decor_root
	_map_rect(p, Vector2.ZERO, Vector2(1280,720), Color("#dce9ee"))
	_map_rect(p, Vector2(0,0), Vector2(1280,88), Color("#76b9cf"))
	_map_rect(p, Vector2(0,88), Vector2(1280,14), Color("#ffffff"))
	_map_window(p, Vector2(870,130), Vector2(260,230), Color("#9fd8ef"), Color("#8ab477"), 12)
	_map_panel(p, Vector2(120,130), Vector2(360,220), Color("#f4efe2"), Color("#9a8768"), 4, 6)
	_map_text(p, "FIELD REQUESTS", Vector2(145,145), Vector2(310,34), 18, Color("#356273"))
	for i in range(3):
		_map_panel(p, Vector2(155 + i*95,195), Vector2(75,105), Color("#ffffff"), Color("#b4cbd4"), 2, 4)
		_map_rect(p, Vector2(165 + i*95,207), Vector2(55,34), [Color("#f3c96b"), Color("#7fc0d8"), Color("#96c982")][i])
	_map_panel(p, Vector2(545,125), Vector2(250,180), Color("#ffffff"), Color("#75b5cc"), 4, 12)
	_map_text(p, "INTERNATIONAL\nAID OFFICE", Vector2(565,145), Vector2(210,82), 22, Color("#3a8eac"))
	_map_text(p, "TRUMP VISIT", Vector2(565,230), Vector2(210,36), 12, Color("#6f7f84"))
	_map_monitor_shell(p, Vector2(90,310), Vector2(290,120), Color("#4e8ea5"))
	_map_lamp(p, Vector2(1160,290), Color("#e7ddbb"))
	_map_panel(p, Vector2(1030,365), Vector2(90,110), Color("#7fa966"), Color("#4e7040"), 2, 12)
	_map_rect(p, Vector2(1068,330), Vector2(12,55), Color("#4a7041"))
	_map_desk(p, 485.0, Color("#b48557"), Color("#765138"), Color("#335b51"))
	_map_text(p, "DONATION FORMS • STAFF REQUESTS • FIELD REPORTS", Vector2(390,447), Vector2(500,30), 12, Color("#466d75"))

func _build_map_un_meeting() -> void:
	var p: Node = visual_map_decor_root
	_map_rect(p, Vector2.ZERO, Vector2(1280,720), Color("#26393f"))
	_map_rect(p, Vector2(0,0), Vector2(1280,100), Color("#17272c"))
	_map_panel(p, Vector2(480,105), Vector2(320,170), Color("#244d5b"), Color("#b69a5a"), 4, 8)
	_map_text(p, "UNITED NATIONS\nMEETING", Vector2(500,130), Vector2(280,90), 28, Color("#eef5f4"))
	_map_text(p, "DELEGATES PRESENT", Vector2(500,220), Vector2(280,28), 11, Color("#c7d9d8"))
	var flag_colors = [Color("#b33a3a"), Color("#3568a6"), Color("#e7e1c8"), Color("#4f8a62"), Color("#d2a342")]
	for i in range(8):
		var fx: float = 85.0 + float(i) * 145.0
		_map_flag(p, Vector2(fx,145), Vector2(48,150), [flag_colors[i%flag_colors.size()], Color("#f4f1e8")], true)
	_map_chair(p, Vector2(515,300), Vector2(250,150), Color("#26282b"))
	_map_monitor_shell(p, Vector2(505,300), Vector2(270,103), Color("#4d7d86"))
	_map_polygon(p, [Vector2(0,440),Vector2(1280,440),Vector2(1130,720),Vector2(150,720)], Color("#5e4935"))
	_map_panel(p, Vector2(455,455), Vector2(370,52), Color("#e4ded0"), Color("#9c8558"), 3, 4)
	_map_text(p, "UNITED STATES", Vector2(465,462), Vector2(350,38), 18, Color("#29343a"))
	_map_desk(p, 500.0, Color("#574330"), Color("#2c241d"), Color("#2a3634"))

func _build_map_air_force_one() -> void:
	var p: Node = visual_map_decor_root
	_map_rect(p, Vector2.ZERO, Vector2(1280,720), Color("#e6dfcf"))
	_map_rect(p, Vector2(0,0), Vector2(1280,78), Color("#d6caa9"))
	_map_rect(p, Vector2(0,78), Vector2(1280,16), Color("#31577a"))
	for x in [90, 360, 830, 1100]:
		_map_panel(p, Vector2(float(x),135), Vector2(170,170), Color("#c9c2b4"), Color("#857c6e"), 4, 55)
		_map_panel(p, Vector2(float(x)+14,149), Vector2(142,142), Color("#92cbe3"), Color("#f3eee2"), 6, 48)
		_map_rect(p, Vector2(float(x)+18,230), Vector2(134,57), Color("#daeaf0"))
	_map_panel(p, Vector2(510,145), Vector2(260,200), Color("#d8d0c2"), Color("#9f957f"), 3, 20)
	_map_text(p, "PRESIDENTIAL\nAIRCRAFT", Vector2(530,180), Vector2(220,85), 25, Color("#2d4c66"))
	_map_chair(p, Vector2(520,300), Vector2(240,160), Color("#2e4660"))
	_map_monitor_shell(p, Vector2(75,320), Vector2(290,115), Color("#4d7188"))
	_map_desk(p, 485.0, Color("#8d6a47"), Color("#513b2a"), Color("#2f4b58"))
	_map_text(p, "CABIN STATUS • CRUISING", Vector2(455,445), Vector2(370,28), 12, Color("#587081"))

func _build_map_rally_backstage() -> void:
	var p: Node = visual_map_decor_root
	_map_rect(p, Vector2.ZERO, Vector2(1280,720), Color("#121114"))
	_map_rect(p, Vector2(0,0), Vector2(1280,95), Color("#08080a"))
	for x in [90,260,430,600,770,940,1110]:
		_map_polygon(p, [Vector2(float(x),0),Vector2(float(x)+55,0),Vector2(float(x)+120,360),Vector2(float(x)-65,360)], Color(0.55,0.10,0.08,0.22))
	_map_rect(p, Vector2(180,120), Vector2(540,190), Color("#8c1e22"))
	_map_panel(p, Vector2(195,135), Vector2(510,160), Color("#17171b"), Color("#b99a59"), 3, 4)
	_map_text(p, "RALLY\nBACKSTAGE", Vector2(215,155), Vector2(470,110), 32, Color("#f0e2bd"))
	_map_panel(p, Vector2(760,130), Vector2(350,220), Color("#242129"), Color("#5c5661"), 3, 4)
	_map_text(p, "STAGE ACCESS", Vector2(785,145), Vector2(300,30), 14, Color("#d4c7ae"))
	for i in range(4):
		_map_rect(p, Vector2(790,195+i*34), Vector2(270,16), Color(0.4,0.8,0.45,0.35 if i<3 else 0.20))
	_map_monitor_shell(p, Vector2(875,300), Vector2(285,110), Color("#8d4545"))
	_map_panel(p, Vector2(45,315), Vector2(250,150), Color("#2d2925"), Color("#4d4033"), 2, 4)
	_map_text(p, "EQUIPMENT\nCASES", Vector2(60,340), Vector2(220,90), 16, Color("#b8aa91"))
	_map_desk(p, 485.0, Color("#422a22"), Color("#1b1310"), Color("#281b1b"))
	_map_text(p, "CROWD LEVEL • LOUD", Vector2(470,447), Vector2(340,28), 12, Color("#dfb8a0"))

func _build_map_g20_summit() -> void:
	var p: Node = visual_map_decor_root
	_map_rect(p, Vector2.ZERO, Vector2(1280,720), Color("#334449"))
	_map_rect(p, Vector2(0,0), Vector2(1280,95), Color("#202e32"))
	_map_panel(p, Vector2(470,100), Vector2(340,155), Color("#435b61"), Color("#c4a96a"), 4, 8)
	_map_text(p, "WORLD LEADERS\nSUMMIT", Vector2(495,125), Vector2(290,90), 27, Color("#eef2e9"))
	var cols=[Color("#a43d42"),Color("#3e6595"),Color("#d2b853"),Color("#5b8b65"),Color("#e9e5d9")]
	for i in range(10):
		var x: float=55.0+float(i)*120.0
		_map_flag(p, Vector2(x,155), Vector2(40,135), [cols[i%cols.size()], Color("#f3f0e8")], true)
	_map_chair(p, Vector2(520,300), Vector2(240,145), Color("#252b2d"))
	_map_monitor_shell(p, Vector2(505,300), Vector2(270,103), Color("#55747a"))
	_map_polygon(p,[Vector2(40,425),Vector2(1240,425),Vector2(1100,650),Vector2(180,650)],Color("#62503b"))
	_map_panel(p, Vector2(515,450), Vector2(250,42), Color("#e8e2d2"), Color("#9e8958"), 2, 3)
	_map_text(p, "UNITED STATES", Vector2(525,454), Vector2(230,32), 15, Color("#30383a"))
	_map_desk(p, 500.0, Color("#574430"), Color("#2a211b"), Color("#273a39"))

func _build_map_emergency_bunker() -> void:
	var p: Node = visual_map_decor_root
	_map_rect(p, Vector2.ZERO, Vector2(1280,720), Color("#242a2d"))
	_map_rect(p, Vector2(0,0), Vector2(1280,90), Color("#14191b"))
	for x in range(0,1280,160):
		_map_rect(p, Vector2(float(x),90), Vector2(8,390), Color("#3e474b"))
	_map_rect(p, Vector2(0,130), Vector2(1280,12), Color("#515d62"))
	_map_rect(p, Vector2(0,390), Vector2(1280,10), Color("#15191b"))
	_map_panel(p, Vector2(455,115), Vector2(370,150), Color("#171c1f"), Color("#a8413b"), 4, 4)
	_map_text(p, "EMERGENCY\nCOMMAND", Vector2(480,138), Vector2(320,84), 28, Color("#f0c5b4"))
	_map_text(p, "SECURITY STATUS ACTIVE", Vector2(480,220), Vector2(320,25), 11, Color("#d98f79"))
	_map_monitor_shell(p, Vector2(70,300), Vector2(300,120), Color("#6a4242"))
	_map_monitor_shell(p, Vector2(910,300), Vector2(300,120), Color("#6a4242"))
	_map_rect(p, Vector2(410,285), Vector2(20,150), Color("#5a6469"))
	_map_rect(p, Vector2(850,285), Vector2(20,150), Color("#5a6469"))
	_map_chair(p, Vector2(520,300), Vector2(240,155), Color("#202528"))
	_map_desk(p, 485.0, Color("#3d4141"), Color("#1d2020"), Color("#252b2c"))
	_map_text(p, "BUNKER SYSTEMS • ARMED", Vector2(455,447), Vector2(370,28), 12, Color("#dc9e8c"))

func _build_map_golf_club() -> void:
	var p: Node = visual_map_decor_root
	_map_rect(p, Vector2.ZERO, Vector2(1280,720), Color("#d7c8aa"))
	_map_rect(p, Vector2(0,0), Vector2(1280,95), Color("#6a452c"))
	_map_rect(p, Vector2(0,95), Vector2(1280,15), Color("#a47a52"))
	_map_window(p, Vector2(430,120), Vector2(420,270), Color("#91cbe7"), Color("#6fa05a"), 10)
	_map_rect(p, Vector2(445,310), Vector2(390,70), Color("#5c8c49"))
	_map_polygon(p,[Vector2(445,330),Vector2(600,260),Vector2(835,335),Vector2(835,380),Vector2(445,380)],Color("#86ad66"))
	_map_lamp(p, Vector2(145,285), Color("#eadcb2"))
	_map_panel(p, Vector2(990,150), Vector2(155,245), Color("#5f4029"), Color("#3e291b"), 3, 8)
	_map_text(p, "CLUB\nTROPHIES", Vector2(1000,160), Vector2(135,58), 16, Color("#e2c985"))
	for i in range(3):
		_map_panel(p, Vector2(1020,230+i*50), Vector2(95,28), Color("#b08b3d"), Color("#725823"), 2, 6)
	_map_monitor_shell(p, Vector2(75,315), Vector2(285,115), Color("#65745b"))
	_map_chair(p, Vector2(520,300), Vector2(240,160), Color("#704d37"))
	_map_desk(p, 485.0, Color("#805636"), Color("#4d321f"), Color("#36573e"))
	_map_text(p, "TEE TIME • DELAYED AGAIN", Vector2(455,447), Vector2(370,28), 12, Color("#587048"))

func _build_map_presidential_nightmare() -> void:
	var p: Node = visual_map_decor_root
	_map_rect(p, Vector2.ZERO, Vector2(1280,720), Color("#17121a"))
	_map_rect(p, Vector2(0,0), Vector2(1280,110), Color("#260e13"))
	_map_polygon(p,[Vector2(0,0),Vector2(300,0),Vector2(620,470),Vector2(380,470)],Color(0.55,0.06,0.08,0.28))
	_map_polygon(p,[Vector2(1280,0),Vector2(980,0),Vector2(660,470),Vector2(900,470)],Color(0.12,0.26,0.48,0.25))
	_map_window(p, Vector2(70,155), Vector2(220,190), Color("#84384b"), Color("#382a35"), 8)
	_map_flag(p, Vector2(330,130), Vector2(75,210), [Color("#b33232"),Color("#e8e4d8"),Color("#315b91")], false)
	_map_flag(p, Vector2(890,130), Vector2(75,210), [Color("#e8e4d8"),Color("#315b91"),Color("#b33232")], false)
	_map_panel(p, Vector2(485,105), Vector2(310,155), Color("#291924"), Color("#c94f45"), 4, 8)
	_map_text(p, "PRESIDENTIAL\nNIGHTMARE", Vector2(510,126), Vector2(260,90), 28, Color("#ffd5b9"))
	_map_monitor_shell(p, Vector2(505,290), Vector2(270,103), Color("#8e3c3c"))
	_map_monitor_shell(p, Vector2(925,300), Vector2(265,110), Color("#63345f"))
	_map_panel(p, Vector2(90,370), Vector2(240,70), Color("#22222a"), Color("#c54848"), 3, 4)
	_map_text(p, "ALERTS: TOO MANY", Vector2(105,385), Vector2(210,38), 14, Color("#ffb7a5"))
	_map_chair(p, Vector2(520,300), Vector2(240,160), Color("#211b22"))
	_map_desk(p, 485.0, Color("#42272a"), Color("#190f11"), Color("#251d27"))
	_map_text(p, "ALL SYSTEMS • OVERLAPPING", Vector2(445,447), Vector2(390,28), 12, Color("#eea99d"))

func _build_visual_reboot_scene() -> void:
	visual_root = Control.new()
	visual_root.name = "VisualReboot"
	visual_root.position = Vector2.ZERO
	visual_root.size = Vector2(1280, 720)
	visual_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(visual_root)
	visual_root.visible = false

	visual_background = TextureRect.new()
	visual_background.name = "SeatedOvalOfficeBackground"
	visual_background.position = Vector2.ZERO
	visual_background.size = Vector2(1280, 720)
	visual_background.texture = load("res://assets/visual_reboot/office_seated_background.png") as Texture2D
	visual_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	visual_background.stretch_mode = TextureRect.STRETCH_SCALE
	visual_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual_root.add_child(visual_background)

	# Maps 2–10 are built from real Godot nodes at runtime. They intentionally do
	# not contain baked-in buttons, phones, paperwork or fake HUD elements.
	visual_map_decor_root = Control.new()
	visual_map_decor_root.name = "BuiltMapEnvironment"
	visual_map_decor_root.position = Vector2.ZERO
	visual_map_decor_root.size = Vector2(1280, 720)
	visual_map_decor_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual_map_decor_root.visible = false
	visual_root.add_child(visual_map_decor_root)

	# Main launch-control readout sits inside the monitor frame painted into the Oval Office
	# and inside runtime-built monitor shells in all later maps.
	visual_main_monitor = _visual_label(
		"LAUNCH CONTROL\n0 READY   •   +1 / CLICK\nSTAGE 1 — THE BUTTON",
		Vector2(505, 321),
		Vector2(270, 103),
		18,
		visual_root,
		Color("#c9f4ff")
	)

	visual_heat_label = _visual_label(
		"TEMP • OK",
		Vector2(565, 438),
		Vector2(150, 24),
		13,
		visual_root,
		Color("#f1d687")
	)

	# Compact secondary status cards — deliberately much quieter than the old wall of screens.
	visual_approval_card = Panel.new()
	visual_approval_card.position = Vector2(32, 26)
	visual_approval_card.size = Vector2(205, 64)
	visual_approval_card.add_theme_stylebox_override(
		"panel",
		_visual_panel_style(Color(0.035, 0.08, 0.13, 0.90), Color("#c8a65a"), 2, 10)
	)
	visual_root.add_child(visual_approval_card)
	visual_approval_label = _visual_label(
		"APPROVAL 50%\nHOLDING",
		Vector2.ZERO,
		Vector2(205, 64),
		14,
		visual_approval_card,
		Color("#f2e1aa")
	)

	visual_chaos_card = Panel.new()
	visual_chaos_card.position = Vector2(1043, 26)
	visual_chaos_card.size = Vector2(205, 64)
	visual_chaos_card.add_theme_stylebox_override(
		"panel",
		_visual_panel_style(Color(0.035, 0.08, 0.13, 0.90), Color("#c8a65a"), 2, 10)
	)
	visual_root.add_child(visual_chaos_card)
	visual_chaos_label = _visual_label(
		"OFFICE STATUS\nSTABLE",
		Vector2.ZERO,
		Vector2(205, 64),
		14,
		visual_chaos_card,
		Color("#f2e1aa")
	)

	visual_threat_card = Panel.new()
	visual_threat_card.position = Vector2(515, 80)
	visual_threat_card.size = Vector2(250, 58)
	visual_threat_card.add_theme_stylebox_override(
		"panel",
		_visual_panel_style(Color(0.06, 0.045, 0.025, 0.92), Color("#c98b46"), 2, 10)
	)
	visual_root.add_child(visual_threat_card)
	visual_threat_label = _visual_label(
		"ENEMY PRESSURE 0%",
		Vector2.ZERO,
		Vector2(250, 58),
		14,
		visual_threat_card,
		Color("#ffd59b")
	)
	visual_threat_card.visible = false

	visual_level_card = Panel.new()
	visual_level_card.position = Vector2(420, 18)
	visual_level_card.size = Vector2(440, 50)
	visual_level_card.add_theme_stylebox_override("panel", _visual_panel_style(Color(0.03, 0.055, 0.09, 0.88), Color(0.86, 0.74, 0.42, 0.72), 2, 10))
	visual_root.add_child(visual_level_card)
	visual_level_label = _visual_label("LEVEL 1/10 • OVAL OFFICE", Vector2.ZERO, Vector2(440, 50), 13, visual_level_card, Color("#f3e4b3"))

	# Hero button.
	visual_button_normal_tex = load("res://assets/visual_reboot/button_normal.png") as Texture2D
	visual_button_pressed_tex = load("res://assets/visual_reboot/button_pressed.png") as Texture2D
	visual_button_hot_tex = load("res://assets/visual_reboot/button_hot.png") as Texture2D

	visual_button = TextureButton.new()
	visual_button.name = "LaunchButton2D"
	visual_button.position = Vector2(550, 533)
	visual_button.size = Vector2(180, 112)
	visual_button.texture_normal = visual_button_normal_tex
	visual_button.texture_pressed = visual_button_pressed_tex
	visual_button.texture_hover = visual_button_normal_tex
	visual_button.ignore_texture_size = true
	visual_button.stretch_mode = TextureButton.STRETCH_SCALE
	visual_button.tooltip_text = "Click to launch"
	visual_button.pressed.connect(_launch_bombs)
	visual_button.pivot_offset = visual_button.size * 0.5
	visual_root.add_child(visual_button)

	# Phone.
	visual_phone_normal_tex = load("res://assets/visual_reboot/phone_normal.png") as Texture2D
	visual_phone_ring_tex = load("res://assets/visual_reboot/phone_ring.png") as Texture2D
	visual_phone = TextureButton.new()
	visual_phone.name = "DeskPhone2D"
	visual_phone.position = visual_phone_home
	visual_phone.size = Vector2(240, 147)
	visual_phone.texture_normal = visual_phone_normal_tex
	visual_phone.texture_hover = visual_phone_normal_tex
	visual_phone.ignore_texture_size = true
	visual_phone.stretch_mode = TextureButton.STRETCH_SCALE
	visual_phone.tooltip_text = "Desk phone"
	visual_phone.pressed.connect(_answer_phone)
	visual_phone.pivot_offset = visual_phone.size * 0.5
	visual_root.add_child(visual_phone)

	visual_phone_status = _visual_label(
		"PHONE • STANDBY",
		Vector2(192, 607),
		Vector2(205, 24),
		11,
		visual_root,
		Color("#d8eadf")
	)

	# Paperwork.
	visual_paper_normal_tex = load("res://assets/visual_reboot/paper_normal.png") as Texture2D
	visual_paper_hover_tex = load("res://assets/visual_reboot/paper_hover.png") as Texture2D
	visual_paper = TextureButton.new()
	visual_paper.name = "Paperwork2D"
	visual_paper.position = visual_paper_home
	visual_paper.size = Vector2(195, 136)
	visual_paper.texture_normal = visual_paper_normal_tex
	visual_paper.texture_hover = visual_paper_hover_tex
	visual_paper.ignore_texture_size = true
	visual_paper.stretch_mode = TextureButton.STRETCH_SCALE
	visual_paper.tooltip_text = "Urgent paperwork — click to sign"
	visual_paper.pressed.connect(_sign_paperwork)
	visual_paper.visible = false
	visual_root.add_child(visual_paper)

	# Stage-five emergency phone.
	visual_emergency_phone = TextureButton.new()
	visual_emergency_phone.name = "EmergencyPhone2D"
	visual_emergency_phone.position = visual_emergency_home
	visual_emergency_phone.size = Vector2(180, 110)
	visual_emergency_phone.texture_normal = load("res://assets/visual_reboot/emergency_phone.png") as Texture2D
	visual_emergency_phone.ignore_texture_size = true
	visual_emergency_phone.stretch_mode = TextureButton.STRETCH_SCALE
	visual_emergency_phone.tooltip_text = "Emergency phone"
	visual_emergency_phone.pressed.connect(_handle_crisis)
	visual_emergency_phone.pivot_offset = visual_emergency_phone.size * 0.5
	visual_emergency_phone.visible = false
	visual_root.add_child(visual_emergency_phone)

	# Stage-six alarm reset.
	visual_alarm_switch = TextureButton.new()
	visual_alarm_switch.name = "AlarmSwitch2D"
	visual_alarm_switch.position = Vector2(405, 515)
	visual_alarm_switch.size = Vector2(120, 100)
	visual_alarm_switch.texture_normal = load("res://assets/visual_reboot/alarm_switch.png") as Texture2D
	visual_alarm_switch.ignore_texture_size = true
	visual_alarm_switch.stretch_mode = TextureButton.STRETCH_SCALE
	visual_alarm_switch.tooltip_text = "Reset office alarm"
	visual_alarm_switch.pressed.connect(_reset_alarm)
	visual_alarm_switch.visible = false
	visual_root.add_child(visual_alarm_switch)

	# Clickable upgrades control — avoids hiding an important gameplay action behind a keyboard shortcut.
	visual_upgrade_button = Button.new()
	visual_upgrade_button.text = "UPGRADES"
	visual_upgrade_button.position = Vector2(1090, 650)
	visual_upgrade_button.size = Vector2(145, 42)
	visual_upgrade_button.add_theme_font_size_override("font_size", 13)
	visual_upgrade_button.add_theme_stylebox_override(
		"normal",
		_visual_panel_style(Color(0.04, 0.10, 0.16, 0.94), Color("#d0ad5c"), 2, 8)
	)
	visual_upgrade_button.add_theme_stylebox_override(
		"hover",
		_visual_panel_style(Color(0.08, 0.18, 0.28, 0.98), Color("#e2c36f"), 2, 8)
	)
	visual_upgrade_button.pressed.connect(_toggle_upgrade_terminal)
	visual_root.add_child(visual_upgrade_button)

func _build_ui() -> void:
	layer = CanvasLayer.new()
	add_child(layer)

	# Deliberate dark fallback background. If the 3D renderer/scene has a
	# problem, the player still gets a readable menu rather than grey.
	fallback_bg = ColorRect.new()
	fallback_bg.name = "FallbackBackground"
	fallback_bg.color = Color("#07111d")
	fallback_bg.position = Vector2(0, 0)
	fallback_bg.size = Vector2(1280, 720)
	fallback_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(fallback_bg)

	_build_visual_reboot_scene()
	_build_menu_scene_fade()
	_build_loading_screen()

	hud_root = Control.new()
	hud_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hud_root)
	hud_root.visible = false

	menu_backdrop = ColorRect.new()
	menu_backdrop.name = "MenuBackdrop"
	menu_backdrop.color = Color(0, 0, 0, 0.24)
	menu_backdrop.position = Vector2.ZERO
	menu_backdrop.size = Vector2(1280, 720)
	menu_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_backdrop.visible = false
	layer.add_child(menu_backdrop)

	_build_hud()
	_build_upgrade_panel()
	_build_main_menu()
	_build_pause_menu()
	_build_settings_menu()
	_build_credits_menu()
	_build_multiplayer_ui()
	_build_update_panel()
	_build_difficulty_select_panel()
	_build_level_complete_panel()
	_build_game_over_panel()
	_build_dev_ui()
	_build_level_intro_overlay()
	_build_mirror_overlay()
	_build_transition_fade()
	_update_menu_buttons()

func _build_loading_screen() -> void:
	loading_root = Control.new()
	loading_root.name = "LoadingScreen"
	loading_root.position = Vector2.ZERO
	loading_root.size = Vector2(1280, 720)
	loading_root.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(loading_root)

	var loading_bg := ColorRect.new()
	loading_bg.color = Color("#050d17")
	loading_bg.position = Vector2.ZERO
	loading_bg.size = Vector2(1280, 720)
	loading_root.add_child(loading_bg)

	# Soft decorative bands give it a finished game-launcher feel.
	var top_band := ColorRect.new()
	top_band.color = Color("#0b1c2f")
	top_band.position = Vector2(0, 0)
	top_band.size = Vector2(1280, 92)
	loading_root.add_child(top_band)

	var bottom_band := ColorRect.new()
	bottom_band.color = Color("#081522")
	bottom_band.position = Vector2(0, 610)
	bottom_band.size = Vector2(1280, 110)
	loading_root.add_child(bottom_band)

	var studio := Label.new()
	studio.text = "SIMULATED STUDIOS"
	studio.position = Vector2(0, 116)
	studio.size = Vector2(1280, 32)
	studio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	studio.add_theme_font_size_override("font_size", 18)
	studio.modulate = Color("#d8b967")
	loading_root.add_child(studio)

	var title := Label.new()
	title.text = "TRUMP SIMULATOR"
	title.position = Vector2(0, 170)
	title.size = Vector2(1280, 68)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 50)
	title.modulate = Color("#f3f6fa")
	loading_root.add_child(title)

	var edition := Label.new()
	edition.text = "DESKTOP EDITION"
	edition.position = Vector2(0, 239)
	edition.size = Vector2(1280, 28)
	edition.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	edition.add_theme_font_size_override("font_size", 13)
	edition.modulate = Color("#9fb0c1")
	loading_root.add_child(edition)

	loading_panel = Panel.new()
	_make_panel_opaque(loading_panel, Color(0.06, 0.10, 0.15, 0.86))
	loading_panel.position = Vector2(310, 330)
	loading_panel.size = Vector2(660, 172)
	loading_root.add_child(loading_panel)

	loading_status_label = Label.new()
	loading_status_label.text = "Preparing the Oval Office..."
	loading_status_label.position = Vector2(32, 25)
	loading_status_label.size = Vector2(596, 28)
	loading_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_status_label.add_theme_font_size_override("font_size", 16)
	loading_panel.add_child(loading_status_label)

	loading_bar = ProgressBar.new()
	loading_bar.min_value = 0.0
	loading_bar.max_value = 100.0
	loading_bar.value = 0.0
	loading_bar.show_percentage = false
	loading_bar.position = Vector2(48, 72)
	loading_bar.size = Vector2(564, 22)
	loading_panel.add_child(loading_bar)

	loading_percent_label = Label.new()
	loading_percent_label.text = "0%"
	loading_percent_label.position = Vector2(48, 103)
	loading_percent_label.size = Vector2(564, 24)
	loading_percent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_percent_label.add_theme_font_size_override("font_size", 13)
	loading_percent_label.modulate = Color("#d8b967")
	loading_panel.add_child(loading_percent_label)

	loading_tip_label = Label.new()
	loading_tip_label.text = "TIP: Click the red button — it is always the priority."
	loading_tip_label.position = Vector2(170, 637)
	loading_tip_label.size = Vector2(940, 36)
	loading_tip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_tip_label.add_theme_font_size_override("font_size", 13)
	loading_tip_label.modulate = Color("#a9b8c6")
	loading_root.add_child(loading_tip_label)

	var version := Label.new()
	version.text = "v" + VERSION
	version.position = Vector2(1135, 678)
	version.size = Vector2(110, 22)
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	version.add_theme_font_size_override("font_size", 10)
	version.modulate = Color("#718394")
	loading_root.add_child(version)

func _update_loading_screen(step_number: int, status_text: String, tip_text: String) -> void:
	if loading_root == null:
		return

	var clamped_step: int = clampi(step_number, 0, 8)
	var percent: int = int(round((float(clamped_step) / 8.0) * 100.0))

	if loading_bar != null:
		loading_bar.value = float(percent)
	if loading_percent_label != null:
		loading_percent_label.text = str(percent) + "%"
	if loading_status_label != null:
		loading_status_label.text = status_text
	if loading_tip_label != null:
		loading_tip_label.text = tip_text

func _finish_loading_screen() -> void:
	if fallback_bg != null:
		fallback_bg.visible = false
	if visual_root != null:
		visual_root.visible = true

	# Start the rotating home-menu showcase on the player's latest saved campaign location.
	_start_menu_background_cycle(_saved_menu_level_index())
	if main_menu != null:
		main_menu.visible = true
	_refresh_menu_backdrop()

	if loading_root == null:
		return

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(loading_root, "modulate:a", 0.0, 0.45)
	await tween.finished
	loading_root.visible = false
	loading_root.modulate.a = 1.0

	# Quietly check the website after the home menu is ready.
	# If the site cannot be reached, UpdateManager intentionally does nothing.
	await get_tree().create_timer(1.2).timeout
	UpdateManager.check_for_updates()

func _build_hud() -> void:
	# Gameplay information now lives on physical 3D screens in the office.
	# The screen-space HUD is intentionally limited to transient feedback,
	# subtitles/accessibility, and a small controls hint.

	status_label = Label.new()
	status_label.position = Vector2(350, 145)
	status_label.size = Vector2(580, 54)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	status_label.add_theme_constant_override("shadow_offset_x", 2)
	status_label.add_theme_constant_override("shadow_offset_y", 2)
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(status_label)

	subtitle_label = Label.new()
	subtitle_label.position = Vector2(220, 615)
	subtitle_label.size = Vector2(840, 55)
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.add_theme_font_size_override("font_size", 18)
	subtitle_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(subtitle_label)

	var hint := Label.new()
	hint.text = "Click the red button to launch • Phone / paperwork are clickable • U = upgrades • Esc = pause"
	hint.position = Vector2(18, 690)
	hint.add_theme_font_size_override("font_size", 11)
	hud_root.add_child(hint)

	# Hidden compatibility nodes. Caller state is shown on the physical phone display.
	bomb_label = Label.new()
	power_label = Label.new()
	stage_label = Label.new()
	difficulty_hud_label = Label.new()
	caller_label = Label.new()
	caller_timer_label = Label.new()
	for hidden_label in [bomb_label, power_label, stage_label, difficulty_hud_label, caller_label, caller_timer_label]:
		hidden_label.visible = false
		hud_root.add_child(hidden_label)

func _meter(label_text: String, parent: Control) -> ProgressBar:
	var label := Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 11)
	parent.add_child(label)

	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 100
	bar.value = 0
	bar.show_percentage = true
	bar.custom_minimum_size = Vector2(255, 15)
	parent.add_child(bar)
	return bar

func _build_upgrade_panel() -> void:
	upgrade_panel = Panel.new()
	upgrade_panel.position = Vector2(835, 205)
	upgrade_panel.size = Vector2(410, 385)
	hud_root.add_child(upgrade_panel)
	upgrade_panel.visible = false

	var title := Label.new()
	title.text = "DESK UPGRADE TERMINAL"
	title.position = Vector2(18, 14)
	title.add_theme_font_size_override("font_size", 18)
	upgrade_panel.add_child(title)

	var note := Label.new()
	note.text = "The office does NOT pause while this terminal is open."
	note.position = Vector2(18, 43)
	note.add_theme_font_size_override("font_size", 11)
	upgrade_panel.add_child(note)

	for i in range(UPGRADES.size()):
		var upgrade: Dictionary = UPGRADES[i]
		var button := Button.new()
		button.position = Vector2(18, 75 + i * 50)
		button.size = Vector2(374, 41)
		button.pressed.connect(_buy_upgrade.bind(i))
		upgrade_panel.add_child(button)
		upgrade_buttons.append(button)

	var close := Button.new()
	close.text = "CLOSE TERMINAL"
	close.position = Vector2(18, 330)
	close.size = Vector2(374, 38)
	close.pressed.connect(_close_upgrade_terminal)
	upgrade_panel.add_child(close)


func _build_update_panel() -> void:
	update_panel = Panel.new()
	_make_panel_opaque(update_panel, Color(0.04, 0.07, 0.11, 0.92))
	update_panel.position = Vector2(335, 125)
	update_panel.size = Vector2(610, 470)
	layer.add_child(update_panel)
	update_panel.visible = false

	update_title_label = Label.new()
	update_title_label.text = "UPDATE AVAILABLE"
	update_title_label.position = Vector2(0, 30)
	update_title_label.size = Vector2(610, 38)
	update_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	update_title_label.add_theme_font_size_override("font_size", 28)
	update_panel.add_child(update_title_label)

	update_version_label = Label.new()
	update_version_label.position = Vector2(50, 80)
	update_version_label.size = Vector2(510, 32)
	update_version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	update_version_label.add_theme_font_size_override("font_size", 17)
	update_version_label.modulate = Color("#d9bd70")
	update_panel.add_child(update_version_label)

	update_notes_label = RichTextLabel.new()
	update_notes_label.position = Vector2(55, 130)
	update_notes_label.size = Vector2(500, 170)
	update_notes_label.bbcode_enabled = true
	update_notes_label.fit_content = false
	update_notes_label.scroll_active = true
	update_notes_label.add_theme_font_size_override("normal_font_size", 14)
	update_notes_label.add_theme_color_override("default_color", Color("#eef5ff"))
	update_panel.add_child(update_notes_label)

	update_status_label = Label.new()
	update_status_label.position = Vector2(55, 315)
	update_status_label.size = Vector2(500, 38)
	update_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	update_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	update_status_label.add_theme_font_size_override("font_size", 12)
	update_status_label.modulate = Color("#b9c5d1")
	update_panel.add_child(update_status_label)

	update_now_button = _menu_button("UPDATE NOW", Vector2(55, 380), update_panel)
	update_now_button.size = Vector2(240, 44)
	update_now_button.pressed.connect(_install_pending_update)

	update_later_button = _menu_button("LATER", Vector2(315, 380), update_panel)
	update_later_button.size = Vector2(240, 44)
	update_later_button.pressed.connect(_dismiss_update)

func _on_update_available(info: Dictionary) -> void:
	# Never interrupt active gameplay. Update checks run from the home menu anyway,
	# but this guard prevents a late network response from covering a match.
	if game_started or lan_match_session:
		return

	pending_update_info = info.duplicate(true)
	var new_version := str(info.get("version", ""))
	var notes := str(info.get("notes", "A new version of Trump Simulator is available."))
	var required := bool(info.get("required", false))

	update_version_label.text = "v%s  →  v%s" % [VERSION, new_version]
	update_notes_label.text = "[b]What's new[/b]\n\n" + notes
	update_status_label.text = "Download and install the update now?"
	update_now_button.disabled = false
	update_later_button.disabled = required
	update_later_button.text = "REQUIRED UPDATE" if required else "LATER"
	update_panel.visible = true
	_refresh_menu_backdrop()

func _dismiss_update() -> void:
	update_panel.visible = false
	_refresh_menu_backdrop()

func _on_update_status(message: String) -> void:
	if update_status_label != null:
		update_status_label.text = message

func _install_pending_update() -> void:
	if pending_update_info.is_empty():
		return
	update_now_button.disabled = true
	update_later_button.disabled = true
	update_status_label.text = "DOWNLOADING UPDATE..."

	var launched := await UpdateManager.download_and_launch_update()
	if launched:
		update_status_label.text = "INSTALLER STARTED — CLOSING GAME..."
		await get_tree().create_timer(0.35).timeout
		get_tree().quit()
		return

	update_now_button.disabled = false
	if not bool(pending_update_info.get("required", false)):
		update_later_button.disabled = false

func _build_main_menu() -> void:
	main_menu = Panel.new()
	_make_panel_opaque(main_menu, Color(0.05, 0.08, 0.12, 0.82))
	main_menu.position = Vector2(370, 60)
	main_menu.size = Vector2(540, 610)
	layer.add_child(main_menu)
	main_menu.visible = false

	var eyebrow := Label.new()
	eyebrow.text = "DESKTOP EDITION"
	eyebrow.position = Vector2(198, 35)
	eyebrow.add_theme_font_size_override("font_size", 13)
	main_menu.add_child(eyebrow)

	var title := Label.new()
	title.text = "TRUMP SIMULATOR"
	title.position = Vector2(78, 68)
	title.add_theme_font_size_override("font_size", 43)
	main_menu.add_child(title)

	var version_label := Label.new()
	version_label.text = "OFFICIAL RELEASE v" + VERSION
	version_label.position = Vector2(170, 122)
	version_label.add_theme_font_size_override("font_size", 11)
	main_menu.add_child(version_label)

	startup_label = Label.new()
	startup_label.text = "BOOTING..."
	startup_label.position = Vector2(45, 145)
	startup_label.size = Vector2(450, 24)
	startup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	startup_label.add_theme_font_size_override("font_size", 12)
	startup_label.modulate = Color("#d9bd70")
	main_menu.add_child(startup_label)

	var new_game := _menu_button("NEW GAME", Vector2(110, 178), main_menu)
	new_game.pressed.connect(_open_new_game_difficulty)

	continue_button = _menu_button("CONTINUE", Vector2(110, 232), main_menu)
	continue_button.pressed.connect(_continue_game)

	var multiplayer := _menu_button("MULTIPLAYER", Vector2(110, 286), main_menu)
	multiplayer.pressed.connect(_open_multiplayer_menu)

	var settings := _menu_button("SETTINGS", Vector2(110, 340), main_menu)
	settings.pressed.connect(_open_settings)

	var credits := _menu_button("CREDITS", Vector2(110, 394), main_menu)
	credits.pressed.connect(_open_credits)

	var quit := _menu_button("QUIT", Vector2(110, 448), main_menu)
	quit.pressed.connect(_quit_game)

func _menu_button(text_value: String, pos: Vector2, parent: Control) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = pos
	button.size = Vector2(320, 42)
	_style_menu_button(button)
	parent.add_child(button)
	return button

func _build_pause_menu() -> void:
	pause_menu = Panel.new()
	_make_panel_opaque(pause_menu, Color(0.05, 0.08, 0.12, 0.82))
	pause_menu.position = Vector2(420, 180)
	pause_menu.size = Vector2(440, 350)
	pause_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	layer.add_child(pause_menu)
	pause_menu.visible = false

	var title := Label.new()
	title.text = "PAUSED"
	title.position = Vector2(145, 40)
	title.add_theme_font_size_override("font_size", 35)
	pause_menu.add_child(title)

	var resume := _menu_button("RESUME", Vector2(60, 110), pause_menu)
	resume.pressed.connect(_resume_game)

	var save := _menu_button("SAVE GAME", Vector2(60, 164), pause_menu)
	save.pressed.connect(_save_game)

	var settings := _menu_button("SETTINGS", Vector2(60, 218), pause_menu)
	settings.pressed.connect(_open_settings)

	var menu := _menu_button("MAIN MENU", Vector2(60, 272), pause_menu)
	menu.pressed.connect(_return_to_main_menu)

func _build_settings_menu() -> void:
	settings_menu = Panel.new()
	_make_panel_opaque(settings_menu, Color(0.05, 0.08, 0.12, 0.82))
	settings_menu.position = Vector2(390, 145)
	settings_menu.size = Vector2(500, 430)
	settings_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	layer.add_child(settings_menu)
	settings_menu.visible = false

	var title := Label.new()
	title.text = "SETTINGS"
	title.position = Vector2(165, 32)
	title.add_theme_font_size_override("font_size", 30)
	settings_menu.add_child(title)

	subtitle_toggle_button = _menu_button("", Vector2(90, 100), settings_menu)
	subtitle_toggle_button.pressed.connect(_toggle_subtitles)

	fullscreen_toggle_button = _menu_button("", Vector2(90, 158), settings_menu)
	fullscreen_toggle_button.pressed.connect(_toggle_fullscreen)

	var mirror := _menu_button("OPEN MIRROR", Vector2(90, 216), settings_menu)
	mirror.pressed.connect(_open_mirror)


	var close := _menu_button("CLOSE", Vector2(90, 330), settings_menu)
	close.pressed.connect(_close_settings)


func _build_multiplayer_ui() -> void:
	multiplayer_menu = Panel.new()
	_make_panel_opaque(multiplayer_menu, Color(0.04, 0.07, 0.11, 0.86))
	multiplayer_menu.position = Vector2(360, 135)
	multiplayer_menu.size = Vector2(560, 455)
	layer.add_child(multiplayer_menu)
	multiplayer_menu.visible = false

	var title := Label.new()
	title.text = "MULTIPLAYER"
	title.position = Vector2(0, 34)
	title.size = Vector2(560, 38)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	multiplayer_menu.add_child(title)

	var note := Label.new()
	note.text = "LAN multiplayer scans for games on your local network. Local Practice is available for learning roles and viewpoints."
	note.position = Vector2(40, 82)
	note.size = Vector2(480, 52)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 12)
	note.modulate = Color("#aebdca")
	multiplayer_menu.add_child(note)

	var online := _menu_button("LAN — HOST / FIND GAMES", Vector2(120, 150), multiplayer_menu)
	online.pressed.connect(_open_online_multiplayer)

	var crisis := _menu_button("CRISIS ROOM — LOCAL PRACTICE", Vector2(120, 208), multiplayer_menu)
	crisis.pressed.connect(_open_multiplayer_roles.bind("crisis"))

	var debate := _menu_button("PRESIDENTIAL DEBATE — LOCAL PRACTICE", Vector2(120, 266), multiplayer_menu)
	debate.pressed.connect(_open_multiplayer_roles.bind("debate"))

	var back := _menu_button("BACK", Vector2(120, 350), multiplayer_menu)
	back.pressed.connect(_close_multiplayer_menu)

	multiplayer_role_menu = Panel.new()
	_make_panel_opaque(multiplayer_role_menu, Color(0.04, 0.07, 0.11, 0.88))
	multiplayer_role_menu.position = Vector2(250, 70)
	multiplayer_role_menu.size = Vector2(780, 590)
	layer.add_child(multiplayer_role_menu)
	multiplayer_role_menu.visible = false

	multiplayer_role_title = Label.new()
	multiplayer_role_title.position = Vector2(0, 28)
	multiplayer_role_title.size = Vector2(780, 36)
	multiplayer_role_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	multiplayer_role_title.add_theme_font_size_override("font_size", 27)
	multiplayer_role_menu.add_child(multiplayer_role_title)

	multiplayer_role_note = Label.new()
	multiplayer_role_note.position = Vector2(60, 72)
	multiplayer_role_note.size = Vector2(660, 55)
	multiplayer_role_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	multiplayer_role_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	multiplayer_role_note.add_theme_font_size_override("font_size", 12)
	multiplayer_role_note.modulate = Color("#aebdca")
	multiplayer_role_menu.add_child(multiplayer_role_note)

	var role_back := _menu_button("BACK", Vector2(230, 515), multiplayer_role_menu)
	role_back.pressed.connect(_back_to_multiplayer_games)

	multiplayer_hud = Panel.new()
	_make_panel_opaque(multiplayer_hud, Color(0.03, 0.05, 0.08, 0.68))
	multiplayer_hud.position = Vector2(18, 18)
	multiplayer_hud.size = Vector2(380, 102)
	layer.add_child(multiplayer_hud)
	multiplayer_hud.visible = false

	multiplayer_hud_title = Label.new()
	multiplayer_hud_title.position = Vector2(16, 12)
	multiplayer_hud_title.size = Vector2(348, 28)
	multiplayer_hud_title.add_theme_font_size_override("font_size", 17)
	multiplayer_hud.add_child(multiplayer_hud_title)

	multiplayer_hud_role = Label.new()
	multiplayer_hud_role.position = Vector2(16, 42)
	multiplayer_hud_role.size = Vector2(348, 44)
	multiplayer_hud_role.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	multiplayer_hud_role.add_theme_font_size_override("font_size", 11)
	multiplayer_hud_role.modulate = Color("#d8c27b")
	multiplayer_hud.add_child(multiplayer_hud_role)


func _open_online_multiplayer() -> void:
	if game_started:
		return

	if online_multiplayer_ui == null or not is_instance_valid(online_multiplayer_ui):
		var ui_script: Script = load("res://scripts/online/online_multiplayer_ui.gd") as Script
		if ui_script == null:
			# Never strand the player on a blank screen if a multiplayer file is missing.
			main_menu.visible = false
			multiplayer_menu.visible = true
			_refresh_menu_backdrop()
			return

		var ui := Control.new()
		ui.name = "OnlineMultiplayerUI"
		ui.set_script(ui_script)
		layer.add_child(ui)
		online_multiplayer_ui = ui

		if online_multiplayer_ui.has_signal("close_requested"):
			online_multiplayer_ui.connect("close_requested", _close_online_multiplayer)
		if online_multiplayer_ui.has_signal("launch_match"):
			online_multiplayer_ui.connect("launch_match", _launch_online_multiplayer_match)

	main_menu.visible = false
	multiplayer_menu.visible = false
	online_multiplayer_ui.visible = true
	if online_multiplayer_ui.has_method("show_home"):
		online_multiplayer_ui.call("show_home")
	_refresh_menu_backdrop()

func _close_online_multiplayer() -> void:
	if online_multiplayer_ui != null:
		online_multiplayer_ui.visible = false
	main_menu.visible = false
	multiplayer_menu.visible = true
	_refresh_menu_backdrop()

func _launch_online_multiplayer_match(mode_name: String, role_name: String) -> void:
	lan_match_session = true
	if online_multiplayer_ui != null:
		online_multiplayer_ui.visible = false
	_start_multiplayer_preview(mode_name, role_name)

func _open_multiplayer_menu() -> void:
	if game_started:
		return
	main_menu.visible = false
	multiplayer_menu.visible = true
	_refresh_menu_backdrop()

func _close_multiplayer_menu() -> void:
	multiplayer_menu.visible = false
	main_menu.visible = true
	_refresh_menu_backdrop()

func _clear_multiplayer_role_buttons() -> void:
	if multiplayer_role_menu == null:
		return
	for child in multiplayer_role_menu.get_children():
		if child is Button and child.name.begins_with("DynamicRole"):
			child.queue_free()

func _open_multiplayer_roles(mode_name: String) -> void:
	multiplayer_selected_mode = mode_name
	multiplayer_menu.visible = false
	multiplayer_role_menu.visible = true
	_clear_multiplayer_role_buttons()

	if mode_name == "crisis":
		multiplayer_role_title.text = "CRISIS ROOM — CHOOSE ROLE"
		multiplayer_role_note.text = "Every player is Trump. Roles change the station, information and responsibilities."
		var roles: Array[String] = ["INTEL", "LAUNCH", "RADAR", "COMMS"]
		for i in range(roles.size()):
			var b := _menu_button(roles[i] + " TRUMP", Vector2(230, 150 + i * 62), multiplayer_role_menu)
			b.name = "DynamicRole_" + roles[i]
			b.pressed.connect(_start_multiplayer_preview.bind("crisis", roles[i]))
	else:
		multiplayer_role_title.text = "PRESIDENTIAL DEBATE — CHOOSE ROLE"
		multiplayer_role_note.text = "Your first-person view is physically located at your podium, moderator desk or audience seat."
		var roles: Array[String] = ["TRUMP", "BIDEN", "MODERATOR", "AUDIENCE"]
		for i in range(roles.size()):
			var role_value: String = roles[i]
			var b := _menu_button(role_value, Vector2(230, 150 + i * 62), multiplayer_role_menu)
			b.name = "DynamicRole_" + role_value
			if role_value == "AUDIENCE":
				role_value = "AUDIENCE_7"
			b.pressed.connect(_start_multiplayer_preview.bind("debate", role_value))
	_refresh_menu_backdrop()

func _back_to_multiplayer_games() -> void:
	multiplayer_role_menu.visible = false
	multiplayer_menu.visible = true
	_refresh_menu_backdrop()

func _start_multiplayer_preview(mode_name: String, role_name: String) -> void:
	_stop_menu_background_cycle(true)
	multiplayer_role_menu.visible = false
	multiplayer_menu.visible = false
	main_menu.visible = false
	hud_root.visible = false
	if visual_root != null:
		visual_root.visible = false
	if fallback_bg != null:
		fallback_bg.visible = false

	if multiplayer_arena != null and is_instance_valid(multiplayer_arena):
		multiplayer_arena.queue_free()

	var arena_script: Script = load("res://scripts/multiplayer_arena.gd") as Script
	multiplayer_arena = Node3D.new()
	multiplayer_arena.name = "MultiplayerArenaRuntime"
	multiplayer_arena.set_script(arena_script)
	add_child(multiplayer_arena)
	multiplayer_arena.exit_requested.connect(_exit_multiplayer_preview)
	multiplayer_arena.role_changed.connect(_on_multiplayer_role_changed)
	multiplayer_arena.build_mode(mode_name, role_name)

	multiplayer_hud.visible = true
	multiplayer_hud_title.text = "CRISIS ROOM" if mode_name == "crisis" else "PRESIDENTIAL DEBATE"
	multiplayer_hud_role.text = "ROLE: %s\nMouse: look • LEFT CLICK: interact • ESC: return" % role_name.replace("_", " ")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_refresh_menu_backdrop()

func _on_multiplayer_role_changed(role_name: String) -> void:
	if multiplayer_hud_role != null:
		multiplayer_hud_role.text = "ROLE: %s\nMouse: look • LEFT CLICK: interact • ESC: return" % role_name.replace("_", " ")

func _exit_multiplayer_preview() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if multiplayer_arena != null and is_instance_valid(multiplayer_arena):
		multiplayer_arena.queue_free()
	multiplayer_arena = null
	multiplayer_hud.visible = false
	if visual_root != null and world_ready:
		visual_root.visible = true

	if lan_match_session:
		lan_match_session = false
		await OnlineMultiplayer.leave_session()
		if online_multiplayer_ui != null and is_instance_valid(online_multiplayer_ui):
			online_multiplayer_ui.visible = true
			online_multiplayer_ui.show_home()
		else:
			main_menu.visible = true
	else:
		multiplayer_menu.visible = true
	_start_menu_background_cycle(_saved_menu_level_index())
	_refresh_menu_backdrop()

func _build_credits_menu() -> void:
	credits_menu = Panel.new()
	_make_panel_opaque(credits_menu, Color(0.05, 0.08, 0.12, 0.82))
	credits_menu.position = Vector2(260, 55)
	credits_menu.size = Vector2(760, 610)
	layer.add_child(credits_menu)
	credits_menu.visible = false

	credits_title_label = Label.new()
	credits_title_label.text = "CREDITS"
	credits_title_label.position = Vector2(0, 26)
	credits_title_label.size = Vector2(760, 40)
	credits_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits_title_label.add_theme_font_size_override("font_size", 30)
	credits_menu.add_child(credits_title_label)

	credits_body = RichTextLabel.new()
	credits_body.position = Vector2(50, 82)
	credits_body.size = Vector2(660, 430)
	credits_body.bbcode_enabled = true
	credits_body.fit_content = false
	credits_body.scroll_active = true
	credits_body.scroll_following = false
	credits_body.add_theme_font_size_override("normal_font_size", 14)
	credits_body.add_theme_font_size_override("bold_font_size", 14)
	credits_body.add_theme_font_size_override("italics_font_size", 14)
	credits_body.add_theme_color_override("default_color", Color("#eef5ff"))
	credits_body.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	credits_body.add_theme_constant_override("shadow_offset_x", 2)
	credits_body.add_theme_constant_override("shadow_offset_y", 2)
	credits_body.text = _credits_main_text()
	credits_menu.add_child(credits_body)

	credits_license_button = _menu_button("OPEN SOURCE LICENCES", Vector2(62, 535), credits_menu)
	credits_license_button.size = Vector2(300, 42)
	credits_license_button.pressed.connect(_toggle_credits_licenses)

	var close := _menu_button("CLOSE", Vector2(398, 535), credits_menu)
	close.size = Vector2(300, 42)
	close.pressed.connect(_close_credits)

func _dev_make_header(parent: Control, text_value: String, pos: Vector2, width: float = 500.0) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = pos
	label.size = Vector2(width, 28)
	label.add_theme_font_size_override("font_size", 16)
	label.modulate = Color("#f2d27c")
	parent.add_child(label)
	return label

func _dev_make_note(parent: Control, text_value: String, pos: Vector2, size_value: Vector2) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = pos
	label.size = size_value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 11)
	label.modulate = Color("#aebdca")
	parent.add_child(label)
	return label

func _build_dev_ui() -> void:
	# Nothing on the normal home menu advertises this panel. Once unlocked, it stays
	# available as a small minimized launcher until the app is closed.
	dev_code_panel = Panel.new()
	_make_panel_opaque(dev_code_panel, Color(0.04, 0.06, 0.09, 0.92))
	dev_code_panel.position = Vector2(435, 235)
	dev_code_panel.size = Vector2(410, 235)
	dev_code_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	layer.add_child(dev_code_panel)
	dev_code_panel.visible = false

	var code_title := Label.new()
	code_title.text = "DEVELOPER ACCESS"
	code_title.position = Vector2(0, 30)
	code_title.size = Vector2(410, 32)
	code_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	code_title.add_theme_font_size_override("font_size", 24)
	dev_code_panel.add_child(code_title)

	dev_code_status = Label.new()
	dev_code_status.text = "ENTER ACCESS CODE"
	dev_code_status.position = Vector2(0, 74)
	dev_code_status.size = Vector2(410, 24)
	dev_code_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dev_code_status.add_theme_font_size_override("font_size", 12)
	dev_code_status.modulate = Color("#aebdca")
	dev_code_panel.add_child(dev_code_status)

	dev_code_input = LineEdit.new()
	dev_code_input.position = Vector2(85, 111)
	dev_code_input.size = Vector2(240, 40)
	dev_code_input.secret = true
	dev_code_input.max_length = 8
	dev_code_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	dev_code_input.placeholder_text = "••••"
	dev_code_input.text_submitted.connect(_submit_dev_code)
	dev_code_panel.add_child(dev_code_input)

	var code_submit := _menu_button("UNLOCK", Vector2(45, 171), dev_code_panel)
	code_submit.size = Vector2(150, 38)
	code_submit.pressed.connect(_submit_dev_code)

	var code_cancel := _menu_button("CANCEL", Vector2(215, 171), dev_code_panel)
	code_cancel.size = Vector2(150, 38)
	code_cancel.pressed.connect(_close_dev_code_prompt)

	dev_minimized_button = Button.new()
	dev_minimized_button.text = "DEV TOOLS • F12"
	dev_minimized_button.position = Vector2(1112, 12)
	dev_minimized_button.size = Vector2(150, 36)
	dev_minimized_button.process_mode = Node.PROCESS_MODE_ALWAYS
	_style_menu_button(dev_minimized_button)
	dev_minimized_button.add_theme_font_size_override("font_size", 12)
	dev_minimized_button.pressed.connect(_open_dev_panel)
	layer.add_child(dev_minimized_button)
	dev_minimized_button.visible = false

	dev_debug_overlay = Panel.new()
	_make_panel_opaque(dev_debug_overlay, Color(0.015, 0.025, 0.035, 0.82))
	dev_debug_overlay.position = Vector2(14, 14)
	dev_debug_overlay.size = Vector2(390, 286)
	dev_debug_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	layer.add_child(dev_debug_overlay)
	dev_debug_overlay.visible = false

	dev_debug_overlay_label = Label.new()
	dev_debug_overlay_label.position = Vector2(12, 10)
	dev_debug_overlay_label.size = Vector2(366, 266)
	dev_debug_overlay_label.add_theme_font_size_override("font_size", 11)
	dev_debug_overlay_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dev_debug_overlay.add_child(dev_debug_overlay_label)

	dev_panel = Panel.new()
	_make_panel_opaque(dev_panel, Color(0.025, 0.04, 0.06, 0.96))
	dev_panel.position = Vector2(80, 34)
	dev_panel.size = Vector2(1120, 650)
	dev_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	layer.add_child(dev_panel)
	dev_panel.visible = false

	var dev_title := Label.new()
	dev_title.text = "TRUMP SIMULATOR — DEVELOPER TOOLS"
	dev_title.position = Vector2(24, 16)
	dev_title.size = Vector2(720, 34)
	dev_title.add_theme_font_size_override("font_size", 25)
	dev_panel.add_child(dev_title)

	var protected_note := Label.new()
	protected_note.text = "DEV CHANGES DO NOT OVERWRITE THE NORMAL CAMPAIGN SAVE"
	protected_note.position = Vector2(24, 48)
	protected_note.size = Vector2(720, 18)
	protected_note.add_theme_font_size_override("font_size", 10)
	protected_note.modulate = Color("#85d9a5")
	dev_panel.add_child(protected_note)

	var minimize := _menu_button("MINIMIZE", Vector2(916, 18), dev_panel)
	minimize.size = Vector2(175, 38)
	minimize.add_theme_font_size_override("font_size", 12)
	minimize.pressed.connect(_minimize_dev_panel)

	dev_tabs = TabContainer.new()
	dev_tabs.position = Vector2(24, 76)
	dev_tabs.size = Vector2(1072, 500)
	dev_tabs.process_mode = Node.PROCESS_MODE_ALWAYS
	dev_panel.add_child(dev_tabs)

	# ---------------- STATUS ----------------
	var status_page := Control.new()
	status_page.name = "STATUS"
	dev_tabs.add_child(status_page)

	dev_overview_label = RichTextLabel.new()
	dev_overview_label.position = Vector2(18, 18)
	dev_overview_label.size = Vector2(590, 425)
	dev_overview_label.bbcode_enabled = false
	dev_overview_label.fit_content = false
	dev_overview_label.scroll_active = true
	dev_overview_label.add_theme_font_size_override("normal_font_size", 12)
	status_page.add_child(dev_overview_label)

	_dev_make_header(status_page, "LIVE DEBUG CONTROLS", Vector2(640, 18), 390)
	dev_overlay_button = _menu_button("DEBUG OVERLAY — OFF", Vector2(640, 52), status_page)
	dev_overlay_button.size = Vector2(390, 38)
	dev_overlay_button.pressed.connect(_dev_toggle_debug_overlay)
	dev_god_button = _menu_button("GOD MODE — OFF", Vector2(640, 96), status_page)
	dev_god_button.size = Vector2(390, 38)
	dev_god_button.pressed.connect(_dev_toggle_god_mode)
	dev_events_button = _menu_button("RANDOM EVENTS — ON", Vector2(640, 140), status_page)
	dev_events_button.size = Vector2(390, 38)
	dev_events_button.pressed.connect(_dev_toggle_random_events)
	dev_freeze_button = _menu_button("SIMULATION FREEZE — OFF", Vector2(640, 184), status_page)
	dev_freeze_button.size = Vector2(390, 38)
	dev_freeze_button.pressed.connect(_dev_toggle_freeze_simulation)

	var normalize := _menu_button("NORMALIZE GAME STATE", Vector2(640, 238), status_page)
	normalize.size = Vector2(390, 38)
	normalize.pressed.connect(_dev_normalize_state)
	var danger := _menu_button("SET NEAR-FAIL STATE", Vector2(640, 282), status_page)
	danger.size = Vector2(390, 38)
	danger.pressed.connect(_dev_set_danger_state)
	var snapshot := _menu_button("CAPTURE RUNTIME SNAPSHOT", Vector2(640, 326), status_page)
	snapshot.size = Vector2(190, 38)
	snapshot.add_theme_font_size_override("font_size", 11)
	snapshot.pressed.connect(_dev_capture_snapshot)
	var restore_snapshot := _menu_button("RESTORE SNAPSHOT", Vector2(840, 326), status_page)
	restore_snapshot.size = Vector2(190, 38)
	restore_snapshot.add_theme_font_size_override("font_size", 11)
	restore_snapshot.pressed.connect(_dev_restore_snapshot)

	_dev_make_header(status_page, "TIME SCALE", Vector2(640, 378), 390)
	var half_speed := _menu_button("0.5x", Vector2(640, 410), status_page)
	half_speed.size = Vector2(120, 36)
	half_speed.pressed.connect(_dev_set_time_scale.bind(0.5))
	var normal_speed := _menu_button("1.0x", Vector2(775, 410), status_page)
	normal_speed.size = Vector2(120, 36)
	normal_speed.pressed.connect(_dev_set_time_scale.bind(1.0))
	var double_speed := _menu_button("2.0x", Vector2(910, 410), status_page)
	double_speed.size = Vector2(120, 36)
	double_speed.pressed.connect(_dev_set_time_scale.bind(2.0))

	# ---------------- MAPS ----------------
	var maps_page := Control.new()
	maps_page.name = "MAPS"
	dev_tabs.add_child(maps_page)
	_dev_make_header(maps_page, "INSTANT CAMPAIGN MAP LOADER", Vector2(18, 14), 700)
	_dev_make_note(maps_page, "Loads directly into a protected developer session. Your normal campaign save is left untouched.", Vector2(18, 42), Vector2(1000, 34))
	for i in range(CAMPAIGN_LEVELS.size()):
		var col: int = i % 2
		var row: int = int(i / 2)
		var map_button := _menu_button("%d — %s" % [i + 1, str(CAMPAIGN_LEVELS[i]["name"])], Vector2(18 + col * 520, 82 + row * 54), maps_page)
		map_button.size = Vector2(500, 40)
		map_button.add_theme_font_size_override("font_size", 12)
		map_button.pressed.connect(_dev_start_level.bind(i))
	var reload_map := _menu_button("RELOAD CURRENT MAP", Vector2(18, 365), maps_page)
	reload_map.size = Vector2(330, 40)
	reload_map.pressed.connect(_dev_reload_current_map)
	var preview := _menu_button("VIEW ALL MAP PREVIEWS", Vector2(370, 365), maps_page)
	preview.size = Vector2(330, 40)
	preview.pressed.connect(_open_dev_map_preview)
	var next_backdrop := _menu_button("NEXT MENU BACKDROP", Vector2(722, 365), maps_page)
	next_backdrop.size = Vector2(310, 40)
	next_backdrop.pressed.connect(_dev_next_menu_backdrop)

	# ---------------- GAME STATE ----------------
	var game_page := Control.new()
	game_page.name = "GAME STATE"
	dev_tabs.add_child(game_page)
	_dev_make_header(game_page, "STAGE OVERRIDE", Vector2(18, 14), 330)
	for i in range(STAGES.size()):
		var stage_button := _menu_button("%d • %s" % [i + 1, str(STAGES[i]["name"])], Vector2(18, 50 + i * 48), game_page)
		stage_button.size = Vector2(320, 36)
		stage_button.add_theme_font_size_override("font_size", 11)
		stage_button.pressed.connect(_dev_start_stage.bind(i + 1))

	_dev_make_header(game_page, "RUNTIME VALUES", Vector2(370, 14), 300)
	var add_10k := _menu_button("+10,000 BOMBS", Vector2(370, 50), game_page)
	add_10k.size = Vector2(280, 36)
	add_10k.pressed.connect(_dev_add_bombs.bind(10000))
	var add_1m := _menu_button("+1,000,000 BOMBS", Vector2(370, 94), game_page)
	add_1m.size = Vector2(280, 36)
	add_1m.pressed.connect(_dev_add_bombs.bind(1000000))
	var zero_bombs := _menu_button("SET BOMBS TO 0", Vector2(370, 138), game_page)
	zero_bombs.size = Vector2(280, 36)
	zero_bombs.pressed.connect(_dev_set_bombs.bind(0))
	var goal_90 := _menu_button("LEVEL PROGRESS → 90%", Vector2(370, 190), game_page)
	goal_90.size = Vector2(280, 36)
	goal_90.pressed.connect(_dev_set_level_progress.bind(0.90))
	var goal_99 := _menu_button("LEVEL PROGRESS → 99%", Vector2(370, 234), game_page)
	goal_99.size = Vector2(280, 36)
	goal_99.pressed.connect(_dev_set_level_progress.bind(0.99))
	var complete := _menu_button("COMPLETE CURRENT LEVEL", Vector2(370, 278), game_page)
	complete.size = Vector2(280, 36)
	complete.pressed.connect(_dev_complete_current_level)
	var reset_progress := _menu_button("RESET LEVEL PROGRESS", Vector2(370, 322), game_page)
	reset_progress.size = Vector2(280, 36)
	reset_progress.pressed.connect(_dev_set_level_progress.bind(0.0))

	_dev_make_header(game_page, "UPGRADES / DIFFICULTY", Vector2(682, 14), 350)
	var all_upgrades := _menu_button("UNLOCK ALL UPGRADES", Vector2(682, 50), game_page)
	all_upgrades.size = Vector2(350, 36)
	all_upgrades.pressed.connect(_dev_unlock_all_upgrades)
	var clear_upgrades := _menu_button("CLEAR ALL UPGRADES", Vector2(682, 94), game_page)
	clear_upgrades.size = Vector2(350, 36)
	clear_upgrades.pressed.connect(_dev_clear_upgrades)
	_dev_make_note(game_page, "Difficulty can be changed live for balance testing.", Vector2(682, 142), Vector2(350, 34))
	for i in range(DIFFICULTIES.size()):
		var dcol: int = i % 2
		var drow: int = int(i / 2)
		var diff_button := _menu_button(str(DIFFICULTIES[i]["name"]).to_upper(), Vector2(682 + dcol * 180, 184 + drow * 48), game_page)
		diff_button.size = Vector2(170, 36)
		diff_button.add_theme_font_size_override("font_size", 9)
		diff_button.pressed.connect(_dev_set_difficulty.bind(i))

	# ---------------- EVENTS ----------------
	var events_page := Control.new()
	events_page.name = "EVENTS"
	dev_tabs.add_child(events_page)
	_dev_make_header(events_page, "PHONE CALLS", Vector2(18, 14), 480)
	var random_call := _menu_button("RANDOM CALL", Vector2(18, 50), events_page)
	random_call.size = Vector2(240, 38)
	random_call.pressed.connect(_dev_force_call.bind(""))
	var kim_call := _menu_button("KIM", Vector2(274, 50), events_page)
	kim_call.size = Vector2(115, 38)
	kim_call.pressed.connect(_dev_force_call.bind("KIM"))
	var putin_call := _menu_button("PUTIN", Vector2(399, 50), events_page)
	putin_call.size = Vector2(115, 38)
	putin_call.pressed.connect(_dev_force_call.bind("PUTIN"))
	var xi_call := _menu_button("XI", Vector2(524, 50), events_page)
	xi_call.size = Vector2(115, 38)
	xi_call.pressed.connect(_dev_force_call.bind("XI"))
	var timmy_call := _menu_button("TIMMY", Vector2(649, 50), events_page)
	timmy_call.size = Vector2(115, 38)
	timmy_call.pressed.connect(_dev_force_call.bind("LIL TIMMY"))
	var answer_call := _menu_button("ANSWER ACTIVE CALL", Vector2(18, 98), events_page)
	answer_call.size = Vector2(240, 38)
	answer_call.pressed.connect(_dev_answer_active_call)
	var end_call := _menu_button("END ACTIVE CALL", Vector2(274, 98), events_page)
	end_call.size = Vector2(240, 38)
	end_call.pressed.connect(_dev_end_active_call)

	_dev_make_header(events_page, "GAMEPLAY EVENTS", Vector2(18, 158), 480)
	var paperwork := _menu_button("TRIGGER PAPERWORK", Vector2(18, 194), events_page)
	paperwork.size = Vector2(240, 38)
	paperwork.pressed.connect(_dev_trigger_paperwork)
	var crisis := _menu_button("TRIGGER CRISIS", Vector2(274, 194), events_page)
	crisis.size = Vector2(240, 38)
	crisis.pressed.connect(_dev_trigger_crisis)
	var alarm := _menu_button("TRIGGER ALARM", Vector2(530, 194), events_page)
	alarm.size = Vector2(240, 38)
	alarm.pressed.connect(_dev_trigger_alarm)
	var gimmick := _menu_button("TRIGGER MAP GIMMICK", Vector2(18, 242), events_page)
	gimmick.size = Vector2(240, 38)
	gimmick.pressed.connect(_dev_trigger_gimmick)
	var overheat := _menu_button("FORCE OVERHEAT", Vector2(274, 242), events_page)
	overheat.size = Vector2(240, 38)
	overheat.pressed.connect(_dev_force_overheat)
	var clear_events := _menu_button("CLEAR ALL EVENTS", Vector2(530, 242), events_page)
	clear_events.size = Vector2(240, 38)
	clear_events.pressed.connect(_dev_clear_events)

	_dev_make_header(events_page, "FAILURE TESTS", Vector2(18, 310), 480)
	var test_game_over := _menu_button("TRIGGER GAME-OVER UI", Vector2(18, 346), events_page)
	test_game_over.size = Vector2(300, 38)
	test_game_over.pressed.connect(_dev_trigger_game_over_test)
	var clear_game_over := _menu_button("RECOVER FROM GAME OVER", Vector2(336, 346), events_page)
	clear_game_over.size = Vector2(300, 38)
	clear_game_over.pressed.connect(_dev_recover_game_over)
	_dev_make_note(events_page, "Event triggers automatically raise the stage if that system would otherwise be locked.", Vector2(18, 402), Vector2(900, 34))

	# ---------------- SAVE / DEBUG ----------------
	var debug_page := Control.new()
	debug_page.name = "SAVE / DEBUG"
	dev_tabs.add_child(debug_page)
	_dev_make_header(debug_page, "NORMAL SAVE PROTECTION", Vector2(18, 14), 490)
	dev_save_status_label = Label.new()
	dev_save_status_label.position = Vector2(18, 48)
	dev_save_status_label.size = Vector2(500, 118)
	dev_save_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dev_save_status_label.add_theme_font_size_override("font_size", 11)
	debug_page.add_child(dev_save_status_label)
	var backup_save := _menu_button("BACK UP SAVE + SETTINGS", Vector2(18, 178), debug_page)
	backup_save.size = Vector2(300, 38)
	backup_save.pressed.connect(_dev_backup_normal_files)
	var restore_save := _menu_button("RESTORE DEV BACKUP", Vector2(334, 178), debug_page)
	restore_save.size = Vector2(300, 38)
	restore_save.pressed.connect(_dev_restore_normal_files)
	var validate_save := _menu_button("VALIDATE SAVE JSON", Vector2(18, 226), debug_page)
	validate_save.size = Vector2(300, 38)
	validate_save.pressed.connect(_dev_validate_save)
	var reload_save := _menu_button("RELOAD NORMAL SAVE", Vector2(334, 226), debug_page)
	reload_save.size = Vector2(300, 38)
	reload_save.pressed.connect(_dev_reload_normal_save)

	_dev_make_header(debug_page, "DEBUG REPORTING", Vector2(680, 14), 350)
	var copy_report := _menu_button("COPY DEBUG REPORT", Vector2(680, 50), debug_page)
	copy_report.size = Vector2(350, 38)
	copy_report.pressed.connect(_dev_copy_debug_report)
	var dump_report := _menu_button("WRITE REPORT TO USER FOLDER", Vector2(680, 98), debug_page)
	dump_report.size = Vector2(350, 38)
	dump_report.add_theme_font_size_override("font_size", 11)
	dump_report.pressed.connect(_dev_dump_debug_report)
	var print_tree_button := _menu_button("PRINT SCENE TREE", Vector2(680, 146), debug_page)
	print_tree_button.size = Vector2(350, 38)
	print_tree_button.pressed.connect(_dev_print_scene_tree)
	var open_user := _menu_button("OPEN USER DATA FOLDER", Vector2(680, 194), debug_page)
	open_user.size = Vector2(350, 38)
	open_user.pressed.connect(_dev_open_user_data_folder)
	var refresh_ui := _menu_button("FORCE UI REFRESH", Vector2(680, 242), debug_page)
	refresh_ui.size = Vector2(350, 38)
	refresh_ui.pressed.connect(_dev_force_ui_refresh)
	_dev_make_note(debug_page, "Debug report includes FPS, level/stage, runtime meters, active events, save protection and LAN state.", Vector2(680, 300), Vector2(350, 70))

	# ---------------- MULTIPLAYER ----------------
	var multiplayer_page := Control.new()
	multiplayer_page.name = "MULTIPLAYER"
	dev_tabs.add_child(multiplayer_page)
	_dev_make_header(multiplayer_page, "LAN DIAGNOSTICS", Vector2(18, 14), 520)
	dev_multiplayer_status_label = Label.new()
	dev_multiplayer_status_label.position = Vector2(18, 48)
	dev_multiplayer_status_label.size = Vector2(610, 160)
	dev_multiplayer_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dev_multiplayer_status_label.add_theme_font_size_override("font_size", 12)
	multiplayer_page.add_child(dev_multiplayer_status_label)
	var scan_lan := _menu_button("REFRESH LAN SCAN", Vector2(18, 222), multiplayer_page)
	scan_lan.size = Vector2(290, 38)
	scan_lan.pressed.connect(_dev_refresh_lan_scan)
	var leave_lan := _menu_button("LEAVE LAN SESSION", Vector2(324, 222), multiplayer_page)
	leave_lan.size = Vector2(290, 38)
	leave_lan.pressed.connect(_dev_leave_lan_session)
	var open_lan := _menu_button("OPEN LAN BROWSER", Vector2(18, 270), multiplayer_page)
	open_lan.size = Vector2(596, 38)
	open_lan.pressed.connect(_dev_open_lan_browser)

	_dev_make_header(multiplayer_page, "LOCAL PRACTICE MAPS", Vector2(660, 14), 360)
	var crisis_mp := _menu_button("CRISIS ROOM — INTEL", Vector2(660, 50), multiplayer_page)
	crisis_mp.size = Vector2(370, 38)
	crisis_mp.pressed.connect(_dev_start_multiplayer.bind("crisis", "INTEL"))
	var debate_mp := _menu_button("DEBATE — TRUMP", Vector2(660, 98), multiplayer_page)
	debate_mp.size = Vector2(370, 38)
	debate_mp.pressed.connect(_dev_start_multiplayer.bind("debate", "TRUMP"))
	_dev_make_note(multiplayer_page, "Local Practice tools are available from the home menu. LAN diagnostics remain visible while testing a session.", Vector2(660, 158), Vector2(370, 76))

	dev_tool_status_label = Label.new()
	dev_tool_status_label.position = Vector2(24, 598)
	dev_tool_status_label.size = Vector2(1072, 28)
	dev_tool_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dev_tool_status_label.add_theme_font_size_override("font_size", 11)
	dev_tool_status_label.modulate = Color("#9fc6d9")
	dev_panel.add_child(dev_tool_status_label)

	dev_map_preview = Panel.new()
	_make_panel_opaque(dev_map_preview, Color(0.02, 0.035, 0.05, 0.98))
	dev_map_preview.position = Vector2(55, 35)
	dev_map_preview.size = Vector2(1170, 650)
	dev_map_preview.process_mode = Node.PROCESS_MODE_ALWAYS
	layer.add_child(dev_map_preview)
	dev_map_preview.visible = false

	var preview_title := Label.new()
	preview_title.text = "ALL CAMPAIGN MAPS"
	preview_title.position = Vector2(0, 14)
	preview_title.size = Vector2(1170, 30)
	preview_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_title.add_theme_font_size_override("font_size", 20)
	dev_map_preview.add_child(preview_title)

	dev_map_preview_texture = TextureRect.new()
	dev_map_preview_texture.position = Vector2(24, 55)
	dev_map_preview_texture.size = Vector2(1122, 535)
	dev_map_preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dev_map_preview_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dev_map_preview_texture.texture = load("res://assets/dev/all_maps_overview.png") as Texture2D
	dev_map_preview.add_child(dev_map_preview_texture)

	var preview_close := _menu_button("BACK TO DEV TOOLS", Vector2(425, 598), dev_map_preview)
	preview_close.size = Vector2(320, 38)
	preview_close.pressed.connect(_close_dev_map_preview)

	_refresh_dev_launcher_visibility()
	_refresh_dev_runtime_ui()

func _refresh_dev_launcher_visibility() -> void:
	if dev_minimized_button == null:
		return
	var full_panel_open := dev_panel != null and dev_panel.visible
	var preview_open := dev_map_preview != null and dev_map_preview.visible
	var code_open := dev_code_panel != null and dev_code_panel.visible
	dev_minimized_button.visible = dev_access_unlocked and not full_panel_open and not preview_open and not code_open

func _dev_set_tool_status(message: String) -> void:
	dev_last_tool_status = message
	if dev_tool_status_label != null:
		dev_tool_status_label.text = "STATUS • " + message

func _dev_mark_modified(reason: String) -> void:
	dev_session_active = true
	_dev_set_tool_status("%s — NORMAL SAVE PROTECTED" % reason)

func _dev_require_game(required_stage: int = 1) -> bool:
	if not game_started or game_over:
		_dev_set_tool_status("START A CAMPAIGN MAP BEFORE USING THIS TOOL")
		return false
	_dev_mark_modified("RUNTIME MODIFIED")
	if stage < required_stage:
		stage = required_stage
		last_stage_seen = stage
		_refresh_stage_unlocks()
	return true

func _dev_modifiers_active() -> bool:
	return dev_god_mode or not dev_random_events_enabled or dev_freeze_simulation or absf(Engine.time_scale - 1.0) > 0.001

func _dev_event_summary() -> String:
	var parts: Array[String] = []
	if call_active:
		parts.append("CALL:%s" % active_caller)
	if paperwork_active:
		parts.append("PAPERWORK")
	if crisis_active:
		parts.append("CRISIS")
	if alarm_active:
		parts.append("ALARM")
	if overheated:
		parts.append("OVERHEAT")
	return "NONE" if parts.is_empty() else ", ".join(parts)

func _dev_debug_report() -> String:
	var fps: int = Engine.get_frames_per_second()
	var frame_ms: float = 0.0 if fps <= 0 else 1000.0 / float(fps)
	var level_name := str(_current_level_data().get("name", "N/A")) if not CAMPAIGN_LEVELS.is_empty() else "N/A"
	var lan_text := "OFFLINE"
	if OnlineMultiplayer.connected or OnlineMultiplayer.is_host:
		lan_text = "%s • %s • %d PLAYER(S)" % ["HOST" if OnlineMultiplayer.is_host else "CLIENT", str(OnlineMultiplayer.game_mode), OnlineMultiplayer.players.size()]
	return (
		"BUILD: v%s\n" % VERSION
		+ "FPS: %d  |  FRAME: %.2f ms  |  TIME SCALE: %.2fx\n" % [fps, frame_ms, Engine.time_scale]
		+ "WORLD: %s  |  GAME: %s  |  PAUSED: %s  |  GAME OVER: %s\n" % [world_load_step, str(game_started), str(paused), str(game_over)]
		+ "LEVEL: %d/%d — %s\n" % [current_level_index + 1, CAMPAIGN_LEVELS.size(), level_name]
		+ "STAGE: %d/%d — %s  |  DIFFICULTY: %s\n" % [stage, STAGES.size(), str(STAGES[clampi(stage - 1, 0, STAGES.size() - 1)]["name"]), str(DIFFICULTIES[difficulty_index]["name"])]
		+ "BOMBS: %d  |  POWER: %d  |  LEVEL LAUNCHES: %d\n" % [bombs, power, level_launches]
		+ "PRESSURE: %.1f  |  HEAT: %.1f  |  APPROVAL: %.1f  |  CHAOS: %.1f\n" % [enemy_pressure, heat, approval, chaos]
		+ "EVENTS: %s\n" % _dev_event_summary()
		+ "DEV SAVE PROTECTION: %s  |  GOD: %s  |  RANDOM EVENTS: %s  |  FREEZE: %s\n" % ["ACTIVE" if dev_session_active else "STANDBY", "ON" if dev_god_mode else "OFF", "ON" if dev_random_events_enabled else "OFF", "ON" if dev_freeze_simulation else "OFF"]
		+ "LAN: %s  |  DISCOVERED: %d\n" % [lan_text, OnlineMultiplayer.discovered_games.size()]
		+ "SAVE: %s\n" % ("PRESENT" if FileAccess.file_exists(SAVE_PATH) else "MISSING")
	)

func _refresh_dev_runtime_ui() -> void:
	if not dev_access_unlocked and not (dev_code_panel != null and dev_code_panel.visible):
		if dev_debug_overlay != null:
			dev_debug_overlay.visible = false
		return
	if dev_overview_label != null:
		dev_overview_label.text = _dev_debug_report()
	if dev_tool_status_label != null:
		dev_tool_status_label.text = "STATUS • " + dev_last_tool_status
	if dev_god_button != null:
		dev_god_button.text = "GOD MODE — " + ("ON" if dev_god_mode else "OFF")
	if dev_events_button != null:
		dev_events_button.text = "RANDOM EVENTS — " + ("ON" if dev_random_events_enabled else "OFF")
	if dev_freeze_button != null:
		dev_freeze_button.text = "SIMULATION FREEZE — " + ("ON" if dev_freeze_simulation else "OFF")
	if dev_overlay_button != null:
		dev_overlay_button.text = "DEBUG OVERLAY — " + ("ON" if dev_debug_overlay_enabled else "OFF")
	if dev_debug_overlay != null:
		var full_panel_open := dev_panel != null and dev_panel.visible
		var preview_open := dev_map_preview != null and dev_map_preview.visible
		dev_debug_overlay.visible = dev_access_unlocked and dev_debug_overlay_enabled and not full_panel_open and not preview_open
	if dev_debug_overlay_label != null:
		dev_debug_overlay_label.text = _dev_debug_report()
	if dev_save_status_label != null:
		var backup_exists := FileAccess.file_exists("user://savegame_dev_backup.json")
		dev_save_status_label.text = (
			"Normal save: %s\n" % ("PRESENT" if FileAccess.file_exists(SAVE_PATH) else "MISSING")
			+ "Settings: %s\n" % ("PRESENT" if FileAccess.file_exists(SETTINGS_PATH) else "MISSING")
			+ "Dev backup: %s\n" % ("PRESENT" if backup_exists else "MISSING")
			+ "Current runtime writes: %s\n" % ("BLOCKED / PROTECTED" if dev_session_active else "NORMAL")
			+ ProjectSettings.globalize_path("user://")
		)
	if dev_multiplayer_status_label != null:
		dev_multiplayer_status_label.text = (
			"Connected: %s\n" % str(OnlineMultiplayer.connected)
			+ "Host: %s\n" % str(OnlineMultiplayer.is_host)
			+ "Mode: %s\n" % (str(OnlineMultiplayer.game_mode) if str(OnlineMultiplayer.game_mode) != "" else "NONE")
			+ "Local role: %s\n" % (str(OnlineMultiplayer.local_role) if str(OnlineMultiplayer.local_role) != "" else "NONE")
			+ "Players: %d\n" % OnlineMultiplayer.players.size()
			+ "Discovered LAN games: %d\n" % OnlineMultiplayer.discovered_games.size()
			+ "Game port: %d  •  Discovery port: %d" % [int(ProjectSettings.get_setting("trump_simulator/multiplayer/lan_port", 27887)), int(ProjectSettings.get_setting("trump_simulator/multiplayer/discovery_port", 27888))]
		)

func _dev_toggle_debug_overlay() -> void:
	dev_debug_overlay_enabled = not dev_debug_overlay_enabled
	_dev_set_tool_status("DEBUG OVERLAY %s" % ("ENABLED" if dev_debug_overlay_enabled else "DISABLED"))
	_refresh_dev_runtime_ui()

func _dev_toggle_god_mode() -> void:
	dev_god_mode = not dev_god_mode
	if game_started:
		_dev_mark_modified("GOD MODE %s" % ("ENABLED" if dev_god_mode else "DISABLED"))
	else:
		_dev_set_tool_status("GOD MODE %s" % ("ENABLED" if dev_god_mode else "DISABLED"))
	_refresh_dev_runtime_ui()

func _dev_toggle_random_events() -> void:
	dev_random_events_enabled = not dev_random_events_enabled
	if game_started:
		_dev_mark_modified("RANDOM EVENTS %s" % ("ENABLED" if dev_random_events_enabled else "DISABLED"))
	else:
		_dev_set_tool_status("RANDOM EVENTS %s" % ("ENABLED" if dev_random_events_enabled else "DISABLED"))
	_refresh_dev_runtime_ui()

func _dev_toggle_freeze_simulation() -> void:
	dev_freeze_simulation = not dev_freeze_simulation
	if game_started:
		_dev_mark_modified("SIMULATION FREEZE %s" % ("ENABLED" if dev_freeze_simulation else "DISABLED"))
	else:
		_dev_set_tool_status("SIMULATION FREEZE %s" % ("ENABLED" if dev_freeze_simulation else "DISABLED"))
	_refresh_dev_runtime_ui()

func _dev_set_time_scale(value: float) -> void:
	Engine.time_scale = clampf(value, 0.1, 4.0)
	_dev_set_tool_status("TIME SCALE SET TO %.2fx" % Engine.time_scale)

func _dev_normalize_state() -> void:
	if not _dev_require_game(1):
		return
	enemy_pressure = 0.0
	heat = 0.0
	approval = 75.0
	chaos = 0.0
	overheated = false
	_set_button_hot(false)
	_reset_runtime_events()
	_update_ui()
	_dev_set_tool_status("RUNTIME METERS AND EVENTS NORMALIZED")

func _dev_set_danger_state() -> void:
	if not _dev_require_game(6):
		return
	enemy_pressure = 94.0
	heat = 92.0
	approval = 8.0
	chaos = 94.0
	_update_ui()
	_dev_set_tool_status("NEAR-FAIL STATE APPLIED")

func _dev_capture_snapshot() -> void:
	if not game_started:
		_dev_set_tool_status("START A MAP BEFORE CAPTURING A SNAPSHOT")
		return
	dev_runtime_snapshot = {
		"bombs": bombs,
		"lifetime_bombs": lifetime_bombs,
		"power": power,
		"stage": stage,
		"difficulty_index": difficulty_index,
		"current_level_index": current_level_index,
		"level_launches": level_launches,
		"campaign_complete": campaign_complete,
		"enemy_pressure": enemy_pressure,
		"heat": heat,
		"approval": approval,
		"chaos": chaos,
		"purchased_upgrades": purchased_upgrades.duplicate(),
	}
	_dev_set_tool_status("RUNTIME SNAPSHOT CAPTURED")

func _dev_restore_snapshot() -> void:
	if dev_runtime_snapshot.is_empty():
		_dev_set_tool_status("NO RUNTIME SNAPSHOT HAS BEEN CAPTURED")
		return
	if not game_started:
		_dev_set_tool_status("START A MAP BEFORE RESTORING THE SNAPSHOT")
		return
	_dev_mark_modified("SNAPSHOT RESTORE")
	bombs = int(dev_runtime_snapshot.get("bombs", bombs))
	lifetime_bombs = int(dev_runtime_snapshot.get("lifetime_bombs", lifetime_bombs))
	power = int(dev_runtime_snapshot.get("power", power))
	stage = clampi(int(dev_runtime_snapshot.get("stage", stage)), 1, STAGES.size())
	difficulty_index = clampi(int(dev_runtime_snapshot.get("difficulty_index", difficulty_index)), 0, DIFFICULTIES.size() - 1)
	current_level_index = clampi(int(dev_runtime_snapshot.get("current_level_index", current_level_index)), 0, CAMPAIGN_LEVELS.size() - 1)
	level_launches = maxi(0, int(dev_runtime_snapshot.get("level_launches", level_launches)))
	campaign_complete = bool(dev_runtime_snapshot.get("campaign_complete", campaign_complete))
	enemy_pressure = float(dev_runtime_snapshot.get("enemy_pressure", enemy_pressure))
	heat = float(dev_runtime_snapshot.get("heat", heat))
	approval = float(dev_runtime_snapshot.get("approval", approval))
	chaos = float(dev_runtime_snapshot.get("chaos", chaos))
	purchased_upgrades.clear()
	for item in dev_runtime_snapshot.get("purchased_upgrades", []):
		purchased_upgrades.append(str(item))
	_reset_runtime_events()
	_apply_current_level(false, false)
	_refresh_stage_unlocks()
	_update_ui()
	_dev_set_tool_status("RUNTIME SNAPSHOT RESTORED")

func _dev_reload_current_map() -> void:
	if not game_started:
		_dev_set_tool_status("START A MAP FIRST")
		return
	_dev_mark_modified("MAP RELOAD")
	_reset_runtime_events()
	_apply_current_level(true, false)
	_update_ui()
	_dev_set_tool_status("CURRENT MAP RELOADED")

func _dev_next_menu_backdrop() -> void:
	if not _home_menu_context():
		_dev_set_tool_status("MENU BACKDROPS CAN ONLY BE CYCLED FROM THE HOME MENU")
		return
	if menu_background_entries.size() < 2:
		_start_menu_background_cycle(_saved_menu_level_index())
	if menu_background_entries.size() < 2:
		_dev_set_tool_status("NO MENU BACKDROPS AVAILABLE")
		return
	menu_background_index = (menu_background_index + 1) % menu_background_entries.size()
	menu_background_elapsed = 0.0
	_apply_menu_background_entry(menu_background_entries[menu_background_index])
	_dev_set_tool_status("MENU BACKDROP ADVANCED")

func _dev_add_bombs(amount: int) -> void:
	if not _dev_require_game(1):
		return
	bombs = maxi(0, bombs + amount)
	lifetime_bombs = maxi(lifetime_bombs, bombs)
	_update_ui()
	_dev_set_tool_status("BOMBS CHANGED BY %+d" % amount)

func _dev_set_bombs(value: int) -> void:
	if not _dev_require_game(1):
		return
	bombs = maxi(0, value)
	_update_ui()
	_dev_set_tool_status("BOMBS SET TO %d" % bombs)

func _dev_set_level_progress(ratio: float) -> void:
	if not _dev_require_game(1):
		return
	var goal := maxi(1, int(_current_level_data().get("goal", 1)))
	level_launches = clampi(int(round(float(goal) * clampf(ratio, 0.0, 0.999))), 0, goal - 1)
	_recalculate_campaign_stage(false)
	_refresh_stage_unlocks()
	_update_ui()
	_dev_set_tool_status("LEVEL PROGRESS SET TO %d%%" % int(round(ratio * 100.0)))

func _dev_complete_current_level() -> void:
	if not _dev_require_game(1):
		return
	var goal := maxi(1, int(_current_level_data().get("goal", 1)))
	level_launches = goal
	_update_ui()
	_complete_current_level()
	_dev_set_tool_status("CURRENT LEVEL COMPLETION TRIGGERED")

func _dev_unlock_all_upgrades() -> void:
	if not _dev_require_game(1):
		return
	purchased_upgrades.clear()
	power = 1
	for upgrade in UPGRADES:
		purchased_upgrades.append(str(upgrade["id"]))
		power += int(upgrade["power"])
	_update_ui()
	_dev_set_tool_status("ALL UPGRADES UNLOCKED")

func _dev_clear_upgrades() -> void:
	if not _dev_require_game(1):
		return
	purchased_upgrades.clear()
	power = 1
	_update_ui()
	_dev_set_tool_status("ALL UPGRADES CLEARED")

func _dev_set_difficulty(index: int) -> void:
	if index < 0 or index >= DIFFICULTIES.size():
		return
	if game_started:
		_dev_mark_modified("DIFFICULTY OVERRIDE")
	difficulty_index = index
	_update_ui()
	_dev_set_tool_status("DIFFICULTY SET TO %s" % str(DIFFICULTIES[index]["name"]))

func _dev_force_call(caller: String) -> void:
	if not _dev_require_game(3):
		return
	_reset_runtime_events()
	_start_call()
	if not call_active:
		_dev_set_tool_status("CALL COULD NOT BE STARTED")
		return
	if caller != "":
		active_caller = caller
		caller_label.text = "INCOMING CALL: " + active_caller
	_update_ui()
	_dev_set_tool_status("CALL TRIGGERED — %s" % active_caller)

func _dev_answer_active_call() -> void:
	if not call_active:
		_dev_set_tool_status("NO ACTIVE CALL TO ANSWER")
		return
	_dev_mark_modified("CALL TEST")
	_answer_phone()
	_dev_set_tool_status("ACTIVE CALL ANSWERED")

func _dev_end_active_call() -> void:
	if not call_active:
		_dev_set_tool_status("NO ACTIVE CALL TO END")
		return
	_dev_mark_modified("CALL TEST")
	if call_answered:
		_finish_answered_call()
	else:
		_reset_runtime_events()
	_update_ui()
	_dev_set_tool_status("ACTIVE CALL ENDED")

func _dev_trigger_paperwork() -> void:
	if not _dev_require_game(4):
		return
	paperwork_active = false
	if paper_timer != null:
		paper_timer.stop()
	_start_paperwork()
	_dev_set_tool_status("PAPERWORK TRIGGERED")

func _dev_trigger_crisis() -> void:
	if not _dev_require_game(5):
		return
	crisis_active = false
	if crisis_timer != null:
		crisis_timer.stop()
	_start_crisis()
	_dev_set_tool_status("CRISIS TRIGGERED")

func _dev_trigger_alarm() -> void:
	if not _dev_require_game(6):
		return
	alarm_active = false
	if alarm_timer != null:
		alarm_timer.stop()
	_start_alarm()
	_dev_set_tool_status("ALARM TRIGGERED")

func _dev_trigger_gimmick() -> void:
	if not _dev_require_game(1):
		return
	_trigger_level_gimmick()
	_dev_set_tool_status("CURRENT MAP GIMMICK TRIGGERED")

func _dev_force_overheat() -> void:
	if not _dev_require_game(4):
		return
	overheated = false
	_start_overheat()
	_update_ui()
	_dev_set_tool_status("BUTTON OVERHEAT TRIGGERED")

func _dev_clear_events() -> void:
	if not game_started:
		_dev_set_tool_status("NO ACTIVE GAMEPLAY SESSION")
		return
	_dev_mark_modified("EVENT RESET")
	_reset_runtime_events()
	overheated = false
	heat = minf(heat, 48.0)
	_set_button_hot(false)
	_update_ui()
	_dev_set_tool_status("ALL ACTIVE EVENTS CLEARED")

func _dev_trigger_game_over_test() -> void:
	if not _dev_require_game(1):
		return
	var previous_god := dev_god_mode
	dev_god_mode = false
	_trigger_game_over("DEVELOPER FAILURE-STATE TEST")
	dev_god_mode = previous_god
	_dev_set_tool_status("GAME-OVER UI TRIGGERED")

func _dev_recover_game_over() -> void:
	if not game_over:
		_dev_set_tool_status("GAME IS NOT CURRENTLY OVER")
		return
	dev_session_active = true
	game_over = false
	paused = false
	get_tree().paused = false
	approval = maxf(approval, 50.0)
	chaos = minf(chaos, 25.0)
	enemy_pressure = minf(enemy_pressure, 25.0)
	if game_over_panel != null:
		game_over_panel.visible = false
	_reset_runtime_events()
	_update_ui()
	_dev_set_tool_status("GAME-OVER STATE CLEARED")

func _dev_copy_file(source_path: String, destination_path: String) -> bool:
	if not FileAccess.file_exists(source_path):
		return false
	var source := FileAccess.open(source_path, FileAccess.READ)
	if source == null:
		return false
	var bytes := source.get_buffer(source.get_length())
	var destination := FileAccess.open(destination_path, FileAccess.WRITE)
	if destination == null:
		return false
	destination.store_buffer(bytes)
	return true

func _dev_backup_normal_files() -> void:
	var save_ok := _dev_copy_file(SAVE_PATH, "user://savegame_dev_backup.json")
	var settings_ok := _dev_copy_file(SETTINGS_PATH, "user://settings_dev_backup.json")
	_dev_set_tool_status("BACKUP COMPLETE — SAVE:%s SETTINGS:%s" % ["OK" if save_ok else "MISSING", "OK" if settings_ok else "MISSING"])
	_refresh_dev_runtime_ui()

func _dev_restore_normal_files() -> void:
	var save_ok := _dev_copy_file("user://savegame_dev_backup.json", SAVE_PATH)
	var settings_ok := _dev_copy_file("user://settings_dev_backup.json", SETTINGS_PATH)
	_dev_set_tool_status("BACKUP RESTORE — SAVE:%s SETTINGS:%s" % ["OK" if save_ok else "MISSING", "OK" if settings_ok else "MISSING"])
	_refresh_dev_runtime_ui()

func _dev_validate_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_dev_set_tool_status("NORMAL SAVE DOES NOT EXIST")
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_dev_set_tool_status("NORMAL SAVE COULD NOT BE OPENED")
		return
	var parsed := JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		_dev_set_tool_status("SAVE JSON INVALID")
		return
	var data := parsed as Dictionary
	_dev_set_tool_status("SAVE JSON VALID — VERSION %s • LEVEL %d" % [str(data.get("version", "UNKNOWN")), int(data.get("current_level_index", 0)) + 1])

func _dev_reload_normal_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_dev_set_tool_status("NORMAL SAVE DOES NOT EXIST")
		return
	var was_started := game_started
	if not _load_game():
		_dev_set_tool_status("NORMAL SAVE FAILED TO LOAD")
		return
	dev_session_active = true
	if was_started:
		game_started = true
		paused = false
		game_over = false
		get_tree().paused = false
		_apply_current_level(true, false)
		_update_ui()
	_dev_set_tool_status("NORMAL SAVE RELOADED INTO PROTECTED DEV SESSION")

func _dev_copy_debug_report() -> void:
	DisplayServer.clipboard_set(_dev_debug_report())
	_dev_set_tool_status("DEBUG REPORT COPIED TO CLIPBOARD")

func _dev_dump_debug_report() -> void:
	var file := FileAccess.open("user://trump_simulator_debug_report.txt", FileAccess.WRITE)
	if file == null:
		_dev_set_tool_status("COULD NOT WRITE DEBUG REPORT")
		return
	file.store_string(_dev_debug_report())
	_dev_set_tool_status("DEBUG REPORT WRITTEN TO USER DATA FOLDER")

func _dev_print_scene_tree() -> void:
	get_tree().root.print_tree_pretty()
	_dev_set_tool_status("SCENE TREE PRINTED TO GODOT OUTPUT")

func _dev_open_user_data_folder() -> void:
	var path := ProjectSettings.globalize_path("user://")
	OS.shell_open(path)
	_dev_set_tool_status("OPENED USER DATA FOLDER")

func _dev_force_ui_refresh() -> void:
	_refresh_stage_unlocks()
	_update_ui()
	_refresh_menu_backdrop()
	_dev_set_tool_status("UI AND STAGE VISIBILITY REFRESHED")

func _dev_refresh_lan_scan() -> void:
	if OnlineMultiplayer.is_host:
		_dev_set_tool_status("LAN HOST IS ACTIVE — DISCOVERY SCAN IS CLIENT-ONLY")
		return
	OnlineMultiplayer.refresh_lan_scan()
	_dev_set_tool_status("LAN DISCOVERY REFRESH REQUESTED")

func _dev_leave_lan_session() -> void:
	OnlineMultiplayer.leave_session()
	lan_match_session = false
	_dev_set_tool_status("LAN SESSION CLOSED")

func _dev_open_lan_browser() -> void:
	if game_started:
		_dev_set_tool_status("RETURN TO THE HOME MENU BEFORE OPENING THE LAN BROWSER")
		return
	_minimize_dev_panel()
	if main_menu != null:
		main_menu.visible = true
	_open_multiplayer_menu()
	_open_online_multiplayer()

func _dev_start_multiplayer(mode_name: String, role_name: String) -> void:
	if game_started:
		_dev_set_tool_status("RETURN TO THE HOME MENU BEFORE STARTING LOCAL PRACTICE")
		return
	_dev_mark_modified("MULTIPLAYER PRACTICE")
	_minimize_dev_panel()
	_start_multiplayer_preview(mode_name, role_name)


func _build_difficulty_select_panel() -> void:
	difficulty_select_panel = Panel.new()
	_make_panel_opaque(difficulty_select_panel, Color(0.04, 0.07, 0.11, 0.86))
	difficulty_select_panel.position = Vector2(205, 70)
	difficulty_select_panel.size = Vector2(870, 580)
	layer.add_child(difficulty_select_panel)
	difficulty_select_panel.visible = false
	var title := Label.new()
	title.text = "START NEW CAMPAIGN — CHOOSE DIFFICULTY"
	title.position = Vector2(0, 24)
	title.size = Vector2(870, 38)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 25)
	difficulty_select_panel.add_child(title)
	var warning := Label.new()
	warning.text = "Difficulty is saved with this campaign. Starting a new campaign overwrites the current campaign save."
	warning.position = Vector2(55, 67)
	warning.size = Vector2(760, 40)
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	warning.add_theme_font_size_override("font_size", 12)
	warning.modulate = Color("#aebdca")
	difficulty_select_panel.add_child(warning)
	difficulty_choice_buttons.clear()
	for i in range(DIFFICULTIES.size()):
		var choice := _menu_button(str(DIFFICULTIES[i]["name"]).to_upper(), Vector2(55, 125 + i * 58), difficulty_select_panel)
		choice.size = Vector2(325, 44)
		choice.pressed.connect(_select_new_game_difficulty.bind(i))
		difficulty_choice_buttons.append(choice)
	difficulty_description_label = Label.new()
	difficulty_description_label.position = Vector2(425, 135)
	difficulty_description_label.size = Vector2(385, 145)
	difficulty_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	difficulty_description_label.add_theme_font_size_override("font_size", 17)
	difficulty_select_panel.add_child(difficulty_description_label)
	difficulty_summary_label = Label.new()
	difficulty_summary_label.position = Vector2(425, 300)
	difficulty_summary_label.size = Vector2(385, 90)
	difficulty_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	difficulty_summary_label.add_theme_font_size_override("font_size", 13)
	difficulty_summary_label.modulate = Color("#e1c77b")
	difficulty_select_panel.add_child(difficulty_summary_label)
	var start := _menu_button("START CAMPAIGN", Vector2(445, 430), difficulty_select_panel)
	start.size = Vector2(320, 44)
	start.pressed.connect(_confirm_new_game_difficulty)
	var cancel := _menu_button("CANCEL", Vector2(445, 492), difficulty_select_panel)
	cancel.size = Vector2(320, 40)
	cancel.pressed.connect(_close_new_game_difficulty)
	_update_difficulty_picker()

func _open_new_game_difficulty() -> void:
	if not _home_menu_context() or difficulty_select_panel == null:
		return
	difficulty_select_panel.visible = true
	_update_difficulty_picker()
	_refresh_menu_backdrop()

func _close_new_game_difficulty() -> void:
	if difficulty_select_panel != null:
		difficulty_select_panel.visible = false
	_refresh_menu_backdrop()

func _select_new_game_difficulty(index: int) -> void:
	difficulty_index = clampi(index, 0, DIFFICULTIES.size() - 1)
	_update_difficulty_picker()

func _update_difficulty_picker() -> void:
	if difficulty_description_label == null:
		return
	var data: Dictionary = DIFFICULTIES[difficulty_index]
	difficulty_description_label.text = str(data["name"]).to_upper() + "\n\n" + str(data["description"])
	difficulty_summary_label.text = str(data["summary"])
	for i in range(difficulty_choice_buttons.size()):
		var button: Button = difficulty_choice_buttons[i]
		button.text = ("▶ " if i == difficulty_index else "") + str(DIFFICULTIES[i]["name"]).to_upper()

func _confirm_new_game_difficulty() -> void:
	_close_new_game_difficulty()
	_save_settings()
	_start_new_game()

func _build_level_complete_panel() -> void:
	level_complete_panel = Panel.new()
	_make_panel_opaque(level_complete_panel, Color(0.04, 0.07, 0.11, 0.88))
	level_complete_panel.position = Vector2(340, 150)
	level_complete_panel.size = Vector2(600, 420)
	level_complete_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	layer.add_child(level_complete_panel)
	level_complete_panel.visible = false
	level_complete_title = Label.new()
	level_complete_title.position = Vector2(40, 38)
	level_complete_title.size = Vector2(520, 52)
	level_complete_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_complete_title.add_theme_font_size_override("font_size", 32)
	level_complete_panel.add_child(level_complete_title)
	level_complete_body = Label.new()
	level_complete_body.position = Vector2(65, 115)
	level_complete_body.size = Vector2(470, 175)
	level_complete_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_complete_body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_complete_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	level_complete_body.add_theme_font_size_override("font_size", 16)
	level_complete_panel.add_child(level_complete_body)
	level_complete_button = _menu_button("CONTINUE CAMPAIGN", Vector2(140, 320), level_complete_panel)
	level_complete_button.size = Vector2(320, 46)
	level_complete_button.pressed.connect(_continue_after_level_complete)

func _build_level_intro_overlay() -> void:
	level_intro_root = Control.new()
	level_intro_root.name = "LevelIntroOverlay"
	level_intro_root.position = Vector2.ZERO
	level_intro_root.size = Vector2(1280, 720)
	level_intro_root.mouse_filter = Control.MOUSE_FILTER_STOP
	level_intro_root.process_mode = Node.PROCESS_MODE_ALWAYS
	layer.add_child(level_intro_root)
	level_intro_root.visible = false

	level_intro_bg = ColorRect.new()
	level_intro_bg.position = Vector2.ZERO
	level_intro_bg.size = Vector2(1280, 720)
	level_intro_bg.color = Color("#05080d")
	level_intro_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_intro_root.add_child(level_intro_bg)

	var studio := Label.new()
	studio.text = "SIMULATED STUDIOS"
	studio.position = Vector2(0, 175)
	studio.size = Vector2(1280, 30)
	studio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	studio.add_theme_font_size_override("font_size", 13)
	studio.modulate = Color("#8f9298")
	level_intro_root.add_child(studio)

	level_intro_title = Label.new()
	level_intro_title.position = Vector2(80, 260)
	level_intro_title.size = Vector2(1120, 80)
	level_intro_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_intro_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_intro_title.add_theme_font_size_override("font_size", 48)
	level_intro_title.modulate = Color("#f2d27c")
	level_intro_root.add_child(level_intro_title)

	var divider := ColorRect.new()
	divider.position = Vector2(490, 357)
	divider.size = Vector2(300, 2)
	divider.color = Color("#b79547")
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_intro_root.add_child(divider)

	level_intro_message = Label.new()
	level_intro_message.position = Vector2(180, 392)
	level_intro_message.size = Vector2(920, 70)
	level_intro_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_intro_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_intro_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	level_intro_message.add_theme_font_size_override("font_size", 22)
	level_intro_message.modulate = Color("#f2f2f2")
	level_intro_root.add_child(level_intro_message)

func _build_mirror_overlay() -> void:
	mirror_overlay = Control.new()
	mirror_overlay.name = "MirrorOverlay"
	mirror_overlay.position = Vector2.ZERO
	mirror_overlay.size = Vector2(1280, 720)
	mirror_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	mirror_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	layer.add_child(mirror_overlay)
	mirror_overlay.visible = false

	var bg := ColorRect.new()
	bg.position = Vector2.ZERO
	bg.size = Vector2(1280, 720)
	bg.color = Color(0.02, 0.02, 0.025, 0.96)
	mirror_overlay.add_child(bg)

	var frame := Panel.new()
	_make_panel_opaque(frame, Color("#17130d"))
	frame.position = Vector2(390, 70)
	frame.size = Vector2(500, 570)
	mirror_overlay.add_child(frame)

	var title := Label.new()
	title.text = "THE MIRROR"
	title.position = Vector2(0, 18)
	title.size = Vector2(500, 34)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.modulate = Color("#d7b765")
	frame.add_child(title)

	mirror_image = TextureRect.new()
	mirror_image.position = Vector2(45, 62)
	mirror_image.size = Vector2(410, 410)
	mirror_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mirror_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists("res://assets/mirror/orange_mirror.png"):
		mirror_image.texture = load("res://assets/mirror/orange_mirror.png") as Texture2D
	frame.add_child(mirror_image)

	var caption := Label.new()
	caption.text = "Looking fantastic."
	caption.position = Vector2(0, 482)
	caption.size = Vector2(500, 30)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 18)
	caption.modulate = Color("#f1d687")
	frame.add_child(caption)

	var close := _menu_button("CLOSE", Vector2(90, 520), frame)
	close.pressed.connect(_close_mirror)

func _open_mirror() -> void:
	if mirror_overlay == null:
		return
	mirror_overlay.visible = true
	_refresh_menu_backdrop()

func _close_mirror() -> void:
	if mirror_overlay != null:
		mirror_overlay.visible = false
	_refresh_menu_backdrop()

func _build_game_over_panel() -> void:
	game_over_panel = Panel.new()
	_make_panel_opaque(game_over_panel, Color(0.05, 0.08, 0.12, 0.84))
	game_over_panel.position = Vector2(350, 170)
	game_over_panel.size = Vector2(580, 390)
	layer.add_child(game_over_panel)
	game_over_panel.visible = false

	var title := Label.new()
	title.name = "GameOverTitle"
	title.position = Vector2(65, 50)
	title.size = Vector2(450, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	game_over_panel.add_child(title)

	var reason := Label.new()
	reason.name = "GameOverReason"
	reason.position = Vector2(65, 125)
	reason.size = Vector2(450, 70)
	reason.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	game_over_panel.add_child(reason)

	var restart := _menu_button("RETRY CHECKPOINT", Vector2(130, 225), game_over_panel)
	restart.pressed.connect(_restart_after_game_over)

	var menu := _menu_button("MAIN MENU", Vector2(130, 285), game_over_panel)
	menu.pressed.connect(_return_to_main_menu)

# ============================================================
# UI UPDATE / FEEDBACK
# ============================================================

func _update_ui() -> void:
	# -------------------------
	# Visual reboot readouts
	# -------------------------
	if visual_main_monitor != null:
		var level_data: Dictionary = _current_level_data()
		var goal: int = int(level_data.get("goal", 1))
		visual_main_monitor.text = (
			"LAUNCH CONTROL\n"
			+ "%d / %d   •   +%d / CLICK\n" % [level_launches, goal, power]
			+ "STAGE %d — %s" % [stage, str(STAGES[stage - 1]["name"])]
		)

	if visual_level_label != null:
		visual_level_label.text = "LEVEL %d/%d • %s" % [current_level_index + 1, CAMPAIGN_LEVELS.size(), str(_current_level_data()["name"])]

	if visual_heat_label != null:
		if stage < 4:
			visual_heat_label.text = "TEMP • OK"
			visual_heat_label.modulate = Color("#f1d687")
		else:
			visual_heat_label.text = "TEMP • %d%%%s" % [
				int(round(heat)),
				" • HOT" if overheated else ""
			]
			visual_heat_label.modulate = Color("#ff8d75") if heat >= 80.0 else Color("#f1d687")

	if visual_approval_label != null:
		visual_approval_label.text = "APPROVAL %d%%\n%s" % [
			int(round(approval)),
			"COLLAPSING" if approval <= 20.0 else ("SHAKY" if approval <= 45.0 else "HOLDING")
		]

	if visual_chaos_label != null:
		visual_chaos_label.text = "OFFICE STATUS\n%s • %d%%" % [
			"CHAOS" if chaos >= 60.0 else ("BUSY" if stage >= 4 else "STABLE"),
			int(round(chaos))
		]

	if visual_threat_label != null:
		visual_threat_label.text = "ENEMY PRESSURE %d%% • %s" % [
			int(round(enemy_pressure)),
			"CRITICAL" if enemy_pressure >= 85.0 else ("ELEVATED" if enemy_pressure >= 60.0 else "TRACKING")
		]

	if visual_phone_status != null:
		if stage < 3:
			visual_phone_status.text = "PHONE • STANDBY"
		elif call_active and not call_answered:
			visual_phone_status.text = "INCOMING • %s" % active_caller
		elif call_active and call_answered:
			visual_phone_status.text = "ON CALL • %s" % active_caller
		else:
			visual_phone_status.text = "PHONE • READY"

	if visual_threat_card != null:
		visual_threat_card.visible = stage >= 2

	# -------------------------
	# In-world command screens
	# -------------------------
	if command_monitor_label != null:
		command_monitor_label.text = (
			"LAUNCH CONTROL\n"
			+ "%d READY\n" % bombs
			+ "+%d / PRESS   LEVEL %d/%d\n" % [power, current_level_index + 1, CAMPAIGN_LEVELS.size()]
			+ "STAGE %d • %s" % [stage, STAGES[stage - 1]["name"]]
		)
		command_monitor_label.modulate = Color("#baf6ff")

	if threat_monitor_label != null:
		if stage < 2:
			threat_monitor_label.text = "THREAT MONITOR\nOFFLINE"
			threat_monitor_label.modulate = Color("#71808a")
		else:
			threat_monitor_label.text = "ENEMY PRESSURE\n%d%%\n%s" % [
				int(round(enemy_pressure)),
				"CRITICAL" if enemy_pressure >= 85.0 else ("ELEVATED" if enemy_pressure >= 60.0 else "TRACKING")
			]
			_set_screen_severity(threat_monitor_label, enemy_pressure)

	if approval_monitor_label != null:
		approval_monitor_label.text = "NEWS / APPROVAL\n%d%%\n%s" % [
			int(round(approval)),
			"COLLAPSING" if approval <= 20.0 else ("SHAKY" if approval <= 45.0 else "HOLDING")
		]
		# Approval danger is inverse: low is bad.
		_set_screen_severity(approval_monitor_label, 100.0 - approval)

	if chaos_monitor_label != null:
		if stage < 5:
			chaos_monitor_label.text = "OFFICE STATUS\n%s\nCHAOS %d%%" % [
				"BUSY" if stage >= 4 else "STABLE",
				int(round(chaos))
			]
		else:
			chaos_monitor_label.text = "OFFICE CHAOS\n%d%%\n%s" % [
				int(round(chaos)),
				"TOTAL MAYHEM" if chaos >= 85.0 else ("UNSTABLE" if chaos >= 60.0 else "MANAGEABLE")
			]
		_set_screen_severity(chaos_monitor_label, chaos)

	if heat_display_label != null:
		if stage < 4:
			heat_display_label.text = "TEMP • OK"
			heat_display_label.modulate = Color("#baf6ff")
		else:
			heat_display_label.text = "TEMP • %d%%%s" % [
				int(round(heat)),
				" • OVERHEAT" if overheated else ""
			]
			_set_screen_severity(heat_display_label, heat)

	if phone_display_label != null:
		if stage < 3:
			phone_display_label.text = "DESK PHONE\nSTANDBY"
			phone_display_label.modulate = Color("#6d7a80")
		elif call_active and not call_answered:
			phone_display_label.text = "INCOMING\n%s\n%.1fs" % [active_caller, call_ring_timer.time_left]
			phone_display_label.modulate = Color("#8affb5")
		elif call_active and call_answered:
			var call_preview: String = active_call_line
			if call_preview.length() > 44:
				call_preview = call_preview.left(41) + "..."
			phone_display_label.text = "ON CALL • %s\n%s\n%.1fs" % [active_caller, call_preview, call_duration_timer.time_left]
			phone_display_label.modulate = Color("#baf6ff")
		else:
			phone_display_label.text = "DESK PHONE\nSTANDBY"
			phone_display_label.modulate = Color("#84d8d1")

	if paper_display_label != null:
		if stage < 4:
			paper_display_label.text = "DOCUMENTS • STANDBY"
			paper_display_label.modulate = Color("#77776f")
		elif paperwork_active:
			paper_display_label.text = "SIGN DOCUMENT • %.1fs" % paper_timer.time_left
			_set_screen_severity(paper_display_label, 100.0 - (paper_timer.time_left / 10.0 * 100.0))
		else:
			paper_display_label.text = "DOCUMENTS • STANDBY"
			paper_display_label.modulate = Color("#efe49a")

	if crisis_display_label != null:
		if stage < 5:
			crisis_display_label.text = "CRISIS SYSTEM\nLOCKED"
			crisis_display_label.modulate = Color("#715b5b")
		elif crisis_active:
			crisis_display_label.text = "CRISIS ALERT\n%.1fs\nACT NOW" % crisis_timer.time_left
			crisis_display_label.modulate = Color("#ff7268")
		else:
			crisis_display_label.text = "CRISIS SYSTEM\nARMED"
			crisis_display_label.modulate = Color("#ffaaa2")

	if alarm_display_label != null:
		if stage < 6:
			alarm_display_label.text = "OFFICE ALARM\nLOCKED"
			alarm_display_label.modulate = Color("#756e5b")
		elif alarm_active:
			alarm_display_label.text = "ALARM ACTIVE\n%.1fs\nRESET SWITCH" % alarm_timer.time_left
			alarm_display_label.modulate = Color("#ffca63")
		else:
			alarm_display_label.text = "OFFICE ALARM\nREADY"
			alarm_display_label.modulate = Color("#f1cf7a")

	if upgrade_terminal_label != null:
		var bought_count: int = purchased_upgrades.size()
		upgrade_terminal_label.text = "UPGRADES\n%d / %d INSTALLED\nCLICK TO OPEN" % [bought_count, UPGRADES.size()]
		upgrade_terminal_label.modulate = Color("#b7ffad")

	# -------------------------
	# Upgrade terminal overlay
	# -------------------------
	for i in range(upgrade_buttons.size()):
		var upgrade: Dictionary = UPGRADES[i]
		var bought: bool = purchased_upgrades.has(str(upgrade["id"]))
		var button: Button = upgrade_buttons[i]
		if bought:
			button.text = "%s — PURCHASED" % str(upgrade["name"])
			button.disabled = true
		else:
			button.text = "%s — %d" % [str(upgrade["name"]), int(upgrade["cost"])]
			button.disabled = bombs < int(upgrade["cost"]) or not game_started


	if subtitle_toggle_button != null:
		subtitle_toggle_button.text = "SUBTITLES — " + ("ON" if subtitles_enabled else "OFF")
	if fullscreen_toggle_button != null:
		fullscreen_toggle_button.text = "FULLSCREEN — " + ("ON" if fullscreen_enabled else "OFF")

func _campaign_save_complete() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	return bool((parsed as Dictionary).get("campaign_complete", false))

func _update_menu_buttons() -> void:
	if continue_button != null:
		var has_save: bool = FileAccess.file_exists(SAVE_PATH)
		var completed: bool = _campaign_save_complete() if has_save else false
		continue_button.disabled = not has_save or completed
		continue_button.text = "CAMPAIGN COMPLETE" if completed else "CONTINUE"

func _show_status(message: String, seconds: float) -> void:
	if status_label == null:
		return

	status_label.text = message
	get_tree().create_timer(seconds).timeout.connect(_clear_status_if_same.bind(message))

func _clear_status_if_same(message: String) -> void:
	if status_label != null and status_label.text == message:
		status_label.text = ""

func _say(message: String) -> void:
	if not subtitles_enabled or subtitle_label == null:
		return

	subtitle_label.text = message
	get_tree().create_timer(3.0).timeout.connect(_clear_subtitle_if_same.bind(message))

func _clear_subtitle_if_same(message: String) -> void:
	if subtitle_label != null and subtitle_label.text == message:
		subtitle_label.text = ""
