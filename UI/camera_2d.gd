class_name ShakeableCamera2D
extends Camera2D

var shake_decay := 5.0;
var shake_time_speed := 20.0;
var unshake_speed := 10.5;

var shake_intensity: float = 0.0;
var active_shake_time := 0.0;
var shake_time := 0.0;

var noise := FastNoiseLite.new();

func _physics_process(delta: float) -> void:
	if (active_shake_time > 0):
		shake_time += delta + shake_time_speed;
		active_shake_time -= delta;

		offset = Vector2(
			noise.get_noise_2d(shake_time, 0) * shake_intensity,
			noise.get_noise_2d(0, shake_time) * shake_intensity,
		);

		shake_intensity = max(shake_intensity - shake_decay * delta, 0);
	else:
		offset = lerp(offset, Vector2.ZERO, unshake_speed * delta);

func _screen_shake(intensity: int, time: float) -> void:
	randomize();
	noise.seed = randi();
	noise.frequency = 2.0;

	shake_intensity = intensity;
	active_shake_time = time;
	shake_time = 0;
