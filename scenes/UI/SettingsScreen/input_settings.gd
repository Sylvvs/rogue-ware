extends Control

@onready var input_button_scene = preload("res://scenes/UI/SettingsScreen/input_button.tscn")
@onready var action_list = $PanelContainer/MarginContainer/VBoxContainer2/VBoxContainer/ScrollContainer/ActionList

@onready var master_slider = $"MarginContainer/VBoxContainer/Master volume/Master_slider"
@onready var music_slider = $"MarginContainer/VBoxContainer/Music volume/Music_slider"
@onready var sfx_slider = $"MarginContainer/VBoxContainer/SFX volume/SFX_slider"

var is_remapping = false
var action_to_remap = null
var remapping_button = null

var input_actions = {
	"walk_left": "Left",
	"walk_right": "Right",
	"up": "Up",
	"down": "Down",
	"jump": "Jump",
	"dash": "Dash",
	"walk_slow": "Walk Slow",
}


func _ready() -> void:
	_load_keybindings_from_settings()
	_create_action_list()
	_setup_volume_sliders()

func _setup_volume_sliders() -> void:
	for slider in [master_slider, music_slider, sfx_slider]:
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.01


	master_slider.value = ConfigFileHandler.load_volume("master", 0.5)
	music_slider.value = ConfigFileHandler.load_volume("music", 0.5)
	sfx_slider.value = ConfigFileHandler.load_volume("sfx", 0.5)


	_apply_volume("Master", master_slider.value)
	_apply_volume("Music", music_slider.value)
	_apply_volume("SFX", sfx_slider.value)

	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)

func _apply_volume(bus_name: String, value: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return  
	if value == 0.0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
		
func _on_master_volume_changed(value: float) -> void:
	_apply_volume("Master", value)
	ConfigFileHandler.save_volume("master", value)

func _on_music_volume_changed(value: float) -> void:
	_apply_volume("Music", value)
	ConfigFileHandler.save_volume("music", value)

func _on_sfx_volume_changed(value: float) -> void:
	_apply_volume("SFX", value)
	ConfigFileHandler.save_volume("sfx", value)


func _load_keybindings_from_settings():
	var keybindings = ConfigFileHandler.load_keybindings()
	for action in keybindings.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybindings[action])

func _create_action_list():
	for item in action_list.get_children():
		item.queue_free()
	
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		
		action_label.text = input_actions[action]
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
			
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))
		
func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press any key to bind..."

func _input(event):
	if is_remapping:
		if (
			event is InputEventKey ||
			(event is InputEventMouseButton && event.pressed)
		):
			
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false;
			
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			ConfigFileHandler.save_keybinding(action_to_remap, event)
			_update_action_list(remapping_button, event)
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			accept_event()

func _update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")


func _on_reset_button_pressed() -> void:
	InputMap.load_from_project_settings()
	for action in input_actions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			ConfigFileHandler.save_keybinding(action, events[0])
	_create_action_list()


func _on_close_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/StartScreen/start_screen.tscn")
