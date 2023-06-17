extends CharacterBody2D
class_name Witch

@export var max_speed: float = 300.0
@export var acceleration: float = 20.0
@export var speed_up: float = 50.0
@export var momentum_speed: float = 20.0

@export var deceleration_factor: float = 0.4
@export var lose_momentum: float = 0.001

const VELOCITY_FLOOR := 5.0

var momentum: float = 0.0

@onready var debug: Label = $debug

func _physics_process(delta: float) -> void:
  if is_on_wall():
    velocity.y = 0
  
  # steer
  var direction := Input.get_axis("ui_up", "ui_down")
  if direction:
    if direction > 0:
      if absf(velocity.y) < max_speed:
        velocity.y = velocity.y + acceleration
    else:
      velocity.y = maxf(velocity.y - acceleration - momentum_speed * momentum, - speed_up - max_speed * momentum)
  elif absf(velocity.y) > 0.0:
    velocity.y = velocity.y * deceleration_factor
    if absf(velocity.y) < 0.0000001:
      velocity.y = 0.0
    
  # momentum
  var r_velocity := get_real_velocity()
  if (r_velocity.y > VELOCITY_FLOOR):
    momentum = maxf(momentum, r_velocity.y / max_speed)
  elif momentum > 0:
    momentum = maxf(0, momentum - lose_momentum)
   
  if (debug.visible):
    debug.text = "M %s  V %s" % [momentum, velocity.y]

  move_and_slide()
