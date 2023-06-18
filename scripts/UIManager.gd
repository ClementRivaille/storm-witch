extends Control
class_name UIManager

@onready var flask: Control = $Flask
@onready var start_screen: Control = $StartScreen
@onready var thanks: Control = $Thanks

@onready var store: Store = StoreState

func _ready() -> void:
  store.pearl_obtained.connect(on_pearl_obtained)

func start_game():
  start_screen.visible = false

func on_pearl_obtained():
  if !flask.visible:
    flask.visible = true
    store.pearl_obtained.disconnect(on_pearl_obtained)

func hide_flask():
  flask.visible = false

func show_thanks():
  var tween_in := create_tween()
  tween_in.tween_property(thanks, "modulate", Color.WHITE, 2.0
    ).set_ease(Tween.EASE_OUT
    ).set_trans(Tween.TRANS_SINE)
  await tween_in.finished
