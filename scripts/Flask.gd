extends Control
class_name Flask

@onready var store: Store = StoreState
@onready var fill: Control = $Fill
@onready var sparkles: TextureRect = $Sparkles

@export var empty_modulate: Color

var tween: Tween

func _ready() -> void:
  store.pearls_updated.connect(update_fill)
  store.pearls_consumed.connect(use_flask)
  store.change_level.connect(func (_lvl): use_flask())
  fill.anchor_bottom = 0.0
  modulate = empty_modulate

func update_fill(nb_pearls: int):
  var level: float = float(nb_pearls) / float(store.max_pearls)
  if (tween && tween.is_running()):
    tween.kill()

  tween = create_tween()
  tween.set_parallel(true)
  tween.tween_property(fill, "anchor_bottom", level, 0.2
    ).set_ease(Tween.EASE_IN_OUT
    ).set_trans(Tween.TRANS_SINE)
    
  if modulate.a < 1 && store.can_jump():
    tween.tween_property(self, "modulate", Color.WHITE, 0.1
      ).set_ease(Tween.EASE_IN
      ).set_trans(Tween.TRANS_SINE)
  elif !store.can_jump() && modulate.a == 1:
    tween.tween_property(self, "modulate", empty_modulate, 0.1
      ).set_ease(Tween.EASE_OUT
      ).set_trans(Tween.TRANS_SINE)
      
  if store.can_levelup() && sparkles.self_modulate.a == 0:
    tween.tween_property(sparkles, "self_modulate", Color.WHITE, 0.2
    ).set_ease(Tween.EASE_OUT
    ).set_trans(Tween.TRANS_SINE)

func use_flask():
  sparkles.self_modulate = Color.WHITE
  
  var sparkles_tween = create_tween()
  sparkles_tween.tween_property(sparkles, "self_modulate", Color.TRANSPARENT, 0.4
    ).set_ease(Tween.EASE_IN
    ).set_trans(Tween.TRANS_SINE)
