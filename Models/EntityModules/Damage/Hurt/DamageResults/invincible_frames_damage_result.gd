class_name InvincibleFramesDamageResult
extends DamageResult

@export var invincible_length := 0.5; ## in seconds
@export var restart_on_new_damage := false;

var timer: Timer;

func _init(
	p_invincible_length: int = 1,
	p_restart_on_new_damage: bool = false
) -> void:
	invincible_length = p_invincible_length;
	restart_on_new_damage = p_restart_on_new_damage;

func on_init(p_damageable: Damageable) -> void:
	super(p_damageable);
	timer = Timer.new();
	timer.wait_time = invincible_length;
	timer.timeout.connect(on_end);
	add_child(timer);
	
func on_damage(_damage_dealt: float, _dmgr: Node, _hit_position: Vector2, _hit_angle: float) -> bool:
	if (_is_inv()):
		return false;
		
	if (restart_on_new_damage):
		start_invincible();
		
	return true;

func on_end() -> void:
	super();
	_reset_inv();
	
func _is_inv() -> bool:
	return !timer.is_stopped();

func _reset_inv() -> void:
	timer.stop();
	
func start_invincible() -> void:
	timer.start();
