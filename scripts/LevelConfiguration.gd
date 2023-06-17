extends Resource
class_name LevelConfiguration

enum LightingLevel {
  dimmed,
  dark,
  light
}

@export var background: NodePath
@export var sky: NodePath
@export var lighting: LightingLevel
@export var rain: bool = true

@export var bird_chance: int = 0
@export var skull_chance: int = 0
@export var enemies_frq: Array[float] = [4.0, 8.0]
