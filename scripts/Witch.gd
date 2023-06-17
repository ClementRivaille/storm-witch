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
const COLLISION_LAYER := 1
const SAFE_CHECK := 640.0

@export var jump_time: float = 0.1
@export var demage_time: float = 0.3

@export var rise_y_threshold: float = 200.0
@export var rise_y_limit: float = -50.0
@export var rise_y_end: float = 500.0
@export var rise_speed: float = 800.0

@export var fall_acceleration: float = 30.0
@export var fall_duration: float = 0.4
@export var fall_through_limit: float = 450.0
@export var fall_y_end: float = 200.0


enum AnimationState {
  None,
  Recentering,
  ExitUp,
  EnteringUp,
  Falling,
  FallingThrough,
  EnteringDown,
}

var locked := false
var animation := AnimationState.None
var momentum: float = 0.0

@onready var lock: Timer = $Lock
@onready var debug: Label = $debug
@onready var store: Store = StoreState

signal collect_pearl
signal fall
signal rise_start
signal rise_stop

func _physics_process(_delta: float) -> void:
  if animation == AnimationState.None:
    steer_broom()
  elif is_falling():
    fall_auto()
  else:
    rise_auto()

  # momentum
  var r_velocity := get_real_velocity()
  if (r_velocity.y > VELOCITY_FLOOR):
    momentum = maxf(momentum, r_velocity.y / max_speed)
  elif momentum > 0:
    momentum = maxf(0, momentum - lose_momentum)
   
  if (debug.visible):
    debug.text = "Y %s  FT %s" % [global_position.y, global_position.y > fall_through_limit]

  move_and_slide()
  
func is_falling() -> bool:
  return [
      AnimationState.Falling,
      AnimationState.FallingThrough,
      AnimationState.EnteringDown
    ].has(animation)

func steer_broom():
  if is_on_wall() && !locked:
    velocity.y = 0

  var direction := Input.get_axis("up", "down")
  # Move with constrols
  if direction && !locked:
    if direction > 0:
      # down
      if absf(velocity.y) < max_speed:
        velocity.y = velocity.y + acceleration
    else:
      # up
      velocity.y = maxf(velocity.y - acceleration - momentum_speed * momentum, - speed_up - max_speed * momentum)
  
  # Lose velocity when not moving
  if absf(velocity.y) > 0.0 && (!direction || locked):
    velocity.y = velocity.y * deceleration_factor
    if absf(velocity.y) < 0.0000001:
      velocity.y = 0.0

func _input(event: InputEvent) -> void:
  if event.is_action_pressed("jump") && !locked && animation == AnimationState.None:
    if store.can_levelup():
      start_rising()
      
    elif store.can_jump():
      jump()
      
func jump():
  locked = true
  velocity.y = -jump_strength
  store.jump(false)
  
  lock.wait_time = jump_time
  lock.start()
  await lock.timeout
  locked = false
  
func start_rising():
  store.jump(true)
  rise_start.emit()
  set_collision_mask_value(COLLISION_LAYER, false)
  
  if (global_position.y < rise_y_threshold):
    animation = AnimationState.Recentering
  else:
    animation = AnimationState.ExitUp
    
func rise_auto():
  var down = animation == AnimationState.Recentering
  velocity.y = velocity.y + acceleration * (1 if down else -1)
  
  if animation == AnimationState.Recentering:
    if global_position.y >= rise_y_threshold:
      animation = AnimationState.ExitUp
  elif animation == AnimationState.ExitUp:
    velocity.y = maxf(velocity.y, -rise_speed)
    if global_position.y < rise_y_limit:
      # warp down
      position.y = get_viewport_rect().size.y - rise_y_limit
      animation = AnimationState.EnteringUp
      store.levelup()
  elif animation == AnimationState.EnteringUp:
    velocity.y = maxf(velocity.y, -rise_speed)
    if (global_position.y <= rise_y_end):
      set_collision_mask_value(COLLISION_LAYER, true)
      animation = AnimationState.None
      rise_stop.emit()
      
func fall_auto():
  velocity.y = minf(velocity.y + fall_acceleration, max_speed)
  
  if animation == AnimationState.FallingThrough:
    if store.can_jump() && global_position.y >= SAFE_CHECK:
      jump()
      animation = AnimationState.None
      set_collision_mask_value(COLLISION_LAYER, true)      
    if global_position.y >= get_viewport_rect().size.y - rise_y_limit:
      position.y = rise_y_limit
      animation = AnimationState.EnteringDown
      store.level_drop()
  elif animation == AnimationState.EnteringDown:
    if global_position.y >= fall_y_end:
      set_collision_mask_value(COLLISION_LAYER, true)
      animation = AnimationState.None

func on_collider_body_entered(body: Node2D) -> void:
  if animation != AnimationState.None:
    return

  if (body is PearlDrop):
    var pearl := body as PearlDrop
    pearl.on_collect()
    collect_pearl.emit()
  elif body.is_in_group("enemy"):
    start_falling()
    
func start_falling():
  fall.emit()
  if global_position.y > fall_through_limit:
    set_collision_mask_value(COLLISION_LAYER, false)
    animation = AnimationState.FallingThrough
  else:
    animation = AnimationState.Falling
    if !lock.is_stopped():
      lock.stop()
    lock.wait_time = fall_duration
    lock.start()
    await lock.timeout
    animation = AnimationState.None
