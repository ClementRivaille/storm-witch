extends AudioStreamPlayer
class_name BroomFX

@export var min_pitch: float = 0.4
@export var max_pitch: float = 1.0
@export var min_vol: float = -60.0
@export var max_vol: float = 0.0

@export var vel_max: float = 300.0

var rise := false

func update_sound(velocityY: float, momentum: float):
  if !rise:
    volume_db = lerpf(min_vol, max_vol, momentum)
  var vel_weight: float = maxf(0, -velocityY) / vel_max
  pitch_scale = lerpf(min_pitch, max_pitch, vel_weight)

func start_rise():
  rise = true
  var tween := create_tween()
  tween.tween_property(self, "volume_db", 1.0, 0.2
    ).set_trans(Tween.TRANS_SINE
    ).set_ease(Tween.EASE_IN_OUT)
    
func end_rise():
  var tween := create_tween()
  tween.tween_property(self, "volume_db", min_vol, 0.8
    ).set_trans(Tween.TRANS_SINE
    ).set_ease(Tween.EASE_IN_OUT)
  await tween.finished
  rise = false
