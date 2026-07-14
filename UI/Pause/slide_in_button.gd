class_name SlideInButton extends AreaButton

@export var transition_duration: float = 0.5;
@export var offscreen_position: Vector2;

var slide_tween: Tween;

var initial_position: Vector2;

func _ready() -> void:
	super();

	initial_position = position;
	position = offscreen_position;

func slide_in(delay: float = 0.0) -> void:
	if (slide_tween && slide_tween.is_running()):
		slide_tween.kill();

	_transition_to_normal();

	slide_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK);
	slide_tween.tween_property(self, "position", initial_position, transition_duration).set_delay(delay);

func slide_out(delay: float = 0.0) -> void:
	if (slide_tween && slide_tween.is_running()):
		slide_tween.kill();

	_transition_to_normal();

	slide_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK);
	slide_tween.tween_property(self, "position", offscreen_position, transition_duration).set_delay(delay);
