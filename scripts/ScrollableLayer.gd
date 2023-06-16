extends ParallaxLayer
class_name ScrollableLayer

@export var width := 1024.0 * 2.5
var iteration := 1
var half := false

func init():
  iteration = 1
  half = false
  copy_texture()

func copy_texture():
  var clone: Polygon2D = get_child(0).duplicate()
  clone.position.x = width * iteration
  add_child(clone)
  
func update(offset: float):
  var distance := fmod(absf(offset) * motion_scale.x, width)
  
  if (half && distance <= 100.0):
    iteration += 1
    copy_texture()
    var past_texture: Polygon2D = get_child(0)
    past_texture.queue_free()
  
  half = distance > width / 2.0
