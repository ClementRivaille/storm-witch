extends Node2D
class_name MusicManager

@export var fade_duration: float = 0.6
@export var fade_delay: float = 0.35
@export var min_volume: float = -60.0

@onready var store: Store = StoreState
@onready var timer: Timer = $Timer

@onready var drops: SamplerInstrument = $Instruments/Drops
@onready var piano: SamplerInstrument = $Instruments/Piano
@onready var piano_rev: SamplerInstrument = $Instruments/PianoRev

var players: Array[AudioStreamPlayer] = []
var tween_in: Tween
var tween_out: Tween
var playing_level := -1

var levels_notes: Array = [
  ["A", "C", "D", "F", "E", "G"],
  ["B", "D", "E", "G", "A", "C"],
  ["A#", "D", "E", "G", "A"],
  ["G", "A#", "D", "E", "F#", "A"],
  ["A", "A#", "D", "E", "G", "C"],
]
var chords: Array = [
  [["A", 5], ["C", 6], ["G", 6], ["A", 6]],
  [["B", 5], ["D", 6], ["E", 6], ["G", 6]],
  [["G", 5], ["A#", 5], ["D", 6], ["E", 6]],
  [["A#", 5], ["D", 6], ["E", 6], ["F#", 6]],
  [["A", 5], ["D", 6], ["E", 6], ["A", 6]],
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  for player in $Players.get_children():
    players.push_back(player)
    
  timer.wait_time = fade_delay
  store.change_level.connect(play_level)
  store.pearl_obtained.connect(play_drop)


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

func play_drop():
  var notes = levels_notes[playing_level]
  var note: String = notes.pick_random()
  drops.play_note(note, 6)

func play_hit():
  var notes = levels_notes[playing_level]
  var noteA: String = notes.pick_random()
  var noteB: String = notes.pick_random()
  while noteB == noteA:
    noteB = notes.pick_random()
    
  
  piano.play_note(noteA, randi_range(6,7))
  piano.play_note(noteB, randi_range(6,7))

func play_chord():
  var chord: Array = chords[playing_level]
  for note in chord:
    piano_rev.play_note(note[0], note[1])
