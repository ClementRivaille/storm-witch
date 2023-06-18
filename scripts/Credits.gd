extends Control
class_name Credits

var labels: Array[Label] = []
var idx := 0

@export var fade_t: float = 0.8
@export var show_t: float = 6.0
@export var interval: float = 0.8

signal next_slide

@onready var timer: Timer = $Timer

func _ready() -> void:
  for l in $Slides.get_children():
    labels.push_back(l)
  
func show_slide():
  var label := labels[idx]
  
  var tween_in := create_tween()
  tween_in.tween_property(label, "modulate", Color.WHITE, fade_t
    ).set_ease(Tween.EASE_OUT
    ).set_trans(Tween.TRANS_SINE)
  await tween_in.finished
  
  timer.wait_time = show_t
  timer.start()
  await timer.timeout
  
  var tween_out := create_tween()
  tween_out.tween_property(label, "modulate", Color.TRANSPARENT, fade_t
    ).set_ease(Tween.EASE_IN
    ).set_trans(Tween.TRANS_SINE)
  await tween_out.finished
  
  next_slide.emit()
  
func start():
  idx = 0
  while idx < labels.size():
    show_slide()
    await next_slide
    
    idx += 1
    timer.wait_time = interval
    timer.start()
    await timer.timeout
