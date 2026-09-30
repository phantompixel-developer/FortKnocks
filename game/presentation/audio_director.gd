class_name FortKnocksAudioDirector
extends Node

const MIX_RATE := 22050
const TAU_F := TAU

var _ambient_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer
var _ui_player: AudioStreamPlayer
var _context := &""
var _cue_cache: Dictionary = {}
var _ambient_cache: Dictionary = {}

func _ready() -> void:
	add_to_group("fort_knocks_audio")
	_ambient_player = _make_player("Ambient", -22.0)
	_sfx_player = _make_player("SFX", -8.0)
	_ui_player = _make_player("UI", -12.0)

func set_context(context: StringName) -> void:
	if context == _context:
		return
	_context = context
	var key := String(context)
	if not _ambient_cache.has(key):
		_ambient_cache[key] = _make_ambient(key)
	_ambient_player.stream = _ambient_cache[key]
	_ambient_player.play()

func play_cue(cue: StringName) -> void:
	var key := String(cue)
	if not _cue_cache.has(key):
		_cue_cache[key] = _make_cue(key)
	var player := _ui_player if key.begins_with("ui_") else _sfx_player
	player.stream = _cue_cache[key]
	player.play()

func _make_player(node_name: String, volume: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = node_name
	player.volume_db = volume
	add_child(player)
	return player

func _make_ambient(context: String) -> AudioStreamWAV:
	var duration := 4.0
	var samples := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples * 2)
	var base_frequency := 44.0 if context == "battle" else 52.0
	if context == "hub":
		base_frequency = 48.0
	for i in range(samples):
		var t := float(i) / float(MIX_RATE)
		var low := sin(TAU_F * base_frequency * t) * 0.10
		var pulse := sin(TAU_F * (base_frequency * 1.5) * t) * 0.035
		var texture := sin(TAU_F * 3.0 * t) * sin(TAU_F * 71.0 * t) * 0.018
		var sample := clampf(low + pulse + texture, -0.85, 0.85)
		data.encode_s16(i * 2, int(round(sample * 32767.0)))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.stereo = false
	wav.data = data
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = samples
	return wav

func _make_cue(key: String) -> AudioStreamWAV:
	match key:
		"fire_heavy":
			return _tone(105.0, 0.28, -60.0, 0.12, 2.6)
		"fire_shock":
			return _tone(260.0, 0.24, 180.0, 0.04, 2.0)
		"fire":
			return _tone(180.0, 0.18, -40.0, 0.08, 2.2)
		"ricochet":
			return _tone(640.0, 0.11, -190.0, 0.03, 3.2)
		"hit_crew":
			return _tone(88.0, 0.20, -30.0, 0.15, 2.0)
		"hit_metal":
			return _tone(420.0, 0.16, -250.0, 0.18, 2.7)
		"surge":
			return _tone(210.0, 0.42, 520.0, 0.05, 1.5)
		"victory":
			return _tone(330.0, 0.52, 330.0, 0.02, 1.2)
		"defeat":
			return _tone(210.0, 0.58, -120.0, 0.05, 1.2)
		"ui_back":
			return _tone(240.0, 0.07, -40.0, 0.0, 3.0)
		_:
			return _tone(360.0, 0.08, 80.0, 0.0, 3.0)

func _tone(
	frequency: float,
	duration: float,
	sweep: float,
	texture_mix: float,
	decay_power: float
) -> AudioStreamWAV:
	var samples := maxi(1, int(duration * MIX_RATE))
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / float(MIX_RATE)
		var progress := clampf(t / duration, 0.0, 1.0)
		var current_frequency := maxf(28.0, frequency + sweep * progress)
		var envelope := pow(1.0 - progress, decay_power)
		var tone := sin(TAU_F * current_frequency * t)
		var harmonic := sin(TAU_F * current_frequency * 2.03 * t) * 0.28
		var texture := sin(TAU_F * 1733.0 * t) * sin(TAU_F * 91.0 * t)
		var sample := (tone + harmonic + texture * texture_mix) * envelope * 0.48
		data.encode_s16(i * 2, int(round(clampf(sample, -0.95, 0.95) * 32767.0)))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.stereo = false
	wav.data = data
	return wav
