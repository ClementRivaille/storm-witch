extends Node2D
class_name Main

@export var scroll_speed: float = 500
@export var levels: Array[LevelConfiguration] = []

@onready var pearl_spanwer: PearlSpawner = $PearlSpawner
@onready var backgrounds: Node2D = $Background
@onready var skies: CanvasLayer = $Sky

@onready var store: Store = StoreState

var current_bg: ScrollBackground
var current_sky: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  get_tree().call_group("scrollable", "set_speed", scroll_speed)
  store.change_level.connect(switch_level)
  
  for bg in backgrounds.get_children():
    var background := bg as ScrollBackground
    bg.set_bg_visible(false)
  
  start_game()
  
func start_game():
  switch_level(0)
  
  pearl_spanwer.activate()
  
func switch_level(idx: int):
  var level := levels[idx]
  var background: ScrollBackground = get_node(level.background)
  if (background != current_bg):
    if current_bg:
      current_bg.deactivate()
    current_bg = background
    current_bg.init()
    
  var sky: Sprite2D = get_node(level.sky)
  if sky != current_sky:
    if current_sky:
      current_sky.visible = false
    sky.visible = true
    current_sky = sky
