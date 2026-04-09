class_name InvincibleFramesDamageResult
extends DamageResult

@export var invicible_frames := 30; # At 30fps, this is 1s;
@export var restart_on_new_damage := false;

var curr_inv_frame := 0;
var attached_node: Variant;

func on_init(_attached_node: Variant) -> void:
	_start_inv();
	attached_node = _attached_node;
	super(attached_node);
	
func update(_delta: float) -> void:
	if (_is_inv()):
		curr_inv_frame += 1;

func on_damage(_damage_dealt: float, _curr_health: float, _dmgr: Node) -> bool:
	if (curr_inv_frame >= invicible_frames):
		on_end();
		return true;
		
	if (_is_inv()):
		return false;
	
	if (restart_on_new_damage):
		on_init(attached_node);
		
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
