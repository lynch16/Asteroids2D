class_name HealthBarDamageResult
extends DamageResult

@export var health_stats: HealthStats;
@export var progress_bar: TextureProgressBar;

func _ready() -> void:
	health_stats.set_health_bar(progress_bar);
	progress_bar.hide();

func on_damage(_damage_dealt: float, _dmgr: Node, _hit_position: Vector2, _hit_angle: float) -> bool:
	health_stats.update_health_bar();
	if (progress_bar.hidden):
		progress_bar.show();
	return true;
