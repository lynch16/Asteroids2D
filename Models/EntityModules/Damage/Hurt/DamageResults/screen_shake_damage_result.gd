class_name ScreenShakeDamageResult extends DamageResult

@export var camera_node_path: String;
@export var shake_intensity: int;
@export var shake_length: float;

var camera: ShakeableCamera2D;

func _ready() -> void:
	camera = get_node(camera_node_path);

func on_damage(_dmg: float, _damager_node: Node, _hit_position: Vector2, _hit_angle: float) -> bool: 
	if (camera):
		camera._screen_shake(shake_intensity, shake_length);
	return true;
