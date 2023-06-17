extends RigidBody2D
class_name Bird

signal exit

func _process(_delta: float) -> void:
  if (global_position.x < -100):
    exit.emit(self)
