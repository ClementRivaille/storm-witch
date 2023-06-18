extends Node2D
class_name Store

@export var max_pearls := 10
@export var jump_cost := 3
@export var levelup_cost := 6

var pearls := 0
var current_level := 0

signal pearls_updated(value: int)
signal pearls_consumed
signal change_level(value: int)

func collect_pearl():
  pearls = mini(pearls+ 1, max_pearls)
  pearls_updated.emit(pearls)

func can_jump() -> bool:
  return pearls >= jump_cost
  
func can_levelup() -> bool:
  return pearls >= max_pearls
  
func jump(levelup: bool):
  pearls = maxi(pearls - (levelup_cost if levelup else jump_cost), 0)
  pearls_updated.emit(pearls)
  pearls_consumed.emit()

func levelup():
  current_level = current_level + 1
  change_level.emit(current_level)
  
func level_drop():
  if current_level > 0:
    current_level -= 1
    change_level.emit(current_level)
