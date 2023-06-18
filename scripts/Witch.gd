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

@export var angle_up: float = -40.0
@export var angle_down: float = 60.0


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
@onready var sprite: Sprite2D = $Sprite
@onready var store: Store = StoreState
@onready var animation_state_machine: AnimationNodeStateMachinePlayback
@onready var broomSFX: BroomFX = $BroomFX

signal collect_pearl
signal fall
signal rise_start
signal rise_stop

func _ready() -> void:
  animation_state_machine = $AnimationTree.get("parameters/playback")
  broomSFX.vel_max = max_speed

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
  broomSFX.update_sound(r_velocity.y, momentum)
  
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
      animation_state_machine.travel(("SteerDown"))
      if absf(velocity.y) < max_speed:
        velocity.y = velocity.y + acceleration
    else:
      # up
      animation_state_machine.travel("SteerUp")
      velocity.y = maxf(velocity.y - acceleration - momentum_speed * momentum, - speed_up - max_speed * momentum)
  
  # Lose velocity when not moving
  if absf(velocity.y) > 0.0 && (!direction || locked):
    velocity.y = velocity.y * deceleration_factor
    if absf(velocity.y) < 0.0000001:
      velocity.y = 0.0
      
  if !direction && !locked:
    animation_state_machine.travel("Idle")

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
  broomSFX.start_rise()
  
  if (global_position.y < rise_y_threshold):
    animation = AnimationState.Recentering
  else:
    animation = AnimationState.ExitUp
    
func rise_auto():
  var down = animation == AnimationState.Recentering
  velocity.y = velocity.y + acceleration * (1 if down else -1)
  
  if animation == AnimationState.Recentering:
    animation_state_machine.travel(("SteerDown"))
    if global_position.y >= rise_y_threshold:
      animation = AnimationState.ExitUp
  elif animation == AnimationState.ExitUp:
    animation_state_machine.travel("SteerUp")
    velocity.y = maxf(velocity.y, -rise_speed)
    if global_position.y < rise_y_limit:
      # warp down
      position.y = get_viewport_rect().size.y - rise_y_limit
      animation = AnimationState.EnteringUp
      store.levelup()
  elif animation == AnimationState.EnteringUp:
    animation_state_machine.travel("SteerUp")
    velocity.y = maxf(velocity.y, -rise_speed)
    if (global_position.y <= rise_y_end):
      set_collision_mask_value(COLLISION_LAYER, true)
      animation = AnimationState.None
      broomSFX.end_rise()
      rise_stop.emit()
      
func fall_auto():
  velocity.y = minf(velocity.y + fall_acceleration, max_speed)
  
  if animation == AnimationState.FallingThrough:
    if store.can_jump() && global_position.y >= SAFE_CHECK:
      jump()
      animation = AnimationState.None
      set_collision_mask_value(COLLISION_LAYER, true)
      animation_state_machine.travel("Idle")
    if global_position.y >= get_viewport_rect().size.y - rise_y_limit:
      position.y = rise_y_limit
      animation = AnimationState.EnteringDown
      store.level_drop()
  elif animation == AnimationState.EnteringDown:
    if global_position.y >= fall_y_end:
      set_collision_mask_value(COLLISION_LAYER, true)
      animation_state_machine.travel("Idle")
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
  animation_state_machine.travel("Falling")
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
    animation_state_machine.travel("Idle")
