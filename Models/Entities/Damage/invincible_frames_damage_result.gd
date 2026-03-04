class_name InvincibleFramesDamageResult
extends DamageResult

@export var invicible_frames := 30; # At 30fps, this is 1s;

var curr_inv_frame := 0;

func on_init(attached_node: Variant) -> void:
	_start_inv();
	super(attached_node);
	
func update(_delta: float) -> void:
	if (_is_inv()):
		curr_inv_frame += 1;

func on_damage(_dmg: float) -> bool:
	if (curr_inv_frame >= invicible_frames):
		on_end();
		return true;
		
	if (_is_inv()):
		return false;
	
	return true;

func on_end() -> void:
	_reset_inv();
	super();
	
func _is_inv() -> bool:
	return curr_inv_frame > 0;

func _reset_inv() -> void:
	curr_inv_frame = 0;
	
func _start_inv() -> void:
	curr_inv_frame = 1;
