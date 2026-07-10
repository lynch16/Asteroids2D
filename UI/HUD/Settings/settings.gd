class_name Settings
extends Node2D

@export var resolution_options: Array[ResolutionOptions] = [];

@onready var resolution_options_button: OptionButton = %ResolutionOptionButton;
@onready var full_screen_button: CheckButton = %FullscreenButton;
@onready var volume_slider: HSlider = %VolumeSlider;

@onready var save_button: AreaButton = %SaveButton;
@onready var revert_button: AreaButton = %RevertButton;

var volume_value := 0.8;
var resolution_option_idx := 1;
var fullscreen := false;

var initial_volume: float;
var initial_resolution_idx: int;
var initial_full_screen: bool;

var has_changed := false;

signal close();
signal save(); # TODO: Need to implement options saving for multiple sessions

func _ready() -> void:
	initial_volume = volume_value;
	initial_resolution_idx = resolution_option_idx;
	initial_full_screen = fullscreen;

	for resolution in resolution_options:
		resolution_options_button.add_item(resolution.name);

	resolution_options_button.item_selected.connect(_on_resolution_changed)

	resolution_options_button.select(resolution_option_idx); # 1 should be 1280x720
	_on_resolution_changed(resolution_option_idx, false); 

	## Defaults for fullscreen
	full_screen_button.set_pressed_no_signal(fullscreen);
	full_screen_button.toggled.connect(_on_fullscreen_toggle);

	volume_slider.value = volume_value;
	volume_slider.value_changed.connect(_on_volume_changed);
	_on_volume_changed(volume_value, false);
	
	revert_button.disable = !has_changed;
	revert_button.button_click.connect(_on_revert_button_click);

	save_button.button_click.connect(_on_save_button_click);

func _on_save_button_click() -> void:
	if (!has_changed):
		close.emit();
	else:
		save.emit();

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
	if (log_change):
		has_changed = true;
	volume_value = new_value;
	AudioServer.set_bus_volume_linear(0, new_value);
