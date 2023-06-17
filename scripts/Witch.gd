extends CharacterBody2D
class_name Witch

@export var max_speed: float = 300.0
@export var acceleration: float = 20.0
@export var speed_up: float = 50.0
@export var momentum_speed: float = 20.0

@export var deceleration_factor: float = 0.4
@export var lose_momentum: float = 0.001

@export var jump_strength: float = 100.0

const VELOCITY_FLOOR := 5.0

@export var jump_time: float = 0.1
@export var demage_time: float = 0.3

var locked := false
var momentum: float = 0.0

@onready var lock: Timer = $Lock
@onready var debug: Label = $debug

signal collect_pearl
signal fall
signal rise

func _physics_process(delta: float) -> void:
  if is_on_wall() && !locked:
    velocity.y = 0
  
  # steer
  var direction := Input.get_axis("up", "down")
  if direction && !locked:
    if direction > 0:
      if absf(velocity.y) < max_speed:
        velocity.y = velocity.y + acceleration
    else:
      velocity.y = maxf(velocity.y - acceleration - momentum_speed * momentum, - speed_up - max_speed * momentum)
  
  if absf(velocity.y) > 0.0 && (!direction || locked):
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

func _input(event: InputEvent) -> void:
  if event.is_action_pressed("jump") && !locked:
    locked = true
    velocity.y = -jump_strength
    
    lock.wait_time = jump_time
    lock.start()
    await lock.timeout
    locked = false


func on_collider_body_entered(body: Node2D) -> void:
  if (body is PearlDrop):
    var pearl := body as PearlDrop
    pearl.on_collect()
    collect_pearl.emit()
