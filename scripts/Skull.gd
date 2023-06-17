extends CharacterBody2D
class_name Skull

@export var aim_position: float = 1200.0
@export var init_velocity: float = 500.0
@export var throw_velocity: float = 1000.0

@export var aiming_time := 1.4
@export var prelaunch_time := 0.3
@export var prelaunch_modulate: Color

signal exit

@onready var timer: Timer = $Timer

var player: Witch
var state: SkullState = SkullState.Coming

enum SkullState {
  Coming,
  Aiming,
  Prelaunch,
  Launched
}

func _ready() -> void:
  player = get_tree().get_first_node_in_group("witch")
  velocity = Vector2(-init_velocity, 0)

func _process(delta: float) -> void:
  if state == SkullState.Coming:
    if global_position.x <= aim_position:
      velocity = Vector2.ZERO
      aim_and_launch()
      
  if state == SkullState.Aiming:
    rotation = PI + global_position.angle_to_point(player.global_position)
  
  elif state == SkullState.Launched:
    if global_position.x < -100:
      exit.emit(self)
  
  move_and_slide()
      
func aim_and_launch() -> void:
  state = SkullState.Aiming
  timer.wait_time = aiming_time
  timer.start()
  await timer.timeout
  
  state = SkullState.Prelaunch
  modulate = prelaunch_modulate
  timer.wait_time = prelaunch_time
  timer.start()
  await timer.timeout
  
  state = SkullState.Launched
  modulate = Color.WHITE
  var direction := global_position.direction_to(player.global_position)
  velocity = direction * throw_velocity
  move_and_slide()
