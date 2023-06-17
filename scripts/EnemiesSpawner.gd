extends Node2D
class_name EnnemiesSpawner

@export var bird_prefab: PackedScene
@export var skull_prefab: PackedScene

@onready var timer: Timer = $Timer
@onready var store: Store = StoreState

var spawn_freq_range: Array[float] = [3.0, 7.0]
var bird_chance: int = 1
var skull_chance: int = 1

@export var min_height: float = 20.0
@export var max_height: float = 700

var active := false
var enemies: Array[Node2D] = []

func _ready() -> void:
  timer.connect("timeout", spawn_enemy)
  store = StoreState
  store.change_level.connect(func (_idx): clear())
  
func configure(freq: Array[float], bird_c: int, skull_c: int) -> void:
  bird_chance = bird_c
  skull_chance = skull_c
  spawn_freq_range = freq
  
func activate():
  active = true
  schedule_spawn()
  
func deactivate():
  active = false
  
func schedule_spawn():
  timer.wait_time = randf_range(spawn_freq_range[0], spawn_freq_range[1])
  timer.start()
  
func spawn_enemy():
  if !active:
    return
  
  var dice := bird_chance + skull_chance
  var result = randi()%dice
  var prefab: PackedScene = bird_prefab if result < bird_chance else skull_prefab
  
  var enemy: Node2D = prefab.instantiate()
  enemy.position.y = randf_range(min_height, max_height)
  add_child(enemy)
  enemy.connect("exit", remove_enemy)
  enemies.push_front(enemy)

  schedule_spawn()
  
func remove_enemy(enemy: Node2D):
  enemies.erase(enemy)
  enemy.queue_free()

func clear():
  for mob in enemies:
    mob.queue_free()
  enemies.clear()
  timer.stop()
  schedule_spawn()
