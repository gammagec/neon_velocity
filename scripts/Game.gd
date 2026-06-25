extends Node2D

const CHUNK_WIDTH := 400.0
const VIEWPORT_WIDTH := 960.0
const SPAWN_BUFFER := 200.0
const RECYCLE_MARGIN := 100.0

const SPEED_START := 260.0
const SPEED_RAMP := 6.0
const SPEED_MAX := 640.0

const MUSIC_PITCH_MAX := 1.4

const LAYER_WRAP_WIDTH := 960.0
const MOUNTAIN_PARALLAX := 0.2
const FOREST_PARALLAX := 0.5

const BIRD_MIN_INTERVAL := 4.0
const BIRD_MAX_INTERVAL := 9.0

const CLOUD_MIN_INTERVAL := 3.0
const CLOUD_MAX_INTERVAL := 7.0
const CLOUD_TEXTURES := [
	preload("res://assets/background/cloud_small.png"),
	preload("res://assets/background/cloud_large.png"),
]

const CHUNK_FLAT := preload("res://scenes/chunks/ChunkFlat.tscn")
const CHUNK_SINGLE_SPIKE := preload("res://scenes/chunks/ChunkSingleSpike.tscn")
const CHUNK_DOUBLE_SPIKE := preload("res://scenes/chunks/ChunkDoubleSpike.tscn")
const CHUNK_GAP := preload("res://scenes/chunks/ChunkGap.tscn")
const CHUNK_RAISED_BLOCK := preload("res://scenes/chunks/ChunkRaisedBlock.tscn")
const CHUNK_FOREST_PLATFORM := preload("res://scenes/chunks/ChunkForestPlatform.tscn")
const BIRD_SCENE := preload("res://scenes/Bird.tscn")
const CLOUD_SCENE := preload("res://scenes/Cloud.tscn")

var scroll_speed := SPEED_START
var spawn_x := 0.0
var chunks_spawned := 0
var score := 0.0
var game_over := false
var active_chunks: Array[Node2D] = []
var bird_timer := 0.0
var bird_next := 0.0
var cloud_timer := 0.0
var cloud_next := 0.0

func _ready() -> void:
	$Player.died.connect(_on_player_died)
	_fill_initial_chunks()
	bird_next = randf_range(BIRD_MIN_INTERVAL, BIRD_MAX_INTERVAL)
	cloud_next = randf_range(CLOUD_MIN_INTERVAL, CLOUD_MAX_INTERVAL)
	$HUD.set_best(HighScore.value)

	var music_stream: AudioStream = $Music.stream
	if music_stream is AudioStreamWAV:
		music_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		music_stream.loop_begin = 0
		music_stream.loop_end = music_stream.data.size() / 2

func _process(delta: float) -> void:
	if game_over:
		return

	scroll_speed = min(SPEED_MAX, scroll_speed + SPEED_RAMP * delta)
	$World.position.x -= scroll_speed * delta
	score += scroll_speed * delta * 0.05
	$HUD.set_score(int(score))

	var speed_t := (scroll_speed - SPEED_START) / (SPEED_MAX - SPEED_START)
	$Music.pitch_scale = lerp(1.0, MUSIC_PITCH_MAX, clamp(speed_t, 0.0, 1.0))

	_scroll_layer($MountainsLayer, scroll_speed * MOUNTAIN_PARALLAX * delta)
	_scroll_layer($ForestLayer, scroll_speed * FOREST_PARALLAX * delta)
	_update_birds(delta)
	_update_clouds(delta)

	_spawn_ahead()
	_recycle_behind()

func _scroll_layer(layer: Node2D, amount: float) -> void:
	layer.position.x -= amount
	if layer.position.x <= -LAYER_WRAP_WIDTH:
		layer.position.x += LAYER_WRAP_WIDTH

func _update_birds(delta: float) -> void:
	bird_timer += delta
	if bird_timer >= bird_next:
		bird_timer = 0.0
		bird_next = randf_range(BIRD_MIN_INTERVAL, BIRD_MAX_INTERVAL)
		_spawn_bird()

func _spawn_bird() -> void:
	var bird: Node2D = BIRD_SCENE.instantiate()
	bird.position = Vector2(VIEWPORT_WIDTH + 20.0, randf_range(40.0, 160.0))
	$BirdsLayer.add_child(bird)

func _update_clouds(delta: float) -> void:
	cloud_timer += delta
	if cloud_timer >= cloud_next:
		cloud_timer = 0.0
		cloud_next = randf_range(CLOUD_MIN_INTERVAL, CLOUD_MAX_INTERVAL)
		_spawn_cloud()

func _spawn_cloud() -> void:
	var cloud: Sprite2D = CLOUD_SCENE.instantiate()
	cloud.texture = CLOUD_TEXTURES[randi() % CLOUD_TEXTURES.size()]
	cloud.position = Vector2(VIEWPORT_WIDTH + 80.0, randf_range(20.0, 140.0))
	$CloudsLayer.add_child(cloud)

func _fill_initial_chunks() -> void:
	_spawn_ahead()

func _spawn_ahead() -> void:
	while $World.position.x + spawn_x < VIEWPORT_WIDTH + SPAWN_BUFFER:
		_spawn_next_chunk()

func _recycle_behind() -> void:
	for chunk in active_chunks.duplicate():
		if chunk.global_position.x + CHUNK_WIDTH < -RECYCLE_MARGIN:
			chunk.queue_free()
			active_chunks.erase(chunk)

func _spawn_next_chunk() -> void:
	var scene: PackedScene = _pick_chunk_scene()
	var chunk: Node2D = scene.instantiate()
	chunk.position = Vector2(spawn_x, 0)
	$World.add_child(chunk)
	active_chunks.append(chunk)
	spawn_x += CHUNK_WIDTH
	chunks_spawned += 1

func _pick_chunk_scene() -> PackedScene:
	if chunks_spawned < 2:
		return CHUNK_FLAT

	var pool: Array[PackedScene] = [CHUNK_FLAT, CHUNK_FLAT, CHUNK_SINGLE_SPIKE, CHUNK_SINGLE_SPIKE]
	if score > 15.0:
		pool.append(CHUNK_GAP)
		pool.append(CHUNK_DOUBLE_SPIKE)
	if score > 40.0:
		pool.append(CHUNK_RAISED_BLOCK)
		pool.append(CHUNK_FOREST_PLATFORM)

	return pool[randi() % pool.size()]

func _on_player_died() -> void:
	if game_over:
		return
	game_over = true
	$Music.stop()
	for bird in $BirdsLayer.get_children():
		bird.set_process(false)
		bird.stop()
	for cloud in $CloudsLayer.get_children():
		cloud.set_process(false)

	var is_new_record := HighScore.try_set(int(score))
	$HUD.set_best(HighScore.value)
	$GameOverLayer.show_game_over(int(score), HighScore.value, is_new_record)
