extends Node2D
class_name MusicManager

@export var fade_duration: float = 0.6
@export var fade_delay: float = 0.35
@export var min_volume: float = -60.0

@onready var store: Store = StoreState
@onready var timer: Timer = $Timer

var players: Array[AudioStreamPlayer] = []
var tween_in: Tween
var tween_out: Tween
var playing_level := -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  for player in $Players.get_children():
    players.push_back(player)
    
  timer.wait_time = fade_delay
  store.change_level.connect(play_level)


func play_level(level: int) -> void:
  var previous_idx = playing_level
  playing_level = level
  
  if level < players.size():
    var play_in := players[level]
  
    if (tween_in && tween_in.is_running()):
      tween_in.kill()    
    tween_in = create_tween()
    
    
    tween_in.tween_property(play_in, "volume_db", 0.0, fade_duration
      ).set_ease(Tween.EASE_IN_OUT
      ).set_trans(Tween.TRANS_SINE)
      
    timer.start()
    await timer.timeout
      
  if previous_idx >= 0:
    var play_out := players[previous_idx]
    if (tween_out && tween_out.is_running()):
      tween_out.kill()
    tween_out = create_tween()
    tween_out.tween_property(play_out, "volume_db", min_volume, fade_duration
      ).set_ease(Tween.EASE_IN_OUT
      ).set_trans(Tween.TRANS_SINE)

