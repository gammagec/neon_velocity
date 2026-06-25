extends SceneTree

const SAMPLE_RATE := 44100
const BPM := 150.0
const STEP_DUR := 60.0 / BPM / 2.0 # eighth note
const SAMPLES_PER_STEP := 8820 # round(STEP_DUR * SAMPLE_RATE)

const LEAD_AMP := 0.22
const BASS_AMP := 0.20
const NOISE_AMP := 0.07

const LEAD_ATTACK := 200
const LEAD_RELEASE := 300
const BASS_ATTACK := 150
const BASS_RELEASE := 400
const NOISE_LEN := 882 # 20ms hi-hat tick

# 4 bars x 8 eighth notes, A minor, original riff with rests for syncopation.
const MELODY := [
	69, -1, 72, 71, 69, -1, 76, 74,
	72, 71, 69, 67, 69, -1, 71, 72,
	74, -1, 77, 76, 74, -1, 72, 71,
	69, 72, 71, 69, 67, 64, 67, 69,
]
const BASS_ROOT_PER_BAR := [57, 57, 52, 57] # A3, A3, E3, A3

func _init() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/audio")
	var samples := _generate_samples()
	_write_wav("res://assets/audio/music.wav", samples)
	print("Music generation done, samples=", samples.size())
	quit()

func _midi_to_freq(midi: int) -> float:
	return 440.0 * pow(2.0, float(midi - 69) / 12.0)

func _square(phase: float) -> float:
	var p := fmod(phase, 1.0)
	return 1.0 if p < 0.5 else -1.0

func _triangle(phase: float) -> float:
	var p := fmod(phase, 1.0)
	return 4.0 * abs(p - 0.5) - 1.0

func _envelope(i: int, total: int, attack: int, release: int) -> float:
	if i < attack:
		return float(i) / float(attack)
	if i > total - release:
		return float(total - i) / float(release)
	return 1.0

func _generate_samples() -> PackedFloat32Array:
	var total_samples := MELODY.size() * SAMPLES_PER_STEP
	var samples := PackedFloat32Array()
	samples.resize(total_samples)

	for step in range(MELODY.size()):
		var bar := step / 8
		var lead_note: int = MELODY[step]
		var bass_note: int = BASS_ROOT_PER_BAR[bar]
		var lead_freq := _midi_to_freq(lead_note) if lead_note >= 0 else 0.0
		var bass_freq := _midi_to_freq(bass_note)
		var base_index := step * SAMPLES_PER_STEP

		for i in range(SAMPLES_PER_STEP):
			var t := float(base_index + i) / float(SAMPLE_RATE)
			var value := 0.0

			if lead_note >= 0:
				var env := _envelope(i, SAMPLES_PER_STEP, LEAD_ATTACK, LEAD_RELEASE)
				value += _square(lead_freq * t) * LEAD_AMP * env

			var bass_env := _envelope(i, SAMPLES_PER_STEP, BASS_ATTACK, BASS_RELEASE)
			value += _triangle(bass_freq * t) * BASS_AMP * bass_env

			if i < NOISE_LEN:
				var decay := 1.0 - (float(i) / float(NOISE_LEN))
				value += randf_range(-1.0, 1.0) * NOISE_AMP * decay

			samples[base_index + i] = clampf(value, -1.0, 1.0)

	return samples

func _write_wav(path: String, samples: PackedFloat32Array) -> void:
	var num_channels := 1
	var bits_per_sample := 16
	var byte_rate := SAMPLE_RATE * num_channels * bits_per_sample / 8
	var block_align := num_channels * bits_per_sample / 8
	var data_size := samples.size() * 2
	var chunk_size := 36 + data_size

	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_buffer("RIFF".to_ascii_buffer())
	f.store_32(chunk_size)
	f.store_buffer("WAVE".to_ascii_buffer())
	f.store_buffer("fmt ".to_ascii_buffer())
	f.store_32(16)
	f.store_16(1)
	f.store_16(num_channels)
	f.store_32(SAMPLE_RATE)
	f.store_32(byte_rate)
	f.store_16(block_align)
	f.store_16(bits_per_sample)
	f.store_buffer("data".to_ascii_buffer())
	f.store_32(data_size)
	for s in samples:
		f.store_16(int(round(s * 32767.0)))
	f.close()
