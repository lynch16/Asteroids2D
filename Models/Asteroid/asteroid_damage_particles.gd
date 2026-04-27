class_name AsteroidDamageParticles
extends GPUParticles2D

var _process_material: ParticleProcessMaterial = preload("res://Models/Asteroid/asteroid_particle_process_material.tres");

func _ready() -> void:
	one_shot = true;
	amount = 50;
	lifetime = 1.0;
	explosiveness = 1.0;
	process_material = _process_material;

	finished.connect(Callable(self, "_queue_free"));
