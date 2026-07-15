class_name  MusicPlayer
extends AudioStreamPlayer

const MUSIC_INDEX = {
	Title = 0,
	Pause = 1,
	Win = 2,
	Lose = 3,
}

const LEVEL_INDEX = {
	Level1 = 4, 
	Level2 = 5,
	Level3 = 6,
	Level4 = 7,
	Level5 = 8
}

var current_level_music: int = 0;

func pause_music() -> void:
	if (is_playing()):
		stop();

func _transition_music(clip_index: int) -> void:
	if (!is_playing()):
		play();

	var playback: AudioStreamPlaybackInteractive = get_stream_playback();
	print("SWITCH TO _", clip_index)
	playback.switch_to_clip(clip_index);


func play_level_music() -> void:
	_transition_music(current_level_music);

func play_next_level_music(level_index: int) -> void:
	current_level_music = LEVEL_INDEX.values()[level_index];
	play_level_music();

func play_title_music() -> void:
	_transition_music(MUSIC_INDEX.Title);

func play_pause_music() -> void:
	_transition_music(MUSIC_INDEX.Pause);

func play_win_music() -> void:
	_transition_music(MUSIC_INDEX.Win);

func _play_lose_music() -> void:
	_transition_music(MUSIC_INDEX.Lose);
