class_name AreaButton
extends Area2D

@export var button_text: String:
	set(value):
		button_text = value;
		_update_button_text(value);
@export var is_reselectable: bool = false;
@export var button_state_transition_length := 1.0;
@export var disable := false:
	set(value):
		if (disable != value):
			disable = value;
			_disable_input(value);

@export var normal_label_settings: LabelSettings;
@export var disabled_label_settings: LabelSettings;

@onready var entered_timer: Timer = $EnteredTimer;
@onready var click_timer: Timer = $ClickTimer;
@onready var rapid_click_timer: Timer = $RapidClickTimer;

@onready var button_label: Label = $BoxContainer/Label;

@onready var normal_texture: Sprite2D = $Normal;
@onready var pressed_texture: Sprite2D = $Pressed;
@onready var hover_texture: Sprite2D = $Hover;
@onready var disabled_texture: Sprite2D = $Disabled;

@onready var hover_sound: AudioStreamPlayer = $HoverAudioPlayer;
@onready var click_sound: AudioStreamPlayer = $ClickAudioPlayer;

var is_hovered := false;
var is_selected := false;
var is_disabled := false;

var tween: Tween;

signal button_click();

func _ready() -> void:
	entered_timer.timeout.connect(_on_click_timer_start);
	click_timer.timeout.connect(_notify_click);
	rapid_click_timer.timeout.connect(_notify_click);

	body_entered.connect(_on_body_enter);
	body_exited.connect(_on_body_exit);

	button_label.text = button_text;

	if (disable):
		normal_texture.self_modulate.a = 0.0;
		pressed_texture.self_modulate.a = 0.0;
		disabled_texture.self_modulate.a = 1.0;
	else:
		normal_texture.self_modulate.a = 1.0;
		disabled_texture.self_modulate.a = 0.0;
		pressed_texture.self_modulate.a = 0.0;

	pressed_texture.self_modulate.a = 0.0;
	hover_texture.self_modulate.a = 0.0;

	mouse_entered.connect(_transition_to_hover)
	mouse_exited.connect(_transition_to_normal)

	_disable_input(disable);

func _notify_click() -> void:
	is_selected = true;
	_stop_all_timers();
	button_click.emit();

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton):
		var e: InputEventMouseButton = event;
		if (e.button_index == MouseButton.MOUSE_BUTTON_LEFT):
			if (e.pressed):
				if (!is_disabled && is_hovered):
					_transition_textures(pressed_texture, [hover_texture, normal_texture, disabled_texture], click_timer.wait_time);
					rapid_click_timer.start();
					click_sound.play();
					is_selected = true;

func _update_button_text(new_text: String) -> void:
	if (button_label):
		button_label.text = new_text;

func _disable_input(p_is_disabled: bool) -> void:
	is_disabled = p_is_disabled;
	if (p_is_disabled):
		if (button_label):
			_transition_to_disabled();
			button_label.label_settings = disabled_label_settings;
	else:
		if (button_label):
			_transition_to_normal();
			button_label.label_settings = normal_label_settings;

func _transition_to_normal() -> void:
	# Dont reset to normal if the input has been clicked
	if (is_selected):
		if (!is_reselectable):
			return;
		else:
			is_selected = false;

	if (!is_disabled && is_hovered):
		_transition_textures(normal_texture, [hover_texture, pressed_texture, disabled_texture]);
		is_hovered = false;

func _transition_to_hover() -> void:
	if (!is_disabled && !is_hovered):
		hover_sound.play();
		_transition_textures(hover_texture, [normal_texture, pressed_texture, disabled_texture]);
		is_hovered = true;

func _transition_to_disabled() -> void:
	is_disabled = true;
	_transition_textures(disabled_texture, [normal_texture, hover_texture, pressed_texture]);

func _on_body_enter(node: Node2D) -> void:
	if (!is_disabled && node is Player):
		_on_entered_timer_start();
		_transition_to_hover();

func _stop_all_timers() -> void:
	if (!entered_timer.is_stopped()):
		entered_timer.stop();
	if (!click_timer.is_stopped()):
		click_timer.stop();
	if (!rapid_click_timer.is_stopped()):
		rapid_click_timer.stop();

func _on_body_exit(node: Node2D) -> void:
	if (node is Player):
		_stop_all_timers();
		_transition_to_normal();

func _transition_to_pressed() -> void:
	_transition_textures(pressed_texture, [hover_texture, normal_texture], click_timer.wait_time);

func _on_click_timer_start() -> void:
	if (click_timer.is_stopped()):
		click_timer.start();
		_transition_to_pressed();

func _on_entered_timer_start() -> void:
	if (entered_timer.is_stopped()):
		entered_timer.start();
		_transition_textures(hover_texture, [pressed_texture, normal_texture], entered_timer.wait_time);

func _transition_textures(texture_in: Sprite2D, texture_outs: Array[Sprite2D], transition_length: float = button_state_transition_length) -> void:
	if (tween && tween.is_running()):
		tween.kill();

	tween = create_tween();
	tween.tween_property(texture_in, "self_modulate:a", 1.0, transition_length);

	for texture_out in texture_outs:
		tween.parallel().tween_property(texture_out, "self_modulate:a", 0.0, transition_length/2.0);
