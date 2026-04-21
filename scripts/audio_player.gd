extends AudioStreamPlayer

const level_music = preload("res://audio/main_menu_music.mp3")

func _play_music(music: AudioStream, volume:float = -20.0):
	if stream == music:
		return
	
	stream = music
	volume_db = volume
	play()
	
func play_music_level():
	_play_music(level_music)

func play_sound_effect(stream_file: AudioStream, volume: float = 0.0):
	var sound_effect = AudioStreamPlayer.new()
	sound_effect.stream = stream_file
	sound_effect.name = "Sound_effect"
	sound_effect.volume_db = volume
	add_child(sound_effect)
	sound_effect.play()
