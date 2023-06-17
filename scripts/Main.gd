extends Node2D
class_name Main

@export var scroll_speed: float = 500

@export var levels: Array[LevelConfiguration] = []

@onready var pearl_spanwer: PearlSpawner = $PearlSpawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  get_tree().call_group("scrollable", "set_speed", scroll_speed)
  pearl_spanwer.activate()

