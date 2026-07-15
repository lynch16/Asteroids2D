class_name ControlDetailsContainer extends MarginContainer

@export var fade_duration: float = 0.2;

@onready var overview: Label = $Overview;
@onready var w: Label = $W;
@onready var a: Label = $A;
@onready var d: Label = $D;
@onready var r: Label = $R;
@onready var space: Label = $Space;

var selected_label: Label;

var tween: Tween;

func _ready() -> void:
	overview.modulate.a = 1.0;
	w.modulate.a = 0.0;
	a.modulate.a = 0.0;
	d.modulate.a = 0.0;
	r.modulate.a = 0.0;
	space.modulate.a = 0.0;

	selected_label = overview;

func show_w() -> void:
	_show_label(w);

func show_overview() -> void:
	_show_label(overview);

func show_a() -> void:
	_show_label(a);

func show_d() -> void:
	_show_label(d);

func show_r() -> void:
	_show_label(r);
	
func show_space() -> void:
	_show_label(space);

func _show_label(label: Label) -> void:
	if (selected_label == label): return;

	if (tween && tween.is_running()):
		tween.kill();

	tween = create_tween();
	tween.tween_property(selected_label, "modulate:a", 0.0, fade_duration);
	tween.tween_property(label, "modulate:a", 1.0, fade_duration);

	selected_label = label;
