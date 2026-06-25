extends SceneTree

const SAMPLE_RATE := 44100

func _init() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/audio")
	_write_wav("res://assets/audio/jump.wav", _generate_jump())
	_write_wav("res://assets/audio/death.wav", _generate_death())
	print("SFX generation done")
	quit()

func _square(phase: float) -> float:
	var p := fmod(phase, 1.0)
	return 1.0 if p < 0.5 else -1.0

func _envelope(i: int, total: int, attack: int, release_start_ratio: float) -> float:
	if i < attack:
		return float(i) / float(attack)
	var release_start := int(float(total) * release_start_ratio)
	if i >= release_start:
		return max(0.0, float(total - i) / float(total - release_start))
	return 1.0

func _generate_jump() -> PackedFloat32Array:
	var duration := 0.18
	var total := int(SAMPLE_RATE * duration)
	var samples := PackedFloat32Array()
	samples.resize(total)

	var start_freq := 300.0
	var end_freq := 950.0
	var phase := 0.0
	var attack := int(0.01 * SAMPLE_RATE)

	for i in range(total):
		var t := float(i) / float(total)
		var freq: float = lerp(start_freq, end_freq, t)
		phase += freq / SAMPLE_RATE
		var env := _envelope(i, total, attack, 0.25)
		samples[i] = clampf(_square(phase) * 0.35 * env, -1.0, 1.0)

	return samples

func _generate_death() -> PackedFloat32Array:
	var duration := 0.7
	var total := int(SAMPLE_RATE * duration)
	var samples := PackedFloat32Array()
	samples.resize(total)

	var start_freq := 500.0
	var end_freq := 50.0
	var phase := 0.0
	var attack := int(0.005 * SAMPLE_RATE)
	var noise_len := int(0.08 * SAMPLE_RATE)

	for i in range(total):
		var t := float(i) / float(total)
		var freq: float = lerp(start_freq, end_freq, t)
		phase += freq / SAMPLE_RATE
		var tone_env := _envelope(i, total, attack, 0.35)
		var value := _square(phase) * 0.32 * tone_env

		if i < noise_len:
			var decay := 1.0 - float(i) / float(noise_len)
			value += randf_range(-1.0, 1.0) * 0.35 * decay

		samples[i] = clampf(value, -1.0, 1.0)

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
