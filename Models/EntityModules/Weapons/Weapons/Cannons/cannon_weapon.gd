@tool
class_name CannonWeapon
extends RangedWeapon

@onready var shot_fired_audio: AudioStreamPlayer2D = $AudioStreamPlayer2D;

func _try_use() -> bool:
	var was_used := super();
	if (was_used):
		shot_fired_audio.play();
	
	return was_used;