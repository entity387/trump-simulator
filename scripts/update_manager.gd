extends Node

signal update_available(info: Dictionary)
signal update_status(message: String)

const DEFAULT_VERSION := "1.1.0"
const DEFAULT_MANIFEST_URL := "https://simulatedstudios.com/updates/trump-simulator.json"

var available_update: Dictionary = {}
var checking := false
var downloading := false

func current_version() -> String:
	return str(ProjectSettings.get_setting(
		"trump_simulator/update/current_version",
		DEFAULT_VERSION
	))

func manifest_url() -> String:
	return str(ProjectSettings.get_setting(
		"trump_simulator/update/manifest_url",
		DEFAULT_MANIFEST_URL
	))

func check_for_updates() -> void:
	if checking or downloading:
		return

	var check_in_editor := bool(ProjectSettings.get_setting(
		"trump_simulator/update/check_in_editor",
		false
	))
	if OS.has_feature("editor") and not check_in_editor:
		return

	var url := manifest_url().strip_edges()
	if not url.begins_with("https://"):
		return

	checking = true
	var http := HTTPRequest.new()
	http.timeout = 6.0
	add_child(http)

	var error := http.request(url, PackedStringArray([
		"Accept: application/json",
		"Cache-Control: no-cache"
	]))
	if error != OK:
		http.queue_free()
		checking = false
		return

	var response: Array = await http.request_completed
	http.queue_free()
	checking = false

	if response.size() < 4:
		return

	var result: int = int(response[0])
	var status_code: int = int(response[1])
	var body: PackedByteArray = response[3]

	# Update checks are deliberately silent when the website is unavailable.
	if result != HTTPRequest.RESULT_SUCCESS or status_code != 200:
		return

	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	var info := parsed as Dictionary
	var remote_version := str(info.get("version", "")).strip_edges()
	var download_url := str(info.get("download_url", "")).strip_edges()
	var expected_hash := str(info.get("sha256", "")).strip_edges().to_lower()

	if remote_version.is_empty():
		return
	if not download_url.begins_with("https://"):
		return
	if not _valid_sha256(expected_hash):
		return
	if not _is_newer(remote_version, current_version()):
		return

	available_update = info.duplicate(true)
	update_available.emit(available_update)

func download_and_launch_update() -> bool:
	if downloading or available_update.is_empty():
		return false

	var download_url := str(available_update.get("download_url", "")).strip_edges()
	var expected_hash := str(available_update.get("sha256", "")).strip_edges().to_lower()
	if not download_url.begins_with("https://") or not _valid_sha256(expected_hash):
		update_status.emit("UPDATE INFORMATION IS INVALID.")
		return false

	downloading = true
	update_status.emit("DOWNLOADING UPDATE...")

	var temp_path := OS.get_temp_dir().path_join("TrumpSimulatorUpdate.exe")
	if FileAccess.file_exists(temp_path):
		DirAccess.remove_absolute(temp_path)

	var http := HTTPRequest.new()
	http.timeout = 120.0
	http.download_file = temp_path
	add_child(http)

	var error := http.request(download_url, PackedStringArray([
		"Accept: application/octet-stream",
		"Cache-Control: no-cache"
	]))
	if error != OK:
		http.queue_free()
		downloading = false
		update_status.emit("COULD NOT START THE DOWNLOAD.")
		return false

	var response: Array = await http.request_completed
	http.queue_free()

	if response.size() < 4:
		downloading = false
		update_status.emit("THE UPDATE DOWNLOAD FAILED.")
		return false

	var result: int = int(response[0])
	var status_code: int = int(response[1])
	if result != HTTPRequest.RESULT_SUCCESS or status_code < 200 or status_code >= 300:
		downloading = false
		update_status.emit("THE UPDATE DOWNLOAD FAILED.")
		return false

	update_status.emit("VERIFYING UPDATE...")
	var actual_hash := FileAccess.get_sha256(temp_path).to_lower()
	if actual_hash.is_empty() or actual_hash != expected_hash:
		DirAccess.remove_absolute(temp_path)
		downloading = false
		update_status.emit("UPDATE VERIFICATION FAILED. NOTHING WAS INSTALLED.")
		return false

	update_status.emit("STARTING INSTALLER...")
	var args := PackedStringArray([
		"/VERYSILENT",
		"/SUPPRESSMSGBOXES",
		"/NORESTART",
		"/CLOSEAPPLICATIONS",
		"/NORESTARTAPPLICATIONS"
	])
	var pid := OS.create_process(temp_path, args)
	downloading = false

	if pid <= 0:
		update_status.emit("COULD NOT START THE UPDATE INSTALLER.")
		return false

	return true

func _valid_sha256(value: String) -> bool:
	if value.length() != 64:
		return false
	for ch in value:
		if not ("0" <= ch and ch <= "9") and not ("a" <= ch and ch <= "f"):
			return false
	return true

func _is_newer(remote: String, local: String) -> bool:
	var r := _version_parts(remote)
	var l := _version_parts(local)
	var count := maxi(r.size(), l.size())
	for i in range(count):
		var rv := int(r[i]) if i < r.size() else 0
		var lv := int(l[i]) if i < l.size() else 0
		if rv > lv:
			return true
		if rv < lv:
			return false
	return false

func _version_parts(value: String) -> Array[int]:
	var cleaned := value.strip_edges()
	if cleaned.begins_with("v"):
		cleaned = cleaned.substr(1)
	var dash := cleaned.find("-")
	if dash >= 0:
		cleaned = cleaned.substr(0, dash)

	var result: Array[int] = []
	for part in cleaned.split("."):
		var digits := ""
		for ch in part:
			if "0" <= ch and ch <= "9":
				digits += ch
			else:
				break
		result.append(int(digits) if not digits.is_empty() else 0)
	return result
