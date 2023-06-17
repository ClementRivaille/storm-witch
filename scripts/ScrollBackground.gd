extends Node2D
class_name ScrollBackground

@onready var parallax: ParallaxBackground = $Parallax
@onready var foreground: Node2D = $Foreground
var fg_clone: Node2D

@export var speed: float = 100.0
@export var foreground_width: float = 1024 * 2.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  init()
  
func init():
  parallax.set_scroll_offset(Vector2(0,0))
  foreground.position.x = 0
  clone_foreground(0.0)
  
  for l in parallax.get_children():
    var layer := l as ScrollableLayer
    layer.init()

func _process(delta: float) -> void:
  scroll(delta)

func scroll(delta: float):
  # foreground
  foreground.position.x = foreground.position.x - delta * speed
  fg_clone.position.x = fg_clone.position.x - delta * speed
  if (fg_clone.position.x <= 0):
    foreground.queue_free()
    foreground = fg_clone
    clone_foreground(fg_clone.position.x)

  # Parallax
  parallax.set_scroll_offset(parallax.scroll_offset + Vector2(-speed*delta, 0))
  for l in parallax.get_children():
    var layer := l as ScrollableLayer
    layer.update(parallax.scroll_offset.x)

func clone_foreground(offset: float):
  fg_clone = foreground.duplicate()
  fg_clone.position.x = foreground_width + offset
  add_child(fg_clone)
  
func set_speed(scroll_speed: float):
  speed = scroll_speed
