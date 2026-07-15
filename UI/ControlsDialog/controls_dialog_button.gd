class_name ControlsDialogButton extends CenterContainer

@export var fade_duration := 0.5;
@export var control_action: StringName = "thrust"


@onready var default_view: TextureRect = $Default;
@onready var selected_view: TextureRect = $Selected;

var tween: Tween;

var is_selected_shown: bool = false;

signal selected();
signal deselected();

func _ready() -> void:
	default_view.modulate.a = 1.0;
	selected_view.modulate.a = 0.0;
	mouse_entered.connect(_show_selected)
	mouse_exited.connect(_show_default);

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed(control_action)):
		_show_selected();
	elif (Input.is_action_just_released(control_action)):
		_show_default();


func _show_selected() -> void:
	if (is_selected_shown): return;

	if (tween && tween.is_running()):
		tween.kill();

	is_selected_shown = true;
	selected.emit();

	tween = create_tween();
	tween.tween_property(default_view, "modulate:a", 0.0, fade_duration);
	tween.parallel().tween_property(selected_view, "modulate:a", 1.0, fade_duration);

func _show_default() -> void:
	if (!is_selected_shown): return;

	if (tween && tween.is_running()):
		tween.kill();

	is_selected_shown = false;
	deselected.emit();

	tween = create_tween();
	tween.tween_property(selected_view, "modulate:a", 0.0, fade_duration);
	tween.parallel().tween_property(default_view, "modulate:a", 1.0, fade_duration);
