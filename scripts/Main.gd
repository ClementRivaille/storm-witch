extends Node2D
class_name Main

@export var scroll_speed: float = 500
@export var levels: Array[LevelConfiguration] = []

@onready var pearl_spanwer: PearlSpawner = $PearlSpawner
@onready var enemies_spawner: EnnemiesSpawner = $EnemiesSpawner
@onready var backgrounds: Node2D = $Background
@onready var skies: CanvasLayer = $Sky
@onready var darklight: DirectionalLight2D = $DarkLight
@onready var rain: GPUParticles2D = $Rain
@onready var music: MusicManager = $MusicManager
@onready var ui: UIManager = $CanvasLayer/UI

@onready var store: Store = StoreState

var current_bg: ScrollBackground
var current_sky: Sprite2D

var game_started := false
signal on_game_start

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  get_tree().call_group("scrollable", "set_speed", scroll_speed)
  store.change_level.connect(switch_level)
  
  for bg in backgrounds.get_children():
    var background := bg as ScrollBackground
    background.set_bg_visible(false)
    switch_level(0)
    
func _input(event: InputEvent) -> void:
  if !game_started && event.is_action_pressed("ui_accept"):
    start_game()
  
func start_game():
  game_started = true
  switch_level(0)
  rain.emitting = true
  ui.start_game()
  on_game_start.emit()

  
  pearl_spanwer.activate()
  music.play_level(0)
  
func switch_level(idx: int):
  var level := levels[idx]
  var background: ScrollBackground = get_node(level.background)
  if (background != current_bg):
    if current_bg:
      current_bg.deactivate()
    current_bg = background
    current_bg.init()
    
  var sky: Sprite2D = get_node(level.sky)
  if sky != current_sky:
    if current_sky:
      current_sky.visible = false
    sky.visible = true
    current_sky = sky
    
  var lighting: LevelConfiguration.LightingLevel = level.lighting
  if lighting == LevelConfiguration.LightingLevel.dimmed:
    darklight.energy = 0.2
  elif lighting == LevelConfiguration.LightingLevel.dark:
    darklight.energy = 0.4
  else:
    darklight.energy = 0
    
  enemies_spawner.configure(level.enemies_frq, level.bird_chance, level.skull_chance)
  if level.bird_chance + level.skull_chance > 0 && !enemies_spawner.active:
    enemies_spawner.activate()
  elif level.bird_chance + level.skull_chance == 0 && enemies_spawner.active:
    enemies_spawner.deactivate()
    
  if !level.rain:
    rain.visible = false
    pearl_spanwer.deactivate()
    enemies_spawner.deactivate()
    ui.hide_flask()

