extends Node


var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"

func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("keybinding", "walk_left", "A")
		config.set_value("keybinding", "walk_right", "D")
		config.set_value("keybinding", "up", "W")
		config.set_value("keybinding", "down", "S")
		config.set_value("keybinding", "jump", "Space")
		config.set_value("keybinding", "dash", "Shift")
		config.set_value("keybinding", "walk_slow", "Ctrl")
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)
	
	_apply_saved_volumes()
	
	var keybindings = load_keybindings()
	for action in keybindings.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybindings[action])

func _apply_saved_volumes() -> void:
	_apply_volume("Master", load_volume("master", 0.5))
	_apply_volume("Music",  load_volume("music",  0.5))
	_apply_volume("SFX",    load_volume("sfx",    0.5))

func _apply_volume(bus_name: String, value: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return
	if value == 0.0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func save_keybinding(action: StringName, event: InputEvent):
	var event_str
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
	
	config.set_value("keybinding", action, event_str)
	config.save(SETTINGS_FILE_PATH)
	
func load_keybindings():
	var keybindings = {}
	var keys = config.get_section_keys("keybinding")
	for key in keys:
		var input_event
		var event_str = config.get_value("keybinding", key)
		
		if event_str.contains("mouse_"):
			input_event = InputEventMouseButton.new()
			input_event.button_index = int(event_str.split("_")[1])
		else:
			input_event = InputEventKey.new()
			input_event.keycode = OS.find_keycode_from_string(event_str)
		
		keybindings[key] = input_event
	return keybindings

func save_volume(bus: String, value: float) -> void:
	config.set_value("audio", bus + "_volume", value)
	config.save(SETTINGS_FILE_PATH)

func load_volume(bus: String, default: float = 0.5) -> float:
	return config.get_value("audio", bus + "_volume", default)
