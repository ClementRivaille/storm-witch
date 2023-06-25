extends Control
class_name Tutorial

@onready var steering: Control = $Steering
@onready var levelUp: Control = $LevelUp
@onready var boost: Control = $Boost
@onready var timer: Timer = $Timer
@onready var store: Store = StoreState

var tuto_levelup := false
var tuto_boost := false

func _ready() -> void:
  store.pearl_obtained.connect(on_pearl_obtained)
  store.pearls_consumed.connect(on_consume_pearl)
  store.change_level.connect(on_change_level)
  
  for screen in [steering, levelUp, boost]:
    screen.modulate = Color.TRANSPARENT

func ease_screen(screen: Control, dir_in: bool):
  var tween = create_tween()
  tween.tween_property(screen, "modulate", Color.WHITE if dir_in else Color.TRANSPARENT, 0.7
    ).set_trans(Tween.TRANS_SINE
    ).set_ease(Tween.EASE_IN_OUT)
    
func show_directions():
  ease_screen(steering, true)
  timer.start()
  await timer.timeout
  ease_screen(steering, false)
  
func on_pearl_obtained():
  if !tuto_levelup && store.can_levelup():
    ease_screen(levelUp, true)
  elif tuto_levelup && !tuto_boost && store.can_jump():
    ease_screen(boost, true)
    tuto_boost = true
    
func on_change_level(_idx: int):
  if !tuto_levelup:
    ease_screen(levelUp, false)
    tuto_levelup = true
    
func on_fall():
  if tuto_levelup && !tuto_boost && store.can_jump():
    ease_screen(boost, true)
    tuto_boost = true
    
func on_consume_pearl():
  if tuto_levelup:
    tuto_boost = true
    if boost.modulate.a == 1:
      ease_screen(boost, false)

