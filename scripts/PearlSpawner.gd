extends Node2D
class_name PearlSpawner

@export var min_delay: float = 0.6
@export var max_delay: float = 3.5

@export var min_height: float = 20.0
@export var max_height: float = 300.0

@export var drop_asset: PackedScene

@onready var timer: Timer = $Timer

var active := false
var drops: Array[PearlDrop] = []
var drops_speed := 500

func _ready() -> void:
  timer.connect("timeout", spawn_drop)
  
func set_speed(speed: float):
  drops_speed = speed
  
func activate():
  active = true
  schedule_spawn()
  
func spawn_drop():
  if !active:
    return
  
  var drop: PearlDrop = drop_asset.instantiate()
  drop.position.y = randf_range(min_height, max_height)
  add_child(drop)
  drop.collected.connect(remove_drop)
  drop.missed.connect(remove_drop)
  drop.set_speed(drops_speed, 100)
  drops.push_front(drop)

  schedule_spawn()

func schedule_spawn():
  timer.wait_time = randf_range(min_delay, max_delay)
  timer.start()

func remove_drop(drop: PearlDrop):
  drops.erase(drop)
  drop.queue_free()
  
func clear():
  for drop in drops:
    drop.queue_free()
  drops.clear()
