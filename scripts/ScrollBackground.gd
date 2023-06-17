extends Node2D
class_name ScrollBackground

@onready var parallax: ParallaxBackground = $Parallax
@onready var foreground: Node2D = $Foreground
var fg_clone: Node2D

@export var speed: float = 100.0
@export var foreground_width: float = 1024 * 2.5

var active := false

func init():
  parallax.set_scroll_offset(Vector2(0,0))
  foreground.position.x = 0
  clone_foreground(0.0)
  
  for l in parallax.get_children():
    var layer := l as ScrollableLayer
    layer.init()
    
  active = true
  set_bg_visible(true)
  
func deactivate():
  active = false
  fg_clone.queue_free()
  set_bg_visible(false)

func _process(delta: float) -> void:
  if active:
    scroll(delta)

func scroll(delta: float):
  # foreground
  if foreground.visible:
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
  
func set_bg_visible(value: bool):
  visible = value
  parallax.visible = value
