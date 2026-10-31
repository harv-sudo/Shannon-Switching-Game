extends AudioStreamPlayer

signal mute_changed
const LEVEL_MUSIC = preload("res://audio/main_menu_music.mp3")
var muted: bool = false

func _ready() -> void:
	var settings = ConfigFile.new()
	if settings.load("user://settings.cfg") == OK:
		muted = settings.get_value("audio", "muted", false)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)

func toggle_mute() -> void:
	muted = not muted
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)
	var settings = ConfigFile.new()
	settings.set_value("audio", "muted", muted)
	settings.save("user://settings.cfg")
	mute_changed.emit()

func play_music_level() -> void:
	if stream == LEVEL_MUSIC and playing:
		return
	stream = LEVEL_MUSIC
	volume_db = -24.0
	play()

func play_sound_effect(stream_file: AudioStream, volume: float = -8.0) -> void:
	var sound_effect = AudioStreamPlayer.new()
	sound_effect.stream = stream_file
	sound_effect.volume_db = volume
	add_child(sound_effect)
	sound_effect.finished.connect(sound_effect.queue_free)
	sound_effect.play()
