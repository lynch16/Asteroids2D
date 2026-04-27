class_name InvincibleFramesDamageResult
extends DamageResult

@export var invicible_frames := 30; # At 30fps, this is 1s;
@export var restart_on_new_damage := false;

var curr_inv_frame_count := 0;
var start_inv_frame_count := 0;

func _init(
	p_invicible_frames: int = 30,
	p_restart_on_new_damage: bool = false
) -> void:
	invicible_frames = p_invicible_frames;
	restart_on_new_damage = p_restart_on_new_damage;

func on_init(p_damageable: Damageable) -> void:
	super(p_damageable);
	_start_inv();
	
func update(_delta: float) -> void:
	if (_is_inv()):
		curr_inv_frame_count = Engine.get_frames_drawn() - start_inv_frame_count;
		if (curr_inv_frame_count >= invicible_frames):
			on_end();

func on_damage(_damage_dealt: float, _dmgr: Node) -> bool:
	if (_is_inv()):
		return false;
		
	if (restart_on_new_damage):
		_start_inv();
		
	return true;

func on_end() -> void:
	super();
	_reset_inv();
	
func _is_inv() -> bool:
	return curr_inv_frame_count > 0;

func _reset_inv() -> void:
	curr_inv_frame_count = 0;
	
func _start_inv() -> void:
	start_inv_frame_count = Engine.get_frames_drawn();
	curr_inv_frame_count = start_inv_frame_count;;
