class_name Player
extends CharacterEntity

@export var mass := 2;

var bulletScn := preload("res://Models/Player/bullet.tscn");

@onready var bullet_spawn_loc: Node2D = get_node("BulletSpawnLocation");
@onready var bullet_timer: Timer = get_node("BulletSpawnTimer");
@onready var damageable: Damageable = get_node("Damageable");
@onready var apply_damage_dr: ApplyDamageResult = get_node("Damageable/ApplyDamageResult");

func _ready() -> void:
	super();
	bullet_timer.timeout.connect(_spawn_bullet)
	# Register broadcast handler and emit initial health state
	apply_damage_dr.damage_applied.connect(_handle_player_damage);
	damageable.on_destroy.connect(_die);
	
	# Call deferred so that handlers can connect before initial broadcast
	SignalBus.call_deferred("_on_player_health_updated", int(damageable.curr_health));
	
func _physics_process(delta: float) -> void:
	acceleration = Vector2.ZERO;
	
	if (Input.is_action_pressed("yaw_left")):
		_yaw_left(delta);
	
	if (Input.is_action_pressed("yaw_right")):
		_yaw_right(delta);
	
	if (Input.is_action_pressed("thrust")):
		_move_forward();
	
	if (Input.is_action_pressed("brake")):
		_brake();
		
	super(delta);
	
	_handle_body_collisions();
	
	if (Input.is_action_pressed("fire_weapon")):
		_fire_weapon();

# MUST be called after move_and_slide to register collisions
# TODO: Need god mode to disable asteroid collisions
func _handle_body_collisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i);
		var maybe_deal_damage: Variant = collision.get_collider().get("deal_damage");
		if maybe_deal_damage is DealDamage:
			var deal_damager: DealDamage = maybe_deal_damage;
			deal_damager.damage(self);
			
func _handle_player_damage(_dmg: float, _new_health: float) -> void:
	SignalBus._on_player_health_updated(int(damageable.curr_health));

func _fire_weapon() -> void:
	if (bullet_timer.is_stopped()):
		bullet_timer.start();

func _spawn_bullet() -> void:
	var bullet: Bullet = bulletScn.instantiate();
	get_tree().root.add_child(bullet)
	bullet.fire_bullet(
		bullet_spawn_loc.global_position, 
		ship_direction, 
		velocity
	);
	
func _die() -> void:
	GameManager.trigger_game_over();
