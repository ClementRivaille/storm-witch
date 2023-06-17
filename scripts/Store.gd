extends Node2D
class_name Store

@export var max_pearls := 10
@export var jump_cost := 3
@export var levelup_cost := 5

var pearls := 0

signal pearls_updated(value: int)
signal pearls_consumed

func collect_pearl():
  pearls = mini(pearls+ 1, max_pearls)
  pearls_updated.emit(pearls)

func can_jump() -> bool:
  return pearls >= jump_cost
  
func can_levelup() -> bool:
  return pearls >= max_pearls
  
func jump():
  pearls = maxi(pearls - jump_cost, 0)
  pearls_updated.emit(pearls)
  pearls_consumed.emit()

func levelup():
  pearls = maxi(pearls - levelup_cost, 0)
  pearls_updated.emit(pearls)
