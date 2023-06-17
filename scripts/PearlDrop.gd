extends RigidBody2D
class_name PearlDrop

signal collected
signal missed

func set_speed(scroll_speed: float, fall_speed: float):
  set_axis_velocity(Vector2(- scroll_speed, fall_speed))

func on_collect():
  collected.emit(self)

func _process(_delta: float) -> void:
  if global_position.x < -100:
    missed.emit(self)
