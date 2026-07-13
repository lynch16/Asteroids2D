class_name Settings
extends Node2D

const SAVE_PATH := "user://settings.tres";

@export var resolution_options: Array[ResolutionOptions] = [];

@onready var resolution_options_button: OptionButton = %ResolutionOptionButton;
@onready var full_screen_button: CheckButton = %FullscreenButton;
@onready var volume_slider: HSlider = %VolumeSlider;

@onready var save_button: AreaButton = %SaveButton;
@onready var revert_button: AreaButton = %RevertButton;

var volume_value := 0.8;
var resolution_option_idx := 0;
var fullscreen := false;

var initial_volume: float;
var initial_resolution_idx: int;
var initial_full_screen: bool;

var has_changed := false;

signal on_close();

func _ready() -> void:
	for resolution in resolution_options:
		resolution_options_button.add_item(resolution.name);

	resolution_options_button.item_selected.connect(_on_resolution_changed)
	full_screen_button.toggled.connect(_on_fullscreen_toggle);
	volume_slider.value_changed.connect(_on_volume_changed);
	
	revert_button.button_click.connect(_on_revert_button_click);
	save_button.button_click.connect(_on_save_button_click);

	close();

func _load() -> void:
	var existing_settings: SettingsResource = ResourceLoader.load(SAVE_PATH);
	if (existing_settings):
		resolution_option_idx = resolution_options.find_custom(
			func(opt: ResolutionOptions) -> bool:
				if (opt.size == existing_settings.resolution):
					return true;
				return false;
		);
		fullscreen = existing_settings.fullscreen;
		volume_value = existing_settings.volume_value;

	volume_slider.value = volume_value;
	_on_volume_changed(volume_value, false);

	resolution_options_button.select(resolution_option_idx); # 1 should be 1280x720
	_on_resolution_changed(resolution_option_idx, false); 

	full_screen_button.set_pressed_no_signal(fullscreen);

func _save() -> void:
	var settings_resource := SettingsResource.new();
	settings_resource.fullscreen = fullscreen;
	settings_resource.resolution = resolution_options[resolution_option_idx].size;
	settings_resource.volume_value = volume_value;

	var error := ResourceSaver.save(settings_resource, SAVE_PATH);

	if (error == OK):
		print("Settings saved at ", SAVE_PATH);
	else:
		print("Failed saving game. Error code: ", error);

func open() -> void:
	_load();
	var viewport := get_viewport_rect();
	global_position = Vector2(viewport.size.x/2, viewport.size.y/2);
	initial_volume = volume_value;
	initial_resolution_idx = resolution_option_idx;
	initial_full_screen = fullscreen;
	revert_button.disable = !has_changed;
	show();
	process_mode = Node.PROCESS_MODE_ALWAYS;

func close() -> void:
	hide();
	has_changed = false;
	process_mode = Node.PROCESS_MODE_DISABLED;

func _on_save_button_click() -> void:
	if (has_changed):
		_save();

	close();
	on_close.emit();

func _on_revert_button_click() -> void:
	_on_resolution_changed(initial_resolution_idx, false);
	resolution_options_button.select(initial_resolution_idx);
	_on_fullscreen_toggle(initial_full_screen, false);
	full_screen_button.set_pressed_no_signal(initial_full_screen);
	_on_volume_changed(initial_volume, false);
	volume_slider.value = initial_volume;
	has_changed = false;

func _process(_delta: float) -> void:
	revert_button.disable = !has_changed;

	if (has_changed):
		save_button.button_text = "Save";
	else:
		save_button.button_text = "Close";

func _on_resolution_changed(option_index: int, log_change: bool = true) -> void:
	if (log_change):
		has_changed = true;
	resolution_option_idx = option_index;
	var resolution := resolution_options[option_index];
	DisplayServer.window_set_size(resolution.size);

func _on_fullscreen_toggle(pressed: bool, log_change: bool = true) -> void:
	if (log_change):
		has_changed = true;
	fullscreen = pressed;
	if (pressed):
		resolution_options_button.disabled = true;
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN);
	else:
		resolution_options_button.disabled = false;
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);

func _on_volume_changed(new_value: float, log_change: bool = true) -> void:
	if (log_change && volume_value != new_value):
		has_changed = true;
	volume_value = new_value;
	AudioServer.set_bus_volume_linear(0, new_value);
