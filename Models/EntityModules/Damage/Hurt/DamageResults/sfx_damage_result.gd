class_name SfxDamageResult
extends DamageResult

@export var position_particles_at_hit_location := false;
@export var play_off_screen := false;
@export var sfx_lifetime := 1.0;
@export var particles_scene: PackedScene;
@export var audio_stream: AudioStreamPlayer2D;

var on_screen_notifier: VisibleOnScreenNotifier2D;

func _ready() -> void:
	if (!play_off_screen):
		on_screen_notifier = VisibleOnScreenNotifier2D.new();
		add_child(on_screen_notifier);

func on_damage(_damage_dealt: float, _dmgr: Node, hit_position: Vector2, hit_angle: float) -> bool:
	if (on_screen_notifier && !on_screen_notifier.is_on_screen()): 
		return true;

	var particles: GPUParticles2D;
	if (particles_scene):
		particles = particles_scene.instantiate();

		particles.emitting = true;

		if (position_particles_at_hit_location):
			particles.global_position = hit_position;
			particles.global_rotation = hit_angle;

		add_child(particles);

	if (audio_stream):
		audio_stream.play();

	get_tree().create_timer(sfx_lifetime, false).timeout.connect(_stop_playing.bind(particles));

	return true;

func _stop_playing(particles: GPUParticles2D) -> void:
	if (particles):
		particles.queue_free();
	if (audio_stream):
		audio_stream.stop();
