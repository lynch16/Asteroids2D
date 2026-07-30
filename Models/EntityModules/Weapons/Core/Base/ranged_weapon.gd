@tool 
class_name RangedWeapon
extends Weapon
## RangedWeapon is a Weapon that has a ThrowerComponent

# TODO: This could probably be expanded to support multiple projectiles by iterating the thrower
@export var thrower: ThrowerComponent:
	set(value):
		thrower = value;
		update_configuration_warnings();
@export var variance := 1.0;
@export var straight_shooter := true;

func _ready() -> void:
	super();

	if (thrower == null):
		thrower = get_node("%ThrowerComponent");
		
	thrower.projectiles_created.connect(_set_projectile_combat_stats);

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray();
	if (thrower == null && get_node_or_null("%ThrowerComponent") == null):
		warnings.append("Projectile is missing ThrowerComponent");
	return warnings;

func _use() -> void:
	# Default per coded exports will be throw straight with variance
	if (variance != 0.0 && straight_shooter):
		thrower.throw_straight_with_variance(variance);
		return;
	elif (variance != 0.0):
		thrower.throw_direct_with_variance(variance);
		return;
	elif (straight_shooter):
		thrower.throw_straight();
		return;
	else:
		thrower.throw_direct();
		return;
	
func _set_projectile_combat_stats(projectiles: Array[Projectile]) -> void:
	for projectile in projectiles:
		projectile.combat_stats = combat_stats;
