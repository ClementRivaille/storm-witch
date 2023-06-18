extends Node2D
class_name End

@export var island_speed: float = 0.25
@export var scroll_delay: float = 4.0
@export var music_delay: float = 6.0

@export var credits_wait: float = 18.4
@export var fadeout_wait: float = 27.4

@export var end_level: int = 5

signal start_credit
signal done

@onready var island: Sprite2D = $IslandLayer/Sprite2D
@onready var player: AudioStreamPlayer = $AudioStreamPlayer
@onready var timer: Timer = $Timer
@onready var black_screen: ColorRect = $BlackScreen
@onready var store: Store = StoreState

var scrolling := false

func _ready() -> void:
  store.change_level.connect(on_change_level)

func _process(_delta: float) -> void:
  if scrolling:
    island.position.x = island.position.x - island_speed
    
func on_change_level(level: int):
  if level == end_level:
    begin()

func begin():
  set_timer(scroll_delay)
  await timer.timeout
  
  scrolling = true
  set_timer(music_delay)
  await timer.timeout
  
  player.play()
  set_timer(credits_wait)
  await timer.timeout
  
  start_credit.emit()
  set_timer(fadeout_wait)
  await timer.timeout
  
  var tween := create_tween()
  tween.tween_property(black_screen, "modulate", Color.WHITE, 4.0
    ).set_trans(Tween.TRANS_SINE
    ).set_ease(Tween.EASE_IN_OUT)
  await tween.finished
  
  done.emit()
  scrolling = false
  
func set_timer(time: float):
  timer.wait_time = time
  timer.start()
